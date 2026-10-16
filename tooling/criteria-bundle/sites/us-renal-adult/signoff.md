# Clinical sign-off — US Renal - Adult (us-renal-adult) — bundle 1.0.0

Source: National Community Referral Criteria for Imaging (Part I), National ID 15372 v2.0, published 09/04/2026 — "US Renal - Adult", pp.52–55
Transcribed by: Claude Code, 2026-10-15 (W1 demo transcription for staging, AD-35 — NOT CLINICALLY REVIEWED)   Engineering review of SOURCE quotes by: second Claude Code session (non-authoring), 2026-10-16 — 57/57 quotes verbatim against the PDF; blocking findings fixed in the review-fix round (PR #48)

## Reading each define against the source
[ ] Every SOURCE quote matches the source document verbatim
[ ] Every define beneath its quote says what the quote says — nothing added, nothing dropped, nothing stronger or weaker
[ ] Modifiers listed in transcription-notes.md are correctly excluded from logic
[ ] Redirects and not-funded items are complete
[ ] The p52 acute-assessment row (RF-12) and the p55 renal colic red flags (RF-03) are correctly left to the national red-flag bundle

## REVIEW questions (answer each)
Q1 "First presentation of renal colic if pregnant or female younger than 35 years old" — reading encoded: pregnant (any age) OR female younger than 35 — ruling: ________  by: ________
Q2 "and no red flags* requiring admission" — reading encoded: not re-encoded at the site; satisfied by the national RF-03 not having stopped the pipeline (RF-03 runs first and shares the renal colic indicator) — ruling: ________  by: ________
Q3 Pregnancy for a male patient — reading encoded: a male patient is treated as not pregnant (so the renal colic redirect applies without asking) — ruling: ________  by: ________
Q4 "Suspected renal colic in a non-pregnant person – See local Renal Colic and Urinary Tract Stones HealthPathway" overlaps the Acute row's "female younger than 35" limb, which redirect-first precedence would make unreachable — reading encoded: the redirect does not apply to a patient who meets the Acute renal colic row (CT KUB p26 states the same intent) — ruling: ________  by: ________
Q5 "Macroscopic haematuria in patients who do not have a UTI, if aged 40 to 85 years. Refer for CT IVU" overlaps P2 "aged 40 to 85 years and unable to have intravenous contrast" — reading encoded: the redirect does not apply to a patient unable to have intravenous contrast — ruling: ________  by: ________
Q6 Age bands — reading encoded: "younger than 40" <40; "aged 86 years and older" ≥86; "aged 40 to 85 years" 40–85 inclusive; "older than 50" >50; "aged 50 years and younger" ≤50; "younger than 35" <35 — ruling: ________  by: ________
Q7 eGFR units — P2 prints "30mL/min", P3 prints "eGFR less than 30 / 45 / 60" with no unit — reading encoded: numbers compared as printed, unit not asserted — ruling: ________  by: ________
Q8 "ACR more than 250" — no unit printed (vocabulary text assumes mg/mmol, at which 250 is an unusually high threshold; 250 mg/g would be about 28 mg/mmol) — reading encoded: >250 compared, unit not asserted — ruling (unit, and whether 250 is correct): ________  by: ________
Q9 Men "recurrent UTI (i.e. 2 or more confirmed UTI)" — no time window printed — reading encoded: any 2 or more confirmed UTIs — ruling: ________  by: ________
Q10 Women "more than 3 UTIs in a year, or more than 2 in six months despite prophylactic antibiotics" — reading encoded: "despite prophylactic antibiotics" qualifies only the six-month limb; "in a year" / "in six months" are the year / six months before referral; and not-funded "Recurrent UTIs in women, except as documented above" fires when the referral states recurrent UTIs and the P3 women's row is definitively not met — ruling: ________  by: ________
Q11 "Urinary incontinence in men with palpable bladder, or new or deteriorating renal impairment" — reading encoded: male AND incontinence AND (palpable bladder OR new/deteriorating renal impairment); not "… or [any] new or deteriorating renal impairment" standing alone — ruling: ________  by: ________
Q12 "eGFR decreased by 15 or more within the previous 12 months" — reading encoded: the decrease is an answered value (≥15); a decrease the model computes from two results is 'inferred' and not used under the strict standard — ruling: ________  by: ________
Q13 Angiomyolipoma "more than 1 cm" (redirect) vs "less 1 cm" (not funded, read as "less than 1 cm") — reading encoded: a lesion of exactly 1 cm meets neither row — ruling: ________  by: ________
Q14 Timeframe order — reading encoded: Acute 48h > P2 > P3 > S2 > P4; a lower priority met while a higher one is indeterminate returns the lower priority — ruling: ________  by: ________
Q15 Redirect rows outrank every criterion when present (e.g. LUTS alongside suspected chronic urinary retention; AKI alongside incontinence with deteriorating renal impairment; enlarged prostate alongside incontinence) — reading encoded: redirect wins (TA-013) — ruling: ________  by: ________
Q16 Clinical-judgement wording ("Suspected chronic urinary retention"; "Recurrent loin pain suggesting renal tract obstruction other than renal stone") — reading encoded: extracted like any fact; candidates for the AD-17 attestation category (not added) — ruling: ________  by: ________
Q17 Vocabulary grouping — pregnancy, smoking, contrast allergy, metformin, hyperthyroidism, diabetes, diabetic renal complications, new CKD diagnosis, BMI, UTI prophylaxis and catheter are proposed under `patient` (no history/medication group exists) — reading encoded: `patient.*` — ruling: ________  by: ________
Q18 "Serial ultrasounds of known polycystic kidneys unless indicated by the radiology report, or the patient develops new symptoms that meet any of the other criteria" — reading encoded: not funded unless the report indicates it or any criterion row of this section is met — ruling: ________  by: ________
Q19 Angiomyolipoma rows — reading encoded: read on the finding (and its size) alone; whether the request is a "follow up" is not a separate indicator — ruling: ________  by: ________
Q20 S2 "Follow up, according to the Renal Colic and Urinary Tract Stones HealthPathway" — reading encoded: the referral's statement that this is that follow-up is the indicator; the HealthPathway's own conditions are not evaluated — ruling: ________  by: ________
Q21 Not-funded precedence (coordinator rule R1) — reading encoded: redirect > paediatric > most urgent met timeframe row > insufficient information (any timeframe row undetermined) > not routinely funded (only when every timeframe row is definitively not met) > criteria not met; so "Recurrent UTIs in women, except as documented above" and "Bacteriuria in patients with in-dwelling catheters who are not systemically unwell" never override a met or undetermined row (e.g. a catheterised man referred for macroscopic haematuria gets P2). Alternative reading: not funded first, as CT CAP does for its patient-level "unfit for treatment" row — ruling: ________  by: ________
Q22 "Repeat renal ultrasound for diabetic patients with known diabetic renal complications is not indicated" — reading encoded: known diabetic renal complications AND a previous renal ultrasound at any time (no interval printed; diabetes implied by the complications) — ruling: ________  by: ________

## Matrix cases
RP-006 (new AKI, eGFR 3) and INT-AKI (new AKI, eGFR 8): ALTERNATIVE_MANAGEMENT — the matrix expected "proceeds" under an "acute renal function deterioration" Acute row that v2.0 does not print. CR-003 (microscopic haematuria, female 64, non-smoker): P4 — matches. MW-010 (no renal indication stated): INSUFFICIENT_INFORMATION — the matrix expected "declined"; the engine never reads silence as "not met". INT-001 (CT KUB case, 30F first-presentation loin-to-groin pain): strict INSUFFICIENT_INFORMATION (renal colic only inferred), inferred ACUTE_48H. Details: transcription-notes.md §5.

Signed off by: ____________________  Role: ____________  Date: ________
State → signed-off   (publish on: ________ by: ________)
