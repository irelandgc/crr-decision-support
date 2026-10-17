// ARCH-MIG-01 slice 4b — prompt assembly tests.
import { describe, expect, it } from "vitest";
import {
  PROMPT_VERSION,
  EQUIVALENCE_LIST_VERSION,
  ATTESTATION_LINK_IDS,
  OUTPUT_TOOL,
  assembleSystemPrompt,
  assembleUserContent,
  stripAttestationItems,
  applyExtractionHints,
  findCriteriaLeaks,
} from "../prompt";
import promptV3 from "../../../../tooling/criteria-bundle/extraction/prompt-v3.0.5.json";
import promptV304 from "../../../../tooling/criteria-bundle/extraction/prompt-v3.0.4.json";
import nationalQ from "../../../../tooling/criteria-bundle/fhir/Questionnaire-CRR-National.json";
import ctCapQ from "../../../../tooling/criteria-bundle/fhir/Questionnaire-CRR-CT-CAP-Adult.json";
import ctCapPd from "../../../../tooling/criteria-bundle/fhir/PlanDefinition-CRR-CT-CAP-Adult.json";

describe("prompt — versions and assembly", () => {
  it("version constants come from prompt-v3.0.5.json", () => {
    expect(PROMPT_VERSION).toBe("3.0.5");
    expect(PROMPT_VERSION).toBe((promptV3 as any).version);
    expect(EQUIVALENCE_LIST_VERSION).toBe((promptV3 as any).equivalenceListVersion);
  });

  it("OUTPUT_TOOL is the versioned output tool with the shape schema", () => {
    expect(OUTPUT_TOOL.name).toBe("submit_extraction");
    expect(OUTPUT_TOOL.input_schema.additionalProperties).toBe(false);
    const ans = OUTPUT_TOOL.input_schema.properties.answers.items;
    expect(ans.required.sort()).toEqual(["linkId", "quote", "status", "value"]);
    expect(ans.additionalProperties).toBe(false);
    expect(ans.properties.status.enum).toEqual(["documented", "inferred"]);
  });

  it("assembleSystemPrompt joins parts[].text with a blank line, deterministically", () => {
    const a = assembleSystemPrompt();
    const b = assembleSystemPrompt();
    expect(a).toBe(b);
    const parts = (promptV3 as any).parts as { text: string }[];
    expect(a).toBe(parts.map((p) => p.text).join("\n\n"));
    // sanity: it contains the role line and the output rule
    expect(a).toContain("You extract. You do not assess.");
    expect(a).toContain("Call the submit_extraction tool");
    expect(a).toContain("Never submit: a verdict");
  });

  it("states the requested entry's null quote and that quotes come only from the note (KI-73)", () => {
    const a = assembleSystemPrompt();
    expect(a).toContain("if it does not, that quote is null");
    expect(a).toContain("never from the exam/site list");
    expect(a).not.toContain("Every entry carries a quote");
  });

  it("scopes equivalence lines to supplied Questionnaires (KI-84)", () => {
    const a = assembleSystemPrompt();
    expect(a).toContain("Each line applies only to an item in a supplied Questionnaire");
    expect(a).toContain("-> workup.bloods where a supplied Questionnaire has it");
    expect(a).not.toContain("-> workup.bloods, documented");
    expect(a).toContain("-> an examination-findings item in a supplied Questionnaire");
    expect(a).toContain("-> weightloss.measured where a supplied Questionnaire has it");
    expect(a).not.toContain("-> weightloss.measured, documented");
  });

  it("documents a false only on the note's own negation or an equivalence (KI-83)", () => {
    const a = assembleSystemPrompt();
    expect(a).toContain("Negation is documented when the note's own words negate that item");
    expect(a).toContain("or an equivalence below makes it a negation");
    expect(a).toContain("A false reasoned from other wording is inferred");
  });

  it("keeps the output tool unchanged from v3.0.4 across the prompt bump", () => {
    // An earlier test sorts `required` in place, so compare with `required` order normalised.
    const norm = (t: unknown) => JSON.parse(JSON.stringify(t), (k: string, v: unknown) => (k === "required" && Array.isArray(v) ? [...v].sort() : v));
    expect(norm(OUTPUT_TOOL)).toEqual(norm((promptV304 as { outputTool: unknown }).outputTool));
  });
});

