/*
  CRR National Community Referral Criteria for Imaging (Part I)
  CT Head - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    Section:    Adult CT > CT Head - Adult, pages 20-22 (footnotes *1-*4 on pp.21-22)
    Repo copy:  documents/reference/National Primary Care Referral Criteria for Imaging.pdf

  STATUS
    NOT CLINICALLY REVIEWED. Transcribed 2026-10-15 for staging demonstration only
    (AD-35). Every genuine ambiguity is a REVIEW Qn below; the most literal reading
    of the published text is encoded at each one.

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the published
    wording verbatim, with page reference. A define with no SOURCE comment is
    engineering plumbing, not a clinical rule. Review is a side-by-side check of
    each SOURCE quote against the define beneath it.

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-CT-Head-Adult" (Questionnaire-ct-head-adult.json). Answer
    evidence extension, documentation standard and three-valued logic exactly as
    in CRR_CTChestAbdomenPelvis_Adult: an unanswered indicator is NULL and
    propagates as "insufficient information".

  NATIONAL RED FLAGS
    Not re-encoded here (CRR_RedFlags runs first). CT Head prints no "Refer for
    acute assessment without initial imaging" row. redflag.suspectedTIA is read
    here only as the stem of the Acute TIA criterion; RF-10 (US Carotid p34) is
    the national library's.

  REVIEW QUESTIONS (listed in signoff.md and transcription-notes.md)
    Q1  TIA high-risk feature "Less than 59 years old" (*1, p21) - encoded literally
        as age < 59. Clinically unexpected (ABCD2 scores age >= 60).
    Q2  "within 7 days of the TIA episode" - encoded as days since episode <= 7
        (day 7 included).
    Q3  First-seizure P2 bullet (p21) carries a duplicated / garbled clause. Encoded
        as the union of every printed clause: (clear history AND low risk) OR
        (MRI not available AND clear history AND low risk) OR MRI not available.
        Alternative: CT only where MRI is not available.
    Q4  Determination precedence: not funded -> alternative management -> paediatric
        -> Acute -> P2 -> P4. A redirect outranks a met criterion (CT CAP Q5
        convention). Consequence: every seizure in a patient older than 40 (a *4
        risk factor) is redirected, including "Seizure in palliative care setting"
        (Acute) - see scenarios CTH-S31/S32.
    Q5  Highest tier met wins even when a higher tier is still unknown (P2 met with
        Acute unanswered returns P2, not insufficient information).
    Q6  "History of anticoagulation" (*3/*4) vs "Anticoagulant therapy" (*2) and
        "On anticoagulants" (*1): two indicators (history vs current therapy);
        current therapy also satisfies "history of".
    Q7  "History of cancers with propensity to brain metastases – lung, melanoma,
        breast" (p21 row) vs "(e.g. lung, melanoma, breast)" (*2, p22): one
        judgement indicator; the list is not used as a closed set.
    Q8  "Fever, systemic symptoms" and "History of anticoagulation, malignancy"
        (*3/*4): comma read as a list separator (either item is a risk factor).
    Q9  "Gait ataxia or incontinence": incontinence reuses the national indicator
        redflag.bowelOrBladderIncontinence ("Loss of bowel or bladder control").
    Q10 "Focal neurologic signs" (Acute), "Presence of focal neurological signs"
        (*2), "New focal neurologic deficit" (*3/*4) and "objective neurological
        deficit causing disturbances of speech, or limb or facial weakness" (P2
        headache): first two are one indicator; the other two are separate.
    Q11 "associated with persistent nausea and vomiting": both nausea and vomiting
        required ("and" literal). Matrix RP-000 (nausea only, blurred vision) then
        does not meet P2 - evaluator expected it to proceed.
    Q12 "Seizures with risk factors for intracranial pathology" redirect applies to
        any seizure (first or not); "Seizure in palliative care setting" applies to
        any seizure.
    Q13 "Established, advanced dementia of more than 2 years duration" - duration
        > 2 years strictly (2 years exactly is not "more than").
    Q14 "Suspected Prolactinoma" redirect is not listed as an unconfirmed exclusion
        when unanswered (it is a presentation, not a general exclusion); the seizure
        redirects are listed only when a seizure is present.
    Q15 The TIA high-risk footnote *1 and national RF-10 ("a high seven day stroke
        risk*", US Carotid p34, which points at *1) overlap: a TIA with high-risk
        features may stop at the national layer if redflag.highSevenDayStrokeRisk
        is answered.
    Q16 "consider seeking neurologist advice first" (focal neurologic signs) is
        advice, not a condition: not encoded.
    Q17 The printed stem "TIA" (p20) is read through the national indicator
        redflag.suspectedTIA ("Suspected transient ischaemic attack"); under the
        extraction contract a "?TIA" query alone does not establish it as documented.
    Q18 Four new indicators rest on the referrer's judgement (AD-17 candidates):
        symptom.seizureClearHistory, workup.suitableForCommunityManagement,
        workup.resultMayChangeManagement, workup.subtypeDiagnosisAltersManagement.
        Not added to the vocabulary's attestationIndicators here.
*/

