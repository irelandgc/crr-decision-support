/*
  CRR National Community Referral Criteria for Imaging (Part I)
  CT Chest - Adult

  SOURCE DOCUMENT
    Title:      National Community Referral Criteria for Imaging (Part I)
    Owner:      System Design Manager Community Radiology
    Authoriser: National Clinical Governance Group
    National ID 15372, Version 2.0, Published 09/04/2026, Review due 09/04/2028
    File:       documents/reference/National Primary Care Referral Criteria for Imaging.pdf
    Section:    Adult CT > CT Chest - Adult, pages 12-16
                (p12 acute row; p13 P2 timeframe cell and Guidance; p14 P2 and P3
                 bullets; p15 alternative management and Notes *1-*3; p16 *3 cont. and *4)

  STATUS
    NOT CLINICALLY REVIEWED. Transcribed for a staging demo bundle (AD-35);
    sign-off pending (signoff.md).

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the published
    wording verbatim, with page reference (line breaks and runs of spaces in the
    PDF are collapsed to single spaces). A define with no SOURCE comment is
    engineering plumbing, not a clinical rule. Review is a side-by-side check of
    each SOURCE quote against the define beneath it.

  WHAT IS NOT IN THIS LIBRARY
    - The "Refer for acute assessment without initial imaging" row (p12: massive
      haemoptysis; stridor / suspected SVC obstruction) is national red flags
      RF-01 and RF-02 in CRR_RedFlags, which runs before any exam library. It is
      not re-encoded here; the PlanDefinition carries the row for display only.
    - No not-routinely-funded row is printed for this section.
    - The "Initial presentation ..." alternative-management bullet (p15) is shown
      in the PlanDefinition but not evaluated (REVIEW Q8).
    - The Guidance equity provision for Māori patients (p13) states no threshold
      and is not evaluated (REVIEW Q12).

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse conforming to
    Questionnaire "CRR-CT-Chest-Adult" (Questionnaire-ct-chest-adult.json).
    Evidence extension, statuses and three-valued logic exactly as
    CRR_CTChestAbdomenPelvis_Adult (see that library's header): an unanswered
    indicator is NULL and propagates as "insufficient information".

  FOOTNOTE *1 (concerning symptoms and signs for lung cancer)
    P2 bullet 2 depends on footnote *1, so each of its 12 items is an indicator
    whose text is the item as printed, including the item's own duration and
    size qualifiers (REVIEW Q4). Footnotes *2 (risk factors), *3 (safety netting)
    and *4 (local pathways - direct to PET CT) gate no criterion directly and are
    carried as notes in the PlanDefinition only (*2 is referenced inside *1 item
    12, whose indicator carries it; see transcription-notes.md section 3).

  CLINICAL REVIEW FLAGS (REVIEW Qn - full text in signoff.md / transcription-notes.md)
    Q1  "over 55 years" read as > 55 (55 does not qualify).
    Q2  P2 bullet 2 sub-bullets read as all required (sub-bullet 2 has no "AND").
    Q3  "new onset" and "Persistent for six weeks despite appropriate treatment"
        read as separate conditions on the *1 symptoms; "for six weeks" read as
        at least six weeks.
    Q4  *1 items encoded whole (qualifiers inside each item, *2 not separately
        encoded for item 12).
    Q5  "Unexplained haemoptysis (...)" parenthetical read as two conditions:
        no chest infection AND upper respiratory tract causes excluded.
    Q6  "CT chest is recommended in the Radiology report" encoded with one
        indicator shared by P2 bullets 3 and 4 and P3 bullet 1.
    Q7  Isolated nodule not confirmed benign (P3) vs indeterminate abnormality
        raising the possibility of lung cancer (P2): which applies to a nodule.
    Q8  "Initial presentation ..." redirect not evaluated: the literal reading,
        with redirects taking precedence, would redirect referrals whose chest
        x-ray is already done.
    Q9  "concerning symptoms or signs" in the re-presentation redirect read as
        the *1 list (no *1 marker there).
    Q10 Redirect precedence over criteria (TA-013) where the non-specific
        symptoms redirect and P2 bullet 2 both hold.
    Q11 Follow-up of incidental CT nodule: redirect unless the report confirms
        benign and no follow-up is required; unknown benign status redirects.
    Q12 Māori equity provision in Guidance not encoded (no threshold stated).
    Q13 Adult gate (age > 15, Overview p4) applied; a child returns
        PAEDIATRIC_CRITERIA_APPLY though no CT Chest - Paediatric section exists.
    Q14 "Persistent, non-specific, non-localising symptoms ... concerning for
        underlying cancer" proposed as an attestation indicator (AD-17).
    Q15 P3 returned when P3 is met and P2 is still indeterminate.
    Q16 P2 bullet 5 omits PCRL and names staging CT "chest/liver": encoded as
        printed, its own advice indicator.
*/

