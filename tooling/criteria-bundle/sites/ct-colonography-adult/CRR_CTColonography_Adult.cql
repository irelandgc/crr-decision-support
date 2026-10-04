/*
  CRR Community Referral Criteria for Imaging
  CT Colonography - Adult

  SOURCE DOCUMENT
    Title:      CT Colonography and CT AP community referred criteria - final draft
    File:       documents/reference/CURRENT CT Colonography and CT AP community
                referred criteria final draft Updated 270826.docx
    Date:       Updated 27/08/2026 (approved draft; supersedes the CT Colonography
                section of National ID 15372 v2.0, pp.17-19)
    Section:    CT Colonography - Adult
    Reading:    tracked changes accepted (REVIEW Q3)

  PROVENANCE CONVENTION
    Every clinical define below carries a "SOURCE:" comment quoting the draft
    wording verbatim. A define with no SOURCE comment is engineering plumbing,
    not a clinical rule. Review is a side-by-side check of each SOURCE quote
    against the define beneath it.

  WHAT THIS SECTION IS
    The draft removes every CT Colonography criterion row. What remains is a
    Guidance block: direct access is being removed and referrals go through a
    single point of referral. There are no indicators to answer, so the
    Questionnaire has no items and every request returns the same outcome:
    alternative management (AD-33).

  INPUT CONTRACT
    The library evaluates a FHIR R4 QuestionnaireResponse. The CT Colonography
    Questionnaire has no items; answers from other exam/sites' Questionnaires
    in the same response are ignored.

  CLINICAL REVIEW FLAGS
    Points where the draft wording is ambiguous are marked "REVIEW Qn" and
    listed in transcription-notes.md and signoff.md.
*/

library CRR_CTColonography_Adult version '1.0.0'

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

define function "CodeValue"(linkId String):
  if "Is Accepted"(linkId) then FHIRHelpers.ToCode("Answer"(linkId).value as FHIR.Coding).code else null

// ---------------------------------------------------------------------------
// Alternative management (the whole section)
// ---------------------------------------------------------------------------

/*
  SOURCE (draft 27/08/2026, CT Colonography - Adult, Guidance):
  "Following the introduction of faecal immune-chemical testing (FIT) for
   symptomatic patients, direct access for CT Colonography (CTC) is being
   removed as a first line investigation."
  "Primary care referrals for all lower GI investigations including CTC and
   Colonoscopy will be via a single point of referral and triage as outlined in
   the guidance."
  "Please follow the Colorectal Symptoms HealthPathway for local guidance and
   follow local processes ."

  REVIEW Q1 - "is being removed" (a tracked change from "has been removed")
  describes removal in progress. This define is unconditionally true: every
  CT Colonography request is redirected, i.e. direct access is treated as
  already closed. Confirm.
  REVIEW Q2 - The draft prints no timeframe row and no "Alternative management"
  heading for this section. The bundle presents the Guidance block as the
  alternative-management outcome: the "single point of referral" sentence is the
  outcome wording and the HealthPathway sentence is the redirect. Both are
  verbatim. Confirm.
*/
define "Alternative Management Recommended": true

define "Active Redirects":
  { 'Please follow the Colorectal Symptoms HealthPathway for local guidance and follow local processes .' }

define "Unconfirmed Exclusions": {} as List<String>

// ---------------------------------------------------------------------------
// Determination
// ---------------------------------------------------------------------------

/*
  No criteria, no not-funded row and no age band are printed for this section,
  so the only reachable outcome is alternative management (REVIEW Q5: no age
  gate).
*/
define "Determination":
  if "Alternative Management Recommended" then 'ALTERNATIVE_MANAGEMENT' else null

define "Priority Code": null as String

define "Priority Timeframe": null as String

// ---------------------------------------------------------------------------
// Missing information (referrer checklist)
// ---------------------------------------------------------------------------

define "Missing Information": {} as List<String>

// ---------------------------------------------------------------------------
// Grounding audit - which accepted indicators were inferred rather than documented
// ---------------------------------------------------------------------------

define "All Indicator LinkIds": {} as List<String>

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
    alternativeManagement: "Alternative Management Recommended",
    documentationStandard: "Documentation Standard"
  }

// ---------------------------------------------------------------------------
// Advisory output (single object for the tools to render)
// ---------------------------------------------------------------------------

define "Advisory":
  Tuple {
    exam: 'CT Colonography - Adult',
    criteriaVersion: 'Final draft, updated 27/08/2026',
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
