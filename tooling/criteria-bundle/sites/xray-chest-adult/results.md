# Scenario results - CRR_XRChest_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| XRC-S01-matrix-LP-001-strict | strict | INSUFFICIENT_INFORMATION | symptom.suspectedCommunityAcquiredPneumonia, symptom.pneumoniaSevereOrAtypicalPresentation, symptom.atRiskOfUnderlyingLungPathology, symptom.respiratoryTractInfection, symptom.possibleLeftVentricularFailure, symptom.dyspnoeaUnexplainedNewOrWorsening, symptom.coughUnexplained, symptom.coughWorsening, symptom.coughDurationWeeks, symptom.chestOrShoulderPainUnexplained, symptom.chronicRespiratoryCondition, symptom.chronicRespiratorySymptomChangeUnexplained, symptom.chronicRespiratorySymptomChangeDurationWeeks, symptom.hoarsenessUnexplained, symptom.hoarsenessDurationWeeks, symptom.chestInfectionsRepeatedOrUnresolved, redflag.haemoptysisPresent, symptom.haemoptysisPersistentUnexplained, weightloss.present, weightloss.periodMonths, symptom.appetiteLoss, symptom.appetiteLossDurationWeeks, symptom.abnormalChestSignsUnexplained, symptom.abnormalChestSignsDurationWeeks, imaging.abnormalChestSigns.ever, symptom.supraclavicularLymphadenopathyNew, symptom.cervicalLymphadenopathyNew, symptom.cervicalLymphadenopathyDurationWeeks, symptom.cervicalLymphNodeDiameterCm, symptom.otherLungCancerFeatures, symptom.paraneoplasticFeatures, symptom.subacuteDyspnoeaUnknownCause, symptom.lowerRespiratoryTractInfection, symptom.noResponseAfter48hAntibiotics, symptom.suspectedSmallPneumothorax, advice.acuteImagingRecommended, symptom.suspectedTuberculosis, symptom.suspectedDrugInducedLungDisease, symptom.newRespiratorySymptoms, symptom.takingPneumotoxicMedication, symptom.unprovokedDvtOrPe, symptom.polymyalgiaRheumatica, symptom.pmrSteroidsStarted, advice.urgentImagingRecommended, symptom.asthmaNonAcute, symptom.asthmaDiagnosisUnclear, symptom.asthmaPoorControl, symptom.asthmaFrequentExacerbations, symptom.chronicDyspnoea, symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment, symptom.asbestosExposureHistory, imaging.cxr.ever, advice.nonUrgentImagingRecommended, imaging.followUpAfterChestInfection, symptom.ongoingSymptomsOrSignsAfterChestInfection, imaging.radiologistSuspiciousFeaturesFollowUpRecommended, advice.followUpImagingRecommendedBySpecialist, imaging.postCancerSurveillance, imaging.noduleFollowUp, advice.followUpImagingRecommended | PASS |
| XRC-S02-matrix-LP-001-inferred | inferred | INSUFFICIENT_INFORMATION | symptom.pneumoniaSevereOrAtypicalPresentation, symptom.atRiskOfUnderlyingLungPathology, symptom.possibleLeftVentricularFailure | PASS |
| XRC-S03-matrix-CR-001-strict | strict | INSUFFICIENT_INFORMATION | symptom.suspectedCommunityAcquiredPneumonia, symptom.pneumoniaSevereOrAtypicalPresentation, symptom.atRiskOfUnderlyingLungPathology, symptom.respiratoryTractInfection, symptom.possibleLeftVentricularFailure, symptom.dyspnoeaUnexplainedNewOrWorsening, symptom.coughUnexplained, symptom.coughWorsening, symptom.coughDurationWeeks, symptom.chestOrShoulderPainUnexplained, symptom.chronicRespiratoryCondition, symptom.chronicRespiratorySymptomChangeUnexplained, symptom.chronicRespiratorySymptomChangeDurationWeeks, symptom.hoarsenessUnexplained, symptom.hoarsenessDurationWeeks, symptom.chestInfectionsRepeatedOrUnresolved, redflag.haemoptysisPresent, symptom.haemoptysisPersistentUnexplained, weightloss.present, weightloss.periodMonths, symptom.appetiteLoss, symptom.appetiteLossDurationWeeks, symptom.abnormalChestSignsUnexplained, symptom.abnormalChestSignsDurationWeeks, imaging.abnormalChestSigns.ever, symptom.supraclavicularLymphadenopathyNew, symptom.cervicalLymphadenopathyNew, symptom.cervicalLymphadenopathyDurationWeeks, symptom.cervicalLymphNodeDiameterCm, symptom.otherLungCancerFeatures, symptom.paraneoplasticFeatures, symptom.subacuteDyspnoeaUnknownCause, symptom.lowerRespiratoryTractInfection, symptom.noResponseAfter48hAntibiotics, symptom.suspectedSmallPneumothorax, advice.acuteImagingRecommended, symptom.suspectedTuberculosis, symptom.suspectedDrugInducedLungDisease, symptom.newRespiratorySymptoms, symptom.takingPneumotoxicMedication, symptom.unprovokedDvtOrPe, symptom.polymyalgiaRheumatica, symptom.pmrSteroidsStarted, advice.urgentImagingRecommended, symptom.asthmaNonAcute, symptom.asthmaDiagnosisUnclear, symptom.asthmaPoorControl, symptom.asthmaFrequentExacerbations, symptom.chronicDyspnoea, symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment, symptom.asbestosExposureHistory, imaging.cxr.ever, advice.nonUrgentImagingRecommended, imaging.followUpAfterChestInfection, symptom.ongoingSymptomsOrSignsAfterChestInfection, imaging.radiologistSuspiciousFeaturesFollowUpRecommended, advice.followUpImagingRecommendedBySpecialist, imaging.postCancerSurveillance, imaging.noduleFollowUp, advice.followUpImagingRecommended | PASS |
| XRC-S04-matrix-CR-001-inferred | inferred | ACUTE_24H (A24) | - | PASS |
| XRC-S05-a24-cap-severe | strict | ACUTE_24H (A24) | - | PASS |
| XRC-S06-a24-cap-neither | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S07-a24-rti-lvf | strict | ACUTE_24H (A24) | - | PASS |
| XRC-S08-a24-started-missing | strict | INSUFFICIENT_INFORMATION | symptom.pneumoniaSevereOrAtypicalPresentation, symptom.atRiskOfUnderlyingLungPathology | PASS |
| XRC-S09-lc01-dyspnoea | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S10-lc02-cough-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S11-lc02-cough-met | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S12-lc03-chest-shoulder-pain | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S13-lc04-chronic-change | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S14-lc05-hoarseness | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S15-lc06-recurrent-infections | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S16-lc07-haemoptysis | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S17-lc08-weight-appetite | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S18-lc08-weight-too-short | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S19-lc09-chest-signs-imaged | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S20-lc09-chest-signs-not-imaged | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S21-lc10-supraclavicular | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S22-lc11-node-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S23-lc11-node-met | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S24-lc12-paraneoplastic | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S25-a48-subacute-dyspnoea | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S26-a48-lrti-not-responding | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S27-a48-small-pneumothorax | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S28-a48-advice-no-name | strict | ACUTE_48H (A48) | advice.adviserNameRole | PASS |
| XRC-S29-p2-tb | strict | P2_URGENT (P2) | - | PASS |
| XRC-S30-p2-dild | strict | P2_URGENT (P2) | - | PASS |
| XRC-S31-p2-unprovoked-pe | strict | P2_URGENT (P2) | - | PASS |
| XRC-S32-p2-pmr-before-steroids | strict | P2_URGENT (P2) | - | PASS |
| XRC-S33-p2-pmr-on-steroids | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S34-p2-advice-named | strict | P2_URGENT (P2) | - | PASS |
| XRC-S35-p3-asthma-poor-control | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S36-p3-asthma-well-controlled | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S37-p3-chronic-cough | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S38-p3-chronic-cough-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S39-p3-chronic-dyspnoea | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S40-p3-cardiorespiratory | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S41-p3-asbestos-no-cxr | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S42-p3-asbestos-prior-cxr | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S43-p3-advice-named | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S44-s2-post-infection-symptoms | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| XRC-S45-s2-post-infection-radiologist | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| XRC-S46-s2-post-infection-none | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S47-s2-post-infection-unknown | strict | INSUFFICIENT_INFORMATION | symptom.ongoingSymptomsOrSignsAfterChestInfection, imaging.radiologistSuspiciousFeaturesFollowUpRecommended, advice.followUpImagingRecommendedBySpecialist | PASS |
| XRC-S48-s2-post-cancer | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| XRC-S49-s2-nodule-recommended | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| XRC-S50-nf-nodule-not-recommended | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S51-s2-advice-no-name | strict | S2_TIME_SENSITIVE (S2) | advice.adviserNameRole | PASS |
| XRC-S52-precedence-a24-over-p3 | strict | ACUTE_24H (A24) | - | PASS |
| XRC-S53-precedence-p2-with-unknown-acute | strict | P2_URGENT (P2) | - | PASS |
| XRC-S54-am-negative-cxr | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| XRC-S55-am-over-a48 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| XRC-S56-am-unconfirmed | strict | P2_URGENT (P2) | - | PASS |
| XRC-S57-nf-immigration | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S58-nf-tb-screening | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S59-tb-screening-positive-test | strict | P2_URGENT (P2) | - | PASS |
| XRC-S60-nf-heart-murmur | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S61-heart-murmur-with-complications | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S62-nf-lung-cancer-screening | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S63-nf-rib-views | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S64-nf-hypertension | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S65-nf-drug-monitoring | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S66-p3-over-nf-asbestos | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| XRC-S67-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| XRC-S68-age-unknown | strict | INSUFFICIENT_INFORMATION | patient.age | PASS |
| XRC-S69-empty | strict | INSUFFICIENT_INFORMATION | patient.age, symptom.suspectedCommunityAcquiredPneumonia, symptom.pneumoniaSevereOrAtypicalPresentation, symptom.atRiskOfUnderlyingLungPathology, symptom.respiratoryTractInfection, symptom.possibleLeftVentricularFailure, symptom.dyspnoeaUnexplainedNewOrWorsening, symptom.coughUnexplained, symptom.coughWorsening, symptom.coughDurationWeeks, symptom.chestOrShoulderPainUnexplained, symptom.chronicRespiratoryCondition, symptom.chronicRespiratorySymptomChangeUnexplained, symptom.chronicRespiratorySymptomChangeDurationWeeks, symptom.hoarsenessUnexplained, symptom.hoarsenessDurationWeeks, symptom.chestInfectionsRepeatedOrUnresolved, redflag.haemoptysisPresent, symptom.haemoptysisPersistentUnexplained, weightloss.present, weightloss.periodMonths, symptom.appetiteLoss, symptom.appetiteLossDurationWeeks, symptom.abnormalChestSignsUnexplained, symptom.abnormalChestSignsDurationWeeks, imaging.abnormalChestSigns.ever, symptom.supraclavicularLymphadenopathyNew, symptom.cervicalLymphadenopathyNew, symptom.cervicalLymphadenopathyDurationWeeks, symptom.cervicalLymphNodeDiameterCm, symptom.otherLungCancerFeatures, symptom.paraneoplasticFeatures, symptom.subacuteDyspnoeaUnknownCause, symptom.lowerRespiratoryTractInfection, symptom.noResponseAfter48hAntibiotics, symptom.suspectedSmallPneumothorax, advice.acuteImagingRecommended, symptom.suspectedTuberculosis, symptom.suspectedDrugInducedLungDisease, symptom.newRespiratorySymptoms, symptom.takingPneumotoxicMedication, symptom.unprovokedDvtOrPe, symptom.polymyalgiaRheumatica, symptom.pmrSteroidsStarted, advice.urgentImagingRecommended, symptom.asthmaNonAcute, symptom.asthmaDiagnosisUnclear, symptom.asthmaPoorControl, symptom.asthmaFrequentExacerbations, symptom.chronicDyspnoea, symptom.cardiorespiratoryDiseaseUnresponsiveToTreatment, symptom.asbestosExposureHistory, imaging.cxr.ever, advice.nonUrgentImagingRecommended, imaging.followUpAfterChestInfection, symptom.ongoingSymptomsOrSignsAfterChestInfection, imaging.radiologistSuspiciousFeaturesFollowUpRecommended, advice.followUpImagingRecommendedBySpecialist, imaging.postCancerSurveillance, imaging.noduleFollowUp, advice.followUpImagingRecommended | PASS |
| XRC-S70-inferred-small-pneumothorax-strict | strict | INSUFFICIENT_INFORMATION | symptom.suspectedSmallPneumothorax | PASS |
| XRC-S71-inferred-small-pneumothorax-inferred | inferred | ACUTE_48H (A48) | - | PASS |
| XRC-S72-r1-nf-with-row-met | strict | P2_URGENT (P2) | - | PASS |
| XRC-S73-r1-nf-with-row-undetermined | strict | INSUFFICIENT_INFORMATION | symptom.coughWorsening, symptom.coughDurationWeeks | PASS |
| XRC-S74-r1-nf-all-rows-false | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| XRC-S75-lc04-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S76-lc05-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S77-lc08-appetite-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S78-lc08-weight-below-21-days | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S79-lc08-weight-above-21-days | strict | ACUTE_48H (A48) | - | PASS |
| XRC-S80-lc09-boundary | strict | CRITERIA_NOT_MET | - | PASS |
| XRC-S81-lc11-duration-boundary | strict | CRITERIA_NOT_MET | - | PASS |
