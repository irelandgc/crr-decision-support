# CRR Tool Suite — Release Log

Changes are listed newest-first. Each entry covers one deployment cycle.

---

## 2026-10-17 — Staging now deployed by Workers Builds on merge (AD-34 amendment, SD-16)

**Status:** Gary connected both staging workers to Workers Builds (production branch `main`, Preview builds off). The first automatic deploy ran on the PR #53 merge (`0e156b7`): `crr-criteria-api-staging` version `3cb8781e-2cdf-4616-a88f-5dcd7e019287`, `crr-tools-staging` version `277d46b2-fba2-4f5a-8158-a05139eb6fe4`. Production's `vite-react-template` build ran as usual. A staging assessment of note 3 afterwards returned 200 with prompt 3.0.4.

**Workers:** `crr-criteria-api-staging` and `crr-tools-staging`. Production is unchanged.

- **Operators and the programme:** staging follows `main` without a manual deploy (CL-64). Secrets, migrations and seeding are still done by hand.
- No change for referrers, triagers or evaluators; the code deployed is the same as the manual deploy earlier today.

---

## 2026-10-17 — Staging API worker redeployed from `main` (prompt v3.0.4 back on staging)

**Status:** Deployed by Gary from `main` after PR #51 and PR #52 merged (`479161d`), with `npx wrangler deploy --config public/crr-criteria/wrangler.json --env staging` (version `a35dd0db-d17c-492c-81c7-c469bdf58bca`). An earlier attempt the same day (version id not captured) deployed a local `main` that had not been pulled, and staging stayed on prompt 3.0.3 (note 3 returned 422 again, assessment `850179f5-…`). After the pull and redeploy, note 3 returned 200 on 2 of 2 runs with `versions.prompt = "3.0.4"`.

**Workers:** `crr-criteria-api-staging` only. Production is unchanged.

- **Referrers on staging:** CL-63 is live again: a note that does not name the selected exam gets an assessment instead of "Assessment not produced (422)".
- Staging is not yet deployed by Workers Builds; the setup in AD-34 (amendment 2026-10-16) is still to do.

---

## 2026-10-16 — Staging: seven more demo exams; extraction prompt v3.0.4 (staging only)

**Status:** Deployed by Gary. In the morning, both staging workers were deployed from `main` (API worker version `7694b210`, main worker `71f5aa1a`). Remote staging D1 and KV were then emptied and re-seeded with `tooling/staging/seed-staging.mjs --demo-published`. In the evening, the staging API worker was redeployed from the PR #51 branch (prompt v3.0.4, KI-73). At about 21:36 UTC Gary redeployed it from `main` before PR #51 had merged, so staging went back to prompt 3.0.3 (observed in a staging assessment's `versions.prompt`). It needs one more redeploy from `main` now that PR #51 is merged (merge commit `e224243`).

**Workers:** `crr-tools-staging` and `crr-criteria-api-staging` only. Production is unchanged.

- **Evaluators and the programme:** on staging, the Triage page can now assess seven more exams: CT Chest, CT Head, US Abdomen, US DVT, US Pelvis, US Renal and X-ray Chest (9 exam/site ids live in total). Their bundles are marked published **as a staging demo only** ("STAGING DEMO ONLY: not clinically signed off", AD-35); none is clinically signed off. The re-seed also carried the engine and renderer changes merged since 2026-10-11 (AD-36, AD-37, KI-75, KI-76, KI-77; CL-58 to CL-62).
- **Referrers on staging:** a note that does not name the selected exam now gets an assessment instead of "Assessment not produced (422)" (CL-63, prompt v3.0.4).
- No change for referrers or triagers on production.

---

## 2026-10-11 — Identity headers are no longer credentials (SD-15, SR-16 closed); production API worker redeployed

**Status:** Deployed by Gary after PR #43 was merged (merge commit `7882c2a`). Production main worker deployed with `npm run build && npx wrangler deploy`; production `crr-criteria-api` deployed with `npx wrangler deploy --config public/crr-criteria/wrangler.json` (version `eac63220-fd6e-48c2-9b59-92871e536493`). `ADMIN_PROXY_KEY` set on both production workers with one value; both secret lists, as Gary pasted them, show it. Gary confirmed that a request carrying only a forged `x-admin-email` gets 401, and that the Admin Tool works.

