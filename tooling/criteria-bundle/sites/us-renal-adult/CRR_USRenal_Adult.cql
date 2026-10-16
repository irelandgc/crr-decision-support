/*
  CRR National Community Referral Criteria for Imaging (Part I)
  US Renal - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    File:       documents/reference/National Primary Care Referral Criteria for Imaging.pdf
    Section:    Ultrasound > US Renal - Adult, pages 52-55 (US Scrotum starts p56)

  STATUS
    NOT CLINICALLY REVIEWED. W1 demo transcription (Gary, 2026-10-15; AD-35):
    staging only, never signed off by this session (AD-10).

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the published
    wording verbatim, with page reference. A define with no SOURCE comment is
    engineering plumbing, not a clinical rule. Review is a side-by-side check of
    each SOURCE quote against the define beneath it. Double spaces inside quotes
    are in the source.

  NOT IN THIS LIBRARY (national bundle CRR_RedFlags, runs first - AD-03)
    p52 "Refer for acute assessment without initial imaging" (pyelonephritis
    not responding / persisting) is RF-12. The p55 footnote "*1 Red flags for
    renal colic" is RF-03. Neither is re-encoded here. The p52 Acute row's
    "and no red flags* requiring admission" is therefore satisfied by the
    national library not having stopped the pipeline (REVIEW Q2).

  INPUT CONTRACT
    FHIR R4 QuestionnaireResponse conforming to Questionnaire
    "CRR-US-Renal-Adult" (Questionnaire-us-renal-adult.json), with the
    answer-evidence extension (status documented | inferred | retrieved,
    quote). An answer with no evidence extension counts as 'documented'.
    An unanswered indicator is NULL and propagates as insufficient information.

  THREE-VALUED LOGIC (deliberate): true met, false not met, null cannot be
  determined. Redirect and not-funded rows fire only when true; criteria are
  never coalesced to false.

  REVIEW QUESTIONS (listed in signoff.md and transcription-notes.md)
    Q1  "if pregnant or female younger than 35 years old" read as
        pregnant OR (female AND age < 35).
    Q2  "and no red flags* requiring admission" not re-encoded; delegated to
        national RF-03, which needs redflag.renalColicAcuteEpisode (composed
        into the Acute renal colic criterion for that reason).
    Q3  A male patient is treated as not pregnant.
    Q4  Overlap: "Suspected renal colic in a non-pregnant person" (alternative
        management) would make the "female younger than 35" limb of the Acute
        row unreachable under redirect-first precedence. The redirect is read
        as not applying to a patient who meets the Acute renal colic row.
    Q5  Overlap: "Macroscopic haematuria ... aged 40 to 85 years. Refer for
        CT IVU" would make the P2 "aged 40 to 85 years and unable to have
        intravenous contrast" limb unreachable. The redirect is read as not
        applying to a patient unable to have intravenous contrast.
    Q6  Age bands: "younger than 40" < 40; "aged 86 years and older" >= 86;
        "aged 40 to 85 years" 40..85 inclusive; "older than 50" > 50;
        "aged 50 years and younger" <= 50; "younger than 35" < 35.
    Q7  "eGFR less than 30mL/min" (P2) and "eGFR less than 30 / 45 / 60"
        (P3, no unit printed): numbers compared, units not asserted.
    Q8  "ACR more than 250": no unit printed; compared as 250, unit not
        asserted (vocabulary text assumes mg/mmol, which would make 250 an
        unusually high threshold).
    Q9  Men "recurrent UTI (i.e. 2 or more confirmed UTI)": no time window
        printed; any 2 or more confirmed UTIs.
    Q10 Women "more than 3 UTIs in a year, or more than 2 in six months despite
        prophylactic antibiotics": "despite prophylactic antibiotics" read as
        qualifying the six-month limb only; "in a year" / "in six months" read
        as the year / six months before referral. Not-funded "Recurrent UTIs in
        women, except as documented above" read from the referral's own
        statement of recurrence (symptom.utiRecurrent).
    Q11 "Urinary incontinence in men with palpable bladder, or new or
        deteriorating renal impairment" read as male AND incontinence AND
        (palpable bladder OR new/deteriorating renal impairment).
    Q12 "eGFR decreased by 15 or more within the previous 12 months" needs the
        decrease as a value; a decrease the model computes from two results
        is 'inferred'.
    Q13 Angiomyolipoma: "more than 1 cm" (redirect) and "less 1 cm" (not
        funded, read as "less than 1 cm"): a lesion of exactly 1 cm meets
        neither row.
    Q14 Timeframe order: Acute 48h > P2 > P3 > S2 > P4. A lower priority
        met while a higher one is indeterminate returns the lower priority.
    Q15 Redirect rows (AKI, LUTS, enlarged prostate / PSA, abdominal mass,
        isolated proteinuria) outrank every criterion when present, e.g. LUTS
        alongside suspected chronic urinary retention.
    Q16 Clinical-judgement wording ("Suspected chronic urinary retention",
        "Recurrent loin pain suggesting renal tract obstruction other than
        renal stone") is extracted like any fact; candidates for AD-17.
    Q18 "Serial ultrasounds of known polycystic kidneys unless ... the patient
        develops new symptoms that meet any of the other criteria" read as:
        not funded unless the radiology report indicates it or any criterion
        row in this section is met.
    Q19 "Follow up of incidental finding ... angiomyolipoma" (not funded) and
        the AML redirect are read on the finding alone; the request being a
        follow-up is not a separate indicator.
    Q20 S2 "Follow up, according to the Renal Colic and Urinary Tract Stones
        HealthPathway": the HealthPathway's own follow-up conditions are not
        evaluated; the referral's statement that this is that follow-up is the
        indicator.
    Q21 Not-funded precedence (coordinator rule R1): redirect > paediatric >
        most urgent met timeframe row > insufficient (any row undetermined) >
        not funded (only when every row is definitively not met) > not met.
        Alternative reading: not funded first, as CT CAP does for its
        patient-level "unfit for treatment" row.
    Q22 "Repeat renal ultrasound for diabetic patients with known diabetic
        renal complications": read as known diabetic renal complications AND
        a previous renal ultrasound at any time (no interval printed); the
        diabetes itself is implied by the complications.
    (Q17 is a vocabulary-grouping question with no define; see signoff.md.)
*/

