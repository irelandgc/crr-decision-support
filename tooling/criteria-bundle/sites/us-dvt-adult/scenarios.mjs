// Test scenarios for CRR_USDVT_Adult (US DVT - Adult, National ID 15372 v2.0 pp.36-37).
// NOT CLINICALLY SIGNED OFF. No matrix case exists for this site (the results matrix's only
// DVT mention, MW-004, is a US Pelvis case - transcription-notes.md section 6), and no STEP-3
// worked example applies. Order: one scenario per pathway met, per redirect, per not-funded item,
// per boundary, the overlap/precedence readings (REVIEW Q3-Q6, Q14), insufficient cases with the
// missing-information list, and strict-vs-inferred.
// Notes are synthetic; no patient-identifiable data.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";

const R_CHILD = "Children aged younger than 15 years – see local DVT HealthPathway";
const R_PREGNANT = "Pregnant women – see local DVT HealthPathway.";

// Every criterion row answered "no", adult, not pregnant: CRITERIA_NOT_MET with nothing missing.
// Scenarios override the atoms they exercise.
const NEG = {
  "patient.age": 50,
  "patient.pregnant": false,
  "symptom.superficialVenousThrombosis": false,
  "symptom.suspectedDvtUpperLimb": false,
  "advice.sameDayImagingRecommended": false,
  "symptom.suspectedDvtLowerLimb": false,
  "imaging.usdvt.initialNegative": false,
  "symptom.calfDvt": false,
  "advice.followUpImagingRecommendedBySpecialist": false,
  "advice.postAnticoagulationScanRecommended": false,
  "funding.routineClotResolutionFollowUp": false,
};
const without = (obj, ...keys) => Object.fromEntries(Object.entries(obj).filter(([k]) => !keys.includes(k)));

const A24 = { determination: "ACUTE_24H", priorityCode: "A24" };
const A48 = { determination: "ACUTE_48H", priorityCode: "A48" };
const S1 = { determination: "S1_TIME_SENSITIVE", priorityCode: "S1" };
const S2 = { determination: "S2_TIME_SENSITIVE", priorityCode: "S2" };
const NRF = { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null };
const NOT_MET = { determination: "CRITERIA_NOT_MET", priorityCode: null };
const INSUFF = { determination: "INSUFFICIENT_INFORMATION", priorityCode: null };

