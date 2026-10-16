// Test scenarios for CRR_XRChest_Adult (X-ray Chest - Adult, National criteria v2.0 pp.62-65).
// Order: the results-matrix cases for this site first (LP-001, CR-001 - real evaluator notes,
// no patient-identifiable data), then coverage of every pathway, tier, redirect, not-funded
// item, boundary and precedence rule. Synthetic notes only.
//
// NONE is the baseline "every indicator answered and nothing present": it lets a scenario
// switch on one pathway and still reach a definite answer (otherwise unknown indicators
// keep the result at INSUFFICIENT_INFORMATION, by design).

const EVIDENCE_URL = "http://crr.health.nz/fhir/StructureDefinition/answer-evidence";

const BOOLEANS = [
  "symptom.suspectedCommunityAcquiredPneumonia", "symptom.pneumoniaSevereOrAtypicalPresentation", "symptom.atRiskOfUnderlyingLungPathology",
  "symptom.respiratoryTractInfection", "symptom.possibleLeftVentricularFailure",
  "symptom.dyspnoeaUnexplainedNewOrWorsening", "symptom.coughUnexplained", "symptom.coughWorsening",
  "symptom.chestOrShoulderPainUnexplained", "symptom.chronicRespiratoryCondition", "symptom.chronicRespiratorySymptomChangeUnexplained",
  "symptom.hoarsenessUnexplained", "symptom.chestInfectionsRepeatedOrUnresolved",
  "redflag.haemoptysisPresent", "symptom.haemoptysisPersistentUnexplained",
  "weightloss.present", "symptom.appetiteLoss",
  "symptom.abnormalChestSignsUnexplained", "imaging.abnormalChestSigns.ever",
  "symptom.supraclavicularLymphadenopathyNew", "symptom.cervicalLymphadenopathyNew", "symptom.otherLungCancerFeatures",
  "symptom.paraneoplasticFeatures", "symptom.subacuteDyspnoeaUnknownCause",
  "symptom.lowerRespiratoryTractInfection", "symptom.noResponseAfter48hAntibiotics", "symptom.suspectedSmallPneumothorax",
  "advice.acuteImagingRecommended", "advice.urgentImagingRecommended", "advice.nonUrgentImagingRecommended", "advice.followUpImagingRecommended",
  "symptom.suspectedTuberculosis", "symptom.suspectedDrugInducedLungDisease", "symptom.newRespiratorySymptoms", "symptom.takingPneumotoxicMedication",
  "symptom.unprovokedDvtOrPe", "symptom.polymyalgiaRheumatica", "symptom.pmrSteroidsStarted",
  "symptom.asthmaNonAcute", "symptom.asthmaDiagnosisUnclear", "symptom.asthmaPoorControl", "symptom.asthmaFrequentExacerbations",
  "symptom.chronicDyspnoea", "symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment", "symptom.asbestosExposureHistory", "imaging.cxr.ever",
  "imaging.followUpAfterChestInfection", "symptom.ongoingSymptomsOrSignsAfterChestInfection",
  "imaging.radiologistSuspiciousFeaturesFollowUpRecommended", "advice.followUpImagingRecommendedBySpecialist",
  "imaging.postCancerSurveillance", "imaging.noduleFollowUp",
  "symptom.respiratorySymptomsOngoingUnexplained", "imaging.cxrNegative.ever",
  "funding.asbestosSurveillance", "funding.heartMurmurIndication", "symptom.heartMurmurComplicationSigns", "funding.lungCancerScreening",
  "funding.tbScreening", "lab.tbSkinOrBloodTestPositive", "funding.ribViews", "funding.immigrationPurposes",
  "funding.routineHypertensionInvestigation", "funding.routineMonitoringPneumotoxicMedication",
];
const DECIMALS = [
  "symptom.coughDurationWeeks", "symptom.chronicRespiratorySymptomChangeDurationWeeks", "symptom.hoarsenessDurationWeeks",
  "weightloss.periodMonths", "symptom.appetiteLossDurationWeeks", "symptom.abnormalChestSignsDurationWeeks",
  "symptom.cervicalLymphadenopathyDurationWeeks", "symptom.cervicalLymphNodeDiameterCm",
];
const NONE = Object.fromEntries([["patient.age", 50], ...BOOLEANS.map((id) => [id, false]), ...DECIMALS.map((id) => [id, 0])]);
const omit = (o, ids) => Object.fromEntries(Object.entries(o).filter(([k]) => !ids.includes(k)));
const ADVISER = { "advice.adviserNameRole": "Dr A Example, respiratory physician" };