library CRR_USRenal_Adult version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

/*
  Documentation standard (BRD TA-010).
    'strict'   - 'documented' and 'retrieved' answers count; 'inferred' = null.
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

define function "Qty"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToQuantity("Answer"(linkId).value as FHIR.Quantity).value else null

define function "CodeValue"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToCode("Answer"(linkId).value as FHIR.Coding).code else null

// The linkIds in the list with no accepted answer (missing-information helper).
define function "Unanswered"(linkIds List<String>):
  linkIds L where not "Is Accepted"(L)

// ---------------------------------------------------------------------------
// Demographics and shared facts
// ---------------------------------------------------------------------------

define "Age In Years":
  Coalesce("Int"('patient.age'), AgeInYears())

define "Sex":
  Coalesce("CodeValue"('patient.sex'), Patient.gender.value)

define "Is Male": "Sex" = 'male'
define "Is Female": "Sex" = 'female'

/*
  SOURCE (Overview, p4, Scope item 5): "The age band covered by the paediatric
  criteria has been specified as up to and including 15 years of age"
*/
define "Is Adult": "Age In Years" > 15

// REVIEW Q3 - a male patient is treated as not pregnant; otherwise the answer.
define "Is Pregnant":
  if "Is Male" then false else "Bool"('patient.pregnant')

define "eGFR": "Qty"('lab.egfr.value')

define "Macroscopic Haematuria": "Bool"('symptom.haematuriaMacroscopic')
define "Microscopic Haematuria": "Bool"('symptom.haematuriaMicroscopic')

// ---------------------------------------------------------------------------
// Acute: Within 48 hours (p52)
// ---------------------------------------------------------------------------

/*
  SOURCE (p52, Acute: Within 48 hours, bullet 1):
  "First presentation of renal colic if pregnant or female younger than 35 years
   old and no red flags* requiring admission."

  REVIEW Q1 - read as pregnant OR (female AND younger than 35).
  REVIEW Q2 - "no red flags* requiring admission" (*1 footnote, p55) is the
  national RF-03, which runs before this library and stops the pipeline when
  it fires; it is not re-encoded here. The renal colic presentation itself is
  redflag.renalColicAcuteEpisode (RF-03's stem), composed here so that every
  referral meeting this row has RF-03 evaluated on the same answers.
*/
define "Acute: First Presentation Renal Colic":
  "Bool"('redflag.renalColicAcuteEpisode')
    and "Bool"('symptom.renalColicFirstPresentation')
    and ("Is Pregnant" or ("Is Female" and "Age In Years" < 35))

/*
  SOURCE (p52, Acute: Within 48 hours, bullet 2):
  "Suspected chronic urinary retention e.g. new onset incontinence with palpable
   enlarged bladder"
  "e.g." - the example is illustrative (KI-05) and is not a condition.
*/
define "Acute: Suspected Chronic Urinary Retention":
  "Bool"('symptom.chronicUrinaryRetentionSuspected')

/*
  SOURCE (p52, Acute: Within 48 hours, bullet 3):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist
   advises referral for acute ultrasound renal"
*/
define "Acute: Specialist Advises Acute US Renal":
  "Bool"('advice.acuteImagingRecommended')

define "Meets Acute 48h Criteria":
  "Is Adult"
    and (
      "Acute: First Presentation Renal Colic"
        or "Acute: Suspected Chronic Urinary Retention"
        or "Acute: Specialist Advises Acute US Renal"
    )

// ---------------------------------------------------------------------------
// P2 Urgent (p52)
// ---------------------------------------------------------------------------

/*
  SOURCE (p52, P2 Urgent, bullet 1, sub-bullet 1):
  "Macroscopic haematuria:
     o If younger than 40 years or aged 86 years and older."
  REVIEW Q6 - age < 40 or age >= 86.
*/
define "P2: Macroscopic Haematuria Younger Than 40 Or 86 And Older":
  "Macroscopic Haematuria"
    and ("Age In Years" < 40 or "Age In Years" >= 86)

/*
  SOURCE (p52, P2 Urgent, bullet 1, sub-bullet 2):
  "o If aged 40 to 85 years and unable to have intravenous contrast (i.e.
     history of allergy to IV contrast, has an eGFR less than 30mL/min, is
     taking metformin, or has hyperthyroidism)."
  "i.e." defines the inability: it is exactly these four.
  REVIEW Q7 - 30 compared, mL/min not asserted.
*/
define "Unable To Have Intravenous Contrast":
  "Bool"('patient.ivContrastAllergy')
    or "eGFR" < 30.0
    or "Bool"('patient.takingMetformin')
    or "Bool"('patient.hyperthyroidism')

