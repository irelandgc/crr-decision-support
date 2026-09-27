# Claude Code Brief: Source errata handling (AD-31), and the KI-47 creatinine/eGFR erratum

**Model:** Claude Sonnet · **Branch:** from main, before CT AP transcription in slice 7 (this brief's completion is a precondition of that transcription, not a parallel task).

**Gate cleared:** AD-31 is **Accepted** (Gary, 2026-09-27). The build may proceed.

## Read first

1. `documents/ARCHITECTURE_DECISIONS.md` **AD-31** (this decision, in full — the case-(a) determination for KI-47 is load-bearing: no CQL value changes, only a documentation/provenance mechanism), **AD-08** (existing per-bundle `source` provenance, which `errata[]` sits beside), **AD-19** (`national-redflags` has no `PlanDefinition` — this is why `errata[]` is a manifest-level array, not a per-action extension), **AD-26** (the per-action extension pattern `indication-theme`/`extraction-hint` — read for contrast: this brief deliberately does not reuse it).
2. `documents/arch-mig-known-issues.md` **KI-47** — the issue, and its current `BLOCKED — awaiting D3 answer` status. Sent to James and Louise 2026-09-05; not yet answered.
3. `tooling/criteria-bundle/cql/CRR_RedFlags.cql` around line 356 (`"Renal Colic Creatinine Or eGFR Threshold"`) — the existing `SOURCE:`/`REVIEW Q7`/`REVIEW Q7b` comment block. This brief's erratum note supplements, not replaces, that comment.
4. `tooling/criteria-bundle/vocabulary/indicators.json` — `lab.creatinine.value`'s existing `notes` field (prose form of the same finding) and `sites[]` provenance.
5. `documents/SECURITY_DECISIONS.md` / `shared/advisory-render.js` (slice 5) — how the Advisory currently renders a fired red flag's wording; the erratum note attaches there.

## What this brief builds

### 1. `errata[]` — bundle manifest schema
An optional array, sibling to `source`, `logicHash`, `testResults`, valid on any bundle manifest (national or site). Each entry:

```
{
  conceptId: string,        // the CQL define name or vocabulary linkId it corrects
  sourceText: string[],     // verbatim quotes, one per document location
  correctedReading: string, // human-readable statement of the corrected value/unit
  decisionRef: string,      // e.g. "KI-47, review pack D3"
  status: "flagged" | "cleared",
  clearedBy: string | null  // a published-correction citation; null while flagged
}
```

`publish.mjs` carries it through unchanged (it is metadata, not logic — no ELM hash impact, so publishing/re-publishing an erratum entry is a **minor** bump under AD-02 if the bundle is already published, or folds into the bundle's first publish if not).

### 2. `check` rule
New rule: every `errata[]` entry has a non-empty `decisionRef`. If `status: "cleared"`, `clearedBy` must be non-null and non-empty. `status: "flagged"` requires `clearedBy: null` (an entry cannot be flagged and carry a citation at the same time — that is a contradiction, not an in-between state).

### 3. KI-47's entry, on `national-redflags`
Add to the `national-redflags` bundle manifest (currently `registry/national-redflags/1.0.0.json` — confirm whether this lands as a metadata-only re-publish of 1.0.0's working copy or is deferred to the next publish; either way it must exist before CT AP transcription starts, per AD-31's schedule):

```
{
  conceptId: "Renal Colic Creatinine Or eGFR Threshold",
  sourceText: [
    "CT KUB - Adult p25/p26 footnote: \"Creatinine greater than 160 mmol/L or eGFR less than 45 ml/min\"",
    "US Renal - Adult p55: \"Creatinine > 160 micromol/L\""
  ],
  correctedReading: "160 µmol/L (unit label only — the numeric value and the CQL comparison are unchanged; CT KUB's printed \"mmol/L\" is the defect, not the CQL)",
  decisionRef: "KI-47, review pack D3",
  status: "flagged",
  clearedBy: null
}
```

Do **not** change the CQL constant (`160.0`) or the comparison. AD-31's case-(a) finding is that the engine is already correct; this brief's job is to make that correctness visible and provisional-pending-publication, not to "fix" a value that isn't wrong.

### 4. Advisory surface
When `RF-03` fires (`"RF-03 Renal Colic With Red Flag"` is true), the Advisory's rendering of that red flag's wording gets one inline note, sourced from the `errata[]` entry, not hard-coded: something in the register of *"Note: the source document states this threshold in two different units at two locations; this assessment applies 160 µmol/L per [decisionRef], pending a published correction."* Exact wording is a rendering-copy decision for the session that builds this — keep it short, factual, and free of clinical judgement (it states a documentation fact, not a clinical opinion). No Criteria Viewer change — confirmed by Gary: the Viewer does not render the national red-flag layer, so there is nothing there to annotate.

`advisory-render.js` reads the fired flag's originating bundle's `errata[]` (filtered to entries whose `conceptId` matches a define contributing to that flag) and renders the note only when a matching entry exists and `status: "flagged"`. A `"cleared"` entry renders nothing (or, if useful for audit, a muted "corrected per [decisionRef]" — session's call, not required).

### 5. Tests
- `check` test: an `errata[]` entry missing `decisionRef` fails the build; a `"cleared"` entry with `clearedBy: null` fails; a `"flagged"` entry with a non-null `clearedBy` fails.
- `advisory-render.test.ts`: RF-03 fires with the KI-47 entry present and `flagged` → note renders with the expected text; RF-03 fires with no matching `errata[]` entry → no note (regression guard, so an unrelated red flag never picks up someone else's erratum); an entry `status: "cleared"` → no flagged note.
- A scenario exercising RF-03 already exists (`RF-S*` in `tests/scenarios.mjs`) — confirm it still passes unchanged (this brief adds a rendering side-effect, not a logic change, so no scenario's engine result should move).

## Do not
- Do not change the CQL constant, the comparison operator, or `lab.creatinine.value`'s type/unit handling. Case (a) means the engine is already right.
- Do not build a Criteria Viewer surface for this. Confirmed out of scope.
- Do not treat KI-47's `status` as resolvable by this brief — it stays `flagged` until a published correction exists; that is a future, separate action (updating `clearedBy` once it exists), not part of this build.
- Do not reuse or extend the `indication-theme`/`extraction-hint` per-action extension mechanism (AD-26) — `errata[]` is manifest-level by design (AD-19: no PlanDefinition to attach an action extension to on `national-redflags`).
- Same error twice: stop and report.

## Report
The `errata[]` schema as implemented; the `check` rule and its test; the Advisory note's rendered wording and where it was fed from; confirmation that no scenario's engine result changed. File this brief per the lifecycle. Stop.
