# Send to Form on the new Triage path — design note

**Status:** DESIGN ONLY, for Gary's decision. No code until a STOP-gate answer.
**Date:** 2026-10-15 · **Raised by:** KI-71 · **Author:** Claude Code

## 1. The gap

| | Legacy Triage Advisor (production today) | New pipeline (staging) |
|---|---|---|
| Send to Form | `?sendButton=on` in a popup shows **Send to Form**. It posts `{type:'crr-output', text, source:'triage'}` to the opener, then closes (`triage/index.html` ~2468, ~2586; `CRR-integration-guide.md` §Triage Advisor) | None |
| Copy | A copy button for the same text (~2514) | None |
| Text sent | The model's `suggested_wording`, a rewritten referral note. The prompt asks for it only on "at risk" or "declined" results (~1711); the code shows the button whenever it is present (~2468) | — |
| Target origin | `'*'` (any opener receives it) | — |

At cut-over (slice 10), any referral platform that opens the Triage Advisor with `sendButton=on` loses the button.

The BRD has no requirement for this on the Triage Advisor. CV-017 (text output), CV-018 (copy) and CV-019 (send to referral form, Should have) cover the Viewer only. The CL row for the build will therefore carry `BRD:NEW`.

## 2. Constraints

- **Invariant 1:** the model never gives advice, so `suggested_wording` cannot carry over. Model-authored referral text is exactly what the migration removes.
- **Invariant 3:** every word sent comes from the published bundle, or from the renderer's fixed chrome strings.
- **Priority codes** (P2, S2…) never appear in referrer-facing text. Not-funded items are never offered as met.
- **The note itself is not sent back.** The form already holds it, and returning it would only widen what crosses windows.

## 3. What already exists to build on

- `shared/advisory-render.js` `resolveAdvisory(response, 'referrer', …)` already produces the referrer view. That view contains:
  - the determination in plain words, with the `P<n>` token stripped (~205);
  - a redirect where one applies (~351);
  - "What to add": one line per missing indicator, worded from the published Questionnaire (~230, rendered ~360);
  - the referrer's attestation answers (~382).
  It has no list of the criteria found documented. Option A's "found" lines would be new rendering, taken from the merged QuestionnaireResponse's documented answers and labelled with bundle wording.
- The Viewer's `buildSendSummaryText()` (`viewer/index.html` ~2610) defines the established text shape: exam, then the ticked criteria as a short list.

## 4. Options

| | What is sent | For | Against |
|---|---|---|---|
| **A (recommended)** | Exam/site, the referrer-view determination line, the criteria found documented (bundle labels), and "To add:" lines for missing information | Builds on the existing referrer view; reads like the Viewer's output; the referrer sees what to strengthen | Text is longer than the Viewer's; the "found" lines are new rendering (§3) |
| B | Only the "To add:" lines | Short; purely helps the referrer improve the note | Says nothing about what was found |
| C | No send from Triage. An "Open in Viewer" link prefills the ticks from the extraction, and the Viewer's own Send to Form does the rest | One send path to maintain | Two windows; depends on the Viewer bundle path's Send to Form working, which is not checked (KI-71) |

Under A, inferred answers are left out under the strict standard (invariant 4). Quotes are left out too: they are the referrer's own words, already in the form.

## 5. Security: origin rule (applies to the Viewer too)

Replace `postMessage(…, '*')` with a send only to an allowed origin (SR-17). The proposal:
- keep a **separate** list for postMessage. The API worker's CORS `ALLOWED_ORIGINS` (`api/worker.ts` ~46) is not suitable, even though its comment reserves it for partner origins. It also gates the unauthenticated `/api/triage/assess` (403 to any other Origin, ~803; a known cost sink, SR-01). Adding a referral platform there would let that platform's pages call the route cross-origin. Being allowed to receive output text is a different permission from being allowed to call the API;
- hold the postMessage list as a constant in one shared page module (e.g. `shared/integration-origins.js`), used by the Viewer and the Triage page and changed only by a reviewed PR. That needs no new route or variable;
- take the opener or parent origin from `document.referrer`;
- send only when that origin is on the list;
- otherwise show "Copy" only.

Which partner origins go on the list, and changing the Viewer in the same build, are both Gary's call. The Viewer change would need its own CL row, because a platform not on the list stops receiving text.

## 6. Message contract

Keep `{type:'crr-output', text, source:'triage'}` and the close-after-send behaviour (`window.close()`, `triage/index.html` ~2594) unchanged, so existing integrations keep working. (`crr-close` is the Viewer's modal message; the Triage page has no modal mode.) The only change is that `text` is no longer model-authored.

## 7. Non-goals

- No model-written or reworded referral text.
- No change to the legacy path. It stays frozen until cut-over (D1).
- No structured (FHIR QuestionnaireResponse) write-back to practice systems. That belongs to the dormant retrieval tiers (invariant 5).
- No callback-URL mode (CV-019 names it as an example only).

## 8. Decisions needed (STOP gate)

1. Option A, B or C?
2. Under A, the exact referrer-facing wording of the determination line and the "To add:" heading. It must contain no priority codes; those are referrer-facing words, so the call is yours.
3. Origin allowlist: which referral platforms, and should the Viewer change in the same PR?
4. Is KI-71 a slice 10 cut-over precondition? I recommend yes, because removing a working integration feature is user-visible.
5. Approve the new shared page module for the origin list (§5, e.g. `shared/integration-origins.js`)? CLAUDE.md asks before new modules.
6. The legacy Triage page keeps `'*'` until cut-over (SR-17). Accept that, or patch it now as an interim with a retirement date? Either way, I add "remove the legacy send code" to the cut-over checklist.

On your answer I'll record an AD (status Proposed until you accept it), add CL rows (`BRD:NEW` for the Triage requirement), build the change with tests, and add the cut-over checklist line if you answer yes to 4.
