# Clinical sign-off — X-ray Chest - Adult (xray-chest-adult) — bundle 1.0.0

Source: National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026 — X-ray Chest - Adult, pp.62-65 (`documents/reference/National Primary Care Referral Criteria for Imaging.pdf`)
Transcribed by: Claude Code, 2026-10-15 (W1, staging demo only under AD-35 — NOT CLINICALLY REVIEWED)   Engineering review of SOURCE quotes by: pending

## Reading each define against the source
[ ] Every SOURCE quote matches the source document verbatim
[ ] Every define beneath its quote says what the quote says — nothing added, nothing dropped, nothing stronger or weaker
[ ] Modifiers listed in transcription-notes.md are correctly excluded from logic
[ ] Redirects and not-funded items are complete
[ ] The "Refer for acute assessment without initial imaging" row (p62) is correctly left to the national red-flag library (RF-14 to RF-17)

## REVIEW questions (answer each)
Q1 More than one timeframe row met — reading encoded: the most urgent wins (Acute 24h > Acute 48h > P2 > P3 > S2) — ruling: ________  by: ________
Q2 A lower row met while a more urgent row is undetermined — reading encoded: the met row is returned; the unknown higher row does not hold it back — ruling: ________  by: ________
Q3 Outcome precedence — reading encoded: not routinely funded > alternative management > paediatric > timeframe rows (as CT CAP) — ruling: ________  by: ________
Q4 "Suspected community-acquired pneumonia (CAP) with unexpectedly severe or atypical presentation, or where the patient is considered at risk of underlying lung pathology (e.g. lung cancer)" — reading encoded: suspected CAP AND (unexpectedly severe or atypical presentation OR considered at risk of underlying lung pathology); "(e.g. lung cancer)" illustrative — ruling: ________  by: ________
Q5 "One or more of the following symptoms or signs concerning for lung cancer" — reading encoded: any one of the twelve listed items; no separate "concerning for lung cancer" judgement — ruling: ________  by: ________
Q6 "Unexplained, new, or worsening dyspnoea" — reading encoded: one indicator carrying the published wording; whether the three adjectives are alternatives (any one) or cumulative is not decided in logic — ruling: ________  by: ________
Q7 "more than 3 weeks", "more than 8 weeks", "greater than 1 cm" — reading encoded: strictly greater (exactly 3 weeks, 8 weeks, 1 cm do not qualify) — ruling: ________  by: ________
Q8 "Unexplained weight loss and loss of appetite persisting for more than 3 weeks" — reading encoded: both present and both persisting more than 3 weeks; weight-loss duration taken from the existing months indicator (more than 21 days, month = 30.4375 days) — ruling: ________  by: ________
Q9 "Persistent, unexplained haemoptysis in the absence of red flags" — reading encoded: "absence of red flags" is satisfied by the national red-flag layer running first; this site does not re-test the RF-14 features — ruling: ________  by: ________
Q10 "where the lymph nodes are greater than 1 cm in diameter" — reading encoded: the largest cervical node is greater than 1 cm — ruling: ________  by: ________
Q11 "Suspected tuberculosis - follow the Tuberculosis pathway and request a CXR if indicated" — reading encoded: suspected TB alone meets P2; "if indicated" left to the referrer and the TB pathway — ruling: ________  by: ________
Q12 "Polymyalgia Rheumatica (PMR) - request CXR for all patients prior to starting steroids" — reading encoded: PMR AND steroids not yet started (PMR already on steroids does not meet P2) — ruling: ________  by: ________
Q13 "Idiopathic / unprovoked DVT or PE - as required" — reading encoded: "as required" is not a condition; unprovoked DVT/PE meets P2 — ruling: ________  by: ________
Q14 Non-acute asthma P3 bullet — reading encoded: "For investigation of alternative diagnoses or co-morbidities" is a purpose, not a condition — ruling: ________  by: ________
Q15 S2 "6 week follow up chest X-ray after chest infection" and not funded "Routine follow-up of pneumonia findings on chest x-ray, other than ... under S2" — reading encoded: the same request; not funded when none of the three S2 sub-conditions holds — ruling: ________  by: ________
Q16 One recommendation indicator serves "when recommended by secondary care clinician or radiologist", "documented specialist recommendation", "if recommended by a secondary care clinician or radiologist" and the not-funded exception "documented recommendation of a hospital secondary care clinician or radiologist" — reading encoded: one concept, distinct from the PCRL-inclusive "advises referral for follow-up x-ray" gateway — ruling: ________  by: ________
Q17 Not-funded items — reading encoded: each is the purpose of the request, not a finding in the patient (e.g. "Heart murmur" = the X-ray is requested for a heart murmur) — ruling: ________  by: ________
Q18 "Routine lateral x-ray view when requesting a PA image" — reading encoded: NOT ENCODED (it withholds a view, not the referral); shown in the not-funded list only — ruling: ________  by: ________
Q19 Asbestos: P3 "History of asbestos exposure and no previous chest x-ray" against not funded "Asbestos exposure surveillance" — reading encoded: a request for surveillance is not funded even when no X-ray has been done (Q3 precedence) — ruling: ________  by: ________
Q20 Alternative management "Ongoing unexplained respiratory symptoms after a negative chest X-ray result, especially if clinical concern of malignancy" — reading encoded: ongoing unexplained respiratory symptoms AND a previous negative chest X-ray; "especially if ..." is a modifier — ruling: ________  by: ________
Q21 Referrer judgements ("unexpectedly severe or atypical presentation", "considered at risk of underlying lung pathology", "other lung cancer symptoms, signs, or risk factors") — reading encoded: ordinary indicators; proposed as AD-17 attestation candidates, not added to the category — ruling: ________  by: ________
Q22 "advises referral for acute x-ray" (Acute: Within 48 hours) — reading encoded: the national acute gateway indicator, whose vocabulary wording says "same or next day scan" — ruling: ________  by: ________
Q23 Missing-information list when nothing has been started — reading encoded: every undetermined pathway's unanswered indicators (about 60 for a note with no documented criterion) — ruling: ________  by: ________

## Matrix cases
LP-001 (legacy verdict Proceeds; evaluator expected Proceeds): strict → INSUFFICIENT_INFORMATION (CAP only inferable); inferred → INSUFFICIENT_INFORMATION, asks for severity/risk and LVF — ruling: ________
CR-001 (legacy verdict Proceeds; evaluator expected Proceeds): strict → INSUFFICIENT_INFORMATION; inferred → Acute 24h — ruling: ________

Signed off by: ____________________  Role: ____________  Date: ________
State → signed-off   (publish on: ________ by: ________)
