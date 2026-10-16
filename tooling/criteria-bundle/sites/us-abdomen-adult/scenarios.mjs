// Test scenarios for CRR_USAbdomen_Adult (US Abdomen - Adult, National criteria v2.0 pp.30-33).
// DEMO TRANSCRIPTION - NOT CLINICALLY REVIEWED. Expectations follow the literal reading
// recorded in the CQL header and signoff.md (REVIEW Q1-Q24).
//
// Order: results-matrix cases for this site first (MW-009 encoded as a US Abdomen request,
// RP-002, CB-001, CB-002), then coverage of every row, redirect, not-funded item, boundary
// and the documentation standard. Notes are synthetic or quoted verbatim from the matrix;
// none carries patient-identifiable data.
//
// Answer shorthand: a bare value is a directly asserted answer (counts as documented);
// { v, status, quote } carries the evidence extension; { q, unit, code } is a quantity.

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";
const ADVISER = "advice.adviserNameRole";

const doc = (v, quote) => ({ v, status: "documented", quote });
// ALT in IU/L. The UCUM code must be sent: FHIRHelpers.ToQuantity falls back to the
// display unit when `code` is absent, and cql-execution rejects "IU/L" as invalid UCUM.
const ALT = (q) => ({ q, unit: "IU/L", code: "[IU]/L" });
const inf = (v, quote) => ({ v, status: "inferred", quote });

// Published redirect wording (verbatim, p32-33), as the library emits it.
const R = {
  upperMass: "Upper abdominal non-pulsatile mass, not consistent with hepatomegaly – discuss with Primary Care Radiology Liaison or relevant secondary care specialist as referral for CT abdomen may be more appropriate.",
  malignancy: "Unexplained weight loss, persistent fatigue, vague abdominal pain and suspicion of underlying malignancy – See local CT Chest, Abdomen and Pelvis HealthPathway.",
  ggtUnder5: "Isolated raised GGT less than 5 times the ULN - Re-test after three months with interim alcohol abstinence. Consider ultrasound if GGT is higher than 5 times the ULN on re-testing.",
  alpNormalGgt: "ALP elevated with normal GGT - suggests ALP increase is probably not liver-related. If ALT or bilirubin elevated as well, or the patient is symptomatic consider ALP iso-enzyme testing to confirm liver origin.",
  ferritin: "Raised ferritin – See local Raised Ferritin or Hereditary Haemochromatosis HealthPathways",
  bilirubin: "Isolated raised bilirubin – Gilberts syndrome with unconjugated hyperbilirubinemia is the most common cause – See local Abnormal Liver Function Tests HealthPathway.",
  dyspepsia: "Dyspepsia – See local HealthPathway",
  colorectal: "Suspected colorectal neoplasm. If colicky vague abdominal pain, with or without distension, and change in bowel habit, consider colorectal cancer - See local Colorectal Symptoms HealthPathway.",
  lymphoedema: "New unilateral lymphoedema - discussion with secondary care recommended as referral for CT is usually preferable",
  pancreatitis: "Suspected or symptomatic chronic pancreatitis – request acute general surgery assessment.",
  urinary: "Urinary tract presentations and suspected renal abnormality - See local Ultrasound Renal HealthPathway",
  bloating: "Isolated bloating with associated clinical symptoms (for example decreased appetite, weight loss, abdominal pain, abnormal vaginal bleeding), seek advice from the appropriate specialist as a CT or US may be indicated.",
};

// Every row answered so that it is definitively not met, with no redirect or not-funded
// item present. Coverage scenarios spread this and change only what they test.
const NONE = {
  "patient.age": 50,
  "symptom.jaundice": false,
  "advice.acuteImagingRecommended": false,
  "advice.urgentImagingRecommended": false,
  "advice.nonUrgentImagingRecommended": false,
  "lab.alp.timesULN": 1.0,
  "lab.alp.high": false,
  "lab.ggt.raised": false,
  "symptom.biliaryColicOrCholecystitis": false,
  "symptom.recurrentRUQOrEpigastricPain": false,
  "lab.repeatAfter3Months": false,
  "lab.alt.value": ALT(30),
  "lab.isolatedLftAbnormality": false,
  "symptom.aaaNewlySuspected": false,
  "symptom.abdominalMassNonPulsatile": false,
  "advice.hccSurveillance": false,
  "advice.aaaSurveillance": false,
  "advice.incidentalFindingFollowUp": false,
};

