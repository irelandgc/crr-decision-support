// ARCH-MIG-01 slice 6 — criteria structure renderer.
//
// resolveCriteria + criteriaHtml are presentation-only and carry no criteria
// content of their own: every string they DISPLAY comes from the bundle artefacts
// (PlanDefinition / Questionnaire / overlay) or from the fixed CHROME_STRINGS.
// This is the same "every displayed string comes from an artefact" contract the
// Advisory renderer holds (advisory-render.test.ts).
import { describe, expect, it } from "vitest";
// @ts-expect-error -- plain .js ESM module, no type declarations
import { resolveCriteria, criteriaHtml, buildQuestionnaireResponse, flattenQrValues, CHROME_STRINGS, stripMidstringPriority } from "../../shared/criteria-render.js";
import ctCapQ from "../../../../tooling/criteria-bundle/fhir/Questionnaire-CRR-CT-CAP-Adult.json";
import ctCapPd from "../../../../tooling/criteria-bundle/fhir/PlanDefinition-CRR-CT-CAP-Adult.json";
import ctCapOverlay from "../../../../tooling/criteria-bundle/fhir/RegionalOverlay-CRR-CT-CAP-Adult-te-waipounamu.json";
import regionsConfig from "../../../../tooling/criteria-bundle/fhir/regions.json";

const bundle = { planDefinition: ctCapPd, questionnaire: ctCapQ, overlays: [ctCapOverlay] };

// Word-level "no invented content" check: every WORD the renderer displays must
// appear in the bundle artefacts, or be one of the renderer's fixed chrome
// words, or be numeric. Concatenation order is not the point - invented
// vocabulary is (invariant 3).
function wordSet(...strings: string[]): Set<string> {
  const set = new Set<string>();
  for (const s of strings) {
    for (const w of String(s).toLowerCase().split(/[^a-z0-9%/+&.-]+/i)) {
      const t = w.replace(/^[.-]+|[.-]+$/g, "");
      if (t) set.add(t);
    }
  }
  return set;
}
const ARTEFACT_WORDS = wordSet(JSON.stringify(ctCapPd), JSON.stringify(ctCapQ), JSON.stringify(ctCapOverlay), JSON.stringify(regionsConfig));
const CHROME_WORDS = wordSet(CHROME_STRINGS.join(" "));

function visibleText(html: string): string {
  return html
    .replace(/<[^>]+>/g, " ")
    .replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&ldquo;|&rdquo;/g, '"').replace(/&#8226;/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function untraceable(html: string): string[] {
  const toks = visibleText(html).toLowerCase().split(/[^a-z0-9%/+&.-]+/i)
    .map((w) => w.replace(/^[.-]+|[.-]+$/g, ""))
    .filter((w) => w.length > 0 && !/^[0-9]+([./-][0-9]+)*$/.test(w)); // numbers, ranges and dates (27/08/2026) are not vocabulary
  return [...new Set(toks)].filter((w) => !ARTEFACT_WORDS.has(w) && !CHROME_WORDS.has(w));
}

describe("criteria-render — every displayed string traces to a bundle artefact", () => {
  for (const ctx of ["referrer", "triager"] as const) {
    for (const layout of ["indication", "urgency", "vocabulary"] as const) {
      it(`${ctx} / ${layout}`, () => {
        const model = resolveCriteria(bundle, {
          context: ctx, layout, region: "te-waipounamu", regionsConfig,
          sourceLine: { title: ctCapPd.title, pages: "10-11" },
        });
        const bad = untraceable(criteriaHtml(model));
        expect(bad).toEqual([]);
      });
      it(`${ctx} / ${layout} — approved-draft source line (KI-66)`, () => {
        const model = resolveCriteria(bundle, {
          context: ctx, layout, region: "te-waipounamu", regionsConfig,
          sourceLine: { title: ctCapPd.title, pages: null, draftDate: "2026-08-27" },
        });
        expect(untraceable(criteriaHtml(model))).toEqual([]);
      });
    }
  }
});

