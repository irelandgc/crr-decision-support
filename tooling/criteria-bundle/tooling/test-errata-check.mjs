// AD-31: `check --bundle` enforces the errata[] rule. Runs the real CLI against the
// real national-redflags bundle with errata mutated in a temp copy.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const real = JSON.parse(fs.readFileSync(path.join(here, "..", "registry", "national-redflags", "1.0.0.json"), "utf8"));
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "errata-check-"));

const entry = (over = {}) => ({
  conceptId: "Renal Colic Creatinine Or eGFR Threshold",
  sourceText: ["q1", "q2"],
  correctedReading: "160 µmol/L",
  decisionRef: "KI-47, review pack D3",
  status: "flagged",
  clearedBy: null,
  ...over,
});

function runCheck(name, errata) {
  const bundle = { ...real };
  if (errata === undefined) delete bundle.errata; else bundle.errata = errata;
  const file = path.join(tmp, `${name}.json`);
  fs.writeFileSync(file, JSON.stringify(bundle));
  const r = spawnSync("node", [path.join(here, "check-consistency.mjs"), "--bundle", file], { encoding: "utf8" });
  return { code: r.status, out: r.stdout + r.stderr };
}

const cases = [
  ["no errata", undefined, 0, null],
  ["flagged entry, clearedBy null", [entry()], 0, null],
  ["cleared entry with a citation", [entry({ status: "cleared", clearedBy: "NZ correction notice 2026-10" })], 0, null],
  ["missing decisionRef", [entry({ decisionRef: "" })], 1, "decisionRef is required"],
  ["cleared with clearedBy null", [entry({ status: "cleared", clearedBy: null })], 1, "requires clearedBy"],
  ["flagged with a clearedBy", [entry({ clearedBy: "NZ correction notice 2026-10" })], 1, "must have clearedBy null"],
  ["unknown status", [entry({ status: "pending" })], 1, "is not \"flagged\" or \"cleared\""],
  ["errata not an array", { not: "an array" }, 1, "errata must be an array"],
];

let failed = 0;
for (const [name, errata, wantCode, wantText] of cases) {
  const { code, out } = runCheck(name.replace(/\W+/g, "-"), errata);
  const ok = code === wantCode && (wantText === null || out.includes(wantText));
  if (!ok) failed++;
  console.log(`${ok ? "PASS" : "FAIL"}  ${name}`);
  if (!ok) console.log(`      exit ${code} (want ${wantCode}), wanted text ${JSON.stringify(wantText)}\n${out}`);
}
fs.rmSync(tmp, { recursive: true, force: true });
console.log(failed ? `${failed} errata check case(s) FAILED` : `Errata check: ${cases.length}/${cases.length} passed`);
process.exit(failed ? 1 : 0);