define "P2: Macroscopic Haematuria Aged 40 To 85 Unable To Have Contrast":
  "Macroscopic Haematuria"
    and "Age In Years" >= 40 and "Age In Years" <= 85
    and "Unable To Have Intravenous Contrast"

define "P2: Macroscopic Haematuria":
  "P2: Macroscopic Haematuria Younger Than 40 Or 86 And Older"
    or "P2: Macroscopic Haematuria Aged 40 To 85 Unable To Have Contrast"

/*
  SOURCE (p52, P2 Urgent, bullet 2):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist
   advises referral for urgent ultrasound renal"
*/
define "P2: Specialist Advises Urgent US Renal":
  "Bool"('advice.urgentImagingRecommended')

define "Meets P2 Criteria":
  "Is Adult"
    and ("P2: Macroscopic Haematuria" or "P2: Specialist Advises Urgent US Renal")

// ---------------------------------------------------------------------------
// P3 (p52-p53)
// ---------------------------------------------------------------------------

/*
  SOURCE (p52, P3, bullet 1):
  "Microscopic haematuria, male patient, older than 50 years, current or
   ex-smoker"
*/
define "P3: Microscopic Haematuria Male Over 50 Current Or Ex-Smoker":
  "Microscopic Haematuria"
    and "Is Male"
    and "Age In Years" > 50
    and "CodeValue"('patient.smokingStatus') in { 'current', 'ex' }

/*
  SOURCE (p52, P3, bullet 2):
  "New diagnosis of chronic kidney disease (CKD) and any of:
     o eGFR less than 30
     o eGFR less than 45 with diabetes
     o eGFR less than 60 with evidence of progressive disease (i.e. eGFR
       decreased by 15 or more within the previous 12 months),
     o ACR more than 250"
  REVIEW Q7 (no unit printed for eGFR here), Q8 (ACR unit), Q12 (decrease).
*/
define "CKD: eGFR Less Than 30":
  "eGFR" < 30.0

define "CKD: eGFR Less Than 45 With Diabetes":
  "eGFR" < 45.0 and "Bool"('patient.diabetes')

define "CKD: eGFR Less Than 60 With Progressive Disease":
  "eGFR" < 60.0 and "Qty"('lab.egfr.decreaseWithin12m') >= 15.0

define "CKD: ACR More Than 250":
  "Qty"('lab.acr.value') > 250.0

define "P3: New CKD Diagnosis With Qualifying Results":
  "Bool"('patient.ckdNewDiagnosis')
    and (
      "CKD: eGFR Less Than 30"
        or "CKD: eGFR Less Than 45 With Diabetes"
        or "CKD: eGFR Less Than 60 With Progressive Disease"
        or "CKD: ACR More Than 250"
    )

/*
  SOURCE (p53, P3, bullet 3): "New right-sided or bilateral varicocele."
*/
define "P3: New Right-Sided Or Bilateral Varicocele":
  "Bool"('symptom.varicoceleNewRightOrBilateral')

/*
  SOURCE (p53, P3, bullets 4 and 5, shared sub-bullet):
  "persistent UTI (i.e. if urine culture shows persistent bacteriuria with same
   organism following treatment with appropriate antibiotic, consider
   colonisation of renal tract stone).  Arrange Xray KUB and pre- and post-void
   renal ultrasound."
  The "consider colonisation of renal tract stone" and "Arrange Xray KUB" clauses
  are advice, not conditions.
*/
define "Persistent UTI":
  "Bool"('lab.persistentBacteriuriaSameOrganism')

/*
  SOURCE (p53, P3, bullet 4):
  "UTI in men (*including pyelonephritis where admission is not required)
     o recurrent UTI (i.e. 2 or more confirmed UTI)
     o persistent UTI (i.e. if urine culture shows persistent bacteriuria with
       same organism following treatment with appropriate antibiotic, consider
       colonisation of renal tract stone).  Arrange Xray KUB and pre- and
       post-void renal ultrasound."
  "*including pyelonephritis where admission is not required" scopes what counts
  as a UTI; not a condition.
  REVIEW Q9 - no time window for "2 or more confirmed UTI".
*/
define "UTI In Men: Recurrent":
  "Int"('symptom.utiConfirmedCount') >= 2

define "P3: UTI In Men":
  "Is Male"
    and ("UTI In Men: Recurrent" or "Persistent UTI")

/*
  SOURCE (p53, P3, bullet 5):
  "UTI in women (*including pyelonephritis where admission is not required)
     o recurrent UTI (i.e.  more than 3 UTIs in a year, or more than 2 in six
       months despite prophylactic antibiotics.)
     o Persistent UTI i.e. if urine culture shows persistent bacteriuria with
       same organism following treatment with appropriate antibiotic, consider
       colonisation of renal tract stone. Arrange Xray KUB and pre- and
       post-void renal ultrasound."
  REVIEW Q10 - "despite prophylactic antibiotics" qualifies the six-month limb.
*/
define "UTI In Women: Recurrent":
  "Int"('symptom.utiCount12m') > 3
    or ("Int"('symptom.utiCount6m') > 2 and "Bool"('patient.onUtiProphylacticAntibiotics'))

define "P3: UTI In Women":
  "Is Female"
    and ("UTI In Women: Recurrent" or "Persistent UTI")

