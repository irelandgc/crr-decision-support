# Scenario results - CRR_USDVT_Adult

| Scenario | Standard | Determination | Missing information | Result |
|---|---|---|---|---|
| DVT-S01-a24-svt-proximal-lsv | strict | ACUTE_24H (A24) | - | PASS |
| DVT-S02-a24-upper-limb | strict | ACUTE_24H (A24) | - | PASS |
| DVT-S03-a24-same-day-advice | strict | ACUTE_24H (A24) | - | PASS |
| DVT-S04-a24-advice-no-adviser | strict | ACUTE_24H (A24) | advice.adviserNameRole | PASS |
| DVT-S05-a48-wells-2-boundary | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S06-a48-wells-1-ddimer-pos | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S07-a48-wells-1-ddimer-neg | strict | CRITERIA_NOT_MET | - | PASS |
| DVT-S08-a48-ddimer-unknown | strict | INSUFFICIENT_INFORMATION | lab.ddimer.positive | PASS |
| DVT-S09-a48-wells-unknown | strict | INSUFFICIENT_INFORMATION | workup.wellsScoreDvt, lab.ddimer.positive | PASS |
| DVT-S10-a48-wells-4-ddimer-neg | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S11-a48-negative-wells | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S12-wells-without-suspicion | strict | CRITERIA_NOT_MET | - | PASS |
| DVT-S13-s1-negative-initial-us | strict | S1_TIME_SENSITIVE (S1) | - | PASS |
| DVT-S14-s1-overlaps-a48 | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S15-s1-wells-1 | strict | CRITERIA_NOT_MET | - | PASS |
| DVT-S16-s1-suspicion-unknown | strict | INSUFFICIENT_INFORMATION | workup.dvtClinicalSuspicionHigh | PASS |
| DVT-S17-s1-calf-no-anticoag | strict | S1_TIME_SENSITIVE (S1) | - | PASS |
| DVT-S18-s1-calf-on-anticoag | strict | CRITERIA_NOT_MET | - | PASS |
| DVT-S19-s1-calf-anticoag-unknown | strict | INSUFFICIENT_INFORMATION | history.anticoagulantTherapy | PASS |
| DVT-S20-s1-follow-up-advice | strict | S1_TIME_SENSITIVE (S1) | - | PASS |
| DVT-S21-s2-post-anticoag | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| DVT-S22-s2-overlaps-s1-advice | strict | S1_TIME_SENSITIVE (S1) | - | PASS |
| DVT-S23-redirect-child | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| DVT-S24-age-15-boundary | strict | ACUTE_24H (A24) | - | PASS |
| DVT-S25-redirect-pregnant | strict | ALTERNATIVE_MANAGEMENT | - | PASS |
| DVT-S26-nf-svt-not-proximal | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| DVT-S27-nf-routine-clot-resolution | strict | NOT_ROUTINELY_FUNDED | - | PASS |
| DVT-S28-nf-svt-with-dvt-criteria | strict | ACUTE_48H (A48) | - | PASS |
| DVT-S29-s2-vs-routine-follow-up | strict | S2_TIME_SENSITIVE (S2) | - | PASS |
| DVT-S34-nf-svt-row-undetermined | strict | INSUFFICIENT_INFORMATION | workup.wellsScoreDvt, lab.ddimer.positive | PASS |
| DVT-S35-nf-routine-s2-undetermined | strict | INSUFFICIENT_INFORMATION | advice.postAnticoagulationScanRecommended | PASS |
| DVT-S30-svt-location-unknown | strict | INSUFFICIENT_INFORMATION | symptom.svtProximalLongSaphenousVeinThigh | PASS |
| DVT-S31-empty | strict | INSUFFICIENT_INFORMATION | symptom.superficialVenousThrombosis, symptom.svtProximalLongSaphenousVeinThigh, symptom.suspectedDvtUpperLimb, advice.sameDayImagingRecommended, symptom.suspectedDvtLowerLimb, workup.wellsScoreDvt, lab.ddimer.positive, imaging.usdvt.initialNegative, workup.dvtClinicalSuspicionHigh, symptom.calfDvt, history.anticoagulantTherapy, advice.followUpImagingRecommendedBySpecialist, advice.postAnticoagulationScanRecommended | PASS |
| DVT-S32-wells-inferred-strict | strict | INSUFFICIENT_INFORMATION | workup.wellsScoreDvt, lab.ddimer.positive | PASS |
| DVT-S33-wells-inferred-accepted | inferred | ACUTE_48H (A48) | - | PASS |