library CRR_CTChest_Adult version '1.0.0'

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

/*
  SOURCE (Overview, p4, Scope item 5): "The age band covered by the paediatric
  criteria has been specified as up to and including 15 years of age"
  REVIEW Q13 - The section is "CT Chest - Adult" and the document has no CT Chest
  paediatric section. The adult gate is applied as in CT CAP; a patient aged 15
  or under returns PAEDIATRIC_CRITERIA_APPLY.
*/
define "Is Adult": "Age In Years" > 15

// ---------------------------------------------------------------------------
// Shared work-up components
// ---------------------------------------------------------------------------

define "Chest X-ray Done": "Bool"('workup.cxr')

define "Bloods Done": "Bool"('workup.bloods')

/*
  "fail to identify a cause" (p14, P2 bullet 1), "unexplained despite initial
  investigations" (p14, P2 bullet 2) and "fail to identify a cause" (p15,
  alternative management bullet 2) are one concept: initial investigations have
  not explained the presentation. One indicator (KI-01).
*/
define "Initial Investigations Fail To Identify Cause": "Bool"('workup.initialInvestigationsCauseNotFound')

/*
  REVIEW Q6 - "CT chest is recommended in the Radiology report" (P2 bullets 3, 4)
  and "referral for CT chest is recommended in the Radiology report" (P3 bullet 1)
  are read as one concept and share one indicator.
*/
define "Radiology Report Recommends CT Chest": "Bool"('workup.radiologyReportRecommendsImaging')

/*
  SOURCE (Overview p5): "If the referral was discussed with and endorsed by any
   secondary care clinician, radiologist, or primary care radiology liaison,
   always include the name and role of that person in the referral."
*/
define "Adviser Name And Role Documented":
  "Is Answered"('advice.adviserNameRole')

// ---------------------------------------------------------------------------
// P2 bullet 1 - unexplained haemoptysis
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 1):
  "Unexplained haemoptysis (occurred in absence of chest infection and upper
   respiratory tract causes including bleeding from the nasopharynx, sinuses, or
   oral cavity have been excluded), And initial investigations including chest
   x-ray fail to identify a cause - refer for urgent CT chest and for respiratory
   assessment."

  REVIEW Q5 - The parenthetical is read as two conditions, both required: the
  haemoptysis occurred in the absence of chest infection, AND upper respiratory
  tract causes (nasopharynx, sinuses, oral cavity) have been excluded.
  "Haemoptysis" reuses the vocabulary indicator redflag.haemoptysisPresent (the
  RF-14 stem; the vocabulary already attributes it to this page).
  "- refer for urgent CT chest and for respiratory assessment" is an instruction
  on the outcome, not a condition; it is shown in the PlanDefinition wording.
*/
define "Haemoptysis": "Bool"('redflag.haemoptysisPresent')

define "Haemoptysis In Absence Of Chest Infection": "Bool"('symptom.haemoptysisWithoutChestInfection')

define "Upper Respiratory Tract Causes Excluded": "Bool"('workup.upperAirwayBleedingExcluded')

define "Pathway P2.1: Unexplained Haemoptysis":
  "Haemoptysis"
    and "Haemoptysis In Absence Of Chest Infection"
    and "Upper Respiratory Tract Causes Excluded"
    and "Chest X-ray Done"
    and "Initial Investigations Fail To Identify Cause"

// ---------------------------------------------------------------------------
// P2 bullet 2 - over 55, current smoker, concerning symptoms (*1)
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 2):
  "Aged over 55 years’ old, current smoker; AND
     o One or more concerning, new onset, symptoms /signs for lung cancer *1
     o Persistent for six weeks despite appropriate treatment.
     o AND unexplained despite initial investigations including chest x-ray and
       blood tests."

  REVIEW Q1 - "over 55" is read as strictly greater than 55.
  REVIEW Q2 - The three sub-bullets are read as all required, with the stem:
  sub-bullet 2 carries no "AND", sub-bullet 3 does.
  REVIEW Q3 - "new onset" and "Persistent for six weeks despite appropriate
  treatment" are read as conditions on the *1 symptoms/signs, each its own
  indicator; "for six weeks" is read as "for at least six weeks" and is judged
  within the indicator (no numeric duration is extracted).