describe("criteria-render — referrer view (GEN-004)", () => {
  const html = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication" }));
  it("shows no priority code", () => {
    expect(html).not.toMatch(/\bP[1-4]\b/);
    expect(html).not.toContain("priority-badge");
  });
  it("strips the leading P2 token from the timeframe row title", () => {
    expect(html).toContain("Urgent: non-deferrable imaging or intervention that must be completed within 2 weeks");
    expect(html).not.toContain("P2 Urgent: non-deferrable");
  });
  it("strips a leading S-code or code range from a row title (KI-76)", () => {
    for (const [prefix, code] of [["S1: ", "S1"], ["S2 ", "S2"], ["P3-P4: ", "P4"]]) {
      const pd = JSON.parse(JSON.stringify(ctCapPd));
      const row = pd.action.find((a: any) => /^P2\b/.test(a.title || ""));
      row.title = row.title.replace(/^P2\s*/, prefix);
      const h = criteriaHtml(resolveCriteria({ ...bundle, planDefinition: pd }, { context: "referrer", layout: "indication" }));
      expect(h).not.toMatch(new RegExp(`\\b${code}\\b`));
      expect(h).toContain("Urgent: non-deferrable imaging or intervention that must be completed within 2 weeks");
    }
  });
  it("removes a priority code inside published wording and notes, for referrers only (KI-76)", () => {
    const pd = JSON.parse(JSON.stringify(ctCapPd));
    const nf = pd.action.find((a: any) => (a.action || []).length && /not routinely funded/i.test(a.title || ""));
    nf.action[0].title = "Routine follow-up, other than in the scenarios specified above under S2 priority imaging";
    nf.documentation = [...(nf.documentation || []), { display: "Complete as for the urgent row (P2)." }];
    const b = { ...bundle, planDefinition: pd };
    const ref = criteriaHtml(resolveCriteria(b, { context: "referrer", layout: "indication" }));
    expect(ref).toContain("other than in the scenarios specified above under priority imaging");
    expect(ref).not.toMatch(/\b[PS][1-4]\b/);
    const tri = criteriaHtml(resolveCriteria(b, { context: "triager", layout: "indication" }));
    expect(tri).toContain("under S2 priority imaging");
  });
  it("keeps line breaks in referrer guidance (KI-76 review)", () => {
    const tri = resolveCriteria(bundle, { context: "triager", layout: "indication" });
    const ref = resolveCriteria(bundle, { context: "referrer", layout: "indication" });
    expect(tri.guidance.text).toContain("\n");
    expect(ref.guidance.text).toBe(tri.guidance.text);
  });
  it("removes only the mid-sentence code forms published wording uses (KI-76 review)", () => {
    expect(stripMidstringPriority("other than in the scenarios specified above under S2 priority imaging")).toBe("other than in the scenarios specified above under priority imaging");
    expect(stripMidstringPriority("Urgent (P2) imaging")).toBe("Urgent imaging");
    for (const keep of ["L5-S1 disc", "L5/S1 disc", "S3 gallop and S2 heart sound", "P2Y12 inhibitor", "P3-4 weeks", "line one\n\nline two"]) {
      expect(stripMidstringPriority(keep)).toBe(keep);
    }
  });
  it("groups the P2 pathways by indication-theme", () => {
    expect(html).toContain("Suspected occult malignancy");
    expect(html).toContain("Specialist-endorsed referral");
    expect(html.indexOf("Suspected occult malignancy")).toBeLessThan(html.indexOf("Specialist-endorsed referral"));
  });
  it("renders compound selectionBehavior labels", () => {
    expect(html).toContain("All of the following:");
    expect(html).toContain("One or more of the following:");
  });
  it("renders badges from action codes, verbatim", () => {
    expect(html).toContain("MANDATORY");
    expect(html).toContain("GATEWAY");
    expect(html).toContain("LAB VALUE REQUIRED");
  });
  it("renders the redirects as a list with page references", () => {
    expect(html).toContain("Alternative management / redirect");
    expect(html).toContain("Presentation requiring urgent admission or urgent secondary care assessment");
    expect(html).toMatch(/page 11/);
  });
  it("not-funded is present but never tickable (GEN-005)", () => {
    expect(html).toContain("Not routinely funded");
    expect(html).toContain("Patient is unfit for treatment or unwilling");
    // funding.unfitOrUnwilling never gets a checkbox / data-linkid
    expect(html).not.toContain('data-linkid="funding.unfitOrUnwilling"');
  });
  it("single-boolean leaves are checkboxes; a compound criterion (B1, B3) is not one tick but a typed input per linkId (AD-27)", () => {
    // criterion-A's five boolean leaves + the six lab booleans are single-tick cards
    for (const id of ["workup.bloods", "workup.urinalysis", "workup.cxr", "workup.strongSuspicionMalignancy", "workup.localisingFeatures", "lab.crp.raised", "lab.hb.low", "lab.alp.high"]) {
      expect(html).toContain(`<input type="checkbox" class="crit-card-check" data-linkid="${id}"`);
    }
    // B1 / B3 are never a single tick over the whole criterion: each renders as a
    // typed-inputs row with no single-tick checkbox inside it
    for (const id of ["b1", "b3"]) {
      const row = html.match(new RegExp(`<div class="cr-row cr-inputs-row" data-action="${id}">[\\s\\S]*?<div class="cr-inputs">[\\s\\S]*?</div>`));
      expect(row, id).not.toBeNull();
      expect(row![0]).not.toContain("crit-card-check");
    }
    // B1: number for age, select for sex, checkbox for present/measured, number for weights/period/percent
    expect(html).toMatch(/<input type="number"[^>]*data-linkid="patient\.age"/);
    expect(html).toMatch(/<select data-linkid="patient\.sex">/);
    expect(html).toContain('<option value="male">Male</option>');
    expect(html).toMatch(/<input type="checkbox" data-linkid="weightloss\.present"/);
    expect(html).toMatch(/<input type="checkbox" data-linkid="weightloss\.measured"/);
    for (const id of ["weightloss.weightBefore", "weightloss.weightNow", "weightloss.periodMonths", "weightloss.percent"]) {
      expect(html).toMatch(new RegExp(`<input type="number"[^>]*data-linkid="${id.replace(".", "\\.")}"`));
    }
    // the fallback (percent) is the last of the weight-loss inputs (PlanDefinition order)
    expect(html.indexOf('data-linkid="weightloss.weightBefore"')).toBeLessThan(html.indexOf('data-linkid="weightloss.percent"'));
    // B3: checkbox for the advice boolean, text for the adviser name/role
    expect(html).toMatch(/<input type="checkbox" data-linkid="advice\.urgentCTRecommended"/);
    expect(html).toMatch(/<input type="text" data-linkid="advice\.adviserNameRole"/);
    // published wording of the criterion still leads the row
    expect(html).toContain("Male over 50 years of age or female over 60 years");
    // unit chips come from the Questionnaire's questionnaire-unit extension
    expect(html).toContain('<span class="cr-unit">kg</span>');
    expect(html).toContain('<span class="cr-unit">years</span>');
  });

  it("read-only (Triage reference column): compound inputs show the value from the merged QR, no entry", () => {
    const ro = criteriaHtml(resolveCriteria(bundle, {
      context: "referrer", layout: "indication", readOnly: true,
      ticks: { "patient.age": 62, "patient.sex": "male", "weightloss.weightBefore": 84, "weightloss.weightNow": 77, "weightloss.periodMonths": 4, "weightloss.present": true },
    }));
    expect(ro).not.toContain('<input type="number"');
    expect(ro).not.toContain("<select");
    expect(ro).toContain('<span class="cr-input-value">84 kg</span>');
    expect(ro).toContain('<span class="cr-input-value">62 years</span>');
    expect(ro).toContain('<span class="cr-input-value">Male</span>');
    // a boolean shows a disabled checked box, not editable
    expect(ro).toMatch(/<input type="checkbox" disabled checked>/);
  });

  it("read-only values come only from answers the engine used: inferred answers are skipped unless the standard is inferred (invariant 4)", () => {
    // merged-QR answer shape from merge.ts: extracted answers carry answer-evidence
    // (status + quote); a context answer carries none (engine treats it as documented)
    const ev = (status: string) => [{ url: "http://crr.health.nz/fhir/StructureDefinition/answer-evidence", extension: [{ url: "status", valueCode: status }, { url: "quote", valueString: "q" }] }];
    const merged = {
      resourceType: "QuestionnaireResponse",
      item: [
        { linkId: "patient", item: [{ linkId: "patient.age", answer: [{ valueInteger: 62 }] }] },
        { linkId: "weightloss", item: [
          { linkId: "weightloss.present", answer: [{ valueBoolean: true, extension: ev("inferred") }] },
          { linkId: "weightloss.weightBefore", answer: [{ valueDecimal: 84, extension: ev("inferred") }] },
          { linkId: "weightloss.weightNow", answer: [{ valueDecimal: 77, extension: ev("documented") }] },
        ] },
      ],
    };
    for (const std of ["strict", undefined]) {
      expect(flattenQrValues(merged, std)).toEqual({ "patient.age": 62, "weightloss.weightNow": 77 });
    }
    expect(flattenQrValues(merged, "inferred")).toEqual({ "patient.age": 62, "weightloss.present": true, "weightloss.weightBefore": 84, "weightloss.weightNow": 77 });
    // and in the reference column under strict: the inferred weight is not shown, the inferred box is not ticked
    const ro = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication", readOnly: true, ticks: flattenQrValues(merged, "strict") }));
    expect(ro).toContain('<span class="cr-input-value">77 kg</span>');
    expect(ro).not.toContain('<span class="cr-input-value">84 kg</span>');
    expect(ro).not.toMatch(/<input type="checkbox" disabled checked>/);
  });
});

