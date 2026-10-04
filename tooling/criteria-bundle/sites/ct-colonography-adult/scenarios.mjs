// Test scenarios for CRR_CTColonography_Adult.
// The Questionnaire has no items. Answers here use national vocabulary linkIds
// that other exam/sites' Questionnaires contribute to the same response; they
// must not change the outcome. No matrix case exists for this site.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";

const REDIRECT = "Please follow the Colorectal Symptoms HealthPathway for local guidance and follow local processes .";
const OUTCOME = { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [REDIRECT], unconfirmedExclusions: [] };

export const scenarios = [
  {
    id: "CTC-S01-empty",
    title: "No answers at all: alternative management, nothing missing",
    answers: {},
    expect: OUTCOME,
  },
  {
    id: "CTC-S02-bowel-symptoms",
    title: "Synthetic note with lower GI symptoms answered for another site: same outcome",
    note: "58F. 8/52 looser, more frequent stools. Persistent lower abdominal discomfort. Requesting CT colonography.",
    answers: {
      "patient.age": 58, "patient.sex": "female",
      "symptom.persistentAbdominal": { v: true, status: "documented", quote: "Persistent lower abdominal discomfort" },
    },
    expect: OUTCOME,
  },
  {
    id: "CTC-S03-inferred-standard",
    title: "Documentation standard 'inferred': same outcome, no inferred indicators",
    answers: { "symptom.persistentAbdominal": { v: true, status: "inferred", quote: "discomfort" } },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...OUTCOME, inferredExcluded: [] },
  },
];

function answerFor(a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const ans = typeof raw.v === "boolean" ? { valueBoolean: raw.v }
    : typeof raw.v === "number" ? (Number.isInteger(raw.v) ? { valueInteger: raw.v } : { valueDecimal: raw.v })
    : { valueCoding: { code: raw.v } };
  if (raw.status) {
    ans.extension = [{ url: EVIDENCE_URL, extension: [
      { url: "status", valueCode: raw.status },
      ...(raw.quote ? [{ url: "quote", valueString: raw.quote }] : []),
    ] }];
  }
  return ans;
}

export function toQuestionnaireResponse(s) {
  const groups = {};
  for (const [linkId, a] of Object.entries(s.answers)) {
    (groups[linkId.split(".")[0]] ||= []).push({ linkId, answer: [answerFor(a)] });
  }
  return {
    resourceType: "QuestionnaireResponse",
    id: "qr-" + s.id,
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-CT-Colonography-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-04",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
