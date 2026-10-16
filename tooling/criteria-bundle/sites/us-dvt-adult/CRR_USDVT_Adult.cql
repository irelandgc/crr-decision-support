/*
  CRR National Community Referral Criteria for Imaging (Part I)
  US DVT - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    Section:    US DVT - Adult, pages 36-37
    Repo copy:  documents/reference/National Primary Care Referral Criteria for Imaging.pdf

  STATUS
    DEMO TRANSCRIPTION - NOT CLINICALLY SIGNED OFF (AD-10; staging demo under
    AD-35). Encodes the most literal reading of the printed text; every
    ambiguity is a REVIEW question below.

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the
    published wording verbatim, with page reference. A define with no SOURCE
    comment is engineering plumbing, not a clinical rule. Review is a
    side-by-side check of each SOURCE quote against the define beneath it.
    The printed "1" after each Wells bullet on p36 is a reference marker (in
    the PDF it is a link to a reference dialog that the PDF does not contain),
    not wording; it is kept in the SOURCE quotes as printed and left out of
    the logic (REVIEW Q2).

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-US-DVT-Adult" (Questionnaire-us-dvt-adult.json). Each
    answer MAY carry the answer-evidence extension (status documented |
    inferred | retrieved, quote). An answer with no evidence extension counts
    as 'documented'. An unanswered indicator is NULL and propagates as
    "insufficient information" under CQL three-valued logic.

  OUTCOMES
    ALTERNATIVE_MANAGEMENT        children younger than 15 / pregnant women
    ACUTE_24H         priority code A24
    ACUTE_48H         priority code A48
    S1_TIME_SENSITIVE  priority code S1
    S2_TIME_SENSITIVE priority code S2
    NOT_ROUTINELY_FUNDED
    CRITERIA_NOT_MET / INSUFFICIENT_INFORMATION
    Determination codes carry no priority code, because the Advisory renderer
    humanises an unmapped determination code for the referrer. Priority codes
    are emitted only in "Priority Code" (triager view).

  CLINICAL REVIEW FLAGS (listed in signoff.md and transcription-notes.md)
    Q1  Wells score is taken as the number the referrer documents; the bundle
        does not compute it from its components (the PDF names the score and
        links mdcalc, but does not define it).
    Q2  The printed "1" after each Wells bullet is read as a reference marker
        with no wording behind it in the PDF.
    Q3  Precedence: redirect > highest priority met > not routinely funded >
        not met > insufficient. Differs from CT CAP (not-funded first).
    Q4  Highest priority wins where rows overlap. "No DVT on initial US, still
        suspected, Wells >= 2" (S1) also meets Acute 48h when the referral says
        lower limb DVT is still clinically suspected - S1 bullet 1 is then
        unreachable.
    Q5  S2 ("follow up scan after anticoagulation as recommended by secondary
        care specialist") also meets S1 bullet 3 when the same advice is read
        as "advises referral for follow up ultrasound DVT" - S1 wins.
    Q6  S2 versus not-funded "routine follow-up scanning to confirm clot
        resolution": both can be true; S2 wins under Q3.
    Q7  "Children aged younger than 15 years" is read as age < 15. Overview p4
        puts age 15 in the paediatric band; a 15-year-old is assessed on these
        adult criteria (no paediatric DVT section exists).
    Q8  "5 - 8 days after the initial scan" (S1 bullets 1 and 2) is read as
        the specified target date, not an eligibility condition.
    Q9  "a calf DVT not being treated with anticoagulation" is read as
        diagnosed calf DVT AND patient not on anticoagulant therapy.
    Q10 "Superficial venous thrombosis" is read as a clinical diagnosis stated
        by the referrer (not necessarily imaging-confirmed).
    Q11 Same-day advice (Acute 24h bullet 3) names "Health NZ Haematology
        service or other secondary care specialist" and "same day"; it is not
        folded into advice.acuteImagingRecommended ("PCRL or radiologist",
        "same or next day").
    Q12 S1 bullet 3 adviser is "Secondary care clinician or Radiologist" (no
        PCRL); encoded as advice.followUpImagingRecommendedBySpecialist worded to match.
    Q13 "clinical suspicion remains high" is an attestation indicator (AD-17);
        "clinically suspected upper / lower limb DVT" is not.
    Q14 A met lower priority is returned even when a higher row is still
        undetermined (e.g. S1 met, Acute 48h unknown).
    Q15 The HealthPathways and "local DVT HealthPathway" page IDs are not in
        the PDF (published JSON cites Auckland page 32358).
*/