const met = (determination, priorityCode, missing = []) => ({ determination, priorityCode, missing, redirects: [], unconfirmedExclusions: [] });

// Missing list when nothing but the MW-009 facts is known (every undetermined row's unanswered parts).
const MW009_MISSING = [
  "workup.jaundiceObviousCause", "advice.acuteImagingRecommended",
  "lab.alp.timesULN", "lab.ggt.raised",
  "symptom.biliaryColicOrCholecystitis", "lab.alp.high", "symptom.settlesWithAnalgesia", "imaging.biliaryTree.ever",
  "advice.urgentImagingRecommended",
  "symptom.recurrentRUQOrEpigastricPain", "symptom.dyspepsia", "imaging.presentingProblem.ever",
  "symptom.biliaryColicResolved", "imaging.gallstones.ever", "workup.cholecystectomyCandidate",
  "lab.repeatAfter3Months", "lab.alp.repeatHigh", "lab.ggt.repeatRaised",
  "lab.alt.value", "workup.conservativeMethodsUnsuccessful", "workup.clinicalFeaturesOfConcern",
  "lab.isolatedLftAbnormality", "lab.ggt.timesULN", "lab.ggt.repeatTimesULN",
  "symptom.aaaNewlySuspected", "symptom.aaaAsymptomatic",
  "symptom.abdominalMassNonPulsatile",
  "advice.nonUrgentImagingRecommended",
  "advice.hccSurveillance", "advice.aaaSurveillance", "advice.incidentalFindingFollowUp",
];

const MW009_NOTE = "CT chest abdo pelvis. 68 yo man. Sudden onset painless jaundice. Diabetes on metformin. Occasional discomfort R side, some pallor and jaundice. Liver ~2 cm below costal margin. wt 58";
const MW009_ANSWERS = {
  "patient.age": doc(68, "68 yo man"),
  "symptom.jaundice": doc(true, "Sudden onset painless jaundice"),
  "redflag.painfulJaundice": doc(false, "painless jaundice"),
  "symptom.abdominalPain": doc(true, "Occasional discomfort R side"),
  "symptom.hepatomegalySuspected": doc(true, "Liver ~2 cm below costal margin"),
  "patient.liverRiskFactors": doc(true, "Diabetes on metformin"),
};