describe("criteria-render — by-urgency layout (CV-027)", () => {
  const html = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "urgency" }));
  it("does not theme-group and does not append the Questionnaire vocabulary groups", () => {
    expect(html).not.toContain("theme-group-hd");
    // the vocabulary-group dump (only for layout: 'vocabulary')
    expect(html).not.toContain("Yellow flag symptoms (context only; do not affect eligibility)");
  });
  it("still renders the timeframe block and the compound selection labels, in printed order", () => {
    expect(html).toContain("Urgent: non-deferrable imaging or intervention that must be completed within 2 weeks");
    expect(html).toContain("All of the following:");
    expect(html).toContain("One or more of the following:");
    // criterion A wording precedes B3 wording (PlanDefinition order)
    expect(html.indexOf("Following full clinical assessment")).toBeLessThan(html.indexOf("advises referral for urgent CT Chest"));
  });
});

describe("criteria-render — triager view", () => {
  const html = criteriaHtml(resolveCriteria(bundle, { context: "triager", layout: "indication" }));
  it("shows the priority code on the timeframe row", () => {
    expect(html).toContain("priority-badge");
    expect(html).toContain("P2");
    expect(html).toContain("P2 Urgent: non-deferrable imaging");
  });
});

describe("criteria-render — region overlay (delivery info only)", () => {
  const withRegion = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication", region: "te-waipounamu", regionsConfig }));
  const noRegion = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication" }));
  it("shows the overlay's delivery notes only when a region is selected", () => {
    expect(withRegion).toContain("Regional delivery");
    expect(withRegion).toContain("Submit via ERMS to the regional CRR Hub");
    expect(noRegion).not.toContain("Regional delivery");
  });
  it("builds a HealthPathways link from the page id + regional domain (first real instance when no legacy id given)", () => {
    expect(withRegion).toContain("Local HealthPathways");
    expect(withRegion).toMatch(/href="https:\/\/canterbury\.communityhealthpathways\.org\/TBC-page-id"/);
  });
  it("uses the instance for the selected legacy region id (AD-29)", () => {
    const southern = criteriaHtml(resolveCriteria(bundle, {
      context: "referrer", layout: "indication", region: "te-waipounamu", regionLegacyId: "southern", regionsConfig,
    }));
    expect(southern).toMatch(/href="https:\/\/southern\.communityhealthpathways\.org\/TBC-page-id"/);
  });
});

