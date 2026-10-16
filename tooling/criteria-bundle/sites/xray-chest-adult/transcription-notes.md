# Transcription notes — X-ray Chest - Adult (`xray-chest-adult`)

**Source:** National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026, section "X-ray Chest - Adult", **pp.62-65** (`documents/reference/National Primary Care Referral Criteria for Imaging.pdf`; X-ray Shoulder starts p66). Published exam/site id `xr_chest` → bundle key `xray-chest-adult` (AD-01, one-to-one). Library `CRR_XRChest_Adult`.

**Status:** NOT CLINICALLY REVIEWED. Transcribed 2026-10-15 (W1, slice 7) for a **staging demo bundle only** (Gary, 2026-10-15; AD-35). The most literal reading is encoded; every genuine ambiguity is a REVIEW Qn (Q1-Q26, listed in the CQL header and `signoff.md`). Nothing without a literal reading is guessed (§4).

**Text extraction.** The plain-text extraction interleaves the Source column (two BTS URLs broken across 20+ lines) with the Clinical Presentation column on p62, so p62-p65 were re-extracted with `pypdf` `extraction_mode="layout"`. The layout pass confirmed: (a) the two bullets "Suspected community-acquired pneumonia …" and "Respiratory tract infection with possible left ventricular failure" sit in the **Acute: Within 24 hours** row, and the lung-cancer list starts the **Acute: Within 48 hours** row; (b) the Guidance box ("In patients with an acute lower respiratory tract infection …") is printed inside the Acute 24h row, above its bullets, not at the foot of p62 where the plain extraction puts it; (c) the 48h list continues across the page break onto p63 with no new row label. The two BTS URLs were read from the page's link annotations (not reassembled from the broken text). SOURCE quotes and PlanDefinition titles were then checked mechanically against the page text (140/140 quoted fragments found verbatim, whitespace and bullet glyphs normalised).

## 1. Atoms

Define names are those in `CRR_XRChest_Adult.cql`. "Existing" = reused vocabulary linkId; everything else is in `vocabulary-additions.json`.

### Refer for acute assessment without initial imaging (p62) — not encoded here

| Source (verbatim) | Where it is evaluated |
|---|---|
| "Haemoptysis with "red flags" including if" + four sub-bullets | CRR_RedFlags RF-14 (`redflag.haemoptysisPresent` + four qualifiers) |
| "Severe respiratory distress" | RF-15 |
| "Suspected large pneumothorax with significant pain, breathlessness, tachycardia" | RF-16 |
| "Suspected active Tuberculosis and the patient is acutely unwell – follow the Tuberculosis pathway" | RF-17 |

