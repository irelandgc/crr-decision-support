// Test scenarios for CRR_CTChest_Adult (CT Chest - Adult, National ID 15372 v2.0 pp.12-16).
// NOT CLINICALLY REVIEWED. Notes are synthetic; no patient-identifiable data.
//
// Matrix cases: none. documents/CRR_Test_Case_Results_Matrix_v2.xlsx (all four sheets)
// has no CT Chest case (exam types seen: CT CAP, CT Head, CT KUB, CT Sinus, CXR, US*,
// X-ray*). No STEP-3 worked example in instructions/arch-mig-prompt-decomposition.md
// applies to this site. So the list starts with pathway coverage.
//
// Each scenario is a map of linkId -> answer. An answer is a bare value (documented,
// no evidence extension) or { v, status, quote }. Omitted linkIds are not answered.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";
const STRING_ITEMS = new Set(["advice.adviserNameRole"]);

// Footnote *1 indicators (p15), in printed order.
const FN1 = [
  "symptom.dyspnoeaUnexplainedNewOrWorsening",
  "symptom.coughUnexplainedOver3Weeks",
  "symptom.chestShoulderPainUnexplainedOver3Weeks",
  "symptom.chronicRespiratorySymptomChangeOver3Weeks",
  "symptom.hoarsenessUnexplainedOver3Weeks",
  "symptom.chestInfectionsRepeatedOrUnresolved",
  "symptom.haemoptysisPersistentUnexplained",
  "symptom.weightAndAppetiteLossOver3Weeks",
  "symptom.abnormalChestSignsOver3Weeks",
  "symptom.supraclavicularLymphadenopathyNew",
  "symptom.paraneoplasticFeatures",
  "symptom.cervicalLymphadenopathyOver3WeeksOver1cm",
];
const FN1_ALL_FALSE = Object.fromEntries(FN1.map(id => [id, false]));

// Both redirect triggers answered "no" (clears unconfirmedExclusions).
const NO_REDIRECT = { "symptom.nonSpecificSymptomsConcerningForCancer": false, "workup.ctIncidentalNoduleFollowUp": false };
// One "no" per pathway: makes every P2 and P3 pathway definitively false.
const ALL_PATHWAYS_FALSE = {
  "redflag.haemoptysisPresent": false,
  "patient.currentSmoker": false,
  "workup.cxrIndeterminateAbnormality": false,
  "workup.cxrPersistentConsolidationFollowUp": false,
  "advice.urgentStagingCtRecommended": false,
  "advice.urgentImagingRecommended": false,
  "workup.cxrIsolatedPulmonaryNodule": false,
  "advice.nonUrgentImagingRecommended": false,
};
const ADVISER = { "advice.adviserNameRole": "Respiratory physician (name and role in referral)" };

const P2_1_MET = {
  "redflag.haemoptysisPresent": true, "symptom.haemoptysisWithoutChestInfection": true,
  "workup.upperAirwayBleedingExcluded": true, "workup.cxr": true, "workup.initialInvestigationsCauseNotFound": true,
};
const P2_2_MET = {
  "patient.currentSmoker": true, "symptom.coughUnexplainedOver3Weeks": true, "symptom.newOnset": true,
  "symptom.persistentSixWeeksDespiteTreatment": true, "workup.cxr": true, "workup.bloods": true,
  "workup.initialInvestigationsCauseNotFound": true,
};

const AM1 = "Patient re-presents with concerning symptoms or signs and chest x-ray is normal, but doesn’t meet the above criteria for CT chest referral – seek advice from secondary care respiratory team, regarding appropriate management and whether CT chest is warranted.";
const AM2 = "Persistent, non-specific, non-localising symptoms and signs which are concerning for underlying cancer (e.g. weight loss, fatigue) and initial investigations including chest x-ray and bloods fail to identify a cause. See CT Chest/Abdomen/Pelvis HealthPathway.";
const AM4 = "Follow-up of nodule discovered incidentally on CT chest scan - refer to secondary care for management advice unless radiology report confirms benign based on CT appearance and no follow-up is required (e.g. intrapulmonary lymph node, benign pattern of calcification).";