library CRR_USDVT_Adult version '1.0.0'

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

define function "Int"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToInteger("Answer"(linkId).value as FHIR.integer) else null

// ---------------------------------------------------------------------------
// Demographics
// ---------------------------------------------------------------------------

define "Age In Years":
  Coalesce("Int"('patient.age'), AgeInYears())

// ---------------------------------------------------------------------------
// Acute: Within 24 hours
// ---------------------------------------------------------------------------

/*
  SOURCE (p36, "Acute:  Within 24 hours", bullet 1):
  "Superficial venous thrombosis affecting the proximal long saphenous vein in
   the thigh,"
  SOURCE (p37, not routinely funded, bullet 2): "Superficial venous thrombosis,
   unless affecting the proximal long saphenous vein in the thigh"

  One concept, one indicator (KI-01): SVT and its location are each read once
  and used both here and in the not-funded item below.
  REVIEW Q10 - "Superficial venous thrombosis" is read as a clinical diagnosis
  stated by the referrer, not necessarily imaging-confirmed. Confirm.
*/
define "Superficial Venous Thrombosis":
  "Bool"('symptom.superficialVenousThrombosis')

define "SVT Affects Proximal Long Saphenous Vein In Thigh":
  "Bool"('symptom.svtProximalLongSaphenousVeinThigh')

define "Acute 24h: SVT Affecting Proximal Long Saphenous Vein In Thigh":
  "Superficial Venous Thrombosis" and "SVT Affects Proximal Long Saphenous Vein In Thigh"

/*
  SOURCE (p36, "Acute:  Within 24 hours", bullet 2):
  "Clinically suspected upper limb DVT"

  REVIEW Q13 - read as a fact the referral states (the question being asked),
  not an attestation indicator. Confirm.
*/
define "Acute 24h: Clinically Suspected Upper Limb DVT":
  "Bool"('symptom.suspectedDvtUpperLimb')

/*
  SOURCE (p36, "Acute:  Within 24 hours", bullet 3):
  "Same day DVT US recommended by Health NZ Haematology service or other
   secondary care specialist"

  REVIEW Q11 - own indicator (advice.sameDayImagingRecommended), not
  advice.acuteImagingRecommended: the adviser set (Haematology / other
  secondary care specialist; no PCRL) and "same day" (not "same or next day")
  differ. Folding them would widen this criterion. Confirm.
*/
define "Acute 24h: Same Day DVT US Recommended By Specialist":
  "Bool"('advice.sameDayImagingRecommended')

/*
  SOURCE (p36, Timeframe column): "Acute:  Within 24 hours"
  The three bullets are separate presentations; any one qualifies.
*/
define "Meets Acute 24h Criteria":
  "Acute 24h: SVT Affecting Proximal Long Saphenous Vein In Thigh"
    or "Acute 24h: Clinically Suspected Upper Limb DVT"
    or "Acute 24h: Same Day DVT US Recommended By Specialist"

// ---------------------------------------------------------------------------
// Acute: Within 48 hours
// ---------------------------------------------------------------------------

/*
  SOURCE (p36, "Acute: Within 48 hours"):
  "Clinically suspected lower limb DVT and one or more of the following:
     o Well’s score of 2 or greater   1
     o Well’s score less than 2 and positive D-dimer 1"

  Shape: mandatory stem AND (option 1 OR option 2); option 2 is internally
  conjunctive (census usdvt_48_1, confirmed by Gary 5 July 2026).
  REVIEW Q1 - "Well’s score" is the number the referrer documents (the
  Source column links "Well’s Criteria for DVT (mdcalc.com)"). The PDF does not
  define the score, so the bundle does not compute it from its components; a
  score the extraction step computes from components is 'inferred' and is not
  accepted under the strict standard. Confirm.
  REVIEW Q2 - the trailing "1" is a reference marker, not part of the
  criterion. Confirm nothing is missing behind it.
  "2 or greater" is >= 2; "less than 2" is < 2 (printed boundary, literal).
*/
define "Clinically Suspected Lower Limb DVT":
  "Bool"('symptom.suspectedDvtLowerLimb')

