// Test scenarios for CRR_USRenal_Adult (US Renal - Adult, National ID 15372 v2.0 pp.52-55).
// NOT CLINICALLY REVIEWED - W1 demo transcription (AD-35).
//
// Order: matrix cases for the site first (documents/CRR_Test_Case_Results_Matrix_v2.xlsx; the
// INT-AKI note is from scripts/reg02-runner.mjs), then one scenario per criterion row, boundary,
// redirect and not-funded row, then precedence and documentation-standard cases.
// Answers are what a correct extraction of the note would produce; notes are synthetic.
// National red flags (RF-03, RF-12) are evaluated by the national bundle, not here.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";
const QUANTITY = new Set(["lab.egfr.value", "lab.egfr.decreaseWithin12m", "lab.acr.value"]);
const INTEGER = new Set(["patient.age", "symptom.utiConfirmedCount", "symptom.utiCount12m", "symptom.utiCount6m"]);
const DECIMAL = new Set(["patient.bmi", "imaging.incidentalSolidLesionDiameterCm"]);
const CODING_SYSTEM = {
  "patient.sex": "http://hl7.org/fhir/administrative-gender",
  "patient.smokingStatus": "http://crr.health.nz/fhir/CodeSystem/smoking-status",
};

// Active-redirect strings, verbatim from the CQL (published wording, p54).
const R = {
  aml: "Incidental finding on ultrasound of a solid lesion more than 1 cm diameter with typical ultrasound appearances of an angiomyolipoma – see local CT IVU HealthPathway",
  macro: "Macroscopic haematuria in patients who do not have a UTI, if aged 40 to 85 years. Refer for CT IVU (Intravenous Urogram).",
  diabetic: "Repeat renal ultrasound for diabetic patients with known diabetic renal complications is not indicated - See local Kidney Disease in Diabetes HealthPathway",
  colic: "Suspected renal colic in a non-pregnant person – See local Renal Colic and Urinary Tract Stones HealthPathway.",
  aki: "Acute kidney injury – manage according to Acute Kidney Injury pathway, or seek advice from the relevant secondary care specialist as to whether a renal ultrasound is indicated",
  prostate: "Enlarged prostate or elevated PSA – See local Prostate Cancer Diagnosis HealthPathway.",
  proteinuria: "Isolated proteinuria – seek nephrology advice.",
  luts: "Lower urinary tract symptoms - See local Lower Urinary Tract Symptoms (LUTS) or Benign Prostatic Hypertrophy HealthPathway, or other relevant HealthPathway.",
  mass: "Abdominal mass - Discuss with secondary care specialist as FSA, CT scan or other investigations may be more appropriate",
};

// Every criterion row answered "not met" for an adult woman: the base for boundary cases that
// must land on CRITERIA_NOT_MET rather than INSUFFICIENT_INFORMATION.
const ALL_ROWS_NOT_MET = {
  "patient.age": 45, "patient.sex": "female", "patient.pregnant": false,
  "redflag.renalColicAcuteEpisode": false, "symptom.renalColicFirstPresentation": false,
  "symptom.chronicUrinaryRetentionSuspected": false, "advice.acuteImagingRecommended": false,
  "symptom.haematuriaMacroscopic": false, "advice.urgentImagingRecommended": false,
  "symptom.haematuriaMicroscopic": false, "patient.ckdNewDiagnosis": false,
  "symptom.varicoceleNewRightOrBilateral": false, "symptom.utiConfirmedCount": 0, "symptom.utiCount12m": 0, "symptom.utiCount6m": 0,
  "patient.onUtiProphylacticAntibiotics": false, "lab.persistentBacteriuriaSameOrganism": false,
  "symptom.urinaryIncontinence": false, "symptom.recurrentLoinPainSuggestingObstruction": false,
  "advice.nonUrgentImagingRecommended": false, "workup.renalStoneFollowUpPerHealthPathway": false,
};

const NOT_MET = { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [] };