describe("prompt — no criteria content (AD-16 at the assembled level)", () => {
  it("the assembled system prompt contains no numeric threshold, priority code, named analyte, redirect, or PlanDefinition action title", () => {
    const actionTitles: string[] = [];
    (function walk(actions: any[]) {
      for (const a of actions || []) {
        if (a.title) actionTitles.push(a.title);
        walk(a.action);
      }
    })((ctCapPd as any).action);
    const leaks = findCriteriaLeaks(assembleSystemPrompt(), actionTitles);
    expect(leaks).toEqual([]);
  });
});

describe("prompt — attestation items are stripped (AD-17)", () => {
  it("ATTESTATION_LINK_IDS is read from the vocabulary and is non-empty", () => {
    expect(ATTESTATION_LINK_IDS).toContain("workup.strongSuspicionMalignancy");
    expect(ATTESTATION_LINK_IDS).toContain("excl.urgentAdmissionRequired");
  });

  it("stripAttestationItems removes those linkIds from the CT CAP Questionnaire", () => {
    const before = JSON.stringify(ctCapQ);
    const stripped = stripAttestationItems(ctCapQ, new Set(ATTESTATION_LINK_IDS));
    const allLinkIds = (function collect(items: any[], acc: string[] = []): string[] {
      for (const i of items || []) {
        if (i.linkId) acc.push(i.linkId);
        if (Array.isArray(i.item)) collect(i.item, acc);
      }
      return acc;
    })(stripped.item);
    for (const id of ATTESTATION_LINK_IDS) expect(allLinkIds).not.toContain(id);
    // at least one attestation item was actually present to remove
    expect(before).toContain("workup.strongSuspicionMalignancy");
    // input object not mutated
    expect(JSON.stringify(ctCapQ)).toBe(before);
  });
});

describe("prompt — extraction-hint split (slice 6 D4)", () => {
  it("CT CAP Questionnaire carries no model hint in item.text; workup.localisingFeatures has an extraction-hint extension", () => {
    const find = (id: string) => {
      let hit: any = null;
      (function w(items: any[]) { for (const i of items || []) { if (i.linkId === id) hit = i; w(i.item); } })((ctCapQ as any).item);
      return hit;
    };
    const lf = find("workup.localisingFeatures");
    expect(lf.text).toBe("Focal pathology, localising signs/symptoms, or a potential biopsy site has been identified");
    expect(lf.text).not.toMatch(/\btrue\s*=/);
    const hint = (lf.extension || []).find((e: any) => e.url === "http://crr.health.nz/fhir/StructureDefinition/extraction-hint");
    expect(hint.valueString).toContain("true = identified");
  });

  it("applyExtractionHints folds the hint back into the model's copy and drops the extension", () => {
    const withHints = applyExtractionHints(ctCapQ);
    const find = (q: any, id: string) => { let hit: any = null; (function w(items: any[]) { for (const i of items || []) { if (i.linkId === id) hit = i; w(i.item); } })(q.item); return hit; };
    const lf = find(withHints, "workup.localisingFeatures");
    expect(lf.text).toBe("Focal pathology, localising signs/symptoms, or a potential biopsy site has been identified (true = identified; this is a redirect to the relevant system-specific pathway)");
    expect((lf.extension || []).some((e: any) => e.url.endsWith("extraction-hint"))).toBe(false);
    // input not mutated
    expect(find(ctCapQ, "workup.localisingFeatures").text).not.toMatch(/true =/);
  });
});

describe("prompt — user content", () => {
  it("puts the stable bulk in a cache-controlled block and the note last, uncached", () => {
    const blocks = assembleUserContent({
      redactedNote: "65yo male w/ unexplained wt loss.",
      questionnaires: [nationalQ, ctCapQ],
      examSiteList: [{ id: "ct_cap", title: "CT — Chest/Abdomen/Pelvis" }],
      context: { age: 65, sex: "male" },
    });
    expect(blocks).toHaveLength(2);
    expect(blocks[0].cache_control).toEqual({ type: "ephemeral" });
    expect(blocks[0].text).toContain("PUBLISHED EXAM/SITE LIST");
    expect(blocks[0].text).toContain("Do NOT answer patient.age");
    expect(blocks[1].cache_control).toBeUndefined();
    expect(blocks[1].text).toContain("REFERRAL NOTE (redacted):");
    expect(blocks[1].text).toContain("unexplained wt loss");
  });
});