*/
define "Aged Over 55": "Age In Years" > 55

define "Current Smoker": "Bool"('patient.currentSmoker')

/*
  SOURCE (p15, Notes, "*1 Concerning symptoms and signs for lung cancer"):
   - "Unexplained, new, or worsening dyspnoea."
   - "Unexplained cough, persisting and worsening for more than 3 weeks."
   - "Unexplained chest and/or shoulder pain persisting for more than 3 weeks."
   - "Unexplained changes in existing symptoms in patients with underlying chronic
      respiratory problems persisting for more than 3 weeks."
   - "Unexplained hoarseness persisting for more than 3 weeks."
   - "Repeated / or unresolved chest infections."
   - "Persistent, unexplained haemoptysis"
   - "Unexplained weight loss and loss of appetite persisting for more than 3 weeks."
   - "Un-investigated/unexplained abnormal chest signs persisting for more than 3
      weeks. (e.g. suspected pleural effusion)"
   - "New, supraclavicular lymphadenopathy"
   - "Features suggestive of paraneoplastic syndromes. e.g. hypercalcaemia,
      hypertrophic osteoarthropathy with finger (and toe) clubbing and painful
      swollen joints"
   - "New cervical lymphadenopathy persisting for more than 3 weeks and nodes are
      more than 1 cm in diameter in a patient with other lung cancer symptoms or
      signs or risk factors."

  REVIEW Q4 - Each item is one indicator whose text is the item as printed; the
  durations ("more than 3 weeks"), the node size ("more than 1 cm") and item 12's
  "other lung cancer symptoms or signs or risk factors" (footnote *2) are judged
  within that indicator, not computed. "e.g." examples are illustrative (KI-05).
*/
define "Concerning Symptom Flags":
  {
    "Bool"('symptom.dyspnoeaUnexplainedNewOrWorsening'),
    "Bool"('symptom.coughUnexplainedOver3Weeks'),
    "Bool"('symptom.chestShoulderPainUnexplainedOver3Weeks'),
    "Bool"('symptom.chronicRespiratorySymptomChangeOver3Weeks'),
    "Bool"('symptom.hoarsenessUnexplainedOver3Weeks'),
    "Bool"('symptom.chestInfectionsRepeatedOrUnresolved'),
    "Bool"('symptom.haemoptysisPersistentUnexplained'),
    "Bool"('symptom.weightAndAppetiteLossOver3Weeks'),
    "Bool"('symptom.abnormalChestSignsOver3Weeks'),
    "Bool"('symptom.supraclavicularLymphadenopathyNew'),
    "Bool"('symptom.paraneoplasticFeatures'),
    "Bool"('symptom.cervicalLymphadenopathyOver3WeeksOver1cm')
  }

define "Concerning Symptom LinkIds":
  {
    'symptom.dyspnoeaUnexplainedNewOrWorsening',
    'symptom.coughUnexplainedOver3Weeks',
    'symptom.chestShoulderPainUnexplainedOver3Weeks',
    'symptom.chronicRespiratorySymptomChangeOver3Weeks',
    'symptom.hoarsenessUnexplainedOver3Weeks',
    'symptom.chestInfectionsRepeatedOrUnresolved',
    'symptom.haemoptysisPersistentUnexplained',
    'symptom.weightAndAppetiteLossOver3Weeks',
    'symptom.abnormalChestSignsOver3Weeks',
    'symptom.supraclavicularLymphadenopathyNew',
    'symptom.paraneoplasticFeatures',
    'symptom.cervicalLymphadenopathyOver3WeeksOver1cm'
  }

// NOTE: "return all" keeps duplicates (a query is distinct by default) and Length
// counts nulls where Count would not - the two CQL traps recorded for CT CAP.
define "Concerning Symptom Count": Length("Concerning Symptom Flags" F where F is true return all F)
define "Unknown Concerning Symptom Count": Length("Concerning Symptom Flags" F where F is null return all F)

// Three-valued: one known -> true; none known but some unknown -> null; all false -> false
define "One Or More Concerning Symptoms Or Signs":
  if "Concerning Symptom Count" >= 1 then true
  else if "Unknown Concerning Symptom Count" >= 1 then null
  else false

define "Unanswered Concerning Symptom LinkIds":
  "Concerning Symptom LinkIds" L where "Bool"(L) is null

define "Concerning Symptoms New Onset": "Bool"('symptom.newOnset')

define "Persistent Six Weeks Despite Appropriate Treatment": "Bool"('symptom.persistentSixWeeksDespiteTreatment')

