/*
  CRR National Community Referral Criteria for Imaging (Part I)
  US Pelvis - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    File:       documents/reference/National Primary Care Referral Criteria for Imaging.pdf
    Section:    US Pelvis -Adult, pages 44-51 (footnotes *1-*5 on pp.49-51)

  STATUS
    NOT CLINICALLY REVIEWED. Demo transcription for staging only (AD-35).
    Every ambiguity is a REVIEW Qn below; signoff.md carries the rulings.

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the published
    wording verbatim, with page reference. A define with no SOURCE comment is
    engineering plumbing, not a clinical rule. Review is a side-by-side check of
    each SOURCE quote against the define beneath it.

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-US-Pelvis-Adult". Answers carry the answer-evidence
    extension (status documented | inferred | retrieved, quote) exactly as for
    CT CAP. An unanswered indicator is NULL and propagates under three-valued
    logic. Redirect and not-funded rows are read "is true" (an unknown does not
    fire them); clinical criteria are never coalesced to false.

  NOT IN THIS LIBRARY
    - "Refer for acute assessment without initial imaging" (p44, "Clinically
      unstable patients with suspected gynaecologic or pelvic cause") is national
      red flag RF-11 in CRR_RedFlags; it is not re-encoded here.
    - The S2 and S3 specialist-advice gateways (p47, p48) carry the same wording
      under two timeframes and are left out of the logic (REVIEW Q3).

  DETERMINATION CODES
    NOT_ROUTINELY_FUNDED, ALTERNATIVE_MANAGEMENT, PAEDIATRIC_CRITERIA_APPLY,
    ACUTE_24H, ACUTE_48H, P2_URGENT, P3_NON_DEFERRABLE,
    P4_DEFERRABLE, S2_TIME_SENSITIVE (priority code S2),
    S3_TIME_SENSITIVE (priority code S3), CRITERIA_NOT_MET,
    INSUFFICIENT_INFORMATION. The S2/S3 determinations deliberately carry no
    priority code in their name: the renderers strip a leading P-code from
    referrer text but not an S-code (GEN-004).

  CLINICAL REVIEW FLAGS (full wording in signoff.md / transcription-notes.md)
    Q1  Precedence across rows: most urgent met row wins; an unresolved more-urgent row is listed in Missing Information, never blocks.
    Q2  Precedence of redirect / not-funded over criteria (CT CAP Q5 / TA-013 order kept).
    Q3  S2 and S3 advice gateways share one wording; left out of the logic.
    Q4  Acute 24h row 1: "including:" sub-bullets read as illustrative; the stem alone is encoded.
    Q5  Acute 24h row 1: the "outside the two-week post miscarriage maternity-funded scan window" condition is not encoded.
    Q6  Footnote *1 "If systemically unstable and/or severe persistent pelvic pain refer for acute assessment" is broader than RF-11.
    Q7  "Postmenopausal bleeding" (P2 row 2) is not restricted to women not on MHT.
    Q8  P2 row 3 "at any age": encoded as post-menopausal + persistent bleeding + continuous combined MHT + more than 6 months.
    Q9  Footnote *2 symptom list is not decomposed; one indicator for the presentation.
    Q10 Footnote *5: Māori / Pacific ethnicity counted as an EH/EC risk factor.
    Q11 One "pelvic mass" indicator serves "on examination", "palpable", "suspected on examination" and "clinically palpable".
    Q12 P3 row 2 requires no exclusion of non-uterine causes (as printed).
    Q13 P3 IUD row: "asymptomatic" encoded as no symptoms suggestive of perforation.
    Q14 Pre-menopausal = not post-menopausal (perimenopausal women count as pre-menopausal).
    Q15 Not-funded "first 3 to 6 months after starting MHT" read as within 6 months (6 inclusive).
    Q16 P3 "routine" gateway mapped to advice.nonUrgentImagingRecommended; P4 "deferrable, non-urgent" given its own indicator.
    Q17 Numeric boundaries (45, 35 units/mL, 1000 IU, 6 months, 6 / 4 weeks, 3 months, 5 cm, 3 / 5 cm, BMI 30, older than 35).
    Q18 Simple cyst "(O-RADS 2)" in the not-funded rows read as a label for the simple cyst; O-RADS 2 not separately required there.
    Q19 Secondary amenorrhoea redirect: "unless a pelvis mass is present" read with the palpable-mass indicator.
    Q20 The Guidance sentence on Māori and Pacific people with AUB ("should be considered at or soon after initial presentation") is not a pathway.
    Q21 Cyst follow-up rows: the ACR table decides the interval; the referrer supplies it.
    Q22 Candidate attestation (AD-17) indicators: acutely unwell, mass suspicious of cancer, symptoms warranting consideration of ovarian cancer.
    Q23 A stated count of risk factors ("2 risk factors", DG-004) cannot be used; each footnote *5 factor is its own indicator.
    Q24 Sex is not checked ("Women" / "woman" read as population wording).
    Q25 A referral raising none of the section's concepts returns insufficient information with an empty missing list (MW-004, MW-006).
*/

library CRR_USPelvis_Adult version '1.0.0'

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
// Plumbing: QuestionnaireResponse access (copied from CT CAP unchanged, plus
// "Answered True", which ignores the documentation standard and is used only
// to decide which rows the referral engages for the missing-information list)
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

define function "Answered True"(linkId String):
  FHIRHelpers.ToBoolean("Answer"(linkId).value as FHIR.boolean) is true

// The linkId when the indicator is not established under the documentation standard.
define function "If Unknown"(linkId String):
  if "Is Accepted"(linkId) then null else linkId

define function "Present"(L List<String>):
  L M where M is not null

// ---------------------------------------------------------------------------
// Demographics and background
// ---------------------------------------------------------------------------

define "Age In Years":
  Coalesce("Int"('patient.age'), AgeInYears())

/*
  SOURCE (Overview, p4, Scope item 5): "The age band covered by the paediatric
  criteria has been specified as up to and including 15 years of age"
*/
define "Is Adult": "Age In Years" > 15

/*
  SOURCE (p46, P3, benign endometrial cells row): "The patient is
   post-menopausal (no period for twelve consecutive months)"
  REVIEW Q14 - "pre-menopausal" / "premenopausal" (pp.47-49) is read as
  "not post-menopausal"; a perimenopausal woman counts as pre-menopausal.
*/
define "Is Post-menopausal": "Bool"('patient.postmenopausal')
define "Is Pre-menopausal": not "Is Post-menopausal"

define "MHT Months Since Start": "Dec"('patient.mhtMonthsSinceStart')

// ---------------------------------------------------------------------------
// Footnote *5 - risk factors for endometrial hyperplasia / endometrial cancer
// ---------------------------------------------------------------------------

/*
  SOURCE (p50-51, footnote *5): "Risk factors for  EH/EC
   Priority group and equity considerations: For Māori and Pacific peoples,
   investigations to exclude endometrial cancer and hyperplasia should be
   considered at, or soon after, the initial presentation of abnormal uterine
   bleeding (AUB). Māori and Pacific peoples have a significantly higher rate of
   endometrial hyperplasia and cancer (relative risk (RR) of 2.47 and 5.11
   respectively compared with other ethnicities).
   Clinical risk factors:
   - Excess estrogen exposure:
     o Endogenous:
       - BMI 30 or higher – the risk is directly proportional to the BMI
       - Polycystic ovary syndrome (PCOS)
       - Chronic anovulation (e.g. fewer than 4 menstrual cycles in 12 months)
       - Nulliparity in women older than 35 years
       - Early menarche (variably defined as earlier than 10 to 12 years of age)
         or late menopause (after age 55 years)
       - Estrogen‐secreting tumour
     o Exogenous:
       - Long‐standing unopposed estrogen menopause hormone therapy (MHT)
       - Tamoxifen therapy
   - Diabetes mellitus
   - Iron deficiency anaemia (Hb less than 100)
   - Family history of endometrial, ovarian, breast, or bowel cancer"

  REVIEW Q10 - Māori or Pacific ethnicity is printed inside the footnote headed
  "Risk factors for EH/EC", before the heading "Clinical risk factors:". It is
  counted here as one risk factor. Confirm, or rule that only the clinical list
  counts.
  REVIEW Q17 - "BMI 30 or higher" is >= 30; "older than 35" is > 35.
*/
define "BMI 30 Or Higher": "Dec"('patient.bmi') >= 30.0

define "Nulliparity In Women Older Than 35":
  "Bool"('patient.nulliparous') and "Age In Years" > 35

define "EH EC Risk Factor Flags":
  {
    "Bool"('patient.maoriOrPacificEthnicity'),
    "BMI 30 Or Higher",
    "Bool"('patient.pcosDiagnosed'),
    "Bool"('patient.chronicAnovulation'),
    "Nulliparity In Women Older Than 35",
    "Bool"('patient.earlyMenarcheOrLateMenopause'),
    "Bool"('patient.estrogenSecretingTumour'),
    "Bool"('patient.unopposedEstrogenMhtLongStanding'),
    "Bool"('patient.tamoxifenTherapy'),
    "Bool"('patient.diabetes'),
    "Bool"('lab.ironDeficiencyAnaemia'),
    "Bool"('patient.familyHistoryEndometrialOvarianBreastBowelCancer')
  }

// "return all": a query returns distinct elements by default. Length, not Count (Count ignores nulls).
define "Risk Factor Count": Length("EH EC Risk Factor Flags" F where F is true return all F)
define "Unknown Risk Factor Count": Length("EH EC Risk Factor Flags" F where F is null return all F)

define "At Least Two Risk Factors":
  if "Risk Factor Count" >= 2 then true
  else if "Risk Factor Count" + "Unknown Risk Factor Count" >= 2 then null
  else false

define "At Least One Risk Factor":
  if "Risk Factor Count" >= 1 then true
  else if "Unknown Risk Factor Count" >= 1 then null
  else false

define "No Risk Factors": not "At Least One Risk Factor"

