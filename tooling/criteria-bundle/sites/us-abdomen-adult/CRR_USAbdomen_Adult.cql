/*
  CRR National Community Referral Criteria for Imaging (Part I)
  US Abdomen - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    File:       documents/reference/National Primary Care Referral Criteria for Imaging.pdf
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    Section:    Adult Ultrasound > US Abdomen - Adult, pages 30-33

  STATUS
    DEMO TRANSCRIPTION - NOT CLINICALLY REVIEWED (AD-10, AD-35). Encodes the most
    literal reading of the published text; every ambiguity is a REVIEW Qn below,
    in signoff.md and in transcription-notes.md.

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the published
    wording verbatim, with page reference. A define with no SOURCE comment is
    engineering plumbing, not a clinical rule. Review is a side-by-side check of
    each SOURCE quote against the define beneath it.

  WHAT IS NOT HERE
    The "Refer for acute assessment without imaging" row (p30: acute
    cholecystitis/cholangitis, acute abdomen, ruptured AAA, testicular torsion,
    painful jaundice) is national red flags RF-05..RF-09 in CRR_RedFlags, which
    runs before this library and stops the pipeline when one fires (AD-03). It is
    not re-encoded here. The p31 Guidance box carries no logic.

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-US-Abdomen-Adult". Each answer MAY carry the evidence
    extension http://crr.health.nz/fhir/StructureDefinition/answer-evidence
    (status documented | inferred | retrieved, quote). An answer with no evidence
    extension counts as 'documented'. An unanswered indicator is NULL and
    propagates as "insufficient information" (three-valued logic). Criteria are
    never coalesced to false; redirect and not-funded indicators are read through
    "is true" (absence does not assert presence).

  CLINICAL REVIEW FLAGS (answer each in signoff.md)
    Q1  "Painless" jaundice = redflag.painfulJaundice answered false (composition, no new indicator)
    Q2  "without obvious cause" = new indicator workup.jaundiceObviousCause; unknown -> insufficient
    Q3  "consider discussing ... as a CT scan may be more appropriate" is advice, not a condition
    Q4  P2 "Initial presentation" is not a separate condition; ALP/GGT indicators are the initial results;
        if GGT has normalised at a 3-month repeat, the ALP/normal-GGT redirect fires and outranks P2 (Q13)
    Q5  P2 "raised ALP and GGT" = both raised; "+/- bilirubin" not encoded
    Q6  P3 "without previous imaging" (modality unstated) = imaging.presentingProblem.ever false
    Q7  P3 "without previous imaging which showed gallstones" = no previous imaging has shown gallstones
    Q8  P3 follow-up ALP/GGT: unprinted sub-bullet connectors read as AND (all four parts)
    Q9  P3 ALT: both sub-bullets required; "in patients with high risk factors" is a condition
    Q10 P3 ALT "greater than 120 IU/L": strictly greater; a number is required; the unit is not checked (KI-77)
    Q11 P3 isolated GGT: "persists" = repeat GGT still more than 5 x ULN; "isolated" shared with bilirubin;
        exactly 5.0 x ULN (initial or repeat) does not meet "more than 5 times"
    Q12 Initial GGT < 5 x ULN, repeat > 5 x ULN: the alternative-management item fires, not P3;
        an initial GGT of exactly 5.0 x ULN meets neither this item ("less than 5") nor P3
    Q13 "ALP elevated with normal GGT" uses the latest GGT (the repeat once repeated); it can therefore
        redirect a patient whose initial results met P2 bullet 1 (Q4)
    Q14 P3 AAA: "asymptomatic" and "newly suspected" are two indicators; "e.g." clause not encoded
    Q15 P3 mass: "non-pulsatile abdominal mass and suspected enlarged liver" = both required
    Q16 S3 rows: one indicator per bullet; heading printed verbatim (renderer strips the leading code);
        the "*Hepatitis Foundation Clinician" Referrers entry is a note, not enforced; S3 ranks below P3 (Q17)
    Q17 Order of timeframe rows: acute 48 h > P2 > P3 > S3; the most urgent row met is returned even
        when a more urgent row is undetermined
    Q18 Not-funded items read as the reason for the request; bloating composes two indicators
    Q19 Weight loss/fatigue/pain/suspicion redirect: all four required; "suspicion" != "strong suspicion";
        p32 "Unexplained weight loss" is read through weightloss.present ("Unintentional, unexplained")
    Q20 Bloating "associated clinical symptoms (for example ...)" = clinical features of concern
    Q21 "Urinary tract presentations and suspected renal abnormality" is one indicator, wording verbatim
    Q22 "Adult" = age over 15 (Overview p4), as CT CAP
    Q23 Chronic pancreatitis ("request acute general surgery assessment") is a redirect, not a red flag
    Q24 Upper abdominal mass redirect needs "upper" and "not consistent with hepatomegaly" both answered
    Q25 Not-funded precedence (coordinator rule R1): redirect > paediatric > most urgent met timeframe
        row > insufficient information (any row undetermined) > not funded (every row not met) >
        criteria not met. Alternative reading: not funded first, as CT CAP does for its patient-level
        "unfit for treatment" row
*/

library CRR_USAbdomen_Adult version '1.0.0'

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

define function "Qty"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToQuantity("Answer"(linkId).value as FHIR.Quantity).value else null

// ---------------------------------------------------------------------------
// Demographics
// ---------------------------------------------------------------------------

define "Age In Years":
  Coalesce("Int"('patient.age'), AgeInYears())

/*
  SOURCE (Overview, p4, Scope item 5): "The age band covered by the paediatric
  criteria has been specified as up to and including 15 years of age"
  REVIEW Q22 - the section is headed "US Abdomen - Adult" and prints no age
  band; adult is read as age over 15, as for CT CAP.
*/
define "Is Adult": "Age In Years" > 15

// ---------------------------------------------------------------------------
// Shared lab components (liver blood tests)
// ---------------------------------------------------------------------------