define "Unexplained Despite Chest X-ray And Blood Tests":
  "Chest X-ray Done" and "Bloods Done" and "Initial Investigations Fail To Identify Cause"

define "Pathway P2.2: Over 55 Current Smoker With Concerning Symptoms":
  "Aged Over 55"
    and "Current Smoker"
    and "One Or More Concerning Symptoms Or Signs"
    and "Concerning Symptoms New Onset"
    and "Persistent Six Weeks Despite Appropriate Treatment"
    and "Unexplained Despite Chest X-ray And Blood Tests"

// ---------------------------------------------------------------------------
// P2 bullet 3 - indeterminate chest x-ray abnormality
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 3):
  "Indeterminate abnormality on chest x-ray which raises the possibility of a
   lung cancer (e.g. bulky hilum), AND CT chest is recommended in the Radiology
   report."
  "(e.g. bulky hilum)" is illustrative (KI-05). REVIEW Q7 - see P3 bullet 1.
*/
define "Indeterminate Chest X-ray Abnormality": "Bool"('workup.cxrIndeterminateAbnormality')

define "Pathway P2.3: Indeterminate Chest X-ray Abnormality":
  "Indeterminate Chest X-ray Abnormality" and "Radiology Report Recommends CT Chest"

// ---------------------------------------------------------------------------
// P2 bullet 4 - persistent consolidation at 6-week follow-up
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 4):
  "Persistent consolidation on chest x-ray done as a 6-week follow-up study AND
   CT chest is recommended in the Radiology report."
*/
define "Persistent Consolidation On 6-Week Follow-up Chest X-ray": "Bool"('workup.cxrPersistentConsolidationFollowUp')

define "Pathway P2.4: Persistent Consolidation":
  "Persistent Consolidation On 6-Week Follow-up Chest X-ray" and "Radiology Report Recommends CT Chest"

// ---------------------------------------------------------------------------
// P2 bullet 5 - staging CT chest/liver advised
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 5):
  "Secondary care clinician or Radiologist advises referral for urgent staging CT
   chest/liver for work up of a suspicious lesion on chest x-ray, AND CT is the
   advised next step on local HealthPathway as opposed to referral to secondary
   care or PET-CT *4"
  SOURCE (p16, "*4 Local pathways–direct to PET CT: Where chest x-ray findings
   are suspicious for a lung cancer but there are no features on the chest x-ray
   to suggest it is not curable, the preferred next step in some districts where
   there is available resource, is to proceed directly with whole body PET-CT
   rather than CT chest.")
  REVIEW Q16 - This bullet names "Secondary care clinician or Radiologist" (no
  PCRL) and a staging CT "chest/liver", so it is its own advice indicator, not
  advice.urgentImagingRecommended. Footnote *4 explains the HealthPathway
  condition and gates nothing itself.
*/
define "Staging CT Advised": "Bool"('advice.urgentStagingCtRecommended')

define "Local HealthPathway Advises CT": "Bool"('advice.localHealthPathwayAdvisesCt')

define "Pathway P2.5: Staging CT Chest/Liver Advised":
  "Staging CT Advised" and "Local HealthPathway Advises CT"

// ---------------------------------------------------------------------------
// P2 bullet 6 - specialist / PCRL / radiologist advises urgent CT chest
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P2 Urgent, bullet 6):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or
   radiologist advises referral for urgent CT chest"
*/
define "Pathway P2.6: Specialist Advises Urgent CT Chest":
  "Bool"('advice.urgentImagingRecommended')

// ---------------------------------------------------------------------------
// P2 Urgent determination
// ---------------------------------------------------------------------------

/*
  SOURCE (p13, Timeframe column): "P2 Urgent: non-deferrable imaging or
   intervention that must be completed within 2 weeks of receiving referral."
  The six bullets (p14) are separate presentations: any one qualifies.
*/
define "Any P2 Pathway":
  "Pathway P2.1: Unexplained Haemoptysis"
    or "Pathway P2.2: Over 55 Current Smoker With Concerning Symptoms"
    or "Pathway P2.3: Indeterminate Chest X-ray Abnormality"
    or "Pathway P2.4: Persistent Consolidation"
    or "Pathway P2.5: Staging CT Chest/Liver Advised"
    or "Pathway P2.6: Specialist Advises Urgent CT Chest"

define "Meets P2 Criteria":
  "Is Adult" and "Any P2 Pathway"

