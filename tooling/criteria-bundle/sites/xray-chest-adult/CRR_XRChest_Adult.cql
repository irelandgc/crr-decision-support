/*
  CRR National Community Referral Criteria for Imaging (Part I)
  X-ray Chest - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    Section:    X-ray Chest - Adult, pages 62-65
    File:       documents/reference/National Primary Care Referral Criteria for Imaging.pdf

  STATUS
    NOT CLINICALLY REVIEWED. Transcribed 2026-10-15 for a STAGING DEMO bundle
    only (AD-35). Every genuine ambiguity is a REVIEW Qn below; the literal
    reading is what is encoded.

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the
    published wording verbatim, with page reference. A define with no SOURCE
    comment is engineering plumbing, not a clinical rule. Review is a
    side-by-side check of each SOURCE quote against the define beneath it.

  WHAT IS NOT IN THIS LIBRARY
    The "Refer for acute assessment without initial imaging." row (p62) is the
    national red-flag layer: CRR_RedFlags RF-14 (haemoptysis with red flags),
    RF-15 (severe respiratory distress), RF-16 (large pneumothorax) and RF-17
    (active TB, acutely unwell). The national library runs before this one and
    stops the pipeline when a red flag fires (AD-03), so none of them is
    re-encoded here. The PlanDefinition shows the row for display only.

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-XRay-Chest-Adult" (Questionnaire-xray-chest-adult.json).
    Each answer MAY carry the answer-evidence extension
    (http://crr.health.nz/fhir/StructureDefinition/answer-evidence) with status
    documented | inferred | retrieved and a verbatim quote. An answer with no
    evidence extension counts as documented. An unanswered indicator is NULL
    and propagates as "insufficient information" (three-valued logic).

  CLINICAL REVIEW FLAGS (listed in signoff.md and transcription-notes.md)
    Q1  Tier precedence: Acute 24h > Acute 48h > P2 > P3 > S2 when more than one is met.
    Q2  A met lower tier is returned even when a higher tier is undetermined (null).
    Q3  Determination precedence: not funded > alternative management > paediatric > tiers.
    Q4  Acute 24h CAP bullet read as: suspected CAP AND (unexpectedly severe or atypical
        presentation OR considered at risk of underlying lung pathology).
    Q5  "One or more of the following symptoms or signs concerning for lung cancer" read as
        any one of the twelve listed items; no separate "concerning for lung cancer" test.
    Q6  "Unexplained, new, or worsening dyspnoea" kept as one indicator in the published
        wording; whether the three adjectives are alternatives or cumulative is not decided
        in logic.
    Q7  "persisting ... for more than 3 weeks" read as a duration strictly greater than 3
        weeks (exactly 3 weeks does not qualify); the same for "more than 8 weeks" and
        "greater than 1 cm".
    Q8  "Unexplained weight loss and loss of appetite persisting for more than 3 weeks":
        both must be present and both must have persisted for more than 3 weeks; the weight
        loss duration is read from weightloss.periodMonths (3 weeks = 21 days, a month taken
        as 30.4375 days).
    Q9  "in the absence of red flags" (persistent haemoptysis) is satisfied by the national
        red-flag layer running first; this library does not re-test the RF-14 qualifiers.
    Q10 "where the lymph nodes are greater than 1 cm in diameter" read as the largest
        cervical node being greater than 1 cm.
    Q11 "Suspected tuberculosis - ... request a CXR if indicated": suspected TB alone meets
        P2; "if indicated" is left to the referrer and the TB pathway.
    Q12 "Polymyalgia Rheumatica (PMR) - request CXR for all patients prior to starting
        steroids": read as PMR AND steroids not yet started.
    Q13 "Idiopathic / unprovoked DVT or PE - as required": "as required" is not a condition.
    Q14 Non-acute asthma P3 bullet: the purpose clause ("For investigation of alternative
        diagnoses or co-morbidities") is not a condition.
    Q15 S2 "6 week follow up chest X-ray after chest infection" and not-funded "Routine
        follow-up of pneumonia findings on chest x-ray" are read as the same request
        (imaging.followUpAfterChestInfection); the not-funded item applies when none of
        the three S2 sub-conditions holds.
    Q16 One indicator (advice.followUpImagingRecommendedBySpecialist) serves "when
        recommended by secondary care clinician or radiologist", "documented specialist
        recommendation", "if recommended by a secondary care clinician or radiologist" and
        the not-funded exception "documented recommendation of a hospital secondary care
        clinician or radiologist". It is distinct from the PCRL-inclusive S2 gateway.
    Q17 Not-funded items are read as the purpose of the request, not as findings in the
        patient (e.g. "Heart murmur" = the CXR is requested for a heart murmur).
    Q18 "Routine lateral x-ray view when requesting a PA image" is NOT encoded: it removes
        a view, not the referral, so there is no literal reading as a referral outcome.
    Q19 Asbestos: P3 "History of asbestos exposure and no previous chest x-ray" versus
        not-funded "Asbestos exposure surveillance" - not funded wins under Q3.
    Q20 Alternative management: "especially if clinical concern of malignancy" is a modifier
        and not encoded; the redirect needs ongoing unexplained respiratory symptoms AND a
        previous negative chest X-ray.
    Q21 Candidate attestation indicators (AD-17): symptom.atRiskOfUnderlyingLungPathology,
        symptom.pneumoniaSevereOrAtypicalPresentation, symptom.otherLungCancerFeatures.
        Not added to the attestation category here.
    Q22 advice.acuteImagingRecommended is reused for "advises referral for acute x-ray"
        although the vocabulary text says "same or next day scan" and this row is
        "Acute: Within 48 hours".
    Q23 Missing information when nothing has started: every undetermined pathway's
        unanswered indicators are listed (long list); see "Missing Information".
*/

library CRR_XRChest_Adult version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

/*
  Documentation standard (BRD TA-010). Governs which evidence statuses are
  accepted as establishing an indicator.
    'strict'   - 'documented' and 'retrieved' answers count; 'inferred'
                 answers are treated as not answered (null).
    'inferred' - 'documented', 'retrieved' and 'inferred' all count.
*/
parameter "Documentation Standard" String default 'strict'

context Patient

// ---------------------------------------------------------------------------
// Plumbing: QuestionnaireResponse access
// ---------------------------------------------------------------------------

define "Evidence Extension URL": 'http://crr.health.nz/fhir/StructureDefinition/answer-evidence'

define "Accepted Evidence Statuses":
  if "Documentation Standard" = 'inferred' then { 'documented', 'retrieved', 'inferred' }
  else { 'documented', 'retrieved' }

define "Responses":
  [QuestionnaireResponse] R
    where R.status.value in { 'completed', 'in-progress' }

define "Top Level Items": flatten ("Responses" R return R.item)

define "Items": "Top Level Items" union flatten ("Top Level Items" I return I.item)

define function "Item"(linkId String):
  First("Items" I where I.linkId.value = linkId)

define function "Answer"(linkId String):
  First("Item"(linkId).answer)

define function "Evidence Status"(linkId String):
  FHIRHelpers.ToString(
    First(
      (First(("Answer"(linkId).extension) E where E.url.value = "Evidence Extension URL").extension) S
        where S.url.value = 'status'
    ).value as FHIR.code
  )

define function "Is Answered"(linkId String):
  "Answer"(linkId) is not null

define function "Is Accepted"(linkId String):
  "Is Answered"(linkId)
    and Coalesce("Evidence Status"(linkId), 'documented') in "Accepted Evidence Statuses"

define function "Bool"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToBoolean("Answer"(linkId).value as FHIR.boolean) else null

define function "Dec"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToDecimal("Answer"(linkId).value as FHIR.decimal) else null

define function "Int"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToInteger("Answer"(linkId).value as FHIR.integer) else null

