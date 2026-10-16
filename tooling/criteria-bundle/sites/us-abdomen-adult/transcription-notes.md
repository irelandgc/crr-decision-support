# Transcription notes — US Abdomen - Adult (`us-abdomen-adult`)

**Source:** `documents/reference/National Primary Care Referral Criteria for Imaging.pdf`, National ID 15372 v2.0, published 09/04/2026, section "Adult Ultrasound > US Abdomen - Adult", pp.30–33. Published exam/site id `us_abdomen` → bundle key `us-abdomen-adult` (AD-01).

**Status:** W1 demo transcription for staging only (AD-35, Gary 2026-10-15). NOT CLINICALLY REVIEWED. Most literal reading encoded; every ambiguity is a REVIEW Qn (CQL header, `signoff.md`, §3 below). No criterion was left out for want of a literal reading.

**Size:** 16 criteria (Acute 48 h ×2, P2 ×3, P3 ×8, S3 ×3), 12 alternative-management redirects, 7 not-funded items (6 published bullets; "Screening for:" has two). 98 ELM definitions in all. 55 Questionnaire items (41 new vocabulary indicators, 14 reused). 47 scenarios.

## 1. Atoms

Each published sentence and the indicator(s) it became. `new` = proposed in `vocabulary-additions.json`. `¬` = the criterion needs the indicator answered false.

### Refer for acute assessment without imaging (p30) — national, not encoded here

| Source sentence | Indicator | Note |
|---|---|---|
| "Suspected acute cholecystitis or cholangitis (i.e. intractable biliary colic not relieved by simple analgesia and especially if accompanied by fever, persistent vomiting)" | `redflag.cholecystitisOrCholangitis` (RF-05) | CRR_RedFlags |
| "Acute abdomen, including possible appendicitis" | `redflag.acuteAbdomen` (RF-06) | CRR_RedFlags |
| "Suspicion of ruptured abdominal aortic aneurysm" | `redflag.rupturedAAA` (RF-07) | CRR_RedFlags |
| "Suspected testicular torsion" | `redflag.testicularTorsion` (RF-08) | CRR_RedFlags |
| "Painful jaundice" | `redflag.painfulJaundice` (RF-09) | CRR_RedFlags; read here as false for "painless" (Q1) |

The PlanDefinition renders this row (`acute-assessment` block, no condition) so the Viewer shows it.

### Acute: Within 48 hours (p30)

| Source sentence | Indicator(s) |
|---|---|
| "Painless jaundice without obvious cause - consider discussing with secondary care specialist or Primary Care Radiology Liaison as a CT scan may be more appropriate." | `symptom.jaundice` + ¬`redflag.painfulJaundice` (Q1) + ¬`workup.jaundiceObviousCause` new (Q2); "consider discussing …" not a condition (Q3) |
| "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist advises referral for same or next day ultrasound scan." | `advice.acuteImagingRecommended`; `advice.adviserNameRole` asked for when met (Overview p5) |

### P2 Urgent (p30)

| Source sentence | Indicator(s) |
|---|---|
| "Initial presentation with ALP more than 2 times the upper limit of normal (ULN) and GGT higher than the ULN" | `lab.alp.timesULN` > 2 + GGT raised (`lab.ggt.raised` new, or `lab.ggt.timesULN` new > 1). "Initial presentation" not a separate atom (Q4) |
| "Suspected acute cholecystitis / biliary colic with raised ALP and GGT +/- bilirubin and where symptoms settle with analgesia and biliary tree has not previously been imaged." | `symptom.biliaryColicOrCholecystitis` new + ALP raised (`lab.alp.high`, or `lab.alp.timesULN` > 1) + GGT raised + `symptom.settlesWithAnalgesia` new + ¬`imaging.biliaryTree.ever` (Q5) |
| "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist advises referral for urgent ultrasound scan." | `advice.urgentImagingRecommended` (+ adviser name) |

### P3 (pp.31–32)