/*
  SOURCE (p30, P2 bullet 1): "ALP more than 2 times the upper limit of normal (ULN)"
  SOURCE (p31, P3 bullet 3): "ALP was more than 2 times the ULN at the initial presentation"
  REVIEW Q4 - lab.alp.timesULN is read as the ALP multiple at the initial
  presentation in both places. "more than" = strictly greater.
*/
define "Initial ALP More Than 2x ULN": "Dec"('lab.alp.timesULN') > 2.0

/*
  SOURCE (p30, P2 bullet 2): "raised ALP"
  SOURCE (p33, Alternative management): "ALP elevated"
  A stated multiple above 1 is the same fact as "raised"; the flag wins when both are given.
*/
define "ALP Raised":
  Coalesce("Bool"('lab.alp.high'), "Dec"('lab.alp.timesULN') > 1.0)

/*
  SOURCE (p30, P2 bullet 1): "GGT higher than the ULN"
  SOURCE (p30, P2 bullet 2): "raised ALP and GGT"
  A stated multiple above 1 is the same fact as "higher than the ULN"; the flag wins when both are given.
*/
define "GGT Higher Than ULN":
  Coalesce("Bool"('lab.ggt.raised'), "Dec"('lab.ggt.timesULN') > 1.0)

/*
  SOURCE (p31, P3 bullet 3): "Follow up imaging on repeat testing 3 months or more
   after the initial presentation"
  SOURCE (p32, P3 bullet 5): "persists on re-testing after 3 months"
*/
define "Repeat Testing At 3 Months Or More": "Bool"('lab.repeatAfter3Months')

/*
  SOURCE (p31, P3 bullet 3): "Repeat GGT remains higher than the ULN"
*/
define "Repeat GGT Higher Than ULN":
  Coalesce("Bool"('lab.ggt.repeatRaised'), "Dec"('lab.ggt.repeatTimesULN') > 1.0)

/*
  SOURCE (p32, P3 bullet 5): "Isolated raised GGT"
  SOURCE (p33, Alternative management): "Isolated raised bilirubin"
  REVIEW Q11 - "isolated" is one indicator (the raised result is the only
  abnormal liver blood test), shared by the GGT and bilirubin items.
*/
define "LFT Abnormality Isolated": "Bool"('lab.isolatedLftAbnormality')

// ---------------------------------------------------------------------------
// Acute: Within 48 hours
// ---------------------------------------------------------------------------

/*
  SOURCE (p30, Acute: Within 48 hours, bullet 1):
  "Painless jaundice without obvious cause - consider discussing with secondary
   care specialist or Primary Care Radiology Liaison as a CT scan may be more
   appropriate."

  REVIEW Q1 - "painless" is read from the national indicator
  redflag.painfulJaundice answered false (extraction contract rule 6: negation
  is documented, e.g. "painless jaundice"). No new indicator. Painful jaundice
  answered true is a national red flag and never reaches this library in the
  pipeline.
  REVIEW Q2 - "without obvious cause" is its own indicator
  (workup.jaundiceObviousCause, true = an obvious cause is apparent). Unknown
  is not assumed absent: the criterion is undetermined and the referrer is
  asked. Candidate attestation indicator (AD-17).
  REVIEW Q3 - "consider discussing ... as a CT scan may be more appropriate" is
  advice to the referrer, not a condition; the criterion is met without a
  documented discussion.
*/
define "Jaundice Present": "Bool"('symptom.jaundice')
define "Jaundice Painless": not "Bool"('redflag.painfulJaundice')
define "Obvious Cause For Jaundice": "Bool"('workup.jaundiceObviousCause')

define "Acute 48h: Painless Jaundice Without Obvious Cause":
  "Jaundice Present" and "Jaundice Painless" and not "Obvious Cause For Jaundice"

/*
  SOURCE (p30, Acute: Within 48 hours, bullet 2):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or
   radiologist advises referral for same or next day ultrasound scan."
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Acute 48h: Specialist Advises Same Or Next Day Ultrasound":
  "Bool"('advice.acuteImagingRecommended')

/*
  SOURCE (p30, Timeframe column): "Acute: Within 48 hours"
  SOURCE (Overview p5): "acute (within 24 – 48 hours)"
*/
define "Meets Acute 48h Criteria":
  "Is Adult"
    and (
      "Acute 48h: Painless Jaundice Without Obvious Cause"
        or "Acute 48h: Specialist Advises Same Or Next Day Ultrasound"
    )

// ---------------------------------------------------------------------------
// P2 Urgent
// ---------------------------------------------------------------------------

/*
  SOURCE (p30, P2 Urgent, bullet 1):
  "Initial presentation with ALP more than 2 times the upper limit of normal
   (ULN) and GGT higher than the ULN"

  REVIEW Q4 - "Initial presentation" is not encoded as a separate condition.
  It is read as when the results were found; the follow-up case (repeat
  testing at 3 months) is P3 bullet 3 with its own repeat-result indicators.
  A patient whose initial results met this bullet still meets it at follow-up,
  unless the GGT has returned to normal at a repeat 3 months or more later: the
  "ALP elevated with normal GGT" redirect then fires (REVIEW Q13) and, being a
  redirect, outranks P2 (scenario USAB-S41).
*/
define "P2: Initial ALP More Than 2x ULN And GGT Raised":
  "Initial ALP More Than 2x ULN" and "GGT Higher Than ULN"

/*
  SOURCE (p30, P2 Urgent, bullet 2):
  "Suspected acute cholecystitis / biliary colic with raised ALP and GGT +/-
   bilirubin and where symptoms settle with analgesia and biliary tree has not
   previously been imaged."

  REVIEW Q5 - "raised ALP and GGT" = ALP raised AND GGT raised. "+/- bilirubin"
  is modifier wording (KI-05) and is not encoded. "Suspected acute
  cholecystitis / biliary colic" is one indicator, shared with P3 bullet 2.
*/
define "Suspected Biliary Colic Or Cholecystitis": "Bool"('symptom.biliaryColicOrCholecystitis')
define "Symptoms Settle With Analgesia": "Bool"('symptom.settlesWithAnalgesia')
define "Biliary Tree Previously Imaged": "Bool"('imaging.biliaryTree.ever')