// A pathway's components, each with the linkId the referrer would supply and
// whether that component is satisfied (true / false / null).
define function "Unanswered Parts"(parts List<Tuple { linkId String, met Boolean }>):
  parts P where P.met is null return P.linkId

define function "Any Part Met"(parts List<Tuple { linkId String, met Boolean }>):
  exists (parts P where P.met is true)

// ---------------------------------------------------------------------------
// Demographics
// ---------------------------------------------------------------------------

define "Age In Years":
  Coalesce("Int"('patient.age'), AgeInYears())

/*
  SOURCE (Overview, p4, Scope item 5): "The age band covered by the paediatric
  criteria has been specified as up to and including 15 years of age"
*/
define "Is Adult": "Age In Years" > 15

// ---------------------------------------------------------------------------
// Acute: Within 24 hours (p62)
// ---------------------------------------------------------------------------

/*
  SOURCE (p62, Acute: Within 24 hours, bullet 1):
  "Suspected community-acquired pneumonia (CAP) with unexpectedly severe or
   atypical presentation, or where the patient is considered at risk of
   underlying lung pathology (e.g. lung cancer)"

  REVIEW Q4 - read as suspected CAP AND (unexpectedly severe or atypical
  presentation OR considered at risk of underlying lung pathology). "(e.g. lung
  cancer)" is illustrative (KI-05) and not encoded.
  REVIEW Q21 - "considered at risk" and "unexpectedly severe or atypical" are
  referrer judgements (AD-17 candidates).
*/
define "A24-1 Parts":
  {
    Tuple { linkId: 'symptom.suspectedCommunityAcquiredPneumonia', met: "Bool"('symptom.suspectedCommunityAcquiredPneumonia') },
    Tuple { linkId: 'symptom.pneumoniaSevereOrAtypicalPresentation', met: "Bool"('symptom.pneumoniaSevereOrAtypicalPresentation') },
    Tuple { linkId: 'symptom.atRiskOfUnderlyingLungPathology', met: "Bool"('symptom.atRiskOfUnderlyingLungPathology') }
  }

define "A24-1 Suspected CAP Severe Atypical Or At Risk":
  "Bool"('symptom.suspectedCommunityAcquiredPneumonia')
    and ("Bool"('symptom.pneumoniaSevereOrAtypicalPresentation') or "Bool"('symptom.atRiskOfUnderlyingLungPathology'))

/*
  SOURCE (p62, Acute: Within 24 hours, bullet 2):
  "Respiratory tract infection with possible left ventricular failure"
*/
define "A24-2 Parts":
  {
    Tuple { linkId: 'symptom.respiratoryTractInfection', met: "Bool"('symptom.respiratoryTractInfection') },
    Tuple { linkId: 'symptom.possibleLeftVentricularFailure', met: "Bool"('symptom.possibleLeftVentricularFailure') }
  }

define "A24-2 RTI With Possible LVF":
  "Bool"('symptom.respiratoryTractInfection') and "Bool"('symptom.possibleLeftVentricularFailure')

/*
  SOURCE (p62, Timeframe column): "Acute: Within 24 hours"
  REVIEW Q1 / Q2 - tier precedence and undetermined higher tiers (see "Determination").
*/
define "Meets Acute 24h Criteria":
  "Is Adult"
    and ("A24-1 Suspected CAP Severe Atypical Or At Risk" or "A24-2 RTI With Possible LVF")

// ---------------------------------------------------------------------------
// Acute: Within 48 hours (p62-63)
// ---------------------------------------------------------------------------

/*
  SOURCE (p62, Acute: Within 48 hours, bullet 1 stem):
  "One or more of the following symptoms or signs concerning for lung cancer"
  REVIEW Q5 - read as any one of the twelve sub-bullets below (LC-01..LC-12).
*/

/*
  SOURCE (p62, LC-01): "Unexplained, new, or worsening dyspnoea"
  REVIEW Q6 - one indicator carrying the published wording.
*/
define "LC-01 Parts":
  { Tuple { linkId: 'symptom.dyspnoeaUnexplainedNewOrWorsening', met: "Bool"('symptom.dyspnoeaUnexplainedNewOrWorsening') } }

define "LC-01 Unexplained New Or Worsening Dyspnoea":
  "Bool"('symptom.dyspnoeaUnexplainedNewOrWorsening')

/*
  SOURCE (p62, LC-02): "Unexplained cough, persisting and worsening for more than 3 weeks"
  REVIEW Q7 - more than 3 weeks is strictly greater than 3.
*/
define "LC-02 Parts":
  {
    Tuple { linkId: 'symptom.coughUnexplained', met: "Bool"('symptom.coughUnexplained') },
    Tuple { linkId: 'symptom.coughWorsening', met: "Bool"('symptom.coughWorsening') },
    Tuple { linkId: 'symptom.coughDurationWeeks', met: "Dec"('symptom.coughDurationWeeks') > 3.0 }
  }

define "LC-02 Unexplained Worsening Cough Over 3 Weeks":
  "Bool"('symptom.coughUnexplained')
    and "Bool"('symptom.coughWorsening')
    and "Dec"('symptom.coughDurationWeeks') > 3.0

/*
  SOURCE (p62, LC-03): "Unexplained chest and/or shoulder pain"
*/
define "LC-03 Parts":
  { Tuple { linkId: 'symptom.chestOrShoulderPainUnexplained', met: "Bool"('symptom.chestOrShoulderPainUnexplained') } }

define "LC-03 Unexplained Chest Or Shoulder Pain":
  "Bool"('symptom.chestOrShoulderPainUnexplained')

/*
  SOURCE (p62, LC-04): "Unexplained changes in existing symptoms in patients with
   underlying chronic respiratory problems persisting for more than 3 weeks"
  "persisting for more than 3 weeks" is read as qualifying the changes.
*/
define "LC-04 Parts":
  {
    Tuple { linkId: 'symptom.chronicRespiratoryCondition', met: "Bool"('symptom.chronicRespiratoryCondition') },
    Tuple { linkId: 'symptom.chronicRespiratorySymptomChangeUnexplained', met: "Bool"('symptom.chronicRespiratorySymptomChangeUnexplained') },
    Tuple { linkId: 'symptom.chronicRespiratorySymptomChangeDurationWeeks', met: "Dec"('symptom.chronicRespiratorySymptomChangeDurationWeeks') > 3.0 }
  }

define "LC-04 Unexplained Change In Chronic Respiratory Symptoms Over 3 Weeks":
  "Bool"('symptom.chronicRespiratoryCondition')
    and "Bool"('symptom.chronicRespiratorySymptomChangeUnexplained')
    and "Dec"('symptom.chronicRespiratorySymptomChangeDurationWeeks') > 3.0

/*
  SOURCE (p63, LC-05): "Persistent, unexplained hoarseness persisting for more than 3 weeks"
*/
define "LC-05 Parts":
  {
    Tuple { linkId: 'symptom.hoarsenessUnexplained', met: "Bool"('symptom.hoarsenessUnexplained') },
    Tuple { linkId: 'symptom.hoarsenessDurationWeeks', met: "Dec"('symptom.hoarsenessDurationWeeks') > 3.0 }
  }

define "LC-05 Unexplained Hoarseness Over 3 Weeks":
  "Bool"('symptom.hoarsenessUnexplained')
    and "Dec"('symptom.hoarsenessDurationWeeks') > 3.0

/*
  SOURCE (p63, LC-06): "Recurrent or unresolved chest infections"
*/
define "LC-06 Parts":
  { Tuple { linkId: 'symptom.chestInfectionsRepeatedOrUnresolved', met: "Bool"('symptom.chestInfectionsRepeatedOrUnresolved') } }

define "LC-06 Recurrent Or Unresolved Chest Infections":
  "Bool"('symptom.chestInfectionsRepeatedOrUnresolved')