define "Unknown Risk Factors":
  "Present"({
    "If Unknown"('patient.maoriOrPacificEthnicity'),
    "If Unknown"('patient.bmi'),
    "If Unknown"('patient.pcosDiagnosed'),
    "If Unknown"('patient.chronicAnovulation'),
    "If Unknown"('patient.nulliparous'),
    "If Unknown"('patient.earlyMenarcheOrLateMenopause'),
    "If Unknown"('patient.estrogenSecretingTumour'),
    "If Unknown"('patient.unopposedEstrogenMhtLongStanding'),
    "If Unknown"('patient.tamoxifenTherapy'),
    "If Unknown"('patient.diabetes'),
    "If Unknown"('lab.ironDeficiencyAnaemia'),
    "If Unknown"('patient.familyHistoryEndometrialOvarianBreastBowelCancer')
  })

// ---------------------------------------------------------------------------
// Shared clinical components
// ---------------------------------------------------------------------------

/*
  SOURCE (p45 "Pelvic mass on examination"; p45/p46 "No palpable pelvic mass";
  p45 "A pelvic mass is suspected on examination"; p46 "pelvic mass"; p48 "in
  the absence of a clinically palpable mass").
  REVIEW Q11 - one indicator (symptom.pelvicMassPalpable) represents all five
  phrasings. "Suspected on examination" may be weaker than "palpable", and the
  p46 cyst row does not say the mass was found on examination.
*/
define "Pelvic Mass Palpable": "Bool"('symptom.pelvicMassPalpable')

define "Pelvic Mass Suspicious Of Cancer": "Bool"('symptom.pelvicMassSuspiciousOfCancer')

/*
  SOURCE (p50, footnote *3): "Abnormal Uterine Bleeding (AUB) –bleeding from the
   uterus that is abnormal in volume, regularity, frequency or duration and
   occurs in the absence of pregnancy (excluding postmenopausal bleeding)"
*/
define "AUB": "Bool"('symptom.abnormalUterineBleeding')

/*
  SOURCE (p50, footnote *4): "Non-uterine i.e. lower genital tract causes of
   bleeding" (vulvovaginal atrophy / atrophic vaginitis; vulval dermatoses;
   sexually transmitted infections e.g. chlamydia; malignancy of cervix, vagina,
   vulva; cervical ectropion; urethral causes e.g. urethral caruncle)
*/
define "Non-uterine Causes Excluded": "Bool"('workup.nonUterineBleedingCausesExcluded')

/*
  SOURCE (p45 P2 and p46 P3): "new abdominal or pelvic symptoms*2 warranting
   consideration of ovarian cancer which are present on a persistent or
   frequent basis"
  SOURCE (p49, footnote *2): "Presentations warranting consideration of ovarian
   cancer, in the absence of a palpable mass - new abdominal or pelvic symptoms
   which are present on a persistent or frequent basis: Persistent abdominal
   distension or bloating; Early satiety or loss of appetite; Pelvic or abdominal
   pain without a known cause; Increased urinary urgency or frequency; Irritable
   bowel symptoms, especially if new onset and aged older than 50 years;
   Unexplained weight loss or fatigue"
  REVIEW Q9 - one indicator for the presentation; the six listed symptoms are
  not separately encoded ("especially if new onset and aged older than 50
  years" is modifier wording, KI-05).
*/
define "Ovarian Cancer Symptoms Persistent": "Bool"('symptom.ovarianCancerSymptomsPersistent')

define "IUD Strings Not Visible Or Fragment Retained":
  "Bool"('symptom.iudStringsNotVisible') or "Bool"('symptom.iudFragmentRetained')

define "IUD Perforation Symptoms": "Bool"('symptom.iudPerforationSymptoms')

// ---------------------------------------------------------------------------
// Acute: Within 24 hours (p44-45)
// ---------------------------------------------------------------------------

/*
  SOURCE (p44, Acute: Within 24 hours, bullet 1):
  "Patients acutely unwell from a suspected gynaecological cause including:
   o sudden onset of severe pelvic pain, clinically stable and suspected ovarian
     torsion or ovarian cyst accident (e.g. cyst rupture or bleed)
   o possible endometritis from RPOC *1 in women with persistent pelvic pain and
     tenderness, +/- low grade fever, +/- bleeding; where the patient is outside
     the two-week post miscarriage maternity-funded scan window. Consider seeking
     gynaecology advice or acute gynaecology assessment if admission may be more
     appropriate."
  REVIEW Q4 - "including:" is read as introducing illustrative presentations
  (vocabulary F-07; census: "illustrative examples of one condition, not gating
  options"), so the stem alone is the criterion.
  REVIEW Q5 - under that reading the endometritis sub-bullet's condition "outside
  the two-week post miscarriage maternity-funded scan window" is not encoded: a
  patient inside the maternity-funded window still meets this row. Confirm.
*/
define "Acute 24h Row 1: Acutely Unwell From Suspected Gynaecological Cause":
  "Bool"('symptom.acutelyUnwellSuspectedGynaeCause')

/*
  SOURCE (p45, Acute: Within 24 hours, bullet 2):
  "IUD strings missing and not visible on examination, or IUD breaks on removal
   attempt and only a fragment is removed, and the patient presents with
   symptoms suggestive of possible perforation including cramping pain,
   discharge, unexplained bleeding."
  ("including cramping pain, discharge, unexplained bleeding" is illustrative.)
*/
define "Acute 24h Row 2: IUD Problem With Possible Perforation Symptoms":
  "IUD Strings Not Visible Or Fragment Retained" and "IUD Perforation Symptoms"

define "Meets Acute 24h Criteria":
  "Acute 24h Row 1: Acutely Unwell From Suspected Gynaecological Cause"
    or "Acute 24h Row 2: IUD Problem With Possible Perforation Symptoms"

// ---------------------------------------------------------------------------
// Acute: Within 48 hours (p45)
// ---------------------------------------------------------------------------

/*
  SOURCE (p45, Acute: Within 48 hours, bullet 1):
  "Suspected ongoing pregnancy more than 14 days post abortion or miscarriage and
   either:
   o Urine HCG is greater than 1000 IU on testing at 14 days post-procedure,
     miscarriage, or early medical abortion (EMA)
   OR
   o Serial serum bHCG remains high after early medical abortion (EMA) or
     miscarriage especially if bHCG has increased between a baseline test done
     within 72 hours of Mifepristone and a follow-up test 8-16 days after
     ingestion (N.B. a decrease in serum bHCG of 80% or more between baseline
     and follow-up tests excludes ongoing pregnancy).
   o +/- Ongoing symptoms of pregnancy (e.g. nausea, breast tenderness)"
  "especially if ..." is modifier wording; the N.B. explains "remains high" and
  is not a separate condition; "+/- ongoing symptoms" does not affect the logic.
  REVIEW Q17 - "greater than 1000 IU" is > 1000 (1000 does not qualify).
*/
define "Urine HCG Greater Than 1000 At 14 Days": "Dec"('lab.urineHcg.value') > 1000.0

define "Acute 48h Row 1: Suspected Ongoing Pregnancy With Raised HCG":
  "Bool"('symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage')
    and ("Urine HCG Greater Than 1000 At 14 Days" or "Bool"('lab.serumBhcg.remainsHigh'))

/*
  SOURCE (p45, Acute: Within 48 hours, bullet 2): "Secondary care clinician or
   Primary Care Radiology Liaison or radiologist advises referral for same or
   next day ultrasound pelvis"
*/
define "Acute 48h Row 2: Advice For Same Or Next Day Ultrasound":
  "Bool"('advice.acuteImagingRecommended')

define "Meets Acute 48h Criteria":
  "Acute 48h Row 1: Suspected Ongoing Pregnancy With Raised HCG"
    or "Acute 48h Row 2: Advice For Same Or Next Day Ultrasound"

// ---------------------------------------------------------------------------
// P2 Urgent (p45-46)
// ---------------------------------------------------------------------------

/*
  SOURCE (p45, P2 Urgent, bullet 1): "Pelvic mass on examination suspicious of
   cancer"
*/
define "P2 Row 1: Pelvic Mass Suspicious Of Cancer":
  "Pelvic Mass Palpable" and "Pelvic Mass Suspicious Of Cancer"

/*
  SOURCE (p45, P2 Urgent, bullet 2): "Postmenopausal bleeding (i.e. vaginal
   bleeding after more than 12 months' amenorrhoea around the expected age of
   menopause (approximately 50 years))."
  "i.e." defines the term; "approximately 50 years" is not a threshold, so the
  definition is carried in the indicator text, not as an age check.
  REVIEW Q7 - nothing in this row excludes women on MHT, so it also fires for
  bleeding on MHT (which rows P2-3, P3-4 and the not-funded MHT row address
  specifically). Matrix LP-003, DG-005.
*/
define "P2 Row 2: Postmenopausal Bleeding":
  "Bool"('symptom.postmenopausalBleeding')

/*
  SOURCE (p45, P2 Urgent, bullet 3): "Persistent postmenopausal bleeding at any
   age, while on continuous combined menopause hormone therapy (MHT), and it has
   been more than 6 months since starting therapy."
  REVIEW Q8 - encoded as post-menopausal AND persistent bleeding AND continuous
  combined MHT AND more than 6 months (6 does not qualify, Q17). "At any age"
  is read as lifting P2 row 2's "around the expected age of menopause".
*/
define "P2 Row 3: Persistent Bleeding On Continuous Combined MHT":
  "Is Post-menopausal"
    and "Bool"('symptom.vaginalBleedingPersistent')
    and "Bool"('patient.mhtContinuousCombined')
    and "MHT Months Since Start" > 6.0

/*
  SOURCE (p45, P2 Urgent, bullet 4): "No palpable pelvic mass but new abdominal
   or pelvic symptoms*2 warranting consideration of ovarian cancer which are
   present on a persistent or frequent basis and the Ca-125 result is 35
   units/mL or greater, irrespective of menopause status."
  REVIEW Q17 - "35 units/mL or greater" is >= 35.
*/
define "Ca-125 35 Or Greater": "Dec"('lab.ca125.value') >= 35.0