| Source sentence | Indicator(s) |
|---|---|
| "Recurrent right upper quadrant / epigastric, non-dyspepsia pain without previous imaging" | `symptom.recurrentRUQOrEpigastricPain` new + ¬`symptom.dyspepsia` new + ¬`imaging.presentingProblem.ever` new (Q6) |
| "Suspected resolved acute biliary colic or cholecystitis, without previous imaging which showed gallstones and the patient is a potential candidate for and would accept a cholecystectomy" | `symptom.biliaryColicOrCholecystitis` + `symptom.biliaryColicResolved` new + ¬`imaging.gallstones.ever` new + `workup.cholecystectomyCandidate` new (Q7) |
| "Follow up imaging on repeat testing 3 months or more after the initial presentation and: o ALP was more than 2 times the ULN at the initial presentation AND on repeat testing 3 months later the : ▪ Repeat ALP remains higher than the ULN ▪ Repeat GGT remains higher than the ULN" | `lab.repeatAfter3Months` new + `lab.alp.timesULN` > 2 + `lab.alp.repeatHigh` new + repeat GGT raised (`lab.ggt.repeatRaised` new, or `lab.ggt.repeatTimesULN` new > 1) (Q8) |
| "ALT greater than 120 IU/L AND o Conservative methods (e.g. weight loss and lifestyle alterations or medication change) unsuccessful in patients with high risk factors (diabetes, obesity, medications that affect the liver, e.g. statins) o No clinical features of concern" | `lab.alt.value` new > 120 IU/L + `patient.liverRiskFactors` new + `workup.conservativeMethodsUnsuccessful` new + ¬`workup.clinicalFeaturesOfConcern` new (Q9, Q10) |
| "Isolated raised GGT more than 5 times the ULN and persists on re-testing after 3 months." | `lab.isolatedLftAbnormality` new + `lab.ggt.timesULN` > 5 + `lab.repeatAfter3Months` + `lab.ggt.repeatTimesULN` > 5 (Q11) |
| "Asymptomatic, newly suspected abdominal aortic aneurysm e.g. on clinical examination or other imaging." | `symptom.aaaNewlySuspected` new + `symptom.aaaAsymptomatic` new (Q14) |
| "Non-pulsatile abdominal mass and suspected enlarged liver on examination." | `symptom.abdominalMassNonPulsatile` new + `symptom.hepatomegalySuspected` new (Q15) |
| "Secondary care clinician or Primary Care Radiology Liaison (PCRL) or radiologist advises referral for non-urgent ultrasound scan." | `advice.nonUrgentImagingRecommended` (+ adviser name) |

### S3 (p32)

| Source sentence | Indicator |
|---|---|
| "HCC surveillance using liver ultrasound as initially recommended by a gastroenterologist or other secondary care specialist, as part of long-term monitoring by Hepatitis Foundation of NZ, or as recommended by an agreed local pathway.*" | `advice.hccSurveillance` new (Q16) |
| "Surveillance of known abdominal aortic aneurysm according to local HealthPathway, or if none available according to the according to New Zealand Vascular Society guidelines (2015) *1 or secondary care specialist advice" | `advice.aaaSurveillance` new. The doubled "according to the according to" is printed so and kept verbatim |
| "Follow up of incidental finding on imaging (including gallbladder polyps) according to the Incidental Findings on Imaging HealthPathway, or if unavailable according to the radiology report advice from the Primary Care Radiology Liaison" | `advice.incidentalFindingFollowUp` new |

### Alternative management or HealthPathway recommended (pp.32–33)

All read through `is true`: an unanswered redirect indicator does not fire and does not block a priority row.

| Source sentence | Indicator(s) |
|---|---|
| "Upper abdominal non-pulsatile mass, not consistent with hepatomegaly – discuss with …" | `symptom.abdominalMassNonPulsatile` + `symptom.abdominalMassUpper` new + ¬`symptom.hepatomegalySuspected` (Q24) |
| "Unexplained weight loss, persistent fatigue, vague abdominal pain and suspicion of underlying malignancy – See local CT Chest, Abdomen and Pelvis HealthPathway." | `weightloss.present` + `symptom.fatigue` + `symptom.abdominalPain` + `workup.suspicionMalignancy` new (Q19) |
| "Isolated raised GGT less than 5 times the ULN - Re-test after three months …" | `lab.isolatedLftAbnormality` + GGT raised + `lab.ggt.timesULN` < 5 (Q12) |
| "ALP elevated with normal GGT - suggests ALP increase is probably not liver-related. …" | ALP raised + GGT normal at the latest test (Q13) |
| "Raised ferritin – See local …" | `lab.ferritin.raised` |
| "Isolated raised bilirubin – …" | `lab.bilirubin.raised` new + `lab.isolatedLftAbnormality` |
| "Dyspepsia – See local HealthPathway" | `symptom.dyspepsia` |
| "Suspected colorectal neoplasm. If colicky …" | `symptom.colorectalNeoplasmSuspected` new; second sentence is advice |
| "New unilateral lymphoedema - …" | `symptom.unilateralLymphoedemaNew` new |
| "Suspected or symptomatic chronic pancreatitis – request acute general surgery assessment." | `symptom.chronicPancreatitis` new (Q23) |
| "Urinary tract presentations and suspected renal abnormality - See local Ultrasound Renal HealthPathway" | `symptom.urinaryTractPresentation` new (Q21) |
| "Isolated bloating with associated clinical symptoms (for example …), seek advice …" | `symptom.isolatedBloating` new + `workup.clinicalFeaturesOfConcern` (Q20) |