// ---------------------------------------------------------------------------
// P3 bullet 1 - isolated pulmonary nodule on chest x-ray
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P3, bullet 1):
  "Isolated, pulmonary nodule identified on a chest x-ray and cannot be confirmed
   as benign from x-ray appearances alone AND referral for CT chest is
   recommended in the Radiology report"

  REVIEW Q7 - An isolated nodule that cannot be confirmed benign could also be
  described as an "indeterminate abnormality ... which raises the possibility of
  a lung cancer" (P2 bullet 3). Encoded as printed: the two are separate
  indicators, so a nodule reaches P2 only if the indeterminate-abnormality
  indicator is also answered true.
*/
define "Isolated Pulmonary Nodule On Chest X-ray": "Bool"('workup.cxrIsolatedPulmonaryNodule')

define "Nodule Not Confirmed Benign On Chest X-ray": "Bool"('workup.cxrNoduleNotConfirmedBenign')

define "Pathway P3.1: Isolated Pulmonary Nodule":
  "Isolated Pulmonary Nodule On Chest X-ray"
    and "Nodule Not Confirmed Benign On Chest X-ray"
    and "Radiology Report Recommends CT Chest"

// ---------------------------------------------------------------------------
// P3 bullet 2 - specialist / PCRL / radiologist advises non-urgent CT chest
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, P3, bullet 2):
  "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or
   radiologist advises referral for non-urgent CT chest"
*/
define "Pathway P3.2: Specialist Advises Non-urgent CT Chest":
  "Bool"('advice.nonUrgentImagingRecommended')

// ---------------------------------------------------------------------------
// P3 determination
// ---------------------------------------------------------------------------

/*
  SOURCE (p14, Timeframe column): "P3: non-deferrable, imaging or intervention
   that must be completed within 6 weeks of receiving referral"
*/
define "Any P3 Pathway":
  "Pathway P3.1: Isolated Pulmonary Nodule"
    or "Pathway P3.2: Specialist Advises Non-urgent CT Chest"

define "Meets P3 Criteria":
  "Is Adult" and "Any P3 Pathway"

// ---------------------------------------------------------------------------
// Alternative management / HealthPathway recommended (redirects)
// ---------------------------------------------------------------------------

/*
  SOURCE (p15, "Alternative management or HealthPathway recommended", bullet 1):
  "Patient re-presents with concerning symptoms or signs and chest x-ray is
   normal, but doesn’t meet the above criteria for CT chest referral – seek
   advice from secondary care respiratory team, regarding appropriate management
   and whether CT chest is warranted."

  REVIEW Q9 - "concerning symptoms or signs" carries no *1 marker here; it is
  read as the *1 list (the same phrase is marked *1 in the Guidance).
  "doesn’t meet the above criteria" is read as: an adult for whom no P2 or P3
  pathway is met on the information supplied (definitively false), so this
  redirect can never override a met criterion.
*/
define "Re-presentation": "Bool"('workup.rePresentation')

define "Chest X-ray Normal": "Bool"('workup.cxrNormal')

define "Above Criteria Definitively Not Met":
  "Is Adult" is true and "Any P2 Pathway" is false and "Any P3 Pathway" is false

define "Redirect: Re-presents With Normal Chest X-ray, Criteria Not Met":
  "Re-presentation"
    and "One Or More Concerning Symptoms Or Signs"
    and "Chest X-ray Normal"
    and "Above Criteria Definitively Not Met"

/*
  SOURCE (p15, "Alternative management or HealthPathway recommended", bullet 2):
  "Persistent, non-specific, non-localising symptoms and signs which are
   concerning for underlying cancer (e.g. weight loss, fatigue) and initial
   investigations including chest x-ray and bloods fail to identify a cause. See
   CT Chest/Abdomen/Pelvis HealthPathway."

  REVIEW Q14 - "symptoms and signs which are concerning for underlying cancer"
  is the referrer's clinical impression; its indicator is proposed for the AD-17
  attestation category (the referrer answers it, the extraction model never does).
  REVIEW Q10 - Redirects take precedence over criteria (BRD TA-013, as CT CAP).
  A current smoker over 55 whose only *1 symptom is unexplained weight loss can
  meet P2 bullet 2 and this redirect at once; encoded as printed, the redirect
  wins. Confirm.
  "(e.g. weight loss, fatigue)" is illustrative (KI-05).
*/
define "Non-specific Symptoms Concerning For Cancer": "Bool"('symptom.nonSpecificSymptomsConcerningForCancer')

define "Redirect: Non-specific Symptoms, Initial Investigations Negative":
  "Non-specific Symptoms Concerning For Cancer"
    and "Chest X-ray Done"
    and "Bloods Done"
    and "Initial Investigations Fail To Identify Cause"