**Workers:** `vite-react-template` and `crr-criteria-api`.

- **Admin Tool (admin users):** no visible change for anyone signed in through Access. Admin requests to the API worker's public workers.dev origin with only an identity header are refused, reads included (SD-15, CL-53).
- **This was the first production API worker deploy since 2026-05-18,** so it carried every API worker change merged since then, not only SR-16. All of it was already merged to `main` through PRs. What reaches users:
  - The assessment pipeline routes (`/api/assess*`) are present but off (`ASSESS_PIPELINE_ENABLED=false`) and internal-only (SD-11). Referrers and triagers see no change; the legacy Triage Advisor is untouched.
  - SR-14's write gate on the API worker reaches production for the first time. Admin Tool writes go through the proxy marker, now that `ADMIN_PROXY_KEY` is set.
  - The snapshot-publish route no longer writes the stub `criteria:match-data` (TA-SRC-01 §6.1, `2cc1f38`); production Triage reads the embedded constant, not that key.
  - The bundle registry routes are present. The remote D1 most likely has no `bundles` table yet (migration 0008, a slice 10 step; recorded under SR-14 on 2026-09-07, not probed since), in which case they fail (KI-68).
  - The nightly 03:00 UTC purge cron (added in slice 3) now runs in production. If the remote D1 lacks the assessment tables it fails each night; if it has them, they should be empty, since the pipeline has never run in production. Either way it is expected to delete nothing. Inferred, not checked (KI-69).
- **Access (later the same day):** production admin logins on `vite-react-template.fk4dsrmq5r.workers.dev` were ending at the old staging hostname after the staging rename. Gary removed the stale `vite-react-template-staging` row from the production Access application, and the login works again (KI-70). Gary's checks also confirmed the remote D1 has no bundle-registry or assessment tables (KI-68, KI-69).
- Deploying production's API worker was planned for the slice 10 cut-over. It went out now so SR-16 (2) could close; the cut-over still applies the remote migrations and the other pre-conditions.

---

## 2026-10-11 — Staging environment available (AD-34)

**Status:** Deployed by Gary from the repo runbook (`CRR-admin-reference.md` §Deployment › Staging) and seeded with `tooling/staging/seed-staging.mjs --demo-published`. Gary checked it in the browser: criteria, bundles and the Viewer load.

**Workers:** new staging copies only: the staging main worker and `crr-criteria-api-staging`, with their own D1 and KV. Production is unchanged.

- **Evaluators and the programme:** a staging copy of the tools behind Cloudflare Access, for synthetic cases only. On staging, the Triage page runs the new assessment pipeline.
  - The legacy Triage Advisor is not reachable on staging: the page switches itself to the new pipeline whenever it is on.
  - This departs from AD-34 (3), which has both on one host. Gary decided (2026-10-11) not to add a legacy switch on staging, so the legacy path is seen on production.
