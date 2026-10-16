# Clinical sign-off — US Abdomen - Adult (us-abdomen-adult) — bundle 1.0.0

Source: National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026 — "US Abdomen - Adult", pp.30–33
Transcribed by: Claude Code, 2026-10-15 (W1 demo transcription, AD-35: staging only, not clinically signed off)   Engineering review of SOURCE quotes by: pending

## Reading each define against the source
[ ] Every SOURCE quote matches the source document verbatim
[ ] Every define beneath its quote says what the quote says — nothing added, nothing dropped, nothing stronger or weaker
[ ] Modifiers listed in transcription-notes.md are correctly excluded from logic
[ ] Redirects and not-funded items are complete
[ ] The acute-assessment row (p30) is fully covered by the national red flags RF-05 to RF-09 and needs nothing in this bundle

## REVIEW questions (answer each)
Q1 Acute 48 h, "Painless jaundice" — reading encoded: jaundice (`symptom.jaundice`) AND the national indicator `redflag.painfulJaundice` answered false; no separate "painless" indicator — ruling: ________  by: ________
Q2 "without obvious cause" — reading encoded: own indicator `workup.jaundiceObviousCause` (true = obvious cause apparent); unknown is not assumed absent, so the row is undetermined and the referrer is asked; proposed AD-17 attestation item — ruling: ________  by: ________
Q3 "consider discussing with secondary care specialist or Primary Care Radiology Liaison as a CT scan may be more appropriate" — reading encoded: advice to the referrer, not a condition; the row is met without a documented discussion — ruling: ________  by: ________
Q4 P2 "Initial presentation with ALP more than 2 times the ULN and GGT higher than the ULN" — reading encoded: "initial presentation" is not a separate condition; the ALP multiple and GGT flag are the initial results (the same ALP multiple feeds P3 bullet 3's "at the initial presentation"); a patient whose initial results met P2 still meets P2 at follow-up; "more than 2 times" is strictly greater (2.0 x ULN does not meet it) — ruling: ________  by: ________
Q5 P2 bullet 2, "raised ALP and GGT +/- bilirubin" — reading encoded: ALP raised AND GGT raised; "+/- bilirubin" not encoded (KI-05); "Suspected acute cholecystitis / biliary colic" is one indicator shared with P3 bullet 2 — ruling: ________  by: ________
Q6 P3 bullet 1, "without previous imaging" — reading encoded: no modality or region is printed, so "the presenting problem has previously been imaged" = false (`imaging.presentingProblem.ever`); "non-dyspepsia" = `symptom.dyspepsia` false (the same indicator drives the Dyspepsia redirect) — ruling: ________  by: ________
Q7 P3 bullet 2, "without previous imaging which showed gallstones" — reading encoded: no previous imaging has shown gallstones (a patient never imaged qualifies); "potential candidate for and would accept a cholecystectomy" is one indicator — ruling: ________  by: ________
Q8 P3 bullet 3 (follow-up ALP/GGT) — the sub-bullets print no connector; reading encoded: all required — repeat testing 3 months or more after the initial presentation AND initial ALP > 2 x ULN AND repeat ALP > ULN AND repeat GGT > ULN — ruling: ________  by: ________
Q9 P3 bullet 4 (ALT) — reading encoded: both sub-bullets required; "in patients with high risk factors (diabetes, obesity, medications that affect the liver, e.g. statins)" is a condition (one indicator: at least one of the three); the "e.g." lists are illustrative — ruling: ________  by: ________
Q10 "ALT greater than 120 IU/L" — reading encoded: strictly greater (120 does not meet it) and a numeric value is required; a qualitative "ALT raised" does not satisfy it — ruling: ________  by: ________
Q11 P3 bullet 5, "Isolated raised GGT more than 5 times the ULN and persists on re-testing after 3 months" — reading encoded: isolated AND initial GGT > 5 x ULN AND repeated at 3 months or more AND repeat GGT still > 5 x ULN; "isolated" = the only abnormal liver blood test, one indicator shared with "Isolated raised bilirubin" — ruling: ________  by: ________
Q12 Initial isolated GGT < 5 x ULN with a repeat > 5 x ULN — reading encoded: the alternative-management item ("... Consider ultrasound if GGT is higher than 5 times the ULN on re-testing") fires; P3 bullet 5 is not met because the initial GGT was not > 5 x ULN. Should this case meet P3 instead? — ruling: ________  by: ________
Q13 "ALP elevated with normal GGT" redirect — reading encoded: judged on the latest GGT (the repeat result once tests have been repeated at 3 months or more), so P3 bullet 3 (GGT normal initially, raised at repeat) is reachable — ruling: ________  by: ________
Q14 P3 bullet 6, "Asymptomatic, newly suspected abdominal aortic aneurysm e.g. on clinical examination or other imaging" — reading encoded: two indicators (newly suspected, asymptomatic); the "e.g." clause not encoded — ruling: ________  by: ________
Q15 P3 bullet 7, "Non-pulsatile abdominal mass and suspected enlarged liver on examination" — reading encoded: two conditions, both required. Does a palpable liver edge alone answer "non-pulsatile abdominal mass" (matrix RP-002)? — ruling: ________  by: ________
Q16 S3 rows — reading encoded: one indicator per bullet (the recommendation or surveillance plan is the condition); the "S3" code is dropped from the rendered row heading so it never reaches referrers; the "*Hepatitis Foundation Clinician" Referrers entry is shown as a note and not enforced — ruling: ________  by: ________
Q17 Precedence — reading encoded: not routinely funded > alternative management > paediatric > Acute: within 48 hours > P2 > P3 > S3; the highest row met is returned even when a higher row is undetermined — ruling: ________  by: ________
Q18 Not-funded items — reading encoded: each is the reason for the request (one indicator each, published wording), except "Isolated bloating with no other features of concern", which is isolated bloating AND no features of concern. "Infective hepatitis" read as the reason for the request so that HCC surveillance under Hepatitis Foundation monitoring (S3) is not swept up; if both are answered, not funded wins — ruling: ________  by: ________
Q19 Redirect "Unexplained weight loss, persistent fatigue, vague abdominal pain and suspicion of underlying malignancy" — reading encoded: all four required; "persistent" and "vague" not captured separately; "suspicion" is a new indicator distinct from CT CAP's "strong suspicion" — ruling: ________  by: ________
Q20 Bloating — reading encoded: "with associated clinical symptoms (for example decreased appetite, weight loss, abdominal pain, abnormal vaginal bleeding)" = clinical features of concern present (the same indicator as P3 bullet 4's "No clinical features of concern") — ruling: ________  by: ________
Q21 "Urinary tract presentations and suspected renal abnormality" — reading encoded: one indicator with the published wording (whether "and" means both or either is left to the answerer) — ruling: ________  by: ________
Q22 Age — reading encoded: the heading says "Adult" and prints no band; adult = age over 15 (Overview p4), as CT CAP; age unknown leaves every met row undetermined — ruling: ________  by: ________
Q23 "Suspected or symptomatic chronic pancreatitis – request acute general surgery assessment" — reading encoded: an alternative-management redirect (it is printed in that row), not an acute red flag — ruling: ________  by: ________
Q24 Redirect "Upper abdominal non-pulsatile mass, not consistent with hepatomegaly" — reading encoded: fires only when the mass, its upper-abdominal site and "not hepatomegaly" are all answered; a lower abdominal mass meets neither this redirect nor P3 bullet 7 — ruling: ________  by: ________

## Matrix cases
MW-009 (requested as CT CAP; evaluator expected US Abdomen acute) — encoded as a US Abdomen request: USAB-M01 → insufficient information (obvious cause not stated; list headed by the obvious-cause and mass questions); USAB-M02 with "no obvious cause" → Acute: within 48 hours.
RP-002 (evaluator expected P3 on the hepatomegaly pathway) — USAB-M03 → P3; USAB-M04/M05 show the strict/inferred difference.
CB-001 (evaluator expected Declined) — USAB-M06 → insufficient information (the engine does not assume a row is not met).
CB-002 (evaluator expected At risk / Proceeds) — USAB-M07 → insufficient information (no ULN multiple, no GGT).

Signed off by: ____________________  Role: ____________  Date: ________
State → signed-off   (publish on: ________ by: ________)