/*
  SOURCE (p63, LC-07): "Persistent, unexplained haemoptysis in the absence of red flags"
  REVIEW Q9 - "in the absence of red flags" is satisfied by the national red-flag
  layer (RF-14) running first; not re-tested here. The haemoptysis stem reuses the
  national linkId redflag.haemoptysisPresent (one concept, one indicator - KI-01).
*/
define "LC-07 Parts":
  {
    Tuple { linkId: 'redflag.haemoptysisPresent', met: "Bool"('redflag.haemoptysisPresent') },
    Tuple { linkId: 'symptom.haemoptysisPersistentUnexplained', met: "Bool"('symptom.haemoptysisPersistentUnexplained') }
  }

define "LC-07 Persistent Unexplained Haemoptysis":
  "Bool"('redflag.haemoptysisPresent')
    and "Bool"('symptom.haemoptysisPersistentUnexplained')

/*
  SOURCE (p63, LC-08): "Unexplained weight loss and loss of appetite persisting for
   more than 3 weeks"
  REVIEW Q8 - both present and both persisting more than 3 weeks; the weight-loss
  duration is weightloss.periodMonths, compared as more than 21 days with a month
  of 30.4375 days.
*/
define "Weight Loss Persisting More Than 3 Weeks":
  "Dec"('weightloss.periodMonths') * 30.4375 > 21.0

define "LC-08 Parts":
  {
    Tuple { linkId: 'weightloss.present', met: "Bool"('weightloss.present') },
    Tuple { linkId: 'weightloss.periodMonths', met: "Weight Loss Persisting More Than 3 Weeks" },
    Tuple { linkId: 'symptom.appetiteLoss', met: "Bool"('symptom.appetiteLoss') },
    Tuple { linkId: 'symptom.appetiteLossDurationWeeks', met: "Dec"('symptom.appetiteLossDurationWeeks') > 3.0 }
  }

define "LC-08 Unexplained Weight Loss And Appetite Loss Over 3 Weeks":
  "Bool"('weightloss.present')
    and "Weight Loss Persisting More Than 3 Weeks"
    and "Bool"('symptom.appetiteLoss')
    and "Dec"('symptom.appetiteLossDurationWeeks') > 3.0

/*
  SOURCE (p63, LC-09): "unexplained abnormal chest signs persisting more than 3 weeks
   (e.g. suspected pleural effusion) which have not yet been investigated with imaging"
  "(e.g. suspected pleural effusion)" is illustrative and not encoded.
*/
define "LC-09 Parts":
  {
    Tuple { linkId: 'symptom.abnormalChestSignsUnexplained', met: "Bool"('symptom.abnormalChestSignsUnexplained') },
    Tuple { linkId: 'symptom.abnormalChestSignsDurationWeeks', met: "Dec"('symptom.abnormalChestSignsDurationWeeks') > 3.0 },
    Tuple { linkId: 'imaging.abnormalChestSigns.ever', met: not "Bool"('imaging.abnormalChestSigns.ever') }
  }

define "LC-09 Unexplained Abnormal Chest Signs Over 3 Weeks Not Yet Imaged":
  "Bool"('symptom.abnormalChestSignsUnexplained')
    and "Dec"('symptom.abnormalChestSignsDurationWeeks') > 3.0
    and not "Bool"('imaging.abnormalChestSigns.ever')

/*
  SOURCE (p63, LC-10): "New supraclavicular lymphadenopathy"
*/
define "LC-10 Parts":
  { Tuple { linkId: 'symptom.supraclavicularLymphadenopathyNew', met: "Bool"('symptom.supraclavicularLymphadenopathyNew') } }

define "LC-10 New Supraclavicular Lymphadenopathy":
  "Bool"('symptom.supraclavicularLymphadenopathyNew')

/*
  SOURCE (p63, LC-11): "New cervical lymphadenopathy persisting for more than 3 weeks,
   where the lymph nodes are greater than 1 cm in diameter in a patient with other
   lung cancer symptoms, signs, or risk factors"
  REVIEW Q10 - the largest cervical node greater than 1 cm (strictly).
*/
define "LC-11 Parts":
  {
    Tuple { linkId: 'symptom.cervicalLymphadenopathyNew', met: "Bool"('symptom.cervicalLymphadenopathyNew') },
    Tuple { linkId: 'symptom.cervicalLymphadenopathyDurationWeeks', met: "Dec"('symptom.cervicalLymphadenopathyDurationWeeks') > 3.0 },
    Tuple { linkId: 'symptom.cervicalLymphNodeDiameterCm', met: "Dec"('symptom.cervicalLymphNodeDiameterCm') > 1.0 },
    Tuple { linkId: 'symptom.otherLungCancerFeatures', met: "Bool"('symptom.otherLungCancerFeatures') }
  }

define "LC-11 New Cervical Lymphadenopathy Over 3 Weeks Over 1 cm With Other Features":
  "Bool"('symptom.cervicalLymphadenopathyNew')
    and "Dec"('symptom.cervicalLymphadenopathyDurationWeeks') > 3.0
    and "Dec"('symptom.cervicalLymphNodeDiameterCm') > 1.0
    and "Bool"('symptom.otherLungCancerFeatures')

/*
  SOURCE (p63, LC-12): "Features suggestive of paraneoplastic syndromes. e.g.
   hypercalcaemia, hypertrophic osteoarthropathy with painful swollen joints and
   finger (and toe) clubbing"
  The examples follow "e.g." and are not encoded (KI-05): a raised calcium alone
  does not meet this item.
*/
define "LC-12 Parts":
  { Tuple { linkId: 'symptom.paraneoplasticFeatures', met: "Bool"('symptom.paraneoplasticFeatures') } }

define "LC-12 Features Suggestive Of Paraneoplastic Syndrome":
  "Bool"('symptom.paraneoplasticFeatures')

define "A48-1 Symptoms Or Signs Concerning For Lung Cancer":
  "LC-01 Unexplained New Or Worsening Dyspnoea"
    or "LC-02 Unexplained Worsening Cough Over 3 Weeks"
    or "LC-03 Unexplained Chest Or Shoulder Pain"
    or "LC-04 Unexplained Change In Chronic Respiratory Symptoms Over 3 Weeks"
    or "LC-05 Unexplained Hoarseness Over 3 Weeks"
    or "LC-06 Recurrent Or Unresolved Chest Infections"
    or "LC-07 Persistent Unexplained Haemoptysis"
    or "LC-08 Unexplained Weight Loss And Appetite Loss Over 3 Weeks"
    or "LC-09 Unexplained Abnormal Chest Signs Over 3 Weeks Not Yet Imaged"
    or "LC-10 New Supraclavicular Lymphadenopathy"
    or "LC-11 New Cervical Lymphadenopathy Over 3 Weeks Over 1 cm With Other Features"
    or "LC-12 Features Suggestive Of Paraneoplastic Syndrome"

/*
  SOURCE (p63, Acute: Within 48 hours, bullet 2):
  "Subacute dyspnoea of unknown cause, e.g. suspected pleural effusion or left
   ventricular failure"
  The examples follow "e.g." and are not encoded.
*/
define "A48-2 Parts":
  { Tuple { linkId: 'symptom.subacuteDyspnoeaUnknownCause', met: "Bool"('symptom.subacuteDyspnoeaUnknownCause') } }

define "A48-2 Subacute Dyspnoea Of Unknown Cause":
  "Bool"('symptom.subacuteDyspnoeaUnknownCause')

/*
  SOURCE (p63, Acute: Within 48 hours, bullet 3):
  "Lower respiratory tract infection which hasn’t responded as expected after 48
   hours of antibiotic treatment"
*/
define "A48-3 Parts":
  {
    Tuple { linkId: 'symptom.lowerRespiratoryTractInfection', met: "Bool"('symptom.lowerRespiratoryTractInfection') },
    Tuple { linkId: 'symptom.noResponseAfter48hAntibiotics', met: "Bool"('symptom.noResponseAfter48hAntibiotics') }
  }