/*
  SOURCE (p15, "Alternative management or HealthPathway recommended", bullet 3):
  "Initial presentation with respiratory symptoms or signs concerning for lung
   cancer - refer for urgent chest x-ray as the initial investigation."

  REVIEW Q8 - NOT EVALUATED. Read literally ("initial presentation"), and with
  redirects taking precedence, this bullet would redirect a first-presentation
  patient whose chest x-ray is already done and abnormal (e.g. P2 bullet 3). The
  instruction ("refer for urgent chest x-ray as the initial investigation")
  suggests "chest x-ray not yet done", but that is not what is printed, and which
  *1 items count as "respiratory" is not stated. No define; the PlanDefinition
  shows the bullet as published wording only.
*/

/*
  SOURCE (p15, "Alternative management or HealthPathway recommended", bullet 4):
  "Follow-up of nodule discovered incidentally on CT chest scan - refer to
   secondary care for management advice unless radiology report confirms benign
   based on CT appearance and no follow-up is required (e.g. intrapulmonary lymph
   node, benign pattern of calcification)."

  REVIEW Q11 - The redirect applies unless the report confirms benign AND no
  follow-up is required; an unanswered benign-confirmation does not stop the
  redirect ("unless" makes referral to secondary care the default). Where the
  report does confirm benign, no criterion here asks for CT either.
*/
define "Incidental CT Nodule Follow-up": "Bool"('workup.ctIncidentalNoduleFollowUp')

define "Report Confirms Benign, No Follow-up Required": "Bool"('workup.ctNoduleReportConfirmsBenign')

define "Redirect: Follow-up Of Incidental CT Nodule":
  "Incidental CT Nodule Follow-up" is true
    and "Report Confirms Benign, No Follow-up Required" is not true

define "Active Redirects":
  (List<String>{
    if "Redirect: Re-presents With Normal Chest X-ray, Criteria Not Met" is true then 'Patient re-presents with concerning symptoms or signs and chest x-ray is normal, but doesn’t meet the above criteria for CT chest referral – seek advice from secondary care respiratory team, regarding appropriate management and whether CT chest is warranted.' else null,
    if "Redirect: Non-specific Symptoms, Initial Investigations Negative" is true then 'Persistent, non-specific, non-localising symptoms and signs which are concerning for underlying cancer (e.g. weight loss, fatigue) and initial investigations including chest x-ray and bloods fail to identify a cause. See CT Chest/Abdomen/Pelvis HealthPathway.' else null,
    if "Redirect: Follow-up Of Incidental CT Nodule" is true then 'Follow-up of nodule discovered incidentally on CT chest scan - refer to secondary care for management advice unless radiology report confirms benign based on CT appearance and no follow-up is required (e.g. intrapulmonary lymph node, benign pattern of calcification).' else null
  }) R where R is not null

define "Alternative Management Recommended": exists "Active Redirects"

/*
  Absence of information about a redirect does not block a referral; the
  redirect triggers that are unanswered are surfaced for the triager. The
  re-presentation redirect only applies once the criteria are definitively not
  met, so its unanswered components are listed only then.
*/
define "Unconfirmed Redirect Triggers":
  (List<String>{
    if "Non-specific Symptoms Concerning For Cancer" is null then 'symptom.nonSpecificSymptomsConcerningForCancer' else null,
    if "Incidental CT Nodule Follow-up" is null then 'workup.ctIncidentalNoduleFollowUp' else null
  }) R where R is not null

define "Unconfirmed Re-presentation Components":
  if "Above Criteria Definitively Not Met"
    and "Redirect: Re-presents With Normal Chest X-ray, Criteria Not Met" is null
  then ((List<String>{
      if "Re-presentation" is null then 'workup.rePresentation' else null,
      if "Chest X-ray Normal" is null then 'workup.cxrNormal' else null
    }) C where C is not null)
    union (if "One Or More Concerning Symptoms Or Signs" is null then "Unanswered Concerning Symptom LinkIds" else {} as List<String>)
  else {} as List<String>

define "Unconfirmed Exclusions":
  "Unconfirmed Redirect Triggers" union "Unconfirmed Re-presentation Components"

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  Precedence (as CT CAP; no not-funded row exists for this section):
    1. Alternative management / redirect (BRD TA-013: redirect wins over criteria; REVIEW Q10)
    2. Paediatric patient - the adult criteria do not apply (REVIEW Q13)
    3. P2 criteria met
    4. P3 criteria met (REVIEW Q15: also when P2 is still indeterminate)
    5. P2 and P3 criteria definitively not met
    6. Insufficient information
  The national red flags (RF-01, RF-02 for this section) are evaluated by
  CRR_RedFlags before this library runs.
