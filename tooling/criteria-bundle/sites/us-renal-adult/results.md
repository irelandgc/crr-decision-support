# Scenario results - CRR_USRenal_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| USR-M01-RP-006 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-M02-INT-AKI | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-M03-CR-003 | strict | P4_DEFERRABLE (P4) | - | PASS |
| USR-M04-MW-010 | strict | INSUFFICIENT_INFORMATION | redflag.renalColicAcuteEpisode, symptom.renalColicFirstPresentation, patient.pregnant, symptom.chronicUrinaryRetentionSuspected, advice.acuteImagingRecommended, symptom.haematuriaMacroscopic, patient.ivContrastAllergy, lab.egfr.value, patient.takingMetformin, patient.hyperthyroidism, advice.urgentImagingRecommended, patient.ckdNewDiagnosis, patient.diabetes, lab.egfr.decreaseWithin12m, lab.acr.value, symptom.varicoceleNewRightOrBilateral, symptom.utiCount12m, symptom.utiCount6m, patient.onUtiProphylacticAntibiotics, lab.persistentBacteriuriaSameOrganism, symptom.recurrentLoinPainSuggestingObstruction, advice.nonUrgentImagingRecommended, symptom.haematuriaMicroscopic, workup.renalStoneFollowUpPerHealthPathway, workup.kubXrayCalculusVisible, patient.bmi | PASS |
| USR-M05-INT-001-strict | strict | INSUFFICIENT_INFORMATION | redflag.renalColicAcuteEpisode, patient.pregnant, symptom.chronicUrinaryRetentionSuspected, advice.acuteImagingRecommended, symptom.haematuriaMacroscopic, patient.ivContrastAllergy, patient.takingMetformin, patient.hyperthyroidism, advice.urgentImagingRecommended, patient.ckdNewDiagnosis, patient.diabetes, lab.egfr.decreaseWithin12m, lab.acr.value, symptom.varicoceleNewRightOrBilateral, symptom.utiCount12m, symptom.utiCount6m, patient.onUtiProphylacticAntibiotics, lab.persistentBacteriuriaSameOrganism, symptom.recurrentLoinPainSuggestingObstruction, advice.nonUrgentImagingRecommended, symptom.haematuriaMicroscopic, workup.renalStoneFollowUpPerHealthPathway, workup.kubXrayCalculusVisible, patient.bmi | PASS |
| USR-M06-INT-001-inferred | inferred | ACUTE_48H (A48) | - | PASS |
| USR-S01-acute-colic-female-under-35 | strict | ACUTE_48H (A48) | - | PASS |
| USR-S02-acute-colic-pregnant-38 | strict | ACUTE_48H (A48) | - | PASS |
| USR-S03-colic-male-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S04-colic-female-35-boundary | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S05-colic-recurrent-female-under-35 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S06-acute-chronic-retention | strict | ACUTE_48H (A48) | - | PASS |
| USR-S07-acute-advice-no-name | strict | ACUTE_48H (A48) | advice.adviserNameRole | PASS |
| USR-S08-p2-macro-39 | strict | P2_URGENT (P2) | - | PASS |
| USR-S09-p2-macro-86 | strict | P2_URGENT (P2) | - | PASS |
| USR-S10-macro-85-no-uti-ct-ivu | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S11-p2-macro-60-metformin | strict | P2_URGENT (P2) | - | PASS |
| USR-S12-p2-macro-40-egfr-29 | strict | P2_URGENT (P2) | - | PASS |
| USR-S13-macro-60-contrast-unknown | strict | INSUFFICIENT_INFORMATION | patient.ivContrastAllergy, lab.egfr.value, patient.takingMetformin, patient.hyperthyroidism | PASS |
| USR-S14-p2-advice | strict | P2_URGENT (P2) | - | PASS |
| USR-S15-p3-micro-male-51-ex-smoker | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S16-micro-male-50-current-smoker | strict | P4_DEFERRABLE (P4) | - | PASS |
| USR-S17-micro-male-60-smoking-unknown | strict | INSUFFICIENT_INFORMATION | patient.smokingStatus | PASS |
| USR-S18-p3-ckd-egfr-28 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S19-p3-ckd-egfr-40-diabetes | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S20-p3-ckd-egfr-55-decrease-15 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S21-p3-ckd-acr-251 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S22-ckd-boundaries-not-met | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S23-p3-varicocele | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S24-p3-uti-men-recurrent | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S25-p3-uti-women-4-in-year | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S26-p3-uti-women-6m-prophylaxis | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S27-nf-recurrent-uti-women | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S28-p3-uti-women-persistent | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S29-p3-incontinence-men-palpable | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S30-incontinence-men-aki-redirect | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S31-p3-incontinence-renal-impairment | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S32-p3-recurrent-loin-pain | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S33-p3-advice | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USR-S34-p4-micro-male-70-non-smoker | strict | P4_DEFERRABLE (P4) | - | PASS |
| USR-S35-p4-micro-male-30-no-smoking | strict | P4_DEFERRABLE (P4) | - | PASS |
| USR-S36-s2-stone-follow-up | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| USR-S37-s2-bmi-30-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S38-am-angiomyolipoma-1-5cm | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S39-angiomyolipoma-1cm-gap | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S40-am-diabetic-repeat | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S41-am-prostate-psa | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S42-am-isolated-proteinuria | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S43-luts-with-retention | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S44-am-abdominal-mass | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USR-S45-nf-hypertension | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S46-nf-catheter-bacteriuria | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S47-catheter-bacteriuria-unwell-unknown | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S48-nf-simple-cyst | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S49-nf-angiomyolipoma-0-8cm | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S50-nf-adpkd-screening | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S51-nf-pkd-serial | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USR-S52-pkd-serial-report-indicates | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S53-pkd-serial-new-symptom-meets-p4 | strict | P4_DEFERRABLE (P4) | - | PASS |
| USR-S54-highest-priority-wins | strict | P2_URGENT (P2) | - | PASS |
| USR-S55-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| USR-S56-all-rows-not-met | strict | CRITERIA_NOT_MET | - | PASS |
| USR-S57-strict-inferred-micro | strict | INSUFFICIENT_INFORMATION | symptom.haematuriaMicroscopic | PASS |
| USR-S58-inferred-standard-micro | inferred | P4_DEFERRABLE (P4) | - | PASS |
| USR-S59-empty | strict | INSUFFICIENT_INFORMATION | redflag.renalColicAcuteEpisode, symptom.renalColicFirstPresentation, patient.pregnant, patient.sex, patient.age, symptom.chronicUrinaryRetentionSuspected, advice.acuteImagingRecommended, symptom.haematuriaMacroscopic, patient.ivContrastAllergy, lab.egfr.value, patient.takingMetformin, patient.hyperthyroidism, advice.urgentImagingRecommended, patient.ckdNewDiagnosis, patient.diabetes, lab.egfr.decreaseWithin12m, lab.acr.value, symptom.varicoceleNewRightOrBilateral, symptom.utiConfirmedCount, lab.persistentBacteriuriaSameOrganism, symptom.utiCount12m, symptom.utiCount6m, patient.onUtiProphylacticAntibiotics, symptom.urinaryIncontinence, symptom.palpableBladder, lab.renalImpairmentNewOrDeteriorating, symptom.recurrentLoinPainSuggestingObstruction, advice.nonUrgentImagingRecommended, symptom.haematuriaMicroscopic, patient.smokingStatus, workup.renalStoneFollowUpPerHealthPathway, workup.kubXrayCalculusVisible, patient.bmi | PASS |
