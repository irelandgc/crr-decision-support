// Test scenarios for CRR_CTHead_Adult (National criteria v2.0, pp.20-22). NOT CLINICALLY REVIEWED.
// Order: (a) every results-matrix case for CT Head, with the evaluator's expectation in
// `evaluator`; where the literal criteria disagree, the literal result is expected and the
// REVIEW question is cited; (b) the STEP-3 worked example (focal neuro vs TIA gateway);
// (c) coverage of every pathway, redirect, the not-funded row, boundaries and
// insufficient-information cases, and a strict-vs-inferred pair.
// Coverage scenarios with no `note` carry structured answers (Criteria Viewer ticks / form
// input). Patient details in notes are the matrix's synthetic tabletop text or invented.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";
const INTEGER_IDS = new Set(["patient.age", "workup.abcd2Score"]);

const d = (v, quote) => ({ v, status: "documented", quote });
const inf = (v, quote) => ({ v, status: "inferred", quote });

// Every presentation stem (and single-indicator pathway) answered "no": isolates one pathway.
const STEMS_NO = {
  "redflag.suspectedTIA": false, "symptom.focalNeurologicalSigns": false, "symptom.seizure": false,
  "symptom.headachePatternChangeProgressive": false, "symptom.cognitiveImpairment": false, "symptom.firstSeizure": false,
  "advice.acuteImagingRecommended": false, "advice.urgentImagingRecommended": false, "advice.nonUrgentImagingRecommended": false,
};
const STEM_IDS = Object.keys(STEMS_NO);
const stemsExcept = (...ids) => STEM_IDS.filter(id => !ids.includes(id));
const HEADACHE_FEATURES = ["history.chronicIllnessWithCerebralInvolvement", "symptom.headacheWorseOnCoughSneezeValsalva", "symptom.headachePersistentNauseaVomiting", "symptom.neuroDeficitSpeechOrWeakness"];
// *4 risk factors (patient.age answered separately).
const RISK_FACTORS_NO = {
  "history.headInjury": false, "symptom.fever": false, "symptom.systemicSymptoms": false,
  "history.anticoagulation": false, "history.anticoagulantTherapy": false,
  "history.malignancy": false, "history.cancerWithBrainMetastasisPropensity": false,
  "symptom.newFocalNeurologicalDeficit": false, "symptom.seizureFocal": false,
  "symptom.persistentAlteredMentalState": false, "symptom.headachePersistent": false,
};
const RISK_FACTOR_LINKIDS = ["history.headInjury", "symptom.fever", "symptom.systemicSymptoms", "history.anticoagulation", "history.malignancy", "symptom.newFocalNeurologicalDeficit", "symptom.seizureFocal", "symptom.persistentAlteredMentalState", "symptom.headachePersistent"];
const LOW_RISK_FIRST_SEIZURE = {
  ...STEMS_NO, "symptom.firstSeizure": true, "symptom.seizureClearHistory": true, "symptom.seizureSingle": true,
  "symptom.seizureUnprovokedOrSubstanceProvoked": true, "symptom.returnedToNormalHealth": true,
  ...RISK_FACTORS_NO, "advice.mriAvailable": true, "symptom.seizuresPoorlyControlledOrRecurrent": false,
  "history.palliativeCare": false,
};
const TIA_ROUTE2 = {
  ...STEMS_NO, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 2,
  "advice.strokeSpecialistRecommended": false, "advice.rapidSpecialistCareAccessible": true,
  "workup.abcd2Score": 3, "symptom.crescendoTIA": false, "history.atrialFibrillation": false, "history.anticoagulantTherapy": false,
  "symptom.tiaSevereOrProlongedDeficit": false, "history.carotidStenosis": false,
  "workup.suitableForCommunityManagement": true, "advice.decisionSupportToolCompleted": true,
};
const SOL_FEATURES_NO = {
  "symptom.rapidCognitiveDecline": false, "history.falls": false, "history.anticoagulantTherapy": false,
  "symptom.gaitAtaxia": false, "redflag.bowelOrBladderIncontinence": false, "history.cancerWithBrainMetastasisPropensity": false,
};