define "A48-3 LRTI Not Responding After 48 Hours Of Antibiotics":
  "Bool"('symptom.lowerRespiratoryTractInfection')
    and "Bool"('symptom.noResponseAfter48hAntibiotics')

/*
  SOURCE (p63, Acute: Within 48 hours, bullet 4): "Suspected small pneumothorax"
  (A suspected LARGE pneumothorax with significant pain, breathlessness,
  tachycardia is national red flag RF-16, p62.)
*/
define "A48-4 Parts":
  { Tuple { linkId: 'symptom.suspectedSmallPneumothorax', met: "Bool"('symptom.suspectedSmallPneumothorax') } }

define "A48-4 Suspected Small Pneumothorax":
  "Bool"('symptom.suspectedSmallPneumothorax')

/*
  SOURCE (p63, Acute: Within 48 hours, bullet 5):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises
   referral for acute x-ray"
  REVIEW Q22 - reuses advice.acuteImagingRecommended.
*/
define "A48-5 Parts":
  { Tuple { linkId: 'advice.acuteImagingRecommended', met: "Bool"('advice.acuteImagingRecommended') } }

define "A48-5 Specialist Advises Acute X-ray":
  "Bool"('advice.acuteImagingRecommended')

/*
  SOURCE (p62, Timeframe column): "Acute: Within 48 hours"
*/
define "Meets Acute 48h Criteria":
  "Is Adult"
    and (
      "A48-1 Symptoms Or Signs Concerning For Lung Cancer"
        or "A48-2 Subacute Dyspnoea Of Unknown Cause"
        or "A48-3 LRTI Not Responding After 48 Hours Of Antibiotics"
        or "A48-4 Suspected Small Pneumothorax"
        or "A48-5 Specialist Advises Acute X-ray"
    )

// ---------------------------------------------------------------------------
// P2 Urgent (p63)
// ---------------------------------------------------------------------------

/*
  SOURCE (p63, P2, bullet 1):
  "Suspected tuberculosis - follow the Tuberculosis pathway and request a CXR if indicated"
  REVIEW Q11 - suspected TB alone; "if indicated" is not tested.
  (Suspected ACTIVE TB with the patient acutely unwell is national red flag RF-17, p62.)
*/
define "P2-1 Parts":
  { Tuple { linkId: 'symptom.suspectedTuberculosis', met: "Bool"('symptom.suspectedTuberculosis') } }

define "P2-1 Suspected Tuberculosis":
  "Bool"('symptom.suspectedTuberculosis')

/*
  SOURCE (p63, P2, bullet 2):
  "Suspected drug induced lung disease in patients who develop new respiratory
   symptoms while taking medication which can potentially affect the lungs e.g.
   Amiodarone, nitrofurantoin, methotrexate."
  The named drugs follow "e.g." and are not encoded.
*/
define "P2-2 Parts":
  {
    Tuple { linkId: 'symptom.suspectedDrugInducedLungDisease', met: "Bool"('symptom.suspectedDrugInducedLungDisease') },
    Tuple { linkId: 'symptom.newRespiratorySymptoms', met: "Bool"('symptom.newRespiratorySymptoms') },
    Tuple { linkId: 'symptom.takingPneumotoxicMedication', met: "Bool"('symptom.takingPneumotoxicMedication') }
  }

define "P2-2 Suspected Drug Induced Lung Disease":
  "Bool"('symptom.suspectedDrugInducedLungDisease')
    and "Bool"('symptom.newRespiratorySymptoms')
    and "Bool"('symptom.takingPneumotoxicMedication')

/*
  SOURCE (p63, P2, bullet 3):
  "Idiopathic / unprovoked DVT or PE - as required, to exclude underlying malignancy."
  REVIEW Q13 - "as required" is not a condition.
*/
define "P2-3 Parts":
  { Tuple { linkId: 'symptom.unprovokedDvtOrPe', met: "Bool"('symptom.unprovokedDvtOrPe') } }

define "P2-3 Idiopathic Or Unprovoked DVT Or PE":
  "Bool"('symptom.unprovokedDvtOrPe')

/*
  SOURCE (p63, P2, bullet 4):
  "Polymyalgia Rheumatica (PMR) - request CXR for all patients prior to starting
   steroids, to exclude an alternative cause for their presenting symptoms (e.g.
   pulmonary pathology, chronic infection, malignancy).  Also consider additional
   targeted imaging if any specific concerns about an underlying malignancy."
  REVIEW Q12 - PMR AND steroids not yet started. The last sentence is guidance.
*/
define "P2-4 Parts":
  {
    Tuple { linkId: 'symptom.polymyalgiaRheumatica', met: "Bool"('symptom.polymyalgiaRheumatica') },
    Tuple { linkId: 'symptom.pmrSteroidsStarted', met: not "Bool"('symptom.pmrSteroidsStarted') }
  }

define "P2-4 PMR Before Starting Steroids":
  "Bool"('symptom.polymyalgiaRheumatica')
    and not "Bool"('symptom.pmrSteroidsStarted')

/*
  SOURCE (p63, P2, bullet 5):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises
   referral for urgent x-ray"
*/
define "P2-5 Parts":
  { Tuple { linkId: 'advice.urgentImagingRecommended', met: "Bool"('advice.urgentImagingRecommended') } }

define "P2-5 Specialist Advises Urgent X-ray":
  "Bool"('advice.urgentImagingRecommended')

/*
  SOURCE (p63, Timeframe column): "P2 Urgent: Non-deferrable imaging or intervention
   that must be completed within 2 weeks of receiving referral."
*/
define "Meets P2 Criteria":
  "Is Adult"
    and (
      "P2-1 Suspected Tuberculosis"
        or "P2-2 Suspected Drug Induced Lung Disease"
        or "P2-3 Idiopathic Or Unprovoked DVT Or PE"
        or "P2-4 PMR Before Starting Steroids"
        or "P2-5 Specialist Advises Urgent X-ray"
    )

// ---------------------------------------------------------------------------
// P3 (p64)
// ---------------------------------------------------------------------------

/*
  SOURCE (p64, P3, bullet 1):
  "For investigation of alternative diagnoses or co-morbidities in patients with
   non-acute asthma and any of - unclear diagnosis, poor control, or frequent
   exacerbations"
  REVIEW Q14 - the purpose clause is not a condition.
*/
define "P3-1 Parts":
  {
    Tuple { linkId: 'symptom.asthmaNonAcute', met: "Bool"('symptom.asthmaNonAcute') },
    Tuple { linkId: 'symptom.asthmaDiagnosisUnclear', met: "Bool"('symptom.asthmaDiagnosisUnclear') },
    Tuple { linkId: 'symptom.asthmaPoorControl', met: "Bool"('symptom.asthmaPoorControl') },
    Tuple { linkId: 'symptom.asthmaFrequentExacerbations', met: "Bool"('symptom.asthmaFrequentExacerbations') }
  }

define "P3-1 Non-acute Asthma With Unclear Diagnosis Poor Control Or Frequent Exacerbations":
  "Bool"('symptom.asthmaNonAcute')
    and (
      "Bool"('symptom.asthmaDiagnosisUnclear')
        or "Bool"('symptom.asthmaPoorControl')
        or "Bool"('symptom.asthmaFrequentExacerbations')
    )

/*
  SOURCE (p64, P3, bullet 2): "Chronic cough (more than 8 weeks)"
  The cough duration is the same indicator as LC-02 (p62).
*/
define "P3-2 Parts":
  { Tuple { linkId: 'symptom.coughDurationWeeks', met: "Dec"('symptom.coughDurationWeeks') > 8.0 } }

define "P3-2 Chronic Cough More Than 8 Weeks":
  "Dec"('symptom.coughDurationWeeks') > 8.0