const ALL_MISSING = [
  "patient.age",
  "redflag.haemoptysisPresent", "symptom.haemoptysisWithoutChestInfection", "workup.upperAirwayBleedingExcluded",
  "workup.cxr", "workup.initialInvestigationsCauseNotFound",
  "patient.currentSmoker", "symptom.newOnset", "symptom.persistentSixWeeksDespiteTreatment", "workup.bloods", ...FN1,
  "workup.cxrIndeterminateAbnormality", "workup.radiologyReportRecommendsImaging",
  "workup.cxrPersistentConsolidationFollowUp",
  "advice.urgentStagingCtRecommended", "advice.localHealthPathwayAdvisesCt",
  "advice.urgentImagingRecommended",
  "workup.cxrIsolatedPulmonaryNodule", "workup.cxrNoduleNotConfirmedBenign",
  "advice.nonUrgentImagingRecommended",
];

export const scenarios = [
  {
    id: "CTCH-S01-empty",
    title: "No answers: insufficient information; every undetermined pathway's indicators asked for",
    answers: {},
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ALL_MISSING, redirects: [],
      unconfirmedExclusions: ["symptom.nonSpecificSymptomsConcerningForCancer", "workup.ctIncidentalNoduleFollowUp"] },
  },
  {
    id: "CTCH-S02-p2-haemoptysis",
    title: "P2 bullet 1: unexplained haemoptysis, no chest infection, URT causes excluded, CXR shows no cause",
    note: "48F. 3 episodes of small-volume haemoptysis over 2/52. No URTI or chest infection features. ENT exam: no nasal/oral bleeding source. CXR normal, no cause found.",
    answers: { "patient.age": 48, ...P2_1_MET, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S03-p2-haemoptysis-infection",
    title: "P2 bullet 1 not met: haemoptysis with chest infection; every other pathway answered no",
    answers: { "patient.age": 48, ...ALL_PATHWAYS_FALSE, ...P2_1_MET, "symptom.haemoptysisWithoutChestInfection": false,
      "workup.rePresentation": false, ...NO_REDIRECT },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S04-p2-smoker-over-55",
    title: "P2 bullet 2: 62, current smoker, new cough >3 weeks, persistent 6 weeks despite treatment, unexplained after CXR and bloods",
    note: "62M current smoker. New cough, worsening, now 7/52 despite 2 courses of antibiotics. CXR and bloods unremarkable.",
    answers: { "patient.age": 62, ...P2_2_MET, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S05-p2-smoker-age-55-boundary",
    title: "P2 bullet 2 boundary: aged exactly 55 is not 'over 55' (REVIEW Q1); every other pathway answered no",
    answers: { "patient.age": 55, ...ALL_PATHWAYS_FALSE, ...P2_2_MET, "workup.rePresentation": false, ...NO_REDIRECT },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "CTCH-S06-p2-smoker-insufficient",
    title: "P2 bullet 2 undetermined: smoker over 55, work-up negative, no symptom detail - asks for *1 items, onset, persistence",
    answers: { "patient.age": 62, ...ALL_PATHWAYS_FALSE, "patient.currentSmoker": true,
      "workup.cxr": true, "workup.bloods": true, "workup.initialInvestigationsCauseNotFound": true, ...NO_REDIRECT },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null,
      missing: ["symptom.newOnset", "symptom.persistentSixWeeksDespiteTreatment", ...FN1], redirects: [] },
  },
  {
    id: "CTCH-S07-p2-smoker-no-concerning-symptom",
    title: "P2 bullet 2 not met: every *1 item answered no; every other pathway answered no",
    answers: { "patient.age": 62, ...ALL_PATHWAYS_FALSE, ...P2_2_MET, ...FN1_ALL_FALSE, ...NO_REDIRECT },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S08-p2-indeterminate-cxr",
    title: "P2 bullet 3: indeterminate CXR abnormality (bulky hilum), report recommends CT chest",
    answers: { "patient.age": 70, "workup.cxrIndeterminateAbnormality": true, "workup.radiologyReportRecommendsImaging": true, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S09-p2-persistent-consolidation",
    title: "P2 bullet 4: persistent consolidation on 6-week follow-up CXR, report recommends CT chest",
    answers: { "patient.age": 66, "workup.cxrPersistentConsolidationFollowUp": true, "workup.radiologyReportRecommendsImaging": true, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S10-p2-staging",
    title: "P2 bullet 5: radiologist advises urgent staging CT chest/liver, CT is the HealthPathway next step, adviser named",
    answers: { "patient.age": 71, "advice.urgentStagingCtRecommended": true, "advice.localHealthPathwayAdvisesCt": true, ...ADVISER, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S11-p2-staging-pathway-unknown",
    title: "P2 bullet 5 undetermined: staging CT advised but the local HealthPathway step is not stated",
    answers: { "patient.age": 71, ...ALL_PATHWAYS_FALSE, "advice.urgentStagingCtRecommended": true, ...NO_REDIRECT },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["advice.localHealthPathwayAdvisesCt"], redirects: [] },
  },
  {
    id: "CTCH-S12-p2-specialist-no-name",
    title: "P2 bullet 6: PCRL advises urgent CT chest; adviser name/role not given - asked for",
    answers: { "patient.age": 58, "advice.urgentImagingRecommended": true, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: ["advice.adviserNameRole"], redirects: [] },
  },
  {
    id: "CTCH-S13-p3-nodule",
    title: "P3 bullet 1: isolated nodule on CXR, not confirmed benign, report recommends CT; P2 pathways answered no",
    answers: { "patient.age": 64, ...ALL_PATHWAYS_FALSE, "workup.cxrIsolatedPulmonaryNodule": true,
      "workup.cxrNoduleNotConfirmedBenign": true, "workup.radiologyReportRecommendsImaging": true, ...NO_REDIRECT },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S14-p3-specialist-p2-unknown",
    title: "P3 bullet 2: specialist advises non-urgent CT chest; P2 pathways unanswered - P3 returned (REVIEW Q15)",
    answers: { "patient.age": 52, "advice.nonUrgentImagingRecommended": true, ...ADVISER, ...NO_REDIRECT },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S15-p2-and-p3",
    title: "P2 and P3 both met: the higher priority wins",
    answers: { "patient.age": 64, "workup.cxrIndeterminateAbnormality": true, "workup.cxrIsolatedPulmonaryNodule": true,
      "workup.cxrNoduleNotConfirmedBenign": true, "workup.radiologyReportRecommendsImaging": true, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S16-redirect-incidental-ct-nodule",
    title: "Redirect: follow-up of incidental CT nodule, benign status not stated; wins over a P3 specialist pathway",
    answers: { "patient.age": 60, "workup.ctIncidentalNoduleFollowUp": true, "advice.nonUrgentImagingRecommended": true, ...ADVISER,
      "symptom.nonSpecificSymptomsConcerningForCancer": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [AM4], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S17-incidental-ct-nodule-benign",
    title: "No redirect: incidental CT nodule but report confirms benign, no follow-up required; every pathway answered no",
    answers: { "patient.age": 60, ...ALL_PATHWAYS_FALSE, "workup.ctIncidentalNoduleFollowUp": true, "workup.ctNoduleReportConfirmsBenign": true,
      "symptom.nonSpecificSymptomsConcerningForCancer": false, "workup.rePresentation": false },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S18-redirect-non-specific-over-p2",
    title: "Redirect: non-specific symptoms concerning for cancer, work-up negative; wins over P2 bullet 2 met on weight/appetite loss (REVIEW Q10)",
    answers: { "patient.age": 63, ...P2_2_MET, "symptom.coughUnexplainedOver3Weeks": false, "symptom.weightAndAppetiteLossOver3Weeks": true,
      "symptom.nonSpecificSymptomsConcerningForCancer": true, "workup.ctIncidentalNoduleFollowUp": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [AM2], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S19-redirect-re-presents",
    title: "Redirect: re-presents with a *1 symptom and a normal CXR, every pathway definitively not met",
    answers: { "patient.age": 50, ...ALL_PATHWAYS_FALSE, "workup.rePresentation": true, "symptom.coughUnexplainedOver3Weeks": true,
      "workup.cxrNormal": true, ...NO_REDIRECT },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [AM1], unconfirmedExclusions: [] },
  },
  {
    id: "CTCH-S20-re-presents-but-p2-met",
    title: "No re-presentation redirect when a criterion is met (P2 bullet 6)",
    answers: { "patient.age": 50, "workup.rePresentation": true, "symptom.coughUnexplainedOver3Weeks": true, "workup.cxrNormal": true,
      "advice.urgentImagingRecommended": true, ...ADVISER, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "CTCH-S21-criteria-not-met-re-presentation-unknown",
    title: "Criteria definitively not met, *1 symptom present, re-presentation and CXR result unanswered - surfaced as unconfirmed",
    answers: { "patient.age": 50, ...ALL_PATHWAYS_FALSE, "symptom.coughUnexplainedOver3Weeks": true, ...NO_REDIRECT },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [],
      unconfirmedExclusions: ["workup.rePresentation", "workup.cxrNormal"] },
  },
  {
    id: "CTCH-S22-paediatric",
    title: "Aged 15: adult criteria do not apply (REVIEW Q13), even with specialist advice",
    answers: { "patient.age": 15, "advice.urgentImagingRecommended": true, ...ADVISER, ...NO_REDIRECT },
    expect: { determination: "PAEDIATRIC_CRITERIA_APPLY", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "CTCH-S23-adult-boundary",
    title: "Aged 16: adult criteria apply",
    answers: { "patient.age": 16, "advice.urgentImagingRecommended": true, ...ADVISER, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [] },
  },
  {
    id: "CTCH-S24-strict-inferred-abnormality",
    title: "Strict standard: CXR abnormality only inferred - not accepted; insufficient, listed as inferred",
    note: "70M. CXR: right hilar fullness. Report: 'recommend CT chest'.",
    answers: { "patient.age": 70, ...ALL_PATHWAYS_FALSE,
      "workup.cxrIndeterminateAbnormality": { v: true, status: "inferred", quote: "right hilar fullness" },
      "workup.radiologyReportRecommendsImaging": { v: true, status: "documented", quote: "recommend CT chest" }, ...NO_REDIRECT },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["workup.cxrIndeterminateAbnormality"],
      inferredExcluded: ["workup.cxrIndeterminateAbnormality"] },
  },
  {
    id: "CTCH-S25-inferred-standard-abnormality",
    title: "Documentation standard 'inferred': the same note meets P2 bullet 3",
    answers: { "patient.age": 70, ...ALL_PATHWAYS_FALSE,
      "workup.cxrIndeterminateAbnormality": { v: true, status: "inferred", quote: "right hilar fullness" },
      "workup.radiologyReportRecommendsImaging": { v: true, status: "documented", quote: "recommend CT chest" }, ...NO_REDIRECT },
    runWith: { "Documentation Standard": "inferred" },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], inferredExcluded: [] },
  },
  {
    id: "CTCH-S26-national-red-flag-not-re-encoded",
    title: "Massive haemoptysis (national RF-01) answered: this library ignores it; CRR_RedFlags stops the pipeline first",
    answers: { "patient.age": 48, "redflag.haemoptysisMassive": true, ...P2_1_MET, ...NO_REDIRECT },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
];

function answerFor(linkId, a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const ans = STRING_ITEMS.has(linkId) ? { valueString: raw.v }
    : typeof raw.v === "boolean" ? { valueBoolean: raw.v }
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
    (groups[linkId.split(".")[0]] ||= []).push({ linkId, answer: [answerFor(linkId, a)] });
  }
  return {
    resourceType: "QuestionnaireResponse",
    id: "qr-" + s.id,
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-CT-Chest-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
