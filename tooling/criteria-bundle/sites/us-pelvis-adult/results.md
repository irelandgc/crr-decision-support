# Scenario results - CRR_USPelvis_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| USP-M-LP-003-strict | strict | INSUFFICIENT_INFORMATION | symptom.postmenopausalBleeding | PASS |
| USP-M-LP-003-inferred | inferred | P2_URGENT (P2) | - | PASS |
| USP-M-LP-004 | strict | INSUFFICIENT_INFORMATION | symptom.iudStringsNotVisible, symptom.iudFragmentRetained, symptom.iudPerforationSymptoms | PASS |
| USP-M-DG-004 | strict | INSUFFICIENT_INFORMATION | patient.age, workup.nonUterineBleedingCausesExcluded, symptom.pelvicMassPalpable, imaging.any.sinceSymptomOnset, patient.maoriOrPacificEthnicity, patient.bmi, patient.pcosDiagnosed, patient.chronicAnovulation, patient.nulliparous, patient.earlyMenarcheOrLateMenopause, patient.estrogenSecretingTumour, patient.unopposedEstrogenMhtLongStanding, patient.tamoxifenTherapy, patient.diabetes, lab.ironDeficiencyAnaemia, patient.familyHistoryEndometrialOvarianBreastBowelCancer | PASS |
| USP-M-DG-005 | strict | P2_URGENT (P2) | - | PASS |
| USP-M-MW-001 | strict | INSUFFICIENT_INFORMATION | symptom.ovarianCancerSymptomsPersistent, symptom.pelvicMassPalpable, lab.ca125.value, symptom.ovarianCancerSymptomsWeeks, workup.recentlyInvestigated | PASS |
| USP-M-MW-002-inferred | inferred | INSUFFICIENT_INFORMATION | symptom.pelvicMassPalpable, lab.ca125.value, symptom.ovarianCancerSymptomsWeeks, workup.recentlyInvestigated | PASS |
| USP-M-MW-004 | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-M-MW-006 | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-M-MW-007 | strict | INSUFFICIENT_INFORMATION | symptom.ovarianCancerSymptomsPersistent, symptom.pelvicMassPalpable, lab.ca125.value, workup.nonUterineBleedingCausesExcluded, imaging.any.sinceSymptomOnset, patient.maoriOrPacificEthnicity, patient.bmi, patient.pcosDiagnosed, patient.chronicAnovulation, patient.nulliparous, patient.earlyMenarcheOrLateMenopause, patient.estrogenSecretingTumour, patient.unopposedEstrogenMhtLongStanding, patient.tamoxifenTherapy, patient.diabetes, lab.ironDeficiencyAnaemia, patient.familyHistoryEndometrialOvarianBreastBowelCancer, symptom.ovarianCancerSymptomsWeeks, workup.recentlyInvestigated | PASS |
| USP-M-MW-008-inferred | inferred | INSUFFICIENT_INFORMATION | symptom.pelvicPainUnrelatedToMenstrualCycle, symptom.pid | PASS |
| USP-M-EQ-001 | strict | P3_NON_DEFERRABLE (P3) | workup.nonUterineBleedingCausesExcluded | PASS |
| USP-M-EQ-002 | strict | INSUFFICIENT_INFORMATION | workup.nonUterineBleedingCausesExcluded | PASS |
| USP-STEP3-pmb-vs-mht | strict | P2_URGENT (P2) | - | PASS |
| USP-A24-01-acutely-unwell | strict | ACUTE_24H (A24) | - | PASS |
| USP-A24-02-iud-strings | strict | ACUTE_24H (A24) | - | PASS |
| USP-A24-03-iud-fragment | strict | ACUTE_24H (A24) | - | PASS |
| USP-A24-04-iud-symptoms-unknown | strict | INSUFFICIENT_INFORMATION | symptom.iudPerforationSymptoms | PASS |
| USP-A24-05-precedence | strict | ACUTE_24H (A24) | - | PASS |
| USP-A48-01-urine-hcg | strict | ACUTE_48H (A48) | - | PASS |
| USP-A48-02-urine-hcg-boundary | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-A48-03-serum-bhcg | strict | ACUTE_48H (A48) | - | PASS |
| USP-A48-04-hcg-unknown | strict | INSUFFICIENT_INFORMATION | lab.urineHcg.value, lab.serumBhcg.remainsHigh | PASS |
| USP-A48-05-advice | strict | ACUTE_48H (A48) | - | PASS |
| USP-A48-06-advice-unnamed | strict | ACUTE_48H (A48) | advice.adviserNameRole | PASS |
| USP-P2-01-mass-suspicious | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-02-pmb | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-03-cc-mht | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-04-cc-mht-boundary | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P2-05-ca125-boundary | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-06-ca125-34-p3 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P2-07-aub-two-risk-factors | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-08-aub-mass-not-imaged | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-09-ag2 | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-10-advice | strict | P2_URGENT (P2) | - | PASS |
| USP-P2-11-lists-more-urgent | strict | P2_URGENT (P2) | lab.urineHcg.value, lab.serumBhcg.remainsHigh | PASS |
| USP-P3-01-aub-45 | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-02-aub-44 | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P3-03-aub-under45-risk | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-04-first-line-3m | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-05-first-line-under-3m | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P3-06-cyclical-mht | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-07-benign-cells-postmenopausal | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-08-cyst-unilateral-pain | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-09-cyst-pain-boundary | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P3-10-cyst-low-suspicion-mass | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-11-pelvic-pain | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-12-primary-amenorrhoea | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-13-iud-asymptomatic | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-14-secondary-dysmenorrhoea | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P3-15-advice | strict | P3_NON_DEFERRABLE (P3) | - | PASS |
| USP-P4-01-pcos-one | strict | P4_DEFERRABLE (P4) | - | PASS |
| USP-P4-02-pcos-two | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P4-03-fibroid | strict | P4_DEFERRABLE (P4) | - | PASS |
| USP-P4-04-fibroid-boundary | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-P4-05-advice | strict | P4_DEFERRABLE (P4) | - | PASS |
| USP-S2-01-orads2-6m | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| USP-S2-02-haemorrhagic | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| USP-S2-03-polyp | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| USP-S3-01-orads2-12m | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USP-S3-02-dermoid | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USP-S3-03-endometrioma | strict | S3_TIME_SENSITIVE (S3) | - | PASS |
| USP-S-04-interval-unknown | strict | INSUFFICIENT_INFORMATION | workup.followUpIntervalMonths | PASS |
| USP-AM-01-rpoc | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-02-endometriosis | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-03-endometriosis-mass-unknown | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-AM-04-primary-dysmenorrhoea | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-05-pid | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-06-cervical-polyp | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-07-secondary-amenorrhoea | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-AM-08-secondary-amenorrhoea-androgens | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-AM-09-redirect-over-p2 | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| USP-NF-01-fibroid-follow-up | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-02-subfertility | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-03-simple-cyst-post | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-04-simple-cyst-post-boundary | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-NF-05-simple-cyst-pre-over-s2 | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-06-non-simple-cyst | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-07-haemorrhagic-5cm | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-08-benign-cells | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-09-mht-bleeding-6m | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-10-mht-bleeding-7m | strict | INSUFFICIENT_INFORMATION | - | PASS |
| USP-NF-11-screening | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-12-aub-under45-untrialled | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-NF-13-over-redirect | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| USP-X-01-paediatric | strict | PAEDIATRIC_CRITERIA_APPLY | - | PASS |
| USP-X-02-age-unknown | strict | INSUFFICIENT_INFORMATION | patient.age | PASS |
| USP-X-03-criteria-not-met | strict | CRITERIA_NOT_MET | - | PASS |
| USP-SI-01-strict | strict | INSUFFICIENT_INFORMATION | symptom.acutelyUnwellSuspectedGynaeCause | PASS |
| USP-SI-02-inferred | inferred | ACUTE_24H (A24) | - | PASS |