/*
  SOURCE (p64, P3, bullet 3): "Chronic dyspnoea"
*/
define "P3-3 Parts":
  { Tuple { linkId: 'symptom.chronicDyspnoea', met: "Bool"('symptom.chronicDyspnoea') } }

define "P3-3 Chronic Dyspnoea":
  "Bool"('symptom.chronicDyspnoea')

/*
  SOURCE (p64, P3, bullet 4):
  "Known cardio-respiratory disease unresponsive to treatment, for example COPD,
   ILD, bronchiectasis, sarcoidosis"
  The conditions after "for example" are illustrative and not encoded.
*/
define "P3-4 Parts":
  { Tuple { linkId: 'symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment', met: "Bool"('symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment') } }

define "P3-4 Known Cardio-respiratory Disease Unresponsive To Treatment":
  "Bool"('symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment')

/*
  SOURCE (p64, P3, bullet 5): "History of asbestos exposure and no previous chest x-ray"
  REVIEW Q19 - against the not-funded "Asbestos exposure surveillance".
*/
define "P3-5 Parts":
  {
    Tuple { linkId: 'symptom.asbestosExposureHistory', met: "Bool"('symptom.asbestosExposureHistory') },
    Tuple { linkId: 'imaging.cxr.ever', met: not "Bool"('imaging.cxr.ever') }
  }

define "P3-5 Asbestos Exposure And No Previous Chest X-ray":
  "Bool"('symptom.asbestosExposureHistory')
    and not "Bool"('imaging.cxr.ever')

/*
  SOURCE (p64, P3, bullet 6):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises
   referral for non-urgent x-ray"
*/
define "P3-6 Parts":
  { Tuple { linkId: 'advice.nonUrgentImagingRecommended', met: "Bool"('advice.nonUrgentImagingRecommended') } }

define "P3-6 Specialist Advises Non-urgent X-ray":
  "Bool"('advice.nonUrgentImagingRecommended')

/*
  SOURCE (p64, Timeframe column): "P3 Non-deferrable imaging or intervention that must
   be completed within 6 weeks of receiving referral."
*/
define "Meets P3 Criteria":
  "Is Adult"
    and (
      "P3-1 Non-acute Asthma With Unclear Diagnosis Poor Control Or Frequent Exacerbations"
        or "P3-2 Chronic Cough More Than 8 Weeks"
        or "P3-3 Chronic Dyspnoea"
        or "P3-4 Known Cardio-respiratory Disease Unresponsive To Treatment"
        or "P3-5 Asbestos Exposure And No Previous Chest X-ray"
        or "P3-6 Specialist Advises Non-urgent X-ray"
    )

// ---------------------------------------------------------------------------
// S2 (p64)
// ---------------------------------------------------------------------------

/*
  SOURCE (p64, S2, bullet 1):
  "6 week follow up chest X-ray after chest infection if the patient has any of:
     o ongoing symptoms or signs
     o suspicious radiological features noted by a radiologist and follow up is recommended
     o when recommended by secondary care clinician or radiologist"
  REVIEW Q15, Q16. "6 week" is the target date of the follow-up, not a condition.
*/
define "S2-1 Sub-conditions":
  "Bool"('symptom.ongoingSymptomsOrSignsAfterChestInfection')
    or "Bool"('imaging.radiologistSuspiciousFeaturesFollowUpRecommended')
    or "Bool"('advice.followUpImagingRecommendedBySpecialist')

define "S2-1 Parts":
  {
    Tuple { linkId: 'imaging.followUpAfterChestInfection', met: "Bool"('imaging.followUpAfterChestInfection') },
    Tuple { linkId: 'symptom.ongoingSymptomsOrSignsAfterChestInfection', met: "Bool"('symptom.ongoingSymptomsOrSignsAfterChestInfection') },
    Tuple { linkId: 'imaging.radiologistSuspiciousFeaturesFollowUpRecommended', met: "Bool"('imaging.radiologistSuspiciousFeaturesFollowUpRecommended') },
    Tuple { linkId: 'advice.followUpImagingRecommendedBySpecialist', met: "Bool"('advice.followUpImagingRecommendedBySpecialist') }
  }

define "S2-1 Follow-up Chest X-ray After Chest Infection":
  "Bool"('imaging.followUpAfterChestInfection') and "S2-1 Sub-conditions"

/*
  SOURCE (p64, S2, bullet 2): "Post-cancer surveillance with documented specialist recommendation"
  REVIEW Q16.
*/
define "S2-2 Parts":
  {
    Tuple { linkId: 'imaging.postCancerSurveillance', met: "Bool"('imaging.postCancerSurveillance') },
    Tuple { linkId: 'advice.followUpImagingRecommendedBySpecialist', met: "Bool"('advice.followUpImagingRecommendedBySpecialist') }
  }

define "S2-2 Post-cancer Surveillance With Specialist Recommendation":
  "Bool"('imaging.postCancerSurveillance')
    and "Bool"('advice.followUpImagingRecommendedBySpecialist')

/*
  SOURCE (p64, S2, bullet 3): "Follow-up of nodules detected on chest X-ray or CT, if
   recommended by a secondary care clinician or radiologist"
  REVIEW Q16.
*/
define "S2-3 Parts":
  {
    Tuple { linkId: 'imaging.noduleFollowUp', met: "Bool"('imaging.noduleFollowUp') },
    Tuple { linkId: 'advice.followUpImagingRecommendedBySpecialist', met: "Bool"('advice.followUpImagingRecommendedBySpecialist') }
  }

define "S2-3 Nodule Follow-up Recommended By Specialist Or Radiologist":
  "Bool"('imaging.noduleFollowUp')
    and "Bool"('advice.followUpImagingRecommendedBySpecialist')

/*
  SOURCE (p64, S2, bullet 4):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises
   referral for follow-up x-ray"
*/
define "S2-4 Parts":
  { Tuple { linkId: 'advice.followUpImagingRecommended', met: "Bool"('advice.followUpImagingRecommended') } }

define "S2-4 Specialist Advises Follow-up X-ray":
  "Bool"('advice.followUpImagingRecommended')

/*
  SOURCE (p64, Timeframe column): "S2 non-deferrable time sensitive imaging or
   intervention that must be completed within 2 weeks of a specified target date."
*/
define "Meets S2 Criteria":
  "Is Adult"
    and (
      "S2-1 Follow-up Chest X-ray After Chest Infection"
        or "S2-2 Post-cancer Surveillance With Specialist Recommendation"
        or "S2-3 Nodule Follow-up Recommended By Specialist Or Radiologist"
        or "S2-4 Specialist Advises Follow-up X-ray"
    )

// ---------------------------------------------------------------------------
// Adviser name and role (all four gateways)
// ---------------------------------------------------------------------------

/*
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Any Adviser Gateway Met":
  "A48-5 Specialist Advises Acute X-ray" is true
    or "P2-5 Specialist Advises Urgent X-ray" is true
    or "P3-6 Specialist Advises Non-urgent X-ray" is true
    or "S2-4 Specialist Advises Follow-up X-ray" is true

define "Adviser Name And Role Documented":
  "Is Answered"('advice.adviserNameRole')

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (p64)
// ---------------------------------------------------------------------------

/*
  SOURCE (p64, "Alternative management or HealthPathway recommended."):
  "Ongoing unexplained respiratory symptoms after a negative chest X-ray result,
   especially if clinical concern of malignancy, either:
     o Seek secondary care specialist assessment
     o See the local Lung Cancer HealthPathway
     o See the local CT Chest, Abdomen and Pelvis HealthPathway"
  REVIEW Q20 - "especially if clinical concern of malignancy" is a modifier (KI-05).
  An unknown component is treated as not present (absence does not block the
  referral) and surfaced in "Unconfirmed Exclusions".
*/
define "Redirect: Ongoing Unexplained Symptoms After Negative Chest X-ray":
  "Bool"('symptom.respiratorySymptomsOngoingUnexplained')
    and "Bool"('imaging.cxrNegative.ever')