Redirect wording in `Active Redirects` and the PlanDefinition is the published text verbatim.

### Not routinely funded (p33)

| Source sentence | Indicator |
|---|---|
| "Hernia in adults" | `funding.hernia` new |
| "Infective hepatitis" | `funding.infectiveHepatitis` new |
| "Follow-up imaging of previously diagnosed gallstones in asymptomatic patients" | `funding.gallstonesFollowUpAsymptomatic` new |
| "Isolated bloating with no other features of concern" | `symptom.isolatedBloating` + ¬`workup.clinicalFeaturesOfConcern` |
| "Follow up imaging of simple renal or hepatic cysts" | `funding.simpleCystFollowUp` new |
| "Screening for: o aortic aneurysm o fatty liver" | `funding.screeningAorticAneurysm` new, `funding.screeningFattyLiver` new |

Not-funded rows carry no input, so the Viewer never renders them as tickable (GEN-005).

### Not logic

- Guidance box (p31, inside the P3 row above its bullets): rendered as the site Guidance block. Its statements ("Ultrasound imaging is a first-line investigation if cholestasis is suspected based on LFT results", "borderline … Mild …") are guidance, not criteria.
- Source column (p30 "Local HealthPathways Suites", "National Referral Criteria 2013"; p31 "Guidelines on the management of abnormal liver blood tests - PMC", "*1 lfts.pdf (bpac.org.nz)"; p32 "RACP Surveillance for liver cancer in primary care") → `PlanDefinition.relatedArtifact` citations.
- Referrers column: "GP & UC Doctors / NPs" → `useContext`. The S3 row also lists "*Hepatitis Foundation Clinician" (the asterisk ties it to the HCC bullet); shown as a note on `s3-hcc`, not enforced — referrer eligibility is not engine logic.

## 2. Modelling decisions

- **Determination codes.** `ACUTE_48H`, `P2_URGENT`, `P3_NON_DEFERRABLE`, `S3_TIME_SENSITIVE` (priority code `S3`), plus the CT CAP set (`ALTERNATIVE_MANAGEMENT`, `NOT_ROUTINELY_FUNDED`, `PAEDIATRIC_CRITERIA_APPLY`, `CRITERIA_NOT_MET`, `INSUFFICIENT_INFORMATION`). No code exists yet for these rows; chosen so a humanised fallback never shows "S3" to a referrer (the renderers strip only a leading P1–P4). The acute row prints no code, so its `priorityCode` is null and the timeframe "Within 48 hours" carries the urgency. Parallel W1 sites may choose differently; the coordinator should align them.
- **S3 heading.** The S3 block title drops the leading "S3" ("Non-deferrable time sensitive imaging …"); the code sits on the `priority-code` coding (triager-only) and the full printed heading is in the documentation label. P2/P3 titles keep the code, as CT CAP does, because the renderers strip it.
- **Compound row titles.** P3 bullets 3 and 4 print sub-bullets; the PlanDefinition titles keep every word but join the sub-bullets with ":" and ";" (p3-follow-up-alp-ggt, p3-alt). "Screening for: o aortic aneurysm o fatty liver" is rendered as two not-funded rows ("Screening for: aortic aneurysm", "Screening for: fatty liver"). The CQL SOURCE quote for P3 bullet 4 spans the p31/p32 page break.
- **LFT time points.** Three time points appear: the initial result (P2 bullet 1; "at the initial presentation" in P3 bullet 3), the repeat at 3 months or more (P3 bullets 3 and 5), and unqualified "raised"/"elevated"/"normal" (P2 bullet 2, redirects). Initial results use `lab.alp.timesULN`, `lab.alp.high`, `lab.ggt.raised`, `lab.ggt.timesULN`; repeat results have their own indicators. "Normal GGT" in the ALP redirect uses the repeat result once repeated (Q13).
- **Flag or multiple.** "Raised"/"higher than the ULN" is satisfied by the boolean flag or, when no flag is given, by a stated multiple above 1. Thresholds stated as multiples (> 2 x, > 5 x, < 5 x) need the multiple (KI-13: the referrer is never asked for a reference range, only for the laboratory's multiple). ALT has a numeric threshold, so `lab.alt.value` (IU/L) is required.
- **Precedence** follows CT CAP (not funded → redirect → paediatric → rows) with the four priority rows ordered Acute 48 h, P2, P3, S3 (Q17). A met lower row is returned when a higher row is undetermined, and nothing further is asked.
- **Missing information** lists, for each row still undetermined, only its unanswered parts; rows already false ask for nothing. For a sparse note this is long (31 items for MW-009); the Advisory renderer groups by pathway with the shortest first, so MW-009 leads with the obvious-cause and mass questions.
- **Unconfirmed exclusions** is empty: this site's alternative-management items are other presentations, not exclusions to confirm (CT CAP's `excl.*` are).
- **Attestation (AD-17) candidates, not added.** `workup.jaundiceObviousCause`, `workup.clinicalFeaturesOfConcern`, `workup.cholecystectomyCandidate`, `workup.suspicionMalignancy` rest on referrer judgement. Adding them to `attestationIndicators` needs `attestationWording` (AD-23) and is outside the additions-file schema; proposed for the vocabulary owner.
- **population.cql: not done.** P3 bullets 3 and 5 (repeat at 3 months) could be computed from coded lab history as CT CAP does, but `run-tests-sites.mjs` does not support record-backed scenarios and retrieval is dormant (invariant 5).