*/
define "Determination":
  case
    when "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT'
    when "Is Adult" is false then 'PAEDIATRIC_CRITERIA_APPLY'
    when "Meets P2 Criteria" is true then 'P2_URGENT'
    when "Meets P3 Criteria" is true then 'P3_NON_DEFERRABLE'
    when "Meets P2 Criteria" is false and "Meets P3 Criteria" is false then 'CRITERIA_NOT_MET'
    else 'INSUFFICIENT_INFORMATION'
  end

define "Priority Code":
  case "Determination"
    when 'P2_URGENT' then 'P2'
    when 'P3_NON_DEFERRABLE' then 'P3'
    else null as String
  end

/*
  SOURCE (p13): "must be completed within 2 weeks of receiving referral."
  SOURCE (p14): "must be completed within 6 weeks of receiving referral"
*/
define "Priority Timeframe":
  case "Determination"
    when 'P2_URGENT' then 'Complete within 2 weeks of receiving referral'
    when 'P3_NON_DEFERRABLE' then 'Complete within 6 weeks of receiving referral'
    else null as String
  end

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

/*
  Only pathways that are still undetermined (null) contribute: a pathway already
  definitively false cannot be rescued by more information, and its unanswered
  components are not asked for.
*/
define "Missing Age":
  if "Age In Years" is null then { 'patient.age' } else {} as List<String>

define "Missing P2.1":
  if "Pathway P2.1: Unexplained Haemoptysis" is null then (List<String>{
    if "Haemoptysis" is null then 'redflag.haemoptysisPresent' else null,
    if "Haemoptysis In Absence Of Chest Infection" is null then 'symptom.haemoptysisWithoutChestInfection' else null,
    if "Upper Respiratory Tract Causes Excluded" is null then 'workup.upperAirwayBleedingExcluded' else null,
    if "Chest X-ray Done" is null then 'workup.cxr' else null,
    if "Initial Investigations Fail To Identify Cause" is null then 'workup.initialInvestigationsCauseNotFound' else null
  }) M where M is not null
  else {} as List<String>

define "Missing P2.2":
  if "Pathway P2.2: Over 55 Current Smoker With Concerning Symptoms" is null then ((List<String>{
    if "Current Smoker" is null then 'patient.currentSmoker' else null,
    if "Concerning Symptoms New Onset" is null then 'symptom.newOnset' else null,
    if "Persistent Six Weeks Despite Appropriate Treatment" is null then 'symptom.persistentSixWeeksDespiteTreatment' else null,
    if "Chest X-ray Done" is null then 'workup.cxr' else null,
    if "Bloods Done" is null then 'workup.bloods' else null,
    if "Initial Investigations Fail To Identify Cause" is null then 'workup.initialInvestigationsCauseNotFound' else null
  }) M where M is not null)
    union (if "One Or More Concerning Symptoms Or Signs" is null then "Unanswered Concerning Symptom LinkIds" else {} as List<String>)
  else {} as List<String>

define "Missing P2.3":
  if "Pathway P2.3: Indeterminate Chest X-ray Abnormality" is null then (List<String>{
    if "Indeterminate Chest X-ray Abnormality" is null then 'workup.cxrIndeterminateAbnormality' else null,
    if "Radiology Report Recommends CT Chest" is null then 'workup.radiologyReportRecommendsImaging' else null
  }) M where M is not null
  else {} as List<String>

define "Missing P2.4":
  if "Pathway P2.4: Persistent Consolidation" is null then (List<String>{
    if "Persistent Consolidation On 6-Week Follow-up Chest X-ray" is null then 'workup.cxrPersistentConsolidationFollowUp' else null,
    if "Radiology Report Recommends CT Chest" is null then 'workup.radiologyReportRecommendsImaging' else null
  }) M where M is not null
  else {} as List<String>

define "Missing P2.5":
  if "Pathway P2.5: Staging CT Chest/Liver Advised" is null then (List<String>{
    if "Staging CT Advised" is null then 'advice.urgentStagingCtRecommended' else null,
    if "Local HealthPathway Advises CT" is null then 'advice.localHealthPathwayAdvisesCt' else null
  }) M where M is not null
  else {} as List<String>

define "Missing P2.6":
  if "Pathway P2.6: Specialist Advises Urgent CT Chest" is null then { 'advice.urgentImagingRecommended' }
  else {} as List<String>