export const scenarios = [
  // ---- Acute: Within 24 hours -------------------------------------------------------------
  {
    id: "DVT-S01-a24-svt-proximal-lsv",
    title: "SVT affecting the proximal long saphenous vein in the thigh: Acute 24h",
    note: "Tender cord medial thigh, superficial thrombophlebitis of proximal long saphenous vein.",
    answers: { ...NEG,
      "symptom.superficialVenousThrombosis": { v: true, status: "documented", quote: "superficial thrombophlebitis" },
      "symptom.svtProximalLongSaphenousVeinThigh": { v: true, status: "documented", quote: "proximal long saphenous vein" } },
    expect: { ...A24, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "DVT-S02-a24-upper-limb",
    title: "Clinically suspected upper limb DVT: Acute 24h",
    answers: { ...NEG, "symptom.suspectedDvtUpperLimb": true },
    expect: { ...A24, missing: [], redirects: [] },
  },
  {
    id: "DVT-S03-a24-same-day-advice",
    title: "Same-day DVT US recommended by Haematology, adviser named: Acute 24h, nothing missing",
    answers: { ...NEG, "advice.sameDayImagingRecommended": true, "advice.adviserNameRole": "Dr A (haematology registrar)" },
    expect: { ...A24, missing: [] },
  },
  {
    id: "DVT-S04-a24-advice-no-adviser",
    title: "Same-day advice without the adviser's name and role: Acute 24h, asks for adviser (Overview p5)",
    answers: { ...NEG, "advice.sameDayImagingRecommended": true },
    expect: { ...A24, missing: ["advice.adviserNameRole"] },
  },

  // ---- Acute: Within 48 hours -------------------------------------------------------------
  {
    id: "DVT-S05-a48-wells-2-boundary",
    title: "Suspected lower limb DVT, Wells exactly 2 (boundary, >= 2): Acute 48h",
    note: "?DVT left calf. Wells score 2.",
    answers: { ...NEG,
      "symptom.suspectedDvtLowerLimb": { v: true, status: "documented", quote: "?DVT left calf" },
      "workup.wellsScoreDvt": { v: 2, status: "documented", quote: "Wells score 2" } },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S06-a48-wells-1-ddimer-pos",
    title: "Suspected lower limb DVT, Wells 1 (boundary, < 2) and positive D-dimer: Acute 48h",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 1, "lab.ddimer.positive": true },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S07-a48-wells-1-ddimer-neg",
    title: "Suspected lower limb DVT, Wells 1, D-dimer negative, every other row no: criteria not met",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 1, "lab.ddimer.positive": false },
    expect: { ...NOT_MET, missing: [] },
  },
  {
    id: "DVT-S08-a48-ddimer-unknown",
    title: "Suspected lower limb DVT, Wells 1, D-dimer not stated: insufficient, asks for D-dimer",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 1 },
    expect: { ...INSUFF, missing: ["lab.ddimer.positive"] },
  },
  {
    id: "DVT-S09-a48-wells-unknown",
    title: "Suspected lower limb DVT, no Wells score and no D-dimer: insufficient, asks for both",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true },
    expect: { ...INSUFF, missing: ["workup.wellsScoreDvt", "lab.ddimer.positive"] },
  },
  {
    id: "DVT-S10-a48-wells-4-ddimer-neg",
    title: "Suspected lower limb DVT, Wells 4, D-dimer negative: Acute 48h (D-dimer only matters below 2)",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 4, "lab.ddimer.positive": false },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S11-a48-negative-wells",
    title: "Suspected lower limb DVT, Wells -1 and positive D-dimer: Acute 48h (score can be negative)",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": -1, "lab.ddimer.positive": true },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S12-wells-without-suspicion",
    title: "Wells 3 but lower limb DVT not suspected: the mandatory stem fails, criteria not met",
    answers: { ...NEG, "workup.wellsScoreDvt": 3 },
    expect: { ...NOT_MET, missing: [] },
  },

  // ---- S1 ---------------------------------------------------------------------------------
  {
    id: "DVT-S13-s1-negative-initial-us",
    title: "No DVT on initial US, suspicion remains high, Wells 2; lower limb suspicion not answered: S1 (REVIEW Q14)",
    answers: { ...without(NEG, "symptom.suspectedDvtLowerLimb"),
      "imaging.usdvt.initialNegative": true, "workup.dvtClinicalSuspicionHigh": true, "workup.wellsScoreDvt": 2 },
    expect: { ...S1, missing: [] },
  },
  {
    id: "DVT-S14-s1-overlaps-a48",
    title: "Same as S13 but lower limb DVT still clinically suspected: Acute 48h also met and wins (REVIEW Q4)",
    answers: { ...NEG, "symptom.suspectedDvtLowerLimb": true,
      "imaging.usdvt.initialNegative": true, "workup.dvtClinicalSuspicionHigh": true, "workup.wellsScoreDvt": 2 },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S15-s1-wells-1",
    title: "No DVT on initial US, suspicion remains high, Wells 1: S1 bullet 1 not met, criteria not met",
    answers: { ...NEG, "imaging.usdvt.initialNegative": true, "workup.dvtClinicalSuspicionHigh": true, "workup.wellsScoreDvt": 1 },
    expect: { ...NOT_MET, missing: [] },
  },
  {
    id: "DVT-S16-s1-suspicion-unknown",
    title: "No DVT on initial US, Wells 3, suspicion not attested; lower limb not suspected: insufficient, asks for the attestation",
    answers: { ...NEG, "imaging.usdvt.initialNegative": true, "workup.wellsScoreDvt": 3 },
    expect: { ...INSUFF, missing: ["workup.dvtClinicalSuspicionHigh"] },
  },
  {
    id: "DVT-S17-s1-calf-no-anticoag",
    title: "Calf DVT not treated with anticoagulation: S1",
    answers: { ...NEG, "symptom.calfDvt": true, "history.anticoagulantTherapy": false },
    expect: { ...S1, missing: [] },
  },
  {
    id: "DVT-S18-s1-calf-on-anticoag",
    title: "Calf DVT on anticoagulation: S1 bullet 2 not met, criteria not met",
    answers: { ...NEG, "symptom.calfDvt": true, "history.anticoagulantTherapy": true },
    expect: { ...NOT_MET, missing: [] },
  },
  {
    id: "DVT-S19-s1-calf-anticoag-unknown",
    title: "Calf DVT, anticoagulation not stated: insufficient, asks for anticoagulation status",
    answers: { ...NEG, "symptom.calfDvt": true },
    expect: { ...INSUFF, missing: ["history.anticoagulantTherapy"] },
  },
  {
    id: "DVT-S20-s1-follow-up-advice",
    title: "Radiologist advises follow-up DVT US, adviser named: S1",
    answers: { ...NEG, "advice.followUpImagingRecommendedBySpecialist": true, "advice.adviserNameRole": "Dr B (radiologist)" },
    expect: { ...S1, missing: [] },
  },

  // ---- S2 ---------------------------------------------------------------------------------
  {
    id: "DVT-S21-s2-post-anticoag",
    title: "Secondary care specialist recommends follow-up scan after anticoagulation, adviser named: S2",
    answers: { ...NEG, "advice.postAnticoagulationScanRecommended": true, "advice.adviserNameRole": "Dr C (haematologist)" },
    expect: { ...S2, missing: [] },
  },
  {
    id: "DVT-S22-s2-overlaps-s1-advice",
    title: "Post-anticoagulation advice also read as follow-up DVT US advice: S1 wins (REVIEW Q5)",
    answers: { ...NEG, "advice.postAnticoagulationScanRecommended": true, "advice.followUpImagingRecommendedBySpecialist": true,
      "advice.adviserNameRole": "Dr C (haematologist)" },
    expect: { ...S1, missing: [] },
  },

  // ---- Alternative management -------------------------------------------------------------
  {
    id: "DVT-S23-redirect-child",
    title: "Age 14 with suspected upper limb DVT: alternative management (local DVT HealthPathway)",
    answers: { ...NEG, "patient.age": 14, "symptom.suspectedDvtUpperLimb": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_CHILD], unconfirmedExclusions: [] },
  },
  {
    id: "DVT-S24-age-15-boundary",
    title: "Age 15 with suspected upper limb DVT: not 'younger than 15', assessed on these criteria (REVIEW Q7)",
    answers: { ...NEG, "patient.age": 15, "symptom.suspectedDvtUpperLimb": true },
    expect: { ...A24, missing: [], redirects: [] },
  },
  {
    id: "DVT-S25-redirect-pregnant",
    title: "Pregnant, suspected lower limb DVT, Wells 3: alternative management (redirect wins over criteria)",
    answers: { ...NEG, "patient.pregnant": true, "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 3 },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_PREGNANT] },
  },

  // ---- Not routinely funded ---------------------------------------------------------------
  {
    id: "DVT-S26-nf-svt-not-proximal",
    title: "SVT not affecting the proximal long saphenous vein in the thigh, every timeframe row no: not routinely funded (REVIEW Q3, all rows false)",
    answers: { ...NEG, "symptom.superficialVenousThrombosis": true, "symptom.svtProximalLongSaphenousVeinThigh": false },
    expect: { ...NRF, missing: [], redirects: [] },
  },
  {
    id: "DVT-S27-nf-routine-clot-resolution",
    title: "Routine follow-up scan to confirm clot resolution, every timeframe row no: not routinely funded (REVIEW Q3, all rows false)",
    answers: { ...NEG, "funding.routineClotResolutionFollowUp": true },
    expect: { ...NRF, missing: [] },
  },
  {
    id: "DVT-S28-nf-svt-with-dvt-criteria",
    title: "Not-funded SVT plus suspected lower limb DVT with Wells 2: Acute 48h (REVIEW Q3, a row met)",
    answers: { ...NEG, "symptom.superficialVenousThrombosis": true, "symptom.svtProximalLongSaphenousVeinThigh": false,
      "symptom.suspectedDvtLowerLimb": true, "workup.wellsScoreDvt": 2 },
    expect: { ...A48, missing: [] },
  },
  {
    id: "DVT-S29-s2-vs-routine-follow-up",
    title: "Specialist-recommended post-anticoagulation scan also marked routine clot-resolution follow-up: S2 (REVIEW Q6)",
    answers: { ...NEG, "advice.postAnticoagulationScanRecommended": true, "funding.routineClotResolutionFollowUp": true,
      "advice.adviserNameRole": "Dr C (haematologist)" },
    expect: { ...S2, missing: [] },
  },
  {
    id: "DVT-S34-nf-svt-row-undetermined",
    title: "Not-funded SVT plus suspected lower limb DVT, Wells and D-dimer not stated: insufficient, asks for both (REVIEW Q3, a row undetermined)",
    answers: { ...NEG, "symptom.superficialVenousThrombosis": true, "symptom.svtProximalLongSaphenousVeinThigh": false,
      "symptom.suspectedDvtLowerLimb": true },
    expect: { ...INSUFF, missing: ["workup.wellsScoreDvt", "lab.ddimer.positive"] },
  },
  {
    id: "DVT-S35-nf-routine-s2-undetermined",
    title: "Routine clot-resolution follow-up, post-anticoagulation specialist advice not stated: insufficient, asks for it (REVIEW Q3, a row undetermined)",
    answers: { ...without(NEG, "advice.postAnticoagulationScanRecommended"), "funding.routineClotResolutionFollowUp": true },
    expect: { ...INSUFF, missing: ["advice.postAnticoagulationScanRecommended"] },
  },

  // ---- Insufficient information -----------------------------------------------------------
  {
    id: "DVT-S30-svt-location-unknown",
    title: "SVT with location not stated, every other row no: insufficient, asks for the location",
    answers: { ...NEG, "symptom.superficialVenousThrombosis": true },
    expect: { ...INSUFF, missing: ["symptom.svtProximalLongSaphenousVeinThigh"] },
  },
  {
    id: "DVT-S31-empty",
    title: "No answers at all: insufficient, every criterion atom listed, age and pregnancy unconfirmed",
    answers: {},
    expect: { ...INSUFF, redirects: [], unconfirmedExclusions: ["patient.age", "patient.pregnant"],
      missing: [
        "symptom.superficialVenousThrombosis", "symptom.svtProximalLongSaphenousVeinThigh", "symptom.suspectedDvtUpperLimb",
        "advice.sameDayImagingRecommended", "symptom.suspectedDvtLowerLimb", "workup.wellsScoreDvt", "lab.ddimer.positive",
        "imaging.usdvt.initialNegative", "workup.dvtClinicalSuspicionHigh", "symptom.calfDvt", "history.anticoagulantTherapy",
        "advice.followUpImagingRecommendedBySpecialist", "advice.postAnticoagulationScanRecommended",
      ] },
  },

  // ---- Strict versus inferred (REVIEW Q1) -------------------------------------------------
  {
    id: "DVT-S32-wells-inferred-strict",
    title: "Wells score computed by the extraction step from components ('inferred'): strict standard does not accept it",
    note: "?DVT right leg. Calf swelling 4 cm, pitting oedema, tender along deep veins. No alternative diagnosis more likely.",
    answers: { ...NEG,
      "symptom.suspectedDvtLowerLimb": { v: true, status: "documented", quote: "?DVT right leg" },
      "workup.wellsScoreDvt": { v: 4, status: "inferred", quote: "Calf swelling 4 cm, pitting oedema, tender along deep veins" } },
    expect: { ...INSUFF, missing: ["workup.wellsScoreDvt", "lab.ddimer.positive"], inferredExcluded: ["workup.wellsScoreDvt"] },
  },
  {
    id: "DVT-S33-wells-inferred-accepted",
    title: "Same note under documentation standard 'inferred': Acute 48h",
    answers: { ...NEG,
      "symptom.suspectedDvtLowerLimb": { v: true, status: "documented", quote: "?DVT right leg" },
      "workup.wellsScoreDvt": { v: 4, status: "inferred", quote: "Calf swelling 4 cm, pitting oedema, tender along deep veins" } },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...A48, missing: [], inferredExcluded: [] },
  },
];

function answerFor(a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const ans = typeof raw.v === "boolean" ? { valueBoolean: raw.v }
    : typeof raw.v === "number" ? (Number.isInteger(raw.v) ? { valueInteger: raw.v } : { valueDecimal: raw.v })
    : { valueString: raw.v };
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
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-US-DVT-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