define "Wells Score":
  "Int"('workup.wellsScoreDvt')

define "Wells Score 2 Or Greater":
  "Wells Score" >= 2

define "Wells Score Less Than 2":
  "Wells Score" < 2

define "Positive D-dimer":
  "Bool"('lab.ddimer.positive')

define "Acute 48h Option: Wells Score 2 Or Greater":
  "Wells Score 2 Or Greater"

define "Acute 48h Option: Wells Score Less Than 2 And Positive D-dimer":
  "Wells Score Less Than 2" and "Positive D-dimer"

define "Meets Acute 48h Criteria":
  "Clinically Suspected Lower Limb DVT"
    and ("Acute 48h Option: Wells Score 2 Or Greater"
      or "Acute 48h Option: Wells Score Less Than 2 And Positive D-dimer")

// ---------------------------------------------------------------------------
// S1: within 1 week of a specified target date
// ---------------------------------------------------------------------------

/*
  SOURCE (p36, S1, bullet 1):
  "No DVT seen on initial ultrasound but where clinical suspicion remains high
   AND there is high likelihood on Well’s score (i.e. 2 or higher). Arrange the
   follow-up scan for 5 - 8 days after the initial scan."

  Three atoms, all required (as printed: "but where ... AND ...").
  REVIEW Q13 - "clinical suspicion remains high" is the referrer's clinical
  judgement: attestation category (AD-17), workup.dvtClinicalSuspicionHigh.
  REVIEW Q8 - "Arrange the follow-up scan for 5 - 8 days after the initial
  scan" is read as the specified target date for the S1 timeframe, not a
  condition. Not encoded.
  REVIEW Q4 - when the referral also says lower limb DVT is clinically
  suspected, Acute 48h is met too and wins (highest priority).
*/
define "No DVT On Initial Ultrasound":
  "Bool"('imaging.usdvt.initialNegative')

define "Clinical Suspicion Remains High":
  "Bool"('workup.dvtClinicalSuspicionHigh')

define "S1: No DVT On Initial US, Suspicion High, Wells 2 Or Higher":
  "No DVT On Initial Ultrasound"
    and "Clinical Suspicion Remains High"
    and "Wells Score 2 Or Greater"

/*
  SOURCE (p36, S1, bullet 2):
  "To check for proximal clot extension in a calf DVT not being treated with
   anticoagulation, between 5 - 8 days after initial scan."

  REVIEW Q9 - read as: calf DVT diagnosed AND patient not on anticoagulant
  therapy. "To check for proximal clot extension" is the purpose of the scan,
  not a further condition. "between 5 - 8 days after initial scan" is the
  target date (REVIEW Q8). Confirm.
*/
define "Calf DVT":
  "Bool"('symptom.calfDvt')

define "On Anticoagulants":
  "Bool"('history.anticoagulantTherapy')

define "S1: Calf DVT Not Treated With Anticoagulation":
  "Calf DVT" and not "On Anticoagulants"

/*
  SOURCE (p36, S1, bullet 3):
  "Secondary care clinician or Radiologist advises referral for follow up
   ultrasound DVT"

  REVIEW Q12 - advice.followUpImagingRecommendedBySpecialist, worded "secondary care
  clinician or radiologist" to match (no PCRL). Confirm.
*/
define "S1: Secondary Care Clinician Or Radiologist Advises Follow Up DVT US":
  "Bool"('advice.followUpImagingRecommendedBySpecialist')

/*
  SOURCE (p36, Timeframe column): "S1: Time sensitive imaging that must be
   completed within 1 week of a specified target date."
*/
define "Meets S1 Criteria":
  "S1: No DVT On Initial US, Suspicion High, Wells 2 Or Higher"
    or "S1: Calf DVT Not Treated With Anticoagulation"
    or "S1: Secondary Care Clinician Or Radiologist Advises Follow Up DVT US"