define "Missing P3.1":
  if "Pathway P3.1: Isolated Pulmonary Nodule" is null then (List<String>{
    if "Isolated Pulmonary Nodule On Chest X-ray" is null then 'workup.cxrIsolatedPulmonaryNodule' else null,
    if "Nodule Not Confirmed Benign On Chest X-ray" is null then 'workup.cxrNoduleNotConfirmedBenign' else null,
    if "Radiology Report Recommends CT Chest" is null then 'workup.radiologyReportRecommendsImaging' else null
  }) M where M is not null
  else {} as List<String>

define "Missing P3.2":
  if "Pathway P3.2: Specialist Advises Non-urgent CT Chest" is null then { 'advice.nonUrgentImagingRecommended' }
  else {} as List<String>

define "Missing Advice Indicators":
  if ("Pathway P2.5: Staging CT Chest/Liver Advised" is true
      or "Pathway P2.6: Specialist Advises Urgent CT Chest" is true
      or "Pathway P3.2: Specialist Advises Non-urgent CT Chest" is true)
    and not "Adviser Name And Role Documented"
  then { 'advice.adviserNameRole' }
  else {} as List<String>

define "Missing Information":
  if "Determination" in { 'P2_URGENT', 'P3_NON_DEFERRABLE', 'ALTERNATIVE_MANAGEMENT' }
    then "Missing Advice Indicators"
  else if "Determination" = 'PAEDIATRIC_CRITERIA_APPLY'
    then {} as List<String>
  else "Missing Age"
    union "Missing P2.1" union "Missing P2.2" union "Missing P2.3"
    union "Missing P2.4" union "Missing P2.5" union "Missing P2.6"
    union "Missing P3.1" union "Missing P3.2"
    union "Missing Advice Indicators"

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds":
  {
    'patient.age', 'patient.currentSmoker',
    'redflag.haemoptysisPresent', 'symptom.haemoptysisWithoutChestInfection',
    'workup.upperAirwayBleedingExcluded', 'workup.cxr', 'workup.bloods',
    'workup.initialInvestigationsCauseNotFound',
    'symptom.newOnset', 'symptom.persistentSixWeeksDespiteTreatment',
    'workup.cxrIndeterminateAbnormality', 'workup.cxrPersistentConsolidationFollowUp',
    'workup.radiologyReportRecommendsImaging',
    'advice.urgentStagingCtRecommended', 'advice.localHealthPathwayAdvisesCt',
    'advice.urgentImagingRecommended', 'advice.nonUrgentImagingRecommended', 'advice.adviserNameRole',
    'workup.cxrIsolatedPulmonaryNodule', 'workup.cxrNoduleNotConfirmedBenign',
    'workup.rePresentation', 'workup.cxrNormal',
    'symptom.nonSpecificSymptomsConcerningForCancer',
    'workup.ctIncidentalNoduleFollowUp', 'workup.ctNoduleReportConfirmsBenign'
  }
  union "Concerning Symptom LinkIds"

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
    pathwayP2_1: "Pathway P2.1: Unexplained Haemoptysis",
    agedOver55: "Aged Over 55",
    currentSmoker: "Current Smoker",
    concerningSymptomCount: "Concerning Symptom Count",
    unknownConcerningSymptomCount: "Unknown Concerning Symptom Count",
    oneOrMoreConcerningSymptoms: "One Or More Concerning Symptoms Or Signs",
    pathwayP2_2: "Pathway P2.2: Over 55 Current Smoker With Concerning Symptoms",
    pathwayP2_3: "Pathway P2.3: Indeterminate Chest X-ray Abnormality",
    pathwayP2_4: "Pathway P2.4: Persistent Consolidation",
    pathwayP2_5: "Pathway P2.5: Staging CT Chest/Liver Advised",
    pathwayP2_6: "Pathway P2.6: Specialist Advises Urgent CT Chest",
    meetsP2: "Meets P2 Criteria",
    pathwayP3_1: "Pathway P3.1: Isolated Pulmonary Nodule",
    pathwayP3_2: "Pathway P3.2: Specialist Advises Non-urgent CT Chest",
    meetsP3: "Meets P3 Criteria",
    redirectRePresentation: "Redirect: Re-presents With Normal Chest X-ray, Criteria Not Met",
    redirectNonSpecificSymptoms: "Redirect: Non-specific Symptoms, Initial Investigations Negative",
    redirectIncidentalCTNodule: "Redirect: Follow-up Of Incidental CT Nodule",
    alternativeManagement: "Alternative Management Recommended",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'CT Chest - Adult',
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