define "P2: Settled Biliary Colic With Raised ALP And GGT, Biliary Tree Not Imaged":
  "Suspected Biliary Colic Or Cholecystitis"
    and "ALP Raised"
    and "GGT Higher Than ULN"
    and "Symptoms Settle With Analgesia"
    and not "Biliary Tree Previously Imaged"

/*
  SOURCE (p30, P2 Urgent, bullet 3):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or
   radiologist advises referral for urgent ultrasound scan."
*/
define "P2: Specialist Advises Urgent Ultrasound":
  "Bool"('advice.urgentImagingRecommended')

/*
  SOURCE (p30, Timeframe column): "P2 Urgent: non-deferrable imaging or
   intervention that must be completed within 2 weeks of receiving referral"
*/
define "Meets P2 Criteria":
  "Is Adult"
    and (
      "P2: Initial ALP More Than 2x ULN And GGT Raised"
        or "P2: Settled Biliary Colic With Raised ALP And GGT, Biliary Tree Not Imaged"
        or "P2: Specialist Advises Urgent Ultrasound"
    )

// ---------------------------------------------------------------------------
// P3
// ---------------------------------------------------------------------------

/*
  SOURCE (p31, P3, bullet 1):
  "Recurrent right upper quadrant / epigastric, non-dyspepsia pain without
   previous imaging"

  REVIEW Q6 - "non-dyspepsia" = symptom.dyspepsia answered false (the same
  indicator drives the "Dyspepsia" redirect, p33). "without previous imaging"
  names no modality or region: read as the presenting problem has not
  previously been imaged (imaging.presentingProblem.ever false).
*/
define "Recurrent RUQ Or Epigastric Pain": "Bool"('symptom.recurrentRUQOrEpigastricPain')
define "Dyspepsia": "Bool"('symptom.dyspepsia')
define "Presenting Problem Previously Imaged": "Bool"('imaging.presentingProblem.ever')

define "P3: Recurrent RUQ Or Epigastric Non-Dyspepsia Pain Without Previous Imaging":
  "Recurrent RUQ Or Epigastric Pain"
    and not "Dyspepsia"
    and not "Presenting Problem Previously Imaged"

/*
  SOURCE (p31, P3, bullet 2):
  "Suspected resolved acute biliary colic or cholecystitis, without previous
   imaging which showed gallstones and the patient is a potential candidate for
   and would accept a cholecystectomy"

  REVIEW Q7 - "without previous imaging which showed gallstones" is read as: no
  previous imaging has shown gallstones (imaging.gallstones.ever false).
  "potential candidate for and would accept a cholecystectomy" is one indicator.
*/
define "Biliary Colic Or Cholecystitis Resolved": "Bool"('symptom.biliaryColicResolved')
define "Previous Imaging Showed Gallstones": "Bool"('imaging.gallstones.ever')
define "Cholecystectomy Candidate Who Would Accept": "Bool"('workup.cholecystectomyCandidate')

define "P3: Resolved Biliary Colic, No Gallstones On Previous Imaging, Cholecystectomy Candidate":
  "Suspected Biliary Colic Or Cholecystitis"
    and "Biliary Colic Or Cholecystitis Resolved"
    and not "Previous Imaging Showed Gallstones"
    and "Cholecystectomy Candidate Who Would Accept"

/*
  SOURCE (p31, P3, bullet 3):
  "Follow up imaging on repeat testing 3 months or more after the initial
   presentation and:
     o ALP was more than 2 times the ULN at the initial presentation AND on
       repeat testing 3 months later the :
         ▪ Repeat ALP remains higher than the ULN
         ▪ Repeat GGT remains higher than the ULN"

  REVIEW Q8 - the sub-bullets carry no printed connector; read as all required:
  repeat testing at 3 months or more AND initial ALP > 2 x ULN AND repeat ALP >
  ULN AND repeat GGT > ULN.
*/
define "Repeat ALP Higher Than ULN": "Bool"('lab.alp.repeatHigh')

define "P3: Follow-Up ALP And GGT Still Raised At 3 Months":
  "Repeat Testing At 3 Months Or More"
    and "Initial ALP More Than 2x ULN"
    and "Repeat ALP Higher Than ULN"
    and "Repeat GGT Higher Than ULN"

/*
  SOURCE (p31-32, P3, bullet 4):
  "ALT greater than 120 IU/L AND
     o Conservative methods (e.g. weight loss and lifestyle alterations or
       medication change) unsuccessful in patients with high risk factors
       (diabetes, obesity, medications that affect the liver, e.g. statins)
     o No clinical features of concern"

  REVIEW Q9 - both sub-bullets are required (the printed "AND" precedes them).
  "in patients with high risk factors" is read as a condition: the patient has
  at least one of diabetes, obesity or medications that affect the liver (one
  indicator, patient.liverRiskFactors). The "e.g." lists are illustrative
  (KI-05) and not encoded.
  REVIEW Q10 - "greater than 120 IU/L" is strictly greater and needs the value;
  a qualitative "ALT raised" does not satisfy it. "Qty" returns only the
  number, so the unit is not checked: a value reported in another unit would be
  compared as if in IU/L. Depends on how the gate handles quantity units (KI-77).
  "No clinical features of concern": workup.clinicalFeaturesOfConcern answered
  false. Candidate attestation indicator (AD-17).
*/
define "ALT Greater Than 120 IU/L": "Qty"('lab.alt.value') > 120.0
define "Has High Risk Factors": "Bool"('patient.liverRiskFactors')
define "Conservative Methods Unsuccessful": "Bool"('workup.conservativeMethodsUnsuccessful')
define "Clinical Features Of Concern": "Bool"('workup.clinicalFeaturesOfConcern')

define "P3: ALT Over 120 With Risk Factors, Conservative Methods Unsuccessful, No Features Of Concern":
  "ALT Greater Than 120 IU/L"
    and "Has High Risk Factors"
    and "Conservative Methods Unsuccessful"
    and not "Clinical Features Of Concern"

