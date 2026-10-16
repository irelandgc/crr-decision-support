# Transcription notes — US Pelvis - Adult (`us-pelvis-adult`)

**Status:** NOT CLINICALLY REVIEWED. W1 demo transcription for staging only (Gary, 2026-10-15; AD-35). Every genuine ambiguity is a REVIEW Qn (`signoff.md`, also listed in the library header).

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf` — National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026, section "US Pelvis -Adult", pp.44-51 (rows pp.44-49, footnotes *1-*5 pp.49-51; US Renal starts p52). Published exam/site id `us_pelvis`; bundle key `us-pelvis-adult`; library `CRR_USPelvis_Adult`.

**Text extraction.** The plain-text extraction was read for pp.44-51. Pages 44-49 were re-extracted in layout mode (`pypdf`, `extraction_mode="layout"`) because the plain text interleaves the Timeframe and Source columns with the Clinical Presentation column (p45 sources "HealthPathway Canterbury / Lead Region-Abortion / … Early Pregnancy" split across the Acute 48h bullets; p46 citations split across the P2 guidance and P3 bullets; p47 "O-RADS US v2022" citation across the S2 bullets). Both extractions give the same clinical wording; the layout pass settled which column each fragment belongs to and confirmed the bullet nesting of P2 bullet 5, P3 bullet 4, P3 bullet 5 and P3 bullet 7. The PDF itself was not rendered visually (no renderer in the container).

**Output.** 48 encoded criteria — Acute 24h 2, Acute 48h 2, P2 7, P3 12, P4 3, S2 3, S3 3, redirects 6, not-funded 10 — plus 2 printed rows deliberately not encoded (S2 and S3 advice gateways, REVIEW Q3). 136 ELM definitions in all (including plumbing, row compositions, missing-information lists and the trace). 89 Questionnaire items: 5 reused vocabulary linkIds and 84 proposed additions. 90 scenarios (12 matrix cases in 13 scenarios, 1 STEP-3 worked example, 76 coverage scenarios).

## 1. Atoms

AD-17 column: "cand." marks an indicator that rests on the referrer's clinical judgement and is a candidate for the attestation category (REVIEW Q22). None is applied to `attestationIndicators`.

| Source wording (page) | Indicator | New? | AD-17 |
|---|---|---|---|
| Age conditions (p46, p49; paediatric band Overview p4) | `patient.age` | existing | |
| "post-menopausal (no period for twelve consecutive months)" (p46); pre-/post-menopausal (pp.47-49) | `patient.postmenopausal` | new | |
| "Perimenopausal woman" (p46) | `patient.perimenopausal` | new | |
| "on continuous combined menopause hormone therapy (MHT)" (p45) | `patient.mhtContinuousCombined` | new | |
| "on combined cyclical MHT" (p46) | `patient.mhtCyclicalCombined` | new | |
| "more than 6 months since starting therapy / MHT" (p45, p46); "first 3 to 6 months after starting MHT" (p49) | `patient.mhtMonthsSinceStart` | new | |
| *5 "For Māori and Pacific peoples … significantly higher rate" (p50) | `patient.maoriOrPacificEthnicity` | new | |
| *5 "BMI 30 or higher" (p50) | `patient.bmi` | new | |
| *5 "Polycystic ovary syndrome (PCOS)" (p50) | `patient.pcosDiagnosed` | new | |
| *5 "Chronic anovulation (e.g. fewer than 4 menstrual cycles in 12 months)" (p50) | `patient.chronicAnovulation` | new | |
| *5 "Nulliparity in women older than 35 years" (p50) | `patient.nulliparous` + `patient.age` | new | |
| *5 "Early menarche … or late menopause (after age 55 years)" (p50) | `patient.earlyMenarcheOrLateMenopause` | new | |
| *5 "Estrogen‐secreting tumour" (p50) | `patient.estrogenSecretingTumour` | new | |
| *5 "Long‐standing unopposed estrogen menopause hormone therapy (MHT)" (p50) | `patient.unopposedEstrogenMhtLongStanding` | new | |
| *5 "Tamoxifen therapy" (p50) | `patient.tamoxifenTherapy` | new | |
| *5 "Diabetes mellitus" (p51) | `patient.diabetes` | new | |
| *5 "Iron deficiency anaemia (Hb less than 100)" (p51) | `lab.ironDeficiencyAnaemia` | new | |
| *5 "Family history of endometrial, ovarian, breast, or bowel cancer" (p51) | `patient.familyHistoryEndometrialOvarianBreastBowelCancer` | new | |
| "Patients acutely unwell from a suspected gynaecological cause" (p44) | `symptom.acutelyUnwellSuspectedGynaeCause` | new | cand. |
| "IUD strings missing and not visible on examination" (p45); "IUD strings not visible on exam" (p47) | `symptom.iudStringsNotVisible` | new | |
| "IUD breaks on removal attempt and only a fragment is removed" (p45, p47) | `symptom.iudFragmentRetained` | new | |
| "symptoms suggestive of possible perforation including cramping pain, discharge, unexplained bleeding" (p45); "patient is asymptomatic" (p47, as false) | `symptom.iudPerforationSymptoms` | new | |
| "Suspected ongoing pregnancy more than 14 days post abortion or miscarriage" (p45) | `symptom.ongoingPregnancySuspectedPostAbortionOrMiscarriage` | new | |
| "Urine HCG is greater than 1000 IU on testing at 14 days post-procedure, miscarriage, or early medical abortion (EMA)" (p45) | `lab.urineHcg.value` | new | |
| "Serial serum bHCG remains high after early medical abortion (EMA) or miscarriage" (p45) | `lab.serumBhcg.remainsHigh` | new | |
| "Secondary care clinician or PCRL or radiologist advises referral for same or next day ultrasound pelvis" (p45) | `advice.acuteImagingRecommended` | existing | |
| "Pelvic mass on examination" (p45); "No palpable pelvic mass" (p45, p46); "A pelvic mass is suspected on examination" (p45); "pelvic mass" (p46); "in the absence of a clinically palpable mass" / "pelvis mass is present" (p48) | `symptom.pelvicMassPalpable` | new | |
| "suspicious of cancer" (p45); "low suspicion of cancer" (p46, as false) | `symptom.pelvicMassSuspiciousOfCancer` | new | cand. |
| "Postmenopausal bleeding (i.e. vaginal bleeding after more than 12 months' amenorrhoea around the expected age of menopause (approximately 50 years))" (p45) | `symptom.postmenopausalBleeding` | new | |
| "Persistent postmenopausal bleeding" (p45) | `symptom.vaginalBleedingPersistent` (+ `patient.postmenopausal`) | new | |
| "new abdominal or pelvic symptoms*2 warranting consideration of ovarian cancer … persistent or frequent basis" (p45, p46; *2 p49) | `symptom.ovarianCancerSymptomsPersistent` | new | cand. |
| "for more than 6 weeks" (p46) | `symptom.ovarianCancerSymptomsWeeks` | new | |
| "the Ca-125 result is 35 units/mL or greater" (p45) | `lab.ca125.value` | new | |
| "Abnormal uterine bleeding (AUB) *3" (p45, p46, p49; *3 p50) | `symptom.abnormalUterineBleeding` | new | |
| "non-uterine causes have been excluded*4" (p45, p46; *4 p50) | `workup.nonUterineBleedingCausesExcluded` | new | |
| "at least two / one or more / at least one / without (any) / no risk factors*5" (pp.45-49) | computed from the 12 risk-factor indicators | — | |
| "no prior imaging has been done since the onset of symptoms" (p45) | `imaging.any.sinceSymptomOnset` | new | |
| "Atypical (AG2) endometrial cells reported on cervical screening cytology" (p46) | `lab.cytology.atypicalEndometrialCells` | new | |
| "advises referral for urgent US pelvis" (p46) | `advice.urgentImagingRecommended` | existing | |
| "have not responded to first-line treatment for AUB" (p46) | `workup.aubFirstLineTreatmentResponded` | new | |
| "trialled for at least three months" (p46) | `workup.aubFirstLineTreatmentMonths` | new | |
| "where first line treatment has not been trialled" (p49) | `workup.aubFirstLineTreatmentTrialled` | new | |
| "ongoing irregular bleeding" (p46) | `symptom.irregularBleedingOngoing` | new | |
| "bleeding outside the time of progestogen withdrawal" (p46) | `symptom.bleedingOutsideProgestogenWithdrawal` | new | |
| "despite a trial of increased progestogen" (p46) | `workup.increasedProgestogenTrialled` | new | |
| "Benign-appearing endometrial cells reported on cervical smear" (p46, p49) | `lab.cytology.benignEndometrialCells` | new | |
| "The patient is symptomatic (e.g. intermenstrual, post-coital, irregular or heavy bleeding)" (p46); "asymptomatic" (p49, as false) | `symptom.gynaeSymptomatic` | new | |
| "no abnormality on exam / on examination" (p49, as false) | `symptom.examinationAbnormality` | new | |
| "the patient has not been recently investigated" (p46, as false) | `workup.recentlyInvestigated` | new | |
| "Suspected ovarian cyst" (p46) | `symptom.ovarianCystSuspected` | new | |
| "unilateral pelvic pain" (p46) | `symptom.pelvicPainUnilateral` | new | |
| "for more than four weeks" (p46); "Pelvic pain for more than six weeks" (p47) | `symptom.pelvicPainWeeks` | new | |
| "unilateral tenderness" (p46) | `symptom.pelvicTendernessUnilateral` | new | |
| "unrelated to menstrual cycle" (p47) | `symptom.pelvicPainUnrelatedToMenstrualCycle` | new | |
| "PID excluded as the cause of the pain as per local PID HealthPathway" (p47, as false); "Pelvic inflammatory disease (PID) in the absence of …" (p48, as true) | `symptom.pid` | new | |
| "Primary amenorrhoea (i.e. absence of menarche by age 16 years, or age 14 years if absent secondary sexual characteristics)" (p47) | `symptom.primaryAmenorrhoea` | new | |
| "(secondary) new onset dysmenorrhoea" (p47) | `symptom.secondaryDysmenorrhoeaNewOnset` | new | |
| "debilitating pain persists" (p47) | `symptom.dysmenorrhoeaDebilitatingPainPersists` | new | |
| "despite a three-month trial of medical management as per local Dysmenorrhoea HealthPathway" (p47) | `workup.dysmenorrhoeaMedicalManagementMonths` | new | |
| "advises referral for routine ultrasound pelvis" (p47) | `advice.nonUrgentImagingRecommended` | existing (Q16) | |
| "Polycystic ovary syndrome (PCOS) suspected" (p47) | `symptom.pcosSuspected` | new | |
| Rotterdam "hyperandrogenism, polycystic ovaries, irregular menses" (p47) | `symptom.hyperandrogenism`, `symptom.polycysticOvaries`, `symptom.irregularMenses` | new | |
| "Known fibroid larger than 5cms" (p47) | `symptom.knownFibroidSizeCm` | new | |
| "becomes symptomatic with pelvic pressure, back pain, dyspareunia, or urination difficulties after commencing MHT" (p47) | `symptom.fibroidSymptomaticAfterStartingMht` | new | |
| "advises referral for deferrable, non-urgent ultrasound pelvis" (p47) | `advice.deferrableImagingRecommended` | new (Q16) | |
| "follow-up scan(s)" (pp.47-49) | `workup.followUpScan` | new | |
| "6-month / 12-month … according to the ACR published table or ACR mobile phone app" (p47, p48) | `workup.followUpIntervalMonths` | new | |
| "O-RADS 2 ovarian or adnexal cysts" (p47, p48) | `symptom.ovarianCystORads2` | new | |
| "simple" / "non-simple ovarian cyst" (p49) | `symptom.ovarianCystSimple` | new | |
| "less than 3 cm / 5 cm in diameter", "up to 5cms diameter" (p49) | `symptom.ovarianCystSizeCm` | new | |
| "asymptomatic" cyst / endometrioma (p48, p49, as false) | `symptom.ovarianCystSymptomatic` | new | |
| "haemorrhagic cyst" (p47, p49) | `symptom.haemorrhagicCyst` | new | |
| "typical-appearing" (p49) | `symptom.haemorrhagicCystTypicalAppearing` | new | |
| "suspected dermoid cyst" (p48) | `symptom.dermoidCystSuspected` | new | |
| "suspected asymptomatic endometrioma" (p48) | `symptom.endometriomaSuspected` (+ `symptom.ovarianCystSymptomatic` false) | new | |
| "asymptomatic endometrial polyps detected as incidental finding on US" (p47) | `symptom.endometrialPolypIncidental` | new | |
| "Suspected retained products of conception (RPOC)" (p48) | `symptom.rpocSuspected` | new | |
| "with persistent or heavy bleeding after abortion or miscarriage" (p48) | `symptom.bleedingPersistentOrHeavyPostAbortionOrMiscarriage` | new | |
| "Suspected endometriosis" (p48) | `symptom.endometriosisSuspected` | new | |
| "Primary dysmenorrhoea" (p48) | `symptom.primaryDysmenorrhoea` | new | |
| "Cervical polyps" (p48) | `symptom.cervicalPolyp` | new | |
| "Secondary amenorrhoea" (p48) | `symptom.secondaryAmenorrhoea` | new | |
| "significantly raised androgens" (p48) | `lab.androgens.significantlyRaised` | new | |
| "Routine follow-up of known fibroids" (p49) | `funding.routineFibroidFollowUp` | new | |
| "Subfertility" (p49) | `funding.subfertility` | new | |
| "Screening ultrasound scan for a family history of ovarian cancer" (p49) | `funding.ovarianCancerFamilyHistoryScreening` | new | |
| "Erratic, unscheduled bleeding … after starting MHT" (p49) | `symptom.erraticUnscheduledBleedingOnMht` | new | |
| Overview p5: name and role of the adviser | `advice.adviserNameRole` | existing | |
| "Clinically unstable patients with suspected gynaecologic or pelvic cause" (p44) | national RF-11 `redflag.clinicallyUnstableGynaePelvicCause` — not in this bundle | existing | |

**Vocabulary additions.** All 84 new indicators are in `vocabulary-additions.json` (`add`), and applied to `vocabulary/indicators.json` in this worktree as one-line entries appended at the end of `indicators[]`. `addSite` is empty: every reused indicator (`patient.age`, `advice.acuteImagingRecommended`, `advice.urgentImagingRecommended`, `advice.nonUrgentImagingRecommended`) already lists `us-pelvis-adult`; `advice.adviserNameRole` is an Overview concept and lists no site. Six existing entries list `us-pelvis-adult` but are **not used** by this transcription: `patient.sex` (p44; Q24), `symptom.fever` (p44; "+/- low grade fever" is modifier wording), and `weightloss.present`, `symptom.abdominalPain`, `symptom.fatigue`, `symptom.persistentAbdominal` (p49; footnote *2 items, not decomposed under Q9). Those attributions are stale for this reading; removing them is a vocabulary-owner edit, not made here.

Naming notes for the vocabulary owner: the fixed `groups` list has no home for history, medication or background, so MHT, menopausal status and the *5 background risk factors are under `patient`; request-purpose items that exist only for not-funded rows are under `funding`; `imaging.any.sinceSymptomOnset` uses a window outside `_convention.priorImaging`. Many additions are single-site (vocabulary REVIEW Q16 asks the same question of earlier entries); site-local would be the alternative. `advice.deferrableImagingRecommended` conflicts with vocabulary REVIEW Q26 (Q16 here).

## 2. Modelling decisions

- **Precedence (Q1, Q2).** Not-funded → redirect → paediatric (age 15 or under, Overview p4) → age unknown → most urgent met timeframe → criteria not met (every timeframe definitively false) → insufficient. A less urgent met row is returned even when a more urgent row is unresolved; the unresolved row's indicators are listed (EQ-001). Redirects are reported in `activeRedirects` even when the determination is not-funded (CT CAP behaviour).
- **Determination codes.** `ACUTE_24H`, `ACUTE_48H`, `P2_URGENT`, `P3_NON_DEFERRABLE`, `P4_DEFERRABLE`, `S2_TIME_SENSITIVE` (priority code S2), `S3_TIME_SENSITIVE` (S3). New codes; other W1 sites may choose differently and the coordinator should converge them. The S2/S3 codes carry no "S2"/"S3" because both renderers strip only a leading P-code from referrer text (see §6).
- **Priority timeframe text** is the printed Timeframe column with the code removed (GEN-004). Acute rows have no priority code (none is printed).
- **Missing information.** A row is *engaged* when one of its presenting indicators is answered true (any evidence status) or, for duration/size rows, answered at all. An engaged, unresolved row lists the indicators that would settle it (only unresolved OR-branches are listed). Unengaged rows list nothing — listing every indicator of an eight-page section would bury the useful ones. With a met determination only more urgent engaged rows are listed, plus `advice.adviserNameRole` whenever an advice gateway is met without a name. Consequence: an unengaged referral returns insufficient information with an empty list (Q25).
- **Unconfirmed exclusions.** Only redirects the referral raises but cannot settle (e.g. endometriosis suspected, palpable mass not stated → `symptom.pelvicMassPalpable`).
- **Risk factors (*5).** Twelve booleans (Q10 adds ethnicity); "BMI 30 or higher" is computed from `patient.bmi`; "nulliparity in women older than 35" from `patient.nulliparous` and age. Three-valued counting as CT CAP's labs (`return all`, `Length` not `Count`): "at least two" is true at two known, null while unknowns could reach two; "no risk factors" needs all twelve known false.
- **Rotterdam "only one of three"** is true only when one is known true and two known false.
- **One concept, two roles (KI-01):** `symptom.iudPerforationSymptoms` (Acute 24h true / P3 false), `symptom.pid` (redirect true / P3 false), `symptom.pelvicMassSuspiciousOfCancer` (P2 true / P3 false), `symptom.pelvicMassPalpable` (five phrasings, Q11), `symptom.gynaeSymptomatic` and `symptom.ovarianCystSymptomatic` (false = asymptomatic).
- **Durations** are numbers (weeks or months) per the vocabulary convention; converting "six months" to weeks is an inference under the extraction contract (MW-008 runs under `inferred` for that reason).
- **Lab values** (`lab.ca125.value`, `lab.urineHcg.value`) are typed `decimal` so the library can read them (the existing `lab.*.value` entries are `quantity`, which the CT CAP library captures but does not read). No unit is asserted on the answer.
- **PlanDefinition.** S2/S3 block titles omit the leading code (carried in the priority-code coding); P2/P3/P4 titles keep it verbatim as CT CAP does (the renderers strip it). Footnotes are `documentation.display` notes on the rows that cite them. The S2/S3 advice rows are present without condition or input, with a "not encoded" note. The HealthPathways page id is the `TBC-page-id` placeholder (the published JSON's Auckland link uses page 15608; not taken from a cross-check).
- **population.cql: not done.** No indicator here has a retrieval path that `run-tests-sites.mjs` supports (it rejects record-backed scenarios); Ca-125, HCG and cytology could be populatable later.

## 3. Not encoded (modifiers and out-of-logic wording)

| Wording (page) | Why |
|---|---|
| Acute 24h sub-bullets "sudden onset of severe pelvic pain, clinically stable and suspected ovarian torsion or ovarian cyst accident (e.g. …)" and "possible endometritis from RPOC *1 … outside the two-week post miscarriage maternity-funded scan window" (p44) | "including" = illustrative (Q4); maternity window not encoded (Q5) |
| "+/- low grade fever, +/- bleeding" (p44); "+/- Ongoing symptoms of pregnancy (e.g. nausea, breast tenderness)" (p45) | "+/-" — does not affect the logic |
| "Consider seeking gynaecology advice or acute gynaecology assessment if admission may be more appropriate." (p44) | advice to the referrer, not a condition |
| "including cramping pain, discharge, unexplained bleeding" (p45) | illustrative |
| "especially if bHCG has increased between a baseline test done within 72 hours of Mifepristone and a follow-up test 8-16 days after ingestion" (p45) | "especially" — modifier (KI-05) |
| "(N.B. a decrease in serum bHCG of 80% or more between baseline and follow-up tests excludes ongoing pregnancy)" (p45) | explains "remains high"; not a separate condition |
| "around the expected age of menopause (approximately 50 years)" (p45) | carried in the indicator definition; not an age check (Q7) |
| "irrespective of menopause status" (p45); "in women of any age and menopause status" (p46); "in both pre- and post-menopausal woman" (p47, p48) | population scope |
| *2 "Irritable bowel symptoms, especially if new onset and aged older than 50 years" (p49) | "especially" — modifier; *2 not decomposed (Q9) |
| "e.g." lists in the symptomatic (p46) and chronic anovulation (p50) items | illustrative |
| *3 "The condition may be acute (urgent referral) or chronic (experienced for 6 months or more)." and the *3 sub-definitions (p50) | define AUB for the referrer; carried in the footnote note |
| *1 "If systemically unstable and/or severe persistent pelvic pain refer for acute assessment without requesting imaging" (p49) | national library owns acute assessment (vocabulary F-08; Q6) |
| Guidance p44 (five paragraphs) and p46 (Māori and Pacific Peoples) | guidance (Q20) |
| Not-funded bullet 9: "All women with Lynch Syndrome … should be referred to secondary care … insufficient evidence to warrant routine pelvic US screening in asymptomatic women." (p49) | explanatory text inside the not-funded item; shown verbatim |
| S2 and S3 advice gateways (p47, p48) | same wording under two timeframes (Q3) |

## 4. Source versus `pdf-criteria-all.json` (`us_pelvis`)

Reported only; nothing resolved by preferring the JSON.

- Item counts agree: 1 acute-assessment, 2 Acute 24h, 2 Acute 48h, 7 P2, 12 P3, 3 P4, 4 S2, 4 S3; 6 redirects and 10 not-funded items in `alternativeManagement` / `notFundedDetail`.
- The JSON flattens nesting into prose: `uspv_24_1` joins the two sub-bullets with ";"; `uspv_48_1` drops the "OR" layout; `uspv_p2_5`, `uspv_p3_4`, `uspv_p3_5`, `uspv_p3_7` run their sub-bullets into one string. Wording otherwise matches the PDF.
- `outOfCriteriaNote` is a paraphrase ("simple cyst follow-up below thresholds", "early MHT-related erratic bleeding") — not published wording; the PlanDefinition uses the PDF bullets.
- `inlineGuidance` + `guidanceNarrative` carry the p44 and p46 guidance verbatim.
- `healthPathwaysUrl` points at an Auckland HealthPathways page (`page=15608`); the PDF prints no page id.
- The JSON has no Source column citations; the PlanDefinition carries the printed ones (including the literal "&nbsp;" in the ajog.org citation title on p46, a typesetting artefact in the PDF).
- The older Viewer theme map (`instructions/archive/indication-groupings.md`) uses a different item numbering (`usp_24_3`, `usp_p3_10` "Specialist-endorsed"), so its themes were used as a vocabulary, not row by row.

## 5. Matrix cases found

Sheets read: "Test Case Results", "Michaela Model Comparison", "Structured Re-Eval", "Corrections Log" of `documents/CRR_Test_Case_Results_Matrix_v2.xlsx`. US Pelvis cases: LP-003, LP-004, DG-004, DG-005, MW-001, MW-002, MW-004, MW-006, MW-007, MW-008 (recorded as "US Pelvis (paed)" but assessed under adult criteria — the patient is 24), EQ-001, EQ-002 (Structured Re-Eval only; note text from `scripts/ta-src-01-baseline-runner.mjs`). Answers were labelled by this session from the matrix note text (a clinician-labelled set is slice 9's job).

| Case | Evaluator expected | Engine (literal) | Divergence |
|---|---|---|---|
| LP-003 | at_risk | strict: insufficient, asks for documented PMB; inferred: P2 | PMB labelled inferred (on HRT, amenorrhoea not stated). Under 'inferred' P2 via bullet 2 (Q7) |
| LP-004 | declined / at_risk | insufficient; asks for string examination, fragment, perforation symptoms | none |
| DG-004 | declined | insufficient; asks for age, non-uterine causes, mass/imaging, each risk factor | stated count of risk factors unusable (Q23) |
| DG-005 | declined + flag contradiction | P2 | "PMB" at 21: the definition's "around the expected age of menopause" is not an age check (Q7); contradiction-flagging is outside the engine (extraction contract rule 11) |
| MW-001 | at_risk or declined | insufficient; Ca-125, mass, duration, investigation; endometriosis redirect unconfirmed | none |
| MW-002 | at_risk | insufficient (run under 'inferred') | none |
| MW-004 | declined | insufficient, nothing to add | Q25 |
| MW-006 | declined (out of scope) | insufficient, nothing to add | Q25; no row covers a dating scan before medical abortion |
| MW-007 | at_risk (Ca-125 pending) | insufficient; asks for Ca-125, non-uterine causes, risk factors | none |
| MW-008 | proceeds (adult) | insufficient on the excerpt (run under 'inferred') | matrix holds only an excerpt; P3 pelvic pain needs "unrelated to menstrual cycle" and PID excluded; primary dysmenorrhoea redirect unconfirmed (mass) |
| EQ-001 | proceeds, P2 with equity provision | P3; P2 waits on non-uterine causes | note does not state non-uterine causes excluded (P2 bullet 5); ethnicity counted (Q10) |
| EQ-002 | proceeds, no equity provision | insufficient; asks for non-uterine causes | P2 bullet 5 and P3 bullet 1 both need it |

STEP-3 worked example (`instructions/arch-mig-prompt-decomposition.md` item 23; system prompt v2.3.0 line 97): "General post-menopausal bleeding pathway is fully met → verdict is \"proceeds\" at P2, even if MHT-specific variant requires type and duration details." Scenario `USP-STEP3-pmb-vs-mht`: documented PMB, MHT type and duration unknown → P2, nothing asked. The literal reading (Q7) agrees with it. Note the tension with LP-003, whose evaluator expected at_risk for a post-menopausal woman on HRT with PV bleeding ("under clinical ruling" in the matrix); the old prompt also treated "post-menopausal" as satisfying the PMB definition (v2.3.0 line 57), an equivalence that is not in `concept-equivalence-v1.2.md`, so the LP-003 PMB answer is labelled inferred here.

## 6. Adjacent problems (flagged, not fixed)

- `public/crr-criteria/shared/advisory-render.js` maps only `P2_URGENT`, `ALTERNATIVE_MANAGEMENT`, `NOT_ROUTINELY_FUNDED` to PlanDefinition wording; every other determination is humanised from its code. Both renderers strip only `^P[1-4]` from referrer text, so any S-coded title or determination would show the code to referrers (GEN-004); this bundle avoids S-codes in titles and determination names for that reason.
- `public/crr-criteria/api/engine.ts` `isPriorityDetermination` is `/^P\d/`: Acute and time-sensitive determinations do not count as "priority" for cross-exam recommendations.
- Six stale `us-pelvis-adult` attributions in the vocabulary (§1).

## 7. Build gates

`npm run build && npm test && npm run check` from `tooling/criteria-bundle/tooling`, all green at commit (results in the session report). `npm run publish` not run.
