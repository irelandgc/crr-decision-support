// Seed the AD-34 staging environment through the API worker's own admin routes.
//
// Staging's admin routes sit behind Cloudflare Access, and `wrangler dev --remote`
// cannot open a preview session on this account. So, in two stages:
//   A. Run the STAGING API worker code entirely on this machine (`wrangler dev
//      --env staging`, local D1/KV in a fresh temp folder, 127.0.0.1 only, one-off
//      admin key) and call the real admin routes, so every write gets the routes'
//      validation and KV/D1 bookkeeping, exactly as an Admin Tool action would.
//   B. Copy the result into the remote staging D1 and KV with wrangler (D1 rows as
//      INSERTs; KV with `kv bulk put`). Refuses if remote staging already holds
//      seeded data, so it never double-loads or overwrites.
// The remote targets are read from env.staging in public/crr-criteria/wrangler.json
// and checked to differ from the production ids. An empty --env-file stops wrangler
// loading public/crr-criteria/.dev.vars.
//
// What it loads:
//   1. Published criteria + match data + region overrides: copied from
//      production's PUBLIC read endpoints (content only; production is never
//      written). Writes through /api/admin/publish and /api/admin/regions/:id.
//   2. The active system prompt: copied from production's public
//      /api/system-prompt, created then activated through the prompt admin
//      routes (activation is what updates KV).
//   3. The latest bundle of national-redflags, CT CAP and CT Colonography from
//      tooling/criteria-bundle/registry, through /api/admin/bundles/publish, in
//      their real state (transcribed). With --demo-published they are then moved
//      transcribed -> signed-off -> published with a sign-off reference that says
//      they are NOT clinically signed off, so the new pipeline will evaluate them
//      on staging (AD-10: never on production without real sign-off).
// No audit, usage, QA or assessment rows are copied (AD-34).
//
// Usage (repo root):
//   node tooling/staging/seed-staging.mjs [--demo-published]
// Needs: `npx wrangler login`; staging runbook steps 1-5 done; port 8799 free.
// --demo-published is AD-35 (Accepted). To re-seed, empty remote staging first.
import { execFileSync, spawn } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const PROD_API = process.env.SEED_SOURCE || "https://crr-criteria-api.fk4dsrmq5r.workers.dev"; // test-only override
// Test-only: SEED_REMOTE_SIM=<dir> stands in for remote staging with a local folder.
const REMOTE_SIM = process.env.SEED_REMOTE_SIM;
const CONFIG = "public/crr-criteria/wrangler.json";
const PORT = 8799;
const BASE = `http://127.0.0.1:${PORT}`;
const ACTOR = "seed-staging@local";
const BUNDLES = ["national-redflags", "ct-chest-abdomen-pelvis-adult", "ct-colonography-adult"];
const TABLES = ["versions", "audit_log", "system_prompts", "system_prompt_audit", "bundles"]; // what the routes write
const DEMO_SIGNOFF = "STAGING DEMO ONLY: not clinically signed off (AD-10, AD-34)";
const demoPublished = process.argv.includes("--demo-published");
const ADMIN_KEY = crypto.randomBytes(32).toString("hex");

if (!fs.existsSync(CONFIG)) {
  console.error("Run this from the repo root.");
  process.exit(1);
}
const cfg = JSON.parse(fs.readFileSync(CONFIG, "utf8"));
const st = cfg.env?.staging;
const DB_NAME = st?.d1_databases?.[0]?.database_name;
const KV_ID = st?.kv_namespaces?.[0]?.id;
if (!DB_NAME || !KV_ID || st.d1_databases[0].database_id === cfg.d1_databases[0].database_id || KV_ID === cfg.kv_namespaces[0].id) {
  console.error("env.staging in public/crr-criteria/wrangler.json is missing or shares an id with production. Refusing.");
  process.exit(1);
}
// Port must be free, or /api/health could answer from another process.
try { await fetch(`${BASE}/api/health`); console.error(`Port ${PORT} is already in use; stop that process first.`); process.exit(1); } catch { /* free */ }
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "seed-staging-"));
const LOCAL = path.join(tmp, "state");
const emptyEnv = path.join(tmp, "empty.env");
fs.writeFileSync(emptyEnv, "");