/*
  SOURCE (p32, P3, bullet 5):
  "Isolated raised GGT more than 5 times the ULN and persists on re-testing
   after 3 months."

  REVIEW Q11 - read as: isolated AND initial GGT > 5 x ULN AND repeat testing at
  3 months or more AND repeat GGT still > 5 x ULN ("persists" refers to the
  "raised GGT more than 5 times the ULN"). Exactly 5.0 x ULN, initially or on
  repeat, is not "more than 5 times" (scenarios USAB-S43, USAB-S44).
*/
define "P3: Isolated GGT More Than 5x ULN Persisting At 3 Months":
  "LFT Abnormality Isolated"
    and "Dec"('lab.ggt.timesULN') > 5.0
    and "Repeat Testing At 3 Months Or More"
    and "Dec"('lab.ggt.repeatTimesULN') > 5.0

/*
  SOURCE (p32, P3, bullet 6):
  "Asymptomatic, newly suspected abdominal aortic aneurysm e.g. on clinical
   examination or other imaging."

  REVIEW Q14 - two indicators; "e.g. on clinical examination or other imaging"
  is illustrative (KI-05) and not encoded.
*/
define "AAA Newly Suspected": "Bool"('symptom.aaaNewlySuspected')
define "AAA Asymptomatic": "Bool"('symptom.aaaAsymptomatic')

define "P3: Asymptomatic Newly Suspected AAA":
  "AAA Newly Suspected" and "AAA Asymptomatic"

/*
  SOURCE (p32, P3, bullet 7):
  "Non-pulsatile abdominal mass and suspected enlarged liver on examination."

  REVIEW Q15 - read as two conditions, both required. Whether a palpable liver
  edge alone answers "non-pulsatile abdominal mass" (matrix RP-002) is for the
  reviewer; the indicators are answered separately.
*/
define "Non-Pulsatile Abdominal Mass": "Bool"('symptom.abdominalMassNonPulsatile')
define "Suspected Enlarged Liver": "Bool"('symptom.hepatomegalySuspected')

define "P3: Non-Pulsatile Abdominal Mass And Suspected Enlarged Liver":
  "Non-Pulsatile Abdominal Mass" and "Suspected Enlarged Liver"

/*
  SOURCE (p32, P3, bullet 8):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or
   radiologist advises referral for non-urgent ultrasound scan."
*/
define "P3: Specialist Advises Non-Urgent Ultrasound":
  "Bool"('advice.nonUrgentImagingRecommended')

/*
  SOURCE (p31, Timeframe column): "P3 non-deferrable imaging or intervention
   that must be completed within 6 weeks of receiving referral."
*/
define "Meets P3 Criteria":
  "Is Adult"
    and (
      "P3: Recurrent RUQ Or Epigastric Non-Dyspepsia Pain Without Previous Imaging"
        or "P3: Resolved Biliary Colic, No Gallstones On Previous Imaging, Cholecystectomy Candidate"
        or "P3: Follow-Up ALP And GGT Still Raised At 3 Months"
        or "P3: ALT Over 120 With Risk Factors, Conservative Methods Unsuccessful, No Features Of Concern"
        or "P3: Isolated GGT More Than 5x ULN Persisting At 3 Months"
        or "P3: Asymptomatic Newly Suspected AAA"
        or "P3: Non-Pulsatile Abdominal Mass And Suspected Enlarged Liver"
        or "P3: Specialist Advises Non-Urgent Ultrasound"
    )

// ---------------------------------------------------------------------------
// S3 (specified date)
// ---------------------------------------------------------------------------

/*
  SOURCE (p32, S3, bullet 1):
  "HCC surveillance using liver ultrasound as initially recommended by a
   gastroenterologist or other secondary care specialist, as part of long-term
   monitoring by Hepatitis Foundation of NZ, or as recommended by an agreed
   local pathway.*"
  REVIEW Q16 - one indicator for the bullet (any of the three sources of the
  recommendation).
*/
define "S3: HCC Surveillance As Recommended":
  "Bool"('advice.hccSurveillance')

/*
  SOURCE (p32, S3, bullet 2):
  "Surveillance of known abdominal aortic aneurysm according to local
   HealthPathway, or if none available according to the according to New
   Zealand Vascular Society guidelines (2015) *1 or secondary care specialist
   advice"
*/
define "S3: Surveillance Of Known AAA":
  "Bool"('advice.aaaSurveillance')

/*
  SOURCE (p32, S3, bullet 3):
  "Follow up of incidental finding on imaging (including gallbladder polyps)
   according to the Incidental Findings on Imaging HealthPathway, or if
   unavailable according to the radiology report advice from the Primary Care
   Radiology Liaison"
*/
define "S3: Incidental Finding Follow Up":
  "Bool"('advice.incidentalFindingFollowUp')

/*
  SOURCE (p32, Timeframe column): "S3 non-deferrable time sensitive imaging or
   intervention that must be completed within 6 weeks of a specified target
   date."
*/
define "Meets S3 Criteria":
  "Is Adult"
    and (
      "S3: HCC Surveillance As Recommended"
        or "S3: Surveillance Of Known AAA"
        or "S3: Incidental Finding Follow Up"
    )

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (redirects)
// ---------------------------------------------------------------------------

/*
  SOURCE (p32, Alternative management, bullet 1):
  "Upper abdominal non-pulsatile mass, not consistent with hepatomegaly – discuss
   with Primary Care Radiology Liaison or relevant secondary care specialist as
   referral for CT abdomen may be more appropriate."
  REVIEW Q24 - fires only when the mass, its upper-abdominal site and the
  absence of hepatomegaly (symptom.hepatomegalySuspected false) are all answered.
*/
define "Redirect: Upper Abdominal Mass Not Hepatomegaly":
  "Non-Pulsatile Abdominal Mass" is true
    and "Bool"('symptom.abdominalMassUpper') is true
    and "Suspected Enlarged Liver" is false

