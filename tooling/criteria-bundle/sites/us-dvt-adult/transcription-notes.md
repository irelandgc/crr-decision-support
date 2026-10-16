# Transcription notes — US DVT - Adult (`us-dvt-adult`)

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf`, National ID 15372 v2.0, published 09/04/2026, section "US DVT - Adult", **pp.36–37** (US Guided FNA starts p38). Published exam/site id `us_dvt`; bundle key `us-dvt-adult`; library `CRR_USDVT_Adult`.

**Status:** W1 demo transcription for staging (AD-35, Gary 2026-10-15). Not clinically signed off. The most literal reading is encoded; every ambiguity is a REVIEW question (Q1–Q15, listed in `signoff.md` and the CQL header).

**PDF text extraction.** Both pages were re-extracted with `extract_text(extraction_mode="layout")` to confirm the table structure (which bullets belong to which timeframe row, and that the Wells sub-bullets sit under the Acute 48h bullet). The plain extraction was correct in content but split the Source column into the middle of the rows. Page 36's link annotations were also read: the "1" after each Wells sub-bullet is a link to `javascript:toggleReferenceDialog('ri1')` / `('ri1_2')`, a reference dialog from the web page the PDF was printed from, with no text in the PDF (REVIEW Q2). The layout extraction renders "D-dimer" as "D       -dimer" (a spacing artefact; the plain extraction and the published JSON both read "D-dimer").

## 1. Atoms

| # | Source sentence (verbatim, page) | Indicator | New? | Attestation (AD-17)? |
|---|---|---|---|---|
| 1 | "Superficial venous thrombosis affecting the proximal long saphenous vein in the thigh," (p36, Acute 24h, bullet 1) | `symptom.superficialVenousThrombosis` AND `symptom.svtProximalLongSaphenousVeinThigh` | new, new | no |
| 2 | "Clinically suspected upper limb DVT" (p36, Acute 24h, bullet 2) | `symptom.suspectedDvtUpperLimb` | new | no (Q13) |
| 3 | "Same day DVT US recommended by Health NZ Haematology service or other secondary care specialist" (p36, Acute 24h, bullet 3) | `advice.sameDayImagingRecommended` (+ `advice.adviserNameRole`, Overview p5) | new (Q11) | no |
| 4 | "Clinically suspected lower limb DVT and one or more of the following:" (p36, Acute 48h stem) | `symptom.suspectedDvtLowerLimb` | new | no (Q13) |
| 5 | "Well’s score of 2 or greater   1" (p36, Acute 48h, sub-bullet 1) | `workup.wellsScoreDvt` >= 2 | new (Q1, Q2) | no |
| 6 | "Well’s score less than 2 and positive D-dimer 1" (p36, Acute 48h, sub-bullet 2) | `workup.wellsScoreDvt` < 2 AND `lab.ddimer.positive` | —, new | no |
| 7 | "No DVT seen on initial ultrasound but where clinical suspicion remains high AND there is high likelihood on Well’s score (i.e. 2 or higher)." (p36, S1, bullet 1) | `imaging.usdvt.initialNegative` AND `workup.dvtClinicalSuspicionHigh` AND `workup.wellsScoreDvt` >= 2 | new, new, — | **yes**: `workup.dvtClinicalSuspicionHigh` |
| 8 | "Arrange the follow-up scan for 5 - 8 days after the initial scan." (p36, S1, bullet 1) | none — target date, not a condition (Q8) | | |
| 9 | "To check for proximal clot extension in a calf DVT not being treated with anticoagulation, between 5 - 8 days after initial scan." (p36, S1, bullet 2) | `symptom.calfDvt` AND NOT `history.anticoagulantTherapy`; purpose and timing not encoded (Q8, Q9) | new, new | no |
| 10 | "Secondary care clinician or Radiologist advises referral for follow up ultrasound DVT" (p36, S1, bullet 3) | `advice.followUpImagingRecommendedBySpecialist` (+ `advice.adviserNameRole`) | new (Q12) | no |
| 11 | "Follow up scan after anticoagulation therapy as recommended by secondary care specialist." (p36, S2) | `advice.postAnticoagulationScanRecommended` (+ `advice.adviserNameRole`) | new (Q5) | no |
| 12 | "Children aged younger than 15 years – see local DVT HealthPathway" (p36, alternative management) | `patient.age` < 15 | existing (addSite) | no |
| 13 | "Pregnant women – see local DVT HealthPathway." (p36, alternative management) | `patient.pregnant` | new | no |
| 14 | "Routine follow-up scanning to confirm clot resolution - this does not typically assist with decisions on duration of anticoagulation." (p37, not funded) | `funding.routineClotResolutionFollowUp`; the rationale after the dash is not encoded | new | no |
| 15 | "Superficial venous thrombosis, unless affecting the proximal long saphenous vein in the thigh" (p37, not funded) | `symptom.superficialVenousThrombosis` true AND `symptom.svtProximalLongSaphenousVeinThigh` false (same two indicators as atom 1, KI-01) | — | no |
| 16 | Overview p5: "If the referral was discussed with and endorsed by any secondary care clinician, radiologist, or primary care radiology liaison, always include the name and role of that person in the referral." | `advice.adviserNameRole` (asked when any advice indicator is true) | existing (addSite) | no |

Timeframe rows, verbatim (p36): "Acute:  Within 24 hours" (two spaces, as printed), "Acute: Within 48 hours", "S1: Time sensitive imaging that must be completed within 1 week of a specified target date.", "S2: Time sensitive imaging that must be completed within 2 weeks of a specified target date."

Source column (p36) → `PlanDefinition.relatedArtifact` citations: "HealthPathways"; "Well’s Criteria for DVT (mdcalc.com)" (link https://www.mdcalc.com/calc/362/wells-criteria-dvt); "HealthNZ Haematologist advice (E. Merriman, L. Young, O’Keefe)"; "Recommendations | Venous thromboembolic diseases: diagnosis, management and thrombophilia testing | Guidance | NICE" (link NICE NG158). These names are printed in the published national document. Referrers: "GP & UC Doctors / NPs" → `useContext`.

## 2. Vocabulary

`vocabulary-additions.json` holds 15 additions, 2 `addSite` entries (`patient.age` p36, `advice.adviserNameRole` p36) and one key the brief's format does not name: **`addAttestationIndicators: ["workup.dvtClinicalSuspicionHigh"]`**, to append to the top-level `attestationIndicators` array (AD-17). That entry carries `attestationWording` (AD-23) so `check` passes. The same changes are applied to `vocabulary/indicators.json` in this worktree so the gates run.

Searched for near-duplicates before adding (KI-01):
- `advice.acuteImagingRecommended` ("secondary care clinician, PCRL or radiologist advises referral for a same or next day scan") was considered for atom 3 and **not reused**: different adviser set and "same day" versus "same or next day". Reusing it would widen Acute 24h (Q11). Precedent the other way: vocabulary REVIEW Q25 folded "acute" into "same or next day".
- `advice.nonUrgentImagingRecommended` / `advice.urgentImagingRecommended` do not fit the S1 follow-up gateway. A follow-up gateway also appears at X-ray Abdomen p61 ("… or Primary Care Radiology Liaison or radiologist advises referral for follow-up x-ray") and US Pelvis ("… advises referral for time-sensitive, specified date, follow-up ultrasound of the pelvis"). `advice.followUpImagingRecommendedBySpecialist` is named for that shared concept but worded as US DVT prints it (no PCRL). A parallel W1 session (US Pelvis) may propose a PCRL-inclusive version; converge centrally (Q12).
- `history.anticoagulantTherapy`: CT Head (pp.20–21, "Anticoagulant therapy", "On anticoagulants") and US Carotid (p34, "is not taking anticoagulants") print the same concept. Not attributed (not read in full). There is no medication group; `patient` is the nearest existing group. A parallel CT Head session may choose another name; converge centrally.
- `patient.pregnant`: also printed at CT KUB p26, US Renal p52, US Pelvis p45 (parallel W1 sessions likely to need it). Not attributed.
- `imaging.usdvt.initialNegative` does not follow `imaging.<examSlug>.<window>`: it records a result, not an interval. Vocabulary-owner question.
- `lab.ddimer.positive`: boolean flag, no `.value` (no numeric threshold printed, KI-06/KI-13).
- `workup.wellsScoreDvt`: integer (the score can be negative). There is no `score` group, so it sits under `workup`.

## 3. Modelling decisions

- **Outcome codes.** `ACUTE_24H`, `ACUTE_48H`, `S1_TIME_SENSITIVE`, `S2_TIME_SENSITIVE`, with `Priority Code` A24 / A48 / S1 / S2 (and the same codes on the PlanDefinition `priority-code` codings). The determination codes leave out the S-code on purpose: `advisory-render.js` turns any determination it has no mapping for into words (`humanizeCode`) in the **referrer** view, so `S1_…` would show a priority code to referrers. Other W1 sites with Acute or S-rows need the same convention; converge centrally.
- **Precedence (Q3):** redirect > Acute 24h > Acute 48h > S1 > S2 > not routinely funded > criteria not met > insufficient. "Highest priority wins" is from `documents/reference/crr-business-rules.md` Rule 2.2 and prompt decomposition item 22.
- **Overlaps encoded literally, highest wins:** S1 bullet 1 and Acute 48h (Q4); S1 bullet 3 and S2 (Q5); S2 and not-funded routine follow-up (Q6). No exclusion that is not printed was added to make S1 bullet 1 or S2 reachable.
- **Not-funded items** are read with `is true` / `is false` (an unknown does not assert a not-funded scenario). SVT with unknown location gives insufficient information and asks for the location (S30).
- **Redirects:** unknown age or pregnancy status does not block; they are listed in `Unconfirmed Exclusions` (`patient.age`, `patient.pregnant`). Pregnancy is listed as unconfirmed whatever the patient's sex (no sex logic was added).
- **Missing information:** every unanswered criterion atom, except a dependent atom whose parent is known false (SVT location, Wells, D-dimer, suspicion, anticoagulation). When a priority, redirect or not-funded outcome is reached, only `advice.adviserNameRole` can be missing (CT CAP pattern).
- **Three-valued consequence:** `CRITERIA_NOT_MET` needs every one of the eight criterion bullets known false. A note that addresses only the lower limb pathway (for example "?DVT, Wells 1, D-dimer negative") without saying "no" to the others returns insufficient information and lists them. This is the architecture's deliberate behaviour (CT CAP has the same shape with its B3 advice), but with eight bullets it is more visible here.
- **Indication themes** (check rule 7b) from `instructions/archive/indication-groupings.md` §US DVT: Superficial venous thrombosis; Suspected upper limb DVT; Suspected lower limb DVT; DVT follow-up (S1 bullets 1–2, S2); Specialist-endorsed referral (Acute 24h bullet 3, S1 bullet 3, which that table does not list).
- **PlanDefinition titles** are verbatim, including the trailing comma on Acute 24h bullet 1 and the "S1:" / "S2:" prefixes. The printed Wells "1" markers are left out of the titles (Q2).
- **HealthPathways:** page ID `TBC-page-id` (Q15).

## 4. Not encoded

- The 5–8 day timing in S1 bullets 1 and 2: a target date, not a condition (Q8).
- "To check for proximal clot extension": the purpose of the S1 bullet 2 scan (Q9).
- "this does not typically assist with decisions on duration of anticoagulation" (p37): the rationale for not funding, with the modifier "typically" (KI-05).
- The Wells score's components: not defined in the PDF; no computation (Q1, as the brief instructs).
- No national red flags appear in this section (vocabulary notes §1: US DVT has no acute-assessment row); none re-encoded.
- No age gate other than the printed "younger than 15" redirect (Q7). No sex logic.
- `population.cql`: **not done.** D-dimer and prior US results could in principle be retrieved, but `run-tests-sites.mjs` does not support record-backed scenarios yet, and nothing here needs history logic to evaluate the printed criteria.

## 5. Source versus published JSON (`documents/reference/pdf-criteria-all.json`, `us_dvt`)

Reported only; nothing was resolved by preferring the JSON.

| # | Difference |
|---|---|
| J1 | The JSON flattens Acute 48h into one item `usdvt_48_1`, with the two Wells options joined by ";" and the stray "1" markers kept ("… 2 or greater 1; … D-dimer 1"). The bundle nests them as stem AND (option 1 OR option 2). Census `instructions/archive/compound-criteria-phase0-findings.md` row 32 classifies it as C(1+2), and B.2 records Gary's confirmation (5 July 2026) that "Wells<2 + positive D-dimer" is one qualifying option. Row 33 classifies `usdvt_s1_1` as A(3), which matches the three atoms of S1 bullet 1. |
| J2 | `outOfCriteriaNote` paraphrases the not-funded row ("routine post-treatment follow-up to confirm clot resolution, superficial venous thrombosis (except proximal long saphenous vein in thigh)"). `notFundedDetail` is verbatim. The bundle uses the PDF wording. |
| J3 | `healthPathwaysUrl` is an Auckland-instance link (page 32358). The PDF Source column says only "HealthPathways" (Q15). |
| J4 | The JSON carries none of the Source-column citations (mdcalc, Haematologist advice, NICE). |
| J5 | Every criterion label is otherwise verbatim to the PDF, including the trailing comma in `usdvt_24_1`. |
| J6 | `instructions/archive/indication-groupings.md` uses item ids `usd_*`, not the JSON's `usdvt_*`. It lists two Acute 48h items (`usd_48_1`, `usd_48_2`), where the JSON has one, and it has no row for S1 bullet 3. |

## 6. Matrix cases and worked examples

- `documents/CRR_Test_Case_Results_Matrix_v2.xlsx` (all four sheets: Test Case Results, Michaela Model Comparison, Structured Re-Eval, Corrections Log) has **no US DVT case**. The only DVT mention is **MW-004**, a **US Pelvis** case ("unilateral leg swelling. Normal D-dimer. Nil signs of DVT."; evaluator expected Declined for US Pelvis). It is not a case for this site, so it is not encoded.
- No STEP-3 worked example in `instructions/arch-mig-prompt-decomposition.md` applies to US DVT. Item 18's lab-requirements table names "DVT: Wells/D-dimer", which is atoms 5–6.

## 7. Adjacent problems found (flagged, not fixed — outside this brief)

1. **`public/crr-criteria/shared/criteria-render.js`** removes a priority code from a timeframe title only when it matches `/^P[1-4]…/` (line ~288). This bundle's verbatim titles "S1: Time sensitive …" and "S2: …" would therefore show the S-code to referrers in the Criteria Viewer. That breaks the CLAUDE.md rule that priority codes never appear in referrer-facing UI. It affects every S-coded site, so it needs fixing before referrers see any S-coded bundle, staging demo included.
2. **`public/crr-criteria/api/engine.ts` `isPriorityDetermination`** matches only `/^P\d/`, so Acute and S-row determinations do not trigger the cross-exam recommendation.
3. **`public/crr-criteria/shared/advisory-render.js` `DETERMINATION_TO_DEFINE`** maps only `P2_URGENT`, so this site's met outcomes fall back to humanised codes ("Acute within 24 hours") rather than the PlanDefinition row wording.

## 8. Build gates

`npm run build` compiles `CRR_USDVT_Adult` (61 definitions). `npm test` runs 33 scenarios, all passing (`results.md`, generated). `npm run check` applies rule 14 to this site.