const AM_REDIRECTS = [
  "Seek secondary care specialist assessment",
  "See the local Lung Cancer HealthPathway",
  "See the local CT Chest, Abdomen and Pelvis HealthPathway",
];
const UNCONFIRMED_AM = ["symptom.respiratorySymptomsOngoingUnexplained", "imaging.cxrNegative.ever"];
const met = (determination, priorityCode) => ({ determination, priorityCode, missing: [], redirects: [], unconfirmedExclusions: [] });
const A24 = met("ACUTE_24H", "A24");
const A48 = met("ACUTE_48H", "A48");
const P2 = met("P2_URGENT", "P2");
const P3 = met("P3_NON_DEFERRABLE", "P3");
const S2 = met("S2_TIME_SENSITIVE", "S2");
const NOT_MET = met("CRITERIA_NOT_MET", null);
const NF = met("NOT_ROUTINELY_FUNDED", null);

const LP001_NOTE = "55 yo man, 3 days cough, fever and shortness of breath";
const LP001 = {
  "patient.age": { v: 55, status: "documented", quote: "55 yo man" },
  "symptom.suspectedCommunityAcquiredPneumonia": { v: true, status: "inferred", quote: "3 days cough, fever and shortness of breath" },
  "symptom.respiratoryTractInfection": { v: true, status: "inferred", quote: "3 days cough, fever and shortness of breath" },
};
const PTX_NOTE = "29M tall, sudden pleuritic pain, ?ptx, comfortable at rest, sats normal.";
const CR001_NOTE = "42 yr old homeless patient with fever productive cough, smoker, unsure re wt loss .Fine lower basal crepitus , mild tachy ,";
const CR001 = {
  "patient.age": { v: 42, status: "documented", quote: "42 yr old" },
  "symptom.suspectedCommunityAcquiredPneumonia": { v: true, status: "inferred", quote: "fever productive cough" },
  "symptom.respiratoryTractInfection": { v: true, status: "inferred", quote: "fever productive cough" },
  "symptom.atRiskOfUnderlyingLungPathology": { v: true, status: "inferred", quote: "smoker" },
};