const local = ["--local", "--persist-to", LOCAL];
const remote = REMOTE_SIM ? ["--local", "--persist-to", REMOTE_SIM] : ["--remote"];
const wrangler = (args) => execFileSync("npx", ["wrangler", ...args], { encoding: "utf8", maxBuffer: 256 * 1024 * 1024, stdio: ["ignore", "pipe", "pipe"] });
// wrangler can print notices (proxy, telemetry) around its JSON on stdout: take the
// outermost JSON value only. Never read single KV values from stdout: notices land
// inside them (`kv bulk get` returns values inside one JSON object instead).
const json = (out) => {
  const start = out.search(/[[{]/);
  const end = Math.max(out.lastIndexOf("]"), out.lastIndexOf("}"));
  return JSON.parse(out.slice(start, end + 1));
};
const kvGetAll = (target, keys) => {
  const f = path.join(tmp, `keys-${crypto.randomUUID()}.json`);
  fs.writeFileSync(f, JSON.stringify(keys));
  return json(wrangler(["kv", "bulk", "get", f, "--namespace-id", KV_ID, ...target]));
};
const d1 = (target, sql) => json(wrangler(["d1", "execute", DB_NAME, ...target, "--config", CONFIG, "--env", "staging", "--command", sql, "--json"]))[0].results;
const kvKeys = (target) => json(wrangler(["kv", "key", "list", "--namespace-id", KV_ID, ...target])).map((k) => k.name);

// Stage B's precondition, checked first: remote staging must not already be seeded.
console.log(`Checking remote staging (${REMOTE_SIM ? "SIMULATED: " + REMOTE_SIM : `D1 ${DB_NAME}, KV ${KV_ID}`})…`);
const remoteRows = TABLES.reduce((n, t) => n + d1(remote, `SELECT COUNT(*) AS n FROM ${t}`)[0].n, 0);
const remoteKeys = kvKeys(remote);
if (remoteRows || remoteKeys.length) {
  console.error(`Remote staging already holds data (${remoteRows} row(s) in ${TABLES.join(", ")}; ${remoteKeys.length} KV key(s)). Refusing to load on top. Empty it first if you mean to re-seed.`);
  process.exit(1);
}
console.log("✓ remote staging is empty");

// Stage A: fresh local D1 with the staging schema + exam_sites seed, then the worker.
for (const f of ["public/crr-criteria/api/schema.sql", "public/crr-criteria/api/migrations/0008_bundle_registry.sql"]) {
  wrangler(["d1", "execute", DB_NAME, ...local, "--config", CONFIG, "--env", "staging", "--file", f]);
}
console.log("Starting the staging API worker on this machine (local copy)…");
const dev = spawn("npx", ["wrangler", "dev", "--config", CONFIG, "--env", "staging", "--persist-to", LOCAL,
  "--port", String(PORT), "--ip", "127.0.0.1", "--show-interactive-dev-session=false",
  "--env-file", emptyEnv, "--var", `ADMIN_KEY:${ADMIN_KEY}`, "--var", "ADMIN_WRITES_ENABLED:true"],
  { stdio: ["ignore", "pipe", "pipe"], detached: true });
const devLog = [];
for (const s of [dev.stdout, dev.stderr]) s.on("data", (d) => devLog.push(...d.toString().split("\n")));
let devExited = false;
dev.on("exit", () => { devExited = true; });
dev.on("error", (e) => { console.error(`Could not start wrangler: ${e.message}`); process.exit(1); });
const stopDev = () => { try { process.kill(-dev.pid, "SIGTERM"); } catch { /* already gone */ } };
process.on("exit", stopDev);
for (const sig of ["SIGINT", "SIGTERM", "SIGHUP"]) process.on(sig, () => process.exit(130));

const admin = (method, p, body) => fetch(BASE + p, {
  method,
  headers: { "content-type": "application/json", "x-admin-key": ADMIN_KEY, "x-admin-email": ACTOR },
  body: body === undefined ? undefined : JSON.stringify(body),
});
// Production read (GET only). 404 = "none published"; anything else non-OK stops the run.
async function prod(p) {
  const r = await fetch(PROD_API + p);
  if (r.status === 404) return null;
  if (!r.ok) fail(`Production ${p} returned ${r.status}; not seeding from a partial read.`);
  return r.json();
}
let stageB = false;
function fail(msg) {
  console.error(`\n✘ ${msg}`);
  if (!stageB) console.error("Last wrangler output:\n" + devLog.filter(Boolean).slice(-25).join("\n"));
  stopDev();
  process.exit(1);
}

try {
  // Wait for the worker.
  const deadline = Date.now() + 180_000;
  for (;;) {
    if (devExited) fail("wrangler dev exited before the worker was ready.");
    if (Date.now() > deadline) fail("Timed out waiting for the worker on " + BASE);
    try { if ((await fetch(BASE + "/api/health")).ok) break; } catch { /* not up yet */ }
    await new Promise((r) => setTimeout(r, 2000));
  }
  console.log("✓ worker ready");

  // Admin check (read), and a guard that this is not production's data.
  const auth = await admin("GET", "/api/admin/versions");
  if (!auth.ok) fail(`Admin check failed (${auth.status}).`);
  const src = await prod("/api/criteria");
  if (!src?.data || !src.publishedAt) fail(`Could not read production's published criteria from ${PROD_API}/api/criteria.`);
  const here = await (await fetch(BASE + "/api/criteria")).json().catch(() => null);
  if (here?.publishedAt && here.publishedAt === src.publishedAt && here.publishedBy !== ACTOR) {
    fail("The local worker already serves production's exact snapshot, not a seeded copy. Refusing: it may be bound to production.");
  }

  // 1. Criteria, match data, regions.
  if (here?.publishedBy === ACTOR && JSON.stringify(here.data) === JSON.stringify(src.data)) {
    console.log(`• criteria ${src.version} already seeded`);
  } else {
    const matchData = await prod("/api/match-data");
    const r = await admin("POST", "/api/admin/publish", {
      versionLabel: src.version, data: src.data, ...(matchData ? { matchData } : {}),
      notes: `Seeded from production (published ${src.publishedAt} by ${src.publishedBy}) for staging (AD-34).`,
    });
    if (!r.ok) fail(`Criteria publish failed (${r.status}): ${await r.text()}`);
    console.log(`✓ criteria ${src.version}${matchData ? " + match data" : " (no match data in production)"}`);
  }
  const regions = (await prod("/api/regions")) || {};
  for (const [regionId, overrides] of Object.entries(regions)) {
    const r = await admin("PUT", `/api/admin/regions/${encodeURIComponent(regionId)}`, { overrides });
    if (!r.ok) fail(`Region ${regionId} failed (${r.status}): ${await r.text()}`);
  }
  console.log(`✓ ${Object.keys(regions).length} region override set(s)`);

  // 2. Active system prompt.
  const prompt = await prod("/api/system-prompt");
  if (!prompt?.version || !prompt?.instruction_text) {
    console.log("• production has no active system prompt to copy; skipped");
  } else {
    const list = await (await admin("GET", "/api/admin/system-prompt/versions")).json();
    const existing = (list.versions || []).find((v) => v.version === prompt.version);
    if (existing) {
      const full = await (await admin("GET", `/api/admin/system-prompt/versions/${encodeURIComponent(prompt.version)}`)).json();
      const text = full.instruction_text ?? full.version?.instruction_text;
      if (text !== prompt.instruction_text) fail(`Staging already has prompt ${prompt.version} with different text from production; resolve by hand.`);
    } else {
      const r = await admin("POST", "/api/admin/system-prompt/versions", {
        version: prompt.version, label: prompt.label || prompt.version, instruction_text: prompt.instruction_text,
        changelog: "Copied from production's active prompt for staging (AD-34).", created_by: ACTOR,
      });
      if (!r.ok) fail(`Prompt create failed (${r.status}): ${await r.text()}`);
    }
    if (existing?.is_active) {
      console.log(`• system prompt ${prompt.version} already active`);
    } else {
      const r = await admin("POST", `/api/admin/system-prompt/activate/${encodeURIComponent(prompt.version)}`, {
        activated_by: ACTOR, reason: "Staging seed: matches production's active prompt (AD-34).",
      });
      if (!r.ok) fail(`Prompt activation failed (${r.status}): ${await r.text()}`);
      console.log(`✓ system prompt ${prompt.version} created and activated`);
    }
  }

  // 3. Bundles.
  for (const site of BUNDLES) {
    const dir = path.join("tooling/criteria-bundle/registry", site);
    const { latestPublished } = JSON.parse(fs.readFileSync(path.join(dir, "index.json"), "utf8"));
    const bundle = JSON.parse(fs.readFileSync(path.join(dir, `${latestPublished}.json`), "utf8"));
    const r = await admin("POST", "/api/admin/bundles/publish", bundle);
    if (r.status === 409) console.log(`• bundle ${site} ${latestPublished} already in staging KV`);
    else if (!r.ok) fail(`Bundle ${site} ${latestPublished} failed (${r.status}): ${await r.text()}`);
    else console.log(`✓ bundle ${site} ${latestPublished} (${bundle.state})`);
    // AD-35: staging-only demo state, and only for bundles that really are transcribed.
    if (demoPublished && bundle.state === "transcribed") {
      for (const [toState, extra] of [["signed-off", { signoffRef: DEMO_SIGNOFF }], ["published", {}]]) {
        const s = await admin("POST", `/api/admin/bundles/${site}/state`, { toState, ...extra });
        if (s.ok) console.log(`  ✓ ${site} → ${toState} (staging demo, not clinically signed off)`);
        else if (s.status !== 422) fail(`State change ${site} → ${toState} failed (${s.status}): ${await s.text()}`);
      }
    }
    // Confirm the D1 row exists and report its state (a 409 only proves the KV key).
    const listed = await (await fetch(`${BASE}/api/bundles`)).json().catch(() => null);
    const row = (listed?.bundles || []).filter((b) => b.exam_site === site).pop();
    if (!row) fail(`Bundle ${site} has no row in the staging bundles table after publishing; check D1.`);
    console.log(`  state on staging: ${row.state}`);
  }

  stopDev();
  await new Promise((r) => setTimeout(r, 1500));

  // Stage B: copy the local result to remote staging.
  stageB = true;
  // `d1 execute --local --json` returns SQL NULL as the string "null", so ask the
  // database which fields are NULL instead of trusting the value.
  const q = (v) => typeof v === "number" ? String(v) : `'${String(v).replace(/'/g, "''")}'`;
  const CHUNK = 20000; // chars per literal: well under D1's 100 KB statement limit
  const lines = [];
  for (const t of TABLES) {
    const cols = d1(local, `PRAGMA table_info(${t})`).map((c) => c.name);
    const rows = d1(local, `SELECT ${cols.join(", ")}, ${cols.map((c) => `(${c} IS NULL) AS "__null_${c}"`).join(", ")} FROM ${t} ORDER BY id`);
    for (const row of rows) {
      const val = (c) => (row[`__null_${c}`] ? null : row[c]);
      const tails = []; // long text goes in as a first chunk plus UPDATE ... || appends
      const first = cols.map((c) => {
        const v = val(c);
        if (v === null) return "NULL";
        if (typeof v === "string" && v.length > CHUNK) {
          for (let i = CHUNK; i < v.length; i += CHUNK) tails.push(`UPDATE ${t} SET ${c} = ${c} || ${q(v.slice(i, i + CHUNK))} WHERE id = ${row.id};`);
          return q(v.slice(0, CHUNK));
        }
        return q(v);
      });
      lines.push(`INSERT INTO ${t} (${cols.join(", ")}) VALUES (${first.join(", ")});`, ...tails);
    }
  }
  const tooBig = lines.find((l) => Buffer.byteLength(l) > 90_000);
  if (tooBig) fail(`A generated statement is ${Buffer.byteLength(tooBig)} bytes, over D1's limit. Nothing copied.`);
  const sqlFile = path.join(tmp, "rows.sql");
  fs.writeFileSync(sqlFile, lines.join("\n") + "\n");
  const keys = kvKeys(local);
  const kvFile = path.join(tmp, "kv.json");
  const vals = kvGetAll(local, keys);
  if (keys.some((k) => typeof vals[k]?.value !== "string")) fail("Could not read every local KV value; nothing copied.");
  fs.writeFileSync(kvFile, JSON.stringify(keys.map((key) => ({ key, value: vals[key].value }))));

  const recovery = `To retry, empty remote staging first:
  npx wrangler d1 execute ${DB_NAME} --remote --config ${CONFIG} --env staging --command "${TABLES.map((t) => `DELETE FROM ${t};`).join(" ")}"
  then delete its KV keys (list them with: npx wrangler kv key list --namespace-id ${KV_ID} --remote).`;
  console.log(`Copying ${lines.length} D1 statement(s) and ${keys.length} KV key(s) to remote staging…`);
  try {
    wrangler(["d1", "execute", DB_NAME, ...remote, "--config", CONFIG, "--env", "staging", "--file", sqlFile, "--yes"]);
  } catch (e) {
    fail(`D1 copy failed; D1 import is all-or-nothing, so remote staging is unchanged.\n${e.stderr || e.message}`);
  }
  try {
    wrangler(["kv", "bulk", "put", kvFile, "--namespace-id", KV_ID, ...remote]);
  } catch (e) {
    fail(`D1 rows were copied, but the KV copy failed.\n${e.stderr || e.message}\n${recovery}`);
  }

  // Verify on remote.
  // Remote KV is eventually consistent: allow a short settle before comparing.
  let back = {};
  for (let i = 0; i < 6; i++) {
    back = kvGetAll(remote, keys);
    if (keys.every((k) => back[k]?.value === vals[k].value)) break;
    await new Promise((r) => setTimeout(r, 5000));
  }
  const differ = keys.filter((k) => back[k]?.value !== vals[k].value);
  if (differ.length) console.warn(`! ${differ.length} KV value(s) not yet visible as written (${differ.join(", ")}). Re-check in a minute; if they stay wrong:\n${recovery}`);
  const pub = JSON.parse((back["criteria:published"] ?? vals["criteria:published"]).value);
  const states = d1(remote, "SELECT exam_site, version, state FROM bundles ORDER BY exam_site").map((b) => `${b.exam_site} ${b.version} ${b.state}`);
  if (pub.version !== src.version || states.length !== BUNDLES.length) fail("Remote staging check failed after the copy; inspect it before re-running.");
  console.log(`✓ remote staging: criteria ${pub.version}; bundles: ${states.join("; ")}`);
  console.log(`\nDone.${demoPublished ? " Bundles are marked published as a STAGING DEMO (not clinically signed off, AD-35)." : " Bundles are transcribed, so the new pipeline will not evaluate them."}`);
} catch (e) {
  fail(e.stack || String(e));
}