library CRR_CTHead_Adult version '1.0.0'

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
// Plumbing: QuestionnaireResponse access (copied unchanged from CT CAP)
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
// Acute: Within 48 hours - TIA
// ---------------------------------------------------------------------------

/*
  SOURCE (p20, Acute: Within 48 hours, bullet 1):
  "TIA, where it is within 7 days of the TIA episode and"
  REVIEW Q2 - "within 7 days" read as days since the episode <= 7 (day 7 included).
*/
define "TIA Within 7 Days":
  "Bool"('redflag.suspectedTIA')
    and "Dec"('symptom.tiaDaysSinceEpisode') <= 7.0

/*
  SOURCE (p20, Acute, bullet 1, sub-bullet 1):
  "CT +/-CTA recommended by HNZ neurologist / stroke specialist or physician."
*/
define "TIA Route 1: Recommended By Neurologist Stroke Specialist Or Physician":
  "Bool"('advice.strokeSpecialistRecommended')

/*
  SOURCE (p21-22, footnote "*1 High risk features for TIA"):
  "Less than 59 years old" / "ABCD2 greater than 4" / "Crescendo TIAs" /
  "Atrial fibrillation" / "On anticoagulants" / "Severe or prolonged deficit
  (hemiparesis longer than 60 minutes)" / "Known carotid artery stenosis."
  REVIEW Q1 - "Less than 59 years old" encoded literally (age < 59).
  REVIEW Q6 - "On anticoagulants" = history.anticoagulantTherapy (current therapy).
*/
define "TIA High-Risk: Less Than 59 Years Old": "Age In Years" < 59
define "TIA High-Risk: ABCD2 Greater Than 4": "Int"('workup.abcd2Score') > 4
define "TIA High-Risk: Crescendo TIAs": "Bool"('symptom.crescendoTIA')
define "TIA High-Risk: Atrial Fibrillation": "Bool"('history.atrialFibrillation')
define "TIA High-Risk: On Anticoagulants": "Bool"('history.anticoagulantTherapy')
define "TIA High-Risk: Severe Or Prolonged Deficit": "Bool"('symptom.tiaSevereOrProlongedDeficit')
define "TIA High-Risk: Known Carotid Artery Stenosis": "Bool"('history.carotidStenosis')

define "Any TIA High-Risk Feature":
  "TIA High-Risk: Less Than 59 Years Old"
    or "TIA High-Risk: ABCD2 Greater Than 4"
    or "TIA High-Risk: Crescendo TIAs"
    or "TIA High-Risk: Atrial Fibrillation"
    or "TIA High-Risk: On Anticoagulants"
    or "TIA High-Risk: Severe Or Prolonged Deficit"
    or "TIA High-Risk: Known Carotid Artery Stenosis"

/*
  SOURCE (p20, Acute, bullet 1, sub-bullet 2):
  "Patient has no high-risk features *1 and assessed as suitable for being managed
   in the community AND completion of the BPAC TIA decision support tool indicates
   CT head +/- carotid imaging is appropriate."
*/
define "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool":
  not "Any TIA High-Risk Feature"
    and "Bool"('workup.suitableForCommunityManagement')
    and "Bool"('advice.decisionSupportToolCompleted')

/*
  SOURCE (p20, Acute, bullet 1, sub-bullet 3):
  "Patient is unable to access rapid specialist care."
*/
define "TIA Route 3: Unable To Access Rapid Specialist Care":
  not "Bool"('advice.rapidSpecialistCareAccessible')

/*
  SOURCE (p20, Acute, bullet 1 as a whole): "TIA, where it is within 7 days of the
   TIA episode and [route 1] OR [route 2] OR [route 3]"
*/
define "Pathway Acute: TIA":
  "TIA Within 7 Days"
    and (
      "TIA Route 1: Recommended By Neurologist Stroke Specialist Or Physician"
        or "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool"
        or "TIA Route 3: Unable To Access Rapid Specialist Care"
    )

// ---------------------------------------------------------------------------
// Acute: Within 48 hours - other bullets
// ---------------------------------------------------------------------------

/*
  SOURCE (p20, Acute, bullet 2):
  "Focal neurologic signs - consider seeking neurologist advice first"
  REVIEW Q16 - "consider seeking neurologist advice first" is advice, not a condition.
  REVIEW Q10 - same indicator as *2 "Presence of focal neurological signs".
*/
define "Focal Neurological Signs": "Bool"('symptom.focalNeurologicalSigns')

define "Pathway Acute: Focal Neurologic Signs": "Focal Neurological Signs"

/*
  SOURCE (p20, Acute, bullet 3):
  "Seizure in palliative care setting and result may change management."
  REVIEW Q12 - any seizure; a first seizure is a seizure.
*/
define "Seizure Present":
  "Bool"('symptom.seizure') or "Bool"('symptom.firstSeizure')