define "P2 Row 4: Ovarian Cancer Symptoms With Ca-125 35 Or Greater":
  not "Pelvic Mass Palpable"
    and "Ovarian Cancer Symptoms Persistent"
    and "Ca-125 35 Or Greater"

/*
  SOURCE (p45, P2 Urgent, bullet 5): "Abnormal uterine bleeding (AUB) *3 and
   non-uterine causes have been excluded*4, and either:
   - Woman of any age, with abnormal uterine bleeding and at least two risk
     factors*5 for EH/EC OR
   - A pelvic mass is suspected on examination, and no prior imaging has been
     done since the onset of symptoms."
*/
define "P2 Row 5b: Suspected Pelvic Mass Not Yet Imaged":
  "Pelvic Mass Palpable" and not "Bool"('imaging.any.sinceSymptomOnset')

define "P2 Row 5 Either":
  "At Least Two Risk Factors" or "P2 Row 5b: Suspected Pelvic Mass Not Yet Imaged"

define "P2 Row 5: AUB With Non-uterine Causes Excluded And Risk Factors Or Mass":
  "AUB" and "Non-uterine Causes Excluded" and "P2 Row 5 Either"

/*
  SOURCE (p46, P2 Urgent, bullet 6): "Atypical (AG2) endometrial cells reported
   on cervical screening cytology result in women of any age and menopause
   status."
*/
define "P2 Row 6: Atypical Endometrial Cells On Cytology":
  "Bool"('lab.cytology.atypicalEndometrialCells')

/*
  SOURCE (p46, P2 Urgent, bullet 7): "Secondary care clinician or Primary Care
   Radiology Liaison or radiologist advises referral for urgent US pelvis."
*/
define "P2 Row 7: Advice For Urgent US Pelvis":
  "Bool"('advice.urgentImagingRecommended')

/*
  SOURCE (p45, Timeframe column): "P2 Urgent: Non-deferrable imaging or
   intervention that must be completed within 2 weeks of receiving referral."
*/
define "Meets P2 Criteria":
  "P2 Row 1: Pelvic Mass Suspicious Of Cancer"
    or "P2 Row 2: Postmenopausal Bleeding"
    or "P2 Row 3: Persistent Bleeding On Continuous Combined MHT"
    or "P2 Row 4: Ovarian Cancer Symptoms With Ca-125 35 Or Greater"
    or "P2 Row 5: AUB With Non-uterine Causes Excluded And Risk Factors Or Mass"
    or "P2 Row 6: Atypical Endometrial Cells On Cytology"
    or "P2 Row 7: Advice For Urgent US Pelvis"

// ---------------------------------------------------------------------------
// P3 (p46-47)
// ---------------------------------------------------------------------------

/*
  SOURCE (p46, P3, bullet 1): "Women aged 45 years or older with AUB and
   non-uterine causes have been excluded*4."
  REVIEW Q17 - "45 years or older" is >= 45; "younger than 45" (bullets 2-3) is < 45.
*/
define "P3 Row 1: AUB Aged 45 Or Older With Non-uterine Causes Excluded":
  "Age In Years" >= 45 and "AUB" and "Non-uterine Causes Excluded"

/*
  SOURCE (p46, P3, bullet 2): "Women aged younger than 45 years with AUB and one
   or more risk factors for EH/EC*5"
  REVIEW Q12 - as printed, this row does not require non-uterine causes to be
  excluded (bullet 1 and P2 bullet 5 do).
*/
define "P3 Row 2: AUB Under 45 With A Risk Factor":
  "Age In Years" < 45 and "AUB" and "At Least One Risk Factor"

/*
  SOURCE (p46, P3, bullet 3): "Women aged younger than 45 years who have not
   responded to first-line treatment for AUB trialled for at least three
   months."
  REVIEW Q17 - "at least three months" is >= 3.
*/
define "P3 Row 3: AUB Under 45 Not Responding To First-line Treatment":
  "Age In Years" < 45
    and "Dec"('workup.aubFirstLineTreatmentMonths') >= 3.0
    and not "Bool"('workup.aubFirstLineTreatmentResponded')

/*
  SOURCE (p46, P3, bullet 4): "Perimenopausal woman, on combined cyclical MHT,
   with ongoing irregular bleeding, or bleeding outside the time of progestogen
   withdrawal,
   o AND despite a trial of increased progestogen,
   o AND it has been more than 6 months since starting MHT."
*/
define "P3 Row 4: Perimenopausal Bleeding On Cyclical MHT Despite Increased Progestogen":
  "Bool"('patient.perimenopausal')
    and "Bool"('patient.mhtCyclicalCombined')
    and ("Bool"('symptom.irregularBleedingOngoing') or "Bool"('symptom.bleedingOutsideProgestogenWithdrawal'))
    and "Bool"('workup.increasedProgestogenTrialled')
    and "MHT Months Since Start" > 6.0

/*
  SOURCE (p46, P3, bullet 5): "Benign-appearing endometrial cells reported on
   cervical smear and at least one of:
   o The patient is post-menopausal (no period for twelve consecutive months)
   o The patient is symptomatic (e.g. intermenstrual, post-coital, irregular or
     heavy bleeding)
   o The patient has at least one risk factor for EC or EH*5"
*/
define "P3 Row 5 At Least One Of":
  "Is Post-menopausal" or "Bool"('symptom.gynaeSymptomatic') or "At Least One Risk Factor"

define "P3 Row 5: Benign Endometrial Cells With Qualifying Feature":
  "Bool"('lab.cytology.benignEndometrialCells') and "P3 Row 5 At Least One Of"

/*
  SOURCE (p46, P3, bullet 6): "No palpable pelvic mass but new abdominal or
   pelvic symptoms *2 warranting consideration of ovarian cancer are present on
   a persistent or frequent basis for more than 6 weeks AND the patient has not
   been recently investigated."
  REVIEW Q17 - "more than 6 weeks" is > 6.
*/
define "P3 Row 6: Ovarian Cancer Symptoms More Than 6 Weeks Not Recently Investigated":
  not "Pelvic Mass Palpable"
    and "Ovarian Cancer Symptoms Persistent"
    and "Dec"('symptom.ovarianCancerSymptomsWeeks') > 6.0
    and not "Bool"('workup.recentlyInvestigated')

/*
  SOURCE (p46, P3, bullet 7): "Suspected ovarian cyst and either:
   - unilateral pelvic pain for more than four weeks and/or unilateral
     tenderness, or
   - pelvic mass and low suspicion of cancer."
  REVIEW Q17 - "more than four weeks" is > 4.
*/
define "P3 Row 7a: Unilateral Pain More Than 4 Weeks Or Unilateral Tenderness":
  ("Bool"('symptom.pelvicPainUnilateral') and "Dec"('symptom.pelvicPainWeeks') > 4.0)
    or "Bool"('symptom.pelvicTendernessUnilateral')

define "P3 Row 7b: Pelvic Mass With Low Suspicion Of Cancer":
  "Pelvic Mass Palpable" and not "Pelvic Mass Suspicious Of Cancer"

define "P3 Row 7: Suspected Ovarian Cyst With Pain Or Low-suspicion Mass":
  "Bool"('symptom.ovarianCystSuspected')
    and ("P3 Row 7a: Unilateral Pain More Than 4 Weeks Or Unilateral Tenderness"
      or "P3 Row 7b: Pelvic Mass With Low Suspicion Of Cancer")

/*
  SOURCE (p47, P3, bullet 8): "Pelvic pain for more than six weeks, unrelated to
   menstrual cycle, and with pelvic inflammatory disease (PID) excluded as the
   cause of the pain as per local PID HealthPathway."
  symptom.pid false = PID excluded as the cause (one concept, two roles: the
  same indicator true is the PID redirect).
*/
define "P3 Row 8: Pelvic Pain More Than 6 Weeks With PID Excluded":
  "Dec"('symptom.pelvicPainWeeks') > 6.0
    and "Bool"('symptom.pelvicPainUnrelatedToMenstrualCycle')
    and not "Bool"('symptom.pid')

/*
  SOURCE (p47, P3, bullet 9): "Primary amenorrhoea (i.e. absence of menarche by
   age 16 years, or age 14 years if absent secondary sexual characteristics)"
*/
define "P3 Row 9: Primary Amenorrhoea":
  "Bool"('symptom.primaryAmenorrhoea')

/*
  SOURCE (p47, P3, bullet 10): "IUD strings not visible on exam or IUD breaks on
   removal attempt and fragment only removed and patient is asymptomatic."
  REVIEW Q13 - "patient is asymptomatic" is encoded as symptom.iudPerforationSymptoms
  = false. A patient with symptoms not suggestive of perforation meets neither
  this row nor Acute 24h row 2.
*/
define "P3 Row 10: IUD Problem Asymptomatic":
  "IUD Strings Not Visible Or Fragment Retained" and not "IUD Perforation Symptoms"

/*
  SOURCE (p47, P3, bullet 11): "Dysmenorrhoea - (secondary) new onset
   dysmenorrhoea and debilitating pain persists despite a three-month trial of
   medical management as per local Dysmenorrhoea HealthPathway."
  REVIEW Q17 - "a three-month trial" is >= 3 months.
*/
define "P3 Row 11: Secondary Dysmenorrhoea Despite Three Months Medical Management":
  "Bool"('symptom.secondaryDysmenorrhoeaNewOnset')
    and "Bool"('symptom.dysmenorrhoeaDebilitatingPainPersists')
    and "Dec"('workup.dysmenorrhoeaMedicalManagementMonths') >= 3.0

/*
  SOURCE (p47, P3, bullet 12): "Secondary care clinician or Primary Care
   Radiology Liaison or radiologist advises referral for routine ultrasound
   pelvis."
  REVIEW Q16 - "routine" is mapped to the national non-urgent gateway
  (advice.nonUrgentImagingRecommended, which the vocabulary attributes to p47).
*/
define "P3 Row 12: Advice For Routine Ultrasound Pelvis":
  "Bool"('advice.nonUrgentImagingRecommended')