export const scenarios = [
  // ---- Results-matrix cases -------------------------------------------------
  {
    id: "USAB-M01-MW-009-as-US",
    title: "MW-009 as a US Abdomen request: painless jaundice, cause not stated -> insufficient; the obvious-cause question heads the list",
    note: MW009_NOTE,
    matrix: "MW-009 (requested as CT CAP; evaluator expected US Abdomen acute). Literal reading: 'without obvious cause' is not stated, so the acute row is undetermined, not met (REVIEW Q2). P3 mass/liver is undetermined too: the note gives a liver edge but no 'non-pulsatile abdominal mass' (REVIEW Q15).",
    answers: MW009_ANSWERS,
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: MW009_MISSING, redirects: [], unconfirmedExclusions: [], inferredExcluded: [] },
  },
  {
    id: "USAB-M02-MW-009-no-cause",
    title: "MW-009 with the referrer confirming no obvious cause for the jaundice -> Acute: within 48 hours",
    note: MW009_NOTE + " [Referrer adds: no obvious cause identified.]",
    answers: { ...MW009_ANSWERS, "workup.jaundiceObviousCause": false },
    expect: met("ACUTE_48H", "A48"),
  },
  {
    id: "USAB-M03-RP-002",
    title: "RP-002: liver edge felt below the costal margin, HCC screen requested without a specialist recommendation -> P3 (mass and enlarged liver)",
    note: "61yo european male newly diagnosed autoimmune hepatitis – liver edge felt just below RCM. Screen for HCC, cirrhosis",
    matrix: "RP-002 (evaluator expected Proceeds on the hepatomegaly pathway). Both P3 bullet-7 indicators answered from the same span (REVIEW Q15). HCC surveillance is not answered (no recommendation in the note), so it neither meets S3 nor blocks P3.",
    answers: {
      "patient.age": doc(61, "61yo european male"),
      "symptom.hepatomegalySuspected": doc(true, "liver edge felt just below RCM"),
      "symptom.abdominalMassNonPulsatile": doc(true, "liver edge felt just below RCM"),
    },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-M04-RP-002-mass-inferred",
    title: "RP-002 with the mass answered as inferred: strict standard -> insufficient, the inferred answer is surfaced",
    note: "61yo european male newly diagnosed autoimmune hepatitis – liver edge felt just below RCM. Screen for HCC, cirrhosis",
    answers: {
      "patient.age": doc(61, "61yo european male"),
      "symptom.hepatomegalySuspected": doc(true, "liver edge felt just below RCM"),
      "symptom.abdominalMassNonPulsatile": inf(true, "liver edge felt just below RCM"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [], inferredExcluded: ["symptom.abdominalMassNonPulsatile"] },
  },
  {
    id: "USAB-M05-RP-002-inferred-standard",
    title: "RP-002 with the mass inferred, documentation standard 'inferred' -> P3",
    answers: {
      "patient.age": doc(61, "61yo european male"),
      "symptom.hepatomegalySuspected": doc(true, "liver edge felt just below RCM"),
      "symptom.abdominalMassNonPulsatile": inf(true, "liver edge felt just below RCM"),
    },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...met("P3_NON_DEFERRABLE", "P3"), inferredExcluded: [] },
  },
  {
    id: "USAB-M06-CB-001",
    title: "CB-001: abdominal pain for 2 days, nothing else -> insufficient information (the engine does not assume)",
    note: "64 yo Maori male with abdominal pain for 2 days",
    matrix: "CB-001 (evaluator expected Declined). The engine returns insufficient information rather than not met: no row is answered either way.",
    answers: {
      "patient.age": doc(64, "64 yo Maori male"),
      "symptom.abdominalPain": doc(true, "abdominal pain for 2 days"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [] },
  },
  {
    id: "USAB-M07-CB-002",
    title: "CB-002: ALP 260 with no ULN multiple or GGT -> insufficient; ALP flag only inferred, ULN multiple and GGT asked for",
    note: "64 yo Maori male with generalised abdominal pain for 2 weeks. ALP 260",
    matrix: "CB-002 (evaluator expected At risk / Proceeds). 'ALP 260' is a value without a flag or multiple: lab.alp.high is inferred (contract rule 4), lab.alp.timesULN is omitted (KI-13).",
    answers: {
      "patient.age": doc(64, "64 yo Maori male"),
      "symptom.abdominalPain": doc(true, "generalised abdominal pain for 2 weeks"),
      "lab.alp.high": inf(true, "ALP 260"),
    },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [], inferredExcluded: ["lab.alp.high"] },
  },

  // ---- Acute: within 48 hours -----------------------------------------------
  {
    id: "USAB-S01-acute-advice",
    title: "PCRL advises same or next day ultrasound, adviser not named -> Acute: within 48 hours, asks for name and role",
    answers: { ...NONE, "advice.acuteImagingRecommended": true },
    expect: met("ACUTE_48H", "A48", [ADVISER]),
  },
  {
    id: "USAB-S02-acute-advice-named",
    title: "Same, adviser named -> nothing missing",
    answers: { ...NONE, "advice.acuteImagingRecommended": true, [ADVISER]: { v: "Dr A Example, PCRL" } },
    expect: met("ACUTE_48H", "A48"),
  },
  {
    id: "USAB-S03-jaundice-obvious-cause",
    title: "Painless jaundice with an obvious cause, everything else not met -> criteria not met",
    answers: { ...NONE, "symptom.jaundice": true, "redflag.painfulJaundice": false, "workup.jaundiceObviousCause": true },
    expect: met("CRITERIA_NOT_MET", null),
  },
  {
    id: "USAB-S04-jaundice-pain-unknown",
    title: "Jaundice, no obvious cause, pain not stated -> insufficient; asks whether the jaundice is painful",
    answers: { ...NONE, "symptom.jaundice": true, "workup.jaundiceObviousCause": false },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["redflag.painfulJaundice"], redirects: [] },
  },

  // ---- P2 Urgent ------------------------------------------------------------
  {
    id: "USAB-S05-p2-alp-ggt",
    title: "Initial ALP 2.5 x ULN with raised GGT -> P2",
    answers: { ...NONE, "lab.alp.timesULN": 2.5, "lab.alp.high": true, "lab.ggt.raised": true },
    expect: met("P2_URGENT", "P2"),
  },
  {
    id: "USAB-S06-p2-alp-boundary",
    title: "ALP exactly 2 x ULN with raised GGT -> not 'more than 2 times'; criteria not met (REVIEW Q4 boundary)",
    answers: { ...NONE, "lab.alp.timesULN": 2.0, "lab.alp.high": true, "lab.ggt.raised": true },
    expect: met("CRITERIA_NOT_MET", null),
  },
  {
    id: "USAB-S07-p2-ggt-multiple",
    title: "ALP 3 x ULN, GGT stated only as 1.5 x ULN (no flag) -> P2",
    answers: { ...NONE, "lab.alp.timesULN": 3.0, "lab.alp.high": true, "lab.ggt.raised": undefined, "lab.ggt.timesULN": 1.5 },
    expect: met("P2_URGENT", "P2"),
  },
  {
    id: "USAB-S08-p2-settled-biliary-colic",
    title: "Suspected biliary colic, settled with analgesia, raised ALP and GGT, biliary tree never imaged -> P2",
    note: "Synthetic. 45F, RUQ pain after fatty meals last week, settled with paracetamol. ALP and GGT raised. No previous imaging.",
    answers: { ...NONE, "symptom.biliaryColicOrCholecystitis": true, "symptom.settlesWithAnalgesia": true, "lab.alp.high": true, "lab.ggt.raised": true, "imaging.biliaryTree.ever": false },
    expect: met("P2_URGENT", "P2"),
  },
  {
    id: "USAB-S09-p2-biliary-tree-imaged",
    title: "Same, but the biliary tree has been imaged before -> P2 bullet 2 not met; criteria not met",
    answers: { ...NONE, "symptom.biliaryColicOrCholecystitis": true, "symptom.settlesWithAnalgesia": true, "lab.alp.high": true, "lab.ggt.raised": true, "imaging.biliaryTree.ever": true, "symptom.biliaryColicResolved": false },
    expect: met("CRITERIA_NOT_MET", null),
  },
  {
    id: "USAB-S10-p2-advice",
    title: "Secondary care advises urgent ultrasound, adviser not named -> P2, asks for name and role",
    answers: { ...NONE, "advice.urgentImagingRecommended": true },
    expect: met("P2_URGENT", "P2", [ADVISER]),
  },

  // ---- P3 -------------------------------------------------------------------
  {
    id: "USAB-S11-p3-recurrent-pain",
    title: "Recurrent RUQ pain, not dyspepsia, never imaged -> P3",
    answers: { ...NONE, "symptom.recurrentRUQOrEpigastricPain": true, "symptom.dyspepsia": false, "imaging.presentingProblem.ever": false },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S12-dyspepsia-redirect",
    title: "Recurrent epigastric pain that is dyspepsia -> alternative management (Dyspepsia HealthPathway); redirect wins",
    answers: { ...NONE, "symptom.recurrentRUQOrEpigastricPain": true, "symptom.dyspepsia": true, "imaging.presentingProblem.ever": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.dyspepsia], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S13-p3-resolved-biliary-colic",
    title: "Resolved biliary colic, no gallstones shown before, cholecystectomy candidate who would accept -> P3",
    answers: { ...NONE, "symptom.biliaryColicOrCholecystitis": true, "symptom.settlesWithAnalgesia": false, "symptom.biliaryColicResolved": true, "imaging.gallstones.ever": false, "workup.cholecystectomyCandidate": true },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S14-p3-follow-up-alp-ggt",
    title: "Initial ALP 2.4 x ULN with normal GGT; at 3 months ALP and GGT both above ULN -> P3 (the ALP/normal-GGT redirect uses the latest GGT)",
    answers: { ...NONE, "lab.alp.timesULN": 2.4, "lab.alp.high": true, "lab.ggt.raised": false, "lab.repeatAfter3Months": true, "lab.alp.repeatHigh": true, "lab.ggt.repeatRaised": true, "lab.ggt.timesULN": 0.8 },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S15-alp-normal-ggt-redirect",
    title: "ALP raised with normal GGT, not repeated -> alternative management (probably not liver-related)",
    answers: { ...NONE, "lab.alp.timesULN": 2.4, "lab.alp.high": true, "lab.ggt.raised": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.alpNormalGgt], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S16-p3-alt",
    title: "ALT 150 IU/L, diabetic, lifestyle measures unsuccessful, no features of concern -> P3",
    answers: { ...NONE, "lab.alt.value": ALT(150), "patient.liverRiskFactors": true, "workup.conservativeMethodsUnsuccessful": true, "workup.clinicalFeaturesOfConcern": false },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S17-p3-alt-boundary",
    title: "ALT exactly 120 IU/L -> not 'greater than 120'; criteria not met (REVIEW Q10)",
    answers: { ...NONE, "lab.alt.value": ALT(120), "patient.liverRiskFactors": true, "workup.conservativeMethodsUnsuccessful": true, "workup.clinicalFeaturesOfConcern": false },
    expect: met("CRITERIA_NOT_MET", null),
  },
  {
    id: "USAB-S18-p3-isolated-ggt",
    title: "Isolated GGT 6 x ULN, still 5.5 x ULN on re-testing after 3 months -> P3",
    answers: { ...NONE, "lab.isolatedLftAbnormality": true, "lab.ggt.raised": true, "lab.ggt.timesULN": 6.0, "lab.repeatAfter3Months": true, "lab.ggt.repeatTimesULN": 5.5, "lab.alp.repeatHigh": false },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S19-isolated-ggt-under-5-redirect",
    title: "Isolated GGT 3 x ULN -> alternative management (re-test after three months)",
    answers: { ...NONE, "lab.isolatedLftAbnormality": true, "lab.ggt.raised": true, "lab.ggt.timesULN": 3.0 },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.ggtUnder5], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S20-p3-aaa",
    title: "Asymptomatic, newly suspected AAA on examination -> P3",
    answers: { ...NONE, "symptom.aaaNewlySuspected": true, "symptom.aaaAsymptomatic": true },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S21-upper-mass-redirect",
    title: "Upper abdominal non-pulsatile mass, not consistent with hepatomegaly -> alternative management (discuss; CT abdomen may be more appropriate)",
    answers: { ...NONE, "symptom.abdominalMassNonPulsatile": true, "symptom.abdominalMassUpper": true, "symptom.hepatomegalySuspected": false },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.upperMass], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S22-p3-advice",
    title: "Radiologist advises non-urgent ultrasound, named -> P3",
    answers: { ...NONE, "advice.nonUrgentImagingRecommended": true, [ADVISER]: { v: "Dr B Example, radiologist" } },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },

  // ---- S3 -------------------------------------------------------------------
  {
    id: "USAB-S23-s3-hcc",
    title: "HCC surveillance recommended by a gastroenterologist -> specified date (S3)",
    answers: { ...NONE, "advice.hccSurveillance": true },
    expect: met("S3_TIME_SENSITIVE", "S3"),
  },
  {
    id: "USAB-S24-s3-incidental",
    title: "Gallbladder polyp follow-up per the Incidental Findings HealthPathway -> specified date (S3)",
    answers: { ...NONE, "advice.incidentalFindingFollowUp": true },
    expect: met("S3_TIME_SENSITIVE", "S3"),
  },
  {
    id: "USAB-S25-s3-aaa-surveillance",
    title: "Known AAA due for surveillance per HealthPathway -> specified date (S3)",
    answers: { ...NONE, "advice.aaaSurveillance": true },
    expect: met("S3_TIME_SENSITIVE", "S3"),
  },

  // ---- Precedence -----------------------------------------------------------
  {
    id: "USAB-S26-p2-over-p3",
    title: "Both P2 (ALP/GGT) and P3 (AAA) met -> P2 (REVIEW Q17)",
    answers: { ...NONE, "lab.alp.timesULN": 2.5, "lab.alp.high": true, "lab.ggt.raised": true, "symptom.aaaNewlySuspected": true, "symptom.aaaAsymptomatic": true },
    expect: met("P2_URGENT", "P2"),
  },
  {
    id: "USAB-S27-p3-met-higher-unknown",
    title: "P3 met while the acute and P2 rows are unanswered -> P3, nothing asked (REVIEW Q17)",
    answers: { "patient.age": 70, "symptom.aaaNewlySuspected": true, "symptom.aaaAsymptomatic": true },
    expect: met("P3_NON_DEFERRABLE", "P3"),
  },
  {
    id: "USAB-S28-paediatric",
    title: "Age 12 with P2 lab results -> paediatric criteria apply",
    answers: { ...NONE, "patient.age": 12, "lab.alp.timesULN": 2.5, "lab.alp.high": true, "lab.ggt.raised": true },
    expect: met("PAEDIATRIC_CRITERIA_APPLY", null),
  },
  {
    id: "USAB-S29-age-unknown",
    title: "P2 lab results, age not given -> insufficient; asks only for age",
    answers: { ...NONE, "patient.age": undefined, "lab.alp.timesULN": 2.5, "lab.alp.high": true, "lab.ggt.raised": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["patient.age"], redirects: [] },
  },
  {
    id: "USAB-S30-criteria-not-met",
    title: "Every row answered and not met, no redirect -> criteria not met, nothing missing",
    answers: { ...NONE },
    expect: met("CRITERIA_NOT_MET", null),
  },

  // ---- Alternative management -----------------------------------------------
  {
    id: "USAB-S31-several-redirects",
    title: "Raised ferritin, isolated raised bilirubin, colorectal, lymphoedema, chronic pancreatitis and urinary presentations -> six redirects",
    answers: {
      ...NONE,
      "lab.ferritin.raised": true, "lab.bilirubin.raised": true, "lab.isolatedLftAbnormality": true,
      "symptom.colorectalNeoplasmSuspected": true, "symptom.unilateralLymphoedemaNew": true,
      "symptom.chronicPancreatitis": true, "symptom.urinaryTractPresentation": true,
    },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.ferritin, R.bilirubin, R.colorectal, R.lymphoedema, R.pancreatitis, R.urinary], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S32-suspected-malignancy-redirect",
    title: "Unexplained weight loss, fatigue, vague abdominal pain and suspicion of malignancy -> CT CAP HealthPathway",
    answers: { ...NONE, "weightloss.present": true, "symptom.fatigue": true, "symptom.abdominalPain": true, "workup.suspicionMalignancy": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.malignancy], unconfirmedExclusions: [] },
  },
  {
    id: "USAB-S33-malignancy-redirect-incomplete",
    title: "Weight loss, fatigue and pain but suspicion of malignancy not stated -> redirect does not fire (all four required, REVIEW Q19)",
    answers: { ...NONE, "weightloss.present": true, "symptom.fatigue": true, "symptom.abdominalPain": true },
    expect: met("CRITERIA_NOT_MET", null),
  },
  {
    id: "USAB-S34-bloating-with-symptoms",
    title: "Isolated bloating with features of concern -> alternative management (seek specialist advice)",
    answers: { ...NONE, "symptom.isolatedBloating": true, "workup.clinicalFeaturesOfConcern": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: [R.bloating], unconfirmedExclusions: [] },
  },

  // ---- Not routinely funded -------------------------------------------------
  {
    id: "USAB-S35-nf-bloating",
    title: "Isolated bloating with no other features of concern -> not routinely funded",
    answers: { ...NONE, "symptom.isolatedBloating": true, "workup.clinicalFeaturesOfConcern": false },
    expect: met("NOT_ROUTINELY_FUNDED", null),
  },
  {
    id: "USAB-S36-nf-screening-fatty-liver",
    title: "Request is screening for fatty liver -> not routinely funded",
    answers: { "patient.age": 55, "funding.screeningFattyLiver": true },
    expect: met("NOT_ROUTINELY_FUNDED", null),
  },
  {
    id: "USAB-S37-nf-over-redirect",
    title: "Hernia request that also mentions dyspepsia -> not routinely funded outranks the redirect (REVIEW Q17); the redirect is still listed",
    answers: { ...NONE, "funding.hernia": true, "symptom.dyspepsia": true },
    expect: { ...met("NOT_ROUTINELY_FUNDED", null), redirects: [R.dyspepsia] },
  },
  {
    id: "USAB-S38-nf-gallstone-follow-up",
    title: "Follow-up of known gallstones in an asymptomatic patient -> not routinely funded",
    answers: { "patient.age": 60, "funding.gallstonesFollowUpAsymptomatic": true },
    expect: met("NOT_ROUTINELY_FUNDED", null),
  },

  // ---- Documentation standard ----------------------------------------------
  {
    id: "USAB-S39-strict-inferred",
    title: "ALP/GGT pathway where the GGT flag is inferred: strict -> insufficient, GGT asked for and surfaced as inferred",
    note: "Synthetic. 52M, RUQ discomfort. ALP 2.5x ULN, GGT 95.",
    answers: { ...NONE, "lab.alp.timesULN": doc(2.5, "ALP 2.5x ULN"), "lab.alp.high": doc(true, "ALP 2.5x ULN"), "lab.ggt.raised": inf(true, "GGT 95") },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["lab.ggt.raised"], redirects: [], inferredExcluded: ["lab.ggt.raised"] },
  },
  {
    id: "USAB-S40-inferred-standard",
    title: "Same under documentation standard 'inferred' -> P2",
    note: "Synthetic. 52M, RUQ discomfort. ALP 2.5x ULN, GGT 95.",
    answers: { ...NONE, "lab.alp.timesULN": doc(2.5, "ALP 2.5x ULN"), "lab.alp.high": doc(true, "ALP 2.5x ULN"), "lab.ggt.raised": inf(true, "GGT 95") },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...met("P2_URGENT", "P2"), inferredExcluded: [] },
  },
];