define "Pathway Acute: Seizure In Palliative Care":
  "Seizure Present"
    and "Bool"('history.palliativeCare')
    and "Bool"('workup.resultMayChangeManagement')

/*
  SOURCE (p20, Acute, bullet 4):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist
   advises referral for same or next day CT scan."
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison, always
   include the name and role of that person in the referral."
*/
define "Pathway Acute: Specialist Advises Same Or Next Day CT":
  "Bool"('advice.acuteImagingRecommended')

/*
  SOURCE (p20, Timeframe column): "Acute: Within 48 hours"
*/
define "Meets Acute 48h Criteria":
  "Is Adult"
    and (
      "Pathway Acute: TIA"
        or "Pathway Acute: Focal Neurologic Signs"
        or "Pathway Acute: Seizure In Palliative Care"
        or "Pathway Acute: Specialist Advises Same Or Next Day CT"
    )

// ---------------------------------------------------------------------------
// P2 Urgent - headaches
// ---------------------------------------------------------------------------

/*
  SOURCE (p20, P2 Urgent, bullet 1):
  "Headaches: A change in the pattern of headaches, with a progressive increase in
   frequency or severity, especially in patients aged 50 years and older
   AND any of:
   o chronic illness associated with potential cerebral complications or
     involvement, especially malignancy. The most likely cancers to metastasise to
     the brain are lung, breast, and melanoma.
   o exacerbated by coughing, sneezing, or Valsalva manoeuvre in a pattern not
     typical of a migraine.
   o associated with persistent nausea and vomiting (i.e. not typical of a migraine
     or other primary headache)
   o objective neurological deficit causing disturbances of speech, or limb or
     facial weakness."
  Modifiers NOT encoded (KI-05): "especially in patients aged 50 years and older"
  (matrix RP-000), "especially malignancy", "The most likely cancers to metastasise
  to the brain are lung, breast, and melanoma."
  REVIEW Q11 - "persistent nausea and vomiting": both required.
  REVIEW Q10 - the neurological-deficit item is its own indicator.
*/
define "Headache Pattern Change With Progressive Increase":
  "Bool"('symptom.headachePatternChangeProgressive')

define "Headache Feature: Chronic Illness With Potential Cerebral Involvement":
  "Bool"('history.chronicIllnessWithCerebralInvolvement')
define "Headache Feature: Exacerbated By Coughing Sneezing Or Valsalva":
  "Bool"('symptom.headacheWorseOnCoughSneezeValsalva')
define "Headache Feature: Persistent Nausea And Vomiting":
  "Bool"('symptom.headachePersistentNauseaVomiting')
define "Headache Feature: Objective Neurological Deficit":
  "Bool"('symptom.neuroDeficitSpeechOrWeakness')

define "Any Headache Feature":
  "Headache Feature: Chronic Illness With Potential Cerebral Involvement"
    or "Headache Feature: Exacerbated By Coughing Sneezing Or Valsalva"
    or "Headache Feature: Persistent Nausea And Vomiting"
    or "Headache Feature: Objective Neurological Deficit"

define "Pathway P2: Headache":
  "Headache Pattern Change With Progressive Increase" and "Any Headache Feature"

// ---------------------------------------------------------------------------
// P2 Urgent / P4 Deferrable - cognitive impairment
// ---------------------------------------------------------------------------

/*
  SOURCE (p20-21, P2 Urgent, bullet 2):
  "Cognitive impairment with 1 or more features to suggest symptoms are secondary
   to a space-occupying lesion (SOL), bleed, or hydrocephalus *2:
   o Rapid cognitive decline over weeks
   o Presence of focal neurological signs
   o History of falls
   o Anticoagulant therapy
   o Gait ataxia or incontinence.
   o History of cancers with propensity to brain metastases – lung, melanoma, breast"
  SOURCE (p22, footnote "*2 Features suggestive of underlying SOL, bleed, or
   hydrocephalus"): same six features; last reads "History of cancers with
   propensity to brain metastases (e.g. lung, melanoma, breast)".
  REVIEW Q7 - cancer list: "–" on p21, "(e.g." on p22; one judgement indicator.
  REVIEW Q9 - incontinence = redflag.bowelOrBladderIncontinence.
*/
define "Cognitive Impairment": "Bool"('symptom.cognitiveImpairment')

define "SOL Feature: Rapid Cognitive Decline Over Weeks": "Bool"('symptom.rapidCognitiveDecline')
define "SOL Feature: Focal Neurological Signs": "Focal Neurological Signs"
define "SOL Feature: History Of Falls": "Bool"('history.falls')
define "SOL Feature: Anticoagulant Therapy": "Bool"('history.anticoagulantTherapy')
define "SOL Feature: Gait Ataxia Or Incontinence":
  "Bool"('symptom.gaitAtaxia') or "Bool"('redflag.bowelOrBladderIncontinence')
