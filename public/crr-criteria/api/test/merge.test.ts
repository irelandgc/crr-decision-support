// ARCH-MIG-01 slice 5 — merge tests.
//
// merge() joins up to four answer sources into one QuestionnaireResponse.
// Covers: precedence for every pair of sources; a discrepancy recorded on every
// override; attestation-category indicators set only from attestations; and
// expectedAbsent linkIds staying absent through the merge.
import { describe, expect, it } from "vitest";
import { merge, ANSWER_EVIDENCE_EXT_URL } from "../merge";
import { buildItemIndex } from "../gate";
import nationalQ from "../../../../tooling/criteria-bundle/fhir/Questionnaire-CRR-National.json";
import ctCapQ from "../../../../tooling/criteria-bundle/fhir/Questionnaire-CRR-CT-CAP-Adult.json";

const itemIndex = buildItemIndex([nationalQ as any, ctCapQ as any]);
const ATTESTATION = ["workup.strongSuspicionMalignancy", "excl.urgentAdmissionRequired"];

// A minimal extracted QuestionnaireResponse: linkId -> { value, status, quote }.
function extractedQr(answers: Record<string, { value: any; status?: string; quote?: string }>) {
  const groups: Record<string, any[]> = {};
  for (const [linkId, a] of Object.entries(answers)) {
    const g = linkId.split(".")[0];
    const valueKey =
      typeof a.value === "boolean" ? "valueBoolean" : typeof a.value === "number" ? "valueDecimal" : "valueString";
    (groups[g] ||= []).push({
      linkId,
      answer: [
        {
          [valueKey]: a.value,
          extension: [
            {
              url: ANSWER_EVIDENCE_EXT_URL,
              extension: [
                { url: "status", valueCode: a.status ?? "documented" },
                ...(a.quote ? [{ url: "quote", valueString: a.quote }] : []),
              ],
            },
          ],
        },
      ],
    });
  }
  return {
    resourceType: "QuestionnaireResponse",
    status: "completed",
    item: Object.entries(groups).map(([linkId, item]) => ({ linkId, item })),
  };
}

function run(input: Partial<Parameters<typeof merge>[0]> & { extractedResponse: any }) {
  return merge({ attestationLinkIds: ATTESTATION, itemIndex, ...input });
}

// Pull linkId -> { value, status, source, attestedBy } out of a merged QR.
function collect(qr: any) {
  const out = new Map<string, { value: any; status?: string; source?: string; attestedBy?: string; hasExt: boolean }>();
  const walk = (items: any[]) => {
    for (const i of items || []) {
      if (Array.isArray(i.item)) walk(i.item);
      if (!Array.isArray(i.answer)) continue;
      const a = i.answer[0];
      const vk = Object.keys(a).find((k) => k.startsWith("value"));
      let value = vk ? a[vk] : undefined;
      if (value && typeof value === "object" && "code" in value) value = value.code;
      const ev = (a.extension || []).find((e: any) => e.url === ANSWER_EVIDENCE_EXT_URL);
      const sub: any = {};
      for (const s of ev?.extension || []) {
        if (s.url === "status") sub.status = s.valueCode;
        if (s.url === "source") sub.source = s.valueCode;
        if (s.url === "attestedBy") sub.attestedBy = s.valueString;
      }
      out.set(i.linkId, { value, status: sub.status, source: sub.source, attestedBy: sub.attestedBy, hasExt: !!ev });
    }
  };
  walk(qr.item);
  return out;
}

describe("merge — source precedence (retrieved › attested › context › documented › inferred)", () => {
  it("context overrides an extracted answer for the same linkId and records a discrepancy", () => {
    const r = run({
      extractedResponse: extractedQr({ "patient.age": { value: 61, status: "documented", quote: "61yo" } }),
      context: { age: 65 },
    });
    const got = collect(r.questionnaireResponse);
    expect(got.get("patient.age")!.value).toBe(65);
    expect(got.get("patient.age")!.hasExt).toBe(false); // context answers carry no evidence extension
    expect(r.discrepancies).toHaveLength(1);
    expect(r.discrepancies[0]).toMatchObject({
      linkId: "patient.age",
      kept: { value: 65, provenance: "context" },
      superseded: { value: 61, provenance: "extracted" },
      valuesMatch: false,
    });
  });

  it("attested overrides context for the same linkId", () => {
    // (contrived — an attestation linkId would not normally also be a context
    // key, but the ranking must hold)
    const r = merge({
      attestationLinkIds: ["patient.age"],
      itemIndex,
      extractedResponse: extractedQr({}),
      context: { age: 40 },
      attestations: { "patient.age": { value: true as any, attestedBy: "Dr A" } },
    });
    const got = collect(r.questionnaireResponse);
    expect(got.get("patient.age")!.source).toBe("referrer-attestation");
    expect(r.discrepancies.some((d) => d.linkId === "patient.age" && d.kept.provenance === "attested" && d.superseded.provenance === "context")).toBe(true);
  });

  it("an inferred extracted answer is kept when nothing supersedes it, and labelled inferred", () => {
    const r = run({
      extractedResponse: extractedQr({ "workup.bloods": { value: true, status: "inferred", quote: "Hb low" } }),
    });
    const got = collect(r.questionnaireResponse);
    expect(got.get("workup.bloods")).toMatchObject({ value: true, status: "inferred" });
    expect(r.discrepancies).toHaveLength(0);
  });

  it("a discrepancy is recorded even when the superseding value agrees (valuesMatch: true)", () => {
    const r = run({
      extractedResponse: extractedQr({ "patient.age": { value: 65, status: "documented", quote: "65yo" } }),
      context: { age: 65 },
    });
    expect(r.discrepancies).toHaveLength(1);
    expect(r.discrepancies[0].valuesMatch).toBe(true);
  });
});

