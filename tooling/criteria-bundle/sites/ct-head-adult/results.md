# Scenario results - CRR_CTHead_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| CTH-RP-000 | strict | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended, history.chronicIllnessWithCerebralInvolvement, symptom.headacheWorseOnCoughSneezeValsalva, symptom.headachePersistentNauseaVomiting, symptom.neuroDeficitSpeechOrWeakness | PASS |
| CTH-RP-000b-age-modifier | strict | P2_URGENT (P2) | - | PASS |
| CTH-RP-003 | strict | ACUTE_48H (A48) | - | PASS |
| CTH-RP-004 | strict | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended, history.chronicIllnessWithCerebralInvolvement, symptom.headacheWorseOnCoughSneezeValsalva, symptom.neuroDeficitSpeechOrWeakness | PASS |
| CTH-DG-001 | strict | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.headachePatternChangeProgressive, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended | PASS |
| CTH-DG-002 | strict | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.headachePatternChangeProgressive, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended | PASS |
| CTH-DG-002-inferred | inferred | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended, history.chronicIllnessWithCerebralInvolvement, symptom.headacheWorseOnCoughSneezeValsalva, symptom.headachePersistentNauseaVomiting, symptom.neuroDeficitSpeechOrWeakness | PASS |
| CTH-INT-SAH | strict | INSUFFICIENT_INFORMATION | redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.headachePatternChangeProgressive, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended | PASS |
| CTH-W01-focal-vs-tia-gateway | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S01-empty | strict | INSUFFICIENT_INFORMATION | patient.age, redflag.suspectedTIA, symptom.focalNeurologicalSigns, symptom.seizure, symptom.headachePatternChangeProgressive, symptom.cognitiveImpairment, symptom.firstSeizure, advice.acuteImagingRecommended, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended | PASS |
| CTH-S02-all-no | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S03-tia-specialist | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S04-tia-specialist-no-name | strict | ACUTE_48H (A48) | advice.adviserNameRole | PASS |
| CTH-S05-tia-bpac | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S06-tia-bpac-af | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S07-tia-no-rapid-access | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S08-tia-day-7 | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S09-tia-day-8 | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S10-tia-age-58 | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S11-tia-age-59 | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S12-abcd2-4 | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S13-abcd2-5 | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S14-tia-insufficient | strict | INSUFFICIENT_INFORMATION | advice.strokeSpecialistRecommended, workup.abcd2Score, symptom.crescendoTIA, history.atrialFibrillation, history.anticoagulantTherapy, symptom.tiaSevereOrProlongedDeficit, history.carotidStenosis, workup.suitableForCommunityManagement, advice.decisionSupportToolCompleted, advice.rapidSpecialistCareAccessible | PASS |
| CTH-S15-palliative-seizure-35 | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S16-palliative-seizure-70 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTH-S17-acute-advice | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S18-headache-valsalva | strict | P2_URGENT (P2) | - | PASS |
| CTH-S19-headache-no-feature | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S20-cognitive-falls | strict | P2_URGENT (P2) | - | PASS |
| CTH-S21-cognitive-incontinence | strict | P2_URGENT (P2) | - | PASS |
| CTH-S22-cognitive-focal-signs | strict | ACUTE_48H (A48) | - | PASS |
| CTH-S23-cognitive-p4 | strict | P4_DEFERRABLE (P4) | - | PASS |
| CTH-S24-cognitive-insufficient | strict | INSUFFICIENT_INFORMATION | symptom.rapidCognitiveDecline, history.falls, history.anticoagulantTherapy, symptom.gaitAtaxia, redflag.bowelOrBladderIncontinence, history.cancerWithBrainMetastasisPropensity, workup.subtypeDiagnosisAltersManagement | PASS |
| CTH-S25-cognitive-subtype-no | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S26-first-seizure-low-risk | strict | P2_URGENT (P2) | - | PASS |
| CTH-S27-first-seizure-age-20 | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S28-first-seizure-age-21 | strict | P2_URGENT (P2) | - | PASS |
| CTH-S29-first-seizure-age-40 | strict | P2_URGENT (P2) | - | PASS |
| CTH-S30-first-seizure-age-41 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTH-S31-first-seizure-mri-unavailable | strict | P2_URGENT (P2) | - | PASS |
| CTH-S32-first-seizure-insufficient | strict | INSUFFICIENT_INFORMATION | symptom.seizureClearHistory, symptom.seizureSingle, symptom.seizureUnprovokedOrSubstanceProvoked, symptom.returnedToNormalHealth, advice.mriAvailable, history.headInjury, symptom.fever, symptom.systemicSymptoms, history.anticoagulation, history.malignancy, symptom.newFocalNeurologicalDeficit, symptom.seizureFocal, symptom.persistentAlteredMentalState, symptom.headachePersistent, history.palliativeCare | PASS |
| CTH-S33-seizure-head-injury | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTH-S34-poorly-controlled-seizures | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTH-S35-prolactinoma | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| CTH-S36-advanced-dementia | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| CTH-S37-dementia-2-years | strict | CRITERIA_NOT_MET | - | PASS |
| CTH-S38-urgent-advice | strict | P2_URGENT (P2) | - | PASS |
| CTH-S39-non-urgent-advice-no-name | strict | P4_DEFERRABLE (P4) | advice.adviserNameRole | PASS |
| CTH-S40-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| CTH-S41-p2-with-acute-unknown | strict | P2_URGENT (P2) | - | PASS |
| CTH-S42-age-unknown | strict | INSUFFICIENT_INFORMATION | patient.age | PASS |