define "Active Redirects":
  if "Redirect: Ongoing Unexplained Symptoms After Negative Chest X-ray" is true
    then {
      'Seek secondary care specialist assessment',
      'See the local Lung Cancer HealthPathway',
      'See the local CT Chest, Abdomen and Pelvis HealthPathway'
    }
  else {} as List<String>

define "Alternative Management Recommended": exists "Active Redirects"

define "Unconfirmed Exclusions":
  if "Redirect: Ongoing Unexplained Symptoms After Negative Chest X-ray" is null
    then (List<String>{
      if "Bool"('symptom.respiratorySymptomsOngoingUnexplained') is null then 'symptom.respiratorySymptomsOngoingUnexplained' else null,
      if "Bool"('imaging.cxrNegative.ever') is null then 'imaging.cxrNegative.ever' else null
    }) X where X is not null
  else {} as List<String>

// ---------------------------------------------------------------------------
// Not routinely funded (p64-65)
// ---------------------------------------------------------------------------

/*
  SOURCE (p64, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
  REVIEW Q17 - each item is read as the purpose of the request. Each is
  exclusion-shaped: an unknown item is treated as not present.
*/

/*
  SOURCE (p64, NF-01): "Routine follow-up of pneumonia findings on chest x-ray, other
   than in the scenarios specified above under S2 priority imaging"
  REVIEW Q15 - the follow-up request is not funded when none of the three S2-1
  sub-conditions holds.
*/
define "NF-01 Routine Pneumonia Follow-up Outside S2":
  "Bool"('imaging.followUpAfterChestInfection') and not "S2-1 Sub-conditions"

/*
  SOURCE (p64, NF-02): "Asbestos exposure surveillance"
*/
define "NF-02 Asbestos Exposure Surveillance":
  "Bool"('funding.asbestosSurveillance')

/*
  SOURCE (p64, NF-03): "Heart murmur, unless signs of complications such as heart failure"
*/
define "NF-03 Heart Murmur Without Complications":
  "Bool"('funding.heartMurmurIndication') and not "Bool"('symptom.heartMurmurComplicationSigns')

/*
  SOURCE (p64, NF-04): "Lung cancer screening"
*/
define "NF-04 Lung Cancer Screening":
  "Bool"('funding.lungCancerScreening')

/*
  SOURCE (p64, NF-05): "Follow-up of nodules detected on chest X-ray or CT, except with
   documented recommendation of a hospital secondary care clinician or radiologist"
  REVIEW Q16 - the exception is the same indicator as S2-3's recommendation.
*/
define "NF-05 Nodule Follow-up Without Specialist Recommendation":
  "Bool"('imaging.noduleFollowUp') and not "Bool"('advice.followUpImagingRecommendedBySpecialist')

/*
  SOURCE (p65, NF-06): "The patient may wish to consider privately funded imaging for
   TB screening in the absence of a positive skin or blood test - See Tuberculosis
   pathway for additional management advice"
*/
define "NF-06 TB Screening Without Positive Skin Or Blood Test":
  "Bool"('funding.tbScreening') and not "Bool"('lab.tbSkinOrBloodTestPositive')

/*
  SOURCE (p65, NF-07): "Rib views"
*/
define "NF-07 Rib Views":
  "Bool"('funding.ribViews')

/*
  SOURCE (p65, NF-08): "Chest x-rays for immigration purposes"
*/
define "NF-08 Immigration Purposes":
  "Bool"('funding.immigrationPurposes')

/*
  SOURCE (p65, NF-09): "Routine lateral x-ray view when requesting a PA image"
  REVIEW Q18 - NOT ENCODED. It withholds one view, not the referral; there is no
  literal reading as a referral outcome. Shown in the PlanDefinition only.
*/

/*
  SOURCE (p65, NF-10): "Routine investigation of hypertension"
*/
define "NF-10 Routine Investigation Of Hypertension":
  "Bool"('funding.routineHypertensionInvestigation')

/*
  SOURCE (p65, NF-11): "Routine monitoring for asymptomatic patients who are taking
   medications which may cause drug induced lung disease (e.g. amiodarone,
   nitrofurantoin, methotrexate)."
*/
define "NF-11 Routine Monitoring On Pneumotoxic Medication":
  "Bool"('funding.routineMonitoringPneumotoxicMedication')

define "Not Routinely Funded":
  Coalesce("NF-01 Routine Pneumonia Follow-up Outside S2", false)
    or Coalesce("NF-02 Asbestos Exposure Surveillance", false)
    or Coalesce("NF-03 Heart Murmur Without Complications", false)
    or Coalesce("NF-04 Lung Cancer Screening", false)
    or Coalesce("NF-05 Nodule Follow-up Without Specialist Recommendation", false)
    or Coalesce("NF-06 TB Screening Without Positive Skin Or Blood Test", false)
    or Coalesce("NF-07 Rib Views", false)
    or Coalesce("NF-08 Immigration Purposes", false)
    or Coalesce("NF-10 Routine Investigation Of Hypertension", false)
    or Coalesce("NF-11 Routine Monitoring On Pneumotoxic Medication", false)

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q3, as CT CAP):
    1. Not routinely funded
    2. Alternative management / redirect (BRD TA-013: redirect wins over criteria)
    3. Paediatric patient - the adult criteria do not apply (BRD TA-003)
    4. The most urgent tier that is met (REVIEW Q1): Acute 24h, Acute 48h, P2, P3, S2.
       A met tier is returned even if a more urgent tier is undetermined (REVIEW Q2).
    5. Every tier definitively not met
    6. Insufficient information
  Determination codes carry no S-code in their text (the Advisory renderer
  humanises an unmapped code for the referrer view).
*/
define "Determination":
  case
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Meets Acute 24h Criteria" is true then 'ACUTE_24H'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P3 Criteria" is true then 'P3_NON_DEFERRABLE'
    when "Meets S2 Criteria" is true then 'S2_TIME_SENSITIVE'
    when "Meets Acute 24h Criteria" is false
      and "Meets Acute 48h Criteria" is false
      and "Meets P2 Criteria" is false
      and "Meets P3 Criteria" is false
      and "Meets S2 Criteria" is false then 'CRITERIA_NOT_MET'
    else 'INSUFFICIENT_INFORMATION'
  end

// Triager-only (GEN-004). Labels as used by the legacy tools.
define "Priority Code":
  case "Determination"
    when 'ACUTE_24H' then 'A24'
    when 'ACUTE_48H' then 'A48'
    when 'P2_URGENT' then 'P2'
    when 'P3_NON_DEFERRABLE' then 'P3'
    when 'S2_TIME_SENSITIVE' then 'S2'
    else null
  end