export const scenarios = [
  // ── Results-matrix cases (documents/CRR_Test_Case_Results_Matrix_v2.xlsx) ──
  {
    id: "XRC-S01-matrix-LP-001-strict",
    title: "LP-001 (legacy: Proceeds, acute CAP): suspected CAP only inferable, nothing documented - insufficient under strict",
    note: LP001_NOTE,
    answers: LP001,
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [],
      inferredExcluded: ["symptom.suspectedCommunityAcquiredPneumonia", "symptom.respiratoryTractInfection"] },
  },
  {
    id: "XRC-S02-matrix-LP-001-inferred",
    title: "LP-001 under 'inferred': CAP and RTI pathways started; asks for severity/risk and LVF",
    note: LP001_NOTE,
    answers: LP001,
    runWith: { "Documentation Standard": "inferred" },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, inferredExcluded: [],
      missing: ["symptom.pneumoniaSevereOrAtypicalPresentation", "symptom.atRiskOfUnderlyingLungPathology", "symptom.possibleLeftVentricularFailure"] },
  },
  {
    id: "XRC-S03-matrix-CR-001-strict",
    title: "CR-001 (legacy: Proceeds): CAP and smoking risk are inferences - insufficient under strict",
    note: CR001_NOTE,
    answers: CR001,
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null,
      inferredExcluded: ["symptom.suspectedCommunityAcquiredPneumonia", "symptom.respiratoryTractInfection", "symptom.atRiskOfUnderlyingLungPathology"] },
  },
  {
    id: "XRC-S04-matrix-CR-001-inferred",
    title: "CR-001 under 'inferred': suspected CAP in a patient at risk of lung pathology - Acute 24h",
    note: CR001_NOTE,
    answers: CR001,
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...A24, unconfirmedExclusions: UNCONFIRMED_AM, inferredExcluded: [] },
  },

  // ── Acute: Within 24 hours ──
  {
    id: "XRC-S05-a24-cap-severe",
    title: "Suspected CAP with unexpectedly severe presentation, documented - Acute 24h",
    note: "64M. Suspected CAP, unexpectedly unwell for the degree of consolidation signs.",
    answers: { "patient.age": 64, "symptom.suspectedCommunityAcquiredPneumonia": true, "symptom.pneumoniaSevereOrAtypicalPresentation": true },
    expect: { ...A24, unconfirmedExclusions: UNCONFIRMED_AM },
  },
  {
    id: "XRC-S06-a24-cap-neither",
    title: "Suspected CAP, typical presentation, not at risk; everything else absent - criteria not met",
    answers: { ...NONE, "symptom.suspectedCommunityAcquiredPneumonia": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S07-a24-rti-lvf",
    title: "Respiratory tract infection with possible LVF - Acute 24h",
    answers: { ...NONE, "symptom.respiratoryTractInfection": true, "symptom.possibleLeftVentricularFailure": true },
    expect: A24,
  },
  {
    id: "XRC-S08-a24-started-missing",
    title: "Suspected CAP only, rest unknown: asks for severity / risk (started pathway only)",
    answers: { "patient.age": 70, "symptom.suspectedCommunityAcquiredPneumonia": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", missing: ["symptom.pneumoniaSevereOrAtypicalPresentation", "symptom.atRiskOfUnderlyingLungPathology"] },
  },

  // ── Acute: Within 48 hours ──
  {
    id: "XRC-S09-lc01-dyspnoea",
    title: "LC-01 unexplained, new or worsening dyspnoea - Acute 48h",
    answers: { ...NONE, "symptom.dyspnoeaUnexplainedNewOrWorsening": true },
    expect: A48,
  },
  {
    id: "XRC-S10-lc02-cough-boundary",
    title: "LC-02 boundary: unexplained worsening cough of exactly 3 weeks - not met",
    answers: { ...NONE, "symptom.coughUnexplained": true, "symptom.coughWorsening": true, "symptom.coughDurationWeeks": 3 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S11-lc02-cough-met",
    title: "LC-02: unexplained worsening cough of 4 weeks - Acute 48h",
    note: "58F smoker. Cough 4/52, worsening, no cause found.",
    answers: { ...NONE, "symptom.coughUnexplained": true, "symptom.coughWorsening": true, "symptom.coughDurationWeeks": 4 },
    expect: A48,
  },
  {
    id: "XRC-S12-lc03-chest-shoulder-pain",
    title: "LC-03 unexplained chest and/or shoulder pain - Acute 48h",
    answers: { ...NONE, "symptom.chestOrShoulderPainUnexplained": true },
    expect: A48,
  },
  {
    id: "XRC-S13-lc04-chronic-change",
    title: "LC-04 COPD patient, unexplained change in usual symptoms for 5 weeks - Acute 48h",
    answers: { ...NONE, "symptom.chronicRespiratoryCondition": true, "symptom.chronicRespiratorySymptomChangeUnexplained": true, "symptom.chronicRespiratorySymptomChangeDurationWeeks": 5 },
    expect: A48,
  },
  {
    id: "XRC-S14-lc05-hoarseness",
    title: "LC-05 unexplained hoarseness 6 weeks - Acute 48h",
    answers: { ...NONE, "symptom.hoarsenessUnexplained": true, "symptom.hoarsenessDurationWeeks": 6 },
    expect: A48,
  },
  {
    id: "XRC-S15-lc06-recurrent-infections",
    title: "LC-06 recurrent chest infections - Acute 48h",
    answers: { ...NONE, "symptom.chestInfectionsRepeatedOrUnresolved": true },
    expect: A48,
  },
  {
    id: "XRC-S16-lc07-haemoptysis",
    title: "LC-07 persistent unexplained haemoptysis (no red-flag qualifiers) - Acute 48h",
    answers: { ...NONE, "redflag.haemoptysisPresent": true, "symptom.haemoptysisPersistentUnexplained": true },
    expect: A48,
  },
  {
    id: "XRC-S17-lc08-weight-appetite",
    title: "LC-08 weight loss over 1 month and appetite loss 4 weeks - Acute 48h",
    answers: { ...NONE, "weightloss.present": true, "weightloss.periodMonths": 1, "symptom.appetiteLoss": true, "symptom.appetiteLossDurationWeeks": 4 },
    expect: A48,
  },
  {
    id: "XRC-S18-lc08-weight-too-short",
    title: "LC-08 boundary: weight loss over 0.5 month (about 15 days) - not met",
    answers: { ...NONE, "weightloss.present": true, "weightloss.periodMonths": 0.5, "symptom.appetiteLoss": true, "symptom.appetiteLossDurationWeeks": 4 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S19-lc09-chest-signs-imaged",
    title: "LC-09: unexplained chest signs 4 weeks but already imaged - not met",
    answers: { ...NONE, "symptom.abnormalChestSignsUnexplained": true, "symptom.abnormalChestSignsDurationWeeks": 4, "imaging.abnormalChestSigns.ever": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S20-lc09-chest-signs-not-imaged",
    title: "LC-09: unexplained chest signs 4 weeks, not yet imaged - Acute 48h",
    answers: { ...NONE, "symptom.abnormalChestSignsUnexplained": true, "symptom.abnormalChestSignsDurationWeeks": 4 },
    expect: A48,
  },
  {
    id: "XRC-S21-lc10-supraclavicular",
    title: "LC-10 new supraclavicular lymphadenopathy - Acute 48h",
    answers: { ...NONE, "symptom.supraclavicularLymphadenopathyNew": true },
    expect: A48,
  },
  {
    id: "XRC-S22-lc11-node-boundary",
    title: "LC-11 boundary: new cervical node of exactly 1 cm, 4 weeks, other features - not met",
    answers: { ...NONE, "symptom.cervicalLymphadenopathyNew": true, "symptom.cervicalLymphadenopathyDurationWeeks": 4, "symptom.cervicalLymphNodeDiameterCm": 1, "symptom.otherLungCancerFeatures": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S23-lc11-node-met",
    title: "LC-11 new cervical node 1.5 cm, 4 weeks, other features - Acute 48h",
    answers: { ...NONE, "symptom.cervicalLymphadenopathyNew": true, "symptom.cervicalLymphadenopathyDurationWeeks": 4, "symptom.cervicalLymphNodeDiameterCm": 1.5, "symptom.otherLungCancerFeatures": true },
    expect: A48,
  },
  {
    id: "XRC-S24-lc12-paraneoplastic",
    title: "LC-12 features suggestive of a paraneoplastic syndrome - Acute 48h",
    answers: { ...NONE, "symptom.paraneoplasticFeatures": true },
    expect: A48,
  },
  {
    id: "XRC-S25-a48-subacute-dyspnoea",
    title: "Subacute dyspnoea of unknown cause - Acute 48h",
    answers: { ...NONE, "symptom.subacuteDyspnoeaUnknownCause": true },
    expect: A48,
  },
  {
    id: "XRC-S26-a48-lrti-not-responding",
    title: "LRTI not responding after 48 hours of antibiotics - Acute 48h",
    answers: { ...NONE, "symptom.lowerRespiratoryTractInfection": true, "symptom.noResponseAfter48hAntibiotics": true },
    expect: A48,
  },
  {
    id: "XRC-S27-a48-small-pneumothorax",
    title: "Suspected small pneumothorax - Acute 48h",
    answers: { ...NONE, "symptom.suspectedSmallPneumothorax": true },
    expect: A48,
  },
  {
    id: "XRC-S28-a48-advice-no-name",
    title: "PCRL advises acute x-ray, adviser not named - Acute 48h, asks for name and role",
    answers: { ...NONE, "advice.acuteImagingRecommended": true },
    expect: { ...A48, missing: ["advice.adviserNameRole"] },
  },

  // ── P2 Urgent ──
  {
    id: "XRC-S29-p2-tb",
    title: "Suspected tuberculosis - P2",
    answers: { ...NONE, "symptom.suspectedTuberculosis": true },
    expect: P2,
  },
  {
    id: "XRC-S30-p2-dild",
    title: "New respiratory symptoms on amiodarone, suspected drug induced lung disease - P2",
    answers: { ...NONE, "symptom.suspectedDrugInducedLungDisease": true, "symptom.newRespiratorySymptoms": true, "symptom.takingPneumotoxicMedication": true },
    expect: P2,
  },
  {
    id: "XRC-S31-p2-unprovoked-pe",
    title: "Unprovoked PE - P2",
    answers: { ...NONE, "symptom.unprovokedDvtOrPe": true },
    expect: P2,
  },
  {
    id: "XRC-S32-p2-pmr-before-steroids",
    title: "PMR, steroids not yet started - P2",
    answers: { ...NONE, "symptom.polymyalgiaRheumatica": true },
    expect: P2,
  },
  {
    id: "XRC-S33-p2-pmr-on-steroids",
    title: "PMR, steroids already started - not met (REVIEW Q12)",
    answers: { ...NONE, "symptom.polymyalgiaRheumatica": true, "symptom.pmrSteroidsStarted": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S34-p2-advice-named",
    title: "Respiratory physician advises urgent x-ray, named - P2, nothing missing",
    answers: { ...NONE, ...ADVISER, "advice.urgentImagingRecommended": true },
    expect: P2,
  },

  // ── P3 ──
  {
    id: "XRC-S35-p3-asthma-poor-control",
    title: "Non-acute asthma with poor control - P3",
    answers: { ...NONE, "symptom.asthmaNonAcute": true, "symptom.asthmaPoorControl": true },
    expect: P3,
  },
  {
    id: "XRC-S36-p3-asthma-well-controlled",
    title: "Non-acute asthma, clear diagnosis, good control, infrequent exacerbations - not met",
    answers: { ...NONE, "symptom.asthmaNonAcute": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S37-p3-chronic-cough",
    title: "Cough 9 weeks, explained and not worsening - P3 (chronic cough), not Acute 48h",
    answers: { ...NONE, "symptom.coughDurationWeeks": 9 },
    expect: P3,
  },
  {
    id: "XRC-S38-p3-chronic-cough-boundary",
    title: "Cough exactly 8 weeks, explained - not met",
    answers: { ...NONE, "symptom.coughDurationWeeks": 8 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S39-p3-chronic-dyspnoea",
    title: "Chronic dyspnoea - P3",
    answers: { ...NONE, "symptom.chronicDyspnoea": true },
    expect: P3,
  },
  {
    id: "XRC-S40-p3-cardiorespiratory",
    title: "Known COPD unresponsive to treatment - P3",
    answers: { ...NONE, "symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment": true },
    expect: P3,
  },
  {
    id: "XRC-S41-p3-asbestos-no-cxr",
    title: "Asbestos exposure, never had a chest X-ray - P3",
    answers: { ...NONE, "symptom.asbestosExposureHistory": true },
    expect: P3,
  },
  {
    id: "XRC-S42-p3-asbestos-prior-cxr",
    title: "Asbestos exposure, previous chest X-ray - not met",
    answers: { ...NONE, "symptom.asbestosExposureHistory": true, "imaging.cxr.ever": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S43-p3-advice-named",
    title: "Radiologist advises non-urgent x-ray, named - P3",
    answers: { ...NONE, ...ADVISER, "advice.nonUrgentImagingRecommended": true },
    expect: P3,
  },

  // ── S2 ──
  {
    id: "XRC-S44-s2-post-infection-symptoms",
    title: "6-week follow-up after chest infection with ongoing symptoms - S2",
    answers: { ...NONE, "imaging.followUpAfterChestInfection": true, "symptom.ongoingSymptomsOrSignsAfterChestInfection": true },
    expect: S2,
  },
  {
    id: "XRC-S45-s2-post-infection-radiologist",
    title: "Follow-up after chest infection, radiologist noted suspicious features and recommended follow up - S2",
    answers: { ...NONE, "imaging.followUpAfterChestInfection": true, "imaging.radiologistSuspiciousFeaturesFollowUpRecommended": true },
    expect: S2,
  },
  {
    id: "XRC-S46-s2-post-infection-none",
    title: "Routine pneumonia follow-up with none of the S2 conditions - not routinely funded",
    answers: { ...NONE, "imaging.followUpAfterChestInfection": true },
    expect: NF,
  },
  {
    id: "XRC-S47-s2-post-infection-unknown",
    title: "Follow-up after chest infection, sub-conditions unknown - insufficient, asks for the three",
    answers: { "patient.age": 60, "imaging.followUpAfterChestInfection": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", missing: ["symptom.ongoingSymptomsOrSignsAfterChestInfection", "imaging.radiologistSuspiciousFeaturesFollowUpRecommended", "advice.followUpImagingRecommendedBySpecialist"] },
  },
  {
    id: "XRC-S48-s2-post-cancer",
    title: "Post-cancer surveillance with documented specialist recommendation - S2",
    answers: { ...NONE, "imaging.postCancerSurveillance": true, "advice.followUpImagingRecommendedBySpecialist": true },
    expect: S2,
  },
  {
    id: "XRC-S49-s2-nodule-recommended",
    title: "Nodule follow-up recommended by radiologist - S2",
    answers: { ...NONE, "imaging.noduleFollowUp": true, "advice.followUpImagingRecommendedBySpecialist": true },
    expect: S2,
  },
  {
    id: "XRC-S50-nf-nodule-not-recommended",
    title: "Nodule follow-up without a specialist or radiologist recommendation - not routinely funded",
    answers: { ...NONE, "imaging.noduleFollowUp": true },
    expect: NF,
  },
  {
    id: "XRC-S51-s2-advice-no-name",
    title: "PCRL advises follow-up x-ray, adviser not named - S2, asks for name and role",
    answers: { ...NONE, "advice.followUpImagingRecommended": true },
    expect: { ...S2, missing: ["advice.adviserNameRole"] },
  },

  // ── Tier precedence ──
  {
    id: "XRC-S52-precedence-a24-over-p3",
    title: "Acute 24h and P3 both met - Acute 24h (REVIEW Q1)",
    answers: { ...NONE, "symptom.respiratoryTractInfection": true, "symptom.possibleLeftVentricularFailure": true, "symptom.chronicDyspnoea": true },
    expect: A24,
  },
  {
    id: "XRC-S53-precedence-p2-with-unknown-acute",
    title: "P2 met, Acute rows unknown - P2 returned (REVIEW Q2)",
    answers: { "patient.age": 66, "symptom.unprovokedDvtOrPe": true },
    expect: { determination: "P2_URGENT", priorityCode: "P2", missing: [] },
  },

  // ── Alternative management ──
  {
    id: "XRC-S54-am-negative-cxr",
    title: "Ongoing unexplained symptoms after a negative CXR - alternative management, three redirects",
    answers: { ...NONE, "symptom.respiratorySymptomsOngoingUnexplained": true, "imaging.cxrNegative.ever": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", priorityCode: null, missing: [], redirects: AM_REDIRECTS, unconfirmedExclusions: [] },
  },
  {
    id: "XRC-S55-am-over-a48",
    title: "Unexplained worsening cough 5 weeks after a negative CXR - redirect wins over Acute 48h (REVIEW Q3)",
    answers: { ...NONE, "symptom.coughUnexplained": true, "symptom.coughWorsening": true, "symptom.coughDurationWeeks": 5,
      "symptom.respiratorySymptomsOngoingUnexplained": true, "imaging.cxrNegative.ever": true },
    expect: { determination: "ALTERNATIVE_MANAGEMENT", redirects: AM_REDIRECTS },
  },
  {
    id: "XRC-S56-am-unconfirmed",
    title: "P2 met, redirect components unknown - P2 with unconfirmed exclusions surfaced",
    answers: { "patient.age": 48, "symptom.suspectedTuberculosis": true },
    expect: { determination: "P2_URGENT", missing: [], redirects: [], unconfirmedExclusions: UNCONFIRMED_AM },
  },

  // ── Not routinely funded ──
  {
    id: "XRC-S57-nf-immigration",
    title: "Chest X-ray for immigration purposes - not routinely funded",
    answers: { ...NONE, "funding.immigrationPurposes": true },
    expect: NF,
  },
  {
    id: "XRC-S58-nf-tb-screening",
    title: "TB screening, no positive skin or blood test - not routinely funded",
    answers: { ...NONE, "funding.tbScreening": true },
    expect: NF,
  },
  {
    id: "XRC-S59-tb-screening-positive-test",
    title: "TB screening after a positive IGRA, TB suspected - P2 (not-funded exception applies)",
    answers: { ...NONE, "funding.tbScreening": true, "lab.tbSkinOrBloodTestPositive": true, "symptom.suspectedTuberculosis": true },
    expect: P2,
  },
  {
    id: "XRC-S60-nf-heart-murmur",
    title: "CXR requested for a heart murmur, no signs of complications - not routinely funded",
    answers: { ...NONE, "funding.heartMurmurIndication": true },
    expect: NF,
  },
  {
    id: "XRC-S61-heart-murmur-with-complications",
    title: "Heart murmur with signs of complications, nothing else - criteria not met (exception lifts not-funded only)",
    answers: { ...NONE, "funding.heartMurmurIndication": true, "symptom.heartMurmurComplicationSigns": true },
    expect: NOT_MET,
  },
  {
    id: "XRC-S62-nf-lung-cancer-screening",
    title: "Lung cancer screening - not routinely funded",
    answers: { ...NONE, "funding.lungCancerScreening": true },
    expect: NF,
  },
  {
    id: "XRC-S63-nf-rib-views",
    title: "Rib views - not routinely funded",
    answers: { ...NONE, "funding.ribViews": true },
    expect: NF,
  },
  {
    id: "XRC-S64-nf-hypertension",
    title: "Routine investigation of hypertension - not routinely funded",
    answers: { ...NONE, "funding.routineHypertensionInvestigation": true },
    expect: NF,
  },
  {
    id: "XRC-S65-nf-drug-monitoring",
    title: "Routine monitoring on methotrexate, asymptomatic - not routinely funded",
    answers: { ...NONE, "funding.routineMonitoringPneumotoxicMedication": true, "symptom.takingPneumotoxicMedication": true },
    expect: NF,
  },
  {
    id: "XRC-S66-p3-over-nf-asbestos",
    title: "Asbestos surveillance request in a patient never X-rayed - the met P3 row wins over not funded (REVIEW Q3, Q19)",
    answers: { ...NONE, "funding.asbestosSurveillance": true, "symptom.asbestosExposureHistory": true },
    expect: P3,
  },

  // ── Age, empty, inferred ──
  {
    id: "XRC-S67-paediatric",
    title: "Age 12 with suspected small pneumothorax - paediatric criteria apply",
    answers: { "patient.age": 12, "symptom.suspectedSmallPneumothorax": true },
    expect: { determination: "PAEDIATRIC_CRITERIA_APPLY", priorityCode: null, missing: [] },
  },
  {
    id: "XRC-S68-age-unknown",
    title: "Criterion met but age unknown - insufficient, asks for age only",
    answers: { "symptom.suspectedSmallPneumothorax": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", missing: ["patient.age"] },
  },
  {
    id: "XRC-S69-empty",
    title: "No answers at all - insufficient information",
    answers: {},
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, redirects: [] },
  },
  {
    id: "XRC-S70-inferred-small-pneumothorax-strict",
    title: "Small pneumothorax only inferred, everything else absent, strict - insufficient (not 'criteria not met')",
    note: PTX_NOTE,
    answers: { ...NONE, "symptom.suspectedSmallPneumothorax": { v: true, status: "inferred", quote: "sudden pleuritic pain, ?ptx" } },
    expect: { determination: "INSUFFICIENT_INFORMATION", missing: ["symptom.suspectedSmallPneumothorax"], inferredExcluded: ["symptom.suspectedSmallPneumothorax"] },
  },
  {
    id: "XRC-S71-inferred-small-pneumothorax-inferred",
    title: "Same answers under 'inferred' - Acute 48h",
    note: PTX_NOTE,
    answers: { ...NONE, "symptom.suspectedSmallPneumothorax": { v: true, status: "inferred", quote: "sudden pleuritic pain, ?ptx" } },
    runWith: { "Documentation Standard": "inferred" },
    expect: { ...A48, inferredExcluded: [] },
  },

  // ── Not-funded precedence (coordinator rule R1, REVIEW Q3) ──
  {
    id: "XRC-S72-r1-nf-with-row-met",
    title: "Immigration CXR, but suspected TB documented - the met P2 row wins over not funded",
    answers: { ...NONE, "funding.immigrationPurposes": true, "symptom.suspectedTuberculosis": true },
    expect: P2,
  },
  {
    id: "XRC-S73-r1-nf-with-row-undetermined",
    title: "Immigration CXR, the cough pathway started and undetermined - insufficient, asks for the cough atoms",
    answers: { ...omit(NONE, ["symptom.coughWorsening", "symptom.coughDurationWeeks"]), "funding.immigrationPurposes": true, "symptom.coughUnexplained": true },
    expect: { determination: "INSUFFICIENT_INFORMATION", priorityCode: null, missing: ["symptom.coughWorsening", "symptom.coughDurationWeeks"] },
  },
  {
    id: "XRC-S74-r1-nf-all-rows-false",
    title: "Rib views requested, every timeframe row definitively not met - not routinely funded",
    answers: { ...NONE, "funding.ribViews": true },
    expect: NF,
  },

  // ── Exactly-at-threshold boundaries (REVIEW Q7: strictly greater) ──
  {
    id: "XRC-S75-lc04-boundary",
    title: "LC-04 boundary: unexplained change in chronic respiratory symptoms for exactly 3 weeks - not met",
    answers: { ...NONE, "symptom.chronicRespiratoryCondition": true, "symptom.chronicRespiratorySymptomChangeUnexplained": true, "symptom.chronicRespiratorySymptomChangeDurationWeeks": 3 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S76-lc05-boundary",
    title: "LC-05 boundary: unexplained hoarseness for exactly 3 weeks - not met",
    answers: { ...NONE, "symptom.hoarsenessUnexplained": true, "symptom.hoarsenessDurationWeeks": 3 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S77-lc08-appetite-boundary",
    title: "LC-08 boundary: weight loss over 1 month, appetite loss exactly 3 weeks - not met",
    answers: { ...NONE, "weightloss.present": true, "weightloss.periodMonths": 1, "symptom.appetiteLoss": true, "symptom.appetiteLossDurationWeeks": 3 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S78-lc08-weight-below-21-days",
    title: "LC-08 boundary: weight loss over 0.68 month (about 20.7 days, just under 21) - not met",
    answers: { ...NONE, "weightloss.present": true, "weightloss.periodMonths": 0.68, "symptom.appetiteLoss": true, "symptom.appetiteLossDurationWeeks": 4 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S79-lc08-weight-above-21-days",
    title: "LC-08 boundary: weight loss over 0.70 month (about 21.3 days, just over 21) - Acute 48h",
    answers: { ...NONE, "weightloss.present": true, "weightloss.periodMonths": 0.7, "symptom.appetiteLoss": true, "symptom.appetiteLossDurationWeeks": 4 },
    expect: A48,
  },
  {
    id: "XRC-S80-lc09-boundary",
    title: "LC-09 boundary: unexplained chest signs for exactly 3 weeks, not imaged - not met",
    answers: { ...NONE, "symptom.abnormalChestSignsUnexplained": true, "symptom.abnormalChestSignsDurationWeeks": 3 },
    expect: NOT_MET,
  },
  {
    id: "XRC-S81-lc11-duration-boundary",
    title: "LC-11 boundary: new cervical node 1.5 cm for exactly 3 weeks, other features - not met",
    answers: { ...NONE, "symptom.cervicalLymphadenopathyNew": true, "symptom.cervicalLymphadenopathyDurationWeeks": 3, "symptom.cervicalLymphNodeDiameterCm": 1.5, "symptom.otherLungCancerFeatures": true },
    expect: NOT_MET,
  },
];

function answerFor(linkId, a) {
  const raw = a !== null && typeof a === "object" && "v" in a ? a : { v: a };
  const v = raw.v;
  let ans;
  if (typeof v === "boolean") ans = { valueBoolean: v };
  else if (linkId === "patient.age") ans = { valueInteger: v };
  else if (typeof v === "number") ans = { valueDecimal: v };
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
    questionnaire: "http://crr.health.nz/fhir/Questionnaire/CRR-XRay-Chest-Adult",
    status: "completed",
    subject: { reference: "Patient/" + s.id },
    authored: "2026-10-15",
    item: Object.entries(groups).map(([g, items]) => ({ linkId: g, item: items })),
  };
}
