# G30 R1 — recover the mock evidence serializer

Attempt 001 reached no candidate behavior. The builder mock used an unsupported JSON representation for an absent event, and native assessment correctly remained unresolved.

R1 permits exactly two implementation changes before a fresh attempt:

1. Replace `@(null)` with the JSON-supported `null` atom in the mock's absent-event evidence.
2. Point preparation at this frozen R1 plan and its commit.

The candidate hash, scenarios, native obligations, restart child process, severed transformations, and acceptance criteria cannot change. Any further failure is preserved as a new consequence rather than repaired inside the same attempt.