/*
  SOURCE (p46, Timeframe column): "P3 non-deferrable imaging or intervention
   that must be completed within 6 weeks of receiving referral."
*/
define "Meets P3 Criteria":
  "P3 Row 1: AUB Aged 45 Or Older With Non-uterine Causes Excluded"
    or "P3 Row 2: AUB Under 45 With A Risk Factor"
    or "P3 Row 3: AUB Under 45 Not Responding To First-line Treatment"
    or "P3 Row 4: Perimenopausal Bleeding On Cyclical MHT Despite Increased Progestogen"
    or "P3 Row 5: Benign Endometrial Cells With Qualifying Feature"
    or "P3 Row 6: Ovarian Cancer Symptoms More Than 6 Weeks Not Recently Investigated"
    or "P3 Row 7: Suspected Ovarian Cyst With Pain Or Low-suspicion Mass"
    or "P3 Row 8: Pelvic Pain More Than 6 Weeks With PID Excluded"
    or "P3 Row 9: Primary Amenorrhoea"
    or "P3 Row 10: IUD Problem Asymptomatic"
    or "P3 Row 11: Secondary Dysmenorrhoea Despite Three Months Medical Management"
    or "P3 Row 12: Advice For Routine Ultrasound Pelvis"

// ---------------------------------------------------------------------------
// P4 Deferrable (p47)
// ---------------------------------------------------------------------------

/*
  SOURCE (p47, P4, bullet 1): "Polycystic ovary syndrome (PCOS) suspected, but
   only one of the three Rotterdam diagnostic criteria (i.e. hyperandrogenism,
   polycystic ovaries, irregular menses) fulfilled."
  "Only one": exactly one of the three known true and the other two known false.
*/
define "Rotterdam Criteria Flags":
  { "Bool"('symptom.hyperandrogenism'), "Bool"('symptom.polycysticOvaries'), "Bool"('symptom.irregularMenses') }

define "Rotterdam Criteria Met Count": Length("Rotterdam Criteria Flags" F where F is true return all F)
define "Rotterdam Criteria Unknown Count": Length("Rotterdam Criteria Flags" F where F is null return all F)

define "Only One Rotterdam Criterion Fulfilled":
  if "Rotterdam Criteria Met Count" >= 2 then false
  else if "Rotterdam Criteria Unknown Count" > 0 then null
  else "Rotterdam Criteria Met Count" = 1

define "P4 Row 1: Suspected PCOS With Only One Rotterdam Criterion":
  "Bool"('symptom.pcosSuspected') and "Only One Rotterdam Criterion Fulfilled"

/*
  SOURCE (p47, P4, bullet 2): "Known fibroid larger than 5cms which becomes
   symptomatic with pelvic pressure, back pain, dyspareunia, or urination
   difficulties after commencing MHT."
  REVIEW Q17 - "larger than 5cms" is > 5.
*/
define "P4 Row 2: Known Fibroid Over 5cm Symptomatic After Starting MHT":
  "Dec"('symptom.knownFibroidSizeCm') > 5.0
    and "Bool"('symptom.fibroidSymptomaticAfterStartingMht')

/*
  SOURCE (p47, P4, bullet 3): "Secondary care clinician or Primary Care
   Radiology Liaison or radiologist advises referral for deferrable, non-urgent
   ultrasound pelvis."
  REVIEW Q16 - its own indicator (advice.deferrableImagingRecommended).
*/
define "P4 Row 3: Advice For Deferrable Ultrasound Pelvis":
  "Bool"('advice.deferrableImagingRecommended')

/*
  SOURCE (p47, Timeframe column): "P4 Deferrable. If capacity is constrained
   could wait up to 6-12 weeks from receiving referral."
*/
define "Meets P4 Criteria":
  "P4 Row 1: Suspected PCOS With Only One Rotterdam Criterion"
    or "P4 Row 2: Known Fibroid Over 5cm Symptomatic After Starting MHT"
    or "P4 Row 3: Advice For Deferrable Ultrasound Pelvis"

// ---------------------------------------------------------------------------
// S2 and S3 time-sensitive follow-up (p47-48)
// ---------------------------------------------------------------------------

/*
  REVIEW Q21 - "according to the ACR published table or ACR mobile phone app":
  the table decides whether and when a follow-up scan is due; the bundle does
  not contain the table. The referrer supplies the interval
  (workup.followUpIntervalMonths) and that a follow-up scan is requested
  (workup.followUpScan).
  "in both pre- and post-menopausal woman" is population scope, not logic.
*/
define "Follow-up Scan Requested": "Bool"('workup.followUpScan')
define "Follow-up Interval Months": "Dec"('workup.followUpIntervalMonths')

/*
  SOURCE (p47, S2, bullet 1): "6-month follow-up scans of O-RADS 2 ovarian or
   adnexal cysts, in both pre- and post-menopausal woman according to the ACR
   published table or ACR mobile phone app."
*/
define "S2 Row 1: 6-month Follow-up Of O-RADS 2 Cyst":
  "Follow-up Scan Requested" and "Bool"('symptom.ovarianCystORads2') and "Follow-up Interval Months" = 6.0

/*
  SOURCE (p47, S2, bullet 2): "Follow up scans of haemorrhagic cyst in
   pre-menopausal woman according to the ACR published table or ACR mobile
   phone app."
*/
define "S2 Row 2: Follow-up Of Haemorrhagic Cyst Pre-menopausal":
  "Follow-up Scan Requested" and "Bool"('symptom.haemorrhagicCyst') and "Is Pre-menopausal"

/*
  SOURCE (p47, S2, bullet 3): "Follow up scan of asymptomatic endometrial polyps
   detected as incidental finding on US in a patient without risk factors for
   EH/ EC as per local Incidental Findings in Imaging HealthPathway."
*/
define "S2 Row 3: Follow-up Of Incidental Endometrial Polyp Without Risk Factors":
  "Follow-up Scan Requested" and "Bool"('symptom.endometrialPolypIncidental') and "No Risk Factors"

/*
  SOURCE (p47, Timeframe column): "S2 non-deferrable time sensitive imaging or
   intervention that must be completed within 2 weeks of a specified target
   date."
  SOURCE (p47, S2, bullet 4) - NOT ENCODED (REVIEW Q3): "Secondary care clinician
   or Primary Care Radiology Liaison or radiologist advises referral for
   time-sensitive, specified date, follow-up ultrasound of the pelvis"
*/
define "Meets S2 Criteria":
  "S2 Row 1: 6-month Follow-up Of O-RADS 2 Cyst"
    or "S2 Row 2: Follow-up Of Haemorrhagic Cyst Pre-menopausal"
    or "S2 Row 3: Follow-up Of Incidental Endometrial Polyp Without Risk Factors"

/*
  SOURCE (p48, S3, bullet 1): "12-month follow-up scans of O-RADS-2 ovarian or
   adnexal cysts, in both pre- and post-menopausal woman according to the ACR
   published table or ACR mobile phone app"
*/
define "S3 Row 1: 12-month Follow-up Of O-RADS 2 Cyst":
  "Follow-up Scan Requested" and "Bool"('symptom.ovarianCystORads2') and "Follow-up Interval Months" = 12.0

/*
  SOURCE (p48, S3, bullet 2): "12 month follow up scan of suspected dermoid cyst
   in pre-menopausal woman according to the ACR published table or ACR mobile
   phone app"
*/
define "S3 Row 2: 12-month Follow-up Of Suspected Dermoid Pre-menopausal":
  "Follow-up Scan Requested" and "Bool"('symptom.dermoidCystSuspected') and "Is Pre-menopausal"
    and "Follow-up Interval Months" = 12.0

/*
  SOURCE (p48, S3, bullet 3): "12 month follow up scan of suspected asymptomatic
   endometrioma in pre-menopausal woman according to the ACR published table or
   ACR mobile phone app"
*/
define "S3 Row 3: 12-month Follow-up Of Suspected Asymptomatic Endometrioma Pre-menopausal":
  "Follow-up Scan Requested" and "Bool"('symptom.endometriomaSuspected')
    and not "Bool"('symptom.ovarianCystSymptomatic') and "Is Pre-menopausal"
    and "Follow-up Interval Months" = 12.0

/*
  SOURCE (p48, Timeframe column): "S3 non-deferrable time sensitive imaging or
   intervention that must be completed within 6 weeks of a specified target
   date."
  SOURCE (p48, S3, bullet 4) - NOT ENCODED (REVIEW Q3): "Secondary care clinician
   or Primary Care Radiology Liaison or radiologist advises referral for
   time–sensitive, specified date follow-up ultrasound of the pelvis"
*/
define "Meets S3 Criteria":
  "S3 Row 1: 12-month Follow-up Of O-RADS 2 Cyst"
    or "S3 Row 2: 12-month Follow-up Of Suspected Dermoid Pre-menopausal"
    or "S3 Row 3: 12-month Follow-up Of Suspected Asymptomatic Endometrioma Pre-menopausal"

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (p48)
// ---------------------------------------------------------------------------

/*
  SOURCE (p48, "Alternative management or HealthPathway recommended."):
   - "Suspected retained products of conception (RPOC) with persistent or heavy
      bleeding after abortion or miscarriage - See local Abortion HealthPathway
      or Miscarriage HealthPathway."
   - "Suspected endometriosis in the absence of a clinically palpable mass - See
      local Endometriosis HealthPathway."
   - "Primary dysmenorrhoea in the absence of a clinically palpable mass - See
      local Dysmenorrhoea HealthPathway."
   - "Pelvic inflammatory disease (PID) in the absence of a clinically palpable
      mass - See local PID HealthPathway."
   - "Cervical polyps - referral to secondary care rather than ultrasound is
      recommended for women with polyps which prove difficult to remove.
      Ultrasound is not able to identify the rare occurrence of malignant polyps
      - See local Endometrial Polyps HealthPathway."
   - "Secondary amenorrhoea. Pelvic USS is not normally helpful in diagnosing
      secondary amenorrhoea unless a pelvis mass is present, or the patient has
      significantly raised androgens which would raise concern regarding an
      ovarian tumour."
  "In the absence of a clinically palpable mass" requires the mass to be known
  absent; an unknown mass leaves the redirect unresolved and is surfaced in
  Unconfirmed Exclusions.
  REVIEW Q19 - the secondary amenorrhoea "unless" clause is encoded as: no
  palpable pelvic mass AND no significantly raised androgens.
*/
define "Redirect: RPOC With Persistent Or Heavy Bleeding":
  "Bool"('symptom.rpocSuspected') and "Bool"('symptom.bleedingPersistentOrHeavyPostAbortionOrMiscarriage')