## 3. REVIEW questions

Q1–Q24 as listed in the CQL header and `signoff.md` (readings encoded stated there in full).

## 4. Modifiers and illustrative wording not encoded (KI-05)

| Where | Wording | Why not encoded |
|---|---|---|
| p30 Acute 48 h | "consider discussing … as a CT scan may be more appropriate" | advice (Q3) |
| p30 P2 bullet 2 | "+/- bilirubin" | "+/-" |
| p31 P3 bullet 4 | "(e.g. weight loss and lifestyle alterations or medication change)", "e.g. statins" | "e.g." |
| p32 P3 bullet 6 | "e.g. on clinical examination or other imaging" | "e.g." |
| p32 S3 bullet 3 | "(including gallbladder polyps)" | illustrative; folded into the indicator text |
| p33 colorectal | "If colicky vague abdominal pain, … consider colorectal cancer" | advice |
| p33 bloating | "(for example decreased appetite, weight loss, abdominal pain, abnormal vaginal bleeding)" | "for example" (Q20) |
| p33 ALP/normal GGT | "If ALT or bilirubin elevated as well, or the patient is symptomatic consider ALP iso-enzyme testing" | advice inside the redirect wording |
| p30 RF-05 | "especially if accompanied by fever, persistent vomiting" | national red flag; "especially" |

## 5. Source versus published JSON, census and vocabulary

- `documents/reference/pdf-criteria-all.json` (`us_abdomen`): item wording matches the PDF. Differences: P3 bullets 3 and 4 are flattened into run-on labels with ";" (finding D-03 pattern); the acute-assessment rows are tickable `cb` items there (national red flags here); `outOfCriteriaNote` paraphrases the not-funded list ("follow-up of previously diagnosed gallstones" drops "in asymptomatic patients", "isolated bloating" drops "with no other features of concern", "simple cyst follow-up" drops "renal or hepatic"); `alternativeManagement` is one run-on string; Source and Referrers columns (including "*Hepatitis Foundation Clinician") are absent; the S3 group title keeps "S3". `healthPathwaysUrl` is an Auckland link to page 15607 — not verified as the national page ID, so the PlanDefinition keeps `TBC-page-id` as the templates do.
- Census (`instructions/archive/compound-criteria-phase0-findings.md` rows 28–29): `usab_p3_3` A(3) and `usab_p3_4` A(3) — both "all", agreeing with Q8/Q9. The census's three parts for `usab_p3_3` omit the 3-month repeat itself, encoded here as a fourth part.
- Vocabulary, flagged not edited (sessions never edit existing entries): `lab.ferritin.low` lists `us-abdomen-adult` p33, but p33 prints only "Raised ferritin"; `symptom.fever` lists `us-abdomen-adult` p30, where fever appears only as RF-05 modifier wording. `lab.repeatConfirmed`'s text fixes "after three weeks" though its notes say the interval is asserted per site, so it could not be reused for the 3-month repeat. The `patient` group is described as demographics; `patient.liverRiskFactors` is a clinical history item (there is no history group).

