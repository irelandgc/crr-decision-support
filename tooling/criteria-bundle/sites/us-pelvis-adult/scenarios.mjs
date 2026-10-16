// Test scenarios for CRR_USPelvis_Adult (US Pelvis - Adult, National ID 15372 v2.0, pp.44-51).
// NOT CLINICALLY REVIEWED. Expected results are what the literal transcription returns; where a
// matrix evaluator expected something else, `matrix.divergence` says why (transcription-notes.md §5).
//
// Order: (1) every matrix case for the site (documents/CRR_Test_Case_Results_Matrix_v2.xlsx and
// the synthetic EQ-002 note in scripts/ta-src-01-baseline-runner.mjs), then the STEP-3 worked example; (2) one scenario per row
// met, per redirect, per not-funded item, per boundary, and insufficient cases showing the
// missing-information list; (3) strict-vs-inferred.
//
// An answer with no status is directly asserted (structured form) and counts as documented.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";
const doc = (v, quote) => ({ v, status: "documented", quote });
const inf = (v, quote) => ({ v, status: "inferred", quote });

// Footnote *5 risk factors, all answered "no" (BMI below 30).
const NO_RF = {
  "patient.maoriOrPacificEthnicity": false, "patient.bmi": 25.0, "patient.pcosDiagnosed": false,
  "patient.chronicAnovulation": false, "patient.nulliparous": false, "patient.earlyMenarcheOrLateMenopause": false,
  "patient.estrogenSecretingTumour": false, "patient.unopposedEstrogenMhtLongStanding": false,
  "patient.tamoxifenTherapy": false, "patient.diabetes": false, "lab.ironDeficiencyAnaemia": false,
  "patient.familyHistoryEndometrialOvarianBreastBowelCancer": false,
};
const RF_IDS = Object.keys(NO_RF);

const R = {
  rpoc: "Suspected retained products of conception (RPOC) with persistent or heavy bleeding after abortion or miscarriage - See local Abortion HealthPathway or Miscarriage HealthPathway.",
  endo: "Suspected endometriosis in the absence of a clinically palpable mass - See local Endometriosis HealthPathway.",
  dysm: "Primary dysmenorrhoea in the absence of a clinically palpable mass - See local Dysmenorrhoea HealthPathway.",
  pid: "Pelvic inflammatory disease (PID) in the absence of a clinically palpable mass - See local PID HealthPathway.",
  polyp: "Cervical polyps - referral to secondary care rather than ultrasound is recommended for women with polyps which prove difficult to remove. Ultrasound is not able to identify the rare occurrence of malignant polyps - See local Endometrial Polyps HealthPathway.",
  amen: "Secondary amenorrhoea. Pelvic USS is not normally helpful in diagnosing secondary amenorrhoea unless a pelvis mass is present, or the patient has significantly raised androgens which would raise concern regarding an ovarian tumour.",
};

const A24 = { determination: "ACUTE_24H", priorityCode: "A24" };
const A48 = { determination: "ACUTE_48H", priorityCode: "A48" };
const P2 = { determination: "P2_URGENT", priorityCode: "P2" };
const P3 = { determination: "P3_NON_DEFERRABLE", priorityCode: "P3" };
const P4 = { determination: "P4_DEFERRABLE", priorityCode: "P4" };
const S2 = { determination: "S2_TIME_SENSITIVE", priorityCode: "S2" };
const S3 = { determination: "S3_TIME_SENSITIVE", priorityCode: "S3" };
const INSUF = { determination: "INSUFFICIENT_INFORMATION", priorityCode: null };
const AM = { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [] };
const NF = { determination: "NOT_ROUTINELY_FUNDED", priorityCode: null, missing: [], redirects: [] };

