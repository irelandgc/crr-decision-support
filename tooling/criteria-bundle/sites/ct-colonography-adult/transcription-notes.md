# Transcription notes — CT Colonography - Adult (`ct-colonography-adult`)

**Source:** approved draft `documents/reference/CURRENT CT Colonography and CT AP community referred criteria final draft Updated 270826.docx`, section "CT Colonography - Adult", updated 27/08/2026. Read from the document XML with tracked changes accepted (REVIEW Q3). Published exam/site id: `ct_colonography` (bundle key `ct-colonography-adult`, `live = 0` in migration 0008).

**Modelling decision (Gary, 2026-10-04; AD-33):** the section has no criteria, so the bundle returns alternative management for every request. No guidance-only outcome was added to the engine.

## 1. Atoms

The draft section has no criterion row. Every sentence is guidance; none names a clinical fact the engine evaluates.

| Source sentence (verbatim, tracked changes accepted) | Indicator | Why |
|---|---|---|
| "Following the introduction of faecal immune-chemical testing (FIT) for symptomatic patients, direct access for CT Colonography (CTC) is being removed as a first line investigation." | none | Service statement; the basis for the unconditional redirect (REVIEW Q1) |
| "Primary care referrals for all lower GI investigations including CTC and Colonoscopy will be via a single point of referral and triage as outlined in the guidance." | none | Used verbatim as the outcome wording (REVIEW Q2) |
| "Most patients will have a FIT test." | none | Describes the secondary-care pathway; not a referral condition |
| "Where appropriate, CTC will be requested and appropriate actions taken by the secondary care team. In particular, the secondary care team will be responsible for any follow-up actions based on the results (which includes, but is not limited to, any findings of cancer, polyps or incidental findings)." | none | Describes secondary-care responsibility; not a referral condition |
| "Please follow the Colorectal Symptoms HealthPathway for local guidance and follow local processes ." | none | Used verbatim as the redirect (REVIEW Q2, Q4) |

No attestation / clinical-judgement indicators (AD-17). No vocabulary additions. Five existing vocabulary entries still list `ct-colonography-adult` in their `sites[]` for the old criteria (p17/p18: `lab.hb.low`, `lab.ferritin.low`, `lab.unexplained`, `advice.urgentImagingRecommended`, `advice.nonUrgentImagingRecommended`); the draft makes them stale. The brief forbids vocabulary edits here, so this is a STATUS follow-up.

Source column: "HNZ Referral Criteria Guidelines for lower GI investigations for symptomatic patients" (healthnz.govt.nz link) → `PlanDefinition.relatedArtifact` citation. Referrers: "GP & UC Doctors / NPs" → `useContext`.

## 2. Tracked changes in this section (all accepted)

| Original | Accepted |
|---|---|
| "direct access for CT Colonography (CTC) has been removed" | "… is being removed" |
| "CT C" (twice, a deleted space) | "CTC" |
| "Please see the Colorectal Symptoms HealthPathway" | "Please follow …" |
| "… for local guidance." | "… for local guidance and follow local processes ." |

No reviewer comment is attached to this section (the document's two comments are on CT AP).

## 3. Source versus published JSON / PDF

- `documents/reference/pdf-criteria-all.json` (`ct_colonography`, from the published PDF, National ID 15372 v2.0 pp.17-19) has **11 criterion items** — `ctcol_p2_1..4` (P2) and `ctcol_p3_1..7` (P3), each "one presenting indication AND the same gate" (tolerates bowel prep, no colonoscopy/CTC within 5 years; census, `instructions/archive/compound-criteria-phase0-findings.md` rows 8-18) — plus guidance on CTC versus colonoscopy for patients over 80 or with co-morbidities.
- The draft removes all of them. That is the change the plan records for W1 ("CT Colonography (changed: guidance-only, single point of referral)"), not a transcription difference to resolve.
- The PDF itself was not re-read here: this container has no PDF renderer, so the cross-check uses the JSON extract only.
- KI-15 records the production Triage Advisor still assessing the old CTC criteria; that resolves at cut-over, not here.

## 4. Not encoded

- No age gate: the section is headed "Adult" but prints no age band (REVIEW Q5).
- No not-funded row, no priority timeframe: none is printed.
- No modifiers ("typically", "especially", etc.) appear in this section.

## 5. Matrix cases and worked examples

None. The results matrix (`documents/CRR_Test_Case_Results_Matrix_v2.xlsx`, all four sheets) has no CT Colonography case. `instructions/arch-mig-prompt-decomposition.md` mentions CTC only in its STEP 2 lab-requirements table (Hb/ferritin, old criteria); no STEP-3 worked example applies.

## 6. Build gates

`npm run build / test / check` do not cover `sites/` yet: CT Colonography is the first site under the `sites/<examSite>/` convention and the brief's guardrail allows edits only inside this folder. Verification for this transcription was run ad hoc (compile, the three scenarios through the engine path, the shared Advisory and criteria renderers); wiring `sites/` into the gates is a separate change.
