# Transcription notes — US Renal - Adult (`us-renal-adult`)

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf` — National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026, section "US Renal - Adult", **pp.52–55** (US Scrotum starts p56). Published exam/site id `us_renal`; bundle key `us-renal-adult`; library `CRR_USRenal_Adult`.

**Status:** NOT CLINICALLY REVIEWED. W1 demo transcription for staging only (Gary, 2026-10-15; AD-35). Ambiguities are encoded on their most literal reading and listed as REVIEW Q1–Q22 (header of the `.cql`, and `signoff.md`). No row was left out of the logic: every printed row has a defensible literal reading.

**Text extraction.** All four pages were re-extracted with `pypdf` `extraction_mode="layout"`, because the plain extraction interleaves the Source column into the Clinical Presentation column (e.g. "Canterbury HealthPathway" between the Acute bullets; ten reference titles split through the P3 bullets on p52–p53) and the P3 and not-funded rows continue onto the next page with no Timeframe label. The layout pass confirmed which bullets belong to which row and sub-bullet. It found no wording difference from the plain text. Two printed double spaces are kept verbatim ("stone).  Arrange", "(i.e.  more than 3").

## 1. Atoms

Source sentence (verbatim, page) → indicator(s) → define. New indicators are in `vocabulary-additions.json`.

| Source (page) | Indicator(s) | Define |
|---|---|---|
| "Consider admission or seek advice for Pyelonephritis where … +/- lower UTI symptoms and: o not responding … or o flank pain …" (p52, Refer for acute assessment) | national RF-12 | not here: `CRR_RedFlags` |
| "First presentation of renal colic" (p52, Acute 1) | `redflag.renalColicAcuteEpisode` (reused) + `symptom.renalColicFirstPresentation` (new) | `Acute: First Presentation Renal Colic` |
| "if pregnant or female younger than 35 years old" (p52, Acute 1) | `patient.pregnant` (new), `patient.sex`, `patient.age` | same (Q1, Q3) |
| "and no red flags* requiring admission." + footnote "*1 Red flags for renal colic" (p52, p55) | national RF-03 | not here (Q2) |
| "Suspected chronic urinary retention" (p52, Acute 2) | `symptom.chronicUrinaryRetentionSuspected` (new) | `Acute: Suspected Chronic Urinary Retention` |
| "… advises referral for acute ultrasound renal" (p52, Acute 3) | `advice.acuteImagingRecommended` (+ `advice.adviserNameRole`, Overview p5) | `Acute: Specialist Advises Acute US Renal` |
| "Macroscopic haematuria: o If younger than 40 years or aged 86 years and older." (p52, P2 1) | `symptom.haematuriaMacroscopic` (new), `patient.age` | `P2: Macroscopic Haematuria Younger Than 40 Or 86 And Older` |
| "o If aged 40 to 85 years and unable to have intravenous contrast (i.e. history of allergy to IV contrast, has an eGFR less than 30mL/min, is taking metformin, or has hyperthyroidism)." (p52, P2 1) | `patient.ivContrastAllergy`, `lab.egfr.value`, `patient.takingMetformin`, `patient.hyperthyroidism` | `Unable To Have Intravenous Contrast`, `P2: … Aged 40 To 85 Unable To Have Contrast` |
| "… advises referral for urgent ultrasound renal" (p52, P2 2) | `advice.urgentImagingRecommended` | `P2: Specialist Advises Urgent US Renal` |
| "Microscopic haematuria, male patient, older than 50 years, current or ex-smoker" (p52, P3 1) | `symptom.haematuriaMicroscopic` (new), `patient.sex`, `patient.age`, `patient.smokingStatus` (new, choice current/ex/non) | `P3: Microscopic Haematuria Male Over 50 Current Or Ex-Smoker` |
| "New diagnosis of chronic kidney disease (CKD) and any of:" (p52, P3 2) | `patient.ckdNewDiagnosis` (new) | `P3: New CKD Diagnosis With Qualifying Results` |
| "o eGFR less than 30" / "o eGFR less than 45 with diabetes" | `lab.egfr.value`, `patient.diabetes` (new) | `CKD: eGFR Less Than 30`, `CKD: eGFR Less Than 45 With Diabetes` |
| "o eGFR less than 60 with evidence of progressive disease (i.e. eGFR decreased by 15 or more within the previous 12 months)," | `lab.egfr.value`, `lab.egfr.decreaseWithin12m` (new) | `CKD: eGFR Less Than 60 With Progressive Disease` (Q12) |
| "o ACR more than 250" | `lab.acr.value` | `CKD: ACR More Than 250` (Q8) |
| "New right-sided or bilateral varicocele." (p53, P3 3) | `symptom.varicoceleNewRightOrBilateral` (new) | `P3: New Right-Sided Or Bilateral Varicocele` |
| "UTI in men … o recurrent UTI (i.e. 2 or more confirmed UTI)" (p53, P3 4) | `patient.sex`, `symptom.utiConfirmedCount` (new) | `UTI In Men: Recurrent`, `P3: UTI In Men` (Q9) |
| "o persistent UTI (i.e. if urine culture shows persistent bacteriuria with same organism following treatment with appropriate antibiotic, …)" (p53, P3 4 and 5) | `lab.persistentBacteriuriaSameOrganism` (new) | `Persistent UTI` |
| "UTI in women … o recurrent UTI (i.e.  more than 3 UTIs in a year, or more than 2 in six months despite prophylactic antibiotics.)" (p53, P3 5) | `symptom.utiCount12m`, `symptom.utiCount6m`, `patient.onUtiProphylacticAntibiotics` (new) | `UTI In Women: Recurrent`, `P3: UTI In Women` (Q10) |
| "Urinary incontinence in men with palpable bladder, or new or deteriorating renal impairment." (p53, P3 6) | `symptom.urinaryIncontinence`, `symptom.palpableBladder`, `lab.renalImpairmentNewOrDeteriorating` (new) | `P3: Urinary Incontinence In Men With …` (Q11) |
| "Recurrent loin pain suggesting renal tract obstruction other than renal stone." (p53, P3 7) | `symptom.recurrentLoinPainSuggestingObstruction` (new) | `P3: Recurrent Loin Pain …` (Q16) |
| "… advises referral for non-urgent ultrasound renal." (p53, P3 8) | `advice.nonUrgentImagingRecommended` | `P3: Specialist Advises Non-Urgent US Renal` |
| "Microscopic haematuria, male patient, older than 50 years who is a non-smoker" (p53, P4 1) | `symptom.haematuriaMicroscopic`, `patient.sex`, `patient.age`, `patient.smokingStatus` | `P4: … Male Over 50 Non-Smoker` |
| "Microscopic haematuria, male patient aged 50 years and younger, with any smoking status …" (p53, P4 2) | same, no smoking | `P4: … Male 50 And Younger` |
| "Microscopic haematuria, female, of any age and smoking status" (p53, P4 3) | `symptom.haematuriaMicroscopic`, `patient.sex` | `P4: … Female` |
| "Follow up, according to the Renal Colic and Urinary Tract Stones HealthPathway, if calculus not visible on KUB X-ray (provided BMI is less than 30)" (p54, S2) | `workup.renalStoneFollowUpPerHealthPathway`, `workup.kubXrayCalculusVisible` (read with `not`), `patient.bmi` (new) | `S2: Renal Stone Follow Up …` (Q20) |
| AM 1 "Incidental finding on ultrasound of a solid lesion more than 1 cm diameter with typical ultrasound appearances of an angiomyolipoma – see local CT IVU HealthPathway" (p54) | `imaging.incidentalAngiomyolipomaOnUs`, `imaging.incidentalSolidLesionDiameterCm` (new) | `Redirect: Angiomyolipoma More Than 1 cm` (Q13, Q19) |
| AM 2 "Macroscopic haematuria in patients who do not have a UTI, if aged 40 to 85 years. Refer for CT IVU (Intravenous Urogram)." | `symptom.haematuriaMacroscopic`, `symptom.utiCurrent` (new), `patient.age` | `Redirect: Macroscopic Haematuria Aged 40 To 85 Without UTI` (Q5) |
| AM 3 "Repeat renal ultrasound for diabetic patients with known diabetic renal complications is not indicated - …" | `patient.diabeticRenalComplications`, `imaging.usrenal.ever` (new) | `Redirect: Repeat US For Known Diabetic Renal Complications` |
| AM 4 "Suspected renal colic in a non-pregnant person – …" | `redflag.renalColicAcuteEpisode`, `patient.pregnant` | `Redirect: Suspected Renal Colic Not Pregnant` (Q4) |
| AM 5 "Acute kidney injury – …" | `lab.acuteKidneyInjury` (new) | `Redirect: Acute Kidney Injury` |
| AM 6 "Enlarged prostate or elevated PSA – …" | `symptom.enlargedProstate`, `lab.psa.raised` (new) | `Redirect: Enlarged Prostate Or Elevated PSA` |
| AM 7 "Isolated proteinuria – seek nephrology advice." | `lab.proteinuriaIsolated` (new) | `Redirect: Isolated Proteinuria` |
| AM 8 "Lower urinary tract symptoms - …" | `symptom.lowerUrinaryTractSymptoms` (new) | `Redirect: Lower Urinary Tract Symptoms` (Q15) |
| AM 9 "Abdominal mass - …" | `symptom.abdominalMass` (new) | `Redirect: Abdominal Mass` |
| NF 1 "Recurrent UTIs in women, except as documented above" (p54) | `patient.sex`, `symptom.utiRecurrent` (new) + the P3 row | `Not Funded: Recurrent UTIs In Women Except As Documented` (Q10) |
| NF 2 "Investigation of uncomplicated hypertension" | `funding.investigationUncomplicatedHypertension` (new) | `Not Funded: Investigation Of Uncomplicated Hypertension` |
| NF 3 "Bacteriuria in patients with in-dwelling catheters who are not systemically unwell" | `lab.bacteriuria`, `patient.indwellingCatheter`, `symptom.systemicallyUnwell` (new) | `Not Funded: Catheter Bacteriuria Not Systemically Unwell` |
| NF 4 "Follow-up imaging of simple renal cysts (Bosniak I and II)" | `funding.simpleRenalCystFollowUp` (new) | `Not Funded: Simple Renal Cyst Follow Up` |
| NF 5 "Follow up of incidental finding on ultrasound of a solid lesion less 1 cm diameter with typical ultrasound appearances of an angiomyolipoma." | AML indicators above | `Not Funded: Angiomyolipoma Less Than 1 cm` (Q13) |
| NF 6 "Screening scan for Autosomal Dominant Polycystic Kidney Disease (ADPKD)" (p55) | `funding.adpkdScreening` (new) | `Not Funded: ADPKD Screening` |
| NF 7 "Serial ultrasounds of known polycystic kidneys unless indicated by the radiology report, or the patient develops new symptoms that meet any of the other criteria for renal ultrasound" (p55) | `funding.polycysticKidneySerialUs`, `imaging.furtherImagingRecommendedByReport` (new) + `Meets Any Criterion` | `Not Funded: Serial US Of Known Polycystic Kidneys` (Q18) |

Counts: 18 criterion rows/sub-rows with their own define (Acute 3, P2 3, P3 8 plus 4 CKD and 3 UTI sub-defines, P4 3, S2 1), 9 redirects, 7 not-funded rows; 38 `SOURCE` comments; 92 ELM definitions in all. Questionnaire: 54 items (45 new, 9 reused: `patient.age`, `patient.sex`, `lab.egfr.value`, `lab.acr.value`, `advice.acuteImagingRecommended`, `advice.urgentImagingRecommended`, `advice.nonUrgentImagingRecommended`, `advice.adviserNameRole`, `redflag.renalColicAcuteEpisode`). `addSite`: `redflag.renalColicAcuteEpisode` (p52, p54). No attestation indicators added (AD-17 candidates are listed under Q16).

Source column → `PlanDefinition.relatedArtifact` citations (10 titles, joined across their printed line breaks). Referrers "GP & UC Doctors / NPs" → `useContext`.

## 2. Modelling decisions

- **National rows are not re-encoded.** The p52 acute-assessment row is RF-12 and the p55 footnote is RF-03, both in `CRR_RedFlags`, which runs first (AD-03). The PlanDefinition still shows both for the referrer: the acute row as an `acute-assessment` block with no condition, and the footnote as a note on the Acute renal colic row, each with a documentation label naming the RF. The Acute row's "no red flags* requiring admission" is satisfied by the national library not having stopped the pipeline (Q2). The renal colic stem is RF-03's `redflag.renalColicAcuteEpisode`, so any referral meeting the Acute row has RF-03 evaluated on the same answers.
- **Determination codes (AD-36).** `ACUTE_48H`/`A48`, `P2_URGENT`/`P2`, `P3_NON_DEFERRABLE`/`P3`, `S2_TIME_SENSITIVE`/`S2`, `P4_DEFERRABLE`/`P4` (priority codes triager-only). Timeframe block conditions are `Meets Acute 48h|P2|P3|S2|P4 Criteria`. The `Priority Timeframe` strings are verbatim fragments of each timeframe heading (review round 1).
- **Precedence (R1, REVIEW Q14, Q21).** Redirect (TA-013) > paediatric (TA-003) > most urgent met timeframe row > insufficient information when any timeframe row is undetermined > not routinely funded (only when every timeframe row is definitively not met) > criteria not met. Before review round 1, not funded came first (CT CAP's order). That let NF 1 (recurrent UTIs in women) and NF 3 (catheter bacteriuria), which are keyed on patient facts, override a met criterion (e.g. a catheterised man with macroscopic haematuria). Scenarios USR-S45b and S60–S62 pin the new order.
- **Two redirects are scoped so they do not cancel a criterion.** Under redirect-first precedence, AM 4 (renal colic, non-pregnant) would make the Acute row's "female younger than 35" limb unreachable, and AM 2 (macroscopic haematuria 40–85, refer for CT IVU) would make P2's "aged 40 to 85 years and unable to have intravenous contrast" limb unreachable. Each redirect is read as not applying to the patient the specific row names. CT KUB p26 states the same intent for females under 35 ("arrange acute renal ultrasound (within 48h) rather than CT KUB"), and CT IVU is a contrast study (CT IVU p23 guidance). Both are REVIEW questions (Q4, Q5), not settled readings.
- **Units are not asserted** for eGFR (P2 prints "30mL/min"; P3 prints no unit), ACR (no unit printed) or the eGFR decrease. Numbers are compared as printed, following the RF-03 creatinine precedent (KI-47). The vocabulary's `lab.acr.value` text says "(mg/mmol)". At that unit, 250 is an unusually high threshold (Q8).
- **Not-funded request purposes go under `funding.`** "Investigation of uncomplicated hypertension", "Follow-up imaging of simple renal cysts", "Screening scan for ADPKD" and "Serial ultrasounds of known polycystic kidneys" describe why the scan is requested. They do not describe a patient state, so they are request-purpose markers. A patient who has uncomplicated hypertension but is referred for haematuria must not trigger not-funded. NF 3 is atomic (bacteriuria, catheter, not systemically unwell) because each part is a patient fact.
- **Questionnaire wording (review round 1).** The site Questionnaire uses the printed p52–p53 wording for the three advice items ("… advises referral for acute / urgent / non-urgent ultrasound renal") and "in a year" / "in six months" for the two UTI counts. The vocabulary entries' texts differ ("same or next day scan", "urgent imaging of the requested exam", "a non-urgent scan", "in the last year", "in the last six months") and are not edited here.
- **Viewer tick boxes (R2).** No PlanDefinition row has a sole boolean input that the library reads negated: the only negated reads (`workup.kubXrayCalculusVisible`, `symptom.utiCurrent`, `symptom.systemicallyUnwell`, `patient.pregnant`, `imaging.furtherImagingRecommendedByReport`) are on multi-input rows or on redirect / not-funded rows, which carry no inputs. Nothing removed.
- **Referrer-visible strings (R3).** The engineering labels that named RF-12 / RF-03 and REVIEW Q2, Q4 and Q5 were removed from the PlanDefinition documentation (they now live only here and in `signoff.md`). The two remaining `display` notes are published wording (the p55 footnote and the Overview p5 adviser sentence) and carry no priority code.
- **Not-funded rows are never tickable.** They have no `input`. Each not-funded and redirect child carries its own condition and `source-page`.
- **Missing information** for `INSUFFICIENT_INFORMATION` is the set of unanswered indicators of every criterion row that is indeterminate. Rows that are definitively false add nothing. Because a site with 18 rows has many stems, a note that says nothing renal yields a long list (MW-010: 26 items). Pregnancy is not asked when the "female younger than 35" limb is already met, and sex/age are not asked for that row when the patient is pregnant (review round 1). The renderer's "what to add" groups the list by pathway. CT CAP's narrower per-lab suppression was not copied. Unanswered indicators of indeterminate redirects go to `unconfirmedExclusions` (triager view) and never block a determination.
- **A male patient is treated as not pregnant** (Q3). Without this, every male renal colic referral would stop on an unanswered pregnancy question.
- **`population.cql` not done.** eGFR, ACR and the 12-month eGFR decrease could come from the record, but `run-tests-sites.mjs` does not support record-backed scenarios yet, and retrieval is dormant (invariant 5).
- **HealthPathways page id** is left as `TBC-page-id`, as in the CT CAP and CTC templates. The published JSON's `healthPathwaysUrl` for `us_renal` uses page `19858` (Auckland instance). It is a candidate, not a source.
- **Vocabulary group placement.** The vocabulary has no history, comorbidity or medication group, so pregnancy, smoking, contrast allergy, metformin, hyperthyroidism, diabetes, known diabetic renal complications, new CKD diagnosis, BMI, UTI prophylaxis and catheter are proposed under `patient` (Q17).

## 3. Not encoded (and why)

- "e.g. new onset incontinence with palpable enlarged bladder" (Acute 2): illustrative (KI-05).
- "+/- lower UTI symptoms" (acute-assessment row): national RF-12, and "+/-" in any case.
- "(*including pyelonephritis where admission is not required)" (P3 4, 5): scope of "UTI", not a condition.
- "consider colonisation of renal tract stone" and "Arrange Xray KUB and pre- and post-void renal ultrasound." (P3 4, 5): advice to the referrer, kept verbatim in the PlanDefinition.
- "see local … HealthPathway", "Refer for CT IVU …", "seek nephrology advice", "Discuss with secondary care specialist …" (AM rows): redirect wording. It is shown verbatim in `activeRedirects`, but it is not a condition.
- "no red flags* requiring admission" and the p55 footnote: national RF-03 (Q2).
- The p52 acute-assessment row: national RF-12.
- No row was dropped for lack of a defensible literal reading.

## 4. Source versus published JSON, census, vocabulary and earlier artefacts

- **`pdf-criteria-all.json` (`us_renal`)** has the same rows and wording. It collapses the acute-assessment sub-bullets into one label (D-03) and splits P2's macroscopic haematuria into two items with the stem repeated (D-02). Its `outOfCriteriaNote` is a paraphrase of the not-funded list ("simple cyst follow-up, small angiomyolipoma follow-up …"), and the PlanDefinition uses the PDF wording instead. It carries no Source or Referrers columns. Its footnote matches the PDF ("Creatinine > 160 micromol/L").
- **Census** (`instructions/archive/compound-criteria-phase0-findings.md` rows 44–46): `usrn_em_1` C(1+2) (national), `usrn_p2_2` A(3) "macroscopic haematuria AND age 40–85 AND unable to have IV contrast (4 enumerated reasons)", `usrn_p3_2` C(1+4). All three match the encoding.
- **A row that v2.0 does not print.** Matrix cases RP-006 and INT-AKI, the v2.0.0–v2.3.0 prompt test results, and system prompt v2.3.0's STEP 3 worked example all rely on an Acute 48hr criterion, "Acute renal function deterioration — serum creatinine increase >50 micromol/L in 7 days or >25 micromol/L in 2 days [p53]" (example: "Acute renal function deterioration criterion is met → verdict is 'proceeds'"). This row is **not in National ID 15372 v2.0**. Acute kidney injury appears only as an alternative-management row (p54), so these cases now return alternative management. The STEP 3 "renal deterioration" example has no v2.0 equivalent. The nearest v2.0 row is P3 6 ("… or new or deteriorating renal impairment", men with incontinence), which scenario USR-S31 covers.
- **`instructions/archive/indication-groupings.md`** supplied the theme names, and its theme order is kept. Its item ids (`usr_24_1` "Acute — within 24–48 hours") predate v2.0.
- **Vocabulary attributions that do not match pp.52–55.** These are not corrected here, because the brief forbids editing existing entries. `lab.unexplained` lists `us-renal-adult` p52, but the word "unexplained" does not appear on pp.52–55. `symptom.haematuria` lists `us-renal-adult` p52, but this site needs the macro/micro distinction and does not use the generic flag. `lab.egfr.low` lists p52/p55, but the thresholds are numeric so the flag is unused. `lab.creatinine.value` lists p55, but that is the national footnote. `symptom.temperatureCelsius` and `lab.pyuriaOnMicroscopy` belong to national RF-12.
- **p55 footnote vs RF-03.** US Renal prints "peritonitis" and "signs of sepsis" as two bullets, and RF-03 has one combined indicator (`redflag.peritonitisOrSepsisSigns`, OR semantics, same logic). The creatinine unit difference is already KI-47 / the errata entry in `publish.mjs`.

## 5. Matrix cases

Sheets read: Test Case Results, Michaela Model Comparison, Structured Re-Eval, Corrections Log.

| Case | Note (source) | Matrix expected | Engine (this bundle) | Agreement |
|---|---|---|---|---|
| RP-006 | Test Case Results | Proceeds (with safety advisory), under the superseded AKI Acute row | `ALTERNATIVE_MANAGEMENT` (AKI row) | Differs, because the source changed (section 4) |
| INT-AKI | Structured Re-Eval; note from `scripts/reg02-runner.mjs` | proceeds + safety alert (borderline, pending clinical input) | `ALTERNATIVE_MANAGEMENT` | Differs, same cause |
| CR-003 | Test Case Results / Structured Re-Eval | Proceeds, P4 | `P4_DEFERRABLE` | Match |
| MW-010 (and Michaela 234/235) | Test Case Results | Declined (no renal indication) | `INSUFFICIENT_INFORMATION`, 26 indicators listed | Differs by design: silence is never "not met" (three-valued logic, as in CT CAP) |
| INT-001 | Test Case Results (a CT KUB case: "request renal US instead") | — (cross-check) | strict: `INSUFFICIENT_INFORMATION` (renal colic only inferred from "loin to groin pain"); inferred: `ACUTE_48H` | Consistent with the matrix's redirect to renal US; doubles as the strict-vs-inferred case |

## 6. Gates

`npm run build && npm test && npm run check` green (from `tooling/criteria-bundle/tooling`): US Renal 73/73 scenario runs (review round 1, on `claude/status-check-hcapoe` with every W1 site), consistency OK; see the commit report for the full tails. SOURCE quotes and PlanDefinition titles were also checked mechanically against the page text (whitespace-normalised). All are verbatim apart from the REVIEW summary in the library header, which uses deliberate ellipses.

## 7. Adjacent problems (flagged, not fixed)

Items 1–3 of the first report (Advisory renderer fallback, referrer title strip of S-codes, engine priority test) are fixed by AD-36 / KI-76 / CL-57.

1. The vocabulary attributions in section 4 (KI-78 e).
2. The vocabulary texts of `advice.acuteImagingRecommended` ("same or next day scan"), `symptom.utiCount12m` / `utiCount6m` ("in the last …") differ from the printed wording the site Questionnaire now uses (section 2).