export const scenarios = [
  // -------------------------------------------------------------------------
  // (1) Matrix cases
  // -------------------------------------------------------------------------
  {
    id: "USP-M-LP-003-strict",
    title: "LP-003: 56yo post-menopausal on HRT, 2 days PV bleeding - PMB only inferred: insufficient, asks for it",
    note: "56 yo post menopausal woman on hormone replacement therapy with 2 days of PV bleeding",
    matrix: { caseId: "LP-003", expected: "at_risk (Structured Re-Eval)", divergence: "none - insufficient is the at_risk analogue" },
    answers: {
      "patient.age": doc(56, "56 yo"),
      "patient.postmenopausal": doc(true, "post menopausal"),
      "symptom.postmenopausalBleeding": inf(true, "56 yo post menopausal woman on hormone replacement therapy with 2 days of PV bleeding"),
    },
    expect: { ...INSUF, missing: ["symptom.postmenopausalBleeding"], redirects: [], unconfirmedExclusions: [], inferredExcluded: ["symptom.postmenopausalBleeding"] },
  },
  {
    id: "USP-M-LP-003-inferred",
    title: "LP-003 under the 'inferred' standard: P2 (REVIEW Q7 - P2 row 2 does not exclude bleeding on MHT)",
    note: "56 yo post menopausal woman on hormone replacement therapy with 2 days of PV bleeding",
    matrix: { caseId: "LP-003", expected: "at_risk", divergence: "inferred standard accepts the PMB inference; REVIEW Q7" },
    answers: {
      "patient.age": doc(56, "56 yo"),
      "patient.postmenopausal": doc(true, "post menopausal"),
      "symptom.postmenopausalBleeding": inf(true, "56 yo post menopausal woman on hormone replacement therapy with 2 days of PV bleeding"),
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...P2, missing: [], redirects: [], inferredExcluded: [] },
  },
  {
    id: "USP-M-LP-004",
    title: "LP-004: 35yo with Mirena, pain and bleeding, ?malpositioned - asks for the string examination",
    note: "35yo with Mirena, recent lower abdominal pain and pv bleeding ? IUD malpositioned",
    matrix: { caseId: "LP-004", expected: "declined / at_risk", divergence: "none" },
    answers: {
      "patient.age": doc(35, "35yo"),
      "symptom.iudPerforationSymptoms": inf(true, "recent lower abdominal pain and pv bleeding"),
    },
    expect: { ...INSUF, missing: ["symptom.iudStringsNotVisible", "symptom.iudFragmentRetained", "symptom.iudPerforationSymptoms"], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "USP-M-DG-004",
    title: "DG-004: 'AUB, 2 risk factors' - the count cannot be used; asks for age, exclusion of non-uterine causes, each risk factor",
    note: "AUB, 2 risk factors, urgent US pelvis pls",
    matrix: { caseId: "DG-004", expected: "declined", divergence: "insufficient, not declined: a stated count of risk factors has no indicator (REVIEW Q10 / finding)" },
    answers: { "symptom.abnormalUterineBleeding": doc(true, "AUB") },
    expect: {
      ...INSUF,
      missing: ["patient.age", "workup.nonUterineBleedingCausesExcluded", "symptom.pelvicMassPalpable", "imaging.any.sinceSymptomOnset", ...RF_IDS],
      redirects: [], unconfirmedExclusions: [],
    },
  },
  {
    id: "USP-M-DG-005",
    title: "DG-005: '21y old girl, PMB, on COC' - literal P2; the age/PMB contradiction is not the engine's to flag",
    note: "21y old girl, PMB, on COC",
    matrix: { caseId: "DG-005", expected: "declined + flag contradiction", divergence: "P2: 'around the expected age of menopause (approximately 50 years)' is not a threshold and is not encoded as an age check (REVIEW Q7)" },
    answers: { "patient.age": doc(21, "21y"), "symptom.postmenopausalBleeding": doc(true, "PMB") },
    expect: { ...P2, missing: [], redirects: [] },
  },
  {
    id: "USP-M-MW-001",
    title: "MW-001: 32F abdo pain and bloating, ?Endo, pelvic exam not done - everything inferred: insufficient",
    note: "32F ... Tender RIF and suprapubic tenderness. Pelvic exam not done. ongoing abdo pain and bloating ? Endo",
    matrix: { caseId: "MW-001", expected: "at_risk or declined", divergence: "none" },
    answers: {
      "patient.age": doc(32, "32F"),
      "symptom.endometriosisSuspected": inf(true, "? Endo"),
      "symptom.ovarianCancerSymptomsPersistent": inf(true, "ongoing abdo pain and bloating"),
    },
    expect: {
      ...INSUF,
      missing: ["symptom.ovarianCancerSymptomsPersistent", "symptom.pelvicMassPalpable", "lab.ca125.value", "symptom.ovarianCancerSymptomsWeeks", "workup.recentlyInvestigated"],
      redirects: [], unconfirmedExclusions: ["symptom.endometriosisSuspected", "symptom.pelvicMassPalpable"],
      inferredExcluded: ["symptom.endometriosisSuspected", "symptom.ovarianCancerSymptomsPersistent"],
    },
  },
  {
    id: "USP-M-MW-002-inferred",
    title: "MW-002 (same note as MW-001 plus PMS paste) under 'inferred': endometriosis redirect waits on the pelvic examination",
    note: "Same as MW-001; Appendix operation 2018. On fluoxetine, quetiapine, ferrograd.",
    matrix: { caseId: "MW-002", expected: "at_risk", divergence: "none" },
    answers: {
      "patient.age": doc(32, "32F"),
      "symptom.endometriosisSuspected": inf(true, "? Endo"),
      "symptom.ovarianCancerSymptomsPersistent": inf(true, "ongoing abdo pain and bloating"),
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: {
      ...INSUF,
      missing: ["symptom.pelvicMassPalpable", "lab.ca125.value", "symptom.ovarianCancerSymptomsWeeks", "workup.recentlyInvestigated"],
      redirects: [], unconfirmedExclusions: ["symptom.pelvicMassPalpable"], inferredExcluded: [],
    },
  },
  {
    id: "USP-M-MW-004",
    title: "MW-004: 64F leg swelling, ?enlarged uterus, no masses palpable - no row engaged: insufficient with nothing to add",
    note: "64 yo female. 3+ months of unilateral leg swelling. ... abdominal examination - firmness noted, no masses palpable",
    matrix: { caseId: "MW-004", expected: "declined", divergence: "insufficient, not declined: three-valued logic cannot conclude 'not met' from silence (transcription-notes §5)" },
    answers: { "patient.age": doc(64, "64 yo"), "symptom.pelvicMassPalpable": doc(false, "no masses palpable") },
    expect: { ...INSUF, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "USP-M-MW-006",
    title: "MW-006: 26yo requesting a dating scan before medical TOP - no row covers it: insufficient with nothing to add",
    note: "26 yo woman keen for TOP, please provide the USS required ... currently 6 weeks gestation",
    matrix: { caseId: "MW-006", expected: "declined (out of scope)", divergence: "insufficient, not declined: the section has no 'out of scope' row for pregnancy dating" },
    answers: { "patient.age": doc(26, "26 yo") },
    expect: { ...INSUF, missing: [], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "USP-M-MW-007",
    title: "MW-007: 29F irregular heavier periods, bloating, ?endometriosis, Ca-125 pending - insufficient, asks for Ca-125 and AUB work-up",
    note: "29 yo female ... irregular periods for last few months, now heavier ... severe bloating ... ?endometriosis ?ovarian pathology ... advised urgent blood test for Ca-125",
    matrix: { caseId: "MW-007", expected: "at_risk (Ca-125 requested but not documented)", divergence: "none" },
    answers: {
      "patient.age": doc(29, "29 yo"),
      "symptom.abnormalUterineBleeding": doc(true, "irregular periods for last few months, now heavier"),
      "symptom.endometriosisSuspected": inf(true, "?endometriosis"),
      "symptom.ovarianCancerSymptomsPersistent": inf(true, "severe bloating"),
    },
    expect: {
      ...INSUF,
      missing: ["workup.nonUterineBleedingCausesExcluded", "symptom.pelvicMassPalpable", "imaging.any.sinceSymptomOnset", ...RF_IDS,
        "symptom.ovarianCancerSymptomsPersistent", "lab.ca125.value", "symptom.ovarianCancerSymptomsWeeks", "workup.recentlyInvestigated"],
      redirects: [], unconfirmedExclusions: ["symptom.endometriosisSuspected", "symptom.pelvicMassPalpable"],
    },
  },
  {
    id: "USP-M-MW-008-inferred",
    title: "MW-008: 24F six months unilateral pelvic pain, dysmenorrhoea since menarche - insufficient on the matrix excerpt",
    note: "24 year old woman ... six-month history of progressively worsening right-sided unilateral pelvic pain with long-standing dysmenorrhoea since menarche ...",
    matrix: { caseId: "MW-008", expected: "proceeds (adult criteria)", divergence: "the matrix holds only an excerpt of a 'well-documented referral'; on the excerpt P3 pelvic pain needs 'unrelated to menstrual cycle' and PID excluded, and the primary dysmenorrhoea redirect waits on the pelvic examination" },
    answers: {
      "patient.age": doc(24, "24 year old"),
      "symptom.pelvicPainUnilateral": doc(true, "right-sided unilateral pelvic pain"),
      "symptom.pelvicPainWeeks": inf(26, "six-month history"),
      "symptom.primaryDysmenorrhoea": inf(true, "long-standing dysmenorrhoea since menarche"),
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...INSUF, missing: ["symptom.pelvicPainUnrelatedToMenstrualCycle", "symptom.pid"], redirects: [], unconfirmedExclusions: ["symptom.pelvicMassPalpable"] },
  },
  {
    id: "USP-M-EQ-001",
    title: "EQ-001: 38yo Maori, irregular heavy bleeding, BMI 34 - P3 (two risk factors incl. ethnicity); P2 waits on non-uterine causes",
    note: "38yo Māori woman with 4 months of irregular heavy menstrual bleeding, intermenstrual spotting, BMI 34. No prior investigations. First presentation.",
    matrix: { caseId: "EQ-001", expected: "proceeds, P2 with equity provision", divergence: "P3 not P2: P2 row 5 also needs non-uterine causes excluded, which the note does not state (listed as missing); ethnicity counted per REVIEW Q10" },
    answers: {
      "patient.age": doc(38, "38yo"),
      "patient.maoriOrPacificEthnicity": doc(true, "Māori"),
      "patient.bmi": doc(34, "BMI 34"),
      "symptom.abnormalUterineBleeding": doc(true, "irregular heavy menstrual bleeding"),
      "imaging.any.sinceSymptomOnset": doc(false, "No prior investigations"),
    },
    expect: { ...P3, missing: ["workup.nonUterineBleedingCausesExcluded"], redirects: [], unconfirmedExclusions: [] },
  },
  {
    id: "USP-M-EQ-002",
    title: "EQ-002: 47yo, heavy irregular bleeding, BMI 33, T2DM - insufficient until non-uterine causes are excluded",
    note: "47yo NZ European woman, 5 months of heavy irregular menstrual bleeding with intermenstrual spotting. BMI 33. Type 2 diabetes on metformin. No prior pelvic imaging. First presentation. Not on hormonal contraception.",
    matrix: { caseId: "EQ-002", expected: "proceeds - no equity provision", divergence: "insufficient: both P2 row 5 and P3 row 1 require non-uterine causes excluded, not stated in the note" },
    answers: {
      "patient.age": doc(47, "47yo"),
      "patient.maoriOrPacificEthnicity": doc(false, "NZ European"),
      "patient.bmi": doc(33, "BMI 33"),
      "patient.diabetes": doc(true, "Type 2 diabetes"),
      "symptom.abnormalUterineBleeding": doc(true, "heavy irregular menstrual bleeding"),
      "imaging.any.sinceSymptomOnset": doc(false, "No prior pelvic imaging"),
    },
    expect: { ...INSUF, missing: ["workup.nonUterineBleedingCausesExcluded"], redirects: [], unconfirmedExclusions: [] },
  },

  // STEP-3 worked example (instructions/arch-mig-prompt-decomposition.md item 23; system prompt v2.3.0:
  // "General post-menopausal bleeding pathway is fully met -> verdict is "proceeds" at P2, even if
  // MHT-specific variant requires type and duration details.")
  {
    id: "USP-STEP3-pmb-vs-mht",
    title: "STEP-3 example: documented PMB on MHT of unknown type and duration - P2; the MHT variant does not block or add questions",
    answers: { "patient.age": 57, "symptom.postmenopausalBleeding": true, "patient.postmenopausal": true },
    expect: { ...P2, missing: [], redirects: [], unconfirmedExclusions: [] },
  },

  // -------------------------------------------------------------------------
  // (2) Acute: Within 24 hours
  // -------------------------------------------------------------------------
  { id: "USP-A24-01-acutely-unwell", title: "Acutely unwell from a suspected gynaecological cause",
    answers: { "patient.age": 30, "symptom.acutelyUnwellSuspectedGynaeCause": true },
    expect: { ...A24, missing: [], redirects: [] } },
  { id: "USP-A24-02-iud-strings", title: "IUD strings not visible with perforation symptoms",
    answers: { "patient.age": 30, "symptom.iudStringsNotVisible": true, "symptom.iudPerforationSymptoms": true },
    expect: { ...A24, missing: [] } },
  { id: "USP-A24-03-iud-fragment", title: "IUD fragment retained with perforation symptoms",
    answers: { "patient.age": 30, "symptom.iudFragmentRetained": true, "symptom.iudPerforationSymptoms": true },
    expect: { ...A24, missing: [] } },
  { id: "USP-A24-04-iud-symptoms-unknown", title: "IUD strings not visible, symptoms not stated: insufficient, asks for symptoms",
    answers: { "patient.age": 30, "symptom.iudStringsNotVisible": true },
    expect: { ...INSUF, missing: ["symptom.iudPerforationSymptoms"] } },
  { id: "USP-A24-05-precedence", title: "Acute 24h outranks P2 when both are met",
    answers: { "patient.age": 55, "symptom.acutelyUnwellSuspectedGynaeCause": true, "symptom.postmenopausalBleeding": true },
    expect: { ...A24, missing: [] } },

  // Acute: Within 48 hours
  { id: "USP-A48-01-urine-hcg", title: "Suspected ongoing pregnancy, urine HCG 1500 IU at 14 days",
    answers: { "patient.age": 28, "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": true, "lab.urineHcg.value": 1500.0 },
    expect: { ...A48, missing: [] } },
  { id: "USP-A48-02-urine-hcg-boundary", title: "Urine HCG exactly 1000 IU, serum bHCG not high: row not met (boundary)",
    answers: { "patient.age": 28, "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": true, "lab.urineHcg.value": 1000.0, "lab.serumBhcg.remainsHigh": false },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-A48-03-serum-bhcg", title: "Suspected ongoing pregnancy, serial serum bHCG remains high",
    answers: { "patient.age": 28, "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": true, "lab.serumBhcg.remainsHigh": true },
    expect: { ...A48, missing: [] } },
  { id: "USP-A48-04-hcg-unknown", title: "Suspected ongoing pregnancy, no HCG results: asks for them",
    answers: { "patient.age": 28, "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": true },
    expect: { ...INSUF, missing: ["lab.urineHcg.value", "lab.serumBhcg.remainsHigh"] } },
  { id: "USP-A48-05-advice", title: "Specialist advises same or next day ultrasound, adviser named",
    answers: { "patient.age": 40, "advice.acuteImagingRecommended": true, "advice.adviserNameRole": { v: "Dr A, gynaecology registrar" } },
    expect: { ...A48, missing: [] } },
  { id: "USP-A48-06-advice-unnamed", title: "Same/next day advice without adviser name: asks for name and role",
    answers: { "patient.age": 40, "advice.acuteImagingRecommended": true },
    expect: { ...A48, missing: ["advice.adviserNameRole"] } },

  // P2 Urgent
  { id: "USP-P2-01-mass-suspicious", title: "Pelvic mass on examination suspicious of cancer",
    answers: { "patient.age": 62, "symptom.pelvicMassPalpable": true, "symptom.pelvicMassSuspiciousOfCancer": true },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-02-pmb", title: "Postmenopausal bleeding",
    answers: { "patient.age": 60, "symptom.postmenopausalBleeding": true },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-03-cc-mht", title: "Persistent bleeding, post-menopausal, continuous combined MHT for 7 months",
    answers: { "patient.age": 58, "patient.postmenopausal": true, "symptom.postmenopausalBleeding": false, "symptom.vaginalBleedingPersistent": true, "patient.mhtContinuousCombined": true, "patient.mhtMonthsSinceStart": 7.0 },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-04-cc-mht-boundary", title: "Same at exactly 6 months: P2 row 3 not met (boundary)",
    answers: { "patient.age": 58, "patient.postmenopausal": true, "symptom.postmenopausalBleeding": false, "symptom.vaginalBleedingPersistent": true, "patient.mhtContinuousCombined": true, "patient.mhtMonthsSinceStart": 6.0 },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P2-05-ca125-boundary", title: "No palpable mass, persistent symptoms, Ca-125 exactly 35: P2 (boundary inclusive)",
    answers: { "patient.age": 55, "symptom.pelvicMassPalpable": false, "symptom.ovarianCancerSymptomsPersistent": true, "lab.ca125.value": 35.0 },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-06-ca125-34-p3", title: "Ca-125 34, symptoms 8 weeks, not recently investigated: P3 row 6",
    answers: { "patient.age": 55, "symptom.pelvicMassPalpable": false, "symptom.ovarianCancerSymptomsPersistent": true, "lab.ca125.value": 34.0, "symptom.ovarianCancerSymptomsWeeks": 8.0, "workup.recentlyInvestigated": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P2-07-aub-two-risk-factors", title: "AUB, non-uterine causes excluded, two risk factors (tamoxifen, diabetes)",
    answers: { "patient.age": 40, "symptom.abnormalUterineBleeding": true, "workup.nonUterineBleedingCausesExcluded": true, "patient.tamoxifenTherapy": true, "patient.diabetes": true },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-08-aub-mass-not-imaged", title: "AUB, non-uterine causes excluded, suspected mass, no imaging since onset",
    answers: { "patient.age": 40, "symptom.abnormalUterineBleeding": true, "workup.nonUterineBleedingCausesExcluded": true, "symptom.pelvicMassPalpable": true, "imaging.any.sinceSymptomOnset": false },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-09-ag2", title: "Atypical (AG2) endometrial cells on cervical screening cytology",
    answers: { "patient.age": 33, "lab.cytology.atypicalEndometrialCells": true },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-10-advice", title: "Specialist advises urgent US pelvis, adviser named",
    answers: { "patient.age": 50, "advice.urgentImagingRecommended": true, "advice.adviserNameRole": { v: "Dr B, PCRL" } },
    expect: { ...P2, missing: [] } },
  { id: "USP-P2-11-lists-more-urgent", title: "P2 met; an engaged but unresolved Acute 48h row is listed (could raise urgency)",
    answers: { "patient.age": 52, "symptom.postmenopausalBleeding": true, "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": true },
    expect: { ...P2, missing: ["lab.urineHcg.value", "lab.serumBhcg.remainsHigh"] } },

  // P3
  { id: "USP-P3-01-aub-45", title: "AUB at exactly 45, non-uterine causes excluded, no risk factors, no mass: P3 row 1 (boundary)",
    answers: { ...NO_RF, "patient.age": 45, "symptom.abnormalUterineBleeding": true, "workup.nonUterineBleedingCausesExcluded": true, "symptom.pelvicMassPalpable": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-02-aub-44", title: "Same at 44, first-line treatment 1 month and responding: no row met",
    answers: { ...NO_RF, "patient.age": 44, "symptom.abnormalUterineBleeding": true, "workup.nonUterineBleedingCausesExcluded": true, "symptom.pelvicMassPalpable": false,
      "workup.aubFirstLineTreatmentTrialled": true, "workup.aubFirstLineTreatmentMonths": 1.0, "workup.aubFirstLineTreatmentResponded": true },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P3-03-aub-under45-risk", title: "AUB under 45 with one risk factor; non-uterine causes not excluded (REVIEW Q12)",
    answers: { "patient.age": 40, "symptom.abnormalUterineBleeding": true, "workup.nonUterineBleedingCausesExcluded": false, "patient.tamoxifenTherapy": true },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-04-first-line-3m", title: "Under 45, first-line treatment 3 months, not responded (boundary inclusive)",
    answers: { "patient.age": 30, "workup.aubFirstLineTreatmentMonths": 3.0, "workup.aubFirstLineTreatmentResponded": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-05-first-line-under-3m", title: "First-line treatment 2.9 months: row not met",
    answers: { "patient.age": 30, "workup.aubFirstLineTreatmentMonths": 2.9, "workup.aubFirstLineTreatmentResponded": false },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P3-06-cyclical-mht", title: "Perimenopausal, cyclical MHT 8 months, irregular bleeding despite increased progestogen",
    answers: { "patient.age": 49, "patient.perimenopausal": true, "patient.mhtCyclicalCombined": true, "symptom.irregularBleedingOngoing": true, "workup.increasedProgestogenTrialled": true, "patient.mhtMonthsSinceStart": 8.0 },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-07-benign-cells-postmenopausal", title: "Benign-appearing endometrial cells on smear, post-menopausal",
    answers: { "patient.age": 57, "lab.cytology.benignEndometrialCells": true, "patient.postmenopausal": true },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-08-cyst-unilateral-pain", title: "Suspected ovarian cyst, unilateral pain 5 weeks",
    answers: { "patient.age": 34, "symptom.ovarianCystSuspected": true, "symptom.pelvicPainUnilateral": true, "symptom.pelvicPainWeeks": 5.0 },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-09-cyst-pain-boundary", title: "Suspected cyst, unilateral pain exactly 4 weeks, no tenderness, no mass: not met (boundary)",
    answers: { "patient.age": 34, "symptom.ovarianCystSuspected": true, "symptom.pelvicPainUnilateral": true, "symptom.pelvicPainWeeks": 4.0, "symptom.pelvicTendernessUnilateral": false, "symptom.pelvicMassPalpable": false },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P3-10-cyst-low-suspicion-mass", title: "Suspected cyst with pelvic mass, low suspicion of cancer",
    answers: { "patient.age": 34, "symptom.ovarianCystSuspected": true, "symptom.pelvicMassPalpable": true, "symptom.pelvicMassSuspiciousOfCancer": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-11-pelvic-pain", title: "Pelvic pain 8 weeks, unrelated to cycle, PID excluded",
    answers: { "patient.age": 29, "symptom.pelvicPainWeeks": 8.0, "symptom.pelvicPainUnrelatedToMenstrualCycle": true, "symptom.pid": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-12-primary-amenorrhoea", title: "Primary amenorrhoea",
    answers: { "patient.age": 17, "symptom.primaryAmenorrhoea": true },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-13-iud-asymptomatic", title: "IUD strings not visible, asymptomatic",
    answers: { "patient.age": 30, "symptom.iudStringsNotVisible": true, "symptom.iudPerforationSymptoms": false },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-14-secondary-dysmenorrhoea", title: "New onset secondary dysmenorrhoea, debilitating despite 3 months medical management",
    answers: { "patient.age": 36, "symptom.secondaryDysmenorrhoeaNewOnset": true, "symptom.dysmenorrhoeaDebilitatingPainPersists": true, "workup.dysmenorrhoeaMedicalManagementMonths": 3.0 },
    expect: { ...P3, missing: [] } },
  { id: "USP-P3-15-advice", title: "Specialist advises routine ultrasound pelvis, adviser named",
    answers: { "patient.age": 36, "advice.nonUrgentImagingRecommended": true, "advice.adviserNameRole": { v: "Dr C, radiologist" } },
    expect: { ...P3, missing: [] } },

  // P4
  { id: "USP-P4-01-pcos-one", title: "Suspected PCOS, only one Rotterdam criterion",
    answers: { "patient.age": 24, "symptom.pcosSuspected": true, "symptom.hyperandrogenism": true, "symptom.polycysticOvaries": false, "symptom.irregularMenses": false },
    expect: { ...P4, missing: [] } },
  { id: "USP-P4-02-pcos-two", title: "Suspected PCOS, two Rotterdam criteria: row not met",
    answers: { "patient.age": 24, "symptom.pcosSuspected": true, "symptom.hyperandrogenism": true, "symptom.irregularMenses": true },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P4-03-fibroid", title: "Known 6cm fibroid symptomatic after starting MHT",
    answers: { "patient.age": 53, "symptom.knownFibroidSizeCm": 6.0, "symptom.fibroidSymptomaticAfterStartingMht": true },
    expect: { ...P4, missing: [] } },
  { id: "USP-P4-04-fibroid-boundary", title: "Known fibroid exactly 5cm: row not met (boundary)",
    answers: { "patient.age": 53, "symptom.knownFibroidSizeCm": 5.0, "symptom.fibroidSymptomaticAfterStartingMht": true },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-P4-05-advice", title: "Specialist advises deferrable ultrasound pelvis, adviser named",
    answers: { "patient.age": 44, "advice.deferrableImagingRecommended": true, "advice.adviserNameRole": { v: "Dr D, gynaecologist" } },
    expect: { ...P4, missing: [] } },

  // S2 / S3
  { id: "USP-S2-01-orads2-6m", title: "6-month follow-up of an O-RADS 2 cyst",
    answers: { "patient.age": 47, "workup.followUpScan": true, "symptom.ovarianCystORads2": true, "workup.followUpIntervalMonths": 6.0 },
    expect: { ...S2, missing: [] } },
  { id: "USP-S2-02-haemorrhagic", title: "Follow-up of a haemorrhagic cyst, pre-menopausal",
    answers: { "patient.age": 31, "workup.followUpScan": true, "symptom.haemorrhagicCyst": true, "patient.postmenopausal": false },
    expect: { ...S2, missing: [] } },
  { id: "USP-S2-03-polyp", title: "Follow-up of an incidental asymptomatic endometrial polyp, no risk factors",
    answers: { ...NO_RF, "patient.age": 50, "workup.followUpScan": true, "symptom.endometrialPolypIncidental": true },
    expect: { ...S2, missing: [] } },
  { id: "USP-S3-01-orads2-12m", title: "12-month follow-up of an O-RADS 2 cyst",
    answers: { "patient.age": 47, "workup.followUpScan": true, "symptom.ovarianCystORads2": true, "workup.followUpIntervalMonths": 12.0 },
    expect: { ...S3, missing: [] } },
  { id: "USP-S3-02-dermoid", title: "12-month follow-up of a suspected dermoid, pre-menopausal",
    answers: { "patient.age": 33, "workup.followUpScan": true, "symptom.dermoidCystSuspected": true, "patient.postmenopausal": false, "workup.followUpIntervalMonths": 12.0 },
    expect: { ...S3, missing: [] } },
  { id: "USP-S3-03-endometrioma", title: "12-month follow-up of a suspected asymptomatic endometrioma, pre-menopausal",
    answers: { "patient.age": 33, "workup.followUpScan": true, "symptom.endometriomaSuspected": true, "symptom.ovarianCystSymptomatic": false, "patient.postmenopausal": false, "workup.followUpIntervalMonths": 12.0 },
    expect: { ...S3, missing: [] } },
  { id: "USP-S-04-interval-unknown", title: "O-RADS 2 follow-up, interval not given: asks for it",
    answers: { "patient.age": 47, "workup.followUpScan": true, "symptom.ovarianCystORads2": true },
    expect: { ...INSUF, missing: ["workup.followUpIntervalMonths"] } },

  // Alternative management
  { id: "USP-AM-01-rpoc", title: "Suspected RPOC with heavy bleeding after miscarriage",
    answers: { "patient.age": 30, "symptom.rpocSuspected": true, "symptom.bleedingPersistentOrHeavyPostAbortionOrMiscarriage": true },
    expect: { ...AM, redirects: [R.rpoc] } },
  { id: "USP-AM-02-endometriosis", title: "Suspected endometriosis, no palpable mass",
    answers: { "patient.age": 30, "symptom.endometriosisSuspected": true, "symptom.pelvicMassPalpable": false },
    expect: { ...AM, redirects: [R.endo] } },
  { id: "USP-AM-03-endometriosis-mass-unknown", title: "Suspected endometriosis, mass not stated: unresolved, surfaced as unconfirmed",
    answers: { "patient.age": 30, "symptom.endometriosisSuspected": true },
    expect: { ...INSUF, missing: [], redirects: [], unconfirmedExclusions: ["symptom.pelvicMassPalpable"] } },
  { id: "USP-AM-04-primary-dysmenorrhoea", title: "Primary dysmenorrhoea, no palpable mass",
    answers: { "patient.age": 19, "symptom.primaryDysmenorrhoea": true, "symptom.pelvicMassPalpable": false },
    expect: { ...AM, redirects: [R.dysm] } },
  { id: "USP-AM-05-pid", title: "PID, no palpable mass",
    answers: { "patient.age": 22, "symptom.pid": true, "symptom.pelvicMassPalpable": false },
    expect: { ...AM, redirects: [R.pid] } },
  { id: "USP-AM-06-cervical-polyp", title: "Cervical polyp",
    answers: { "patient.age": 42, "symptom.cervicalPolyp": true },
    expect: { ...AM, redirects: [R.polyp] } },
  { id: "USP-AM-07-secondary-amenorrhoea", title: "Secondary amenorrhoea, no mass, androgens not significantly raised",
    answers: { "patient.age": 27, "symptom.secondaryAmenorrhoea": true, "symptom.pelvicMassPalpable": false, "lab.androgens.significantlyRaised": false },
    expect: { ...AM, redirects: [R.amen] } },
  { id: "USP-AM-08-secondary-amenorrhoea-androgens", title: "Secondary amenorrhoea with significantly raised androgens: no redirect",
    answers: { "patient.age": 27, "symptom.secondaryAmenorrhoea": true, "lab.androgens.significantlyRaised": true },
    expect: { ...INSUF, missing: [], redirects: [], unconfirmedExclusions: [] } },
  { id: "USP-AM-09-redirect-over-p2", title: "Redirect outranks a met P2 row (REVIEW Q2)",
    answers: { "patient.age": 55, "symptom.pid": true, "symptom.pelvicMassPalpable": false, "symptom.postmenopausalBleeding": true },
    expect: { ...AM, redirects: [R.pid] } },

  // Not routinely funded
  { id: "USP-NF-01-fibroid-follow-up", title: "Routine follow-up of known fibroids",
    answers: { "patient.age": 45, "funding.routineFibroidFollowUp": true }, expect: NF },
  { id: "USP-NF-02-subfertility", title: "Subfertility",
    answers: { "patient.age": 33, "funding.subfertility": true }, expect: NF },
  { id: "USP-NF-03-simple-cyst-post", title: "Follow-up of asymptomatic simple cyst 2.5cm, post-menopausal",
    answers: { "patient.age": 60, "workup.followUpScan": true, "symptom.ovarianCystSymptomatic": false, "symptom.ovarianCystSimple": true, "symptom.ovarianCystSizeCm": 2.5, "patient.postmenopausal": true },
    expect: NF },
  { id: "USP-NF-04-simple-cyst-post-boundary", title: "Same at exactly 3cm: not in the not-funded row (boundary)",
    answers: { "patient.age": 60, "workup.followUpScan": true, "symptom.ovarianCystSymptomatic": false, "symptom.ovarianCystSimple": true, "symptom.ovarianCystSizeCm": 3.0, "patient.postmenopausal": true },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-NF-05-simple-cyst-pre-over-s2", title: "Asymptomatic simple O-RADS 2 cyst 4.9cm pre-menopausal at 6 months: not funded outranks S2",
    answers: { "patient.age": 38, "workup.followUpScan": true, "symptom.ovarianCystSymptomatic": false, "symptom.ovarianCystSimple": true, "symptom.ovarianCystORads2": true, "symptom.ovarianCystSizeCm": 4.9, "patient.postmenopausal": false, "workup.followUpIntervalMonths": 6.0 },
    expect: NF },
  { id: "USP-NF-06-non-simple-cyst", title: "Follow-up of asymptomatic non-simple cyst 2cm, premenopausal",
    answers: { "patient.age": 38, "workup.followUpScan": true, "symptom.ovarianCystSymptomatic": false, "symptom.ovarianCystSimple": false, "symptom.ovarianCystSizeCm": 2.0, "patient.postmenopausal": false },
    expect: NF },
  { id: "USP-NF-07-haemorrhagic-5cm", title: "Typical haemorrhagic cyst exactly 5cm pre-menopausal: not funded (up to 5cm inclusive), outranks S2",
    answers: { "patient.age": 31, "workup.followUpScan": true, "symptom.haemorrhagicCyst": true, "symptom.haemorrhagicCystTypicalAppearing": true, "symptom.ovarianCystSizeCm": 5.0, "patient.postmenopausal": false },
    expect: NF },
  { id: "USP-NF-08-benign-cells", title: "Benign endometrial cells, asymptomatic, pre-menopausal, normal exam, no risk factors",
    answers: { ...NO_RF, "patient.age": 40, "lab.cytology.benignEndometrialCells": true, "symptom.gynaeSymptomatic": false, "patient.postmenopausal": false, "symptom.examinationAbnormality": false },
    expect: NF },
  { id: "USP-NF-09-mht-bleeding-6m", title: "Erratic unscheduled bleeding at exactly 6 months after starting MHT (REVIEW Q15)",
    answers: { "patient.age": 52, "symptom.erraticUnscheduledBleedingOnMht": true, "patient.mhtMonthsSinceStart": 6.0 },
    expect: NF },
  { id: "USP-NF-10-mht-bleeding-7m", title: "Same at 7 months: not in the not-funded row",
    answers: { "patient.age": 52, "symptom.erraticUnscheduledBleedingOnMht": true, "patient.mhtMonthsSinceStart": 7.0 },
    expect: { ...INSUF, missing: [] } },
  { id: "USP-NF-11-screening", title: "Screening ultrasound for family history of ovarian cancer",
    answers: { "patient.age": 41, "funding.ovarianCancerFamilyHistoryScreening": true }, expect: NF },
  { id: "USP-NF-12-aub-under45-untrialled", title: "AUB under 45, no risk factors, normal exam, first-line not trialled",
    answers: { ...NO_RF, "patient.age": 30, "symptom.abnormalUterineBleeding": true, "symptom.examinationAbnormality": false, "workup.aubFirstLineTreatmentTrialled": false },
    expect: NF },
  { id: "USP-NF-13-over-redirect", title: "Not funded outranks a redirect (REVIEW Q2)",
    answers: { "patient.age": 33, "funding.subfertility": true, "symptom.cervicalPolyp": true },
    expect: { ...NF, redirects: [R.polyp] } },

  // Age, determination edges
  { id: "USP-X-01-paediatric", title: "Age 15: paediatric criteria apply",
    answers: { "patient.age": 15, "symptom.postmenopausalBleeding": true },
    expect: { determination: "PAEDIATRIC_CRITERIA_APPLY", priorityCode: null, missing: [] } },
  { id: "USP-X-02-age-unknown", title: "Age unknown: insufficient, asks for age",
    answers: { "symptom.postmenopausalBleeding": true },
    expect: { ...INSUF, missing: ["patient.age"] } },
  { id: "USP-X-03-criteria-not-met", title: "Every row answered not met: criteria not met",
    answers: {
      "patient.age": 50, "symptom.acutelyUnwellSuspectedGynaeCause": false, "symptom.iudStringsNotVisible": false, "symptom.iudFragmentRetained": false,
      "symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage": false, "advice.acuteImagingRecommended": false,
      "symptom.pelvicMassPalpable": false, "symptom.postmenopausalBleeding": false, "symptom.vaginalBleedingPersistent": false,
      "symptom.ovarianCancerSymptomsPersistent": false, "symptom.abnormalUterineBleeding": false, "lab.cytology.atypicalEndometrialCells": false,
      "advice.urgentImagingRecommended": false, "patient.perimenopausal": false, "lab.cytology.benignEndometrialCells": false,
      "symptom.ovarianCystSuspected": false, "symptom.pelvicPainUnrelatedToMenstrualCycle": false, "symptom.primaryAmenorrhoea": false,
      "symptom.secondaryDysmenorrhoeaNewOnset": false, "advice.nonUrgentImagingRecommended": false, "symptom.pcosSuspected": false,
      "symptom.fibroidSymptomaticAfterStartingMht": false, "advice.deferrableImagingRecommended": false, "symptom.ovarianCystORads2": false,
      "symptom.haemorrhagicCyst": false, "symptom.endometrialPolypIncidental": false, "symptom.dermoidCystSuspected": false,
      "symptom.endometriomaSuspected": false,
    },
    expect: { determination: "CRITERIA_NOT_MET", priorityCode: null, missing: [], redirects: [], unconfirmedExclusions: [] } },

  // (3) Strict vs inferred
  { id: "USP-SI-01-strict", title: "'Acutely unwell' only inferred, strict standard: insufficient, asks for it",
    answers: { "patient.age": 30, "symptom.acutelyUnwellSuspectedGynaeCause": inf(true, "sudden severe pelvic pain, ?torsion") },
    expect: { ...INSUF, missing: ["symptom.acutelyUnwellSuspectedGynaeCause"], inferredExcluded: ["symptom.acutelyUnwellSuspectedGynaeCause"] } },
  { id: "USP-SI-02-inferred", title: "Same under the 'inferred' standard: Acute 24h",
    answers: { "patient.age": 30, "symptom.acutelyUnwellSuspectedGynaeCause": inf(true, "sudden severe pelvic pain, ?torsion") },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...A24, missing: [], inferredExcluded: [] } },
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

// Decimal-typed indicators must be sent as valueDecimal even for whole numbers.
const DECIMAL_IDS = new Set([
  "patient.mhtMonthsSinceStart", "patient.bmi", "lab.urineHcg.value", "lab.ca125.value",
  "symptom.ovarianCancerSymptomsWeeks", "symptom.pelvicPainWeeks", "symptom.knownFibroidSizeCm", "symptom.ovarianCystSizeCm",
  "workup.aubFirstLineTreatmentMonths", "workup.dysmenorrhoeaMedicalManagementMonths", "workup.followUpIntervalMonths",
]);

export function toQuestionnaireResponse(s) {
  const groups = {};
  for (const [linkId, a] of Object.entries(s.answers)) {
    const ans = answerFor(a);
    if (DECIMAL_IDS.has(linkId) && "valueInteger" in ans) { ans.valueDecimal = ans.valueInteger; delete ans.valueInteger; }
    (groups[linkId.split(".")[0]] ||= []).push({ linkId, answer: [ans] });
  }
  return {
    resourceType: "QuestionnaireResponse",
    id: "qr-" + s.id,
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-US-Pelvis-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
