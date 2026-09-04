# G33 R7 attempt 001 diagnosis

Attempt 001 crossed the current continuity consumer with one localhost model
call. The native voice consumer also produced the expected faithful
`expression-certificate-v1` for the canonical, neutral-order, and restored
arms, and produced `expression-incomplete` when the source frame was absent.

The runner nevertheless classified voice re-entry as failed for two
builder-harness reasons:

1. It had not created the four evidence-owned result directories before calling
   `RWaitReturned`, so `rv_save_result` truthfully returned
   `result-storage-failed` around otherwise valid native products.
2. It compared the complete neutral-order certificate byte-for-byte. Source
   record order is intentionally retained in proof detail, so the correct frozen
   neutral claim is semantic invariance, as in R6, not structural identity of
   every provenance list.

No Miter core source failed or changed. The attempt stopped before reactor
execution and performed no external network request, credential lookup, Chroma
mutation, Mattermost operation, human emission, or external effect. Attempt 002
may correct only those harness defects: create the output directories and apply
the already-frozen semantic neutral comparison. Attempt 001 remains immutable
failure evidence.