// ---------------------------------------------------------------------------
// S2: within 2 weeks of a specified target date
// ---------------------------------------------------------------------------

/*
  SOURCE (p36, S2, bullet 1):
  "Follow up scan after anticoagulation therapy as recommended by secondary
   care specialist."
  SOURCE (p36, Timeframe column): "S2: Time sensitive imaging that must be
   completed within 2 weeks of a specified target date."

  One indicator (advice.postAnticoagulationScanRecommended): the row is a
  single specialist recommendation, gated by that recommendation (KI-07).
  REVIEW Q5 - the same advice may also be read as S1 bullet 3; S1 then wins.
  REVIEW Q6 - may coexist with the not-funded "routine follow-up scanning to
  confirm clot resolution"; S2 wins under the precedence in REVIEW Q3.
*/
define "S2: Follow Up Scan After Anticoagulation Recommended By Specialist":
  "Bool"('advice.postAnticoagulationScanRecommended')

define "Meets S2 Criteria":
  "S2: Follow Up Scan After Anticoagulation Recommended By Specialist"

// ---------------------------------------------------------------------------
// Specialist advice - adviser name and role
// ---------------------------------------------------------------------------

/*
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Specialist Advice Given":
  "Acute 24h: Same Day DVT US Recommended By Specialist" is true
    or "S1: Secondary Care Clinician Or Radiologist Advises Follow Up DVT US" is true
    or "S2: Follow Up Scan After Anticoagulation Recommended By Specialist" is true

define "Adviser Name And Role Documented":
  "Is Answered"('advice.adviserNameRole')

// ---------------------------------------------------------------------------
// Alternative management or HealthPathway recommended (redirects)
// ---------------------------------------------------------------------------

/*
  SOURCE (p36, "Alternative management or HealthPathway recommended."):
   - "Children aged younger than 15 years – see local DVT HealthPathway"
   - "Pregnant women – see local DVT HealthPathway."

  REVIEW Q7 - "younger than 15 years" is age < 15 (literal). Overview p4 puts
  "up to and including 15 years" in the paediatric band, so age 15 falls in a
  gap: not redirected here, and there is no paediatric DVT section. Encoded:
  a 15-year-old is assessed on these criteria. Confirm.
  An unknown age or pregnancy status does not block a referral; it is
  surfaced in "Unconfirmed Exclusions" for the triager.
*/
define "Redirect: Child Younger Than 15 Years":
  "Age In Years" < 15

define "Redirect: Pregnant Woman":
  "Bool"('patient.pregnant')

