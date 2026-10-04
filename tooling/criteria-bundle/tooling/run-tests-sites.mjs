// Runs every transcribed site's scenarios (sites/<examSite>/scenarios.mjs) through that site's
// compiled library and checks expectations. Same checks as run-tests.mjs; record-backed
// (population) scenarios are not supported here yet.
// Usage (from tooling/): npm test
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import cql from "cql-execution";
import cqlfhir from "cql-exec-fhir";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(here, "..");
const sitesDir = path.join(root, "sites");
const helpers = JSON.parse(fs.readFileSync(path.join(root, "elm", "FHIRHelpers-4.0.1.json"), "utf8"));
const sameSet = (a, b) => JSON.stringify([...(a || [])].sort()) === JSON.stringify([...(b || [])].sort());

let total = 0, failed = 0;
for (const site of fs.existsSync(sitesDir) ? fs.readdirSync(sitesDir, { withFileTypes: true }).filter(d => d.isDirectory()).map(d => d.name) : []) {
  const dir = path.join(sitesDir, site);
  const libFile = fs.readdirSync(dir).find(f => f.endsWith(".cql") && f !== "population.cql");
  const libName = fs.readFileSync(path.join(dir, libFile), "utf8").match(/^library\s+(\w+)/m)[1];
  const elm = JSON.parse(fs.readFileSync(path.join(root, "elm", `${libName}.json`), "utf8"));
  const lib = new cql.Library(elm, new cql.Repository({ FHIRHelpers: helpers }));
  const { scenarios, toQuestionnaireResponse } = await import(path.join(dir, "scenarios.mjs"));
  for (const s of scenarios) {
    if (s.record) throw new Error(`${site} ${s.id}: record-backed scenarios are not supported by run-tests-sites.mjs yet`);
    const ps = cqlfhir.PatientSource.FHIRv401();
    ps.loadBundles([{ resourceType: "Bundle", type: "collection", entry: [{ resource: { resourceType: "Patient", id: s.id } }, { resource: toQuestionnaireResponse(s) }] }]);
    const adv = (await new cql.Executor(lib, new cql.CodeService({}), s.runWith || {}).exec(ps)).patientResults[s.id].Advisory;
    const e = s.expect, f = [];
    if (e.determination !== undefined && adv.determination !== e.determination) f.push(`determination ${adv.determination} != ${e.determination}`);
    if (e.priorityCode !== undefined && adv.priorityCode !== e.priorityCode) f.push(`priorityCode ${adv.priorityCode} != ${e.priorityCode}`);
    if (e.missing !== undefined && !sameSet(adv.missingInformation, e.missing)) f.push(`missing ${JSON.stringify(adv.missingInformation)} != ${JSON.stringify(e.missing)}`);
    if (e.redirects !== undefined && !sameSet(adv.activeRedirects, e.redirects)) f.push(`redirects ${JSON.stringify(adv.activeRedirects)}`);
    if (e.unconfirmedExclusions !== undefined && !sameSet(adv.unconfirmedExclusions, e.unconfirmedExclusions)) f.push(`unconfirmedExclusions ${JSON.stringify(adv.unconfirmedExclusions)}`);
    if (e.inferredExcluded !== undefined && !sameSet(adv.inferredExcludedByStrictStandard, e.inferredExcluded)) f.push(`inferredExcluded ${JSON.stringify(adv.inferredExcludedByStrictStandard)}`);
    total++;
    if (f.length) failed++;
    console.log(`${f.length ? "FAIL" : "PASS"}  ${site.padEnd(28)} ${s.id.padEnd(30)} -> ${adv.determination}${f.length ? "  " + f.join("; ") : ""}`);
  }
}
console.log(`\nSites: ${total - failed}/${total} scenario runs passed`);
process.exit(failed ? 1 : 0);
