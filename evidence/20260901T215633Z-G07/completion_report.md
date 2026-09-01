# G07 completion report

Status: **PASS**

## Canonical trajectory

Three fixed event intents were selected in MeTTa and appended through the
typed store membrane:

1. `evt-g07-contact-0001` — external contact
2. `evt-g07-internal-movement-0002` — internal movement, parented to contact
3. `evt-g07-witnessed-result-0003` — witnessed consequence, parented to movement

Every envelope carries a monotonic local sequence, stable event ID, content-
addressed payload reference and SHA-256, semantic parent IDs, previous-event
hash, and its own SHA-256. Payload bodies are stored separately by hash.

## Durability and restart

The Prolog membrane holds an advisory cross-process write lock across integrity
verification, payload persistence, and ledger append. SWI-Prolog flushes the
stream and a 43-line C runtime primitive invokes POSIX `fsync(2)` on the actual
stream descriptor. There is no shell or Python durability workaround.
Ledger and payload files are set to owner-read/write mode before content is
written.

A fresh PeTTa process verified and read back the first three events, then
appended `evt-g07-fork-0004`. The fork's semantic parent is event 2 while its
mechanical hash-chain predecessor is the sequence-3 tip. The original three
ledger lines remained byte-identical. A third PeTTa process verified and read
back all four events without changing any ledger byte.

## Negative control

A separate copy changed only old line 2 from `movement-candidate` to
`movement-certified`, retaining the stored hash. Integrity verification failed
at sequence 2 with `event-hash-mismatch`, named the exact event ID, and reported
two later lines still preserved. The canonical test ledger was not mutated.

## Integrity boundary

The protected packet is byte-identical, no `~/.miter` path was created or
modified, the compiled test library remains ignored, and no Chroma service was
contacted. G08 may now build structured continuity on this canonical ground.