define "SOL Feature: Cancer With Propensity To Brain Metastases":
  "Bool"('history.cancerWithBrainMetastasisPropensity')

define "Any SOL Feature":
  "SOL Feature: Rapid Cognitive Decline Over Weeks"
    or "SOL Feature: Focal Neurological Signs"
    or "SOL Feature: History Of Falls"
    or "SOL Feature: Anticoagulant Therapy"
    or "SOL Feature: Gait Ataxia Or Incontinence"
    or "SOL Feature: Cancer With Propensity To Brain Metastases"

define "Pathway P2: Cognitive Impairment With SOL Feature":
  "Cognitive Impairment" and "Any SOL Feature"

/*
  SOURCE (p21, P4 Deferrable, bullet 1):
  "Cognitive impairment without any features suggestive of SOL, bleed, or
   hydrocephalus*2: and establishing the subtype diagnosis will alter management."
*/
define "Subtype Diagnosis Will Alter Management":
  "Bool"('workup.subtypeDiagnosisAltersManagement')

define "Pathway P4: Cognitive Impairment Without SOL Features":
  "Cognitive Impairment"
    and not "Any SOL Feature"
    and "Subtype Diagnosis Will Alter Management"

// ---------------------------------------------------------------------------
// P2 Urgent - first seizure
// ---------------------------------------------------------------------------

/*
  SOURCE (p22, footnote "*4 Risk factors for intracranial pathology", identical to
  the list inside *3): "Head injury" / "Aged older than 40" / "Fever, systemic
  symptoms" / "History of anticoagulation, malignancy" / "New focal neurologic
  deficit" / "Focal seizure" / "Persistent altered mental state" / "Persistent
  headache"
  REVIEW Q8 - commas read as list separators (either item is a risk factor).
  REVIEW Q6 - current anticoagulant therapy also counts as a history of
  anticoagulation; a cancer with brain-metastasis propensity is a malignancy.
*/
define "Risk Factor: Head Injury": "Bool"('history.headInjury')
define "Risk Factor: Aged Older Than 40": "Age In Years" > 40
define "Risk Factor: Fever": "Bool"('symptom.fever')
define "Risk Factor: Systemic Symptoms": "Bool"('symptom.systemicSymptoms')
define "Risk Factor: History Of Anticoagulation":
  "Bool"('history.anticoagulation') or "Bool"('history.anticoagulantTherapy')
define "Risk Factor: History Of Malignancy":
  "Bool"('history.malignancy') or "Bool"('history.cancerWithBrainMetastasisPropensity')
define "Risk Factor: New Focal Neurologic Deficit": "Bool"('symptom.newFocalNeurologicalDeficit')
define "Risk Factor: Focal Seizure": "Bool"('symptom.seizureFocal')
define "Risk Factor: Persistent Altered Mental State": "Bool"('symptom.persistentAlteredMentalState')
define "Risk Factor: Persistent Headache": "Bool"('symptom.headachePersistent')

define "Any Risk Factor For Intracranial Pathology":
  "Risk Factor: Head Injury"
    or "Risk Factor: Aged Older Than 40"
    or "Risk Factor: Fever"
    or "Risk Factor: Systemic Symptoms"
    or "Risk Factor: History Of Anticoagulation"
    or "Risk Factor: History Of Malignancy"
    or "Risk Factor: New Focal Neurologic Deficit"
    or "Risk Factor: Focal Seizure"
    or "Risk Factor: Persistent Altered Mental State"
    or "Risk Factor: Persistent Headache"

/*
  SOURCE (p22, footnote "*3 Criteria for low-risk first seizure – all of the
  following must apply"):
  "Single seizure which is unprovoked, or provoked by a known substance (e.g. drug
   or alcohol use)" / "Patient has since returned to normal health" / "There are
   none of the following risk factors for intracranial pathology: [as *4]"
  "e.g. drug or alcohol use" illustrates "known substance"; not encoded separately.
*/
define "Low Risk First Seizure":
  "Bool"('symptom.seizureSingle')
    and "Bool"('symptom.seizureUnprovokedOrSubstanceProvoked')
    and "Bool"('symptom.returnedToNormalHealth')
    and not "Any Risk Factor For Intracranial Pathology"

/*
  SOURCE (p21, P2 Urgent, bullet 3):
  "First seizure in patient aged 21 years or older, where there is a clear history
   and the patient is low risk3, or where MRI (preferred first-line investigation)
   is not available, clear history, and low risk* or MRI not available"
  REVIEW Q3 - the bullet repeats a clause. Encoded as the union of the three
  printed clauses (which reduces to: clear history and low risk, or MRI not
  available). "low risk3" and "low risk*" both read as footnote *3.
  "(preferred first-line investigation)" is explanatory, not a condition.
*/
define "First Seizure Aged 21 Or Older":
  "Bool"('symptom.firstSeizure') and "Age In Years" >= 21

define "Seizure Clear History": "Bool"('symptom.seizureClearHistory')