The PlanDefinition carries this row as an `acute-assessment` block with no condition and no inputs (display only, as the Viewer's acute banner). The national library runs first and stops the pipeline when a flag fires (AD-03).

### Acute: Within 24 hours (p62)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "Suspected community-acquired pneumonia (CAP) with unexpectedly severe or atypical presentation, or where the patient is considered at risk of underlying lung pathology (e.g. lung cancer)" | `symptom.suspectedCommunityAcquiredPneumonia` AND (`symptom.pneumoniaSevereOrAtypicalPresentation` OR `symptom.atRiskOfUnderlyingLungPathology`) | A24-1 (Q4, Q21) |
| "Respiratory tract infection with possible left ventricular failure" | `symptom.respiratoryTractInfection` AND `symptom.possibleLeftVentricularFailure` | A24-2 |

### Acute: Within 48 hours (p62-63)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "One or more of the following symptoms or signs concerning for lung cancer" | any of LC-01..LC-12 | A48-1 (Q5) |
| "Unexplained, new, or worsening dyspnoea" | `symptom.dyspnoeaUnexplainedNewOrWorsening` | LC-01 (Q6) |
| "Unexplained cough, persisting and worsening for more than 3 weeks" | `symptom.coughUnexplained` AND `symptom.coughWorsening` AND `symptom.coughDurationWeeks` > 3 | LC-02 (Q7, Q24: present > 3 weeks AND currently worsening) |
| "Unexplained chest and/or shoulder pain" | `symptom.chestOrShoulderPainUnexplained` | LC-03 |
| "Unexplained changes in existing symptoms in patients with underlying chronic respiratory problems persisting for more than 3 weeks" | `symptom.chronicRespiratoryCondition` AND `symptom.chronicRespiratorySymptomChangeUnexplained` AND `symptom.chronicRespiratorySymptomChangeDurationWeeks` > 3 | LC-04 (Q25: duration attaches to the changes) |
| "Persistent, unexplained hoarseness persisting for more than 3 weeks" | `symptom.hoarsenessUnexplained` AND `symptom.hoarsenessDurationWeeks` > 3 | LC-05 |
| "Recurrent or unresolved chest infections" | `symptom.chestInfectionsRepeatedOrUnresolved` | LC-06 |
| "Persistent, unexplained haemoptysis in the absence of red flags" | `redflag.haemoptysisPresent` (existing, national stem) AND `symptom.haemoptysisPersistentUnexplained` | LC-07 (Q9) |
| "Unexplained weight loss and loss of appetite persisting for more than 3 weeks" | `weightloss.present` (existing) AND `weightloss.periodMonths` (existing) × 30.4375 > 21 days AND `symptom.appetiteLoss` AND `symptom.appetiteLossDurationWeeks` > 3 | LC-08 (Q8: "unexplained" applied to the weight loss only) |
| "unexplained abnormal chest signs persisting more than 3 weeks (e.g. suspected pleural effusion) which have not yet been investigated with imaging" | `symptom.abnormalChestSignsUnexplained` AND `symptom.abnormalChestSignsDurationWeeks` > 3 AND NOT `imaging.abnormalChestSigns.ever` | LC-09 |
| "New supraclavicular lymphadenopathy" | `symptom.supraclavicularLymphadenopathyNew` | LC-10 |
| "New cervical lymphadenopathy persisting for more than 3 weeks, where the lymph nodes are greater than 1 cm in diameter in a patient with other lung cancer symptoms, signs, or risk factors" | `symptom.cervicalLymphadenopathyNew` AND `symptom.cervicalLymphadenopathyDurationWeeks` > 3 AND `symptom.cervicalLymphNodeDiameterCm` > 1 AND `symptom.otherLungCancerFeatures` | LC-11 (Q10, Q21) |
| "Features suggestive of paraneoplastic syndromes. e.g. hypercalcaemia, hypertrophic osteoarthropathy with painful swollen joints and finger (and toe) clubbing" | `symptom.paraneoplasticFeatures` | LC-12 |
| "Subacute dyspnoea of unknown cause, e.g. suspected pleural effusion or left ventricular failure" | `symptom.subacuteDyspnoeaUnknownCause` | A48-2 |
| "Lower respiratory tract infection which hasn’t responded as expected after 48 hours of antibiotic treatment" | `symptom.lowerRespiratoryTractInfection` AND `symptom.noResponseAfter48hAntibiotics` | A48-3 |
| "Suspected small pneumothorax" | `symptom.suspectedSmallPneumothorax` | A48-4 |
| "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises referral for acute x-ray" | `advice.acuteImagingRecommended` (existing) | A48-5 (Q22) |

### P2 Urgent (p63)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "Suspected tuberculosis - follow the Tuberculosis pathway and request a CXR if indicated" | `symptom.suspectedTuberculosis` | P2-1 (Q11) |
| "Suspected drug induced lung disease in patients who develop new respiratory symptoms while taking medication which can potentially affect the lungs e.g. Amiodarone, nitrofurantoin, methotrexate." | `symptom.suspectedDrugInducedLungDisease` AND `symptom.newRespiratorySymptoms` AND `symptom.takingPneumotoxicMedication` | P2-2 |
| "Idiopathic / unprovoked DVT or PE - as required, to exclude underlying malignancy." | `symptom.unprovokedDvtOrPe` | P2-3 (Q13) |
| "Polymyalgia Rheumatica (PMR) - request CXR for all patients prior to starting steroids, to exclude …" | `symptom.polymyalgiaRheumatica` AND NOT `symptom.pmrSteroidsStarted` | P2-4 (Q12) |
| "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises referral for urgent x-ray" | `advice.urgentImagingRecommended` (existing) | P2-5 |

### P3 (p64)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "For investigation of alternative diagnoses or co-morbidities in patients with non-acute asthma and any of - unclear diagnosis, poor control, or frequent exacerbations" | `symptom.asthmaNonAcute` AND (`symptom.asthmaDiagnosisUnclear` OR `symptom.asthmaPoorControl` OR `symptom.asthmaFrequentExacerbations`) | P3-1 (Q14) |
| "Chronic cough (more than 8 weeks)" | `symptom.coughDurationWeeks` > 8 (same indicator as LC-02) | P3-2 |
| "Chronic dyspnoea" | `symptom.chronicDyspnoea` | P3-3 |
| "Known cardio-respiratory disease unresponsive to treatment, for example COPD, ILD, bronchiectasis, sarcoidosis" | `symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment` | P3-4 |
| "History of asbestos exposure and no previous chest x-ray" | `symptom.asbestosExposureHistory` AND NOT `imaging.cxr.ever` | P3-5 (Q19) |
| "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises referral for non-urgent x-ray" | `advice.nonUrgentImagingRecommended` (existing) | P3-6 |

### S2 (p64)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "6 week follow up chest X-ray after chest infection if the patient has any of: ongoing symptoms or signs / suspicious radiological features noted by a radiologist and follow up is recommended / when recommended by secondary care clinician or radiologist" | `imaging.followUpAfterChestInfection` AND (`symptom.ongoingSymptomsOrSignsAfterChestInfection` OR `imaging.radiologistSuspiciousFeaturesFollowUpRecommended` OR `advice.followUpImagingRecommendedBySpecialist`) | S2-1 (Q15, Q16) |
| "Post-cancer surveillance with documented specialist recommendation" | `imaging.postCancerSurveillance` AND `advice.followUpImagingRecommendedBySpecialist` | S2-2 (Q16) |
| "Follow-up of nodules detected on chest X-ray or CT, if recommended by a secondary care clinician or radiologist" | `imaging.noduleFollowUp` AND `advice.followUpImagingRecommendedBySpecialist` | S2-3 (Q16) |
| "Secondary care clinician or Primary Care Radiology Liaison or radiologist advises referral for follow-up x-ray" | `advice.followUpImagingRecommended` (new gateway) | S2-4 |

All four gateways (A48-5, P2-5, P3-6, S2-4) carry the GATEWAY badge and the Overview p5 rule "always include the name and role of that person" (`advice.adviserNameRole`, existing): a met gateway with no name asks for it.

### Alternative management or HealthPathway recommended (p64)

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "Ongoing unexplained respiratory symptoms after a negative chest X-ray result, especially if clinical concern of malignancy, either:" | `symptom.respiratorySymptomsOngoingUnexplained` AND `imaging.cxrNegative.ever` | Redirect (Q20) |
| "Seek secondary care specialist assessment" / "See the local Lung Cancer HealthPathway" / "See the local CT Chest, Abdomen and Pelvis HealthPathway" | — | the three `activeRedirects` strings, verbatim |

Exclusion-shaped (CT CAP pattern): an unknown component is treated as not present and listed in `unconfirmedExclusions`.

### Not routinely funded (p64-65)

Each item is read as the **purpose of the request** (Q17), exclusion-shaped (`Coalesce(…, false)`). Under coordinator rule R1 (Q3) a not-funded item applies only when every timeframe row is definitively not met: a met row wins, and an undetermined row gives INSUFFICIENT_INFORMATION. PlanDefinition children have no `input`, so none is ever tickable (GEN-005).

| Source (verbatim) | Indicators | Define |
|---|---|---|
| "Routine follow-up of pneumonia findings on chest x-ray, other than in the scenarios specified above under S2 priority imaging" | `imaging.followUpAfterChestInfection` AND none of the S2-1 sub-conditions | NF-01 (Q15) |
| "Asbestos exposure surveillance" | `funding.asbestosSurveillance` | NF-02 (Q19) |
| "Heart murmur, unless signs of complications such as heart failure" | `funding.heartMurmurIndication` AND NOT `symptom.heartMurmurComplicationSigns` | NF-03 |
| "Lung cancer screening" | `funding.lungCancerScreening` | NF-04 |
| "Follow-up of nodules detected on chest X-ray or CT, except with documented recommendation of a hospital secondary care clinician or radiologist" | `imaging.noduleFollowUp` AND NOT `advice.followUpImagingRecommendedBySpecialist` | NF-05 (Q16) |
| "The patient may wish to consider privately funded imaging for TB screening in the absence of a positive skin or blood test - See Tuberculosis pathway for additional management advice" | `funding.tbScreening` AND NOT `lab.tbSkinOrBloodTestPositive` | NF-06 |
| "Rib views" | `funding.ribViews` | NF-07 |
| "Chest x-rays for immigration purposes" | `funding.immigrationPurposes` | NF-08 |
| "Routine lateral x-ray view when requesting a PA image" | — | **not encoded** (Q18) |
| "Routine investigation of hypertension" | `funding.routineHypertensionInvestigation` | NF-10 |
| "Routine monitoring for asymptomatic patients who are taking medications which may cause drug induced lung disease (e.g. amiodarone, nitrofurantoin, methotrexate)." | `funding.routineMonitoringPneumotoxicMedication` | NF-11 |

### Age

"Adult": `Is Adult` = age > 15 (Overview p4, as CT CAP); a paediatric patient gets PAEDIATRIC_CRITERIA_APPLY (X-ray Chest - Paediatric is p93).

## 2. Modelling decisions

- **Five timeframe rows, one determination each (AD-36).** `ACUTE_24H`/`A24`, `ACUTE_48H`/`A48`, `P2_URGENT`/`P2`, `P3_NON_DEFERRABLE`/`P3`, `S2_TIME_SENSITIVE`/`S2`, defines `Meets <row> Criteria`, plus `NOT_ROUTINELY_FUNDED`, `ALTERNATIVE_MANAGEMENT`, `PAEDIATRIC_CRITERIA_APPLY`, `CRITERIA_NOT_MET`, `INSUFFICIENT_INFORMATION`. `priorityCode` is triager-only and non-null exactly when a row is met; `priorityTimeframe` carries no code.
- **Precedence** (Q1-Q3, coordinator rule R1): alternative management > paediatric > the most urgent met row (not held back by an undetermined more urgent row) > INSUFFICIENT_INFORMATION while any row is undetermined > not routinely funded (only when every row is definitively false) > `CRITERIA_NOT_MET`. Alternative reading for Q3: not funded first, as CT CAP does for "unfit for treatment".
- **Durations are numbers, thresholds live in CQL.** "more than 3 weeks" / "more than 8 weeks" / "greater than 1 cm" are compared in the library (invariant 3); the Questionnaire asks for the duration in weeks (or size in cm). One cough-duration indicator serves both LC-02 (> 3) and P3-2 (> 8). The one window kept in an indicator's text, "after 48 hours of antibiotic treatment", follows `redflag.notRespondingToAntibiotics72h`.
- **"unexplained" is per symptom**, not a shared qualifier: one response carries many symptoms, so a single "unexplained" answer would be ambiguous. One exception, LC-08 (Q8): "Unexplained weight loss and loss of appetite" is encoded with "unexplained" on the weight loss only (`weightloss.present` already reads "Unintentional, unexplained weight loss"); no `symptom.appetiteLossUnexplained` was minted. If the ruling is that "unexplained" governs both, that indicator is needed.
- **Viewer tick boxes (coordinator rule R2).** No PlanDefinition row has a single boolean input that the CQL reads negated, so no input was removed. The negated reads (`imaging.abnormalChestSigns.ever`, `symptom.pmrSteroidsStarted`, `imaging.cxr.ever`) are each one of several inputs on their row, and each item's wording matches what a tick means (e.g. "Patient has previously had a chest X-ray").
- **Referrer-visible strings (coordinator rule R3).** The PlanDefinition carries no engineering notes in `documentation.display` (the only display note is the Overview p5 adviser sentence on the four gateways). The one priority code in the middle of published wording, "…under S2 priority imaging" in the first not-funded item, is left verbatim for the renderer.
- **Missing information** (Q23): a pathway is *started* when it is undetermined and one of its components is met; only started pathways' unanswered components are listed; if none is started, every undetermined pathway's are (about 60 items for the strict matrix cases); if a pathway is already met, only `patient.age` can be missing.
- **Shared national stem.** LC-07 composes the national `redflag.haemoptysisPresent` with a site qualifier rather than minting a second haemoptysis concept (KI-01). The site Questionnaire repeats that item; one response answers it once.
- **Groups.** No new vocabulary group was added. Request purposes that are not "not funded" (`imaging.followUpAfterChestInfection`, `imaging.postCancerSurveillance`, `imaging.noduleFollowUp`) are under `imaging`, and history items (asbestos exposure, PMR, unprovoked DVT/PE) under `symptom` ("clinical findings"). A `request` / `history` group would be cleaner; that is the vocabulary owner's call.
- **Themes** (render-only grouping in the Viewer): chest infection, suspected lung cancer, breathlessness, pneumothorax, tuberculosis, chronic respiratory symptoms and disease, follow-up imaging, other indications, and CT CAP's specialist-endorsed referral for the four gateways.
- **HealthPathways page id:** `TBC-page-id`, as CT CAP and CTC. The published JSON's Auckland URL carries `page=20715.htm`; not used (precedent: CT CAP left its JSON page id unused too).

## 3. Modifiers (KI-05) — listed, not encoded

| Page | Wording | Treatment |
|---|---|---|
| p62 | "(e.g. lung cancer)" | illustrative; "considered at risk" is the condition |
| p63 | "(e.g. suspected pleural effusion)" | illustrative |
| p63 | "e.g. hypercalcaemia, hypertrophic osteoarthropathy … clubbing" | illustrative; `lab.calcium.raised` is **not** used |
| p63 | "e.g. suspected pleural effusion or left ventricular failure" (subacute dyspnoea) | illustrative |
| p63 | "e.g. Amiodarone, nitrofurantoin, methotrexate." | illustrative |
| p63 | "(e.g. pulmonary pathology, chronic infection, malignancy)" | purpose, illustrative |
| p63 | "Also consider additional targeted imaging if any specific concerns about an underlying malignancy." | guidance |
| p63 | "as required, to exclude underlying malignancy" | not a condition (Q13) |
| p63 | "request a CXR if indicated" | not a condition (Q11) |
| p64 | "for example COPD, ILD, bronchiectasis, sarcoidosis" | illustrative |
| p64 | "especially if clinical concern of malignancy" | modifier (Q20) |
| p64 | "such as heart failure" | illustrative example of "signs of complications" |
| p64 | "6 week" (S2 "6 week follow up chest X-ray after chest infection") | the follow-up's target date, not a condition on when the infection was (Q26) |
| p65 | "(e.g. amiodarone, nitrofurantoin, methotrexate)" | illustrative |

## 4. Not encoded

- **"Routine lateral x-ray view when requesting a PA image"** (p65) — it withholds one view, not the referral; returning NOT_ROUTINELY_FUNDED for the whole referral would be a guess. Displayed in the not-funded list only (Q18).
- **The acute-assessment row** (p62) — national library, not this site (above).
- **Guidance** (p62) — displayed; not a criterion.
- **`population.cql` — not done.** No criterion here depends on a lab series or an imaging interval the record could compute (the only lab item, a positive TB skin/blood test, is a single fact), and `run-tests-sites.mjs` does not run record-backed scenarios yet.
- **AD-17 attestation category** — three candidates proposed (Q21), not added: the additions file has no slot for `attestationIndicators`, and the category is a governance decision.

## 5. Vocabulary

66 additions (`vocabulary-additions.json` → `add`, all `PLACEHOLDER` codes, all naming the clinical concept, not the site): 48 `symptom`, 7 `imaging`, 2 `advice`, 1 `lab`, 8 `funding`. `addSite`: `patient.age` (p62), `weightloss.periodMonths` (p63). Reused unchanged and already attributed to this site: `weightloss.present` (p63), `redflag.haemoptysisPresent` (p62), `advice.acuteImagingRecommended` (p63), `advice.urgentImagingRecommended` (p63), `advice.nonUrgentImagingRecommended` (p64). `advice.adviserNameRole` is reused and left attributed to the Overview (p5), as CT CAP leaves it.

Existing attributions to `xray-chest-adult` this transcription does **not** use (for the vocabulary owner, not edited here):
- `lab.calcium.raised` (p63) — hypercalcaemia is an "e.g." example of a paraneoplastic feature.
- `workup.cxr` (p62) — no X-ray Chest criterion asks whether a chest X-ray was done as initial work-up; the concepts used are `imaging.cxr.ever` (P3 asbestos) and `imaging.cxrNegative.ever` (alternative management).

Near-duplicate risks the owner should look at (KI-01): `advice.followUpImagingRecommendedBySpecialist` vs the new gateway `advice.followUpImagingRecommended` (differ by PCRL and by "documented recommendation" vs "advises referral"; Q16); `imaging.postCancerSurveillance` vs `excl.currentCancerFollowUp` (kept apart: surveillance after cancer vs a current diagnosis under follow-up); `symptom.respiratoryTractInfection` vs `symptom.lowerRespiratoryTractInfection` (the rows name them separately).

## 6. Source versus published JSON (`pdf-criteria-all.json`, `xr_chest`)

- Same rows and items. The JSON flattens two compound bullets with the stem repeated: the haemoptysis red-flag bullet (`xrch_em_1..4`) and the 12-item lung-cancer list (`xrch_48_1..12`, "One or more of the following symptoms or signs concerning for lung cancer: …") — census headline finding 2 / vocabulary D-02. The PlanDefinition restores the PDF nesting.
- `xrch_s2_1` joins the three sub-bullets with "; "; the PlanDefinition keeps them as three children.
- The JSON P3 group title reads "P3 non-deferrable …"; the PDF prints "P3 Non-deferrable …" (PDF wording used).
- The JSON PMR label has one space after "malignancy)."; the PDF has two (kept).
- `outOfCriteriaNote` paraphrases the not-funded list; `notFundedDetail` drops bullets and joins items; `alternativeManagement` joins the three options with "; ". The PlanDefinition uses the PDF wording.
- The JSON carries no Source column; the PlanDefinition cites the Canterbury HealthPathway, both BTS guidelines (URLs from the PDF link annotations), "3D, Canterbury HealthPathways" and "MoH Comm Rad Criteria 2015".
- The legacy Triage Advisor cited the CAP criterion as "[p65]" in both matrix cases; it is printed on p62.

## 7. Matrix cases and worked examples

`documents/CRR_Test_Case_Results_Matrix_v2.xlsx`, all four sheets: two X-ray Chest cases, both in "Test Case Results" and "Structured Re-Eval"; none in "Michaela Model Comparison" or "Corrections Log". `instructions/arch-mig-prompt-decomposition.md` has no X-ray Chest worked example.

| Case | Note (verbatim) | Legacy verdict / evaluator | Engine (strict) | Engine (inferred) |
|---|---|---|---|---|
| LP-001 | "55 yo man, 3 days cough, fever and shortness of breath" | Proceeds (acute CAP) / Proceeds | INSUFFICIENT_INFORMATION — CAP only inferable; 60-item checklist (XRC-S01) | INSUFFICIENT_INFORMATION — asks for severe/atypical presentation, at-risk, possible LVF (XRC-S02) |
| CR-001 | "42 yr old homeless patient with fever productive cough, smoker, unsure re wt loss .Fine lower basal crepitus , mild tachy ," | Proceeds (acute CAP, at-risk smoker) / Proceeds | INSUFFICIENT_INFORMATION (XRC-S03) | ACUTE_24H, A24 (XRC-S04) |

Neither note documents a criterion: "suspected CAP" and "at risk of underlying lung pathology" are clinical interpretations (`inferred` under the extraction contract), so under the strict standard both cases are insufficient where the legacy tool said Proceeds. That is the documentation-standard question (TA-010), visible, not a transcription defect. The CR-001 evaluator's urgent-care comment (needs same-day imaging, social circumstances) is a workflow point for the working group, not a criterion.

## 8. Adjacent problems

The three renderer/engine gaps raised at transcription (leading S2 code shown to referrers, cross-exam recommendation ignoring Acute and S outcomes, humanised wording for unmapped codes) are resolved by AD-36 / KI-76 / CL-57. A priority code in the middle of published wording (the first not-funded item) is the coordinator's renderer item (R3). Still open:

1. **Checklist length** (Q23): a note with no documented criterion gets about 60 "what to add" lines. Under R1 this now also applies to a not-funded request (e.g. immigration) whose timeframe rows are unanswered.

## 9. Build gates

`npm run build` compiles `CRR_XRChest_Adult` (125 defines); `npm test` runs this site's 81 scenarios, all passing (results in `results.md`); `npm run check` rule 14 passes for this site (82 Questionnaire items incl. groups). Publish manifest added to `tooling/publish.mjs` (`source.pages` "62-65"); not published.
