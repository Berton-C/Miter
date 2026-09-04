# G33 R2 Outcome — Source-grounded continuity reading repair

Status: **PASS-BOUNDED**

Plan commit: `aba224974d74ca86a6144a524b2170db0ac2e6c9`

Passing evidence: `evidence/G33/R2/attempt-006/`

## Result

The exact-string dispatch exposed by G33 R1 has been removed. `ContinuityRNA` now records authenticated restart contact, requests a bounded local semantic reading, and passes the resulting generated relations to native `ContinuityReadingDecision`. The model product remains inert data. It cannot contain a project ID, principal, audience, permission, capsule field, exact location, next movement, or answer.

Each generated claim cites literal source spans. The Prolog membrane validates the response identity, source hash, schema, forbidden extra fields, and exact span occurrence. For the identity-bearing `project-kind` relation, the proposed kind must itself be named within a cited span. Native MeTTa then requires exactly one kind relation, at least one recognized continuity-facet relation, no unsupported relation, and exactly one project of that kind within the already authenticated principal/audience registry. Only then does the existing capsule and trajectory certificate construct the exact answer.

Two disclosed synthetic requests exercised the actual local `qwen/qwen3.8-27b` model:

1. `Can you remind me exactly where we paused in my book and what I should work on next?` produced cited `book`, `current-position`, and `next-movement` relations in 61,273 ms.
2. `Where was I with the book?` produced cited `book` and `current-position` relations in 45,742 ms with Chroma deliberately unavailable.

The readings differed, but both resolved to the identical exact project, artifact hash, chapter/paragraph anchor, last completed work, unresolved question, live tensions, next movement, capsule identity, and source-event identities. Chroma loss removed only semantic enrichment; it did not change exact continuity.

## Causal and adversarial evidence

The suite rejected or differentiated:

- wrong request identity;
- stale/wrong source hash;
- a fabricated quoted span;
- a real `book` span mislabeled as `codebase`;
- a model-supplied `project_id` field;
- malformed JSON;
- no continuity facet, an unknown facet, an unsupported relation, and duplicate kind relations;
- an insufficient reading;
- zero and multiple in-scope projects;
- unavailable local provider;
- disabled capsule resolution; and
- loss of the exact cited trajectory event.

Capsule or trajectory severance produced a stored but explicitly `non-authoritative-recall` answer with no exact state. Restoring the exact participant recovered `exact-continuity`. Provider loss returned `continuity-reading-provider-unavailable` rather than silence, retry, or fabricated recall.

## Fidelity finding

The model does not choose the project or answer. It proposes a source-bearing semantic relation. Prolog validates bytes and structure. Native MeTTa decides whether the relation set is recognizable and sufficient, applies authenticated scope, and selects a project only through unique registry cardinality. Exact state is reconstructed solely from the current capsule and independently verified trajectory events.

This is a bounded semantic seam, not a rules catalogue: no input sentence or synonym maps to an outcome, there is no score or threshold, and the R1 wording is not encoded in runtime source. The finite continuity facet vocabulary is an ontology of requested state relations. It constrains what this first implementation can claim; it does not prescribe a response or exhaust possible cognition.

## Privacy, authority, and resource result

The passing attempt made exactly two localhost model calls, capped at 512 output tokens and 120 seconds. It made zero external-network requests, Keychain/credential lookups, Mattermost operations, Chroma mutations, or external effects. All source text and continuity data in evidence are synthetic public fixtures. Raw model products were parsed as JSON data and never imported or evaluated as MeTTa or Prolog.

## Limits and next dependency

R2 does not prove general natural-language understanding, a genuinely unseen T-19 case, stale external-artifact reconciliation, mixed-user scope, complete S-502/S-803, or the whole G33 organism. The builder had already inspected both wordings, so they are transfer/regression cases, not held-out performance.

The next bounded revision must restart G33's clean-start integrated demonstration with this repaired current consumer and stop at the next actual semantic discontinuity. It may not inherit R2's PASS as proof of later voice, quiescence, development, capability, learning, restart, Mattermost, severed, or final-report phases.
