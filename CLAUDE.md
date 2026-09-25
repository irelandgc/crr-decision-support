# CLAUDE.md

CRR (Community Radiology Referral) decision-support tools — Criteria Viewer,
Triage Advisor, Admin Tool — on Cloudflare Workers. App: `public/crr-criteria/`.
Rules bundles: `tooling/criteria-bundle/`.

## Working rules
- **Code is liability.** Build the minimum; every abstraction traces to a
  concrete, existing need. When in doubt, build less.
- State assumptions (signatures, data shapes, clinical logic) before coding;
  ask if unsure. Never guess silently.
- Surgical changes only. Flag adjacent problems — don't fix them. Ask before
  new files, modules, abstractions or dependencies, or reorganising structure.
- State what "done" looks like first; run the tests.
- Same error twice → STOP, explain what you tried, let Gary redirect.
- Style: vanilla CSS, no CSS-in-JS; standalone HTML tools keep CSS/JS in one
  file; destructure imports.

## Commands
Root: `npm run dev` · `npm run build` · `npm run lint` · `npm test` (Vitest,
main worker) · `npm run test:api-worker` · `npm run check` (tsc + build +
deploy dry-run)
Bundles (`cd tooling/criteria-bundle/tooling`): `npm run build && npm test &&
npm run check` — all three green before any bundle change is done;
`npm run publish -- <examSite>`
Deploy: main worker `npm run build && npx wrangler deploy`; API worker
`npx wrangler deploy --config public/crr-criteria/wrangler.json`
Always `npx wrangler`, never bare `wrangler`.

## Briefs and STOP gates
- DESIGN ONLY briefs produce markdown only: no code, no schema changes.
- A STOP gate is literal: end the turn and wait for review. Never continue
  because the next phase seems obvious.
- Every proposed schema feature or abstraction cites the named item in the
  codebase or criteria data it serves. Include a real non-goals section.
- Claude Fable sessions: design and complex data work only. Never modify
  production Worker routes, the deployed system prompt, or deployed assets.

## Target architecture invariants (ARCH-MIG-01)
1. The LLM never decides — no verdict, priority, eligibility or advice. Its
   output is a QuestionnaireResponse.
2. Every LLM answer carries status (documented|inferred) and a verbatim quote;
   the gate rejects the whole response on any unquotable value, unknown linkId
   or type mismatch.
3. Criteria logic lives only in the published bundle, loaded by version. None
   in application code, prompts or constants.
4. Strict documentation standard by default; inferred answers are surfaced,
   not used, unless the parameter says otherwise.
5. Retrieval from referrer systems is dormant; enabling a tier is a governance
   event (PTA / IPP 3A, terminology validation).
6. Terminology is validated against NZHTS in the build, never model-authored;
   placeholders are marked and listed.
7. Regional overlays carry delivery information only; the build rejects logic.
8. Bundle, engine, model and prompt versions are stamped on every assessment.
During the migration a recorded fix the target supersedes is not built unless
the plan names it as an interim with a retirement date.

## Where state lives
Three ledgers. Each fact has one home; the others point at it.
- **Requirements → the BRD** (`documents/…Business_Requirements_…docx` +
  `BRD-change-log-vX.md`). Changed only by versioned redline from CHANGE-LOG
  rows tagged `BRD:`.
- **Decisions and rationale → `documents/` registers**: AD (design), SD/SR
  (security), CHANGE-LOG (what changed, for whom), Release Log (when it
  reached users), KI (`arch-mig-known-issues.md`, defects and dispositions),
  the migration plan (`arch-mig-plan.md`, slice status and cut-over checklist).
- **State → `STATUS.md`**: what is done, queued or blocked — nothing else.
  One line per item, tagged `@claude` (Claude can pick it up now), `@gary`
  (needs Gary's decision or action), or `@blocked` (waits on someone else or
  a precondition; name it). Every line cites the file or AD/SD/SR/KI/CL id
  holding the rationale. No rationale, history or narrative in STATUS.md.
  Done items drop off 30 days after they are marked done.
- If STATUS.md and a register disagree, the register wins; correct STATUS.md.

**Definition of done:** a change is done when the same commit updates
STATUS.md (plus CHANGE-LOG, AD/SD and the release log where the rules below
require). A commit that changes state without touching STATUS.md is
incomplete.