function answerFor(a) {
  const raw = a !== null && typeof a === "object" && ("v" in a || "q" in a) ? a : { v: a };
  const ans = "q" in raw ? { valueQuantity: { value: raw.q, unit: raw.unit, system: "http://unitsofmeasure.org", code: raw.code } }
    : typeof raw.v === "boolean" ? { valueBoolean: raw.v }
    : typeof raw.v === "number" ? (Number.isInteger(raw.v) && raw.decimal !== true ? { valueInteger: raw.v } : { valueDecimal: raw.v })
    : typeof raw.v === "string" && raw.v.includes(" ") ? { valueString: raw.v }
    : { valueCoding: { code: raw.v } };
  if (raw.status) {
    ans.extension = [{ url: EVIDENCE_URL, extension: [
      { url: "status", valueCode: raw.status },
      ...(raw.quote ? [{ url: "quote", valueString: raw.quote }] : []),
    ] }];
  }
  return ans;
}

// Decimal-typed indicators: a whole number (e.g. 3) must still go out as valueDecimal.
const DECIMAL_LINK_IDS = new Set(["lab.alp.timesULN", "lab.ggt.timesULN", "lab.ggt.repeatTimesULN"]);

export function toQuestionnaireResponse(s) {
  const groups = {};
  for (const [linkId, a] of Object.entries(s.answers)) {
    if (a === undefined) continue; // `undefined` removes a NONE answer
    const raw = a !== null && typeof a === "object" && ("v" in a || "q" in a) ? { ...a } : { v: a };
    if (DECIMAL_LINK_IDS.has(linkId)) raw.decimal = true;
    (groups[linkId.split(".")[0]] ||= []).push({ linkId, answer: [answerFor(raw)] });
  }
  return {
    resourceType: "QuestionnaireResponse",
    id: "qr-" + s.id,
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-US-Abdomen-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