/*
  SOURCE (p53, P3, bullet 6):
  "Urinary incontinence in men with palpable bladder, or new or deteriorating
   renal impairment."
  REVIEW Q11 - male AND incontinence AND (palpable bladder OR renal impairment).
*/
define "P3: Urinary Incontinence In Men With Palpable Bladder Or Renal Impairment":
  "Is Male"
    and "Bool"('symptom.urinaryIncontinence')
    and ("Bool"('symptom.palpableBladder') or "Bool"('lab.renalImpairmentNewOrDeteriorating'))

/*
  SOURCE (p53, P3, bullet 7):
  "Recurrent loin pain suggesting renal tract obstruction other than renal
   stone."
*/
define "P3: Recurrent Loin Pain Suggesting Non-Stone Obstruction":
  "Bool"('symptom.recurrentLoinPainSuggestingObstruction')

/*
  SOURCE (p53, P3, bullet 8):
  "Secondary care clinician or Primary Care Radiology Liaison or radiologist
   advises referral for non-urgent ultrasound renal."
*/
define "P3: Specialist Advises Non-Urgent US Renal":
  "Bool"('advice.nonUrgentImagingRecommended')

define "Meets P3 Criteria":
  "Is Adult"
    and (
      "P3: Microscopic Haematuria Male Over 50 Current Or Ex-Smoker"
        or "P3: New CKD Diagnosis With Qualifying Results"
        or "P3: New Right-Sided Or Bilateral Varicocele"
        or "P3: UTI In Men"
        or "P3: UTI In Women"
        or "P3: Urinary Incontinence In Men With Palpable Bladder Or Renal Impairment"
        or "P3: Recurrent Loin Pain Suggesting Non-Stone Obstruction"
        or "P3: Specialist Advises Non-Urgent US Renal"
    )

// ---------------------------------------------------------------------------
// P4 Deferrable (p53)
// ---------------------------------------------------------------------------

/*
  SOURCE (p53, P4, bullet 1):
  "Microscopic haematuria, male patient, older than 50 years who is a
   non-smoker"
*/
define "P4: Microscopic Haematuria Male Over 50 Non-Smoker":
  "Microscopic Haematuria"
    and "Is Male"
    and "Age In Years" > 50
    and "CodeValue"('patient.smokingStatus') = 'non'

/*
  SOURCE (p53, P4, bullet 2):
  "Microscopic haematuria, male patient aged 50 years and younger, with any
   smoking status (current or ex-smoker, or non-smoker)"
*/
define "P4: Microscopic Haematuria Male 50 And Younger":
  "Microscopic Haematuria"
    and "Is Male"
    and "Age In Years" <= 50

/*
  SOURCE (p53, P4, bullet 3):
  "Microscopic haematuria, female, of any age and smoking status"
*/
define "P4: Microscopic Haematuria Female":
  "Microscopic Haematuria"
    and "Is Female"

define "Meets P4 Criteria":
  "Is Adult"
    and (
      "P4: Microscopic Haematuria Male Over 50 Non-Smoker"
        or "P4: Microscopic Haematuria Male 50 And Younger"
        or "P4: Microscopic Haematuria Female"
    )

// ---------------------------------------------------------------------------
// S2 (p54)
// ---------------------------------------------------------------------------

/*
  SOURCE (p54, S2):
  "Follow up, according to the Renal Colic and Urinary Tract Stones
   HealthPathway, if calculus not visible on KUB X-ray (provided BMI is less
   than 30)"
  REVIEW Q20.
*/
define "S2: Renal Stone Follow Up Calculus Not Visible On KUB X-ray":
  "Bool"('workup.renalStoneFollowUpPerHealthPathway')
    and not "Bool"('workup.kubXrayCalculusVisible')
    and "Dec"('patient.bmi') < 30.0

define "Meets S2 Criteria":
  "Is Adult" and "S2: Renal Stone Follow Up Calculus Not Visible On KUB X-ray"

define "Meets Any Criterion":
  "Meets Acute 48h Criteria" or "Meets P2 Criteria" or "Meets P3 Criteria"
    or "Meets S2 Criteria" or "Meets P4 Criteria"

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (p54)
// ---------------------------------------------------------------------------

/*
  SOURCE (p54, Alternative management, bullet 1):
  "Incidental finding on ultrasound of a solid lesion more than 1 cm diameter
   with typical ultrasound appearances of an angiomyolipoma – see local CT IVU
   HealthPathway"
  REVIEW Q13, Q19.
*/
define "Redirect: Angiomyolipoma More Than 1 cm":
  "Bool"('imaging.incidentalAngiomyolipomaOnUs')
    and "Dec"('imaging.incidentalSolidLesionDiameterCm') > 1.0

/*
  SOURCE (p54, Alternative management, bullet 2):
  "Macroscopic haematuria in patients who do not have a UTI, if aged 40 to 85
   years.
   Refer for CT IVU (Intravenous Urogram)."
  REVIEW Q5 - read as not applying to a patient unable to have intravenous
  contrast: that patient is the P2 row's "aged 40 to 85 years and unable to
  have intravenous contrast", which this redirect would otherwise make
  unreachable (and CT IVU is a contrast study).
*/
define "Redirect: Macroscopic Haematuria Aged 40 To 85 Without UTI":
  "Macroscopic Haematuria"
    and not "Bool"('symptom.utiCurrent')
    and "Age In Years" >= 40 and "Age In Years" <= 85
    and not "Unable To Have Intravenous Contrast"