/*
  SOURCE (p62): "Acute: Within 24 hours"; "Acute: Within 48 hours"
  SOURCE (p63): "must be completed within 2 weeks of receiving referral."
  SOURCE (p64): "must be completed within 6 weeks of receiving referral."
  SOURCE (p64): "must be completed within 2 weeks of a specified target date."
  Referrer-facing: no priority code in the wording.
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_24H' then 'Acute: within 24 hours'
    when 'ACUTE_48H' then 'Acute: within 48 hours'
    when 'P2_URGENT' then 'Complete within 2 weeks of receiving referral'
    when 'P3_NON_DEFERRABLE' then 'Complete within 6 weeks of receiving referral'
    when 'S2_TIME_SENSITIVE' then 'Complete within 2 weeks of a specified target date'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

define "Pathways":
  {
    Tuple { id: 'A24-1', result: "A24-1 Suspected CAP Severe Atypical Or At Risk", parts: "A24-1 Parts" },
    Tuple { id: 'A24-2', result: "A24-2 RTI With Possible LVF", parts: "A24-2 Parts" },
    Tuple { id: 'LC-01', result: "LC-01 Unexplained New Or Worsening Dyspnoea", parts: "LC-01 Parts" },
    Tuple { id: 'LC-02', result: "LC-02 Unexplained Worsening Cough Over 3 Weeks", parts: "LC-02 Parts" },
    Tuple { id: 'LC-03', result: "LC-03 Unexplained Chest Or Shoulder Pain", parts: "LC-03 Parts" },
    Tuple { id: 'LC-04', result: "LC-04 Unexplained Change In Chronic Respiratory Symptoms Over 3 Weeks", parts: "LC-04 Parts" },
    Tuple { id: 'LC-05', result: "LC-05 Unexplained Hoarseness Over 3 Weeks", parts: "LC-05 Parts" },
    Tuple { id: 'LC-06', result: "LC-06 Recurrent Or Unresolved Chest Infections", parts: "LC-06 Parts" },
    Tuple { id: 'LC-07', result: "LC-07 Persistent Unexplained Haemoptysis", parts: "LC-07 Parts" },
    Tuple { id: 'LC-08', result: "LC-08 Unexplained Weight Loss And Appetite Loss Over 3 Weeks", parts: "LC-08 Parts" },
    Tuple { id: 'LC-09', result: "LC-09 Unexplained Abnormal Chest Signs Over 3 Weeks Not Yet Imaged", parts: "LC-09 Parts" },
    Tuple { id: 'LC-10', result: "LC-10 New Supraclavicular Lymphadenopathy", parts: "LC-10 Parts" },
    Tuple { id: 'LC-11', result: "LC-11 New Cervical Lymphadenopathy Over 3 Weeks Over 1 cm With Other Features", parts: "LC-11 Parts" },
    Tuple { id: 'LC-12', result: "LC-12 Features Suggestive Of Paraneoplastic Syndrome", parts: "LC-12 Parts" },
    Tuple { id: 'A48-2', result: "A48-2 Subacute Dyspnoea Of Unknown Cause", parts: "A48-2 Parts" },
    Tuple { id: 'A48-3', result: "A48-3 LRTI Not Responding After 48 Hours Of Antibiotics", parts: "A48-3 Parts" },
    Tuple { id: 'A48-4', result: "A48-4 Suspected Small Pneumothorax", parts: "A48-4 Parts" },
    Tuple { id: 'A48-5', result: "A48-5 Specialist Advises Acute X-ray", parts: "A48-5 Parts" },
    Tuple { id: 'P2-1', result: "P2-1 Suspected Tuberculosis", parts: "P2-1 Parts" },
    Tuple { id: 'P2-2', result: "P2-2 Suspected Drug Induced Lung Disease", parts: "P2-2 Parts" },
    Tuple { id: 'P2-3', result: "P2-3 Idiopathic Or Unprovoked DVT Or PE", parts: "P2-3 Parts" },
    Tuple { id: 'P2-4', result: "P2-4 PMR Before Starting Steroids", parts: "P2-4 Parts" },
    Tuple { id: 'P2-5', result: "P2-5 Specialist Advises Urgent X-ray", parts: "P2-5 Parts" },
    Tuple { id: 'P3-1', result: "P3-1 Non-acute Asthma With Unclear Diagnosis Poor Control Or Frequent Exacerbations", parts: "P3-1 Parts" },
    Tuple { id: 'P3-2', result: "P3-2 Chronic Cough More Than 8 Weeks", parts: "P3-2 Parts" },
    Tuple { id: 'P3-3', result: "P3-3 Chronic Dyspnoea", parts: "P3-3 Parts" },
    Tuple { id: 'P3-4', result: "P3-4 Known Cardio-respiratory Disease Unresponsive To Treatment", parts: "P3-4 Parts" },
    Tuple { id: 'P3-5', result: "P3-5 Asbestos Exposure And No Previous Chest X-ray", parts: "P3-5 Parts" },
    Tuple { id: 'P3-6', result: "P3-6 Specialist Advises Non-urgent X-ray", parts: "P3-6 Parts" },
    Tuple { id: 'S2-1', result: "S2-1 Follow-up Chest X-ray After Chest Infection", parts: "S2-1 Parts" },
    Tuple { id: 'S2-2', result: "S2-2 Post-cancer Surveillance With Specialist Recommendation", parts: "S2-2 Parts" },
    Tuple { id: 'S2-3', result: "S2-3 Nodule Follow-up Recommended By Specialist Or Radiologist", parts: "S2-3 Parts" },
    Tuple { id: 'S2-4', result: "S2-4 Specialist Advises Follow-up X-ray", parts: "S2-4 Parts" }
  }

// A pathway is "started" when it is undetermined but at least one of its
// components is already met - the referrer is part-way to it.
define "Started Pathways":
  "Pathways" P where P.result is null and "Any Part Met"(P.parts)

define "Undetermined Pathways":
  "Pathways" P where P.result is null

/*
  REVIEW Q23 - when a pathway is already met, the result can only be insufficient
  because age is unknown, so no pathway indicator is listed. Otherwise, when at
  least one pathway is started, only the started pathways' unanswered components
  are listed; when none is started, every undetermined pathway's unanswered
  components are listed (the whole checklist).
*/
define "Missing Pathway Indicators":
  if exists ("Pathways" P where P.result is true) then {} as List<String>
  else if exists "Started Pathways"
    then flatten ("Started Pathways" P return "Unanswered Parts"(P.parts))
  else flatten ("Undetermined Pathways" P return "Unanswered Parts"(P.parts))

define "Missing Advice Indicators":
  if "Any Adviser Gateway Met" and not "Adviser Name And Role Documented"
    then { 'advice.adviserNameRole' }
  else {} as List<String>

define "Missing Information":
  if "Determination" = 'INSUFFICIENT_INFORMATION'
    then (if "Age In Years" is null then { 'patient.age' } else {} as List<String>)
      union "Missing Pathway Indicators"
      union "Missing Advice Indicators"
  else "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age',
    'symptom.suspectedCommunityAcquiredPneumonia', 'symptom.pneumoniaSevereOrAtypicalPresentation', 'symptom.atRiskOfUnderlyingLungPathology',
    'symptom.respiratoryTractInfection', 'symptom.possibleLeftVentricularFailure',
    'symptom.dyspnoeaUnexplainedNewOrWorsening',
    'symptom.coughUnexplained', 'symptom.coughWorsening', 'symptom.coughDurationWeeks',
    'symptom.chestOrShoulderPainUnexplained',
    'symptom.chronicRespiratoryCondition', 'symptom.chronicRespiratorySymptomChangeUnexplained', 'symptom.chronicRespiratorySymptomChangeDurationWeeks',
    'symptom.hoarsenessUnexplained', 'symptom.hoarsenessDurationWeeks',
    'symptom.chestInfectionsRepeatedOrUnresolved',
    'redflag.haemoptysisPresent', 'symptom.haemoptysisPersistentUnexplained',
    'weightloss.present', 'weightloss.periodMonths', 'symptom.appetiteLoss', 'symptom.appetiteLossDurationWeeks',
    'symptom.abnormalChestSignsUnexplained', 'symptom.abnormalChestSignsDurationWeeks', 'imaging.abnormalChestSigns.ever',
    'symptom.supraclavicularLymphadenopathyNew',
    'symptom.cervicalLymphadenopathyNew', 'symptom.cervicalLymphadenopathyDurationWeeks', 'symptom.cervicalLymphNodeDiameterCm', 'symptom.otherLungCancerFeatures',
    'symptom.paraneoplasticFeatures',
    'symptom.subacuteDyspnoeaUnknownCause',
    'symptom.lowerRespiratoryTractInfection', 'symptom.noResponseAfter48hAntibiotics',
    'symptom.suspectedSmallPneumothorax',
    'advice.acuteImagingRecommended', 'advice.urgentImagingRecommended', 'advice.nonUrgentImagingRecommended', 'advice.followUpImagingRecommended',
    'advice.adviserNameRole',
    'symptom.suspectedTuberculosis',
    'symptom.suspectedDrugInducedLungDisease', 'symptom.newRespiratorySymptoms', 'symptom.takingPneumotoxicMedication',
    'symptom.unprovokedDvtOrPe',
    'symptom.polymyalgiaRheumatica', 'symptom.pmrSteroidsStarted',
    'symptom.asthmaNonAcute', 'symptom.asthmaDiagnosisUnclear', 'symptom.asthmaPoorControl', 'symptom.asthmaFrequentExacerbations',
    'symptom.chronicDyspnoea', 'symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment',
    'symptom.asbestosExposureHistory', 'imaging.cxr.ever',
    'imaging.followUpAfterChestInfection', 'symptom.ongoingSymptomsOrSignsAfterChestInfection',
    'imaging.radiologistSuspiciousFeaturesFollowUpRecommended', 'advice.followUpImagingRecommendedBySpecialist',
    'imaging.postCancerSurveillance', 'imaging.noduleFollowUp',
    'symptom.respiratorySymptomsOngoingUnexplained', 'imaging.cxrNegative.ever',
    'funding.asbestosSurveillance', 'funding.heartMurmurIndication', 'symptom.heartMurmurComplicationSigns',
    'funding.lungCancerScreening', 'funding.tbScreening', 'lab.tbSkinOrBloodTestPositive',
    'funding.ribViews', 'funding.immigrationPurposes', 'funding.routineHypertensionInvestigation',
    'funding.routineMonitoringPneumotoxicMedication'
  }