- **Content** (from the seed script's output): production's published criteria as served at the time (label v4.1.2), its 6 region override sets and its active system prompt 2.3.0. The national red-flag, CT CAP and CT Colonography bundles are marked published **as a staging demo only**, with sign-off reference "STAGING DEMO ONLY: not clinically signed off (AD-10, AD-34)" (AD-35); none is clinically signed off.
- No change for referrers or triagers on production.

---

## 2026-10-10 — Admin proxy verifies the Cloudflare Access token (SD-14, SR-15 closed)

**Status:** Deployed. PR #35 was merged to `main` (merge commit `f5eea53`) and Workers Builds deployed `vite-react-template`. Gary confirmed on 2026-10-10 that the Admin Tool loads and the Versions tab (an admin route) works through the new check.

**Workers:** `vite-react-template` only. `crr-criteria-api` is unchanged.

- **Admin Tool (admin users):** no visible change for anyone signed in through Access. Admin requests are now accepted only with a verified Access token; identity headers alone are refused (SD-14, CL-50).
- **Operators:** local two-worker dev needs `ACCESS_DEV_BYPASS=true` in `.dev.vars` for local admin paths. `ACCESS_AUD` must be updated if the Access application is recreated.
- The Bundles tab still fails in production (KI-68). It predates this release: the production API worker most likely has no `/api/bundles` route yet. That is inferred, not probed (see the KI).

---

## 2026-10-10 — Admin Tool restored (KI-67); Preview URLs kept off (SR-15)

**Status:** Deployed. PR #34 was merged to `main` (merge commit `3c4a441`) and Workers Builds deployed `vite-react-template`. Gary confirmed on 2026-10-10 that `iteratio.nz/crr-criteria/admin` loads.

**Workers:** `vite-react-template` only. `crr-criteria-api` is unchanged.

- **Admin Tool (admin users):** the page had been rendering blank because one JSX attribute in `admin/index.html` failed to compile (KI-67). It now loads with every tab. No behaviour change beyond the restore.
- **Preview URLs (operators):** `"preview_urls": false` in `wrangler.json`, so a production deploy no longer re-enables Workers Builds Preview URLs. They carried production secrets without Access (SR-15). PR builds no longer get preview links: observed on the PR #35 build of `7b6d7d5`.
- No change for referrers or triagers.

---

## [DRAFT — not deployed] 2026-09-07 — ARCH-MIG-01 slice 5: assessment pipeline + thin Triage page (flag off)

**Status:** DRAFT. Merged to `main` behind `ASSESS_PIPELINE_ENABLED` (off in both
workers' production config). Nothing user-facing changes until the slice 10
cut-over flips the flag; this entry is written at the time of the change per the
lifecycle, not retrospectively.

**Workers:** `crr-criteria-api` (`POST /api/assess`, `GET /api/assess/status`,
`POST /api/assess/compare-extract`), `vite-react-template` (`/api/assess/*`
forward already in place from slice 3).

- `POST /api/assess` — one call runs PII gate → extract → merge → evaluate →
  Advisory and writes **one** `assessments` row (bundle/engine/prompt/equivalence/
  model/provider versions, documentation standard, merged QuestionnaireResponse,
  Advisory, discrepancies, `validation_failures`, redaction pattern types,
  attestations, exam/site selection). A gate rejection or a fail-closed national
  bundle is a typed error **and** still writes a row with `validation_failures`
  and no Advisory.
- `merge.ts` — one QuestionnaireResponse from up to four sources
  (`retrieved › attested › context › documented › inferred`); every override
  recorded in `discrepancies[]`. Population source is interface-only
  (`POPULATION_ENABLED` off — slice 8).
- Referrer attestation questions (AD-17 / AD-23) — `GET /api/assess/attestation-questions`
  serves the category indicators on the selected Questionnaire in two role
  wordings; the merged answer carries `status: documented` + an
  `{ source, attestedBy }` sub-extension; no new evidence status, engine
  unchanged.
- `shared/advisory-render.js` — one engine Advisory, referrer and triager views,
  presentation-only (SD-01 rebased). Referrer view: no priority codes (GEN-004),
  "what to add" = published Questionnaire item text, cross-exam recommendations,
  page references, the attestation questions. Triager view adds priority codes,
  rule trace, per-indicator evidence + quote, discrepancies, version stamps.
- `triage/index.html` — a `<script type="module">` that, when
  `GET /api/assess/status` returns 200, runs the page as a **thin client**
  (collects note + context + attestation answers, calls `/api/assess`, renders
  the Advisory). It does not assemble a prompt, load `EMBEDDED_MATCH_DATA`, run
  synonym auto-detect, run post-processing, or call the model. **Flag off ⇒ the
  page is byte-identical to today** — the legacy code paths are retained for
  slice 10, so the flag can be flipped both ways during tabletop. Usage/QA
  submissions carry `assessmentId`.
- `POST /api/assess/compare-extract` — compare-extraction mode (TA-022–024):
  two providers/models, same contract, per-indicator diff + engine determination
  each; the Azure provider is a visible `NotConfigured` error.
- Migration `0010_assess_pipeline_audit.sql` — five nullable columns on
  `assessments`. Applied to the remote D1 at the slice 10 cut-over, with 0009.
- End-to-end proof: `benchmark/results/2026-09-07-pipeline-e2e-claude-sonnet-4-6.md`
  (two-worker `wrangler dev`, real model). 3/4 CT CAP ground-truth determinations
  match; MW-009 diverges on `workup.localisingFeatures` extraction (FINDINGS #6,
  open). One complete `assessments` row per call.

---

## 2026-06-20 — Triage Advisor v1.1.0: default model updated to claude-sonnet-4-6

**Deployed:** `vite-react-template` worker

- Default model changed from `claude-sonnet-4-20250514` (retired by Anthropic) to `claude-sonnet-4-6`
- `claude-sonnet-4-20250514` removed from the model toggle; Sonnet 4.6 is now the only non-compare model
- Model comparison mode updated to Sonnet 4.6 vs Opus 4.8 (was Sonnet 4 vs Opus 4.6; `claude-opus-4-20250514` → `claude-opus-4-8`)
- Tool version bumped to v1.1.0 DEV; BUILD date updated to 2026-06-20
- No changes to criteria content, prompts, or clinical logic

---

## [backfilled 2026-06-21] System Prompt v2.3.0 — active in production (date promoted: UNKNOWN)

**Note:** Live API confirms v2.3.0 is the active system prompt as of 2026-06-21. The 2026-05-24 release log entry incorrectly stated v2.2.0 was the promoted version and v2.3.0 was "not promoted". v2.3.0 was created on 2026-05-24 (same day) and has been active since — exact promotion date unconfirmed; Gary to verify.

Key changes in v2.3.0 vs v2.2.0 (from prompt label and regression tests):
- Verdict consistency check (Step 3b) — explicit self-check rules before JSON output
- General-vs-specific pathway rule — general pathway can be fully met even when specific variant has unmet requirements
- Clinical severity override fix — redirect/safety concerns after Step 0 do not downgrade a met verdict

Regression test results (v2.3.0, 20 cases): 3 improved / 15 unchanged / 2 regressed (LP-004, CR-003) vs v2.2.0.

---

## [backfilled 2026-06-21] Viewer Fixes 9, 10, 11, 13 — confirmed present, original ship date unknown

Verified present in `public/crr-criteria/viewer/index.html` source on 2026-06-21. These fixes shipped without release log entries (likely during the 2026-05-28 display overhaul or 2026-05-18 passive mode fix cycle).

- **Fix 9:** Per-item expand/collapse arrows removed. `UX11_EXPANDABLE_SECTIONS = false` (viewer line 333); neither `toolRenderCb` nor `toolRenderIndicCb` renders arrow HTML.
- **Fix 10:** Not-funded items excluded from tickable checkbox list. `isNonClinicalGroup()` (viewer line 621) identifies groups with "not fund" / "not routinely" / "alternative management" and excludes them from `nonEmergencyGroups`; shown only in `renderFooterBlocks()` as a non-interactive `not-funded-box`.
- **Fix 11:** Urgency-view group header de-duplication. `getPriorityShortFromGroup()` (viewer line 1548) replaces raw group titles (which contained P-codes) with clean short labels ("Urgent (within two weeks)" etc.); used in both `toolRenderGroup` and `toolRenderGroupPassive`.
- **Fix 13:** Before-Referring items not pre-ticked in urgency view. No pre-ticking logic exists; live criteria contain no "Before Referring" groups; all checkboxes default to unticked via empty `TS.cbs = {}`.

---

## 2026-06-14 — Admin tool: model column in usage log and QA tables

**Deployed:** `vite-react-template` worker

- Model column added between Mode and Prompt in the Usage Log table
- Model, Mode, and Prompt columns added to the Triage QA table (after Exam, before IP)
- Model names displayed in short form (`sonnet-4`, `sonnet-4-6`, `opus-4`)
- Redundant model/mode line in QA expanded row removed (now in table columns)

---

## 2026-06-12 — Usage log: full AI response capture + JSON export

**Deployed:** `vite-react-template` worker (triage tool + admin tool)

- `ai_response_json` now stores a clean structured object with all AI response fields: verdict, verdict_title, verdict_summary, priority, criteria_page, interpreted_note, met_criteria, missing_criteria, add_to_note, suggested_wording, notes, redirect, safety_alert, overrides
- Previously stored full `result` object including internal `_` fields; now stores only the audit-relevant fields
- `interpreted_note` (AI spelling-corrected version of the note) added to stored JSON
- Admin Usage Log expanded row now displays full pretty-printed JSON instead of truncated summary
- **Export JSON** button added to Usage Log tab (primary export) — each record includes all AI response fields and clinical note, matching QA reviews export structure
- CSV export updated to include the same 12 new columns (arrays JSON-stringified in cells)

---

## 2026-06-02 — Triage Advisor: reliability improvements + Sonnet 4.6 model option

**Deployed:** `vite-react-template` worker

### QA feedback form fix
- QA submit button was not re-enabling for second/subsequent reviews in the same session
- Root cause 1: reviewer name field not included in enabled-state check — button could enable with empty name, causing silent failure on submit
- Root cause 2: role button visual state not explicitly cleared on modal open — ghost selection could block enable logic when localStorage was unavailable
- Fix: name added to `checkQaSubmitEnabled()`, explicit `.qa-role-btn` clear added before localStorage pre-population in `openQaModal()`

### Post-processing override accuracy (MET_PHRASES)
- Added 7 new phrases without trailing 's': `meet criteria`, `meet p1`, `meet p2`, `meet p3`, `meet p4`, `meet acute`, `meet urgent`
- Added `criteria met independently` and `criteria met`
- MET_PHRASES array now 18 entries — covers all observed AI documentation patterns for confirmed-met pathways

### Sonnet 4.6 model toggle
- `claude-sonnet-4-6` added as selectable model in the Triage Advisor
- Model toggle row added below the Check Referral button: Sonnet 4 (default, active) | Sonnet 4.6
- Default remains Sonnet 4 pending full regression suite validation
- Regression testing (v2.2.0 prompt): Sonnet 4.6 scores 3 improved / 10 unchanged / 7 regressed vs baseline — not suitable as default on v2.2.0 prompt
- v2.3.0 prompt + Sonnet 4.6: 3 improved / 15 unchanged / 2 regressed — better pairing if v2.3.0 is promoted

---

## 2026-05-28 — Criteria Viewer search improvements + Triage display overhaul

**Deployed:** `vite-react-template` worker (both tools)

### Criteria Viewer
- Global search now recognises 25+ clinical abbreviations (PMB, DVT, TIA, CXR, AUB, OA, etc.)
- Gateway tooltip added — hover info icon explains gateway criteria
- Footnote cross-references — asterisked items have clickable superscript scrolling to footnote
- Inline definitions — asterisked items can expand definition inline without scrolling
- Expandable sections — Definitions, Alternative management, Not routinely funded start collapsed

### Triage Advisor display
- Staged loading messages — Loading criteria → Assessing referral → Preparing result with elapsed-seconds counter
- Output reordered — verdict block and missing criteria shown first
- Merged 'What's missing' section — missing criteria paired with documentation hints in single list
- Criteria panel filtering — matching exam groups expand automatically after assessment
- Character count on clinical note input
- Session info footer — model, documentation mode, and prompt version shown per assessment

---

## 2026-05-24 — Triage Advisor System Prompt v2.2.0 (Production)

**Deployed:** D1 system_prompts table (no worker redeployment required)

### System Prompt v2.2.0 — now active production prompt

Replaces v1.1.0 as the active triage assessment prompt. Key changes from v2.1.0:

- **Concrete gateway/pathway examples in Step 3** — three worked examples added for focal neurological signs + ?TIA, hepatomegaly + HCC surveillance, and post-menopausal bleeding (general) + MHT-specific variant. Addresses RP-002, RP-003, TEST-003 regressions where gateway requirements from non-deciding pathways were blocking correct verdicts.
- **Postmenopausal clinical shorthand** — "post menopausal" / "postmenopausal" now explicitly accepted as satisfying ">12 months amenorrhoea around expected age of menopause" without requiring the phrase to be spelled out.
- **Clinical shorthand equivalence rule** — standard clinical shorthand inherently implying a criterion element is accepted (e.g., "?IUD malpositioned with symptoms" accepted against IUD perforation criterion). Fixes LP-004 IUCD malposition case.

### Regression test results (v2.2.0, 20 cases)

| Status | Count | Cases |
|--------|-------|-------|
| Improved vs v1.x | 4 | RP-002, RP-003, TEST-001, TEST-003 |
| Unchanged (correct) | 13 | All other passing cases including paediatric RP-005, CR-002, CR-003, LP-004 |
| Remaining regressions | 3 | LP-003 (PMB/HRT — at_risk), RP-006 (AKI redirect override), TEST-004 (hepatomegaly verdict contradiction) |

All 4 original regression cases from v2.0.0 testing (RP-005, CR-002, CR-003, LP-004) are correct in v2.2.0.

### Prompt version history in D1

| Version | Status | Summary |
|---------|--------|---------|
| 1.0.0 | inactive | Original prompt |
| 1.1.0 | inactive | Prior production prompt |
| 2.0.0 | inactive | Step-based assessment structure (introduced regressions) |
| 2.1.0 | inactive | Gender-exclusive criteria fix + one-pathway-met rule |
| **2.2.0** | **active** | Concrete gateway examples + postmenopausal shorthand |
| 2.3.0 | inactive | Experimental — 3 new regressions, not promoted |

---

## 2026-05-18 — Viewer Telemetry + Passive/Integration Mode Fixes

**Deployed:** Both workers (`vite-react-template` + `crr-criteria-api`)

### Viewer Usage Telemetry (new feature)
- **D1 schema** — new `viewer_events` table with indexes on session, type, exam, date
- **API** — `POST /api/viewer-event` (public, rate-limited 500/hr/IP) logs exam selections, copy actions, HP link clicks, guidance expansions
- **API** — `GET /api/admin/viewer-events` (CF Access protected) serves the admin tab with from/to/event_type/exam filters, limit 500
- **Viewer** — session ID (`vsess_` prefix) persisted in sessionStorage; `logViewerEvent()` beacon function using `sendBeacon`/`fetch`; identity (name/role) inherited from QA review submission
- **Viewer** — four instrumentation points: exam radio switch, site checkbox tick, copy button, send-to-form button, and all five HealthPathways link clicks
- **Admin** — new "Viewer Usage" tab (between Viewer QA and Usage Log) with filter bar, five summary cards (total events, unique sessions, top exam, copy rate, HP clicks), colour-coded event table, expandable rows, CSV export

### Viewer Passive Mode & Integration Mode Fixes
- Both interactive and passive modes now use the same two-column layout (left: exam selector; right: criteria panel) in all four contexts: standalone interactive, standalone passive, integration interactive, integration passive
- "By indication / By urgency" toggle now works in passive mode
- Passive mode renders items without checkboxes/summary bar/copy button; gateway and emergency banners render identically to interactive mode
- Interactive/Passive toggle added to footer bar in standalone mode; persists via `localStorage`
- URL param `?mode=passive` overrides localStorage

### Integration Mode — Show Selectors
- Integration interactive mode now shows modality radio buttons and exam site checkboxes (previously hidden)
- Sites pre-selected by URL params show a "from referral" badge; badge is purely informational
- Integration passive mode uses the same two-column layout as standalone passive

### Compound Criteria Mockup
- New standalone prototype at `public/crr-criteria/compound-mockup.html` demonstrating AND/OR compound criteria logic with Interactive, Passive, and Triage reference render modes

---

## 2026-05-16 — Admin Tool Major Release

**Deployed:** Both workers

- Admin tool restructured with Releases tab for creating and publishing release notes/announcements
- Release bell added to Criteria Viewer, Triage Advisor, and Admin Tool header — shows unread indicator and modal listing recent releases
- Releases stored in D1 `releases` table with draft/published workflow
- Public API: `GET /api/releases`, `GET /api/releases/latest-id`
- Admin API: `GET/POST/PUT/DELETE /api/admin/releases`
- Shared `release-bell.js` loaded from `/crr-criteria/shared/release-bell.js`

---

## Earlier history

Prior to 2026-05-16 the project did not maintain a structured release log. Key milestones from git history:

- **Triage Clinical Review Brief** — Triage Advisor prompt and clinical logic updates
- **API and Cloudflare infrastructure fixes** — `run_worker_first` route pattern, ASSETS binding, same-origin proxy wiring
- **Admin Tool v1.5.x series** — admin key persistence, Safari compat fixes, region management, version control, PDF import (since deprecated), QA review tabs, usage log tab, audit log
- **Criteria Viewer** — two-column layout, HealthPathways regional localisation, QA feedback modal, search, passive/interactive modes, integration URL params, postMessage output
- **Triage Advisor** — PII pipeline, AI assessment via Anthropic API, usage logging, QA reviews, paediatric mode, model comparison