describe("criteria-render — ticks -> QuestionnaireResponse (CV-015)", () => {
  it("builds a QR grouped by linkId prefix from the ticked boxes", () => {
    const qr = buildQuestionnaireResponse(ctCapQ, { "workup.bloods": true, "weightloss.percent": 8, "funding.unfitOrUnwilling": true });
    const workup = qr.item.find((g: any) => g.linkId === "workup");
    expect(workup.item.find((i: any) => i.linkId === "workup.bloods").answer[0].valueBoolean).toBe(true);
    const wl = qr.item.find((g: any) => g.linkId === "weightloss");
    expect(wl.item.find((i: any) => i.linkId === "weightloss.percent").answer[0].valueDecimal).toBe(8);
  });
});

describe("criteria-render — source line (AD-01)", () => {
  it("renders the exam title and section pages passed by the host", () => {
    const html = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication", sourceLine: { title: "CT Chest, Abdomen and Pelvis - Adult", pages: "10-11" } }));
    expect(html).toContain("CT Chest, Abdomen and Pelvis - Adult");
    expect(html).toContain("page 10-11");
  });

  it("an approved-draft source shows its date, never a page or the repo path (KI-66, AD-33)", () => {
    const html = criteriaHtml(resolveCriteria(bundle, { context: "referrer", layout: "indication", sourceLine: { title: "CT Colonography - Adult", pages: null, draftDate: "2026-08-27" } }));
    const line = html.match(/<div class="cr-source-line">.*?<\/div>/)![0];
    expect(line).toContain("CT Colonography - Adult");
    expect(line).toContain("approved draft, 27/08/2026");
    expect(visibleText(line)).not.toMatch(/page/);
    expect(line).not.toMatch(/documents\/|\.docx/);
  });
});