## Registers — conventions
- `documents/ARCHITECTURE_DECISIONS.md` (AD) and `documents/SECURITY_DECISIONS.md`
  (SD = decision, SR = open risk/gate): append-only; supersede, never rewrite.
  Add an entry whenever a design or security-relevant call is made. A
  production change gated on a risk cites the SR id. Cite AD/SD ids in briefs
  and PR descriptions.
- Behaviour a referrer, triager, admin, operator or requirement can see →
  add `documents/CHANGE-LOG.md` rows (status `built`) before filing the brief;
  the AD entry names its `CL-nn` rows.
- **BRD sync:** any requirement-affecting change carries a `BRD:<req id|NEW>`
  token on its CL row. The BRD is redlined from those rows at the points in
  `documents/DOCUMENTATION-PLAN.md` (v3.3 after slice 5, v3.4 at slice 10),
  with a `BRD-change-log-vX.md` companion.
- Deployed behaviour changes → `documents/CRR_Release_Log.md` entry at the
  time, not retrospectively. (Change log = what changed; release log = when
  it reached users.)

## Instruction file lifecycle
`instructions/` holds pending work only. Finished → same commit as the work:
prepend the tag below, then `git mv` to `instructions.complete/`. Superseded →
`instructions/archive/` with `[SUPERSEDED — YYYY-MM-DD]`, reason, replacement.

   > **[COMPLETE — YYYY-MM-DD]** <one line: what was done>
   > Verification: "verified: <commit hash, test output, live API check>" |
   > "not independently verified: <what could not be confirmed and why>"
   > Filed by: <Claude Code | Gary>

The verification line is mandatory and must not be softened. Never tag or
move a file whose completion you are inferring rather than observing — leave
it and raise it with Gary.

## Pitfalls
- Prompt activation only through the admin API, never raw SQL (raw SQL skips
  the KV publish; evaluators once tested a stale prompt for days).
- Regression/test assessments only through the Worker endpoint, never the
  Anthropic API directly (bypasses prompt assembly, post-processing, D1 audit).
- One publish updates KV for every tool: after changing criteria or prompts,
  confirm the publish ran and check what is live.
- The production Triage Advisor model is governance-controlled. Never change
  it, even in dev/test paths, without an instruction citing sign-off.
- Newer Sonnet versions may 400 on `temperature: 0.1` — flag, don't work
  around silently.
- Local two-worker dev: the two wrangler configs persist to different dirs.
  Use `--persist-to ./public/crr-criteria/.wrangler/state` (KI-54).
- Before any admin write in local dev, confirm it targets the local worker,
  not production (SR-14).
- Anything under `public/crr-criteria/` is served unless `postbuild:clean`
  strips it (KI-38).
- Clinical data: never alter clinical meaning when restructuring criteria —
  ambiguous → stop and ask. Priority codes (P2, P3, S2…) never appear in
  referrer-facing UI or text. Not-funded items are never tickable. No
  patient-identifiable data or secrets in any fixture, log, example or commit.

## Key documents — read when relevant
| Read | When |
|---|---|
| `documents/arch-mig-plan.md` | Starting or resuming any slice (status, cut-over checklist) |
| `documents/arch-mig-known-issues.md` | Before fixing a defect — it may already be dispositioned |
| `documents/ARCHITECTURE_DECISIONS.md` | Before any design call |
| `documents/SECURITY_DECISIONS.md` | Touching auth, routes, PII, secrets, public exposure |
| `documents/CHANGE-LOG.md`, `DOCUMENTATION-PLAN.md` | Any user-, operator- or requirement-visible change |
| `documents/reference/architecture/` | Target architecture |
| `tooling/criteria-bundle/README.md`, `extraction/extraction-contract.md` | Bundle, transcription or extraction work |
| `documents/CRR-admin-reference.md` | Deploy, publish, admin API |
| `documents/CRR-integration-guide.md` | URL params, postMessage, `/api/assess` contracts |
| BRD `documents/CRR_Tool_Suite_Business_Requirements_DRAFT_v3.2.docx` + `BRD-change-log-v3.2.md` | Requirement ids and wording |
| `documents/CRR_Architecture_Briefing.md` | Only when touching legacy paths (`/api/triage/assess`, `EMBEDDED_MATCH_DATA`, system prompt v2.3.0) — describes pre-migration production |

## When compacting
Preserve: modified files, task status, pending constraints, and which STOP
gate (if any) the session is holding at.
