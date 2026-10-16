# Scenario results - CRR_CTChest_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| CTCH-S01-empty | strict | INSUFFICIENT_INFORMATION | patient.age, redflag.haemoptysisPresent, symptom.haemoptysisWithoutChestInfection, workup.upperAirwayBleedingExcluded, workup.cxr, workup.initialInvestigationsCauseNotFound, patient.currentSmoker, symptom.newOnset, symptom.persistentSixWeeksDespiteTreatment, workup.bloods, symptom.dyspnoeaUnexplainedNewOrWorsening, symptom.coughUnexplainedOver3Weeks, symptom.chestShoulderPainUnexplainedOver3Weeks, symptom.chronicRespiratorySymptomChangeOver3Weeks, symptom.hoarsenessUnexplainedOver3Weeks, symptom.chestInfectionsRepeatedOrUnresolved, symptom.haemoptysisPersistentUnexplained, symptom.weightAndAppetiteLossOver3Weeks, symptom.abnormalChestSignsOver3Weeks, symptom.supraclavicularLymphadenopathyNew, symptom.paraneoplasticFeatures, symptom.cervicalLymphadenopathyOver3WeeksOver1cm, workup.cxrIndeterminateAbnormality, workup.radiologyReportRecommendsImaging, workup.cxrPersistentConsolidationFollowUp, advice.urgentStagingCtRecommended, advice.localHealthPathwayAdvisesCt, advice.urgentImagingRecommended, workup.cxrIsolatedPulmonaryNodule, workup.cxrNoduleNotConfirmedBenign, advice.nonUrgentImagingRecommended | PASS |
| CTCH-S02-p2-haemoptysis | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S03-p2-haemoptysis-infection | strict | CRITERIA_NOT_MET | - | PASS |
| CTCH-S04-p2-smoker-over-55 | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S05-p2-smoker-age-55-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| CTCH-S06-p2-smoker-insufficient | strict | INSUFFICIENT_INFORMATION | symptom.newOnset, symptom.persistentSixWeeksDespiteTreatment, symptom.dyspnoeaUnexplainedNewOrWorsening, symptom.coughUnexplainedOver3Weeks, symptom.chestShoulderPainUnexplainedOver3Weeks, symptom.chronicRespiratorySymptomChangeOver3Weeks, symptom.hoarsenessUnexplainedOver3Weeks, symptom.chestInfectionsRepeatedOrUnresolved, symptom.haemoptysisPersistentUnexplained, symptom.weightAndAppetiteLossOver3Weeks, symptom.abnormalChestSignsOver3Weeks, symptom.supraclavicularLymphadenopathyNew, symptom.paraneoplasticFeatures, symptom.cervicalLymphadenopathyOver3WeeksOver1cm | PASS |
| CTCH-S07-p2-smoker-no-concerning-symptom | strict | CRITERIA_NOT_MET | - | PASS |
| CTCH-S08-p2-indeterminate-cxr | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S09-p2-persistent-consolidation | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S10-p2-staging | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S11-p2-staging-pathway-unknown | strict | INSUFFICIENT_INFORMATION | advice.localHealthPathwayAdvisesCt | PASS |
| CTCH-S12-p2-specialist-no-name | strict | P2_URGENT (P2) | advice.adviserNameRole | PASS |
| CTCH-S13-p3-nodule | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| CTCH-S14-p3-specialist-p2-unknown | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| CTCH-S15-p2-and-p3 | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S16-redirect-incidental-ct-nodule | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTCH-S17-incidental-ct-nodule-benign | strict | CRITERIA_NOT_MET | - | PASS |
| CTCH-S18-redirect-non-specific-over-p2 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTCH-S19-redirect-re-presents | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTCH-S20-re-presents-but-p2-met | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S21-criteria-not-met-re-presentation-unknown | strict | CRITERIA_NOT_MET | - | PASS |
| CTCH-S22-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| CTCH-S23-adult-boundary | strict | P2_URGENT (P2) | - | PASS |
| CTCH-S24-strict-inferred-abnormality | strict | INSUFFICIENT_INFORMATION | workup.cxrIndeterminateAbnormality | PASS |
| CTCH-S25-inferred-standard-abnormality | inferred | P2_URGENT (P2) | - | PASS |
| CTCH-S26-national-red-flag-not-re-encoded | strict | P2_URGENT (P2) | - | PASS |