/*
  SOURCE (p32, Alternative management, bullet 2):
  "Unexplained weight loss, persistent fatigue, vague abdominal pain and
   suspicion of underlying malignancy – See local CT Chest, Abdomen and Pelvis
   HealthPathway."
  REVIEW Q19 - all four required ("and"). "persistent" and "vague" are not
  captured separately (symptom.fatigue, symptom.abdominalPain). "suspicion" is
  not CT CAP's "strong suspicion": new indicator workup.suspicionMalignancy.
  "Unexplained weight loss" is read through weightloss.present, whose text is
  "Unintentional, unexplained weight loss" (adds "unintentional").
*/
define "Redirect: Weight Loss, Fatigue, Abdominal Pain And Suspected Malignancy":
  ("Bool"('weightloss.present')
    and "Bool"('symptom.fatigue')
    and "Bool"('symptom.abdominalPain')
    and "Bool"('workup.suspicionMalignancy')) is true

/*
  SOURCE (p32, Alternative management, bullet 3):
  "Isolated raised GGT less than 5 times the ULN - Re-test after three months
   with interim alcohol abstinence. Consider ultrasound if GGT is higher than 5
   times the ULN on re-testing."
  REVIEW Q12 - evaluated on the initial GGT multiple. A repeat GGT above 5 x
  ULN does not switch this off (the item's own wording then advises
  considering ultrasound), and P3 bullet 5 is not met because the initial GGT
  was not above 5 x ULN. An initial GGT of exactly 5.0 x ULN is neither "less
  than 5 times" (this item) nor "more than 5 times" (P3 bullet 5): neither fires
  (scenario USAB-S43).
*/
define "Redirect: Isolated GGT Less Than 5x ULN":
  ("LFT Abnormality Isolated"
    and "GGT Higher Than ULN"
    and "Dec"('lab.ggt.timesULN') < 5.0) is true

/*
  SOURCE (p33, Alternative management, bullet 4):
  "ALP elevated with normal GGT - suggests ALP increase is probably not
   liver-related. If ALT or bilirubin elevated as well, or the patient is
   symptomatic consider ALP iso-enzyme testing to confirm liver origin."
  REVIEW Q13 - "normal GGT" is the latest GGT: the repeat result once liver
  tests have been repeated at 3 months or more, otherwise the initial result.
  Without this, P3 bullet 3 (initial ALP > 2 x ULN with GGT rising by the
  repeat) could never be reached. Consequence: a patient whose initial ALP was
  > 2 x ULN with raised GGT (P2 bullet 1) but whose GGT is normal at the
  3-month repeat is redirected here, and the redirect outranks P2 (REVIEW Q4,
  scenario USAB-S41).
*/
define "GGT Normal At Latest Test":
  if "Repeat Testing At 3 Months Or More" is true then not "Repeat GGT Higher Than ULN"
  else not "GGT Higher Than ULN"

define "Redirect: ALP Elevated With Normal GGT":
  ("ALP Raised" and "GGT Normal At Latest Test") is true

/*
  SOURCE (p33, Alternative management, bullet 5):
  "Raised ferritin – See local Raised Ferritin or Hereditary Haemochromatosis
   HealthPathways"
*/
define "Redirect: Raised Ferritin":
  "Bool"('lab.ferritin.raised') is true

/*
  SOURCE (p33, Alternative management, bullet 6):
  "Isolated raised bilirubin – Gilberts syndrome with unconjugated
   hyperbilirubinemia is the most common cause – See local Abnormal Liver
   Function Tests HealthPathway."
*/
define "Redirect: Isolated Raised Bilirubin":
  ("Bool"('lab.bilirubin.raised') and "LFT Abnormality Isolated") is true

/*
  SOURCE (p33, Alternative management, bullet 7): "Dyspepsia – See local HealthPathway"
*/
define "Redirect: Dyspepsia":
  "Dyspepsia" is true

/*
  SOURCE (p33, Alternative management, bullet 8):
  "Suspected colorectal neoplasm. If colicky vague abdominal pain, with or
   without distension, and change in bowel habit, consider colorectal cancer -
   See local Colorectal Symptoms HealthPathway."
  The second sentence is advice to the referrer, not a condition.
*/
define "Redirect: Suspected Colorectal Neoplasm":
  "Bool"('symptom.colorectalNeoplasmSuspected') is true

/*
  SOURCE (p33, Alternative management, bullet 9):
  "New unilateral lymphoedema - discussion with secondary care recommended as
   referral for CT is usually preferable"
*/
define "Redirect: New Unilateral Lymphoedema":
  "Bool"('symptom.unilateralLymphoedemaNew') is true

/*
  SOURCE (p33, Alternative management, bullet 10):
  "Suspected or symptomatic chronic pancreatitis – request acute general surgery
   assessment."
  REVIEW Q23 - printed in the alternative-management row, so encoded as a
  redirect here, not as a national red flag.
*/
define "Redirect: Chronic Pancreatitis":
  "Bool"('symptom.chronicPancreatitis') is true

/*
  SOURCE (p33, Alternative management, bullet 11):
  "Urinary tract presentations and suspected renal abnormality - See local
   Ultrasound Renal HealthPathway"
  REVIEW Q21 - one indicator carrying the published wording.
*/
define "Redirect: Urinary Tract Or Renal Presentation":
  "Bool"('symptom.urinaryTractPresentation') is true

/*
  SOURCE (p33, Alternative management, bullet 12):
  "Isolated bloating with associated clinical symptoms (for example decreased
   appetite, weight loss, abdominal pain, abnormal vaginal bleeding), seek
   advice from the appropriate specialist as a CT or US may be indicated."
  REVIEW Q20 - "associated clinical symptoms" is read as clinical features of
  concern (workup.clinicalFeaturesOfConcern true); the "for example" list is
  illustrative (KI-05).
*/
define "Isolated Bloating": "Bool"('symptom.isolatedBloating')

define "Redirect: Isolated Bloating With Associated Symptoms":
  ("Isolated Bloating" and "Clinical Features Of Concern") is true

