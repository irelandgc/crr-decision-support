# Clinical sign-off — CT Head - Adult (ct-head-adult) — bundle 1.0.0

Source: National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026 — CT Head - Adult, pp.20–22 (footnotes *1–*4 on pp.21–22)
Transcribed by: Claude Code, 2026-10-15 (W1; staging demo only under AD-35, not clinically signed off)   Engineering review of SOURCE quotes by: pending

## Reading each define against the source
[ ] Every SOURCE quote matches the source document verbatim
[ ] Every define beneath its quote says what the quote says — nothing added, nothing dropped, nothing stronger or weaker
[ ] Modifiers listed in transcription-notes.md are correctly excluded from logic
[ ] Redirects and not-funded items are complete

## REVIEW questions (answer each)
Q1 TIA high-risk feature "Less than 59 years old" (*1, p21) is clinically unexpected (ABCD2 scores age 60 or over) — reading encoded: literal, age under 59 is a high-risk feature and closes the BPAC route (CTH-S10/S11) — ruling: ________  by: ________
Q2 "within 7 days of the TIA episode" — reading encoded: 7 days or fewer since the episode (day 7 included, day 8 not; CTH-S08/S09) — ruling: ________  by: ________
Q3 The first-seizure P2 bullet repeats a clause ("…low risk3, or where MRI … is not available, clear history, and low risk* or MRI not available") — reading encoded: union of the printed clauses, i.e. (clear history AND low risk) OR MRI not available; alternative: CT only when MRI is not available (CTH-S31: MRI not available, risk factors unanswered) — ruling: ________  by: ________
Q4 A redirect outranks a met timeframe row (BRD TA-013; CT CAP convention). Consequence: any seizure in a patient older than 40 is redirected to Neurology phone advice, including "Seizure in palliative care setting" (CTH-S15 vs S16) and a focal-signs patient who has also had a seizure — reading encoded: redirect wins — ruling: ________  by: ________
Q5 When a lower timeframe is met and a higher one is still unanswered — reading encoded: highest timeframe met wins (P2 returned, not insufficient information; CTH-S41) — ruling: ________  by: ________
Q6 "History of anticoagulation" (*3/*4) vs "Anticoagulant therapy" (*2) and "On anticoagulants" (*1) — reading encoded: two indicators, history.anticoagulation (history) and history.anticoagulantTherapy (current); current therapy also satisfies "history of". Merge into one? — ruling: ________  by: ________
Q7 Cancer list reads "– lung, melanoma, breast" in the P2 row (p21) but "(e.g. lung, melanoma, breast)" in *2 (p22) — reading encoded: one judgement indicator, list not a closed set — ruling: ________  by: ________
Q8 "Fever, systemic symptoms" and "History of anticoagulation, malignancy" (*3/*4) — reading encoded: comma as list separator, either item is a risk factor — ruling: ________  by: ________
Q9 "Gait ataxia or incontinence" — reading encoded: incontinence uses the national indicator redflag.bowelOrBladderIncontinence ("Loss of bowel or bladder control"); gait ataxia is its own indicator (narrower than redflag.gaitDisturbance) — ruling: ________  by: ________
Q10 "Focal neurologic signs" (Acute) / "Presence of focal neurological signs" (*2) / "New focal neurologic deficit" (*3/*4) / "objective neurological deficit causing disturbances of speech, or limb or facial weakness" (P2 headache) — reading encoded: first two one indicator (so cognitive impairment with focal signs meets Acute, CTH-S22); the other two separate — ruling: ________  by: ________
Q11 "associated with persistent nausea and vomiting" — reading encoded: both nausea and vomiting, persistent. Matrix RP-000 (nausea only, blurred vision) is then insufficient information, not "proceeds" as the evaluator expected — ruling: ________  by: ________
Q12 "Seizures with risk factors for intracranial pathology" and "Seizure in palliative care setting" — reading encoded: any seizure, first or not — ruling: ________  by: ________
Q13 "Established, advanced dementia of more than 2 years duration" — reading encoded: duration over 2.0 years (2 years exactly is not "more than"; CTH-S37) — ruling: ________  by: ________
Q14 Unanswered redirects — reading encoded: the two seizure redirects are surfaced as unconfirmed only when a seizure is present; "Suspected Prolactinoma" is never surfaced as unconfirmed (it is a presentation, not a general exclusion) — ruling: ________  by: ________
Q15 Footnote *1 overlaps national RF-10 ("a high seven day stroke risk*", US Carotid p34). RF-10's asterisk points at US Carotid's own p35 footnote ("*High seven-day stroke risk: Seven days or less since episode plus one or more of: ABCD2 score of 4 or higher / Anticoagulant use / … / Unilateral arm weakness"), which differs from CT Head *1 (ABCD2 4 or higher vs greater than 4; no age feature; adds unilateral arm weakness); a TIA may stop at the national layer if redflag.highSevenDayStrokeRisk is answered — reading encoded: not re-encoded here; national library owns RF-10 — ruling: ________  by: ________
Q16 "Focal neurologic signs - consider seeking neurologist advice first" — reading encoded: the advice clause is not a condition — ruling: ________  by: ________
Q17 Printed stem "TIA" (p20) — reading encoded: read through redflag.suspectedTIA; a "?TIA" query alone is not documented (matrix RP-003) — ruling: ________  by: ________
Q18 AD-17 attestation candidates: symptom.seizureClearHistory, workup.suitableForCommunityManagement, workup.resultMayChangeManagement, workup.subtypeDiagnosisAltersManagement — reading encoded: ordinary extracted indicators; not added to attestationIndicators (needs AD-23 wording) — ruling: ________  by: ________
Q19 TIA route 1 ("CT +/-CTA recommended by HNZ neurologist / stroke specialist or physician") — reading encoded: treated as an endorsement under Overview p5 (an HNZ neurologist / stroke specialist / physician read as a "secondary care clinician"), so the adviser's name and role are asked for when it is met (CTH-S04) — ruling: ________  by: ________
Q20 Not-funded precedence (coordinator rule R1) — reading encoded: redirect → paediatric → most urgent met timeframe row → insufficient information while any timeframe row is undetermined → not routinely funded only when every timeframe row is definitively not met → criteria not met (CTH-S36 all rows not met → not funded; CTH-S43 row met → P2; CTH-S44 row undetermined → insufficient). Alternative: not funded first, as CT CAP does for its patient-level "unfit for treatment" row — ruling: ________  by: ________

## Matrix cases
RP-000: engine result INSUFFICIENT_INFORMATION (asks for a qualifying headache feature) vs evaluator expectation Proceeds — ruled (see Q11); variant CTH-RP-000b shows age 45 is not a barrier
RP-003: engine result ACUTE_48H (focal neurologic signs) vs evaluator expectation Proceeds (focal neurological signs pathway) — agreed
RP-004: engine result INSUFFICIENT_INFORMATION vs evaluator expectation At risk (strict; PCRL accepts proceeds) — agreed (strict)
DG-001: engine result INSUFFICIENT_INFORMATION (no cognitive-impairment pathway, change in headache pattern asked for) vs evaluator expectation Declined (insufficient information) — agreed
DG-002: engine result INSUFFICIENT_INFORMATION under strict and under inferred vs evaluator expectation At risk / Declined — agreed
INT-SAH (no verbatim note): engine result INSUFFICIENT_INFORMATION, no redirect vs legacy expectation Declined — ED emergency — not a CT Head criterion; governance question in vocabulary finding F-01

Signed off by: ____________________  Role: ____________  Date: ________
State → signed-off   (publish on: ________ by: ________)