describe("merge — attestation category (AD-17)", () => {
  it("a category indicator is set only from the attestation, with status documented + source sub-extension", () => {
    const r = run({
      extractedResponse: extractedQr({ "weightloss.present": { value: true, quote: "wt loss" } }),
      attestations: { "workup.strongSuspicionMalignancy": { value: true, attestedBy: "Dr Smith" } },
    });
    const got = collect(r.questionnaireResponse);
    const att = got.get("workup.strongSuspicionMalignancy")!;
    expect(att.value).toBe(true);
    expect(att.status).toBe("documented");
    expect(att.source).toBe("referrer-attestation");
    expect(att.attestedBy).toBe("Dr Smith");
    expect(att.source).toBe("referrer-attestation");
    expect(r.attestationsApplied).toEqual([{ linkId: "workup.strongSuspicionMalignancy", value: true, attestedBy: "Dr Smith", mode: "referrer" }]);
  });

  it("emits a category answer as valueBoolean even when itemIndex has no type for it (the pipeline strips attestation items before building itemIndex — AD-17)", () => {
    // Reproduce the pipeline: itemIndex built over Questionnaires with the
    // attestation items removed, so it carries no type for the linkId. The
    // attestation value is a boolean; a valueString would make the CQL `Bool()`
    // retrieve null and the pathway unreachable.
    const strippedIndex = new Map(itemIndex);
    strippedIndex.delete("workup.strongSuspicionMalignancy");
    const r = merge({
      attestationLinkIds: ATTESTATION,
      itemIndex: strippedIndex,
      extractedResponse: extractedQr({}),
      attestations: { "workup.strongSuspicionMalignancy": { value: true, attestedBy: "Dr Smith" } },
    });
    const workup = r.questionnaireResponse.item.find((g: any) => g.linkId === "workup");
    const ans = workup.item.find((i: any) => i.linkId === "workup.strongSuspicionMalignancy").answer[0];
    expect(ans.valueBoolean).toBe(true);
    expect("valueString" in ans).toBe(false);
  });

  it("triager mode records source 'triager-from-referral'", () => {
    const r = run({
      extractedResponse: extractedQr({}),
      attestations: { "workup.strongSuspicionMalignancy": { value: true, attestedBy: "PCRL Jones", mode: "triager" } },
    });
    const att = collect(r.questionnaireResponse).get("workup.strongSuspicionMalignancy")!;
    expect(att.source).toBe("triager-from-referral");
    expect(r.attestationsApplied[0].mode).toBe("triager");
  });

  it("throws if the extracted response answered a category indicator (the gate should have rejected it)", () => {
    expect(() =>
      run({ extractedResponse: extractedQr({ "workup.strongSuspicionMalignancy": { value: true, quote: "malignancy" } }) }),
    ).toThrow(/attestation-category/);
  });

  it("ignores an attestation for a non-category linkId (a referrer tick cannot set an arbitrary indicator)", () => {
    const r = run({
      extractedResponse: extractedQr({}),
      attestations: { "weightloss.present": { value: true, attestedBy: "Dr Smith" } },
    });
    expect(collect(r.questionnaireResponse).has("weightloss.present")).toBe(false);
    expect(r.attestationsApplied).toHaveLength(0);
  });

  it("a category indicator with no attestation stays absent (null downstream, never defaulted)", () => {
    const r = run({ extractedResponse: extractedQr({ "weightloss.present": { value: true, quote: "wt loss" } }) });
    expect(collect(r.questionnaireResponse).has("workup.strongSuspicionMalignancy")).toBe(false);
  });
});

describe("merge — expectedAbsent linkIds stay absent", () => {
  it("the merge never invents an answer — an unmentioned linkId is not in the output", () => {
    const r = run({
      extractedResponse: extractedQr({
        "patient.age": { value: 68, quote: "68yo" },
        "workup.localisingFeatures": { value: true, quote: "mass" },
      }),
      context: { sex: "male" },
      attestations: { "workup.strongSuspicionMalignancy": { value: false, attestedBy: "Dr A" } },
    });
    const got = collect(r.questionnaireResponse);
    // present: exactly what was supplied
    expect([...got.keys()].sort()).toEqual(
      ["patient.age", "patient.sex", "workup.localisingFeatures", "workup.strongSuspicionMalignancy"].sort(),
    );
    // absent: e.g. weightloss.percent, symptom.jaundice — never fabricated
    expect(got.has("weightloss.percent")).toBe(false);
    expect(got.has("symptom.jaundice")).toBe(false);
  });
});

