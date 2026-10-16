# Clinical sign-off — US DVT - Adult (us-dvt-adult) — bundle 1.0.0

Source: National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026 — US DVT - Adult, pp.36–37
Transcribed by: Claude Code, 2026-10-15 (W1 demo transcription for staging under AD-35; not clinically signed off)   Engineering review of SOURCE quotes by: pending

## Reading each define against the source
[ ] Every SOURCE quote matches the source document verbatim
[ ] Every define beneath its quote says what the quote says — nothing added, nothing dropped, nothing stronger or weaker
[ ] Modifiers listed in transcription-notes.md are correctly excluded from logic
[ ] Redirects and not-funded items are complete

## REVIEW questions (answer each)
Q1 "Well's score" — the PDF names the score and links "Well's Criteria for DVT (mdcalc.com)" but does not define it — reading encoded: the score is the number the referrer documents (`workup.wellsScoreDvt`); the bundle does not compute it from its components, and a score the extraction step computes from components is `inferred` and not accepted under the strict standard — ruling: ________  by: ________
Q2 A "1" is printed after each Wells sub-bullet (Acute 48h); in the PDF it is a link to a reference dialog the PDF does not contain — reading encoded: a reference marker with no wording behind it; left out of the logic and the PlanDefinition titles — ruling: ________  by: ________
Q3 Precedence is not printed — reading encoded: redirect > highest priority met > not routinely funded > criteria not met > insufficient. Not-funded sits below the priority rows because its items are presentations, so not-funded SVT plus suspected lower limb DVT meeting Acute 48h returns Acute 48h (scenario S28). CT CAP orders not-funded first — ruling: ________  by: ________
Q4 S1 bullet 1 (no DVT on initial US, suspicion remains high, Wells ≥ 2) also meets Acute 48h whenever the referral says lower limb DVT is still clinically suspected — reading encoded: highest priority wins, so it returns Acute 48h and S1 bullet 1 is reachable only when lower limb suspicion is not answered (scenarios S13, S14). Is Acute 48h meant for the first scan only? — ruling: ________  by: ________
Q5 S2 ("Follow up scan after anticoagulation therapy as recommended by secondary care specialist") overlaps S1 bullet 3 ("Secondary care clinician or Radiologist advises referral for follow up ultrasound DVT") — reading encoded: separate indicators; if both are answered yes, S1 wins (scenario S22). Should S1 bullet 3 exclude the post-anticoagulation scan? — ruling: ________  by: ________
Q6 S2 versus not-funded "Routine follow-up scanning to confirm clot resolution" — reading encoded: if both are answered yes, S2 wins under Q3 (scenario S29) — ruling: ________  by: ________
Q7 "Children aged younger than 15 years" — reading encoded: age < 15 is redirected. Overview p4 puts "up to and including 15 years" in the paediatric band and there is no paediatric DVT section, so a 15-year-old is assessed on these criteria (scenario S24) — ruling: ________  by: ________
Q8 "Arrange the follow-up scan for 5 - 8 days after the initial scan" (S1 bullet 1) and "between 5 - 8 days after initial scan" (S1 bullet 2) — reading encoded: the specified target date for the S1 timeframe, not an eligibility condition; not encoded as logic — ruling: ________  by: ________
Q9 "a calf DVT not being treated with anticoagulation" — reading encoded: calf DVT diagnosed AND patient not on anticoagulant therapy; "to check for proximal clot extension" is the purpose, not a further condition — ruling: ________  by: ________
Q10 "Superficial venous thrombosis" (Acute 24h and not-funded) — reading encoded: a clinical diagnosis stated by the referrer, not necessarily imaging-confirmed — ruling: ________  by: ________
Q11 "Same day DVT US recommended by Health NZ Haematology service or other secondary care specialist" — reading encoded: its own indicator (`advice.sameDayImagingRecommended`), not the national `advice.acuteImagingRecommended` ("secondary care clinician, PCRL or radiologist … same or next day"), because folding would widen the criterion — ruling: ________  by: ________
Q12 S1 bullet 3 names "Secondary care clinician or Radiologist" (no PCRL) — reading encoded: `advice.followUpImagingRecommendedBySpecialist` worded without PCRL; other sites print PCRL variants of the follow-up gateway — ruling: ________  by: ________
Q13 Attestation category (AD-17) — reading encoded: "clinical suspicion remains high" is attestation (`workup.dvtClinicalSuspicionHigh`, referrer answers); "clinically suspected upper / lower limb DVT" is not (the suspected diagnosis is what the referral states) — ruling: ________  by: ________
Q14 A met lower priority is returned even when a higher row is still undetermined (e.g. S1 met, lower limb suspicion unanswered) — reading encoded: the met row is returned and nothing further is asked (scenario S13) — ruling: ________  by: ________
Q15 HealthPathways — the PDF's Source column says "HealthPathways" and the alternative-management rows say "see local DVT HealthPathway", with no page ID — reading encoded: page ID `TBC-page-id` (the published JSON cites Auckland page 32358) — ruling: ________  by: ________

## Matrix cases
None — the results matrix (`documents/CRR_Test_Case_Results_Matrix_v2.xlsx`, all four sheets) has no US DVT case. MW-004 mentions D-dimer and "Nil signs of DVT" but is a US Pelvis case (transcription-notes.md section 6).

Signed off by: ____________________  Role: ____________  Date: ________
State → signed-off   (publish on: ________ by: ________)
