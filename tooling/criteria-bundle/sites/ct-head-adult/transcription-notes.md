# Transcription notes — CT Head - Adult (`ct-head-adult`)

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf` (National ID 15372 v2.0, published 09/04/2026), CT Head - Adult, pp.20–22. Footnote *1 starts on p21 and finishes on p22; *2–*4 are on p22. CT IVU starts p23. Published exam/site id: `ct_head` (bundle key `ct-head-adult`, `live = 0` in migration 0008).

**Status:** NOT CLINICALLY REVIEWED. Transcribed 2026-10-15 under Gary's W1 decision of the same day: publish to staging only as a demo bundle (AD-35). The most literal reading is encoded at every ambiguity, and each one is a REVIEW Qn in `signoff.md` and the CQL header. Nothing is left out of the logic for lack of a defensible literal reading (see §4).

**PDF text extraction:** the plain-text dump interleaved the Sources column with the criteria, moved the "Guidance: Transient Ischaemic Attack (TIA)" box to the foot of p20 (it sits at the top of the Acute row) and printed footnote superscripts inline ("low risk3", "intracranial pathology4"). Pages 20, 21 and 22 were re-extracted with `extraction_mode="layout"` to confirm the bullet nesting, the "OR" placement in the TIA bullet and the footnote lists. In layout mode the TIA bullet's second "o" (no high-risk features…) is indented further than the first and third; the two "OR" lines sit at the first and third bullets' level, so the three are read as alternatives at one level.

## 1. Atoms

AD-17 column: **A** = rests on the referrer's judgement (attestation candidate, REVIEW Q18). New = proposed in `vocabulary-additions.json`.

| Source wording (page) | Indicator | New? | AD-17 |
|---|---|---|---|
| "TIA" (p20) | `redflag.suspectedTIA` | reused (Q17) | |
| "within 7 days of the TIA episode" (p20) | `symptom.tiaDaysSinceEpisode` (decimal, ≤ 7.0, Q2) | new | |
| "CT +/-CTA recommended by HNZ neurologist / stroke specialist or physician." (p20) | `advice.strokeSpecialistRecommended` | new | |
| "Patient has no high-risk features *1" (p20) → *1 (p21–22) | composed from the seven *1 features below | — | |
| *1 "Less than 59 years old" | `patient.age` < 59 (Q1) | reused | |
| *1 "ABCD2 greater than 4" | `workup.abcd2Score` (integer) > 4 | new | |
| *1 "Crescendo TIAs" | `symptom.crescendoTIA` | new | |
| *1 "Atrial fibrillation" | `history.atrialFibrillation` | new | |
| *1 "On anticoagulants" | `history.anticoagulantTherapy` | new | |
| *1 "Severe or prolonged deficit (hemiparesis longer than 60 minutes)" | `symptom.tiaSevereOrProlongedDeficit` | new | |
| *1 "Known carotid artery stenosis." | `history.carotidStenosis` | new | |
| "assessed as suitable for being managed in the community" (p20) | `workup.suitableForCommunityManagement` | new | A |
| "completion of the BPAC TIA decision support tool indicates CT head +/- carotid imaging is appropriate" (p20) | `advice.decisionSupportToolCompleted` | reused | |
| "Patient is unable to access rapid specialist care." (p20) | `advice.rapidSpecialistCareAccessible` (negated) | reused | |
| "Focal neurologic signs" (p20); *2 "Presence of focal neurological signs" (p21, p22) | `symptom.focalNeurologicalSigns` (Q10) | new | |
| "Seizure in palliative care setting" (p20) | `symptom.seizure` (or `symptom.firstSeizure`) + `history.palliativeCare` | new | |
| "result may change management" (p20) | `workup.resultMayChangeManagement` | new | A |
| "advises referral for same or next day CT scan" (p20) | `advice.acuteImagingRecommended` | reused | |
| "A change in the pattern of headaches, with a progressive increase in frequency or severity" (p20) | `symptom.headachePatternChangeProgressive` | new | |
| "chronic illness associated with potential cerebral complications or involvement" (p20) | `history.chronicIllnessWithCerebralInvolvement` | new | |
| "exacerbated by coughing, sneezing, or Valsalva manoeuvre in a pattern not typical of a migraine" (p20) | `symptom.headacheWorseOnCoughSneezeValsalva` | new | |
| "associated with persistent nausea and vomiting (i.e. not typical of a migraine or other primary headache)" (p20) | `symptom.headachePersistentNauseaVomiting` (Q11) | new | |
| "objective neurological deficit causing disturbances of speech, or limb or facial weakness" (p20) | `symptom.neuroDeficitSpeechOrWeakness` (Q10) | new | |
| "Cognitive impairment" (p20, p21) | `symptom.cognitiveImpairment` | new | |
| *2 "Rapid cognitive decline over weeks" | `symptom.rapidCognitiveDecline` | new | |
| *2 "History of falls" | `history.falls` | new | |
| *2 "Anticoagulant therapy" | `history.anticoagulantTherapy` | new (shared with *1) | |
| *2 "Gait ataxia or incontinence." | `symptom.gaitAtaxia` OR `redflag.bowelOrBladderIncontinence` (Q9) | new / reused | |
| *2 "History of cancers with propensity to brain metastases – lung, melanoma, breast" | `history.cancerWithBrainMetastasisPropensity` (Q7) | new | |
| "First seizure" (p21) | `symptom.firstSeizure` | new | |
| "aged 21 years or older" (p21) | `patient.age` ≥ 21 | reused | |
| "clear history" (p21) | `symptom.seizureClearHistory` | new | A |
| "MRI (preferred first-line investigation) is not available" (p21) | `advice.mriAvailable` (negated) | new | |
| *3 "Single seizure" | `symptom.seizureSingle` | new | |
| *3 "which is unprovoked, or provoked by a known substance (e.g. drug or alcohol use)" | `symptom.seizureUnprovokedOrSubstanceProvoked` | new | |
| *3 "Patient has since returned to normal health" | `symptom.returnedToNormalHealth` | new | |
| *3/*4 "Head injury" | `history.headInjury` | new | |
| *3/*4 "Aged older than 40" | `patient.age` > 40 | reused | |
| *3/*4 "Fever, systemic symptoms" | `symptom.fever` OR `symptom.systemicSymptoms` (Q8) | reused / new | |
| *3/*4 "History of anticoagulation, malignancy" | `history.anticoagulation` (or current therapy) OR `history.malignancy` (or cancer with brain-metastasis propensity) (Q6, Q8) | new | |
| *3/*4 "New focal neurologic deficit" | `symptom.newFocalNeurologicalDeficit` (Q10) | new | |
| *3/*4 "Focal seizure" | `symptom.seizureFocal` | new | |
| *3/*4 "Persistent altered mental state" | `symptom.persistentAlteredMentalState` | new | |
| *3/*4 "Persistent headache" | `symptom.headachePersistent` | new | |
| "advises referral for urgent CT scan" (p21) | `advice.urgentImagingRecommended` | reused | |
| "establishing the subtype diagnosis will alter management" (P4, p21) / "establishing the subtype will not alter management" (not funded, p21) | `workup.subtypeDiagnosisAltersManagement` (both polarities, KI-01) | new | A |
| "advises referral for non-urgent, CT scan" (p21) | `advice.nonUrgentImagingRecommended` | reused | |
| "Suspected Prolactinoma" (p21) | `symptom.suspectedProlactinoma` | new | |
| "Seizures with risk factors for intracranial pathology4" (p21) | seizure present AND any *4 risk factor (Q12) | — | |
| "Poorly controlled or recurrent seizures" (p21) | `symptom.seizuresPoorlyControlledOrRecurrent` | new | |
| "Established, advanced dementia" (p21) | `history.dementiaEstablishedAdvanced` | new | |
| "of more than 2 years duration" (p21) | `history.dementiaDurationYears` (decimal, > 2.0, Q13) | new | |
| "no unexpected change in disease progression" (p21) | `symptom.dementiaUnexpectedChange` (negated) | new | |
| Overview p5 "always include the name and role of that person" | `advice.adviserNameRole` | reused | |
| Overview p4 adult band (over 15) | `patient.age` > 15 | reused | |

**Vocabulary:** 43 additions (one new group, `history`, declared in the additions file's `addGroup` because the `indicators.json` `groups` map needs it) and 2 `addSite` entries (`symptom.fever` p22, `redflag.bowelOrBladderIncontinence` p21–22). Seven reused indicators already list `ct-head-adult`; `advice.adviserNameRole` stays attributed to Overview p5 (as for CT CAP). linkIds name the clinical concept; candidates for convergence with US Carotid (p34): `advice.strokeSpecialistRecommended`, `symptom.tiaDaysSinceEpisode`, `history.anticoagulantTherapy`, `history.atrialFibrillation`, `workup.suitableForCommunityManagement`.

## 2. Modelling decisions

- **Timeframes.** Three indication blocks, named per AD-36: `Meets Acute 48h Criteria` (`ACUTE_48H`, priority code `A48`), `Meets P2 Criteria` (`P2_URGENT`, `P2`), `Meets P4 Criteria` (`P4_DEFERRABLE`, `P4`). The most urgent timeframe met wins (Q5). Every tier requires an adult (over 15).
- **Precedence** (coordinator rule R1, 2026-10-16): alternative management → paediatric → Acute 48h → P2 → P4 → insufficient information while any timeframe row is undetermined → not routinely funded (only when every timeframe row is definitively not met) → criteria not met (Q4, Q20). The first transcription put not funded first, as CT CAP does; R1 moved it so the advanced-dementia row can never pre-empt a met or undetermined row (CTH-S36, S43, S44).
- **Shared indicators across tiers.** `symptom.focalNeurologicalSigns` is both an Acute criterion and a *2 feature, so cognitive impairment with focal signs lands in Acute (CTH-S22). `workup.subtypeDiagnosisAltersManagement` makes P4 cognitive and the not-funded row mutually exclusive.
- **Definitional implications** (not clinical inference): current anticoagulant therapy satisfies "history of anticoagulation"; a cancer with brain-metastasis propensity satisfies "history of malignancy"; a first seizure is a seizure.
- **First-seizure bullet** encoded as the union of its three printed clauses (Q3); the CQL keeps all three so a reviewer can read it against the text.
- **Redirects** are active only when known true. The seizure redirects are surfaced as unconfirmed exclusions only when a seizure is present; prolactinoma never (Q14). The "Poorly controlled or recurrent seizures" redirect string joins the four printed HealthPathway sub-bullets with "; " (one string per redirect in the Advisory); the PlanDefinition keeps them as four sub-actions.
- **Not funded** uses `Coalesce(…, false)` like CT CAP: it applies only when every part is known. The not-funded item has no `input`, so the Viewer cannot offer it as a tick (CLAUDE.md: not-funded items are never tickable).
- **Missing information.** A pathway's sub-indicators are asked for only once its presentation is known to be present; until then the presentation (stem) is asked for. Single-indicator pathways (focal signs, the three advice gateways) are their own stems. When a determination is reached, only the adviser name/role is asked for (CT CAP pattern).
- **Headache stem** is one indicator for "a change in the pattern of headaches, with a progressive increase in frequency or severity": "progressive headache" answers it (prompt decomposition rule 14, RP-004); "different to usual" does not state a progressive increase (DG-002).
- **Determination and priority codes** follow AD-36 (normalised at the W1 merge).
- **Viewer tick boxes (coordinator rule R2).** The Viewer renders a row's boolean input as a tick box that sends `true` (KI-65). Three PlanDefinition rows had inputs the CQL reads negated, so a tick would have recorded the opposite of the row wording; their inputs were removed from the PlanDefinition (CQL unchanged; the indicators stay in the Questionnaire for extraction and forms): `a-tia-r3` ("Patient is unable to access rapid specialist care" — `advice.rapidSpecialistCareAccessible`), `a-tia-r2-no-high-risk` ("Patient has no high-risk features *1" — the seven *1 features, each a high-risk feature when true), and `advice.mriAvailable` on `p2-first-seizure` ("MRI … is not available"). Effect: the Advisory's "what to add" no longer groups those linkIds under the TIA / first-seizure pathway headings.
- **Referrer-visible notes (rule R3).** The PlanDefinition carries no engineering notes: the REVIEW Q1/Q2/Q3/Q4/Q7/Q16 and KI-05 modifier notes that were `documentation.display` entries are recorded here and in `signoff.md` only. Remaining displays are published wording (footnotes *1–*4, Overview p5 adviser sentence).
- **Structural label.** One PlanDefinition title is a label, not printed wording, and says so: `a-tia-routes` ("One of the following (printed as three alternatives separated by \"OR\")"). The other decomposition rows (`a-tia-within-7d`, `a-tia-r2-no-high-risk`, `a-tia-r2-community`, `a-tia-r2-bpac`, the headache and cognitive sub-rows) use printed fragments.

## 3. Modifiers and wording deliberately not encoded

| Wording (page) | Why |
|---|---|
| "especially in patients aged 50 years and older" (p20) | KI-05 modifier; matrix RP-000 (CTH-RP-000b) |
| "especially malignancy. The most likely cancers to metastasise to the brain are lung, breast, and melanoma." (p20) | modifier and explanation; malignancy is named in the indicator's extraction hint as the main example |
| "consider seeking neurologist advice first" (p20) | advice, not a condition (Q16) |
| "(preferred first-line investigation)" (p21) | explanatory |
| "(e.g. drug or alcohol use)" (*3) | illustrates "known substance" |
| "Guidance: Transient Ischaemic Attack (TIA)" box (p20) | protocol guidance on adding CTA / carotid ultrasound; PlanDefinition `guidance` action only |
| "Epilepsy in Adults / Epilepsy in Women / First Seizure in Adults / Seizure in Palliative Care" (p21) | HealthPathway names in the redirect wording; not conditions |
| Sources column, "Referrers: GP & UC Doctors / NPs" | PlanDefinition `relatedArtifact` citations and `useContext` |

## 4. Not encoded

- Nothing clinical was left out of the logic: every printed criterion has a literal reading, recorded with its REVIEW Qn where the reading is uncertain.
- No national red flag is re-encoded. CT Head prints no "Refer for acute assessment" row; the thunderclap / SAH redirect of the legacy prompt has no source here (vocabulary finding F-01, matrix INT-SAH).
- `population.cql`: not done. No CT Head criterion depends on laboratory results or prior-imaging history, and `run-tests-sites.mjs` does not support record-backed scenarios.
- No terminology codes (all PLACEHOLDER, SR-11).

## 5. Source versus published JSON (`documents/reference/pdf-criteria-all.json`, `ct_head`)

- Item set matches the PDF: `cth_a48_1..4`, `cth_p2_1..4`, `cth_p4_1..2`, plus `alternativeManagement`, `notFundedDetail`, `footnotes`, `inlineGuidance` (TIA guidance, verbatim).
- `cth_p2_3` carries the same repeated clause as the PDF. The census (`instructions/archive/compound-criteria-phase0-findings.md`, data-quality list) called it JSON text corruption; the layout re-extraction shows the PDF itself prints it (Q3).
- `cth_p2_2` and `cth_p2_1` are run-on prose in the JSON (sub-bullet breaks lost; census finding); the PDF has sub-bullets.
- `outOfCriteriaNote` paraphrases the not-funded row (">2 years", "with no unexpected change … where subtype will not alter management"); `notFundedDetail` is verbatim. The bundle uses the PDF wording.
- `alternativeManagement` adds a full stop after "seek Neurology phone advice" and joins the pathway names with commas; the bundle uses the PDF wording.
- The JSON has no Sources column. Its `healthPathwaysUrl` (Auckland region, `page=15616.htm`) supplied the HealthPathways page ID in the PlanDefinition; not verified as common to all instances.
- `instructions/archive/indication-groupings.md` uses different item ids (`cth_a1..a4`) for the same rows; its themes (TIA / stroke, Headache, Cognitive impairment, Seizure, Specialist-endorsed referral) are used for `indication-theme`.
- Census rows 19–22: `cth_a48_1` B(3) nested, `cth_p2_1` C(1+4), `cth_p2_2` C(1+6), `cth_p2_3` M — all match the encoded structure.

## 6. Engineering notes

- The renderer and engine gaps recorded at first transcription (determination codes other than `P2_URGENT` had no row wording; `ACUTE_48H` did not count as a priority) are fixed by AD-36, KI-76 and CL-57.
- Reading `redflag.suspectedTIA` as true at this site also makes the national library report RF-10 as indeterminate (stem true, qualifiers unanswered) — existing national behaviour (vocabulary Q20, Q23). RF-10's asterisk refers to US Carotid's own p35 footnote, not to CT Head *1 (Q15); `cql/CRR_RedFlags.cql` comment at RF-10 says otherwise (logged by the coordinator, not edited here).

## 7. Matrix cases found

Six CT Head cases in `documents/CRR_Test_Case_Results_Matrix_v2.xlsx` (sheet "Test Case Results": RP-000, RP-003, RP-004, DG-001, DG-002; sheet "Structured Re-Eval": the same plus INT-SAH, which has no verbatim note). No CT Head case in "Michaela Model Comparison"; "Corrections Log" rows only fix DB ids. Results (strict unless stated):

| Case | Engine | Evaluator | |
|---|---|---|---|
| RP-000 | INSUFFICIENT_INFORMATION (asks for a qualifying headache feature) | Proceeds | differs — Q11 (nausea only; blurred vision is not speech/limb/facial weakness). CTH-RP-000b: age 45 meets P2 once a feature is documented |
| RP-003 | ACUTE_48H via focal neurologic signs; `?TIA` inferred and excluded | Proceeds (focal neurological signs pathway) | agrees |
| RP-004 | INSUFFICIENT_INFORMATION | At risk (strict); PCRL accepts proceeds | agrees with strict |
| DG-001 | INSUFFICIENT_INFORMATION; no cognitive pathway | Declined (insufficient information) | agrees |
| DG-002 | INSUFFICIENT_INFORMATION (strict and inferred) | At risk / Declined | agrees |
| INT-SAH | INSUFFICIENT_INFORMATION, no redirect | Declined — ED emergency (legacy Step 0) | not a CT Head criterion; F-01 governance question |

STEP-3 worked example (prompt decomposition §3, "CT Head focal neuro vs TIA gateway"): CTH-W01, plus RP-003.

## 8. Build gates

`npm run build && npm test && npm run check` green on 2026-10-15 (first transcription) and again on 2026-10-16 after the review fixes (53 CT Head scenarios). Every Rule Trace define reaches true in at least one scenario; every scenario quote is a verbatim span of its note.
