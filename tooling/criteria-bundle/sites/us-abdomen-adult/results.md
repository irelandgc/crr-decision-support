# Scenario results - CRR_USAbdomen_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| USAB-M01-MW-009-as-US | strict | INSUFFICIENT_INFORMATION | workup.jaundiceObviousCause, advice.acuteImagingRecommended, lab.alp.timesULN, lab.ggt.raised, symptom.biliaryColicOrCholecystitis, lab.alp.high, symptom.settlesWithAnalgesia, imaging.biliaryTree.ever, advice.urgentImagingRecommended, symptom.recurrentRUQOrEpigastricPain, symptom.dyspepsia, imaging.presentingProblem.ever, symptom.biliaryColicResolved, imaging.gallstones.ever, workup.cholecystectomyCandidate, lab.repeatAfter3Months, lab.alp.repeatHigh, lab.ggt.repeatRaised, lab.alt.value, workup.conservativeMethodsUnsuccessful, workup.clinicalFeaturesOfConcern, lab.isolatedLftAbnormality, lab.ggt.timesULN, lab.ggt.repeatTimesULN, symptom.aaaNewlySuspected, symptom.aaaAsymptomatic, symptom.abdominalMassNonPulsatile, advice.nonUrgentImagingRecommended, advice.hccSurveillance, advice.aaaSurveillance, advice.incidentalFindingFollowUp | PASS |
| USAB-M02-MW-009-no-cause | strict | ACUTE_48H (A48) | - | PASS |
| USAB-M03-RP-002 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-M04-RP-002-mass-inferred | strict | INSUFFICIENT_INFORMATION | symptom.jaundice, redflag.painfulJaundice, workup.jaundiceObviousCause, advice.acuteImagingRecommended, lab.alp.timesULN, lab.ggt.raised, symptom.biliaryColicOrCholecystitis, lab.alp.high, symptom.settlesWithAnalgesia, imaging.biliaryTree.ever, advice.urgentImagingRecommended, symptom.recurrentRUQOrEpigastricPain, symptom.dyspepsia, imaging.presentingProblem.ever, symptom.biliaryColicResolved, imaging.gallstones.ever, workup.cholecystectomyCandidate, lab.repeatAfter3Months, lab.alp.repeatHigh, lab.ggt.repeatRaised, lab.alt.value, patient.liverRiskFactors, workup.conservativeMethodsUnsuccessful, workup.clinicalFeaturesOfConcern, lab.isolatedLftAbnormality, lab.ggt.timesULN, lab.ggt.repeatTimesULN, symptom.aaaNewlySuspected, symptom.aaaAsymptomatic, symptom.abdominalMassNonPulsatile, advice.nonUrgentImagingRecommended, advice.hccSurveillance, advice.aaaSurveillance, advice.incidentalFindingFollowUp | PASS |
| USAB-M05-RP-002-inferred-standard | inferred | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-M06-CB-001 | strict | INSUFFICIENT_INFORMATION | symptom.jaundice, redflag.painfulJaundice, workup.jaundiceObviousCause, advice.acuteImagingRecommended, lab.alp.timesULN, lab.ggt.raised, symptom.biliaryColicOrCholecystitis, lab.alp.high, symptom.settlesWithAnalgesia, imaging.biliaryTree.ever, advice.urgentImagingRecommended, symptom.recurrentRUQOrEpigastricPain, symptom.dyspepsia, imaging.presentingProblem.ever, symptom.biliaryColicResolved, imaging.gallstones.ever, workup.cholecystectomyCandidate, lab.repeatAfter3Months, lab.alp.repeatHigh, lab.ggt.repeatRaised, lab.alt.value, patient.liverRiskFactors, workup.conservativeMethodsUnsuccessful, workup.clinicalFeaturesOfConcern, lab.isolatedLftAbnormality, lab.ggt.timesULN, lab.ggt.repeatTimesULN, symptom.aaaNewlySuspected, symptom.aaaAsymptomatic, symptom.abdominalMassNonPulsatile, symptom.hepatomegalySuspected, advice.nonUrgentImagingRecommended, advice.hccSurveillance, advice.aaaSurveillance, advice.incidentalFindingFollowUp | PASS |
| USAB-M07-CB-002 | strict | INSUFFICIENT_INFORMATION | symptom.jaundice, redflag.painfulJaundice, workup.jaundiceObviousCause, advice.acuteImagingRecommended, lab.alp.timesULN, lab.ggt.raised, symptom.biliaryColicOrCholecystitis, lab.alp.high, symptom.settlesWithAnalgesia, imaging.biliaryTree.ever, advice.urgentImagingRecommended, symptom.recurrentRUQOrEpigastricPain, symptom.dyspepsia, imaging.presentingProblem.ever, symptom.biliaryColicResolved, imaging.gallstones.ever, workup.cholecystectomyCandidate, lab.repeatAfter3Months, lab.alp.repeatHigh, lab.ggt.repeatRaised, lab.alt.value, patient.liverRiskFactors, workup.conservativeMethodsUnsuccessful, workup.clinicalFeaturesOfConcern, lab.isolatedLftAbnormality, lab.ggt.timesULN, lab.ggt.repeatTimesULN, symptom.aaaNewlySuspected, symptom.aaaAsymptomatic, symptom.abdominalMassNonPulsatile, symptom.hepatomegalySuspected, advice.nonUrgentImagingRecommended, advice.hccSurveillance, advice.aaaSurveillance, advice.incidentalFindingFollowUp | PASS |
| USAB-S01-acute-advice | strict | ACUTE_48H (A48) | advice.adviserNameRole | PASS |
| USAB-S02-acute-advice-named | strict | ACUTE_48H (A48) | - | PASS |
| USAB-S03-jaundice-obvious-cause | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S04-jaundice-pain-unknown | strict | INSUFFICIENT_INFORMATION | redflag.painfulJaundice | PASS |
| USAB-S05-p2-alp-ggt | strict | P2_URGENT (P2) | - | PASS |
| USAB-S06-p2-alp-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S07-p2-ggt-multiple | strict | P2_URGENT (P2) | - | PASS |
| USAB-S08-p2-settled-biliary-colic | strict | P2_URGENT (P2) | - | PASS |
| USAB-S09-p2-biliary-tree-imaged | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S10-p2-advice | strict | P2_URGENT (P2) | advice.adviserNameRole | PASS |
| USAB-S11-p3-recurrent-pain | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S12-dyspepsia-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S13-p3-resolved-biliary-colic | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S14-p3-follow-up-alp-ggt | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S15-alp-normal-ggt-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S16-p3-alt | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S17-p3-alt-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S18-p3-isolated-ggt | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S19-isolated-ggt-under-5-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S20-p3-aaa | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S21-upper-mass-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S22-p3-advice | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S23-s3-hcc | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USAB-S24-s3-incidental | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USAB-S25-s3-aaa-surveillance | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USAB-S26-p2-over-p3 | strict | P2_URGENT (P2) | - | PASS |
| USAB-S27-p3-met-higher-unknown | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S28-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| USAB-S29-age-unknown | strict | INSUFFICIENT_INFORMATION | patient.age | PASS |
| USAB-S30-criteria-not-met | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S31-several-redirects | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S32-suspected-malignancy-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S33-malignancy-redirect-incomplete | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S34-bloating-with-symptoms | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S35-nf-bloating | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USAB-S36-nf-screening-fatty-liver | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USAB-S37-nf-over-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S38-nf-gallstone-follow-up | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USAB-S45-nf-with-row-met | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USAB-S46-nf-with-row-undetermined | strict | INSUFFICIENT_INFORMATION | symptom.jaundice, redflag.painfulJaundice, workup.jaundiceObviousCause, advice.acuteImagingRecommended, lab.alp.timesULN, lab.ggt.raised, symptom.biliaryColicOrCholecystitis, lab.alp.high, symptom.settlesWithAnalgesia, imaging.biliaryTree.ever, advice.urgentImagingRecommended, symptom.recurrentRUQOrEpigastricPain, symptom.dyspepsia, imaging.presentingProblem.ever, symptom.biliaryColicResolved, imaging.gallstones.ever, workup.cholecystectomyCandidate, lab.repeatAfter3Months, lab.alp.repeatHigh, lab.ggt.repeatRaised, lab.alt.value, patient.liverRiskFactors, workup.conservativeMethodsUnsuccessful, workup.clinicalFeaturesOfConcern, lab.isolatedLftAbnormality, lab.ggt.timesULN, lab.ggt.repeatTimesULN, symptom.aaaNewlySuspected, symptom.aaaAsymptomatic, symptom.abdominalMassNonPulsatile, symptom.hepatomegalySuspected, advice.nonUrgentImagingRecommended, advice.hccSurveillance, advice.aaaSurveillance, advice.incidentalFindingFollowUp | PASS |
| USAB-S47-nf-all-rows-false | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USAB-S41-p2-initial-ggt-normal-at-repeat | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USAB-S42-age-15 | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| USAB-S48-age-16 | strict | P2_URGENT (P2) | - | PASS |
| USAB-S43-ggt-initial-exactly-5 | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S44-ggt-repeat-exactly-5 | strict | CRITERIA_NOT_MET | - | PASS |
| USAB-S39-strict-inferred | strict | INSUFFICIENT_INFORMATION | lab.ggt.raised | PASS |
| USAB-S40-inferred-standard | inferred | P2_URGENT (P2) | - | PASS |