define "Inferred Indicators":
  "All Indicator LinkIds" L where "Evidence Status"(L) = 'inferred'

define "Inferred Indicators Excluded By Strict Standard":
  if "Documentation Standard" = 'strict' then "Inferred Indicators" else {} as List<String>

define "Retrieved Indicators":
  "All Indicator LinkIds" L where "Evidence Status"(L) = 'retrieved'

// ---------------------------------------------------------------------------
// Rule trace (triager audit view)
// ---------------------------------------------------------------------------

define "Rule Trace":
  Tuple {
    isAdult: "Is Adult",
    a24_1SuspectedCap: "A24-1 Suspected CAP Severe Atypical Or At Risk",
    a24_2RtiWithPossibleLvf: "A24-2 RTI With Possible LVF",
    meetsAcute24h: "Meets Acute 24h Criteria",
    lc01Dyspnoea: "LC-01 Unexplained New Or Worsening Dyspnoea",
    lc02Cough: "LC-02 Unexplained Worsening Cough Over 3 Weeks",
    lc03ChestOrShoulderPain: "LC-03 Unexplained Chest Or Shoulder Pain",
    lc04ChronicRespiratoryChange: "LC-04 Unexplained Change In Chronic Respiratory Symptoms Over 3 Weeks",
    lc05Hoarseness: "LC-05 Unexplained Hoarseness Over 3 Weeks",
    lc06ChestInfections: "LC-06 Recurrent Or Unresolved Chest Infections",
    lc07Haemoptysis: "LC-07 Persistent Unexplained Haemoptysis",
    lc08WeightAndAppetiteLoss: "LC-08 Unexplained Weight Loss And Appetite Loss Over 3 Weeks",
    weightLossOver3Weeks: "Weight Loss Persisting More Than 3 Weeks",
    lc09ChestSigns: "LC-09 Unexplained Abnormal Chest Signs Over 3 Weeks Not Yet Imaged",
    lc10Supraclavicular: "LC-10 New Supraclavicular Lymphadenopathy",
    lc11Cervical: "LC-11 New Cervical Lymphadenopathy Over 3 Weeks Over 1 cm With Other Features",
    lc12Paraneoplastic: "LC-12 Features Suggestive Of Paraneoplastic Syndrome",
    a48_1LungCancer: "A48-1 Symptoms Or Signs Concerning For Lung Cancer",
    a48_2SubacuteDyspnoea: "A48-2 Subacute Dyspnoea Of Unknown Cause",
    a48_3LrtiNotResponding: "A48-3 LRTI Not Responding After 48 Hours Of Antibiotics",
    a48_4SmallPneumothorax: "A48-4 Suspected Small Pneumothorax",
    a48_5AcuteAdvice: "A48-5 Specialist Advises Acute X-ray",
    meetsAcute48h: "Meets Acute 48h Criteria",
    p2_1Tuberculosis: "P2-1 Suspected Tuberculosis",
    p2_2DrugInducedLungDisease: "P2-2 Suspected Drug Induced Lung Disease",
    p2_3DvtOrPe: "P2-3 Idiopathic Or Unprovoked DVT Or PE",
    p2_4Pmr: "P2-4 PMR Before Starting Steroids",
    p2_5UrgentAdvice: "P2-5 Specialist Advises Urgent X-ray",
    meetsP2: "Meets P2 Criteria",
    p3_1Asthma: "P3-1 Non-acute Asthma With Unclear Diagnosis Poor Control Or Frequent Exacerbations",
    p3_2ChronicCough: "P3-2 Chronic Cough More Than 8 Weeks",
    p3_3ChronicDyspnoea: "P3-3 Chronic Dyspnoea",
    p3_4CardiorespiratoryDisease: "P3-4 Known Cardio-respiratory Disease Unresponsive To Treatment",
    p3_5Asbestos: "P3-5 Asbestos Exposure And No Previous Chest X-ray",
    p3_6NonUrgentAdvice: "P3-6 Specialist Advises Non-urgent X-ray",
    meetsP3: "Meets P3 Criteria",
    s2_1PostInfectionFollowUp: "S2-1 Follow-up Chest X-ray After Chest Infection",
    s2_1SubConditions: "S2-1 Sub-conditions",
    s2_2PostCancerSurveillance: "S2-2 Post-cancer Surveillance With Specialist Recommendation",
    s2_3NoduleFollowUp: "S2-3 Nodule Follow-up Recommended By Specialist Or Radiologist",
    s2_4FollowUpAdvice: "S2-4 Specialist Advises Follow-up X-ray",
    meetsS2: "Meets S2 Criteria",
    redirectAfterNegativeCxr: "Redirect: Ongoing Unexplained Symptoms After Negative Chest X-ray",
    alternativeManagement: "Alternative Management Recommended",
    nf01PneumoniaFollowUp: "NF-01 Routine Pneumonia Follow-up Outside S2",
    nf02AsbestosSurveillance: "NF-02 Asbestos Exposure Surveillance",
    nf03HeartMurmur: "NF-03 Heart Murmur Without Complications",
    nf04LungCancerScreening: "NF-04 Lung Cancer Screening",
    nf05NoduleFollowUp: "NF-05 Nodule Follow-up Without Specialist Recommendation",
    nf06TbScreening: "NF-06 TB Screening Without Positive Skin Or Blood Test",
    nf07RibViews: "NF-07 Rib Views",
    nf08Immigration: "NF-08 Immigration Purposes",
    nf10Hypertension: "NF-10 Routine Investigation Of Hypertension",
    nf11DrugMonitoring: "NF-11 Routine Monitoring On Pneumotoxic Medication",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'X-ray Chest - Adult',
    criteriaVersion: '2.0 (published 09/04/2026)',
    determination: "Determination",
    priorityCode: "Priority Code",
    priorityTimeframe: "Priority Timeframe",
    activeRedirects: "Active Redirects",
    unconfirmedExclusions: "Unconfirmed Exclusions",
    missingInformation: "Missing Information",
    inferredIndicators: "Inferred Indicators",
    inferredExcludedByStrictStandard: "Inferred Indicators Excluded By Strict Standard",
    retrievedIndicators: "Retrieved Indicators",
    ruleTrace: "Rule Trace"
  }
