# G33 R1 Outcome — First clean-start semantic discontinuity

Status: **FAIL**

Plan commit: `5ecb9b1e94bed0b5672cf0b80360035ee5c03e73`

Evidence: `evidence/G33/R1/attempt-001/`

## Result

The first G33 R1 experiment stopped at the first required semantic discontinuity, as the frozen plan required.

From an empty G33-owned runtime root and an empty LLM context, the current store and continuity membranes successfully reconstructed a valid copied trajectory/capsule environment and recorded a new restart event and human-contact event. The current native `ContinuityRNA` consumer then received the precommitted held-out request:

> Can you remind me exactly where we paused in my book and what I should work on next?

It returned `continuity-intent-unsupported`. No authoritative continuity answer was written. The trajectory grew from 17 to 19 events, proving that the contact entered the current path before the semantic failure.

## Fidelity finding

`src/continuity.metta` currently recognizes the G11 test sentence by exact equality with `Where was I with the book?`. Its otherwise useful capsule/trajectory authority is therefore downstream of a builder-selected phrase dispatch. The historical G11 PASS proves the exact fixture, not the held-out intent or the stronger T-19 claim. Continuing to later G33 phases or producing `FINAL_POC_REPORT.md` after this result would turn the final demonstration into Soul theater.

The failure is specific and bounded. It does not show that later voice, reactor, development, NACE, restart, workshop, or Mattermost mechanisms fail. It shows that G33 cannot yet reach them through a sufficiently general continuity-contact seam.

## Constraint and privacy result

The attempt made two localhost health requests, one to LM Studio and one to the dedicated Miter Chroma service. It made no external-network request, credential lookup, model inference, external effect, Chroma mutation, or Mattermost operation. The copied runtime root is entirely under the G33 evidence directory and contains only synthetic prior fixtures. No personal content or private stable identity entered the public evidence.

## Required repair direction

The repair must not add the held-out sentence to another phrase table. It must separate:

1. a bounded semantic reading of the authenticated contact, which may use an LLM only as a non-authoritative translator;
2. native verification of the reading's source spans, scope, project-kind reference, and provenance;
3. native selection of exactly one in-scope project from the registry;
4. the existing authoritative capsule/trajectory reconstruction; and
5. typed ambiguity, insufficiency, malformed, stale, and service-unavailable outcomes.

The exact G11 sentence must remain a regression case, not the privileged definition of continuity intent. A separately frozen G33 R2 plan is required before changing `src/continuity.metta` or adding the new reading seam.