/*
  SOURCE (p54, Alternative management, bullet 3):
  "Repeat renal ultrasound for diabetic patients with known diabetic renal
   complications is not indicated - See local Kidney Disease in Diabetes
   HealthPathway"
  REVIEW Q22.
*/
define "Redirect: Repeat US For Known Diabetic Renal Complications":
  "Bool"('patient.diabeticRenalComplications')
    and "Bool"('imaging.usrenal.ever')

/*
  SOURCE (p54, Alternative management, bullet 4):
  "Suspected renal colic in a non-pregnant person – See local Renal Colic and
   Urinary Tract Stones HealthPathway."
  REVIEW Q4 - read as not applying to a patient who meets the Acute row
  "First presentation of renal colic if pregnant or female younger than 35
  years old", whose "female younger than 35" limb this redirect would otherwise
  make unreachable.
*/
define "Redirect: Suspected Renal Colic Not Pregnant":
  "Bool"('redflag.renalColicAcuteEpisode')
    and not "Is Pregnant"
    and not "Acute: First Presentation Renal Colic"

/*
  SOURCE (p54, Alternative management, bullet 5):
  "Acute kidney injury – manage according to Acute Kidney Injury pathway, or
   seek advice from the relevant secondary care specialist as to whether a
   renal ultrasound is indicated"
*/
define "Redirect: Acute Kidney Injury":
  "Bool"('lab.acuteKidneyInjury')

/*
  SOURCE (p54, Alternative management, bullet 6):
  "Enlarged prostate or elevated PSA – See local Prostate Cancer
   Diagnosis HealthPathway."
*/
define "Redirect: Enlarged Prostate Or Elevated PSA":
  "Bool"('symptom.enlargedProstate') or "Bool"('lab.psa.raised')

/*
  SOURCE (p54, Alternative management, bullet 7):
  "Isolated proteinuria – seek nephrology advice."
*/
define "Redirect: Isolated Proteinuria":
  "Bool"('lab.proteinuriaIsolated')

/*
  SOURCE (p54, Alternative management, bullet 8):
  "Lower urinary tract symptoms - See local Lower Urinary Tract Symptoms (LUTS)
   or Benign Prostatic Hypertrophy HealthPathway, or other relevant
   HealthPathway."
*/
define "Redirect: Lower Urinary Tract Symptoms":
  "Bool"('symptom.lowerUrinaryTractSymptoms')

/*
  SOURCE (p54, Alternative management, bullet 9):
  "Abdominal mass - Discuss with secondary care specialist as FSA, CT scan or
   other investigations may be more appropriate"
*/
define "Redirect: Abdominal Mass":
  "Bool"('symptom.abdominalMass')