define "MRI Not Available": not "Bool"('advice.mriAvailable')

define "First Seizure: Clear History And Low Risk":
  "Seizure Clear History" and "Low Risk First Seizure"

define "Pathway P2: First Seizure":
  "First Seizure Aged 21 Or Older"
    and (
      "First Seizure: Clear History And Low Risk"
        or ("MRI Not Available" and "Seizure Clear History" and "Low Risk First Seizure")
        or "MRI Not Available"
    )

/*
  SOURCE (p21, P2 Urgent, bullet 4):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist
   advises referral for urgent CT scan."
*/
define "Pathway P2: Specialist Advises Urgent CT":
  "Bool"('advice.urgentImagingRecommended')

/*
  SOURCE (p20, Timeframe column): "P2 Urgent: Non-deferrable imaging or
   intervention that must be completed within 2 weeks of receiving referral."
*/
define "Meets P2 Criteria":
  "Is Adult"
    and (
      "Pathway P2: Headache"
        or "Pathway P2: Cognitive Impairment With SOL Feature"
        or "Pathway P2: First Seizure"
        or "Pathway P2: Specialist Advises Urgent CT"
    )

// ---------------------------------------------------------------------------
// P4 Deferrable
// ---------------------------------------------------------------------------

/*
  SOURCE (p21, P4 Deferrable, bullet 2):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist
   advises referral for non-urgent, CT scan."
*/
define "Pathway P4: Specialist Advises Non-Urgent CT":
  "Bool"('advice.nonUrgentImagingRecommended')

/*
  SOURCE (p21, Timeframe column): "P4 Deferrable. If capacity is constrained could
   wait up to 6-12 weeks from receiving referral."
*/
define "Meets P4 Criteria":
  "Is Adult"
    and (
      "Pathway P4: Cognitive Impairment Without SOL Features"
        or "Pathway P4: Specialist Advises Non-Urgent CT"
    )

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (redirects)
// ---------------------------------------------------------------------------

/*
  SOURCE (p21, "Alternative management or HealthPathway recommended."):
   - "Suspected Prolactinoma – request non-acute assessment by the appropriate
      secondary care specialist."
   - "Seizures with risk factors for intracranial pathology4 – seek Neurology phone
      advice"
   - "Poorly controlled or recurrent seizures – follow the appropriate pathway:
      Epilepsy in Adults / Epilepsy in Women / First Seizure in Adults / Seizure in
      Palliative Care"
  A redirect is active only when known true (absence of information does not
  block a referral). REVIEW Q12 - "Seizures" read as any seizure. REVIEW Q14 -
  which unknown redirects are surfaced.
*/
define "Redirect: Suspected Prolactinoma": "Bool"('symptom.suspectedProlactinoma')
define "Redirect: Seizures With Risk Factors For Intracranial Pathology":
  "Seizure Present" and "Any Risk Factor For Intracranial Pathology"
define "Redirect: Poorly Controlled Or Recurrent Seizures":
  "Bool"('symptom.seizuresPoorlyControlledOrRecurrent')