define "Redirect: Endometriosis Without Palpable Mass":
  "Bool"('symptom.endometriosisSuspected') and not "Pelvic Mass Palpable"
define "Redirect: Primary Dysmenorrhoea Without Palpable Mass":
  "Bool"('symptom.primaryDysmenorrhoea') and not "Pelvic Mass Palpable"
define "Redirect: PID Without Palpable Mass":
  "Bool"('symptom.pid') and not "Pelvic Mass Palpable"
define "Redirect: Cervical Polyps":
  "Bool"('symptom.cervicalPolyp')
define "Redirect: Secondary Amenorrhoea Without Mass Or Raised Androgens":
  "Bool"('symptom.secondaryAmenorrhoea') and not "Pelvic Mass Palpable"
    and not "Bool"('lab.androgens.significantlyRaised')

define "Active Redirects":
  (List<String>{
    if "Redirect: RPOC With Persistent Or Heavy Bleeding" is true then 'Suspected retained products of conception (RPOC) with persistent or heavy bleeding after abortion or miscarriage - See local Abortion HealthPathway or Miscarriage HealthPathway.' else null,
    if "Redirect: Endometriosis Without Palpable Mass" is true then 'Suspected endometriosis in the absence of a clinically palpable mass - See local Endometriosis HealthPathway.' else null,
    if "Redirect: Primary Dysmenorrhoea Without Palpable Mass" is true then 'Primary dysmenorrhoea in the absence of a clinically palpable mass - See local Dysmenorrhoea HealthPathway.' else null,
    if "Redirect: PID Without Palpable Mass" is true then 'Pelvic inflammatory disease (PID) in the absence of a clinically palpable mass - See local PID HealthPathway.' else null,
    if "Redirect: Cervical Polyps" is true then 'Cervical polyps - referral to secondary care rather than ultrasound is recommended for women with polyps which prove difficult to remove. Ultrasound is not able to identify the rare occurrence of malignant polyps - See local Endometrial Polyps HealthPathway.' else null,
    if "Redirect: Secondary Amenorrhoea Without Mass Or Raised Androgens" is true then 'Secondary amenorrhoea. Pelvic USS is not normally helpful in diagnosing secondary amenorrhoea unless a pelvis mass is present, or the patient has significantly raised androgens which would raise concern regarding an ovarian tumour.' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

// A redirect the referral raises (its presenting concept answered true, under any
// documentation standard) but cannot settle: the linkIds that would settle it.
define "Unconfirmed Exclusions":
  (if "Answered True"('symptom.rpocSuspected') and "Redirect: RPOC With Persistent Or Heavy Bleeding" is null
     then "Present"({ "If Unknown"('symptom.rpocSuspected'), "If Unknown"('symptom.bleedingPersistentOrHeavyPostAbortionOrMiscarriage') })
     else {} as List<String>)
  union (if "Answered True"('symptom.endometriosisSuspected') and "Redirect: Endometriosis Without Palpable Mass" is null
     then "Present"({ "If Unknown"('symptom.endometriosisSuspected'), "If Unknown"('symptom.pelvicMassPalpable') })
     else {} as List<String>)
  union (if "Answered True"('symptom.primaryDysmenorrhoea') and "Redirect: Primary Dysmenorrhoea Without Palpable Mass" is null
     then "Present"({ "If Unknown"('symptom.primaryDysmenorrhoea'), "If Unknown"('symptom.pelvicMassPalpable') })
     else {} as List<String>)
  union (if "Answered True"('symptom.pid') and "Redirect: PID Without Palpable Mass" is null
     then "Present"({ "If Unknown"('symptom.pid'), "If Unknown"('symptom.pelvicMassPalpable') })
     else {} as List<String>)
  union (if "Answered True"('symptom.cervicalPolyp') and "Redirect: Cervical Polyps" is null
     then { 'symptom.cervicalPolyp' }
     else {} as List<String>)
  union (if "Answered True"('symptom.secondaryAmenorrhoea') and "Redirect: Secondary Amenorrhoea Without Mass Or Raised Androgens" is null
     then "Present"({ "If Unknown"('symptom.secondaryAmenorrhoea'), "If Unknown"('symptom.pelvicMassPalpable'), "If Unknown"('lab.androgens.significantlyRaised') })
     else {} as List<String>)

// ---------------------------------------------------------------------------
// Not routinely funded (p49)
// ---------------------------------------------------------------------------

/*
  SOURCE (p49, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
   1 "Routine follow-up of known fibroids"
   2 "Subfertility"
   3 "Follow-up of asymptomatic, simple ovarian cyst (O-RADS 2) less than 3 cm in
      diameter in post-menopausal woman"
   4 "Follow-up of asymptomatic, simple ovarian cyst (O-RADS 2) less than 5 cm in
      diameter in premenopausal woman"
   5 "Follow-up of asymptomatic, non-simple ovarian cyst less than 3 cm diameter
      in premenopausal woman"
   6 "Follow up of typical-appearing haemorrhagic cyst up to 5cms diameter in
      pre-menopausal woman."
   7 "Benign-appearing endometrial cells on smear in asymptomatic,
      pre-menopausal women, no abnormality on exam and without any risk
      factors*5 for endometrial hyperplasia or cancer"
   8 "Erratic, unscheduled bleeding in the first 3 to 6 months after starting MHT."
   9 "Screening ultrasound scan for a family history of ovarian cancer. All women
      with Lynch Syndrome, Hereditary non-polyposis colorectal cancer (HNPCC), or
      Cowden Syndrome, or BRCA gene mutations associated with increased ovarian
      cancer risk should be referred to secondary care for assessment and
      management. There is insufficient evidence to warrant routine pelvic US
      screening in asymptomatic women."
  10 "Women aged less than 45 years with abnormal uterine bleeding and no risk
      factors for endometrial hyperplasia or endometrial cancer, no abnormality
      on examination and where first line treatment has not been trialled."
  Each is read "is true": an unknown does not make the referral not funded.
  REVIEW Q17 - "less than 3 cm" < 3; "less than 5 cm" < 5; "up to 5cms" <= 5.
  REVIEW Q18 - "simple ovarian cyst (O-RADS 2)": the parenthetical is read as the
  category label of the simple cyst; O-RADS 2 is not separately required.
  REVIEW Q15 - "in the first 3 to 6 months" is read as within 6 months of
  starting MHT (6 inclusive), the complement of P2 row 3 / P3 row 4 ("more than
  6 months").
*/
define "Cyst Asymptomatic": not "Bool"('symptom.ovarianCystSymptomatic')
define "Cyst Size Cm": "Dec"('symptom.ovarianCystSizeCm')

define "Not Funded 1: Routine Follow-up Of Known Fibroids": "Bool"('funding.routineFibroidFollowUp')
define "Not Funded 2: Subfertility": "Bool"('funding.subfertility')
define "Not Funded 3: Small Simple Cyst Post-menopausal":
  "Follow-up Scan Requested" and "Cyst Asymptomatic" and "Bool"('symptom.ovarianCystSimple')
    and "Cyst Size Cm" < 3.0 and "Is Post-menopausal"
define "Not Funded 4: Simple Cyst Under 5cm Premenopausal":
  "Follow-up Scan Requested" and "Cyst Asymptomatic" and "Bool"('symptom.ovarianCystSimple')
    and "Cyst Size Cm" < 5.0 and "Is Pre-menopausal"
define "Not Funded 5: Non-simple Cyst Under 3cm Premenopausal":
  "Follow-up Scan Requested" and "Cyst Asymptomatic" and not "Bool"('symptom.ovarianCystSimple')
    and "Cyst Size Cm" < 3.0 and "Is Pre-menopausal"
define "Not Funded 6: Typical Haemorrhagic Cyst Up To 5cm Pre-menopausal":
  "Follow-up Scan Requested" and "Bool"('symptom.haemorrhagicCyst') and "Bool"('symptom.haemorrhagicCystTypicalAppearing')
    and "Cyst Size Cm" <= 5.0 and "Is Pre-menopausal"
define "Not Funded 7: Benign Endometrial Cells Asymptomatic Pre-menopausal No Risk Factors":
  "Bool"('lab.cytology.benignEndometrialCells') and not "Bool"('symptom.gynaeSymptomatic')
    and "Is Pre-menopausal" and not "Bool"('symptom.examinationAbnormality') and "No Risk Factors"
define "Not Funded 8: Erratic Unscheduled Bleeding Within 6 Months Of Starting MHT":
  "Bool"('symptom.erraticUnscheduledBleedingOnMht') and "MHT Months Since Start" <= 6.0
define "Not Funded 9: Screening For Family History Of Ovarian Cancer": "Bool"('funding.ovarianCancerFamilyHistoryScreening')
define "Not Funded 10: AUB Under 45 No Risk Factors First-line Not Trialled":
  "Age In Years" < 45 and "AUB" and "No Risk Factors"
    and not "Bool"('symptom.examinationAbnormality') and not "Bool"('workup.aubFirstLineTreatmentTrialled')

define "Not Routinely Funded":
  "Not Funded 1: Routine Follow-up Of Known Fibroids" is true
    or "Not Funded 2: Subfertility" is true
    or "Not Funded 3: Small Simple Cyst Post-menopausal" is true
    or "Not Funded 4: Simple Cyst Under 5cm Premenopausal" is true
    or "Not Funded 5: Non-simple Cyst Under 3cm Premenopausal" is true
    or "Not Funded 6: Typical Haemorrhagic Cyst Up To 5cm Pre-menopausal" is true
    or "Not Funded 7: Benign Endometrial Cells Asymptomatic Pre-menopausal No Risk Factors" is true
    or "Not Funded 8: Erratic Unscheduled Bleeding Within 6 Months Of Starting MHT" is true
    or "Not Funded 9: Screening For Family History Of Ovarian Cancer" is true
    or "Not Funded 10: AUB Under 45 No Risk Factors First-line Not Trialled" is true

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q1, Q2 - confirm):
    1. Not routinely funded
    2. Alternative management / redirect (BRD TA-013: redirect wins over criteria)
    3. Paediatric patient - the adult criteria do not apply (BRD TA-003)
    4. Age unknown - insufficient information
    5. The most urgent timeframe with a met row, in printed order:
       Acute 24h, Acute 48h, P2, P3, P4, S2, S3. A more urgent row that is
       unresolved does not block a less urgent met row; its missing indicators
       are listed in Missing Information.
    6. Every timeframe definitively not met - criteria not met
    7. Otherwise insufficient information
*/
define "Determination":
  case
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Is Adult" is null then 'INSUFFICIENT_INFORMATION'
    when "Meets Acute 24h Criteria" is true then 'ACUTE_24H'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P3 Criteria" is true then 'P3_NON_DEFERRABLE'
    when "Meets P4 Criteria" is true then 'P4_DEFERRABLE'
    when "Meets S2 Criteria" is true then 'S2_TIME_SENSITIVE'
    when "Meets S3 Criteria" is true then 'S3_TIME_SENSITIVE'
    when "Meets Acute 24h Criteria" is false and "Meets Acute 48h Criteria" is false
      and "Meets P2 Criteria" is false and "Meets P3 Criteria" is false and "Meets P4 Criteria" is false
      and "Meets S2 Criteria" is false and "Meets S3 Criteria" is false then 'CRITERIA_NOT_MET'
    else 'INSUFFICIENT_INFORMATION'
  end

// Triager-only field. Acute timeframes print no code.
define "Priority Code":
  case "Determination"
    when 'ACUTE_24H' then 'A24'
    when 'ACUTE_48H' then 'A48'
    when 'P2_URGENT' then 'P2'
    when 'P3_NON_DEFERRABLE' then 'P3'
    when 'P4_DEFERRABLE' then 'P4'
    when 'S2_TIME_SENSITIVE' then 'S2'
    when 'S3_TIME_SENSITIVE' then 'S3'
    else null
  end

/*
  SOURCE (Timeframe column, pp.44-48), with the priority code removed (GEN-004:
  the timeframe words are shown to referrers, the code is not):
   p44 "Acute: Within 24 hours"; p45 "Acute: Within 48 hours";
   p45 "P2 Urgent: Non-deferrable imaging or intervention that must be completed
        within 2 weeks of receiving referral.";
   p46 "P3 non-deferrable imaging or intervention that must be completed within
        6 weeks of receiving referral.";
   p47 "P4 Deferrable. If capacity is constrained could wait up to 6-12 weeks
        from receiving referral.";
   p47 "S2 non-deferrable time sensitive imaging or intervention that must be
        completed within 2 weeks of a specified target date.";
   p48 "S3 non-deferrable time sensitive imaging or intervention that must be
        completed within 6 weeks of a specified target date."
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_24H' then 'Acute: Within 24 hours'
    when 'ACUTE_48H' then 'Acute: Within 48 hours'
    when 'P2_URGENT' then 'Non-deferrable imaging or intervention that must be completed within 2 weeks of receiving referral.'
    when 'P3_NON_DEFERRABLE' then 'Non-deferrable imaging or intervention that must be completed within 6 weeks of receiving referral.'
    when 'P4_DEFERRABLE' then 'Deferrable. If capacity is constrained could wait up to 6-12 weeks from receiving referral.'
    when 'S2_TIME_SENSITIVE' then 'Non-deferrable time sensitive imaging or intervention that must be completed within 2 weeks of a specified target date.'
    when 'S3_TIME_SENSITIVE' then 'Non-deferrable time sensitive imaging or intervention that must be completed within 6 weeks of a specified target date.'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
//
// A row is "engaged" when one of its presenting indicators is answered true
// (under any documentation standard). An engaged row that is still unresolved
// lists the indicators that would resolve it. Rows the referral does not touch
// list nothing: listing every indicator of an eight-page section would bury the
// useful ones. With a met determination, only engaged rows of MORE urgent
// timeframes are listed (they could raise the urgency), plus the adviser.
// ---------------------------------------------------------------------------

define "Missing Age":
  if "Age In Years" is null then { 'patient.age' } else {} as List<String>

define function "Missing If"(engaged Boolean, unresolved Boolean, ids List<String>):
  if engaged and unresolved then "Present"(ids) else {} as List<String>

define "IUD Engaged":
  "Answered True"('symptom.iudStringsNotVisible') or "Answered True"('symptom.iudFragmentRetained')
    or "Answered True"('symptom.iudPerforationSymptoms')

define "IUD Missing": "Present"({
  if "IUD Strings Not Visible Or Fragment Retained" is null then "If Unknown"('symptom.iudStringsNotVisible') else null,
  if "IUD Strings Not Visible Or Fragment Retained" is null then "If Unknown"('symptom.iudFragmentRetained') else null,
  "If Unknown"('symptom.iudPerforationSymptoms') })

define "Missing Acute 24":
  "Missing If"("Answered True"('symptom.acutelyUnwellSuspectedGynaeCause'),
    "Acute 24h Row 1: Acutely Unwell From Suspected Gynaecological Cause" is null,
    { "If Unknown"('symptom.acutelyUnwellSuspectedGynaeCause') })
  union "Missing If"("IUD Engaged", "Acute 24h Row 2: IUD Problem With Possible Perforation Symptoms" is null, "IUD Missing")

define "Missing Acute 48":
  "Missing If"("Answered True"('symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage'),
    "Acute 48h Row 1: Suspected Ongoing Pregnancy With Raised HCG" is null,
    { "If Unknown"('symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage'),
      if ("Urine HCG Greater Than 1000 At 14 Days" or "Bool"('lab.serumBhcg.remainsHigh')) is null then "If Unknown"('lab.urineHcg.value') else null,
      if ("Urine HCG Greater Than 1000 At 14 Days" or "Bool"('lab.serumBhcg.remainsHigh')) is null then "If Unknown"('lab.serumBhcg.remainsHigh') else null })
  union "Missing If"("Answered True"('advice.acuteImagingRecommended'),
    "Acute 48h Row 2: Advice For Same Or Next Day Ultrasound" is null,
    { "If Unknown"('advice.acuteImagingRecommended') })

define "AUB Engaged": "Answered True"('symptom.abnormalUterineBleeding')

define "Missing P2":
  "Missing If"("Answered True"('symptom.pelvicMassPalpable') or "Answered True"('symptom.pelvicMassSuspiciousOfCancer'),
    "P2 Row 1: Pelvic Mass Suspicious Of Cancer" is null,
    { "If Unknown"('symptom.pelvicMassPalpable'), "If Unknown"('symptom.pelvicMassSuspiciousOfCancer') })
  union "Missing If"("Answered True"('symptom.postmenopausalBleeding'),
    "P2 Row 2: Postmenopausal Bleeding" is null,
    { "If Unknown"('symptom.postmenopausalBleeding') })
  union "Missing If"("Answered True"('symptom.vaginalBleedingPersistent') or "Answered True"('patient.mhtContinuousCombined'),
    "P2 Row 3: Persistent Bleeding On Continuous Combined MHT" is null,
    { "If Unknown"('patient.postmenopausal'), "If Unknown"('symptom.vaginalBleedingPersistent'),
      "If Unknown"('patient.mhtContinuousCombined'), "If Unknown"('patient.mhtMonthsSinceStart') })
  union "Missing If"("Answered True"('symptom.ovarianCancerSymptomsPersistent'),
    "P2 Row 4: Ovarian Cancer Symptoms With Ca-125 35 Or Greater" is null,
    { "If Unknown"('symptom.ovarianCancerSymptomsPersistent'), "If Unknown"('symptom.pelvicMassPalpable'), "If Unknown"('lab.ca125.value') })
  union "Missing If"("AUB Engaged",
    "P2 Row 5: AUB With Non-uterine Causes Excluded And Risk Factors Or Mass" is null,
    { "If Unknown"('symptom.abnormalUterineBleeding'), "If Unknown"('workup.nonUterineBleedingCausesExcluded'),
      if "P2 Row 5 Either" is null and "P2 Row 5b: Suspected Pelvic Mass Not Yet Imaged" is null then "If Unknown"('symptom.pelvicMassPalpable') else null,
      if "P2 Row 5 Either" is null and "P2 Row 5b: Suspected Pelvic Mass Not Yet Imaged" is null then "If Unknown"('imaging.any.sinceSymptomOnset') else null })
  union (if "AUB Engaged" and "P2 Row 5: AUB With Non-uterine Causes Excluded And Risk Factors Or Mass" is null
           and "P2 Row 5 Either" is null and "At Least Two Risk Factors" is null
         then "Unknown Risk Factors" else {} as List<String>)
  union "Missing If"("Answered True"('lab.cytology.atypicalEndometrialCells'),
    "P2 Row 6: Atypical Endometrial Cells On Cytology" is null,
    { "If Unknown"('lab.cytology.atypicalEndometrialCells') })
  union "Missing If"("Answered True"('advice.urgentImagingRecommended'),
    "P2 Row 7: Advice For Urgent US Pelvis" is null,
    { "If Unknown"('advice.urgentImagingRecommended') })

define "Missing P3":
  "Missing If"("AUB Engaged",
    "P3 Row 1: AUB Aged 45 Or Older With Non-uterine Causes Excluded" is null,
    { "If Unknown"('symptom.abnormalUterineBleeding'), "If Unknown"('workup.nonUterineBleedingCausesExcluded') })
  union "Missing If"("AUB Engaged",
    "P3 Row 2: AUB Under 45 With A Risk Factor" is null,
    { "If Unknown"('symptom.abnormalUterineBleeding') })
  union (if "AUB Engaged" and "P3 Row 2: AUB Under 45 With A Risk Factor" is null and "At Least One Risk Factor" is null
         then "Unknown Risk Factors" else {} as List<String>)
  union "Missing If"("Answered True"('workup.aubFirstLineTreatmentTrialled') or "Is Answered"('workup.aubFirstLineTreatmentMonths'),
    "P3 Row 3: AUB Under 45 Not Responding To First-line Treatment" is null,
    { "If Unknown"('workup.aubFirstLineTreatmentMonths'), "If Unknown"('workup.aubFirstLineTreatmentResponded') })
  union "Missing If"("Answered True"('patient.mhtCyclicalCombined') or "Answered True"('patient.perimenopausal'),
    "P3 Row 4: Perimenopausal Bleeding On Cyclical MHT Despite Increased Progestogen" is null,
    { "If Unknown"('patient.perimenopausal'), "If Unknown"('patient.mhtCyclicalCombined'),
      if ("Bool"('symptom.irregularBleedingOngoing') or "Bool"('symptom.bleedingOutsideProgestogenWithdrawal')) is null then "If Unknown"('symptom.irregularBleedingOngoing') else null,
      if ("Bool"('symptom.irregularBleedingOngoing') or "Bool"('symptom.bleedingOutsideProgestogenWithdrawal')) is null then "If Unknown"('symptom.bleedingOutsideProgestogenWithdrawal') else null,
      "If Unknown"('workup.increasedProgestogenTrialled'), "If Unknown"('patient.mhtMonthsSinceStart') })
  union "Missing If"("Answered True"('lab.cytology.benignEndometrialCells'),
    "P3 Row 5: Benign Endometrial Cells With Qualifying Feature" is null,
    { "If Unknown"('lab.cytology.benignEndometrialCells'),
      if "P3 Row 5 At Least One Of" is null then "If Unknown"('patient.postmenopausal') else null,
      if "P3 Row 5 At Least One Of" is null then "If Unknown"('symptom.gynaeSymptomatic') else null })
  union (if "Answered True"('lab.cytology.benignEndometrialCells') and "P3 Row 5: Benign Endometrial Cells With Qualifying Feature" is null
           and "P3 Row 5 At Least One Of" is null and "At Least One Risk Factor" is null
         then "Unknown Risk Factors" else {} as List<String>)
  union "Missing If"("Answered True"('symptom.ovarianCancerSymptomsPersistent'),
    "P3 Row 6: Ovarian Cancer Symptoms More Than 6 Weeks Not Recently Investigated" is null,
    { "If Unknown"('symptom.ovarianCancerSymptomsPersistent'), "If Unknown"('symptom.pelvicMassPalpable'),
      "If Unknown"('symptom.ovarianCancerSymptomsWeeks'), "If Unknown"('workup.recentlyInvestigated') })
  union "Missing If"("Answered True"('symptom.ovarianCystSuspected'),
    "P3 Row 7: Suspected Ovarian Cyst With Pain Or Low-suspicion Mass" is null,
    { "If Unknown"('symptom.ovarianCystSuspected'),
      if "P3 Row 7a: Unilateral Pain More Than 4 Weeks Or Unilateral Tenderness" is null then "If Unknown"('symptom.pelvicPainUnilateral') else null,
      if "P3 Row 7a: Unilateral Pain More Than 4 Weeks Or Unilateral Tenderness" is null then "If Unknown"('symptom.pelvicPainWeeks') else null,
      if "P3 Row 7a: Unilateral Pain More Than 4 Weeks Or Unilateral Tenderness" is null then "If Unknown"('symptom.pelvicTendernessUnilateral') else null,
      if "P3 Row 7b: Pelvic Mass With Low Suspicion Of Cancer" is null then "If Unknown"('symptom.pelvicMassPalpable') else null,
      if "P3 Row 7b: Pelvic Mass With Low Suspicion Of Cancer" is null then "If Unknown"('symptom.pelvicMassSuspiciousOfCancer') else null })
  union "Missing If"("Is Answered"('symptom.pelvicPainWeeks') or "Answered True"('symptom.pelvicPainUnrelatedToMenstrualCycle'),
    "P3 Row 8: Pelvic Pain More Than 6 Weeks With PID Excluded" is null,
    { "If Unknown"('symptom.pelvicPainWeeks'), "If Unknown"('symptom.pelvicPainUnrelatedToMenstrualCycle'), "If Unknown"('symptom.pid') })
  union "Missing If"("Answered True"('symptom.primaryAmenorrhoea'),
    "P3 Row 9: Primary Amenorrhoea" is null,
    { "If Unknown"('symptom.primaryAmenorrhoea') })
  union "Missing If"("IUD Engaged", "P3 Row 10: IUD Problem Asymptomatic" is null, "IUD Missing")
  union "Missing If"("Answered True"('symptom.secondaryDysmenorrhoeaNewOnset') or "Answered True"('symptom.dysmenorrhoeaDebilitatingPainPersists'),
    "P3 Row 11: Secondary Dysmenorrhoea Despite Three Months Medical Management" is null,
    { "If Unknown"('symptom.secondaryDysmenorrhoeaNewOnset'), "If Unknown"('symptom.dysmenorrhoeaDebilitatingPainPersists'),
      "If Unknown"('workup.dysmenorrhoeaMedicalManagementMonths') })
  union "Missing If"("Answered True"('advice.nonUrgentImagingRecommended'),
    "P3 Row 12: Advice For Routine Ultrasound Pelvis" is null,
    { "If Unknown"('advice.nonUrgentImagingRecommended') })

define "Missing P4":
  "Missing If"("Answered True"('symptom.pcosSuspected'),
    "P4 Row 1: Suspected PCOS With Only One Rotterdam Criterion" is null,
    { "If Unknown"('symptom.pcosSuspected'), "If Unknown"('symptom.hyperandrogenism'),
      "If Unknown"('symptom.polycysticOvaries'), "If Unknown"('symptom.irregularMenses') })
  union "Missing If"("Is Answered"('symptom.knownFibroidSizeCm') or "Answered True"('symptom.fibroidSymptomaticAfterStartingMht'),
    "P4 Row 2: Known Fibroid Over 5cm Symptomatic After Starting MHT" is null,
    { "If Unknown"('symptom.knownFibroidSizeCm'), "If Unknown"('symptom.fibroidSymptomaticAfterStartingMht') })
  union "Missing If"("Answered True"('advice.deferrableImagingRecommended'),
    "P4 Row 3: Advice For Deferrable Ultrasound Pelvis" is null,
    { "If Unknown"('advice.deferrableImagingRecommended') })

define "Missing S2":
  "Missing If"("Answered True"('symptom.ovarianCystORads2'),
    "S2 Row 1: 6-month Follow-up Of O-RADS 2 Cyst" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.ovarianCystORads2'), "If Unknown"('workup.followUpIntervalMonths') })
  union "Missing If"("Answered True"('symptom.haemorrhagicCyst'),
    "S2 Row 2: Follow-up Of Haemorrhagic Cyst Pre-menopausal" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.haemorrhagicCyst'), "If Unknown"('patient.postmenopausal') })
  union "Missing If"("Answered True"('symptom.endometrialPolypIncidental'),
    "S2 Row 3: Follow-up Of Incidental Endometrial Polyp Without Risk Factors" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.endometrialPolypIncidental') })
  union (if "Answered True"('symptom.endometrialPolypIncidental')
           and "S2 Row 3: Follow-up Of Incidental Endometrial Polyp Without Risk Factors" is null and "No Risk Factors" is null
         then "Unknown Risk Factors" else {} as List<String>)

define "Missing S3":
  "Missing If"("Answered True"('symptom.ovarianCystORads2'),
    "S3 Row 1: 12-month Follow-up Of O-RADS 2 Cyst" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.ovarianCystORads2'), "If Unknown"('workup.followUpIntervalMonths') })
  union "Missing If"("Answered True"('symptom.dermoidCystSuspected'),
    "S3 Row 2: 12-month Follow-up Of Suspected Dermoid Pre-menopausal" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.dermoidCystSuspected'), "If Unknown"('patient.postmenopausal'),
      "If Unknown"('workup.followUpIntervalMonths') })
  union "Missing If"("Answered True"('symptom.endometriomaSuspected'),
    "S3 Row 3: 12-month Follow-up Of Suspected Asymptomatic Endometrioma Pre-menopausal" is null,
    { "If Unknown"('workup.followUpScan'), "If Unknown"('symptom.endometriomaSuspected'), "If Unknown"('symptom.ovarianCystSymptomatic'),
      "If Unknown"('patient.postmenopausal'), "If Unknown"('workup.followUpIntervalMonths') })

/*
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Any Advice Gateway Met":
  "Bool"('advice.acuteImagingRecommended') is true or "Bool"('advice.urgentImagingRecommended') is true
    or "Bool"('advice.nonUrgentImagingRecommended') is true or "Bool"('advice.deferrableImagingRecommended') is true

define "Missing Advice Indicators":
  if "Any Advice Gateway Met" and not "Is Answered"('advice.adviserNameRole')
    then { 'advice.adviserNameRole' } else {} as List<String>

define "Missing Information":
  case "Determination"
    when 'NOT_ROUTINELY_FUNDED' then "Missing Advice Indicators"
    when 'ALTERNATIVE_MANAGEMENT' then "Missing Advice Indicators"
    when 'PAEDIATRIC_CRITERIA_APPLY' then "Missing Advice Indicators"
    when 'ACUTE_24H' then "Missing Advice Indicators"
    when 'ACUTE_48H' then "Missing Acute 24" union "Missing Advice Indicators"
    when 'P2_URGENT' then "Missing Acute 24" union "Missing Acute 48" union "Missing Advice Indicators"
    when 'P3_NON_DEFERRABLE' then "Missing Acute 24" union "Missing Acute 48" union "Missing P2" union "Missing Advice Indicators"
    when 'P4_DEFERRABLE' then "Missing Acute 24" union "Missing Acute 48" union "Missing P2" union "Missing P3" union "Missing Advice Indicators"
    when 'S2_TIME_SENSITIVE' then "Missing Acute 24" union "Missing Acute 48" union "Missing P2" union "Missing P3" union "Missing P4" union "Missing Advice Indicators"
    when 'S3_TIME_SENSITIVE' then "Missing Acute 24" union "Missing Acute 48" union "Missing P2" union "Missing P3" union "Missing P4" union "Missing S2" union "Missing Advice Indicators"
    else "Missing Age" union "Missing Acute 24" union "Missing Acute 48" union "Missing P2" union "Missing P3"
      union "Missing P4" union "Missing S2" union "Missing S3" union "Missing Advice Indicators"
  end

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age', 'patient.postmenopausal', 'patient.perimenopausal', 'patient.mhtContinuousCombined',
    'patient.mhtCyclicalCombined', 'patient.mhtMonthsSinceStart', 'patient.maoriOrPacificEthnicity', 'patient.bmi',
    'patient.pcosDiagnosed', 'patient.chronicAnovulation', 'patient.nulliparous', 'patient.earlyMenarcheOrLateMenopause',
    'patient.estrogenSecretingTumour', 'patient.unopposedEstrogenMhtLongStanding', 'patient.tamoxifenTherapy',
    'patient.diabetes', 'patient.familyHistoryEndometrialOvarianBreastBowelCancer',
    'lab.ironDeficiencyAnaemia', 'lab.urineHcg.value', 'lab.serumBhcg.remainsHigh', 'lab.ca125.value',
    'lab.cytology.atypicalEndometrialCells', 'lab.cytology.benignEndometrialCells', 'lab.androgens.significantlyRaised',
    'symptom.acutelyUnwellSuspectedGynaeCause', 'symptom.iudStringsNotVisible', 'symptom.iudFragmentRetained',
    'symptom.iudPerforationSymptoms', 'symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage',
    'symptom.pelvicMassPalpable', 'symptom.pelvicMassSuspiciousOfCancer', 'symptom.postmenopausalBleeding',
    'symptom.vaginalBleedingPersistent', 'symptom.ovarianCancerSymptomsPersistent', 'symptom.ovarianCancerSymptomsWeeks',
    'symptom.abnormalUterineBleeding', 'symptom.irregularBleedingOngoing', 'symptom.bleedingOutsideProgestogenWithdrawal',
    'symptom.gynaeSymptomatic', 'symptom.examinationAbnormality', 'symptom.ovarianCystSuspected', 'symptom.pelvicPainWeeks',
    'symptom.pelvicPainUnilateral', 'symptom.pelvicTendernessUnilateral', 'symptom.pelvicPainUnrelatedToMenstrualCycle',
    'symptom.pid', 'symptom.primaryAmenorrhoea', 'symptom.secondaryDysmenorrhoeaNewOnset',
    'symptom.dysmenorrhoeaDebilitatingPainPersists', 'symptom.primaryDysmenorrhoea', 'symptom.pcosSuspected',
    'symptom.hyperandrogenism', 'symptom.polycysticOvaries', 'symptom.irregularMenses', 'symptom.knownFibroidSizeCm',
    'symptom.fibroidSymptomaticAfterStartingMht', 'symptom.ovarianCystORads2', 'symptom.ovarianCystSimple',
    'symptom.ovarianCystSizeCm', 'symptom.ovarianCystSymptomatic', 'symptom.haemorrhagicCyst',
    'symptom.haemorrhagicCystTypicalAppearing', 'symptom.dermoidCystSuspected', 'symptom.endometriomaSuspected',
    'symptom.endometrialPolypIncidental', 'symptom.rpocSuspected', 'symptom.bleedingPersistentOrHeavyPostAbortionOrMiscarriage',
    'symptom.endometriosisSuspected', 'symptom.cervicalPolyp', 'symptom.secondaryAmenorrhoea',
    'symptom.erraticUnscheduledBleedingOnMht',
    'workup.nonUterineBleedingCausesExcluded', 'workup.aubFirstLineTreatmentTrialled', 'workup.aubFirstLineTreatmentMonths',
    'workup.aubFirstLineTreatmentResponded', 'workup.increasedProgestogenTrialled', 'workup.recentlyInvestigated',
    'workup.dysmenorrhoeaMedicalManagementMonths', 'workup.followUpScan', 'workup.followUpIntervalMonths',
    'imaging.any.sinceSymptomOnset',
    'advice.acuteImagingRecommended', 'advice.urgentImagingRecommended', 'advice.nonUrgentImagingRecommended',
    'advice.deferrableImagingRecommended', 'advice.adviserNameRole',
    'funding.routineFibroidFollowUp', 'funding.subfertility', 'funding.ovarianCancerFamilyHistoryScreening'
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
    acute24Row1: "Acute 24h Row 1: Acutely Unwell From Suspected Gynaecological Cause",
    acute24Row2: "Acute 24h Row 2: IUD Problem With Possible Perforation Symptoms",
    acute48Row1: "Acute 48h Row 1: Suspected Ongoing Pregnancy With Raised HCG",
    acute48Row2: "Acute 48h Row 2: Advice For Same Or Next Day Ultrasound",
    p2Row1: "P2 Row 1: Pelvic Mass Suspicious Of Cancer",
    p2Row2: "P2 Row 2: Postmenopausal Bleeding",
    p2Row3: "P2 Row 3: Persistent Bleeding On Continuous Combined MHT",
    p2Row4: "P2 Row 4: Ovarian Cancer Symptoms With Ca-125 35 Or Greater",
    p2Row5: "P2 Row 5: AUB With Non-uterine Causes Excluded And Risk Factors Or Mass",
    p2Row6: "P2 Row 6: Atypical Endometrial Cells On Cytology",
    p2Row7: "P2 Row 7: Advice For Urgent US Pelvis",
    p3Row1: "P3 Row 1: AUB Aged 45 Or Older With Non-uterine Causes Excluded",
    p3Row2: "P3 Row 2: AUB Under 45 With A Risk Factor",
    p3Row3: "P3 Row 3: AUB Under 45 Not Responding To First-line Treatment",
    p3Row4: "P3 Row 4: Perimenopausal Bleeding On Cyclical MHT Despite Increased Progestogen",
    p3Row5: "P3 Row 5: Benign Endometrial Cells With Qualifying Feature",
    p3Row6: "P3 Row 6: Ovarian Cancer Symptoms More Than 6 Weeks Not Recently Investigated",
    p3Row7: "P3 Row 7: Suspected Ovarian Cyst With Pain Or Low-suspicion Mass",
    p3Row8: "P3 Row 8: Pelvic Pain More Than 6 Weeks With PID Excluded",
    p3Row9: "P3 Row 9: Primary Amenorrhoea",
    p3Row10: "P3 Row 10: IUD Problem Asymptomatic",
    p3Row11: "P3 Row 11: Secondary Dysmenorrhoea Despite Three Months Medical Management",
    p3Row12: "P3 Row 12: Advice For Routine Ultrasound Pelvis",
    p4Row1: "P4 Row 1: Suspected PCOS With Only One Rotterdam Criterion",
    p4Row2: "P4 Row 2: Known Fibroid Over 5cm Symptomatic After Starting MHT",
    p4Row3: "P4 Row 3: Advice For Deferrable Ultrasound Pelvis",
    s2Row1: "S2 Row 1: 6-month Follow-up Of O-RADS 2 Cyst",
    s2Row2: "S2 Row 2: Follow-up Of Haemorrhagic Cyst Pre-menopausal",
    s2Row3: "S2 Row 3: Follow-up Of Incidental Endometrial Polyp Without Risk Factors",
    s3Row1: "S3 Row 1: 12-month Follow-up Of O-RADS 2 Cyst",
    s3Row2: "S3 Row 2: 12-month Follow-up Of Suspected Dermoid Pre-menopausal",
    s3Row3: "S3 Row 3: 12-month Follow-up Of Suspected Asymptomatic Endometrioma Pre-menopausal",
    riskFactorCount: "Risk Factor Count",
    unknownRiskFactorCount: "Unknown Risk Factor Count",
    meetsAcute24: "Meets Acute 24h Criteria",
    meetsAcute48: "Meets Acute 48h Criteria",
    meetsP2: "Meets P2 Criteria",
    meetsP3: "Meets P3 Criteria",
    meetsP4: "Meets P4 Criteria",
    meetsS2: "Meets S2 Criteria",
    meetsS3: "Meets S3 Criteria",
    redirectRpoc: "Redirect: RPOC With Persistent Or Heavy Bleeding",
    redirectEndometriosis: "Redirect: Endometriosis Without Palpable Mass",
    redirectPrimaryDysmenorrhoea: "Redirect: Primary Dysmenorrhoea Without Palpable Mass",
    redirectPid: "Redirect: PID Without Palpable Mass",
    redirectCervicalPolyps: "Redirect: Cervical Polyps",
    redirectSecondaryAmenorrhoea: "Redirect: Secondary Amenorrhoea Without Mass Or Raised Androgens",
    notFunded1: "Not Funded 1: Routine Follow-up Of Known Fibroids",
    notFunded2: "Not Funded 2: Subfertility",
    notFunded3: "Not Funded 3: Small Simple Cyst Post-menopausal",
    notFunded4: "Not Funded 4: Simple Cyst Under 5cm Premenopausal",
    notFunded5: "Not Funded 5: Non-simple Cyst Under 3cm Premenopausal",
    notFunded6: "Not Funded 6: Typical Haemorrhagic Cyst Up To 5cm Pre-menopausal",
    notFunded7: "Not Funded 7: Benign Endometrial Cells Asymptomatic Pre-menopausal No Risk Factors",
    notFunded8: "Not Funded 8: Erratic Unscheduled Bleeding Within 6 Months Of Starting MHT",
    notFunded9: "Not Funded 9: Screening For Family History Of Ovarian Cancer",
    notFunded10: "Not Funded 10: AUB Under 45 No Risk Factors First-line Not Trialled",
    alternativeManagement: "Alternative Management Recommended",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'US Pelvis - Adult',
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
