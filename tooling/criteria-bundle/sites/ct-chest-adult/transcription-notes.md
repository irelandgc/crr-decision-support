# Transcription notes — CT Chest - Adult (`ct-chest-adult`)

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf` — National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026, section "CT Chest - Adult", **pp.12-16**: p12 heading and acute-assessment row; p13 P2 timeframe cell and the Guidance block; p14 P2 bullets and P3 row; p15 alternative management row and Notes *1, *2, *3 (start); p16 *3 (end) and *4. CT Colonography starts p17. Published exam/site id `ct_chest`; library `CRR_CTChest_Adult`.

**Status:** NOT CLINICALLY REVIEWED. Transcribed 2026-10-15 for a staging demo bundle under AD-35 (Gary's decision of 2026-10-15: encode the most literal reading, record every ambiguity as a REVIEW Qn rather than stopping). The 17 REVIEW questions are in `signoff.md`. Revised 2026-10-16 after the second-session review (§11).

## 1. Atoms

Source sentence (verbatim; line breaks collapsed) → indicator. **New** = proposed in `vocabulary-additions.json`. **Att** = attestation / clinical-judgement indicator (AD-17).

| Source (page, row) | Fact | Indicator | |
|---|---|---|---|
| p12 acute: "Life threatening, massive haemoptysis – patient is at high risk of asphyxiation or exsanguination" | national red flag | `redflag.haemoptysisMassive` (RF-01, CRR_RedFlags) | not in this library |
| p12 acute: "Stridor / suspected SVC obstruction" | national red flag | `redflag.stridorOrSvcObstruction` (RF-02, CRR_RedFlags) | not in this library |
| p14 P2-1: "Unexplained haemoptysis" | haemoptysis | `redflag.haemoptysisPresent` | existing (RF-14 stem; already attributed to this page) |
| p14 P2-1: "(occurred in absence of chest infection" | no chest infection | `symptom.haemoptysisWithoutChestInfection` | New (Q5) |
| p14 P2-1: "and upper respiratory tract causes including bleeding from the nasopharynx, sinuses, or oral cavity have been excluded)" | URT causes excluded | `workup.upperAirwayBleedingExcluded` | New (Q5) |
| p14 P2-1: "And initial investigations including chest x-ray" | CXR done | `workup.cxr` | existing |
| p14 P2-1: "fail to identify a cause" | no cause found | `workup.initialInvestigationsCauseNotFound` | New |
| p14 P2-1: "- refer for urgent CT chest and for respiratory assessment." | instruction | none | wording only |
| p14 P2-2: "Aged over 55 years’ old" | age > 55 | `patient.age` | existing (Q1) |
| p14 P2-2: "current smoker" | current smoker | `patient.currentSmoker` | New |
| p14 P2-2: "One or more concerning, new onset, symptoms /signs for lung cancer *1" | any *1 item | 12 `symptom.*` items below | New (Q4) |
| ″ | new onset | `symptom.newOnset` | New (Q3) |
| p14 P2-2: "Persistent for six weeks despite appropriate treatment." | persistence | `symptom.persistentSixWeeksDespiteTreatment` | New (Q3) |
| p14 P2-2: "AND unexplained despite initial investigations including chest x-ray and blood tests." | CXR, bloods, no cause | `workup.cxr`, `workup.bloods`, `workup.initialInvestigationsCauseNotFound` | existing, existing, New |
| p14 P2-3: "Indeterminate abnormality on chest x-ray which raises the possibility of a lung cancer (e.g. bulky hilum)" | CXR finding | `workup.cxrIndeterminateAbnormality` | New (Q7) |
| p14 P2-3/P2-4: "AND CT chest is recommended in the Radiology report." | report recommends CT | `workup.radiologyReportRecommendsImaging` | New (Q6) |
| p14 P2-4: "Persistent consolidation on chest x-ray done as a 6-week follow-up study" | CXR finding | `workup.cxrPersistentConsolidationFollowUp` | New |
| p14 P2-5: "Secondary care clinician or Radiologist advises referral for urgent staging CT chest/liver for work up of a suspicious lesion on chest x-ray" | advice | `advice.urgentStagingCtRecommended` | New (Q16) |
| p14 P2-5: "AND CT is the advised next step on local HealthPathway as opposed to referral to secondary care or PET-CT *4" | pathway step | `advice.localHealthPathwayAdvisesCt` | New |
| p14 P2-6: "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist advises referral for urgent CT chest" | advice | `advice.urgentImagingRecommended` | existing (already attributed p14) |
| Overview p5: name and role of the endorsing clinician | adviser named | `advice.adviserNameRole` | existing (missing-information prompt only) |
| p14 P3-1: "Isolated, pulmonary nodule identified on a chest x-ray" | CXR finding | `workup.cxrIsolatedPulmonaryNodule` | New |
| p14 P3-1: "and cannot be confirmed as benign from x-ray appearances alone" | not confirmed benign | `workup.cxrNoduleNotConfirmedBenign` | New |
| p14 P3-1: "AND referral for CT chest is recommended in the Radiology report" | report recommends CT | `workup.radiologyReportRecommendsImaging` | New (Q6) |
| p14 P3-2: "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist advises referral for non-urgent CT chest" | advice | `advice.nonUrgentImagingRecommended` | existing (addSite p14) |
| p15 AM-1: "Patient re-presents" | re-presentation | `workup.rePresentation` | New |
| p15 AM-1: "with concerning symptoms or signs" | any *1 item | 12 `symptom.*` items | Q9 |
| p15 AM-1: "and chest x-ray is normal" | CXR normal | `workup.cxrNormal` | New |
| p15 AM-1: "but doesn’t meet the above criteria for CT chest referral" | computed | (every P2/P3 pathway false) | Q9 |
| p15 AM-2: "Persistent, non-specific, non-localising symptoms and signs which are concerning for underlying cancer (e.g. weight loss, fatigue)" | clinical impression | `symptom.nonSpecificSymptomsConcerningForCancer` | New, **Att** (Q14) |
| p15 AM-2: "and initial investigations including chest x-ray and bloods fail to identify a cause" | CXR, bloods, no cause | `workup.cxr`, `workup.bloods`, `workup.initialInvestigationsCauseNotFound` | |
| p15 AM-3: "Initial presentation with respiratory symptoms or signs concerning for lung cancer - refer for urgent chest x-ray as the initial investigation." | — | none | not evaluated (Q8) |
| p15 AM-4: "Follow-up of nodule discovered incidentally on CT chest scan" | request type | `workup.ctIncidentalNoduleFollowUp` | New |
| p15 AM-4: "unless radiology report confirms benign based on CT appearance and no follow-up is required" | benign confirmed | `workup.ctNoduleReportConfirmsBenign` | New (Q11) |
| p15 *1 item 1: "Unexplained, new, or worsening dyspnoea." | | `symptom.dyspnoeaUnexplainedNewOrWorsening` | New |
| *1 item 2: "Unexplained cough, persisting and worsening for more than 3 weeks." | | `symptom.coughUnexplainedOver3Weeks` | New |
| *1 item 3: "Unexplained chest and/or shoulder pain persisting for more than 3 weeks." | | `symptom.chestShoulderPainUnexplainedOver3Weeks` | New |
| *1 item 4: "Unexplained changes in existing symptoms in patients with underlying chronic respiratory problems persisting for more than 3 weeks." | | `symptom.chronicRespiratorySymptomChangeOver3Weeks` | New |
| *1 item 5: "Unexplained hoarseness persisting for more than 3 weeks." | | `symptom.hoarsenessUnexplainedOver3Weeks` | New |
| *1 item 6: "Repeated / or unresolved chest infections." | | `symptom.chestInfectionsRepeatedOrUnresolved` | New |
| *1 item 7: "Persistent, unexplained haemoptysis" | | `symptom.haemoptysisPersistentUnexplained` | New |
| *1 item 8: "Unexplained weight loss and loss of appetite persisting for more than 3 weeks." | | `symptom.weightAndAppetiteLossOver3Weeks` | New |
| *1 item 9: "Un-investigated/unexplained abnormal chest signs persisting for more than 3 weeks. (e.g. suspected pleural effusion)" | | `symptom.abnormalChestSignsOver3Weeks` | New |
| *1 item 10: "New, supraclavicular lymphadenopathy" | | `symptom.supraclavicularLymphadenopathyNew` | New |
| *1 item 11: "Features suggestive of paraneoplastic syndromes. e.g. hypercalcaemia, hypertrophic osteoarthropathy with finger (and toe) clubbing and painful swollen joints" | | `symptom.paraneoplasticFeatures` | New |
| *1 item 12: "New cervical lymphadenopathy persisting for more than 3 weeks and nodes are more than 1 cm in diameter in a patient with other lung cancer symptoms or signs or risk factors." | | `symptom.cervicalLymphadenopathyOver3WeeksOver1cm` | New |

Attestation (AD-17): one new indicator is proposed for the category, `symptom.nonSpecificSymptomsConcerningForCancer` (the referrer's impression that symptoms are "concerning for underlying cancer"), with referrer/triager wordings. No existing attestation indicator is used. Considered and not flagged: "appropriate treatment" (P2-2) and "raises the possibility of a lung cancer" (P2-3, a radiology-report finding) — both are facts a note or report states.

Source column (pp.12-15) → `PlanDefinition.relatedArtifact` citations (16, as printed). Referrers "GP & UC Doctors / NPs" → `useContext`.

## 2. Modelling decisions

- **Structure.** P2: six bullets, any one qualifies (`selectionBehavior: any`). P3: two bullets, any one. Bullet 2 of P2 is a conjunction: stem (age, smoker) AND *1 any-of AND new onset AND persistence AND unexplained-after-work-up (Q2, Q3). Every other bullet is a conjunction of its atoms.
- **Determination precedence** (as CT CAP): redirect → paediatric → P2 → P3 → not met → insufficient. No not-funded row exists, so there is no `NOT_ROUTINELY_FUNDED` path and no not-funded action. The P3 code is `P3_NON_DEFERRABLE` (P3 priority code, "Complete within 6 weeks of receiving referral"); the outcome codes, priority codes and `Meets P2 Criteria` / `Meets P3 Criteria` define names already follow AD-36, so the engine treats the result as a priority (non-null `priorityCode`) and the Advisory renderer shows the P2/P3 row wording with the leading code stripped for referrers (AD-36, KI-76, CL-57).
- **Three-valued logic.** Unanswered clinical indicators are null. Redirects fire only when definitively true. The re-presentation redirect (AM-1) needs every P2/P3 pathway definitively false, so it can never override a met criterion and needs no precedence ruling of its own.
- **Missing information** lists only the unanswered atoms of pathways that are still undetermined; a pathway already false asks for nothing. As in CT CAP, an unanswered specialist-advice indicator keeps P2-6 / P3-2 undetermined, so `CRITERIA_NOT_MET` needs those answered "no".
- **Unconfirmed exclusions**: the two redirect triggers (`symptom.nonSpecificSymptomsConcerningForCancer`, `workup.ctIncidentalNoduleFollowUp`) when unanswered; and, only once the criteria are definitively not met, the unanswered components of the re-presentation redirect.
- **One concept, one indicator (KI-01).** "Initial investigations fail to identify a cause" appears three times (P2-1, P2-2, AM-2) and is one indicator; which investigations were done stays with `workup.cxr` / `workup.bloods` (REVIEW Q17). "CT chest is recommended in the Radiology report" appears three times and is one indicator, worded for "the requested imaging" (house style of `advice.urgentImagingRecommended`) so other sites can reuse it. *1 item 7 (persistent unexplained haemoptysis) and *1 item 8 (weight loss with appetite loss over 3 weeks) are distinct from `redflag.haemoptysisPresent` and `weightloss.present` (each adds qualifiers); the vocabulary notes say so.
- **National red flags not re-encoded.** The p12 row is RF-01/RF-02 in `CRR_RedFlags`, which runs first. The PlanDefinition carries it as an `acute-assessment` block (rendered as the banner) with no condition. Scenario CTCH-S26 shows this library ignores `redflag.haemoptysisMassive`.
- **Advice gateways** carry the GATEWAY badge and `advice.adviserNameRole` as an input; the name/role is asked for in missing information when an advice pathway is met (Overview p5), as CT CAP.
- **Indication themes** from `instructions/archive/indication-groupings.md` (CT Chest): Haemoptysis (P2-1), Lung cancer risk (P2-2), Abnormal CXR / nodule (P2-3, P2-4, P3-1), Staging (P2-5), Specialist-endorsed referral (P2-6, P3-2).
- **HealthPathways**: page ID left as `TBC-page-id` (as CT CAP); the published JSON's Auckland URL uses `page=448214`, not adopted because page-ID commonality across instances is unverified.

## 3. Footnotes

- ***1 (concerning symptoms and signs)** — encoded, because P2 bullet 2 depends on it (and AM-1 by reading, Q9). Each of the 12 items is one boolean indicator whose text is the item as printed (trailing full stop dropped). Qualifiers inside an item (">3 weeks", "more than 1 cm", "in a patient with other lung cancer symptoms or signs or risk factors") are judged within the indicator, not computed (Q4). "One or more" is a three-valued any-of: one known yes → true; none known but some unanswered → null; all no → false (`Length(... return all)`, the CT CAP counting pattern). The PlanDefinition renders them as a one-or-more group under P2 bullet 2 and repeats the full *1 text as a note.
- ***2 (risk factors)** — not encoded. No criterion gates on it: it is referenced by the Guidance ("or sooner if the patient has risk factors", "especially if the patient has risk factors") and, without a marker, inside *1 item 12, whose indicator carries it. P2 bullet 2's "current smoker" is its own indicator and is narrower than *2's "Current or past smoker". Carried verbatim as a note on the Guidance action.
- ***3 (safety netting)** — not encoded; advice, no criterion. Carried as a note on the Guidance action and on AM-1 (the scenario it describes).
- ***4 (local pathways – direct to PET CT)** — not encoded; it explains P2 bullet 5's HealthPathway condition, which is its own indicator. Carried as a note on P2 bullet 5.
- Footnote text in notes is verbatim with line breaks and runs of spaces collapsed; list items are joined with their printed full stops (a full stop added after items printed without one).

## 4. Not encoded (and why)

- **AM-3 "Initial presentation ..."** — no define; shown as published wording in the alternative-management block (Q8).
- **Māori equity provision (Guidance, p13)** — "a lower threshold ... should be considered": Guidance, no threshold stated (Q12).
- **Modifiers (KI-05)**: "especially if the patient has risk factors*2" (Guidance); "particularly in combination with haemoptysis, weight loss or persistent thrombocytosis" (Guidance); "(preferably same or next day)" (Guidance); "(e.g. bulky hilum)" (P2-3); "(e.g. weight loss, fatigue)" (AM-2); "(e.g. intrapulmonary lymph node, benign pattern of calcification)" (AM-4); "(e.g. suspected pleural effusion)", "e.g. hypercalcaemia, …" (*1 items 9, 11); *2's "especially more than 15 years", "especially head and neck cancer"; *3's "especially clusters of symptoms and especially in patients at increased risk".
- **Guidance sentences** — "should be considered … which last more than 3 weeks or sooner if …" and the CXR-sensitivity statement are advice; Guidance text is in the PlanDefinition only.
- **Instructions on outcomes** — "refer for urgent CT chest and for respiratory assessment" (P2-1), "seek advice from secondary care respiratory team …" (AM-1), "See CT Chest/Abdomen/Pelvis HealthPathway" (AM-2), "refer to secondary care for management advice" (AM-4): wording, not conditions.
- **population.cql** — not done. None of the indicators is lab- or imaging-history data the population pattern covers (CXR findings and report recommendations are report text, not coded results), and `run-tests-sites.mjs` does not yet support record-backed scenarios.

## 5. Source versus published JSON / census

Cross-check: `documents/reference/pdf-criteria-all.json` entry `ct_chest` (under exam `ct`). Differences are reported, not resolved toward the JSON.

- **P3 heading**: PDF "P3: non-deferrable, imaging or intervention that must be completed within 6 weeks of receiving referral"; JSON "P3 non-deferrable imaging or intervention that must be completed within 6 weeks of receiving referral." (colon and comma dropped, full stop added). Bundle uses the PDF.
- **P2 bullet 2** (`ctch_p2_2`): the JSON flattens the stem and three sub-bullets into one string and writes "years'" with a straight apostrophe; the PDF prints sub-bullets and "years’". Bundle keeps the structure (Q2).
- **Acute row** (`ctch_em_1`, `ctch_em_2`): tickable `cb` items in the JSON; in the bundle a display-only banner, logic national (RF-01/RF-02).
- **Guidance**: the JSON splits it into `inlineGuidance` + `guidanceNarrative`, drops the heading "Guidance: Lung Cancer Imaging", and adds a full stop after "risk factors*2". Bundle uses the PDF.
- **shortLabel** for `ctch_p2_1` reads "Unexplained haemoptysis with normal CXR"; the PDF says initial investigations including CXR "fail to identify a cause", which is not the same as a normal CXR. The bundle does not use shortLabels.
- **Not funded**: JSON `outOfCriteriaNote` and `notFundedDetail` are empty; the PDF prints no not-funded row. Agree.
- **Alternative management** and **footnotes**: wording agrees (JSON joins the bullets into one string; whitespace differs).
- **HealthPathways**: JSON `healthPathwaysUrl` (Auckland, page 448214); bundle `TBC-page-id` (see §2).
- **Item IDs**: the JSON uses `ctch_*`; `instructions/archive/indication-groupings.md` uses `ctc_p2_*` for the same items. Not used by the bundle.
- **Census** (`instructions/archive/compound-criteria-phase0-findings.md` Appendix A rows 3-7): `ctch_p2_2` A(3), `ctch_p2_3`/`p2_4`/`p2_5`/`p3_1` A(2). The bundle agrees on all-of for each; it splits row 3's "≥1 concerning symptom 6wks" into any-of *1 + new onset + persistence (Q3), and also decomposes `ctch_p2_1` (not in the census) into five atoms (Q5).

## 6. Matrix cases and worked examples

None. `documents/CRR_Test_Case_Results_Matrix_v2.xlsx` (sheets Test Case Results, Michaela Model Comparison, Structured Re-Eval, Corrections Log) has no CT Chest case; exam types present are CT CAP, CT Head, CT KUB, CT Sinus, CXR, US (several), X-ray hand/hip/knee/spine. RP-001 (CT CAP, "Ex-smoker") and CR-001/LP-001 (CXR) touch lung-cancer symptoms but were assessed against other sites. No STEP-3 worked example in `instructions/arch-mig-prompt-decomposition.md` applies. `scenarios.mjs` therefore starts with pathway coverage: 27 scenarios (each P2/P3 pathway met; not-met and insufficient cases; the 55/15/16 age boundaries; the three evaluated redirects; redirect precedence over P2 bullet 2 and over the specialist-advice gateways; strict vs inferred; national red flag ignored).

## 7. PDF text extraction

The plain-text extraction was reliable for wording but interleaves the Source column into the Clinical Presentation column on pp.13-14. Pages 12-16 were re-extracted with `pypdf` layout mode to confirm: the P2 row starts on p13 (timeframe cell and Guidance) and its bullets are on p14; P2 bullet 2 has one stem bullet and three "o" sub-bullets; the *1 and *3 markers are superscripts that layout mode places on a line of their own; "non-urgent" (P3-2) and "x-ray" (AM-3) are hyphenated across lines.

## 8. Vocabulary

- **add** (30): `patient.currentSmoker`; the 12 *1 items; `symptom.newOnset`, `symptom.persistentSixWeeksDespiteTreatment`, `symptom.haemoptysisWithoutChestInfection`, `symptom.nonSpecificSymptomsConcerningForCancer`; `workup.upperAirwayBleedingExcluded`, `workup.initialInvestigationsCauseNotFound`, `workup.cxrNormal`, `workup.cxrIndeterminateAbnormality`, `workup.cxrPersistentConsolidationFollowUp`, `workup.cxrIsolatedPulmonaryNodule`, `workup.cxrNoduleNotConfirmedBenign`, `workup.radiologyReportRecommendsImaging`, `workup.rePresentation`, `workup.ctIncidentalNoduleFollowUp`, `workup.ctNoduleReportConfirmsBenign`; `advice.urgentStagingCtRecommended`, `advice.localHealthPathwayAdvisesCt`.
- **addSite** (3): `patient.age` p14, `workup.bloods` p14, `advice.nonUrgentImagingRecommended` p14. (`workup.cxr`, `redflag.haemoptysisPresent` and `advice.urgentImagingRecommended` already list this site.)
- **addAttestation** (1, an extra key beyond `add`/`addSite`): `symptom.nonSpecificSymptomsConcerningForCancer` to `attestationIndicators`; its entry carries `attestationWording` (check rule AD-23 requires it).
- Merged centrally into vocabulary 1.3.0 (KI-78). X-ray Chest - Adult now shares several *1-list linkIds, and its chest-infections item was renamed to `symptom.chestInfectionsRepeatedOrUnresolved`, whose vocabulary text is now X-ray Chest’s "Recurrent or unresolved chest infections"; this site’s Questionnaire keeps CT Chest’s printed "Repeated / or unresolved chest infections". Still divergent and left to the vocabulary owner (KI-78 a, b): smoking (`patient.currentSmoker` here, `patient.smokingStatus` in US Renal) and composite *1 items here versus item + duration in X-ray Chest.
- Requested of the vocabulary owner (fix round): `workup.rePresentation` text changed in this site’s Questionnaire and `vocabulary-additions.json` to "Patient re-presents with the symptoms or signs being referred (this is not the initial presentation)" (the earlier "these symptoms or signs" had no antecedent); `vocabulary/indicators.json` still has the old text.

## 9. Build gates

From `tooling/criteria-bundle/tooling`: `npm run build && npm test && npm run check` — see the session report for the output. Wiring: one `translate.mjs` line in `package.json` `build`; a `ct-chest-adult` entry in `publish.mjs` `MANIFESTS` (`source.type: pdf`, pages 12-16). Not published.

## 10. Adjacent problems noticed

- None open. The renderer gap recorded at transcription (no `P3_NON_DEFERRABLE` mapping in `advisory-render.js`) is fixed: `DETERMINATION_TO_DEFINE` now maps every AD-36 code, including `P3_NON_DEFERRABLE` → `Meets P3 Criteria` (CL-57).

## 11. Fix round after second-session review (2026-10-16)

- Attestation wording for `symptom.nonSpecificSymptomsConcerningForCancer` uses the PDF’s "symptoms and signs" (coordinator commit 05da6c5; confirmed in `vocabulary-additions.json` and `indicators.json`).
- REVIEW Q10 and Q11 now name the cases where a redirect overrides a specialist-advice gateway (CTCH-S16: incidental-CT-nodule redirect over P3 bullet 2; new CTCH-S27: non-specific-symptoms redirect over P2 bullet 6; P2 bullet 5 likewise).
- P2 bullet 1 in the PlanDefinition: the two stitched component rows ("Initial investigations including chest x-ray", "Initial investigations fail to identify a cause") are replaced by one row carrying the printed text "And initial investigations including chest x-ray fail to identify a cause", with inputs `workup.cxr` and `workup.initialInvestigationsCauseNotFound`.
- REVIEW Q17 added for the shared `workup.initialInvestigationsCauseNotFound` (parity with Q6).
- `workup.rePresentation` Questionnaire text no longer says "these symptoms or signs" (§8).
- R2 (Viewer tick boxes): checked; no PlanDefinition row has a sole boolean input that the CQL reads negated. The one negated read (`workup.ctNoduleReportConfirmsBenign`, "unless … confirms benign") is not a PlanDefinition input. No change.
- R3 (referrer-visible strings): removed the engineering label on the acute-assessment row ("Evaluated by the national red-flag library …") and the engineering description on the "Initial presentation" redirect row ("… not evaluated by the engine … REVIEW Q8"); both facts are recorded here (§2, §4) and in signoff.md Q8. Remaining `documentation.display` notes are published wording (footnotes *1–*4, Overview p5 adviser sentence); no priority code appears in any of them.
- R4 (stale text): §2 and §10 updated for AD-36 / KI-76 / CL-57; no pre-rename linkId is used by this site.
