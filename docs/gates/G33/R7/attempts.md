# G33 R7 attempt history

## Attempt 001 — stopped at a harness-created voice storage fault

Continuity crossed with one localhost model call and the native voice consumer
formed the expected certificate, but the runner had not created its four result
directories. `rv_save_result` therefore reported `result-storage-failed`.
The runner also compared neutral provenance ordering byte-for-byte instead of
comparing the frozen semantic projection. The attempt stopped before reactor
execution. Its diagnosis is retained with the raw evidence.

## Attempt 002 — native run passed; independent verifier failed itself

The full native run passed the four frozen claims. The verifier then found its
own literal copy of a repaired sentence while attempting to prove that repaired
wording was absent from builder inputs. Because the freeze pinned that verifier,
the result was not retroactively rechecked. The diagnosis and passing raw run
remain retained.

## Attempt 003 — PASS-BOUNDED

The corrected verifier derives the selected clauses from the native certificate
and tests their absence from builder inputs without embedding those clauses.
The complete run and independent verification passed. No runtime or core source
changed between the plan freeze and the passing experiment.
