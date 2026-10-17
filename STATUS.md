# STATUS

State only — rules in CLAUDE.md "Where state lives". Done items drop off 30
days after their date. [U] = inferred, not found.

## Done
- 2026-09-06 Slices 3, 4a, 4b merged (PRs #7–#14); benchmark run 1 recorded — documents/arch-mig-plan.md §2
- 2026-09-06 Slice 5 pipeline + thin Triage page merged (PR #15), flag off, not deployed — documents/arch-mig-plan.md §Slice 5; CRR_Release_Log.md (DRAFT 2026-09-07)
- 2026-09-06 SR-14 dev→prod admin proxy closed (PR #18) — SECURITY_DECISIONS.md SR-14
- 2026-09-06 Two-phase assess (propose/complete) merged (PR #19) — AD-25; CL-27–32
- 2026-09-07 Slice 6 Viewer on bundles merged (PR #21), flags off — instructions.complete/arch-mig-01-slice6-viewer-brief.md
- 2026-09-25 CLAUDE.md thinned; KI register and plan moved to documents/; ledger rule added (5a533ce, 153cb4b)
- 2026-09-27 Slice 6 marked Done (AD-05 provisional keep, pending D1) — documents/arch-mig-plan.md §Slice 6; AD-05; CL-46
- 2026-09-27 Phase 0/1/2 headers corrected to reflect slices 0–6 ran — instructions/arch-mig-01-brief.md, instructions/arch-mig-gap-analysis.md, documents/arch-mig-plan.md line 4
- 2026-09-27 Wrangler persist path recorded/closed: `./public/crr-criteria/.wrangler/state` (matches existing tests) — KI-54; CLAUDE.md pitfalls
- 2026-09-27 UX-03 filed, not implemented — prototype scope (AD-30) — instructions/archive/claude-code-plan-ux-enhancements.md
- 2026-09-27 KI-64 added (local dev `ASSESS_PIPELINE_ENABLED=true` vs committed `false` — intentional, now documented); README gains a two-worker dev section; both `.dev.vars.example` persist-to commands corrected to match KI-54 — README.md; documents/arch-mig-known-issues.md KI-54, KI-64; .dev.vars.example; public/crr-criteria/.dev.vars.example
- 2026-09-27 PR #23 merged (Viewer typed inputs, AD-27 option a) — merge commit 96a6562 — AD-27; CL-44–45
- 2026-09-27 AD-27 Accepted (Gary, on merge of PR #23) — AD-27
- 2026-09-29 SR-11 (terminology placeholders) raised in the register, Open — SECURITY_DECISIONS.md SR-11
- 2026-10-04 AD-31 errata[]: publish.mjs carries it, `check --bundle` and the publish route enforce the rule, KI-47 entry in the national-redflags manifest; Advisory note dropped by decision — AD-31; AD-32; CL-47; instructions.complete/arch-mig-01-errata-brief.md
- 2026-10-04 CT Colonography transcribed into sites/ (unconditional alternative management; not yet published or live) — AD-33; CL-48; sites/ct-colonography-adult/
- 2026-10-04 CT Colonography SOURCE quotes reviewed against the 27/08/26 draft by a second session: all verbatim — PR #26 review comment; documents/arch-mig-plan.md §Slice 7 step 3
- 2026-10-04 `sites/` wired into `npm run build` / `npm test` (run-tests-sites.mjs) / `npm run check` (rule 14, which accepts `draft-reference`; rule 7 unchanged, page-only) — documents/arch-mig-plan.md §Slice 7; AD-33
- 2026-10-04 AD-32 Accepted (Gary; PR #25 merged) — AD-32
- 2026-10-04 AD-33 Accepted (Gary; PR #26 merged) — AD-33
- 2026-10-05 AD-32 corrected in place: the KI-47 error is not yet raised with the document owner (Gary) — AD-32; KI-47
- 2026-10-05 CT Colonography published to the local registry as `transcribed` (v1.0.0, approved-draft source; not in remote KV, not live) — tooling/criteria-bundle/registry/ct-colonography-adult/; AD-33
- 2026-10-05 Local demo run (two-worker dev, bundles published locally, synthetic cases): engine and Viewer work end to end; KI-65 and KI-66 logged — documents/arch-mig-known-issues.md KI-65, KI-66
- 2026-10-05 AD-34 (staging environment) proposed; SR-15 (admin proxy trusts `x-admin-email` on hosts Access does not front) raised, Open — AD-34; SECURITY_DECISIONS.md SR-15
- 2026-10-06 SR-15 mitigated by configuration: Preview URLs off; Access now covers `vite-react-template.fk4dsrmq5r.workers.dev/crr-api/*` (checked by Gary) — SECURITY_DECISIONS.md SR-15; documents/CRR-admin-reference.md
- 2026-10-06 AD-34 (staging environment) Accepted (Gary) — AD-34
- 2026-10-10 Admin Tool blank page fixed and deployed; `preview_urls: false` deployed and Preview URLs observed off (PR #34, `3c4a441`) — documents/arch-mig-known-issues.md KI-67; SECURITY_DECISIONS.md SR-15; CRR_Release_Log.md 2026-10-10
- 2026-10-10 SR-15 closed: admin proxy verifies the Access token, deployed and confirmed (PR #35, `f5eea53`) — SECURITY_DECISIONS.md SD-14, SR-15; CRR_Release_Log.md 2026-10-10
- 2026-10-11 Staging deployed, behind Access and seeded; checked by Gary in the browser — AD-34; AD-35; CRR_Release_Log.md 2026-10-11
- 2026-10-11 Staging main worker renamed `crr-tools-staging` in Cloudflare (Gary); no legacy Triage on staging, legacy is compared on production (Gary) — AD-34
- 2026-10-11 SR-16 closed: SD-15 deployed to both production workers (PR #43, `7882c2a`); `ADMIN_PROXY_KEY` set on both; forged-header read 401 and Admin Tool checked by Gary — SECURITY_DECISIONS.md SR-16; CRR_Release_Log.md 2026-10-11
- 2026-10-11 Staging workers redeployed after PR #43 merged (Gary's dashboard) — SECURITY_DECISIONS.md SD-15
- 2026-10-11 Production admin login on workers.dev fixed: stale staging row removed from the production Access application (Gary) — documents/arch-mig-known-issues.md KI-70
- 2026-10-11 Remote D1 checked (Gary): no bundle-registry or assessment tables; Bundles tab errors — documents/arch-mig-known-issues.md KI-68, KI-69
- 2026-10-11 Unreachable `cf-access-authenticated-user-email` fallbacks dropped from the API worker's assess routes (performedBy); built, not deployed — SECURITY_DECISIONS.md SD-15
- 2026-10-14 Viewer source line shows an approved draft's date, not its repo path; built, not deployed — documents/arch-mig-known-issues.md KI-66; CL-54
- 2026-10-15 PR #47 merged (KI-66 fix; KI-71 design note) — merge commit 2de4283 — documents/arch-mig-known-issues.md KI-66, KI-71
- 2026-10-15 AD-35 amendment Accepted (Gary): staging seed marks demo-published exam sites live — ARCHITECTURE_DECISIONS.md AD-35; CL-55
- 2026-10-15 Account moved to Workers Paid (Gary); staging re-run: no CPU-limit failures in 10 runs — documents/arch-mig-known-issues.md KI-72
- 2026-10-16 Referrer views hide S-codes and code ranges as well as P1–P4; on staging (2026-10-16), not in production — documents/arch-mig-known-issues.md KI-76; CL-56
- 2026-10-16 Timeframe outcome convention (Acute/P/S): Advisory shows row wording, cross-exam recommendations include Acute and S outcomes; on staging (2026-10-16), not in production — AD-36; CL-57
- 2026-10-16 Seven W1 sites transcribed (CT Chest, CT Head, US Abdomen, US DVT, US Pelvis, US Renal, X-ray Chest), second-session reviewed, published to the local registry as `transcribed`; vocabulary 1.3.0; PR #48 merged (b9bebfe) — documents/arch-mig-plan.md §Slice 7; AD-37; AD-38; CL-58; CL-60
- 2026-10-16 AD-36, AD-37 and AD-38 Accepted (Gary) — ARCHITECTURE_DECISIONS.md AD-36, AD-37, AD-38
- 2026-10-16 Lab quantities reach the rules as values (were silently dropped; units dropped, so FHIRHelpers cannot throw); on staging (2026-10-16), not in production — documents/arch-mig-known-issues.md KI-77; CL-61
- 2026-10-16 "What to add" no longer repeats a heading as its only line; on staging (2026-10-16), not in production — documents/arch-mig-known-issues.md KI-75; CL-62
- 2026-10-16 CRR_RedFlags RF-10 comment / REVIEW Q23 corrected to the US Carotid p35 footnote (no logic change, national bundle not republished) — documents/arch-mig-known-issues.md KI-79
- 2026-10-16 Staging redeployed from main and re-seeded: 10 bundles published as a staging demo, 9 exam/site ids live; 22 synthetic runs, no 500/502 — AD-35; documents/arch-mig-known-issues.md KI-72
- 2026-10-16 Extraction prompt v3.0.4 (KI-73) verified on staging: note 3 returns 200 on 3/3 runs; staging API worker runs PR #51's branch until merge — documents/arch-mig-known-issues.md KI-73; CL-63

- 2026-10-17 AD-34 amendment Accepted (Gary): staging deployed by Workers Builds on merge to `main` — ARCHITECTURE_DECISIONS.md AD-34
## Queued
- @claude E6 terminology validation against NZHTS, incl. refusal of unvalidated codes at the admin publish route — after credentials are loaded — SR-11; documents/arch-mig-plan.md §Slice 1, E6; CL-19
- @claude Correct register: NZHTS access now held (OAuth2 client-credentials via NZHTS Keycloak) — documents/arch-mig-plan.md E6 (line 7)
- @claude Resize slice 7 waves W1–W5 to 38 bundles — documents/arch-mig-plan.md §Slice 7 (AD-01)
- @claude Remove or annotate the 5 stale vocabulary `sites[]` entries citing `ct-colonography-adult` p17/p18 (lab.hb.low, lab.ferritin.low, lab.unexplained, advice.urgentImagingRecommended, advice.nonUrgentImagingRecommended) — the 27/08/26 draft removes those criteria — vocabulary/indicators.json; sites/ct-colonography-adult/transcription-notes.md §1; AD-33
- @claude Measure `/api/assess` CPU per stage; cache the compiled CQL library per isolate — documents/arch-mig-known-issues.md KI-72
- @claude Extraction gives a documented false from wording that does not negate the item (over-inference case 19); benchmark it, then propose a rule or gate change — documents/arch-mig-known-issues.md KI-83
- @claude Add comparison notes 3 and 4 to the extraction benchmark (no-exam-named quote; jaundice localising features) — documents/arch-mig-known-issues.md KI-73, KI-74
- @claude Relabel KI-75/76/77/79/80 from "RESOLVED on branch" (PRs #48 and #50 merged; changes on staging) and split that bucket in the counts line — documents/arch-mig-known-issues.md Counts
- @claude Slice 8 population stage behind POPULATION_ENABLED — documents/arch-mig-plan.md §Slice 8
- @claude Slice 9 benchmark harness: labelling page + runner — documents/arch-mig-plan.md §Slice 9
- @claude Draft BRD v3.3 redline from CL rows tagged BRD (due after slice 5) — documents/DOCUMENTATION-PLAN.md
- @claude Move CL-01–45 from `built` to `documented` — documents/CHANGE-LOG.md; slice 11
- @claude Correct stale register lines: plan slice 5 "PR open" (merged PR #15), KI-37 CARRY (schema.sql current to 0011) — documents/arch-mig-plan.md; documents/arch-mig-known-issues.md KI-37
- @claude Archive superseded instructions/ files: claude-code-brief-role-aware-view-step1.md, prompt-v2.3.0-* results/runner/prompt text — instructions.complete/arch-mig-01-slice5-pipeline-brief.md; CLAUDE.md lifecycle
- @claude SD-13 (Entra ID / admin approval workflow) is cited at documents/arch-mig-plan.md line 177 with no matching row in SECURITY_DECISIONS.md — raise the row or correct the citation — documents/arch-mig-plan.md line 177; AD-30
- @claude Unify `prefillDemographicsFromMerge` with `flattenQrValues` (next brief) — documents/arch-mig-known-issues.md KI-63
- @claude Viewer self-check: let a yes/no item be answered No (three states), so CT CAP P2 is reachable — design note against AD-27 first (control shape is Gary's call) — documents/arch-mig-known-issues.md KI-65; AD-27

## Needs Gary
- @gary One-time Workers Builds setup for both staging workers (deploy on merge to `main`), then tell Claude to verify on the next merge — ARCHITECTURE_DECISIONS.md AD-34 (amendment 2026-10-16)
- @gary Redeploy the staging API worker from `main` (PR #51 merged; staging still serves prompt 3.0.3) — documents/CRR_Release_Log.md 2026-10-16; CL-63
- @gary Rule on how note 4's localising features (jaundice, palpable liver) can count: reviewed equivalence, extraction hint, or documentation-standard parameter — documents/arch-mig-known-issues.md KI-74
- @gary Decide how an inference that only combines stated facts is treated under the strict standard (test-pack case 10) — documents/arch-mig-known-issues.md KI-82
- @gary Decide whether the bundle logic hash should exclude ELM annotations (a comment-only CQL change otherwise forces a major version) — documents/arch-mig-known-issues.md KI-81
- @gary Vocabulary review of the W1 additions (smoking, lung-cancer list shape, history group, attestation candidates, stale attributions) before any W1 sign-off — documents/arch-mig-known-issues.md KI-78
- @gary Decide what the new Triage Send to Form sends and which origins may receive it (cut-over gap) — instructions/arch-mig-send-to-form-design.md; documents/arch-mig-known-issues.md KI-71; SECURITY_DECISIONS.md SR-17
- @gary Check staging admin still loads Versions and Bundles after the SR-16 redeploy — SECURITY_DECISIONS.md SD-15; documents/CRR-admin-reference.md §Staging
- @gary Decide whether CI should parse the Admin Tool's inline JSX (KI-67 shipped because nothing did) — documents/arch-mig-known-issues.md KI-67
- @gary Get a clean version or ruling on CT AP criterion B (reviewer comment: "and" vs "+/-"; whether abnormal labs are required and how persistent) and the other unaccepted tracked changes (new exclusions, secondary-care OR pathway, frailty 7-9 pathway) — documents/reference/CURRENT CT Colonography and CT AP community referred criteria final draft Updated 270826.docx; KI-52
- @gary Schedule or decide PR #23 review KIs: latent defects KI-58/59/60, B2 pass KI-61, retro-file brief? KI-62 — documents/arch-mig-known-issues.md KI-58–62
- @gary Clinical review pack (D1–D6) cited in ARCHITECTURE_DECISIONS.md but not in repo — decide: pointer to M365 location, or copy in — AD-03/04/05/06/07/10/11/17/23/26
- @gary Load NZHTS credentials into env/secrets — documents/arch-mig-plan.md E6; CL-19
- @gary Raise the KI-47 creatinine unit error (CT KUB mmol/L vs US Renal micromol/L) with the national document owner, then record date and recipient — KI-47; AD-32
- @gary Locate BRD v3.1.1 — KI-42
- @gary Set tabletop evaluation date (runs on new pipeline post-cutover) — documents/arch-mig-plan.md §Slice 10

## Pre-tabletop gate
Governance posture that must be visibly correct before the tabletop runs — even though tabletop cases are synthetic, not real referrals (a stated constraint, not a reason to skip these) — AD-30.
- @gary PTA IPP 3A indirect-collection gap — corrected, not just decided, before tabletop — KI-36
- @gary Data residency: decide the route and record an implementation plan before tabletop (full build/verification stays at the pre-pilot gate) — KI-57; KI-35

## Pre-pilot gate
Production-readiness decisions, gated at the pre-pilot review, not at slice completion — not blockers for slice work (AD-30).
- @gary Rename the production main worker (`vite-react-template`, a template-derived name) together with the host decision: move routes, Workers Builds, secrets and the Access hostnames/AUD — KI-44; AD-34
- @gary Production publish policy for criteria updates (e.g. the CT AP revision, approved draft 27/08/26) — open item, no register entry yet — AD-30
- @gary Decide whether to adopt a DCB0129-style clinical safety case (hazard log, named clinical safety officer, safety case report) before pilot — open item, no register entry yet — AD-30
- @gary Decide AD-17 (ask attestation questions at all?) — AD-17 (review pack D6)
- @gary Overlay authoring granularity — AD-29
- @gary HNZ branding / iteratio.nz host (GEN-010) — KI-44
- @gary SR-03 Origin/Referer gate — confirm — SECURITY_DECISIONS.md SR-03
- @gary Confirm assessment_notes retention period / privacy-office sign-off before AUDIT_STORE_REDACTED_NOTE is enabled (default 180 days already in code) — KI-34; SD-12
- @gary Data residency implementation and verification (decision + plan due pre-tabletop — see Pre-tabletop gate) — KI-35
- @gary Admin Tool structured editor with roles/approval workflow and Entra ID auth — documents/arch-mig-plan.md line 7; SD-13 as cited at documents/arch-mig-plan.md line 177 (register row missing — see Queued: raise SD-13 or correct citation)

## Blocked
- @blocked Admin Tool Bundles tab in production fails until migration 0008 is applied to the remote D1 (slice 10 cut-over) — documents/arch-mig-known-issues.md KI-68
- @blocked AD-05 final ruling (governed national safety addendum vs drop) — review pack D1; provisional keep in force meanwhile (slice 6 marked Done on that basis) — AD-05; KI-51
- @blocked Transcribe CT AP (W1) — the 27/08/26 draft has unresolved tracked changes and open reviewer comments on criterion B ("and" vs "+/-"); waits on a clean version or ruling (see Needs Gary) — documents/reference/CURRENT CT Colonography and CT AP community referred criteria final draft Updated 270826.docx; documents/arch-mig-plan.md §Slice 7; KI-52
- @blocked CT Colonography clinical sign-off of REVIEW Q1-Q5 (SOURCE quotes reviewed verbatim 2026-10-04) — sites/ct-colonography-adult/signoff.md; documents/arch-mig-plan.md §Slice 7 step 4; AD-33
- @blocked Clinical rulings AD-03/AD-04 (review pack D4/D5), AD-16 equivalence list, AD-23 wordings — ARCHITECTURE_DECISIONS.md
- @blocked Vocabulary v1 clinical review — documents/arch-mig-plan.md §Slice 1
- @blocked W1 clinical sign-off per site: each `sites/<bundleKey>/signoff.md` lists its REVIEW questions — waits on a clinical reviewer — documents/arch-mig-plan.md §Slice 7 step 4
- @blocked Clinician labelling of 37 matrix cases — documents/arch-mig-plan.md §Slice 9
- @blocked Creatinine unit erratum (review pack D3) — sent to James and Louise 2026-09-05, awaiting their answer; once answered, a published correction to the national document is still required before the bundle can cite it — KI stays open until then — KI-47
- @blocked Slice 10 cut-over — on 5, 6, 7-W1, 9, SD-11/12 sign-off, remote national-redflags publish, ASSESS_INTERNAL_KEY secret, remote migrations 0008–0011 (KI-68, KI-69), prompt v3.0.0 activation — documents/arch-mig-plan.md §Slice 10
- @blocked Slice 11 documents — alongside slice 10 — documents/arch-mig-plan.md §Slice 11
- @blocked Open SRs (SR-01 cost sink, SR-05 model alias drift, SR-09 extraction drift) close at slice 9/10 — SECURITY_DECISIONS.md