## 6. Matrix cases

From `documents/CRR_Test_Case_Results_Matrix_v2.xlsx` (all four sheets):

| Case | Matrix | Evaluator expected | Scenario | Engine result |
|---|---|---|---|---|
| MW-009 | Test Case Results; Michaela Model Comparison (232/233) | CT CAP declined, US Abdomen acute | USAB-M01 (as US request) | INSUFFICIENT_INFORMATION — "without obvious cause" not stated (Q2); P3 mass/liver undetermined (Q15) |
| MW-009 + referrer answer | — | — | USAB-M02 | ACUTE_48H |
| RP-002 | Test Case Results; Structured Re-Eval | Proceeds (P3 hepatomegaly) | USAB-M03 | P3_NON_DEFERRABLE |
| RP-002 mass inferred | — | — | USAB-M04 / M05 | strict INSUFFICIENT (inferred surfaced) / inferred P3 |
| CB-001 | Test Case Results; Structured Re-Eval | Declined | USAB-M06 | INSUFFICIENT_INFORMATION (nothing answered either way; the engine does not assume "not met") |
| CB-002 | Test Case Results; Structured Re-Eval | At risk / Proceeds | USAB-M07 | INSUFFICIENT_INFORMATION (no ULN multiple, no GGT; ALP flag inferred) |

MW-009 as requested (CT CAP) is unchanged: the CT CAP bundle still redirects it. The engine will not offer US Abdomen as a cross-exam alternative for it today, because `engine.ts` only treats `P<n>` determinations as priorities (see §7). The Structured Re-Eval responses for CB-002 quote a P2 criterion ("elevated ALP more than 2x ULN together with elevated GGT +/- raised bilirubin +/- raised ALT") and a P3 criterion that are not the published wording — the paraphrase problem the bundle removes.

## 7. Adjacent problems found (flagged, not fixed)

1. `public/crr-criteria/api/engine.ts` `isPriorityDetermination` matches only `/^P\d/`, and its comment says acute determinations come only from the national library. Site rows "Acute: Within 48 hours" and S-coded rows are priority outcomes too; without a change, MW-009 (CT CAP requested, US Abdomen candidate) never surfaces US Abdomen as an alternative.
2. `public/crr-criteria/shared/advisory-render.js` `DETERMINATION_TO_DEFINE` maps only P2 / alternative management / not funded; P3, S3 and acute outcomes fall back to the humanised code with no row wording or page. Both renderers strip only a leading P1–P4 from referrer-facing text, so an S-code would leak (worked around here by the S3 title).
3. A quantity answer carrying a display unit but no UCUM `code` (e.g. `unit: "IU/L"`) throws inside `FHIRHelpers.ToQuantity` (cql-execution rejects "IU/L"; UCUM is `[IU]/L`). An extraction answer for `lab.alt.value` shaped that way would fail the whole evaluation; the gate or merge step should normalise or reject it. The scenarios send `code: "[IU]/L"`.

## 8. PDF text extraction

The plain-text extraction was reliable for wording but not for layout on three pages, which were re-extracted with `extract_text(extraction_mode="layout")`:
- **p31:** plain mode put "ALT greater than 120 IU/L AND" above the Guidance box and interleaved the Source column (". *1 lfts.pdf (bpac.org.nz)"). Layout mode shows the Guidance box at the top of the P3 Clinical Presentation cell, the P3 bullets beneath it, and the ALT bullet as the last line of p31, its two sub-bullets continuing at the top of p32.
- **p32:** "*Hepatitis Foundation Clinician" sits in the Referrers column of the S3 row, not in the HCC bullet.
- **p30:** the Source column ("Local HealthPathways Suites", "National Referral Criteria 2013") is interleaved with the acute-assessment bullets in plain mode.

## 9. Build gates

`npm run build && npm test && npm run check` from `tooling/criteria-bundle/tooling`, 2026-10-16: all green. Build compiles `CRR_USAbdomen_Adult` (98 definitions); sites 50/50 scenario runs (47 for this site); CT CAP 30/30, red flags 47/47, errata 8/8, ground truth 5/5; check: "Site us-abdomen-adult: CRR_USAbdomen_Adult (98 defines), 64 Questionnaire items, 47 scenarios … Consistency OK" (64 items = 55 answerable + 9 groups). The site is wired into the `build` script and `publish.mjs` `MANIFESTS` (coordinator re-does both centrally). Not published.
