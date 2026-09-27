# STATUS

State only — rules in CLAUDE.md "Where state lives". Done items drop off 30
days after their date. [U] = inferred, not found.

## Done
- 2026-09-05 Slices 0–2 merged (PRs #1–#6) — documents/arch-mig-plan.md §2
- 2026-09-06 Slices 3, 4a, 4b merged (PRs #7–#14); benchmark run 1 recorded — documents/arch-mig-plan.md §2
- 2026-09-06 Slice 5 pipeline + thin Triage page merged (PR #15), flag off, not deployed — documents/arch-mig-plan.md §Slice 5; CRR_Release_Log.md (DRAFT 2026-09-07)
- 2026-09-06 SR-14 dev→prod admin proxy closed (PR #18) — SECURITY_DECISIONS.md SR-14
- 2026-09-06 Two-phase assess (propose/complete) merged (PR #19) — AD-25; CL-27–32
- 2026-09-07 Slice 6 Viewer on bundles merged (PR #21), flags off — instructions.complete/arch-mig-01-slice6-viewer-brief.md
- 2026-09-25 CLAUDE.md thinned; KI register and plan moved to documents/; ledger rule added (5a533ce, 153cb4b)
- 2026-09-27 Slice 6 marked Done (AD-05 provisional keep, pending D1) — documents/arch-mig-plan.md §Slice 6; AD-05; CL-46

## Queued
- @claude Raise SR-11 (terminology placeholders) in SECURITY_DECISIONS.md — OVERDUE: due at slice 1, merged 2026-09-05 — documents/arch-mig-plan.md §5
- @claude E6 terminology validation against NZHTS (after credentials are loaded) — documents/arch-mig-plan.md §Slice 1, E6; CL-19
- @claude Correct register: NZHTS access now held (OAuth2 client-credentials via NZHTS Keycloak) — documents/arch-mig-plan.md E6 (line 7)
- @claude Resize slice 7 waves W1–W5 to 38 bundles — documents/arch-mig-plan.md §Slice 7 (AD-01)
- @claude Transcribe CT AP (W1, approved draft 27/08/26) first — documents/arch-mig-plan.md §Slice 7; KI-52
- @claude Transcribe remaining W1 sites (CTC, CT Head, US Pelvis, US Abdomen, US DVT, CT Chest, XR Chest, US Renal) — documents/arch-mig-plan.md §Slice 7
- @claude Slice 8 population stage behind POPULATION_ENABLED — documents/arch-mig-plan.md §Slice 8
- @claude Slice 9 benchmark harness: labelling page + runner — documents/arch-mig-plan.md §Slice 9
- @claude Draft BRD v3.3 redline from CL rows tagged BRD (due after slice 5) — documents/DOCUMENTATION-PLAN.md
- @claude Move CL-01–45 from `built` to `documented` — documents/CHANGE-LOG.md; slice 11
- @claude Correct stale register lines: plan slice 5 "PR open" (merged PR #15), KI-37 CARRY (schema.sql current to 0011) — documents/arch-mig-plan.md; documents/arch-mig-known-issues.md KI-37
- @claude Archive superseded instructions/ files: claude-code-brief-role-aware-view-step1.md, prompt-v2.3.0-* results/runner/prompt text — instructions.complete/arch-mig-01-slice5-pipeline-brief.md; CLAUDE.md lifecycle
- @claude SD-13 (Entra ID / admin approval workflow) is cited at documents/arch-mig-plan.md line 177 with no matching row in SECURITY_DECISIONS.md — raise the row or correct the citation — documents/arch-mig-plan.md line 177; AD-30

## Needs Gary
- @gary Review/merge PR #23 (Viewer typed inputs, AD-27 option a) — AD-27; CL-44–45
- @gary Clinical review pack (D1–D6) cited in ARCHITECTURE_DECISIONS.md but not in repo — decide: pointer to M365 location, or copy in — AD-03/04/05/06/07/10/11/17/23/26
- @gary Load NZHTS credentials into env/secrets — documents/arch-mig-plan.md E6; CL-19
- @gary Confirm whether creatinine unit erratum was sent to the document owner — KI-47 (review pack D3)
- @gary Pick a single wrangler persist path — KI-54
- @gary Locate BRD v3.1.1 — KI-42
- @gary UX plan: UX-03 has no commit (10 of 11 done) — finish or file — instructions/claude-code-plan-ux-enhancements.md [U]
- @gary Phase 0/1/2 headers still read "STOP — awaiting approval" though slices ran — instructions/arch-mig-01-brief.md, instructions/arch-mig-gap-analysis.md, documents/arch-mig-plan.md line 4
- @gary Set tabletop evaluation date (runs on new pipeline post-cutover) — documents/arch-mig-plan.md §Slice 10

## Pre-tabletop gate
Governance posture that must be visibly correct before the tabletop runs — even though tabletop cases are synthetic, not real referrals (a stated constraint, not a reason to skip these) — AD-30.
- @gary PTA IPP 3A indirect-collection gap — corrected, not just decided, before tabletop — KI-36
- @gary Data residency: decide the route and record an implementation plan before tabletop (full build/verification stays at the pre-pilot gate) — KI-57; KI-35

## Pre-pilot gate
Production-readiness decisions, gated at the pre-pilot review, not at slice completion — not blockers for slice work (AD-30).
- @gary Production publish policy for criteria updates (e.g. the CT AP revision, approved draft 27/08/26) — open item, no register entry yet — AD-30
- @gary Decide AD-17 (ask attestation questions at all?) — AD-17 (review pack D6)
- @gary Overlay authoring granularity — AD-29
- @gary HNZ branding / iteratio.nz host (GEN-010) — KI-44
- @gary SR-03 Origin/Referer gate — confirm — SECURITY_DECISIONS.md SR-03
- @gary Confirm assessment_notes retention period / privacy-office sign-off before AUDIT_STORE_REDACTED_NOTE is enabled (default 180 days already in code) — KI-34; SD-12
- @gary Data residency implementation and verification (decision + plan due pre-tabletop — see Pre-tabletop gate) — KI-35
- @gary Admin Tool structured editor with roles/approval workflow and Entra ID auth — documents/arch-mig-plan.md line 7; SD-13 as cited at documents/arch-mig-plan.md line 177 (register row missing — see Queued: raise SD-13 or correct citation)

## Blocked
- @blocked AD-05 final ruling (governed national safety addendum vs drop) — review pack D1; provisional keep in force meanwhile (slice 6 marked Done on that basis) — AD-05; KI-51
- @blocked Clinical rulings AD-03/AD-04 (review pack D4/D5), AD-16 equivalence list, AD-23 wordings — ARCHITECTURE_DECISIONS.md
- @blocked Vocabulary v1 clinical review — documents/arch-mig-plan.md §Slice 1
- @blocked W1 clinical sign-off per site (signoff.md) — documents/arch-mig-plan.md §Slice 7 step 4
- @blocked Clinician labelling of 37 matrix cases — documents/arch-mig-plan.md §Slice 9
- @blocked Creatinine unit erratum — on the national document owner (after Gary confirms it was sent) — KI-47
- @blocked Slice 10 cut-over — on 5, 6, 7-W1, 9, SD-11/12 sign-off, remote national-redflags publish, remote migration 0009, ASSESS_INTERNAL_KEY secrets, prompt v3.0.0 activation — documents/arch-mig-plan.md §Slice 10
- @blocked Slice 11 documents — alongside slice 10 — documents/arch-mig-plan.md §Slice 11
- @blocked Open SRs (SR-01 cost sink, SR-05 model alias drift, SR-09 extraction drift) close at slice 9/10 — SECURITY_DECISIONS.md