describe("merge — context labs", () => {
  it("uses a lab entry that carries a linkId; lists one that does not in unmappedContext", () => {
    const r = run({
      extractedResponse: extractedQr({}),
      context: {
        labs: [
          { linkId: "lab.hb.low", value: true },
          { name: "Ferritin", value: 12 },
        ],
      },
    });
    const got = collect(r.questionnaireResponse);
    expect(got.get("lab.hb.low")).toMatchObject({ value: true, hasExt: false });
    expect(r.unmappedContext).toEqual([{ name: "Ferritin", reason: expect.stringContaining("no linkId") }]);
  });
});

describe("merge — quantity answers reach the engine as valueQuantity.value (KI-77)", () => {
  const qtyQr = (vq: any) => ({
    resourceType: "QuestionnaireResponse", status: "completed",
    item: [{ linkId: "lab", item: [{ linkId: "lab.crp.value", answer: [{ valueQuantity: vq, extension: [{ url: ANSWER_EVIDENCE_EXT_URL, extension: [{ url: "status", valueCode: "documented" }, { url: "quote", valueString: "CRP 12" }] }] }] }] }],
  });
  const vqOf = (qr: any) => {
    let out: any;
    const walk = (items: any[]) => { for (const i of items || []) { if (Array.isArray(i.item)) walk(i.item); if (i.linkId === "lab.crp.value") out = i.answer[0].valueQuantity; } };
    walk(qr.item);
    return out;
  };
  it("wraps a bare number", () => {
    expect(vqOf(run({ extractedResponse: qtyQr(12) }).questionnaireResponse)).toEqual({ value: 12 });
  });
  it("drops a UCUM-system code that is not valid UCUM (FHIRHelpers would throw) and converts a numeric string", () => {
    const r = run({ extractedResponse: extractedQr({}), context: { labs: [{ linkId: "lab.crp.value", value: { value: 12, system: "http://unitsofmeasure.org", code: "IU/L" } }] } });
    expect(vqOf(r.questionnaireResponse)).toEqual({ value: 12 });
    expect(vqOf(run({ extractedResponse: qtyQr("12") }).questionnaireResponse)).toEqual({ value: 12 });
  });
  it("keeps a full UCUM quantity's value (was: reduced to its code string)", () => {
    const got = vqOf(run({ extractedResponse: qtyQr({ value: 12, unit: "mg/L", system: "http://unitsofmeasure.org", code: "mg/L" }) }).questionnaireResponse);
    expect(got).toEqual({ value: 12 });
  });
  it("reduces a context quantity with a non-UCUM unit to its value (FHIRHelpers would throw)", () => {
    const r = run({ extractedResponse: extractedQr({}), context: { labs: [{ linkId: "lab.crp.value", value: { value: 12, unit: "IU/L" } }] } });
    expect(vqOf(r.questionnaireResponse)).toEqual({ value: 12 });
  });
});

describe("engine — a merged quantity is read by a real site library (KI-77)", () => {
  it("US Abdomen reads lab.alt.value from merge output; the old bare-number shape was treated as missing", async () => {
    const { evaluateExam } = await import("../engine");
    const usAbdomenElm = (await import("../../../../tooling/criteria-bundle/elm/CRR_USAbdomen_Adult.json")).default;
    const ev = (q: string) => [{ url: ANSWER_EVIDENCE_EXT_URL, extension: [{ url: "status", valueCode: "documented" }, { url: "quote", valueString: q }] }];
    const qr = (vq: any) => ({
      resourceType: "QuestionnaireResponse", status: "completed", subject: { reference: "Patient/p" },
      item: [
        { linkId: "patient", item: [{ linkId: "patient.age", answer: [{ valueInteger: 60, extension: ev("60") }] }] },
        { linkId: "lab", item: [{ linkId: "lab.alt.value", answer: [{ valueQuantity: vq, extension: ev("ALT 150") }] }] },
      ],
    });
    const usAbdomenQ = (await import("../../../../tooling/criteria-bundle/sites/us-abdomen-adult/Questionnaire-us-abdomen-adult.json")).default;
    const idx = buildItemIndex([nationalQ as any, usAbdomenQ as any]);
    const merged = run({ extractedResponse: qr(150), itemIndex: idx }).questionnaireResponse; // the route's bare number, merged
    const good: any = await evaluateExam(usAbdomenElm, merged, "strict");
    expect(good.missingInformation ?? []).not.toContain("lab.alt.value");
    const old: any = await evaluateExam(usAbdomenElm, qr(150), "strict"); // bare number, unmerged
    expect(old.missingInformation ?? []).toContain("lab.alt.value");
  });
});