define "Active Redirects":
  (List<String>{
    if "Redirect: Upper Abdominal Mass Not Hepatomegaly" then 'Upper abdominal non-pulsatile mass, not consistent with hepatomegaly – discuss with Primary Care Radiology Liaison or relevant secondary care specialist as referral for CT abdomen may be more appropriate.' else null,
    if "Redirect: Weight Loss, Fatigue, Abdominal Pain And Suspected Malignancy" then 'Unexplained weight loss, persistent fatigue, vague abdominal pain and suspicion of underlying malignancy – See local CT Chest, Abdomen and Pelvis HealthPathway.' else null,
    if "Redirect: Isolated GGT Less Than 5x ULN" then 'Isolated raised GGT less than 5 times the ULN - Re-test after three months with interim alcohol abstinence. Consider ultrasound if GGT is higher than 5 times the ULN on re-testing.' else null,
    if "Redirect: ALP Elevated With Normal GGT" then 'ALP elevated with normal GGT - suggests ALP increase is probably not liver-related. If ALT or bilirubin elevated as well, or the patient is symptomatic consider ALP iso-enzyme testing to confirm liver origin.' else null,
    if "Redirect: Raised Ferritin" then 'Raised ferritin – See local Raised Ferritin or Hereditary Haemochromatosis HealthPathways' else null,
    if "Redirect: Isolated Raised Bilirubin" then 'Isolated raised bilirubin – Gilberts syndrome with unconjugated hyperbilirubinemia is the most common cause – See local Abnormal Liver Function Tests HealthPathway.' else null,
    if "Redirect: Dyspepsia" then 'Dyspepsia – See local HealthPathway' else null,
    if "Redirect: Suspected Colorectal Neoplasm" then 'Suspected colorectal neoplasm. If colicky vague abdominal pain, with or without distension, and change in bowel habit, consider colorectal cancer - See local Colorectal Symptoms HealthPathway.' else null,
    if "Redirect: New Unilateral Lymphoedema" then 'New unilateral lymphoedema - discussion with secondary care recommended as referral for CT is usually preferable' else null,
    if "Redirect: Chronic Pancreatitis" then 'Suspected or symptomatic chronic pancreatitis – request acute general surgery assessment.' else null,
    if "Redirect: Urinary Tract Or Renal Presentation" then 'Urinary tract presentations and suspected renal abnormality - See local Ultrasound Renal HealthPathway' else null,
    if "Redirect: Isolated Bloating With Associated Symptoms" then 'Isolated bloating with associated clinical symptoms (for example decreased appetite, weight loss, abdominal pain, abnormal vaginal bleeding), seek advice from the appropriate specialist as a CT or US may be indicated.' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

/*
  US Abdomen's alternative-management items are other presentations to be
  managed elsewhere, not exclusions to be confirmed before referring (CT CAP's
  excl.* are). Nothing is reported as an unconfirmed exclusion; an unanswered
  redirect indicator does not block a priority determination.
*/
define "Unconfirmed Exclusions": {} as List<String>

// ---------------------------------------------------------------------------
// Not routinely funded
// ---------------------------------------------------------------------------

/*
  SOURCE (p33, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
   - "Hernia in adults"
   - "Infective hepatitis"
   - "Follow-up imaging of previously diagnosed gallstones in asymptomatic patients"
   - "Isolated bloating with no other features of concern"
   - "Follow up imaging of simple renal or hepatic cysts"
   - "Screening for:" "aortic aneurysm" "fatty liver"
  REVIEW Q18 - each item is read as the reason for the request (one funding.*
  indicator each, published wording as the item text), except bloating, which
  composes symptom.isolatedBloating with workup.clinicalFeaturesOfConcern
  answered false (the same two indicators drive the bloating redirect).
  Unknown is treated as not present. Not funded is returned only when every
  timeframe row is definitively not met (REVIEW Q25).
*/
define "Not Funded: Isolated Bloating With No Features Of Concern":
  ("Isolated Bloating" and not "Clinical Features Of Concern") is true

define "Not Routinely Funded":
  Coalesce("Bool"('funding.hernia'), false)
    or Coalesce("Bool"('funding.infectiveHepatitis'), false)
    or Coalesce("Bool"('funding.gallstonesFollowUpAsymptomatic'), false)
    or "Not Funded: Isolated Bloating With No Features Of Concern"
    or Coalesce("Bool"('funding.simpleCystFollowUp'), false)
    or Coalesce("Bool"('funding.screeningAorticAneurysm'), false)
    or Coalesce("Bool"('funding.screeningFattyLiver'), false)

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q17, Q25 - confirm ordering):
    1. Alternative management / redirect (BRD TA-013: redirect wins over criteria)
    2. Paediatric patient - the adult criteria do not apply (BRD TA-003)
    3. Acute: within 48 hours met
    4. P2 met
    5. P3 met
    6. S3 met
    7. Any timeframe row undetermined -> insufficient information
    8. Not routinely funded (only when every timeframe row is definitively not met)
    9. Criteria not met
  The most urgent row that is met is returned even when a more urgent row is
  undetermined (Q17). A not-funded item never pre-empts a timeframe row that is
  met or still undetermined (coordinator rule R1, Q25).
*/
define "All Timeframe Rows Not Met":
  "Meets Acute 48h Criteria" is false
    and "Meets P2 Criteria" is false
    and "Meets P3 Criteria" is false
    and "Meets S3 Criteria" is false

define "Determination":
  case
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P3 Criteria" is true then 'P3_NON_DEFERRABLE'
    when "Meets S3 Criteria" is true then 'S3_TIME_SENSITIVE'
    when not "All Timeframe Rows Not Met" then 'INSUFFICIENT_INFORMATION'
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    else 'CRITERIA_NOT_MET'
  end

/*
  AD-36 priority codes. The acute row prints no code ("Acute: Within 48
  hours"); A48 is the AD-36 code for it (triager view only).
*/
define "Priority Code":
  case "Determination"
    when 'ACUTE_48H' then 'A48'
    when 'P2_URGENT' then 'P2'
    when 'P3_NON_DEFERRABLE' then 'P3'
    when 'S3_TIME_SENSITIVE' then 'S3'
    else null
  end

/*
  SOURCE (p30): "Acute: Within 48 hours"
  SOURCE (p30): "must be completed within 2 weeks of receiving referral"
  SOURCE (p31): "must be completed within 6 weeks of receiving referral."
  SOURCE (p32): "must be completed within 6 weeks of a specified target date."
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_48H' then 'Within 48 hours'
    when 'P2_URGENT' then 'Complete within 2 weeks of receiving referral'
    when 'P3_NON_DEFERRABLE' then 'Complete within 6 weeks of receiving referral'
    when 'S3_TIME_SENSITIVE' then 'Complete within 6 weeks of a specified target date'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

/*
  Only criteria that are still undetermined contribute, and only their
  unanswered parts: a criterion already false (one part definitively not met)
  asks for nothing.
*/
define function "Non Null"(values List<String>):
  values V where V is not null

define function "Missing When Undetermined"(criterion Boolean, parts List<String>):
  if criterion is null then parts else {} as List<String>

define "Missing Pathway Indicators":
  "Non Null"(List<String>{ if "Age In Years" is null then 'patient.age' else null })
  union "Missing When Undetermined"("Acute 48h: Painless Jaundice Without Obvious Cause",
    "Non Null"(List<String>{
      if "Jaundice Present" is null then 'symptom.jaundice' else null,
      if "Jaundice Painless" is null then 'redflag.painfulJaundice' else null,
      if "Obvious Cause For Jaundice" is null then 'workup.jaundiceObviousCause' else null
    }))
  union "Missing When Undetermined"("Acute 48h: Specialist Advises Same Or Next Day Ultrasound", { 'advice.acuteImagingRecommended' })
  union "Missing When Undetermined"("P2: Initial ALP More Than 2x ULN And GGT Raised",
    "Non Null"(List<String>{
      if "Initial ALP More Than 2x ULN" is null then 'lab.alp.timesULN' else null,
      if "GGT Higher Than ULN" is null then 'lab.ggt.raised' else null
    }))
  union "Missing When Undetermined"("P2: Settled Biliary Colic With Raised ALP And GGT, Biliary Tree Not Imaged",
    "Non Null"(List<String>{
      if "Suspected Biliary Colic Or Cholecystitis" is null then 'symptom.biliaryColicOrCholecystitis' else null,
      if "ALP Raised" is null then 'lab.alp.high' else null,
      if "GGT Higher Than ULN" is null then 'lab.ggt.raised' else null,
      if "Symptoms Settle With Analgesia" is null then 'symptom.settlesWithAnalgesia' else null,
      if "Biliary Tree Previously Imaged" is null then 'imaging.biliaryTree.ever' else null
    }))
  union "Missing When Undetermined"("P2: Specialist Advises Urgent Ultrasound", { 'advice.urgentImagingRecommended' })
  union "Missing When Undetermined"("P3: Recurrent RUQ Or Epigastric Non-Dyspepsia Pain Without Previous Imaging",
    "Non Null"(List<String>{
      if "Recurrent RUQ Or Epigastric Pain" is null then 'symptom.recurrentRUQOrEpigastricPain' else null,
      if "Dyspepsia" is null then 'symptom.dyspepsia' else null,
      if "Presenting Problem Previously Imaged" is null then 'imaging.presentingProblem.ever' else null
    }))
  union "Missing When Undetermined"("P3: Resolved Biliary Colic, No Gallstones On Previous Imaging, Cholecystectomy Candidate",
    "Non Null"(List<String>{
      if "Suspected Biliary Colic Or Cholecystitis" is null then 'symptom.biliaryColicOrCholecystitis' else null,
      if "Biliary Colic Or Cholecystitis Resolved" is null then 'symptom.biliaryColicResolved' else null,
      if "Previous Imaging Showed Gallstones" is null then 'imaging.gallstones.ever' else null,
      if "Cholecystectomy Candidate Who Would Accept" is null then 'workup.cholecystectomyCandidate' else null
    }))
  union "Missing When Undetermined"("P3: Follow-Up ALP And GGT Still Raised At 3 Months",
    "Non Null"(List<String>{
      if "Repeat Testing At 3 Months Or More" is null then 'lab.repeatAfter3Months' else null,
      if "Initial ALP More Than 2x ULN" is null then 'lab.alp.timesULN' else null,
      if "Repeat ALP Higher Than ULN" is null then 'lab.alp.repeatHigh' else null,
      if "Repeat GGT Higher Than ULN" is null then 'lab.ggt.repeatRaised' else null
    }))
  union "Missing When Undetermined"("P3: ALT Over 120 With Risk Factors, Conservative Methods Unsuccessful, No Features Of Concern",
    "Non Null"(List<String>{
      if "ALT Greater Than 120 IU/L" is null then 'lab.alt.value' else null,
      if "Has High Risk Factors" is null then 'patient.liverRiskFactors' else null,
      if "Conservative Methods Unsuccessful" is null then 'workup.conservativeMethodsUnsuccessful' else null,
      if "Clinical Features Of Concern" is null then 'workup.clinicalFeaturesOfConcern' else null
    }))
  union "Missing When Undetermined"("P3: Isolated GGT More Than 5x ULN Persisting At 3 Months",
    "Non Null"(List<String>{
      if "LFT Abnormality Isolated" is null then 'lab.isolatedLftAbnormality' else null,
      if "Dec"('lab.ggt.timesULN') is null then 'lab.ggt.timesULN' else null,
      if "Repeat Testing At 3 Months Or More" is null then 'lab.repeatAfter3Months' else null,
      if "Dec"('lab.ggt.repeatTimesULN') is null then 'lab.ggt.repeatTimesULN' else null
    }))
  union "Missing When Undetermined"("P3: Asymptomatic Newly Suspected AAA",
    "Non Null"(List<String>{
      if "AAA Newly Suspected" is null then 'symptom.aaaNewlySuspected' else null,
      if "AAA Asymptomatic" is null then 'symptom.aaaAsymptomatic' else null
    }))
  union "Missing When Undetermined"("P3: Non-Pulsatile Abdominal Mass And Suspected Enlarged Liver",
    "Non Null"(List<String>{
      if "Non-Pulsatile Abdominal Mass" is null then 'symptom.abdominalMassNonPulsatile' else null,
      if "Suspected Enlarged Liver" is null then 'symptom.hepatomegalySuspected' else null
    }))
  union "Missing When Undetermined"("P3: Specialist Advises Non-Urgent Ultrasound", { 'advice.nonUrgentImagingRecommended' })
  union "Missing When Undetermined"("S3: HCC Surveillance As Recommended", { 'advice.hccSurveillance' })
  union "Missing When Undetermined"("S3: Surveillance Of Known AAA", { 'advice.aaaSurveillance' })
  union "Missing When Undetermined"("S3: Incidental Finding Follow Up", { 'advice.incidentalFindingFollowUp' })

/*
  SOURCE (Overview p5): "always include the name and role of that person in the referral."
*/
define "Any Adviser Gateway Met":
  "Acute 48h: Specialist Advises Same Or Next Day Ultrasound" is true
    or "P2: Specialist Advises Urgent Ultrasound" is true
    or "P3: Specialist Advises Non-Urgent Ultrasound" is true

define "Missing Advice Indicators":
  if "Any Adviser Gateway Met" and not "Is Answered"('advice.adviserNameRole')
    then { 'advice.adviserNameRole' }
  else {} as List<String>

define "Missing Information":
  if "Determination" in { 'ACUTE_48H', 'P2_URGENT', 'P3_NON_DEFERRABLE', 'S3_TIME_SENSITIVE', 'ALTERNATIVE_MANAGEMENT', 'NOT_ROUTINELY_FUNDED', 'PAEDIATRIC_CRITERIA_APPLY' }
    then "Missing Advice Indicators"
  else "Missing Pathway Indicators" union "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age', 'patient.liverRiskFactors',
    'symptom.jaundice', 'redflag.painfulJaundice', 'workup.jaundiceObviousCause',
    'symptom.biliaryColicOrCholecystitis', 'symptom.settlesWithAnalgesia', 'symptom.biliaryColicResolved',
    'symptom.recurrentRUQOrEpigastricPain', 'symptom.dyspepsia',
    'symptom.aaaNewlySuspected', 'symptom.aaaAsymptomatic',
    'symptom.abdominalMassNonPulsatile', 'symptom.abdominalMassUpper', 'symptom.hepatomegalySuspected',
    'symptom.fatigue', 'symptom.abdominalPain', 'weightloss.present',
    'symptom.colorectalNeoplasmSuspected', 'symptom.unilateralLymphoedemaNew', 'symptom.chronicPancreatitis',
    'symptom.urinaryTractPresentation', 'symptom.isolatedBloating',
    'lab.alp.timesULN', 'lab.alp.high', 'lab.alp.repeatHigh',
    'lab.ggt.raised', 'lab.ggt.timesULN', 'lab.ggt.repeatRaised', 'lab.ggt.repeatTimesULN',
    'lab.repeatAfter3Months', 'lab.isolatedLftAbnormality', 'lab.bilirubin.raised', 'lab.alt.value', 'lab.ferritin.raised',
    'imaging.biliaryTree.ever', 'imaging.presentingProblem.ever', 'imaging.gallstones.ever',
    'workup.cholecystectomyCandidate', 'workup.conservativeMethodsUnsuccessful', 'workup.clinicalFeaturesOfConcern',
    'workup.suspicionMalignancy',
    'advice.acuteImagingRecommended', 'advice.urgentImagingRecommended', 'advice.nonUrgentImagingRecommended',
    'advice.adviserNameRole', 'advice.hccSurveillance', 'advice.aaaSurveillance', 'advice.incidentalFindingFollowUp',
    'funding.hernia', 'funding.infectiveHepatitis', 'funding.gallstonesFollowUpAsymptomatic',
    'funding.simpleCystFollowUp', 'funding.screeningAorticAneurysm', 'funding.screeningFattyLiver'
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
    acute48hPainlessJaundice: "Acute 48h: Painless Jaundice Without Obvious Cause",
    acute48hAdvice: "Acute 48h: Specialist Advises Same Or Next Day Ultrasound",
    meetsAcute48h: "Meets Acute 48h Criteria",
    p2AlpGgt: "P2: Initial ALP More Than 2x ULN And GGT Raised",
    p2SettledBiliaryColic: "P2: Settled Biliary Colic With Raised ALP And GGT, Biliary Tree Not Imaged",
    p2Advice: "P2: Specialist Advises Urgent Ultrasound",
    meetsP2: "Meets P2 Criteria",
    p3RecurrentPain: "P3: Recurrent RUQ Or Epigastric Non-Dyspepsia Pain Without Previous Imaging",
    p3ResolvedBiliaryColic: "P3: Resolved Biliary Colic, No Gallstones On Previous Imaging, Cholecystectomy Candidate",
    p3FollowUpAlpGgt: "P3: Follow-Up ALP And GGT Still Raised At 3 Months",
    p3Alt: "P3: ALT Over 120 With Risk Factors, Conservative Methods Unsuccessful, No Features Of Concern",
    p3IsolatedGgt: "P3: Isolated GGT More Than 5x ULN Persisting At 3 Months",
    p3Aaa: "P3: Asymptomatic Newly Suspected AAA",
    p3MassLiver: "P3: Non-Pulsatile Abdominal Mass And Suspected Enlarged Liver",
    p3Advice: "P3: Specialist Advises Non-Urgent Ultrasound",
    meetsP3: "Meets P3 Criteria",
    s3Hcc: "S3: HCC Surveillance As Recommended",
    s3Aaa: "S3: Surveillance Of Known AAA",
    s3Incidental: "S3: Incidental Finding Follow Up",
    meetsS3: "Meets S3 Criteria",
    ggtNormalAtLatestTest: "GGT Normal At Latest Test",
    alternativeManagement: "Alternative Management Recommended",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'US Abdomen - Adult',
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