// Not-funded row fully met, with every timeframe row answered "no".
const ADVANCED_DEMENTIA = {
  ...STEMS_NO, ...SOL_FEATURES_NO, "patient.age": 84, "symptom.cognitiveImpairment": true,
  "history.dementiaEstablishedAdvanced": true, "history.dementiaDurationYears": 3,
  "symptom.dementiaUnexpectedChange": false, "workup.subtypeDiagnosisAltersManagement": false,
};

const R_SEIZURE_RISK = "Seizures with risk factors for intracranial pathology – seek Neurology phone advice";
const R_POORLY_CONTROLLED = "Poorly controlled or recurrent seizures – follow the appropriate pathway: Epilepsy in Adults; Epilepsy in Women; First Seizure in Adults; Seizure in Palliative Care";
const R_PROLACTINOMA = "Suspected Prolactinoma – request non-acute assessment by the appropriate secondary care specialist.";
const ACUTE = { determination: "ACUTE_48H", priorityCode: "A48", missing: [], redirects: [] };
const P2 = { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] };
const P4 = { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] };
const NOT_MET = { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [], unconfirmedExclusions: [] };

export const scenarios = [
  // ---- (a) Results-matrix cases (documents/CRR_Test_Case_Results_Matrix_v2.xlsx) ----
  {
    id: "CTH-RP-000",
    title: "Matrix RP-000: progressive headache, blurred vision, nausea, age 45. Evaluator: proceeds. Literal: insufficient (REVIEW Q11)",
    evaluator: "Proceeds (age 45 is not a barrier: 'especially aged 50+' is a modifier)",
    note: "45 maori woman with 2/12 h/o progressively worsening HA present nocturnally and first thing in the morning with associated blurred vision and nausea",
    answers: {
      "patient.age": d(45, "45"),
      "symptom.headachePatternChangeProgressive": d(true, "progressively worsening HA"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: [...stemsExcept("symptom.headachePatternChangeProgressive"), ...HEADACHE_FEATURES] },
  },
  {
    id: "CTH-RP-000b-age-modifier",
    title: "RP-000 variant: age 45 with a documented qualifying headache feature meets P2 (age modifier not encoded, KI-05)",
    note: "45F. 2/12 progressively worsening headache with persistent nausea and vomiting.",
    answers: {
      "patient.age": d(45, "45F"),
      "symptom.headachePatternChangeProgressive": d(true, "progressively worsening headache"),
      "symptom.headachePersistentNauseaVomiting": d(true, "persistent nausea and vomiting"),
    },
    expect: P2,
  },
  {
    id: "CTH-RP-003",
    title: "Matrix RP-003: '?TIA' with focal signs on examination - focal neurologic signs pathway (Acute); ?TIA does not block it",
    evaluator: "Proceeds (focal neurological signs pathway)",
    note: "64yo f w/ sudden onset R facial numbness + diplopia, lasting 10min. O/E: reduced sensation R face cf L, FROEM without diplopia. Obs OK, pulse regular. ?TIA",
    answers: {
      "patient.age": d(64, "64yo"),
      "symptom.focalNeurologicalSigns": d(true, "O/E: reduced sensation R face cf L"),
      "redflag.suspectedTIA": inf(true, "?TIA"),
    },
    expect: { ...ACUTE, inferredExcluded: ["redflag.suspectedTIA"] },
  },
  {
    id: "CTH-RP-004",
    title: "Matrix RP-004: progressive headache with 'sometimes' nausea - insufficient (no qualifying feature documented)",
    evaluator: "At risk (strict interpretation); PCRL accepts proceeds",
    note: "48yo m w/ 8/52 h/o progressive HA – bilateral – sometimes associated nausea – dizziness and vertigo over this period (normal hearing + vision testing). ?SOL",
    answers: {
      "patient.age": d(48, "48yo"),
      "symptom.headachePatternChangeProgressive": d(true, "progressive HA"),
      "symptom.headachePersistentNauseaVomiting": d(false, "sometimes associated nausea"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: [...stemsExcept("symptom.headachePatternChangeProgressive"), "history.chronicIllnessWithCerebralInvolvement", "symptom.headacheWorseOnCoughSneezeValsalva", "symptom.neuroDeficitSpeechOrWeakness"] },
  },
  {
    id: "CTH-DG-001",
    title: "Matrix DG-001: headache + metastatic melanoma, no change in pattern stated - insufficient; no cognitive-impairment pathway",
    evaluator: "Declined (insufficient information)",
    note: "21y man, headche, known hx of met mel.",
    answers: {
      "patient.age": d(21, "21y"),
      "history.malignancy": d(true, "known hx of met mel"),
      "history.cancerWithBrainMetastasisPropensity": d(true, "known hx of met mel"),
      "history.chronicIllnessWithCerebralInvolvement": d(true, "known hx of met mel"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: STEM_IDS },
  },
  {
    id: "CTH-DG-002",
    title: "Matrix DG-002: 'different to usual' headache - progressive increase not documented; inferred answer excluded under strict",
    evaluator: "At risk / Declined",
    note: "64y girl with 2/12 headche, differentn to usual headache, not responding to meds",
    answers: {
      "patient.age": d(64, "64y"),
      "symptom.headachePatternChangeProgressive": inf(true, "differentn to usual headache"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: STEM_IDS, inferredExcluded: ["symptom.headachePatternChangeProgressive"] },
  },
  {
    id: "CTH-DG-002-inferred",
    title: "DG-002 under documentation standard 'inferred': stem counts, still insufficient - asks for a qualifying feature",
    note: "64y girl with 2/12 headche, differentn to usual headache, not responding to meds",
    answers: {
      "patient.age": d(64, "64y"),
      "symptom.headachePatternChangeProgressive": inf(true, "differentn to usual headache"),
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: [...stemsExcept("symptom.headachePatternChangeProgressive"), ...HEADACHE_FEATURES], inferredExcluded: [] },
  },
  {
    id: "CTH-INT-SAH",
    title: "Matrix INT-SAH (no verbatim note in the matrix): thunderclap headache is not a CT Head criterion - the site emits no ED redirect (vocabulary F-01; national RF-S38)",
    evaluator: "Declined - ED emergency (legacy prompt Step 0)",
    answers: { "patient.age": 50 },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: STEM_IDS },
  },

  // ---- (b) STEP-3 worked example ----
  {
    id: "CTH-W01-focal-vs-tia-gateway",
    title: "Focal neurologic signs met; TIA gateway not met (no specialist recommendation, not community-suitable, rapid access available) - Acute via focal signs",
    answers: {
      ...STEMS_NO, "patient.age": 64, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 2,
      "advice.strokeSpecialistRecommended": false, "workup.suitableForCommunityManagement": false,
      "advice.rapidSpecialistCareAccessible": true, "symptom.focalNeurologicalSigns": true,
    },
    expect: ACUTE,
  },

  // ---- (c) Coverage ----
  { id: "CTH-S01-empty", title: "No answers: insufficient, asks for age and every presentation", answers: {},
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], unconfirmedExclusions: [], missing: ["patient.age", ...STEM_IDS] } },
  { id: "CTH-S02-all-no", title: "Every presentation answered no: criteria not met", answers: { ...STEMS_NO, "patient.age": 50 }, expect: NOT_MET },

  // TIA
  { id: "CTH-S03-tia-specialist", title: "TIA within 7 days, recommended by stroke specialist, adviser named: Acute",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 3, "advice.strokeSpecialistRecommended": true, "advice.adviserNameRole": "Neurologist (name supplied)" },
    expect: ACUTE },
  { id: "CTH-S04-tia-specialist-no-name", title: "TIA route 1 without adviser name/role: Acute, asks for name and role",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 3, "advice.strokeSpecialistRecommended": true },
    expect: { ...ACUTE, missing: ["advice.adviserNameRole"] } },
  { id: "CTH-S05-tia-bpac", title: "TIA route 2: no high-risk features, community-suitable, BPAC tool indicates imaging: Acute",
    answers: { ...TIA_ROUTE2, "patient.age": 70 }, expect: ACUTE },
  { id: "CTH-S06-tia-bpac-af", title: "TIA route 2 closed by atrial fibrillation (*1); rapid access available: criteria not met",
    answers: { ...TIA_ROUTE2, "patient.age": 70, "history.atrialFibrillation": true }, expect: NOT_MET },
  { id: "CTH-S07-tia-no-rapid-access", title: "TIA route 3: unable to access rapid specialist care: Acute",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 5, "advice.strokeSpecialistRecommended": false, "advice.rapidSpecialistCareAccessible": false },
    expect: ACUTE },
  { id: "CTH-S08-tia-day-7", title: "Boundary (REVIEW Q2): TIA 7 days ago is within 7 days",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 7, "advice.rapidSpecialistCareAccessible": false },
    expect: ACUTE },
  { id: "CTH-S09-tia-day-8", title: "Boundary (REVIEW Q2): TIA 8 days ago is outside the window: criteria not met",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 8, "advice.rapidSpecialistCareAccessible": false },
    expect: NOT_MET },
  { id: "CTH-S10-tia-age-58", title: "Boundary (REVIEW Q1): age 58 is a *1 high-risk feature ('Less than 59 years old'), closing route 2",
    answers: { ...TIA_ROUTE2, "patient.age": 58 }, expect: NOT_MET },
  { id: "CTH-S11-tia-age-59", title: "Boundary (REVIEW Q1): age 59 is not a high-risk feature; route 2 open: Acute",
    answers: { ...TIA_ROUTE2, "patient.age": 59 }, expect: ACUTE },
  { id: "CTH-S12-abcd2-4", title: "Boundary: ABCD2 4 is not 'greater than 4'; route 2 open: Acute",
    answers: { ...TIA_ROUTE2, "patient.age": 70, "workup.abcd2Score": 4 }, expect: ACUTE },
  { id: "CTH-S13-abcd2-5", title: "Boundary: ABCD2 5 is a high-risk feature; route 2 closed: criteria not met",
    answers: { ...TIA_ROUTE2, "patient.age": 70, "workup.abcd2Score": 5 }, expect: NOT_MET },
  { id: "CTH-S14-tia-insufficient", title: "TIA within 7 days, nothing about routes: insufficient, asks for the three routes' indicators",
    answers: { ...STEMS_NO, "patient.age": 70, "redflag.suspectedTIA": true, "symptom.tiaDaysSinceEpisode": 3 },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: [
      "advice.strokeSpecialistRecommended", "workup.abcd2Score", "symptom.crescendoTIA", "history.atrialFibrillation", "history.anticoagulantTherapy",
      "symptom.tiaSevereOrProlongedDeficit", "history.carotidStenosis", "workup.suitableForCommunityManagement", "advice.decisionSupportToolCompleted",
      "advice.rapidSpecialistCareAccessible"] } },

  // Other Acute bullets
  { id: "CTH-S15-palliative-seizure-35", title: "Seizure in palliative care, result may change management, age 35, no *4 risk factors: Acute",
    answers: { ...STEMS_NO, ...RISK_FACTORS_NO, "patient.age": 35, "symptom.seizure": true, "history.palliativeCare": true, "workup.resultMayChangeManagement": true, "symptom.seizuresPoorlyControlledOrRecurrent": false },
    expect: { ...ACUTE, unconfirmedExclusions: [] } },
  { id: "CTH-S16-palliative-seizure-70", title: "Same at age 70: 'aged older than 40' is a *4 risk factor, so the seizure redirect wins (REVIEW Q4)",
    answers: { ...STEMS_NO, ...RISK_FACTORS_NO, "patient.age": 70, "symptom.seizure": true, "history.palliativeCare": true, "workup.resultMayChangeManagement": true, "symptom.seizuresPoorlyControlledOrRecurrent": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_SEIZURE_RISK], unconfirmedExclusions: [] } },
  { id: "CTH-S17-acute-advice", title: "PCRL advises same or next day CT, adviser named: Acute",
    answers: { ...STEMS_NO, "patient.age": 50, "advice.acuteImagingRecommended": true, "advice.adviserNameRole": "PCRL (name supplied)" },
    expect: ACUTE },

  // P2 headache
  { id: "CTH-S18-headache-valsalva", title: "Progressive headache change, worse on coughing/Valsalva: P2",
    answers: { ...STEMS_NO, "patient.age": 55, "symptom.headachePatternChangeProgressive": true, "symptom.headacheWorseOnCoughSneezeValsalva": true },
    expect: P2 },
  { id: "CTH-S19-headache-no-feature", title: "Progressive headache change, all four features answered no: criteria not met",
    answers: { ...STEMS_NO, "patient.age": 55, "symptom.headachePatternChangeProgressive": true, "history.chronicIllnessWithCerebralInvolvement": false, "symptom.headacheWorseOnCoughSneezeValsalva": false, "symptom.headachePersistentNauseaVomiting": false, "symptom.neuroDeficitSpeechOrWeakness": false },
    expect: NOT_MET },

  // Cognitive impairment
  { id: "CTH-S20-cognitive-falls", title: "Cognitive impairment with history of falls (*2): P2",
    answers: { ...STEMS_NO, "patient.age": 78, "symptom.cognitiveImpairment": true, "history.falls": true }, expect: P2 },
  { id: "CTH-S21-cognitive-incontinence", title: "Cognitive impairment with incontinence (redflag.bowelOrBladderIncontinence, REVIEW Q9): P2",
    answers: { ...STEMS_NO, "patient.age": 78, "symptom.cognitiveImpairment": true, "redflag.bowelOrBladderIncontinence": true }, expect: P2 },
  { id: "CTH-S22-cognitive-focal-signs", title: "Cognitive impairment with focal neurological signs: the same indicator meets Acute, highest tier wins",
    answers: { ...STEMS_NO, "patient.age": 78, "symptom.cognitiveImpairment": true, "symptom.focalNeurologicalSigns": true }, expect: ACUTE },
  { id: "CTH-S23-cognitive-p4", title: "Cognitive impairment, no *2 features, subtype diagnosis will alter management: P4",
    answers: { ...STEMS_NO, ...SOL_FEATURES_NO, "patient.age": 78, "symptom.cognitiveImpairment": true, "workup.subtypeDiagnosisAltersManagement": true }, expect: P4 },
  { id: "CTH-S24-cognitive-insufficient", title: "Cognitive impairment only: insufficient, asks for the *2 features and the subtype question",
    answers: { ...STEMS_NO, "patient.age": 78, "symptom.cognitiveImpairment": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: [
      "symptom.rapidCognitiveDecline", "history.falls", "history.anticoagulantTherapy", "symptom.gaitAtaxia", "redflag.bowelOrBladderIncontinence",
      "history.cancerWithBrainMetastasisPropensity", "workup.subtypeDiagnosisAltersManagement"] } },
  { id: "CTH-S25-cognitive-subtype-no", title: "Cognitive impairment, no features, subtype will not alter management (dementia details not given): criteria not met",
    answers: { ...STEMS_NO, ...SOL_FEATURES_NO, "patient.age": 78, "symptom.cognitiveImpairment": true, "workup.subtypeDiagnosisAltersManagement": false }, expect: NOT_MET },

  // First seizure
  { id: "CTH-S26-first-seizure-low-risk", title: "First seizure, age 30, clear history, low risk (*3): P2",
    answers: { ...LOW_RISK_FIRST_SEIZURE, "patient.age": 30 }, expect: { ...P2, unconfirmedExclusions: [] } },
  { id: "CTH-S27-first-seizure-age-20", title: "Boundary: first seizure at age 20 (bullet requires 21 or older): criteria not met",
    answers: { ...LOW_RISK_FIRST_SEIZURE, "patient.age": 20 }, expect: NOT_MET },
  { id: "CTH-S28-first-seizure-age-21", title: "Boundary: first seizure at age 21: P2",
    answers: { ...LOW_RISK_FIRST_SEIZURE, "patient.age": 21 }, expect: P2 },
  { id: "CTH-S29-first-seizure-age-40", title: "Boundary: age 40 is not 'older than 40'; still low risk: P2",
    answers: { ...LOW_RISK_FIRST_SEIZURE, "patient.age": 40 }, expect: P2 },
  { id: "CTH-S30-first-seizure-age-41", title: "Boundary: age 41 is a *4 risk factor: seizure redirect (Neurology phone advice)",
    answers: { ...LOW_RISK_FIRST_SEIZURE, "patient.age": 41 },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_SEIZURE_RISK], unconfirmedExclusions: [] } },
  { id: "CTH-S31-first-seizure-mri-unavailable", title: "First seizure, age 30, MRI not available, risk factors unknown: P2 (REVIEW Q3); seizure redirects unconfirmed",
    answers: { ...STEMS_NO, "patient.age": 30, "symptom.firstSeizure": true, "advice.mriAvailable": false },
    expect: { ...P2, unconfirmedExclusions: [...RISK_FACTOR_LINKIDS, "symptom.seizuresPoorlyControlledOrRecurrent"] } },
  { id: "CTH-S32-first-seizure-insufficient", title: "First seizure, age 30, nothing else: insufficient, asks for *3 criteria, risk factors, MRI availability and palliative setting",
    answers: { ...STEMS_NO, "patient.age": 30, "symptom.firstSeizure": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [],
      missing: ["symptom.seizureClearHistory", "symptom.seizureSingle", "symptom.seizureUnprovokedOrSubstanceProvoked", "symptom.returnedToNormalHealth", "advice.mriAvailable", ...RISK_FACTOR_LINKIDS, "history.palliativeCare"],
      unconfirmedExclusions: [...RISK_FACTOR_LINKIDS, "symptom.seizuresPoorlyControlledOrRecurrent"] } },

  // Alternative management
  { id: "CTH-S33-seizure-head-injury", title: "Seizure with head injury (*4 risk factor): redirect - seek Neurology phone advice",
    answers: { ...STEMS_NO, "patient.age": 30, "symptom.seizure": true, "history.headInjury": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_SEIZURE_RISK] } },
  { id: "CTH-S34-poorly-controlled-seizures", title: "Poorly controlled or recurrent seizures: redirect to the seizure HealthPathways",
    answers: { ...STEMS_NO, ...RISK_FACTORS_NO, "patient.age": 30, "symptom.seizure": true, "symptom.seizuresPoorlyControlledOrRecurrent": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_POORLY_CONTROLLED], unconfirmedExclusions: [] } },
  { id: "CTH-S35-prolactinoma", title: "Suspected prolactinoma: redirect to non-acute secondary care assessment",
    answers: { ...STEMS_NO, "patient.age": 30, "symptom.suspectedProlactinoma": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R_PROLACTINOMA] } },

  // Not routinely funded
  { id: "CTH-S36-advanced-dementia", title: "Established advanced dementia, 3 years, no unexpected change, subtype will not alter management, every timeframe row not met: not routinely funded (R1, REVIEW Q20)",
    answers: ADVANCED_DEMENTIA, expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] } },
  { id: "CTH-S37-dementia-2-years", title: "Boundary (REVIEW Q13): 2 years is not 'more than 2 years' - not the not-funded row; no other pathway met",
    answers: { ...STEMS_NO, ...SOL_FEATURES_NO, "patient.age": 84, "symptom.cognitiveImpairment": true, "history.dementiaEstablishedAdvanced": true, "history.dementiaDurationYears": 2, "symptom.dementiaUnexpectedChange": false, "workup.subtypeDiagnosisAltersManagement": false },
    expect: NOT_MET },

  // Advice gateways
  { id: "CTH-S38-urgent-advice", title: "Radiologist advises urgent CT, adviser named: P2",
    answers: { ...STEMS_NO, "patient.age": 50, "advice.urgentImagingRecommended": true, "advice.adviserNameRole": "Radiologist (name supplied)" }, expect: P2 },
  { id: "CTH-S39-non-urgent-advice-no-name", title: "Secondary care clinician advises non-urgent CT, no adviser name: P4, asks for name and role",
    answers: { ...STEMS_NO, "patient.age": 50, "advice.nonUrgentImagingRecommended": true }, expect: { ...P4, missing: ["advice.adviserNameRole"] } },

  // Gates and precedence
  { id: "CTH-S40-paediatric", title: "Age 12: adult criteria do not apply",
    answers: { ...STEMS_NO, "patient.age": 12, "symptom.focalNeurologicalSigns": true },
    expect: { determination: "PAEDIATRIC_CRITERIA_APPLY", priorityCode: null, missing: [], redirects: [] } },
  { id: "CTH-S41-p2-with-acute-unknown", title: "P2 headache met, every Acute presentation unanswered: P2 (highest tier met wins, REVIEW Q5)",
    answers: { "patient.age": 55, "symptom.headachePatternChangeProgressive": true, "symptom.headacheWorseOnCoughSneezeValsalva": true },
    expect: P2 },
  // R1 not-funded precedence (REVIEW Q20)
  { id: "CTH-S43-not-funded-and-row-met", title: "R1: not-funded row met but a timeframe row is also met (urgent CT advised): the met row wins",
    answers: { ...ADVANCED_DEMENTIA, "advice.urgentImagingRecommended": true, "advice.adviserNameRole": "Geriatrician (name supplied)" },
    expect: P2 },
  { id: "CTH-S44-not-funded-and-row-undetermined", title: "R1: not-funded row met but the cognitive-impairment rows are undetermined (*2 features unanswered): insufficient information",
    answers: { ...STEMS_NO, "patient.age": 84, "symptom.cognitiveImpairment": true, "history.dementiaEstablishedAdvanced": true, "history.dementiaDurationYears": 3, "symptom.dementiaUnexpectedChange": false, "workup.subtypeDiagnosisAltersManagement": false },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [], missing: ["symptom.rapidCognitiveDecline", "history.falls", "history.anticoagulantTherapy", "symptom.gaitAtaxia", "redflag.bowelOrBladderIncontinence", "history.cancerWithBrainMetastasisPropensity"] } },
  // (all rows false + not funded: CTH-S36)
  { id: "CTH-S42-age-unknown", title: "Focal signs but age unknown: insufficient, asks only for age",
    answers: { ...STEMS_NO, "symptom.focalNeurologicalSigns": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", redirects: [], missing: ["patient.age"] } },
];

function answerFor(linkId, a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const ans = typeof raw.v === "boolean" ? { valueBoolean: raw.v }
    : typeof raw.v === "number" ? (INTEGER_IDS.has(linkId) ? { valueInteger: raw.v } : { valueDecimal: raw.v })
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
    (groups[linkId.split(".")[0]] ||= []).push({ linkId, answer: [answerFor(linkId, a)] });
  }
  return {
    resourceType: "QuestionnaireResponse",
    id: "qr-" + s.id,
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-CT-Head-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