export const scenarios = [
  // ---- Matrix cases --------------------------------------------------------------------------
  {
    id: "USR-M01-RP-006",
    title: "Matrix RP-006: new AKI, eGFR 3 - alternative management (AKI row). Matrix expected 'proceeds' under a superseded 'acute renal function deterioration' row that v2.0 does not print",
    note: "75yo m w/ new AKI, eGFR 3 (normally 55). No clear cause.",
    answers: {
      "patient.age": { v: 75, status: "documented", quote: "75yo" },
      "patient.sex": { v: "male", status: "documented", quote: "m" },
      "lab.acuteKidneyInjury": { v: true, status: "documented", quote: "new AKI" },
      "lab.egfr.value": { v: 3, status: "documented", quote: "eGFR 3" },
    },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.aki] },
  },
  {
    id: "USR-M02-INT-AKI",
    title: "Matrix INT-AKI (Structured Re-Eval): new AKI, eGFR 8 - alternative management (AKI row)",
    note: "72yo man, 1/52 malaise and reduced urine output. New AKI — eGFR 8, baseline 62 three months ago. No catheter, no obvious precipitant, not on nephrotoxics. BP 158/94, otherwise obs stable.",
    answers: {
      "patient.age": { v: 72, status: "documented", quote: "72yo" },
      "patient.sex": { v: "male", status: "documented", quote: "man" },
      "lab.acuteKidneyInjury": { v: true, status: "documented", quote: "New AKI" },
      "lab.egfr.value": { v: 8, status: "documented", quote: "eGFR 8" },
      "patient.indwellingCatheter": { v: false, status: "documented", quote: "No catheter" },
    },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.aki] },
  },
  {
    id: "USR-M03-CR-003",
    title: "Matrix CR-003: microscopic haematuria, female 64, non-smoker - P4 (matrix: proceeds P4)",
    note: "Persisting microscopic heamaturia in usually well and active 64 year old lady works as a hairdresser all her life , non smoker , No infection on microscopy , no wt loss or other symptoms",
    answers: {
      "patient.age": { v: 64, status: "documented", quote: "64 year old" },
      "patient.sex": { v: "female", status: "documented", quote: "lady" },
      "symptom.haematuriaMicroscopic": { v: true, status: "documented", quote: "Persisting microscopic heamaturia" },
      "patient.smokingStatus": { v: "non", status: "documented", quote: "non smoker" },
      "symptom.utiCurrent": { v: false, status: "documented", quote: "No infection on microscopy" },
    },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] },
  },
  {
    id: "USR-M04-MW-010",
    title: "Matrix MW-010: LUQ ache near a lipoma, no renal indication stated - insufficient information (matrix expected 'declined'; the engine never reads silence as 'not met')",
    note: "82 year old woman, ongoing LUQ ache in her back radiating to L side, bloating, belching, H pylori negative, pain just above the L lipoma. Requesting renal ultrasound and soft tissue ultrasound.",
    answers: {
      "patient.age": { v: 82, status: "documented", quote: "82 year old" },
      "patient.sex": { v: "female", status: "documented", quote: "woman" },
    },
    expect: {
      determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [],
      missing: [
        "redflag.renalColicAcuteEpisode", "symptom.renalColicFirstPresentation", "patient.pregnant",
        "symptom.chronicUrinaryRetentionSuspected", "advice.acuteImagingRecommended",
        "symptom.haematuriaMacroscopic", "patient.ivContrastAllergy", "lab.egfr.value", "patient.takingMetformin", "patient.hyperthyroidism",
        "advice.urgentImagingRecommended",
        "patient.ckdNewDiagnosis", "patient.diabetes", "lab.egfr.decreaseWithin12m", "lab.acr.value",
        "symptom.varicoceleNewRightOrBilateral",
        "symptom.utiCount12m", "symptom.utiCount6m", "patient.onUtiProphylacticAntibiotics", "lab.persistentBacteriuriaSameOrganism",
        "symptom.recurrentLoinPainSuggestingObstruction", "advice.nonUrgentImagingRecommended",
        "symptom.haematuriaMicroscopic",
        "workup.renalStoneFollowUpPerHealthPathway", "workup.kubXrayCalculusVisible", "patient.bmi",
      ],
    },
  },
  {
    id: "USR-M05-INT-001-strict",
    title: "Matrix INT-001 (a CT KUB case whose expected outcome is 'request renal US instead'): 30F first presentation loin-to-groin pain; renal colic only inferred - strict: insufficient",
    note: "30-year-old female, first presentation severe right loin to groin pain. No fever, temp 36.8. eGFR 78. No history of renal stones. No solitary kidney.",
    answers: {
      "patient.age": { v: 30, status: "documented", quote: "30-year-old" },
      "patient.sex": { v: "female", status: "documented", quote: "female" },
      "redflag.renalColicAcuteEpisode": { v: true, status: "inferred", quote: "severe right loin to groin pain" },
      "symptom.renalColicFirstPresentation": { v: true, status: "documented", quote: "first presentation" },
      "lab.egfr.value": { v: 78, status: "documented", quote: "eGFR 78" },
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [], inferredExcluded: ["redflag.renalColicAcuteEpisode"] },
  },
  {
    id: "USR-M06-INT-001-inferred",
    title: "Matrix INT-001 under documentation standard 'inferred': Acute within 48 hours (female younger than 35); the renal colic redirect does not apply (REVIEW Q4)",
    note: "30-year-old female, first presentation severe right loin to groin pain. No fever, temp 36.8. eGFR 78. No history of renal stones. No solitary kidney.",
    answers: {
      "patient.age": { v: 30, status: "documented", quote: "30-year-old" },
      "patient.sex": { v: "female", status: "documented", quote: "female" },
      "redflag.renalColicAcuteEpisode": { v: true, status: "inferred", quote: "severe right loin to groin pain" },
      "symptom.renalColicFirstPresentation": { v: true, status: "documented", quote: "first presentation" },
      "lab.egfr.value": { v: 78, status: "documented", quote: "eGFR 78" },
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: { determination: "ACUTE_48H", priorityCode: "A48", missing: [], redirects: [], inferredExcluded: [] },
  },

  // ---- Acute: Within 48 hours (p52) ----------------------------------------------------------
  {
    id: "USR-S01-acute-colic-female-under-35",
    title: "Acute row 1: first presentation renal colic, female 28, not pregnant",
    answers: { "patient.age": 28, "patient.sex": "female", "patient.pregnant": false, "redflag.renalColicAcuteEpisode": true, "symptom.renalColicFirstPresentation": true },
    expect: { determination: "ACUTE_48H", priorityCode: "A48", missing: [], redirects: [] },
  },
  {
    id: "USR-S02-acute-colic-pregnant-38",
    title: "Acute row 1: first presentation renal colic, pregnant, 38 (pregnant limb has no age limit - REVIEW Q1)",
    answers: { "patient.age": 38, "patient.sex": "female", "patient.pregnant": true, "redflag.renalColicAcuteEpisode": true, "symptom.renalColicFirstPresentation": true },
    expect: { determination: "ACUTE_48H", priorityCode: "A48", missing: [], redirects: [] },
  },
  {
    id: "USR-S03-colic-male-redirect",
    title: "Renal colic, male 40: alternative management (non-pregnant person; male treated as not pregnant - REVIEW Q3)",
    answers: { "patient.age": 40, "patient.sex": "male", "redflag.renalColicAcuteEpisode": true, "symptom.renalColicFirstPresentation": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.colic] },
  },
  {
    id: "USR-S04-colic-female-35-boundary",
    title: "Boundary: female aged exactly 35, not pregnant - not 'younger than 35', so the renal colic redirect applies",
    answers: { "patient.age": 35, "patient.sex": "female", "patient.pregnant": false, "redflag.renalColicAcuteEpisode": true, "symptom.renalColicFirstPresentation": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.colic] },
  },
  {
    id: "USR-S05-colic-recurrent-female-under-35",
    title: "Renal colic, female 25, not the first presentation: alternative management",
    answers: { "patient.age": 25, "patient.sex": "female", "patient.pregnant": false, "redflag.renalColicAcuteEpisode": true, "symptom.renalColicFirstPresentation": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.colic] },
  },
  {
    id: "USR-S06-acute-chronic-retention",
    title: "Acute row 2: suspected chronic urinary retention",
    answers: { "patient.age": 70, "patient.sex": "male", "symptom.chronicUrinaryRetentionSuspected": true },
    expect: { determination: "ACUTE_48H", priorityCode: "A48", missing: [], redirects: [] },
  },
  {
    id: "USR-S07-acute-advice-no-name",
    title: "Acute row 3: specialist advises acute US renal; adviser name and role missing (Overview p5)",
    answers: { "patient.age": 55, "patient.sex": "male", "advice.acuteImagingRecommended": true },
    expect: { determination: "ACUTE_48H", priorityCode: "A48", missing: ["advice.adviserNameRole"], redirects: [] },
  },

  // ---- P2 Urgent (p52) -----------------------------------------------------------------------
  {
    id: "USR-S08-p2-macro-39",
    title: "P2 limb 1: macroscopic haematuria, age 39 (younger than 40)",
    answers: { "patient.age": 39, "patient.sex": "male", "symptom.haematuriaMacroscopic": true },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "USR-S09-p2-macro-86",
    title: "P2 limb 1: macroscopic haematuria, age 86 (86 and older)",
    answers: { "patient.age": 86, "patient.sex": "female", "symptom.haematuriaMacroscopic": true },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "USR-S10-macro-85-no-uti-ct-ivu",
    title: "Macroscopic haematuria, 85, no UTI, able to have contrast: alternative management (refer for CT IVU)",
    answers: {
      "patient.age": 85, "patient.sex": "male", "symptom.haematuriaMacroscopic": true, "symptom.utiCurrent": false,
      "patient.ivContrastAllergy": false, "lab.egfr.value": 70, "patient.takingMetformin": false, "patient.hyperthyroidism": false,
    },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.macro] },
  },
  {
    id: "USR-S11-p2-macro-60-metformin",
    title: "P2 limb 2: macroscopic haematuria, 60, no UTI, taking metformin - P2; the CT IVU redirect does not apply (REVIEW Q5)",
    answers: { "patient.age": 60, "patient.sex": "male", "symptom.haematuriaMacroscopic": true, "symptom.utiCurrent": false, "patient.takingMetformin": true },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "USR-S12-p2-macro-40-egfr-29",
    title: "P2 limb 2: macroscopic haematuria, age 40 (lower bound), eGFR 29 (less than 30mL/min)",
    answers: { "patient.age": 40, "patient.sex": "female", "symptom.haematuriaMacroscopic": true, "lab.egfr.value": 29 },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "USR-S13-macro-60-contrast-unknown",
    title: "Macroscopic haematuria, 60, no UTI, nothing about contrast: insufficient - neither P2 limb 2 nor the CT IVU redirect can be decided",
    answers: { ...ALL_ROWS_NOT_MET, "patient.age": 60, "symptom.haematuriaMacroscopic": true, "symptom.utiCurrent": false },
    expect: {
      determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [],
      missing: ["patient.ivContrastAllergy", "lab.egfr.value", "patient.takingMetformin", "patient.hyperthyroidism"],
    },
  },
  {
    id: "USR-S14-p2-advice",
    title: "P2 row 2: specialist advises urgent US renal, name and role given",
    answers: { "patient.age": 50, "patient.sex": "female", "advice.urgentImagingRecommended": true, "advice.adviserNameRole": "Dr A Example, urologist" },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },

  // ---- P3 (p52-p53) --------------------------------------------------------------------------
  {
    id: "USR-S15-p3-micro-male-51-ex-smoker",
    title: "P3 row 1: microscopic haematuria, male 51, ex-smoker",
    answers: { "patient.age": 51, "patient.sex": "male", "symptom.haematuriaMicroscopic": true, "patient.smokingStatus": "ex" },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S16-micro-male-50-current-smoker",
    title: "Boundary: microscopic haematuria, male aged exactly 50, current smoker - not 'older than 50', so P4 (50 and younger, any smoking status)",
    answers: { "patient.age": 50, "patient.sex": "male", "symptom.haematuriaMicroscopic": true, "patient.smokingStatus": "current" },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] },
  },
  {
    id: "USR-S17-micro-male-60-smoking-unknown",
    title: "Microscopic haematuria, male 60, smoking status not stated: insufficient, asks for smoking status",
    answers: { ...ALL_ROWS_NOT_MET, "patient.age": 60, "patient.sex": "male", "symptom.haematuriaMicroscopic": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["patient.smokingStatus"], redirects: [] },
  },
  {
    id: "USR-S18-p3-ckd-egfr-28",
    title: "P3 row 2: new CKD diagnosis, eGFR 28",
    answers: { "patient.age": 66, "patient.sex": "female", "patient.ckdNewDiagnosis": true, "lab.egfr.value": 28 },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S19-p3-ckd-egfr-40-diabetes",
    title: "P3 row 2: new CKD diagnosis, eGFR 40 with diabetes",
    answers: { "patient.age": 66, "patient.sex": "male", "patient.ckdNewDiagnosis": true, "lab.egfr.value": 40, "patient.diabetes": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S20-p3-ckd-egfr-55-decrease-15",
    title: "P3 row 2: new CKD diagnosis, eGFR 55, decreased by exactly 15 within 12 months (15 or more)",
    answers: { "patient.age": 66, "patient.sex": "male", "patient.ckdNewDiagnosis": true, "lab.egfr.value": 55, "lab.egfr.decreaseWithin12m": 15 },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S21-p3-ckd-acr-251",
    title: "P3 row 2: new CKD diagnosis, ACR 251 (more than 250; unit not asserted - REVIEW Q8)",
    answers: { "patient.age": 66, "patient.sex": "female", "patient.ckdNewDiagnosis": true, "lab.acr.value": 251 },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S22-ckd-boundaries-not-met",
    title: "Boundaries: new CKD, eGFR 60, decrease 14, no diabetes, ACR 250 - every sub-bullet false; all other rows not met",
    answers: { ...ALL_ROWS_NOT_MET, "patient.ckdNewDiagnosis": true, "lab.egfr.value": 60, "lab.egfr.decreaseWithin12m": 14, "patient.diabetes": false, "lab.acr.value": 250 },
    expect: NOT_MET,
  },
  {
    id: "USR-S23-p3-varicocele",
    title: "P3 row 3: new right-sided or bilateral varicocele",
    answers: { "patient.age": 34, "patient.sex": "male", "symptom.varicoceleNewRightOrBilateral": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S24-p3-uti-men-recurrent",
    title: "P3 row 4: UTI in men, 2 confirmed UTIs",
    answers: { "patient.age": 45, "patient.sex": "male", "symptom.utiConfirmedCount": 2 },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S25-p3-uti-women-4-in-year",
    title: "P3 row 5: UTI in women, 4 UTIs in a year (more than 3)",
    answers: { "patient.age": 45, "patient.sex": "female", "symptom.utiCount12m": 4 },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S26-p3-uti-women-6m-prophylaxis",
    title: "P3 row 5: UTI in women, 3 in six months despite prophylactic antibiotics",
    answers: { "patient.age": 45, "patient.sex": "female", "symptom.utiCount6m": 3, "patient.onUtiProphylacticAntibiotics": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S27-nf-recurrent-uti-women",
    title: "Not funded: recurrent UTIs in a woman not meeting the P3 row (3 in a year, 2 in six months, no prophylaxis, not persistent)",
    answers: {
      "patient.age": 45, "patient.sex": "female", "symptom.utiRecurrent": true, "symptom.utiCount12m": 3, "symptom.utiCount6m": 2,
      "patient.onUtiProphylacticAntibiotics": false, "lab.persistentBacteriuriaSameOrganism": false,
    },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S28-p3-uti-women-persistent",
    title: "P3 row 5: persistent UTI in a woman (same organism after appropriate antibiotic)",
    answers: { "patient.age": 30, "patient.sex": "female", "symptom.utiRecurrent": true, "lab.persistentBacteriuriaSameOrganism": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S29-p3-incontinence-men-palpable",
    title: "P3 row 6: urinary incontinence in a man with palpable bladder",
    answers: { "patient.age": 78, "patient.sex": "male", "symptom.urinaryIncontinence": true, "symptom.palpableBladder": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S30-incontinence-men-aki-redirect",
    title: "Precedence (REVIEW Q15): incontinence in a man with deteriorating renal impairment, but AKI stated - the AKI redirect wins",
    answers: { "patient.age": 78, "patient.sex": "male", "symptom.urinaryIncontinence": true, "lab.renalImpairmentNewOrDeteriorating": true, "lab.acuteKidneyInjury": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.aki] },
  },
  {
    id: "USR-S31-p3-incontinence-renal-impairment",
    title: "P3 row 6 ('renal deterioration' worked example under v2.0): incontinence in a man with new renal impairment, AKI documented absent",
    answers: { "patient.age": 78, "patient.sex": "male", "symptom.urinaryIncontinence": true, "lab.renalImpairmentNewOrDeteriorating": true, "lab.acuteKidneyInjury": false },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S32-p3-recurrent-loin-pain",
    title: "P3 row 7: recurrent loin pain suggesting non-stone renal tract obstruction",
    answers: { "patient.age": 52, "patient.sex": "female", "symptom.recurrentLoinPainSuggestingObstruction": true },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },
  {
    id: "USR-S33-p3-advice",
    title: "P3 row 8: specialist advises non-urgent US renal, name and role given",
    answers: { "patient.age": 52, "patient.sex": "male", "advice.nonUrgentImagingRecommended": true, "advice.adviserNameRole": "Dr B Example, nephrologist" },
    expect: { determination: "P3_NON_DEFERRABLE", priorityCode: "P3", missing: [], redirects: [] },
  },

  // ---- P4 (p53) and S2 (p54) -----------------------------------------------------------------
  {
    id: "USR-S34-p4-micro-male-70-non-smoker",
    title: "P4 row 1: microscopic haematuria, male 70, non-smoker",
    answers: { "patient.age": 70, "patient.sex": "male", "symptom.haematuriaMicroscopic": true, "patient.smokingStatus": "non" },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] },
  },
  {
    id: "USR-S35-p4-micro-male-30-no-smoking",
    title: "P4 row 2: microscopic haematuria, male 30, smoking status not needed",
    answers: { "patient.age": 30, "patient.sex": "male", "symptom.haematuriaMicroscopic": true },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] },
  },
  {
    id: "USR-S36-s2-stone-follow-up",
    title: "S2: renal stone follow up per HealthPathway, calculus not visible on KUB X-ray, BMI 29.9",
    answers: { "patient.age": 44, "patient.sex": "male", "workup.renalStoneFollowUpPerHealthPathway": true, "workup.kubXrayCalculusVisible": false, "patient.bmi": 29.9 },
    expect: { determination: "S2_TIME_SENSITIVE", priorityCode: "S2", missing: [], redirects: [] },
  },
  {
    id: "USR-S37-s2-bmi-30-boundary",
    title: "Boundary: S2 with BMI exactly 30 - not 'less than 30'; all other rows not met",
    answers: { ...ALL_ROWS_NOT_MET, "workup.renalStoneFollowUpPerHealthPathway": true, "workup.kubXrayCalculusVisible": false, "patient.bmi": 30 },
    expect: NOT_MET,
  },

  // ---- Alternative management (p54) ----------------------------------------------------------
  {
    id: "USR-S38-am-angiomyolipoma-1-5cm",
    title: "Redirect 1: incidental angiomyolipoma 1.5 cm",
    answers: { "patient.age": 58, "patient.sex": "female", "imaging.incidentalAngiomyolipomaOnUs": true, "imaging.incidentalSolidLesionDiameterCm": 1.5 },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.aml] },
  },
  {
    id: "USR-S39-angiomyolipoma-1cm-gap",
    title: "Boundary (REVIEW Q13): angiomyolipoma of exactly 1 cm meets neither the redirect (more than 1 cm) nor the not-funded row (less 1 cm)",
    answers: { ...ALL_ROWS_NOT_MET, "imaging.incidentalAngiomyolipomaOnUs": true, "imaging.incidentalSolidLesionDiameterCm": 1.0 },
    expect: NOT_MET,
  },
  {
    id: "USR-S40-am-diabetic-repeat",
    title: "Redirect 3: repeat renal US, diabetic with known diabetic renal complications",
    answers: { "patient.age": 63, "patient.sex": "male", "patient.diabeticRenalComplications": true, "imaging.usrenal.ever": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.diabetic] },
  },
  {
    id: "USR-S41-am-prostate-psa",
    title: "Redirect 6: elevated PSA",
    answers: { "patient.age": 67, "patient.sex": "male", "lab.psa.raised": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.prostate] },
  },
  {
    id: "USR-S42-am-isolated-proteinuria",
    title: "Redirect 7: isolated proteinuria",
    answers: { "patient.age": 47, "patient.sex": "female", "lab.proteinuriaIsolated": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.proteinuria] },
  },
  {
    id: "USR-S43-luts-with-retention",
    title: "Precedence (REVIEW Q15): lower urinary tract symptoms alongside suspected chronic urinary retention - the LUTS redirect wins over the Acute row",
    answers: { "patient.age": 74, "patient.sex": "male", "symptom.lowerUrinaryTractSymptoms": true, "symptom.chronicUrinaryRetentionSuspected": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.luts] },
  },
  {
    id: "USR-S44-am-abdominal-mass",
    title: "Redirect 9: abdominal mass",
    answers: { "patient.age": 61, "patient.sex": "female", "symptom.abdominalMass": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.mass] },
  },

  // ---- Not routinely funded (p54-p55) --------------------------------------------------------
  {
    id: "USR-S45-nf-hypertension",
    title: "Not funded: investigation of uncomplicated hypertension",
    answers: { "patient.age": 49, "patient.sex": "male", "funding.investigationUncomplicatedHypertension": true },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S46-nf-catheter-bacteriuria",
    title: "Not funded: bacteriuria with in-dwelling catheter, not systemically unwell",
    answers: { "patient.age": 81, "patient.sex": "male", "lab.bacteriuria": true, "patient.indwellingCatheter": true, "symptom.systemicallyUnwell": false },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S47-catheter-bacteriuria-unwell-unknown",
    title: "Catheter bacteriuria with systemic state not stated: the not-funded row does not fire on silence; all rows not met",
    answers: { ...ALL_ROWS_NOT_MET, "lab.bacteriuria": true, "patient.indwellingCatheter": true },
    expect: NOT_MET,
  },
  {
    id: "USR-S48-nf-simple-cyst",
    title: "Not funded: follow-up imaging of simple renal cysts (Bosniak I and II)",
    answers: { "patient.age": 59, "patient.sex": "female", "funding.simpleRenalCystFollowUp": true },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S49-nf-angiomyolipoma-0-8cm",
    title: "Not funded: follow up of incidental angiomyolipoma 0.8 cm (less 1 cm)",
    answers: { "patient.age": 58, "patient.sex": "female", "imaging.incidentalAngiomyolipomaOnUs": true, "imaging.incidentalSolidLesionDiameterCm": 0.8 },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S50-nf-adpkd-screening",
    title: "Not funded: screening scan for ADPKD",
    answers: { "patient.age": 24, "patient.sex": "male", "funding.adpkdScreening": true },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S51-nf-pkd-serial",
    title: "Not funded: serial US of known polycystic kidneys, not indicated by the report, no other criterion met",
    answers: { ...ALL_ROWS_NOT_MET, "funding.polycysticKidneySerialUs": true, "imaging.furtherImagingRecommendedByReport": false },
    expect: { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S52-pkd-serial-report-indicates",
    title: "Serial PKD US indicated by the radiology report: not the not-funded row; all rows not met",
    answers: { ...ALL_ROWS_NOT_MET, "funding.polycysticKidneySerialUs": true, "imaging.furtherImagingRecommendedByReport": true },
    expect: NOT_MET,
  },
  {
    id: "USR-S53-pkd-serial-new-symptom-meets-p4",
    title: "Serial PKD US but new microscopic haematuria meets P4 (REVIEW Q18): P4, not not-funded",
    answers: { ...ALL_ROWS_NOT_MET, "funding.polycysticKidneySerialUs": true, "imaging.furtherImagingRecommendedByReport": false, "symptom.haematuriaMicroscopic": true },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [] },
  },

  // ---- Precedence, age band, documentation standard, empty -----------------------------------
  {
    id: "USR-S54-highest-priority-wins",
    title: "Precedence (REVIEW Q14): macroscopic haematuria at 30 (P2) and a new varicocele (P3) - P2",
    answers: { "patient.age": 30, "patient.sex": "male", "symptom.haematuriaMacroscopic": true, "symptom.varicoceleNewRightOrBilateral": true },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [], redirects: [] },
  },
  {
    id: "USR-S55-paediatric",
    title: "Age 15: paediatric criteria apply (Overview p4)",
    answers: { "patient.age": 15, "patient.sex": "female", "symptom.haematuriaMicroscopic": true },
    expect: { determination: "PAEDIATRIC_CRITERIA_APPLY", priorityCode: null, missing: [], redirects: [] },
  },
  {
    id: "USR-S56-all-rows-not-met",
    title: "Every criterion row answered not met: criteria not met, nothing missing",
    answers: { ...ALL_ROWS_NOT_MET },
    expect: NOT_MET,
  },
  {
    id: "USR-S57-strict-inferred-micro",
    title: "Strict standard: microscopic haematuria only inferred - treated as unanswered, so insufficient (asks for it) and surfaced as inferred-excluded",
    answers: { ...ALL_ROWS_NOT_MET, "symptom.haematuriaMicroscopic": { v: true, status: "inferred", quote: "blood on dipstick" } },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["symptom.haematuriaMicroscopic"], redirects: [], inferredExcluded: ["symptom.haematuriaMicroscopic"] },
  },
  {
    id: "USR-S58-inferred-standard-micro",
    title: "Documentation standard 'inferred': the same inferred microscopic haematuria counts - P4",
    answers: { ...ALL_ROWS_NOT_MET, "symptom.haematuriaMicroscopic": { v: true, status: "inferred", quote: "blood on dipstick" } },
    runWith: { "Documentation Standard": "inferred" },
    expect: { determination: "P4_DEFERRABLE", priorityCode: "P4", missing: [], redirects: [], inferredExcluded: [] },
  },
  {
    id: "USR-S59-empty",
    title: "No answers at all: insufficient information",
    answers: {},
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [] },
  },
];

function answerFor(linkId, a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const v = raw.v;
  let ans;
  if (CODING_SYSTEM[linkId]) ans = { valueCoding: { system: CODING_SYSTEM[linkId], code: v } };
  else if (typeof v === "boolean") ans = { valueBoolean: v };
  else if (QUANTITY.has(linkId)) ans = { valueQuantity: { value: v } };
  else if (INTEGER.has(linkId)) ans = { valueInteger: v };
  else if (DECIMAL.has(linkId)) ans = { valueDecimal: v };
  else if (typeof v === "string") ans = { valueString: v };
  else throw new Error("unsupported answer for " + linkId);
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
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-US-Renal-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
