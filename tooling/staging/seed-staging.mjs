// Seed the AD-34 staging environment through the API worker's own admin routes.
//
// Staging's admin routes sit behind Cloudflare Access, so a script cannot reach
// them through the staging host. Instead this runs the STAGING API worker code
// locally with `wrangler dev --env staging --remote` (bound to the staging D1 and
// KV, listening on 127.0.0.1 only) and calls the real admin routes there, so every
// write gets the same validation and KV/D1 bookkeeping as an Admin Tool action.
// Raw SQL/KV writes are never used (CLAUDE.md pitfalls).
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
// Usage (repo root, logged in with `npx wrangler login`):
//   node tooling/staging/seed-staging.mjs [--demo-published]
// Safe to re-run: steps already done are reported and skipped.
import { spawn } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const PROD_API = process.env.SEED_SOURCE || "https://crr-criteria-api.fk4dsrmq5r.workers.dev"; // SEED_SOURCE: test-only override
const LOCAL_TEST = process.env.SEED_LOCAL === "1"; // test-only: local wrangler dev, no --remote
const PORT = 8799;
const BASE = `http://127.0.0.1:${PORT}`;
const ACTOR = "seed-staging@local";
const BUNDLES = ["national-redflags", "ct-chest-abdomen-pelvis-adult", "ct-colonography-adult"];
const DEMO_SIGNOFF = "STAGING DEMO ONLY: not clinically signed off (AD-10, AD-34)";
const demoPublished = process.argv.includes("--demo-published");
const ADMIN_KEY = crypto.randomBytes(32).toString("hex");

if (!fs.existsSync("public/crr-criteria/wrangler.json")) {
  console.error("Run this from the repo root.");
  process.exit(1);
}
for (const f of ["public/crr-criteria/.dev.vars", "public/crr-criteria/.dev.vars.staging"]) {
  if (fs.existsSync(f) && /^(ADMIN_KEY|ADMIN_WRITES_ENABLED)=/m.test(fs.readFileSync(f, "utf8"))) {
    console.warn(`Note: ${f} sets ADMIN_KEY or ADMIN_WRITES_ENABLED; if the admin check below fails, that file is overriding this script's values.`);
  }
}

const args = ["wrangler", "dev", "--config", "public/crr-criteria/wrangler.json", "--env", "staging",
  "--port", String(PORT), "--ip", "127.0.0.1", "--show-interactive-dev-session=false",
  "--var", `ADMIN_KEY:${ADMIN_KEY}`, "--var", "ADMIN_WRITES_ENABLED:true"];
if (!LOCAL_TEST) args.splice(6, 0, "--remote");
console.log(`Starting the staging API worker locally (${LOCAL_TEST ? "LOCAL TEST" : "remote staging D1/KV"})…`);
const dev = spawn("npx", args, { stdio: ["ignore", "pipe", "pipe"], detached: true });
const devLog = [];
for (const s of [dev.stdout, dev.stderr]) s.on("data", (d) => devLog.push(...d.toString().split("\n")));
let devExited = false;
dev.on("exit", () => { devExited = true; });
const stopDev = () => { try { process.kill(-dev.pid, "SIGTERM"); } catch { /* already gone */ } };
process.on("SIGINT", () => { stopDev(); process.exit(130); });

const admin = (method, p, body) => fetch(BASE + p, {
  method,
  headers: { "content-type": "application/json", "x-admin-key": ADMIN_KEY, "x-admin-email": ACTOR },
  body: body === undefined ? undefined : JSON.stringify(body),
});
async function prod(p) {
  const r = await fetch(PROD_API + p);
  return r.ok ? r.json() : null;
}
function fail(msg) {
  console.error(`\n✘ ${msg}`);
  console.error("Last wrangler output:\n" + devLog.filter(Boolean).slice(-25).join("\n"));
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

  // Admin check, and a guard that this is not production's data.
  const auth = await admin("GET", "/api/admin/versions");
  if (!auth.ok) fail(`Admin check failed (${auth.status}). See the note about .dev.vars above.`);
  const src = await prod("/api/criteria");
  if (!src?.data) fail(`Could not read production's published criteria from ${PROD_API}/api/criteria.`);
  const here = await (await fetch(BASE + "/api/criteria")).json().catch(() => null);
  if (here?.publishedAt && here.publishedAt === src.publishedAt && here.publishedBy !== ACTOR) {
    fail("The local worker already serves production's exact snapshot, not a seeded copy. Refusing: it may be bound to production.");
  }

  // 1. Criteria, match data, regions.
  if (here?.publishedBy === ACTOR && here?.version === src.version) {
    console.log(`• criteria ${src.version} already seeded`);
  } else {
    const matchData = await prod("/api/match-data");
    const r = await admin("POST", "/api/admin/publish", {
      versionLabel: src.version, data: src.data, ...(matchData && !matchData.error ? { matchData } : {}),
      notes: `Seeded from production (published ${src.publishedAt} by ${src.publishedBy}) for staging (AD-34).`,
    });
    if (!r.ok) fail(`Criteria publish failed (${r.status}): ${await r.text()}`);
    console.log(`✓ criteria ${src.version}${matchData && !matchData.error ? " + match data" : " (no match data in production)"}`);
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
    if (!existing) {
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
    if (r.status === 409) console.log(`• bundle ${site} ${latestPublished} already published to staging`);
    else if (!r.ok) fail(`Bundle ${site} ${latestPublished} failed (${r.status}): ${await r.text()}`);
    else console.log(`✓ bundle ${site} ${latestPublished} (${bundle.state})`);
    if (demoPublished) {
      for (const [toState, extra] of [["signed-off", { signoffRef: DEMO_SIGNOFF }], ["published", {}]]) {
        const s = await admin("POST", `/api/admin/bundles/${site}/state`, { toState, ...extra });
        if (s.ok) console.log(`  ✓ ${site} → ${toState} (staging demo)`);
        else if (s.status !== 422) fail(`State change ${site} → ${toState} failed (${s.status}): ${await s.text()}`);
      }
    }
  }

  console.log(`\nDone. Staging now serves production's criteria ${src.version}${demoPublished ? ", with bundles marked published as a STAGING DEMO (not clinically signed off)" : "; bundles are loaded as transcribed, so the new pipeline will not evaluate them until a state change"}.`);
  stopDev();
} catch (e) {
  fail(e.stack || String(e));
}