define "Active Redirects":
  (List<String>{
    if "Redirect: Suspected Prolactinoma" is true then 'Suspected Prolactinoma – request non-acute assessment by the appropriate secondary care specialist.' else null,
    if "Redirect: Seizures With Risk Factors For Intracranial Pathology" is true then 'Seizures with risk factors for intracranial pathology – seek Neurology phone advice' else null,
    if "Redirect: Poorly Controlled Or Recurrent Seizures" is true then 'Poorly controlled or recurrent seizures – follow the appropriate pathway: Epilepsy in Adults; Epilepsy in Women; First Seizure in Adults; Seizure in Palliative Care' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

// The *4 risk-factor linkIds still unanswered (only those that could still make the redirect true).
define "Unanswered Risk Factor LinkIds":
  if "Any Risk Factor For Intracranial Pathology" is true then {} as List<String>
  else (List<String>{
    if "Risk Factor: Head Injury" is null then 'history.headInjury' else null,
    if "Risk Factor: Aged Older Than 40" is null then 'patient.age' else null,
    if "Risk Factor: Fever" is null then 'symptom.fever' else null,
    if "Risk Factor: Systemic Symptoms" is null then 'symptom.systemicSymptoms' else null,
    if "Risk Factor: History Of Anticoagulation" is null then 'history.anticoagulation' else null,
    if "Risk Factor: History Of Malignancy" is null then 'history.malignancy' else null,
    if "Risk Factor: New Focal Neurologic Deficit" is null then 'symptom.newFocalNeurologicalDeficit' else null,
    if "Risk Factor: Focal Seizure" is null then 'symptom.seizureFocal' else null,
    if "Risk Factor: Persistent Altered Mental State" is null then 'symptom.persistentAlteredMentalState' else null,
    if "Risk Factor: Persistent Headache" is null then 'symptom.headachePersistent' else null
  }) M where M is not null

define "Unconfirmed Exclusions":
  if "Seizure Present" is not true then {} as List<String>
  else
    (if "Redirect: Seizures With Risk Factors For Intracranial Pathology" is null then "Unanswered Risk Factor LinkIds" else {} as List<String>)
      union ((List<String>{
        if "Redirect: Poorly Controlled Or Recurrent Seizures" is null then 'symptom.seizuresPoorlyControlledOrRecurrent' else null
      }) M where M is not null)

// ---------------------------------------------------------------------------
// Not routinely funded
// ---------------------------------------------------------------------------

/*
  SOURCE (p21, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
   - "Established, advanced dementia of more than 2 years duration, no unexpected
      change in disease progression and establishing the subtype will not alter
      management."
  REVIEW Q13 - "more than 2 years" is > 2.0 years.
  "establishing the subtype will not alter management" is the negation of the P4
  indicator workup.subtypeDiagnosisAltersManagement (one concept, KI-01).
*/
define "Not Routinely Funded":
  Coalesce(
    "Bool"('history.dementiaEstablishedAdvanced')
      and "Dec"('history.dementiaDurationYears') > 2.0
      and not "Bool"('symptom.dementiaUnexpectedChange')
      and not "Subtype Diagnosis Will Alter Management",
    false
  )

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q4, Q5 - confirm):
    1. Not routinely funded
    2. Alternative management / redirect
    3. Paediatric patient - the adult criteria do not apply (BRD TA-003)
    4. Acute criteria met (highest timeframe met wins; P1 > Acute > P2 > P3 > P4)
    5. P2 criteria met
    6. P4 criteria met
    7. Every timeframe definitively not met
    8. Insufficient information
*/
define "Determination":
  case
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P4 Criteria" is true then 'P4_DEFERRABLE'
    when "Meets Acute 48h Criteria" is false and "Meets P2 Criteria" is false and "Meets P4 Criteria" is false then 'CRITERIA_NOT_MET'
    else 'INSUFFICIENT_INFORMATION'
  end

define "Priority Code":
  case "Determination"
    when 'ACUTE_48H' then 'A48'
    when 'P2_URGENT' then 'P2'
    when 'P4_DEFERRABLE' then 'P4'
    else null
  end

/*
  SOURCE (p20): "Acute: Within 48 hours"; "P2 Urgent: Non-deferrable imaging or
   intervention that must be completed within 2 weeks of receiving referral."
  SOURCE (p21): "P4 Deferrable. If capacity is constrained could wait up to 6-12
   weeks from receiving referral."
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_48H' then 'Within 48 hours'
    when 'P2_URGENT' then 'Must be completed within 2 weeks of receiving referral'
    when 'P4_DEFERRABLE' then 'If capacity is constrained could wait up to 6-12 weeks from receiving referral'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

/*
  A pathway's own sub-indicators are asked for only once its presentation (stem)
  is known to be present; until then only the stem is asked for. Single-indicator
  pathways (focal signs, the three advice gateways) are their own stem.
*/
define "Missing Stem Indicators":
  (List<String>{
    if "Age In Years" is null then 'patient.age' else null,
    if "Bool"('redflag.suspectedTIA') is null then 'redflag.suspectedTIA' else null,
    if "Focal Neurological Signs" is null then 'symptom.focalNeurologicalSigns' else null,
    if "Seizure Present" is null then 'symptom.seizure' else null,
    if "Headache Pattern Change With Progressive Increase" is null then 'symptom.headachePatternChangeProgressive' else null,
    if "Cognitive Impairment" is null then 'symptom.cognitiveImpairment' else null,
    if "Bool"('symptom.firstSeizure') is null then 'symptom.firstSeizure' else null,
    if "Pathway Acute: Specialist Advises Same Or Next Day CT" is null then 'advice.acuteImagingRecommended' else null,
    if "Pathway P2: Specialist Advises Urgent CT" is null then 'advice.urgentImagingRecommended' else null,
    if "Pathway P4: Specialist Advises Non-Urgent CT" is null then 'advice.nonUrgentImagingRecommended' else null
  }) M where M is not null

define "Missing TIA Indicators":
  if "Bool"('redflag.suspectedTIA') is not true or "Pathway Acute: TIA" is not null then {} as List<String>
  else (List<String>{
    if "Dec"('symptom.tiaDaysSinceEpisode') is null then 'symptom.tiaDaysSinceEpisode' else null,
    if "TIA Route 1: Recommended By Neurologist Stroke Specialist Or Physician" is null then 'advice.strokeSpecialistRecommended' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: ABCD2 Greater Than 4" is null then 'workup.abcd2Score' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: Crescendo TIAs" is null then 'symptom.crescendoTIA' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: Atrial Fibrillation" is null then 'history.atrialFibrillation' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: On Anticoagulants" is null then 'history.anticoagulantTherapy' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: Severe Or Prolonged Deficit" is null then 'symptom.tiaSevereOrProlongedDeficit' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "TIA High-Risk: Known Carotid Artery Stenosis" is null then 'history.carotidStenosis' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "Bool"('workup.suitableForCommunityManagement') is null then 'workup.suitableForCommunityManagement' else null,
    if "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool" is null and "Bool"('advice.decisionSupportToolCompleted') is null then 'advice.decisionSupportToolCompleted' else null,
    if "TIA Route 3: Unable To Access Rapid Specialist Care" is null then 'advice.rapidSpecialistCareAccessible' else null
  }) M where M is not null

define "Missing Headache Indicators":
  if "Headache Pattern Change With Progressive Increase" is not true or "Pathway P2: Headache" is not null then {} as List<String>
  else (List<String>{
    if "Headache Feature: Chronic Illness With Potential Cerebral Involvement" is null then 'history.chronicIllnessWithCerebralInvolvement' else null,
    if "Headache Feature: Exacerbated By Coughing Sneezing Or Valsalva" is null then 'symptom.headacheWorseOnCoughSneezeValsalva' else null,
    if "Headache Feature: Persistent Nausea And Vomiting" is null then 'symptom.headachePersistentNauseaVomiting' else null,
    if "Headache Feature: Objective Neurological Deficit" is null then 'symptom.neuroDeficitSpeechOrWeakness' else null
  }) M where M is not null

define "Missing Cognitive Indicators":
  if "Cognitive Impairment" is not true then {} as List<String>
  else (List<String>{
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "SOL Feature: Rapid Cognitive Decline Over Weeks" is null then 'symptom.rapidCognitiveDecline' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "SOL Feature: Focal Neurological Signs" is null then 'symptom.focalNeurologicalSigns' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "SOL Feature: History Of Falls" is null then 'history.falls' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "SOL Feature: Anticoagulant Therapy" is null then 'history.anticoagulantTherapy' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "Bool"('symptom.gaitAtaxia') is null then 'symptom.gaitAtaxia' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "Bool"('redflag.bowelOrBladderIncontinence') is null then 'redflag.bowelOrBladderIncontinence' else null,
    if "Pathway P2: Cognitive Impairment With SOL Feature" is null and "SOL Feature: Cancer With Propensity To Brain Metastases" is null then 'history.cancerWithBrainMetastasisPropensity' else null,
    if "Pathway P4: Cognitive Impairment Without SOL Features" is null and "Subtype Diagnosis Will Alter Management" is null then 'workup.subtypeDiagnosisAltersManagement' else null
  }) M where M is not null

define "Missing First Seizure Indicators":
  if "Bool"('symptom.firstSeizure') is not true or "Pathway P2: First Seizure" is not null then {} as List<String>
  else
    ((List<String>{
      if "First Seizure: Clear History And Low Risk" is null and "Seizure Clear History" is null then 'symptom.seizureClearHistory' else null,
      if "First Seizure: Clear History And Low Risk" is null and "Bool"('symptom.seizureSingle') is null then 'symptom.seizureSingle' else null,
      if "First Seizure: Clear History And Low Risk" is null and "Bool"('symptom.seizureUnprovokedOrSubstanceProvoked') is null then 'symptom.seizureUnprovokedOrSubstanceProvoked' else null,
      if "First Seizure: Clear History And Low Risk" is null and "Bool"('symptom.returnedToNormalHealth') is null then 'symptom.returnedToNormalHealth' else null,
      if "MRI Not Available" is null then 'advice.mriAvailable' else null
    }) M where M is not null)
    union (if "First Seizure: Clear History And Low Risk" is null then "Unanswered Risk Factor LinkIds" else {} as List<String>)

define "Missing Palliative Seizure Indicators":
  if "Seizure Present" is not true or "Pathway Acute: Seizure In Palliative Care" is not null then {} as List<String>
  else (List<String>{
    if "Bool"('history.palliativeCare') is null then 'history.palliativeCare' else null,
    if "Bool"('history.palliativeCare') is true and "Bool"('workup.resultMayChangeManagement') is null then 'workup.resultMayChangeManagement' else null
  }) M where M is not null

define "Adviser Name And Role Documented":
  "Is Answered"('advice.adviserNameRole')

define "Missing Advice Indicators":
  (List<String>{
    if ("Pathway Acute: Specialist Advises Same Or Next Day CT" is true
          or "Pathway P2: Specialist Advises Urgent CT" is true
          or "Pathway P4: Specialist Advises Non-Urgent CT" is true
          or "TIA Route 1: Recommended By Neurologist Stroke Specialist Or Physician" is true)
        and not "Adviser Name And Role Documented"
      then 'advice.adviserNameRole' else null
  }) M where M is not null

define "Missing Information":
  if "Determination" in { 'ACUTE_48H', 'P2_URGENT', 'P4_DEFERRABLE', 'ALTERNATIVE_MANAGEMENT', 'NOT_ROUTINELY_FUNDED', 'PAEDIATRIC_CRITERIA_APPLY' }
    then "Missing Advice Indicators"
  else "Missing Stem Indicators"
    union "Missing TIA Indicators"
    union "Missing Headache Indicators"
    union "Missing Cognitive Indicators"
    union "Missing First Seizure Indicators"
    union "Missing Palliative Seizure Indicators"
    union "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age',
    'redflag.suspectedTIA', 'redflag.bowelOrBladderIncontinence',
    'symptom.tiaDaysSinceEpisode', 'symptom.crescendoTIA', 'symptom.tiaSevereOrProlongedDeficit',
    'symptom.focalNeurologicalSigns', 'symptom.seizure',
    'symptom.headachePatternChangeProgressive', 'symptom.headacheWorseOnCoughSneezeValsalva',
    'symptom.headachePersistentNauseaVomiting', 'symptom.neuroDeficitSpeechOrWeakness',
    'symptom.cognitiveImpairment', 'symptom.rapidCognitiveDecline', 'symptom.gaitAtaxia',
    'symptom.firstSeizure', 'symptom.seizureClearHistory', 'symptom.seizureSingle',
    'symptom.seizureUnprovokedOrSubstanceProvoked', 'symptom.returnedToNormalHealth',
    'symptom.fever', 'symptom.systemicSymptoms', 'symptom.newFocalNeurologicalDeficit',
    'symptom.seizureFocal', 'symptom.persistentAlteredMentalState', 'symptom.headachePersistent',
    'symptom.seizuresPoorlyControlledOrRecurrent', 'symptom.suspectedProlactinoma',
    'symptom.dementiaUnexpectedChange',
    'history.anticoagulantTherapy', 'history.anticoagulation', 'history.malignancy',
    'history.cancerWithBrainMetastasisPropensity', 'history.chronicIllnessWithCerebralInvolvement',
    'history.falls', 'history.headInjury', 'history.atrialFibrillation', 'history.carotidStenosis',
    'history.palliativeCare', 'history.dementiaEstablishedAdvanced', 'history.dementiaDurationYears',
    'workup.abcd2Score', 'workup.suitableForCommunityManagement', 'workup.resultMayChangeManagement',
    'workup.subtypeDiagnosisAltersManagement',
    'advice.strokeSpecialistRecommended', 'advice.decisionSupportToolCompleted',
    'advice.rapidSpecialistCareAccessible', 'advice.mriAvailable',
    'advice.acuteImagingRecommended', 'advice.urgentImagingRecommended',
    'advice.nonUrgentImagingRecommended', 'advice.adviserNameRole'
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
    tiaWithin7Days: "TIA Within 7 Days",
    tiaRoute1SpecialistRecommended: "TIA Route 1: Recommended By Neurologist Stroke Specialist Or Physician",
    anyTiaHighRiskFeature: "Any TIA High-Risk Feature",
    tiaRoute2CommunityBpac: "TIA Route 2: No High-Risk Features, Community Management, BPAC Tool",
    tiaRoute3NoRapidAccess: "TIA Route 3: Unable To Access Rapid Specialist Care",
    acuteTia: "Pathway Acute: TIA",
    acuteFocalNeurologicSigns: "Pathway Acute: Focal Neurologic Signs",
    seizurePresent: "Seizure Present",
    acuteSeizureInPalliativeCare: "Pathway Acute: Seizure In Palliative Care",
    acuteSpecialistAdvice: "Pathway Acute: Specialist Advises Same Or Next Day CT",
    meetsAcute: "Meets Acute 48h Criteria",
    headachePatternChange: "Headache Pattern Change With Progressive Increase",
    anyHeadacheFeature: "Any Headache Feature",
    p2Headache: "Pathway P2: Headache",
    cognitiveImpairment: "Cognitive Impairment",
    anySolFeature: "Any SOL Feature",
    p2Cognitive: "Pathway P2: Cognitive Impairment With SOL Feature",
    firstSeizureAged21OrOlder: "First Seizure Aged 21 Or Older",
    lowRiskFirstSeizure: "Low Risk First Seizure",
    anyRiskFactorForIntracranialPathology: "Any Risk Factor For Intracranial Pathology",
    mriNotAvailable: "MRI Not Available",
    p2FirstSeizure: "Pathway P2: First Seizure",
    p2SpecialistAdvice: "Pathway P2: Specialist Advises Urgent CT",
    meetsP2: "Meets P2 Criteria",
    p4Cognitive: "Pathway P4: Cognitive Impairment Without SOL Features",
    p4SpecialistAdvice: "Pathway P4: Specialist Advises Non-Urgent CT",
    meetsP4: "Meets P4 Criteria",
    redirectProlactinoma: "Redirect: Suspected Prolactinoma",
    redirectSeizureRiskFactors: "Redirect: Seizures With Risk Factors For Intracranial Pathology",
    redirectPoorlyControlledSeizures: "Redirect: Poorly Controlled Or Recurrent Seizures",
    alternativeManagement: "Alternative Management Recommended",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'CT Head - Adult',
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