define "Active Redirects":
  (List<String>{
    if "Redirect: Angiomyolipoma More Than 1 cm" is true then 'Incidental finding on ultrasound of a solid lesion more than 1 cm diameter with typical ultrasound appearances of an angiomyolipoma – see local CT IVU HealthPathway' else null,
    if "Redirect: Macroscopic Haematuria Aged 40 To 85 Without UTI" is true then 'Macroscopic haematuria in patients who do not have a UTI, if aged 40 to 85 years. Refer for CT IVU (Intravenous Urogram).' else null,
    if "Redirect: Repeat US For Known Diabetic Renal Complications" is true then 'Repeat renal ultrasound for diabetic patients with known diabetic renal complications is not indicated - See local Kidney Disease in Diabetes HealthPathway' else null,
    if "Redirect: Suspected Renal Colic Not Pregnant" is true then 'Suspected renal colic in a non-pregnant person – See local Renal Colic and Urinary Tract Stones HealthPathway.' else null,
    if "Redirect: Acute Kidney Injury" is true then 'Acute kidney injury – manage according to Acute Kidney Injury pathway, or seek advice from the relevant secondary care specialist as to whether a renal ultrasound is indicated' else null,
    if "Redirect: Enlarged Prostate Or Elevated PSA" is true then 'Enlarged prostate or elevated PSA – See local Prostate Cancer Diagnosis HealthPathway.' else null,
    if "Redirect: Isolated Proteinuria" is true then 'Isolated proteinuria – seek nephrology advice.' else null,
    if "Redirect: Lower Urinary Tract Symptoms" is true then 'Lower urinary tract symptoms - See local Lower Urinary Tract Symptoms (LUTS) or Benign Prostatic Hypertrophy HealthPathway, or other relevant HealthPathway.' else null,
    if "Redirect: Abdominal Mass" is true then 'Abdominal mass - Discuss with secondary care specialist as FSA, CT scan or other investigations may be more appropriate' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

// An unknown redirect does not block a determination; its unanswered
// indicators are surfaced to the triager.
define "Unconfirmed Exclusions":
  flatten {
    if "Redirect: Angiomyolipoma More Than 1 cm" is null then "Unanswered"({ 'imaging.incidentalAngiomyolipomaOnUs', 'imaging.incidentalSolidLesionDiameterCm' }) else {} as List<String>,
    if "Redirect: Macroscopic Haematuria Aged 40 To 85 Without UTI" is null then "Unanswered"({ 'symptom.haematuriaMacroscopic', 'symptom.utiCurrent', 'patient.ivContrastAllergy', 'lab.egfr.value', 'patient.takingMetformin', 'patient.hyperthyroidism' }) else {} as List<String>,
    if "Redirect: Repeat US For Known Diabetic Renal Complications" is null then "Unanswered"({ 'patient.diabeticRenalComplications', 'imaging.usrenal.ever' }) else {} as List<String>,
    if "Redirect: Suspected Renal Colic Not Pregnant" is null then "Unanswered"({ 'redflag.renalColicAcuteEpisode', 'patient.pregnant', 'symptom.renalColicFirstPresentation' }) else {} as List<String>,
    if "Redirect: Acute Kidney Injury" is null then { 'lab.acuteKidneyInjury' } else {} as List<String>,
    if "Redirect: Enlarged Prostate Or Elevated PSA" is null then "Unanswered"({ 'symptom.enlargedProstate', 'lab.psa.raised' }) else {} as List<String>,
    if "Redirect: Isolated Proteinuria" is null then { 'lab.proteinuriaIsolated' } else {} as List<String>,
    if "Redirect: Lower Urinary Tract Symptoms" is null then { 'symptom.lowerUrinaryTractSymptoms' } else {} as List<String>,
    if "Redirect: Abdominal Mass" is null then { 'symptom.abdominalMass' } else {} as List<String>
  }

// ---------------------------------------------------------------------------
// Not routinely funded (p54-p55)
// ---------------------------------------------------------------------------

/*
  SOURCE (p54, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
   - "Recurrent UTIs in women, except as documented above"
  REVIEW Q10 - "except as documented above" = the P3 "UTI in women" row.
  REVIEW Q21 - reached only when every timeframe row is definitively not met.
*/
define "Not Funded: Recurrent UTIs In Women Except As Documented":
  Coalesce("Is Female" and "Bool"('symptom.utiRecurrent') and not "P3: UTI In Women", false)

/*
  SOURCE (p54, not routinely funded): "Investigation of uncomplicated hypertension"
*/
define "Not Funded: Investigation Of Uncomplicated Hypertension":
  Coalesce("Bool"('funding.investigationUncomplicatedHypertension'), false)

/*
  SOURCE (p54, not routinely funded):
  "Bacteriuria in patients with in-dwelling catheters who are not systemically
   unwell"
*/
define "Not Funded: Catheter Bacteriuria Not Systemically Unwell":
  Coalesce(
    "Bool"('lab.bacteriuria') and "Bool"('patient.indwellingCatheter') and not "Bool"('symptom.systemicallyUnwell'),
    false
  )

/*
  SOURCE (p54, not routinely funded):
  "Follow-up imaging of simple renal cysts (Bosniak I and II)"
*/
define "Not Funded: Simple Renal Cyst Follow Up":
  Coalesce("Bool"('funding.simpleRenalCystFollowUp'), false)

/*
  SOURCE (p54, not routinely funded):
  "Follow up of incidental finding on ultrasound of a solid lesion less 1 cm
   diameter with typical ultrasound appearances of an angiomyolipoma."
  REVIEW Q13 - "less 1 cm" read as less than 1 cm.
*/
define "Not Funded: Angiomyolipoma Less Than 1 cm":
  Coalesce(
    "Bool"('imaging.incidentalAngiomyolipomaOnUs') and "Dec"('imaging.incidentalSolidLesionDiameterCm') < 1.0,
    false
  )

/*
  SOURCE (p55, not routinely funded):
  "Screening scan for Autosomal Dominant Polycystic Kidney Disease (ADPKD)"
*/
define "Not Funded: ADPKD Screening":
  Coalesce("Bool"('funding.adpkdScreening'), false)

/*
  SOURCE (p55, not routinely funded):
  "Serial ultrasounds of known polycystic kidneys unless indicated by the
   radiology report, or the patient develops new symptoms that meet any of the
   other criteria for renal ultrasound"
  REVIEW Q18.
*/
define "Not Funded: Serial US Of Known Polycystic Kidneys":
  Coalesce(
    "Bool"('funding.polycysticKidneySerialUs')
      and not "Bool"('imaging.furtherImagingRecommendedByReport')
      and not "Meets Any Criterion",
    false
  )

define "Not Routinely Funded":
  "Not Funded: Recurrent UTIs In Women Except As Documented"
    or "Not Funded: Investigation Of Uncomplicated Hypertension"
    or "Not Funded: Catheter Bacteriuria Not Systemically Unwell"
    or "Not Funded: Simple Renal Cyst Follow Up"
    or "Not Funded: Angiomyolipoma Less Than 1 cm"
    or "Not Funded: ADPKD Screening"
    or "Not Funded: Serial US Of Known Polycystic Kidneys"

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q14, Q21):
    1. Alternative management / redirect (BRD TA-013: redirect wins over criteria)
    2. Paediatric patient - the adult criteria do not apply (BRD TA-003)
    3. Most urgent timeframe row met: Acute 48h > P2 > P3 > S2 > P4
    4. Any timeframe row still undetermined - insufficient information
    5. Not routinely funded - only when every timeframe row is definitively
       not met (coordinator rule R1, 2026-10-16), so a not-funded row keyed on
       a patient fact (NF 1 recurrent UTIs in women, NF 3 catheter bacteriuria)
       never pre-empts a met or undetermined criterion
    6. Every row definitively not met
*/
define "Determination":
  case
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P3 Criteria" is true then 'P3_NON_DEFERRABLE'
    when "Meets S2 Criteria" is true then 'S2_TIME_SENSITIVE'
    when "Meets P4 Criteria" is true then 'P4_DEFERRABLE'
    when "Meets Any Criterion" is null then 'INSUFFICIENT_INFORMATION'
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    else 'CRITERIA_NOT_MET'
  end

define "Priority Code":
  case "Determination"
    when 'ACUTE_48H' then 'A48'
    when 'P2_URGENT' then 'P2'
    when 'P3_NON_DEFERRABLE' then 'P3'
    when 'S2_TIME_SENSITIVE' then 'S2'
    when 'P4_DEFERRABLE' then 'P4'
    else null
  end

/*
  SOURCE (p52-p54, Timeframe column):
  "Acute: Within 48 hours"
  "P2 Urgent: Non-deferrable imaging or intervention that must be completed
   within 2 weeks of receiving referral."
  "P3 non-deferrable imaging or intervention that must be completed within 6
   weeks of receiving referral."
  "P4 Deferrable. If capacity is constrained could wait up to 6-12 weeks from
   receiving referral."
  "S2 non-deferrable time sensitive imaging to be completed within 2 weeks of a
   specified target date"
  Each timeframe string below is a verbatim fragment of its heading, with the
  priority code and the row's classification words left out.
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_48H' then 'Within 48 hours'
    when 'P2_URGENT' then 'must be completed within 2 weeks of receiving referral.'
    when 'P3_NON_DEFERRABLE' then 'must be completed within 6 weeks of receiving referral.'
    when 'S2_TIME_SENSITIVE' then 'to be completed within 2 weeks of a specified target date'
    when 'P4_DEFERRABLE' then 'If capacity is constrained could wait up to 6-12 weeks from receiving referral.'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

// For each criterion row that cannot be determined, its unanswered indicators.
// Rows already definitively not met add nothing.
define "Missing Criterion Indicators":
  flatten {
    if "Acute: First Presentation Renal Colic" is null then "Unanswered"({ 'redflag.renalColicAcuteEpisode', 'symptom.renalColicFirstPresentation' }) else {} as List<String>,
    // pregnancy is not asked when the "female younger than 35" limb is already met, nor sex/age when pregnant
    if "Acute: First Presentation Renal Colic" is null and ("Is Female" and "Age In Years" < 35) is not true then "Unanswered"({ 'patient.pregnant' }) else {} as List<String>,
    if "Acute: First Presentation Renal Colic" is null and "Is Pregnant" is not true then "Unanswered"({ 'patient.sex', 'patient.age' }) else {} as List<String>,
    if "Acute: Suspected Chronic Urinary Retention" is null then { 'symptom.chronicUrinaryRetentionSuspected' } else {} as List<String>,
    if "Acute: Specialist Advises Acute US Renal" is null then { 'advice.acuteImagingRecommended' } else {} as List<String>,
    if "P2: Macroscopic Haematuria" is null then "Unanswered"({ 'symptom.haematuriaMacroscopic', 'patient.age', 'patient.ivContrastAllergy', 'lab.egfr.value', 'patient.takingMetformin', 'patient.hyperthyroidism' }) else {} as List<String>,
    if "P2: Specialist Advises Urgent US Renal" is null then { 'advice.urgentImagingRecommended' } else {} as List<String>,
    if "P3: Microscopic Haematuria Male Over 50 Current Or Ex-Smoker" is null then "Unanswered"({ 'symptom.haematuriaMicroscopic', 'patient.sex', 'patient.age', 'patient.smokingStatus' }) else {} as List<String>,
    if "P3: New CKD Diagnosis With Qualifying Results" is null then "Unanswered"({ 'patient.ckdNewDiagnosis', 'lab.egfr.value', 'patient.diabetes', 'lab.egfr.decreaseWithin12m', 'lab.acr.value' }) else {} as List<String>,
    if "P3: New Right-Sided Or Bilateral Varicocele" is null then { 'symptom.varicoceleNewRightOrBilateral' } else {} as List<String>,
    if "P3: UTI In Men" is null then "Unanswered"({ 'patient.sex', 'symptom.utiConfirmedCount', 'lab.persistentBacteriuriaSameOrganism' }) else {} as List<String>,
    if "P3: UTI In Women" is null then "Unanswered"({ 'patient.sex', 'symptom.utiCount12m', 'symptom.utiCount6m', 'patient.onUtiProphylacticAntibiotics', 'lab.persistentBacteriuriaSameOrganism' }) else {} as List<String>,
    if "P3: Urinary Incontinence In Men With Palpable Bladder Or Renal Impairment" is null then "Unanswered"({ 'patient.sex', 'symptom.urinaryIncontinence', 'symptom.palpableBladder', 'lab.renalImpairmentNewOrDeteriorating' }) else {} as List<String>,
    if "P3: Recurrent Loin Pain Suggesting Non-Stone Obstruction" is null then { 'symptom.recurrentLoinPainSuggestingObstruction' } else {} as List<String>,
    if "P3: Specialist Advises Non-Urgent US Renal" is null then { 'advice.nonUrgentImagingRecommended' } else {} as List<String>,
    if "P4: Microscopic Haematuria Male Over 50 Non-Smoker" is null then "Unanswered"({ 'symptom.haematuriaMicroscopic', 'patient.sex', 'patient.age', 'patient.smokingStatus' }) else {} as List<String>,
    if "P4: Microscopic Haematuria Male 50 And Younger" is null then "Unanswered"({ 'symptom.haematuriaMicroscopic', 'patient.sex', 'patient.age' }) else {} as List<String>,
    if "P4: Microscopic Haematuria Female" is null then "Unanswered"({ 'symptom.haematuriaMicroscopic', 'patient.sex' }) else {} as List<String>,
    if "S2: Renal Stone Follow Up Calculus Not Visible On KUB X-ray" is null then "Unanswered"({ 'workup.renalStoneFollowUpPerHealthPathway', 'workup.kubXrayCalculusVisible', 'patient.bmi' }) else {} as List<String>,
    if "Is Adult" is null then { 'patient.age' } else {} as List<String>
  }

// Age and sex may come from the Patient resource rather than an answer.
define "Missing Core Indicators":
  "Missing Criterion Indicators" M
    where not (M = 'patient.age' and "Age In Years" is not null)
      and not (M = 'patient.sex' and "Sex" is not null)

/*
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Missing Advice Indicators":
  (List<String>{
    if ("Acute: Specialist Advises Acute US Renal" is true
          or "P2: Specialist Advises Urgent US Renal" is true
          or "P3: Specialist Advises Non-Urgent US Renal" is true)
        and not "Is Answered"('advice.adviserNameRole')
      then 'advice.adviserNameRole' else null
  }) M where M is not null

define "Missing Information":
  if "Determination" = 'INSUFFICIENT_INFORMATION'
    then "Missing Core Indicators" union "Missing Advice Indicators"
  else "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age', 'patient.sex', 'patient.pregnant', 'patient.smokingStatus',
    'patient.ivContrastAllergy', 'patient.takingMetformin', 'patient.hyperthyroidism',
    'patient.diabetes', 'patient.diabeticRenalComplications', 'patient.ckdNewDiagnosis',
    'patient.bmi', 'patient.onUtiProphylacticAntibiotics', 'patient.indwellingCatheter',
    'symptom.haematuriaMacroscopic', 'symptom.haematuriaMicroscopic',
    'symptom.renalColicFirstPresentation', 'symptom.chronicUrinaryRetentionSuspected',
    'symptom.varicoceleNewRightOrBilateral', 'symptom.utiConfirmedCount', 'symptom.utiCount12m',
    'symptom.utiCount6m', 'symptom.utiRecurrent', 'symptom.utiCurrent', 'symptom.urinaryIncontinence',
    'symptom.palpableBladder', 'symptom.recurrentLoinPainSuggestingObstruction',
    'symptom.enlargedProstate', 'symptom.lowerUrinaryTractSymptoms', 'symptom.abdominalMass',
    'symptom.systemicallyUnwell',
    'lab.egfr.value', 'lab.egfr.decreaseWithin12m', 'lab.acr.value',
    'lab.renalImpairmentNewOrDeteriorating', 'lab.acuteKidneyInjury', 'lab.psa.raised',
    'lab.proteinuriaIsolated', 'lab.bacteriuria', 'lab.persistentBacteriuriaSameOrganism',
    'imaging.usrenal.ever', 'imaging.incidentalAngiomyolipomaOnUs',
    'imaging.incidentalSolidLesionDiameterCm', 'imaging.furtherImagingRecommendedByReport',
    'workup.renalStoneFollowUpPerHealthPathway', 'workup.kubXrayCalculusVisible',
    'advice.acuteImagingRecommended', 'advice.urgentImagingRecommended',
    'advice.nonUrgentImagingRecommended', 'advice.adviserNameRole',
    'funding.investigationUncomplicatedHypertension', 'funding.simpleRenalCystFollowUp',
    'funding.adpkdScreening', 'funding.polycysticKidneySerialUs',
    'redflag.renalColicAcuteEpisode'
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
    isPregnant: "Is Pregnant",
    acuteFirstPresentationRenalColic: "Acute: First Presentation Renal Colic",
    acuteSuspectedChronicUrinaryRetention: "Acute: Suspected Chronic Urinary Retention",
    acuteSpecialistAdvises: "Acute: Specialist Advises Acute US Renal",
    meetsAcute: "Meets Acute 48h Criteria",
    p2MacroHaematuriaAgeBand: "P2: Macroscopic Haematuria Younger Than 40 Or 86 And Older",
    unableToHaveIntravenousContrast: "Unable To Have Intravenous Contrast",
    p2MacroHaematuriaContrast: "P2: Macroscopic Haematuria Aged 40 To 85 Unable To Have Contrast",
    p2SpecialistAdvises: "P2: Specialist Advises Urgent US Renal",
    meetsP2: "Meets P2 Criteria",
    p3MicroHaematuriaMaleSmoker: "P3: Microscopic Haematuria Male Over 50 Current Or Ex-Smoker",
    p3NewCkd: "P3: New CKD Diagnosis With Qualifying Results",
    p3Varicocele: "P3: New Right-Sided Or Bilateral Varicocele",
    persistentUti: "Persistent UTI",
    p3UtiMen: "P3: UTI In Men",
    p3UtiWomen: "P3: UTI In Women",
    p3IncontinenceMen: "P3: Urinary Incontinence In Men With Palpable Bladder Or Renal Impairment",
    p3RecurrentLoinPain: "P3: Recurrent Loin Pain Suggesting Non-Stone Obstruction",
    p3SpecialistAdvises: "P3: Specialist Advises Non-Urgent US Renal",
    meetsP3: "Meets P3 Criteria",
    p4MicroHaematuriaMaleNonSmoker: "P4: Microscopic Haematuria Male Over 50 Non-Smoker",
    p4MicroHaematuriaMale50OrYounger: "P4: Microscopic Haematuria Male 50 And Younger",
    p4MicroHaematuriaFemale: "P4: Microscopic Haematuria Female",
    meetsP4: "Meets P4 Criteria",
    s2RenalStoneFollowUp: "S2: Renal Stone Follow Up Calculus Not Visible On KUB X-ray",
    meetsS2: "Meets S2 Criteria",
    alternativeManagement: "Alternative Management Recommended",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'US Renal - Adult',
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