define "Active Redirects":
  (List<String>{
    if "Redirect: Child Younger Than 15 Years" is true then 'Children aged younger than 15 years – see local DVT HealthPathway' else null,
    if "Redirect: Pregnant Woman" is true then 'Pregnant women – see local DVT HealthPathway.' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

define "Unconfirmed Exclusions":
  (List<String>{
    if "Redirect: Child Younger Than 15 Years" is null then 'patient.age' else null,
    if "Redirect: Pregnant Woman" is null then 'patient.pregnant' else null
  }) R where R is not null

// ---------------------------------------------------------------------------
// Not routinely funded
// ---------------------------------------------------------------------------

/*
  SOURCE (p37, "Community-referred radiology not routinely funded by Health New
  Zealand in these clinical scenarios. Imaging may still be appropriate, and the
  patient may wish to consider privately funding imaging."):
   - "Routine follow-up scanning to confirm clot resolution - this does not
      typically assist with decisions on duration of anticoagulation."
   - "Superficial venous thrombosis, unless affecting the proximal long
      saphenous vein in the thigh"

  The clause after the dash in item 1 is the rationale ("typically" - a
  modifier, KI-05); it is not encoded. An unknown not-funded item is treated
  as not present.
*/
define "Not Funded: Routine Follow Up To Confirm Clot Resolution":
  Coalesce("Bool"('funding.routineClotResolutionFollowUp'), false)

define "Not Funded: SVT Not Affecting Proximal Long Saphenous Vein In Thigh":
  "Superficial Venous Thrombosis" is true
    and "SVT Affects Proximal Long Saphenous Vein In Thigh" is false

define "Not Routinely Funded":
  "Not Funded: Routine Follow Up To Confirm Clot Resolution"
    or "Not Funded: SVT Not Affecting Proximal Long Saphenous Vein In Thigh"

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (REVIEW Q3 - confirm ordering):
    1. Alternative management / redirect (BRD TA-013: redirect wins over criteria)
    2. Highest priority met: Acute 24h > Acute 48h > S1 > S2
       (crr-business-rules.md Rule 2.2; prompt decomposition item 22)
    3. Not routinely funded
    4. Every priority row definitively not met
    5. Insufficient information
  Not-funded sits below the priority rows because its items are presentations
  ("in these clinical scenarios"), not patient-level vetoes: a referral with a
  not-funded SVT AND a suspected lower limb DVT meeting Acute 48h is referred
  for the DVT. CT CAP orders not-funded first; its one item is patient-level.
  REVIEW Q14 - a met lower priority is returned even if a higher row is still
  undetermined.
*/
define "Any Priority Criteria Met":
  "Meets Acute 24h Criteria"
    or "Meets Acute 48h Criteria"
    or "Meets S1 Criteria"
    or "Meets S2 Criteria"

define "Determination":
  case
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Meets Acute 24h Criteria" is true then 'ACUTE_24H'
    when "Meets Acute 48h Criteria" is true then 'ACUTE_48H'
    when "Meets S1 Criteria" is true then 'S1_TIME_SENSITIVE'
    when "Meets S2 Criteria" is true then 'S2_TIME_SENSITIVE'
    when "Not Routinely Funded" then 'NOT_ROUTINELY_FUNDED'
    when "Any Priority Criteria Met" is false then 'CRITERIA_NOT_MET'
    else 'INSUFFICIENT_INFORMATION'
  end

define "Priority Code":
  case "Determination"
    when 'ACUTE_24H' then 'A24'
    when 'ACUTE_48H' then 'A48'
    when 'S1_TIME_SENSITIVE' then 'S1'
    when 'S2_TIME_SENSITIVE' then 'S2'
    else null
  end

/*
  SOURCE (p36, Timeframe column): "Acute:  Within 24 hours"; "Acute: Within 48
   hours"; "S1: Time sensitive imaging that must be completed within 1 week of a
   specified target date."; "S2: Time sensitive imaging that must be completed
   within 2 weeks of a specified target date."
  The referrer-facing timeframe carries the wording without the S-code.
*/
define "Priority Timeframe":
  case "Determination"
    when 'ACUTE_24H' then 'Within 24 hours'
    when 'ACUTE_48H' then 'Within 48 hours'
    when 'S1_TIME_SENSITIVE' then 'Time sensitive imaging that must be completed within 1 week of a specified target date'
    when 'S2_TIME_SENSITIVE' then 'Time sensitive imaging that must be completed within 2 weeks of a specified target date'
    else null
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

/*
  Every unanswered criterion atom is listed, except an atom whose parent atom
  is already known false (SVT location once SVT is known absent; Wells and
  D-dimer once lower limb DVT is known not suspected and the S1 bullet 1 route
  is closed; anticoagulation once calf DVT is known absent; D-dimer once Wells
  is 2 or greater).
*/
define "Missing Criteria Indicators":
  (List<String>{
    if "Superficial Venous Thrombosis" is null then 'symptom.superficialVenousThrombosis' else null,
    if "Superficial Venous Thrombosis" is not false and "SVT Affects Proximal Long Saphenous Vein In Thigh" is null
      then 'symptom.svtProximalLongSaphenousVeinThigh' else null,
    if "Acute 24h: Clinically Suspected Upper Limb DVT" is null then 'symptom.suspectedDvtUpperLimb' else null,
    if "Acute 24h: Same Day DVT US Recommended By Specialist" is null then 'advice.sameDayImagingRecommended' else null,
    if "Clinically Suspected Lower Limb DVT" is null then 'symptom.suspectedDvtLowerLimb' else null,
    if "Wells Score" is null
      and ("Clinically Suspected Lower Limb DVT" is not false
        or ("No DVT On Initial Ultrasound" is not false and "Clinical Suspicion Remains High" is not false))
      then 'workup.wellsScoreDvt' else null,
    if "Positive D-dimer" is null
      and "Clinically Suspected Lower Limb DVT" is not false
      and "Wells Score 2 Or Greater" is not true
      then 'lab.ddimer.positive' else null,
    if "No DVT On Initial Ultrasound" is null then 'imaging.usdvt.initialNegative' else null,
    if "No DVT On Initial Ultrasound" is not false and "Clinical Suspicion Remains High" is null
      then 'workup.dvtClinicalSuspicionHigh' else null,
    if "Calf DVT" is null then 'symptom.calfDvt' else null,
    if "Calf DVT" is not false and "On Anticoagulants" is null then 'history.anticoagulantTherapy' else null,
    if "S1: Secondary Care Clinician Or Radiologist Advises Follow Up DVT US" is null then 'advice.followUpImagingRecommendedBySpecialist' else null,
    if "S2: Follow Up Scan After Anticoagulation Recommended By Specialist" is null then 'advice.postAnticoagulationScanRecommended' else null
  }) M where M is not null

define "Missing Advice Indicators":
  (List<String>{
    if "Specialist Advice Given" and not "Adviser Name And Role Documented"
      then 'advice.adviserNameRole' else null
  }) M where M is not null

define "Missing Information":
  if "Determination" in { 'ACUTE_24H', 'ACUTE_48H', 'S1_TIME_SENSITIVE',
                          'S2_TIME_SENSITIVE', 'ALTERNATIVE_MANAGEMENT', 'NOT_ROUTINELY_FUNDED' }
    then "Missing Advice Indicators"
  else "Missing Criteria Indicators" union "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age', 'patient.pregnant', 'history.anticoagulantTherapy',
    'symptom.superficialVenousThrombosis', 'symptom.svtProximalLongSaphenousVeinThigh',
    'symptom.suspectedDvtUpperLimb', 'symptom.suspectedDvtLowerLimb', 'symptom.calfDvt',
    'workup.wellsScoreDvt', 'workup.dvtClinicalSuspicionHigh',
    'lab.ddimer.positive',
    'imaging.usdvt.initialNegative',
    'advice.sameDayImagingRecommended', 'advice.followUpImagingRecommendedBySpecialist',
    'advice.postAnticoagulationScanRecommended', 'advice.adviserNameRole',
    'funding.routineClotResolutionFollowUp'
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
    ageInYears: "Age In Years",
    a24Svt: "Acute 24h: SVT Affecting Proximal Long Saphenous Vein In Thigh",
    a24UpperLimb: "Acute 24h: Clinically Suspected Upper Limb DVT",
    a24SameDayAdvice: "Acute 24h: Same Day DVT US Recommended By Specialist",
    meetsAcute24h: "Meets Acute 24h Criteria",
    lowerLimbSuspected: "Clinically Suspected Lower Limb DVT",
    wellsScore: "Wells Score",
    positiveDDimer: "Positive D-dimer",
    a48WellsTwoOrMore: "Acute 48h Option: Wells Score 2 Or Greater",
    a48WellsUnderTwoWithDDimer: "Acute 48h Option: Wells Score Less Than 2 And Positive D-dimer",
    meetsAcute48h: "Meets Acute 48h Criteria",
    s1NegativeInitialUs: "S1: No DVT On Initial US, Suspicion High, Wells 2 Or Higher",
    s1CalfDvtNoAnticoagulation: "S1: Calf DVT Not Treated With Anticoagulation",
    s1FollowUpAdvice: "S1: Secondary Care Clinician Or Radiologist Advises Follow Up DVT US",
    meetsS1: "Meets S1 Criteria",
    s2PostAnticoagulationAdvice: "S2: Follow Up Scan After Anticoagulation Recommended By Specialist",
    meetsS2: "Meets S2 Criteria",
    alternativeManagement: "Alternative Management Recommended",
    notFundedRoutineClotResolution: "Not Funded: Routine Follow Up To Confirm Clot Resolution",
    notFundedSvtNotProximal: "Not Funded: SVT Not Affecting Proximal Long Saphenous Vein In Thigh",
    notRoutinelyFunded: "Not Routinely Funded",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'US DVT - Adult',
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
