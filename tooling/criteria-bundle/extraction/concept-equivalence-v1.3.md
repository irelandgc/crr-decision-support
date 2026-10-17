# Concept equivalence list v1.3

**Status: NEEDS CLINICAL REVIEW.** No entry below has been confirmed by a clinician.
**Owner:** clinical. **Versioned with:** extraction prompt v3.0.5 (`prompt-v3.0.5.json` names
`equivalenceListVersion: "concept-equivalence-v1.3"`). Earlier prompts keep their lists.
**Supersedes:** `concept-equivalence-v1.2.md` for prompt v3.0.5. Entries E-01 to E-08 are carried
forward with **no change of meaning**. Read v1, v1.1 and v1.2 for their full rationale and reviewer
notes. This file records only what v1.3 changes.

---

## What v1.3 changes, and why

**Scoping, not meaning (KI-84).** Two entries name a site-specific linkId as their target:

- **E-05** (v1.1): a reported blood result ⇒ `workup.bloods`. The item is in the CT CAP and CT Chest
  Questionnaires only.
- **E-07** (v1.2): negative examination shorthand ⇒ an examination-findings item such as
  `workup.localisingFeatures`. That item is in the CT CAP Questionnaire only.

On an exam whose Questionnaires lack the item, the model still answered it. On a synthetic US
Abdomen note ("64M, abnormal LFTs on routine bloods. Feels well.") it answered `workup.bloods` in
2 of 3 staging runs, and the gate rejected the whole response (unknown linkId, contract rule 2).

v1.3 adds one rule for the whole list: **an entry applies only to an item in a Questionnaire
supplied with the request.** E-05 and E-07 are restated with that scope in the prompt (v3.0.5). An
entry whose target item is not supplied answers nothing. The note is not re-routed to a different
item.

No entry is added or removed, and no phrase form changes. The clinical reviewer questions recorded
in v1–v1.2 are unchanged.
