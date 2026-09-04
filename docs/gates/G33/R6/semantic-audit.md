# G33 R6 semantic fidelity audit

The integration has one semantic handler. `RWait` passes every non-pending
transport result to `RWaitReturned`; rendered states are passed to
`RRenderedContinuation`. The acceptance runner invokes `RWaitReturned` itself,
and a separate arm imports the actual public bootstrap. There is no test-only
decision path.

The handler checks renderer request identity, performs the current `RAudit`, and
forms one `RDisposition`. A faithful result returns directly. A repair request
can continue only when the originating source frame was retained. The public
handler passes its actual intention, clauses, audit, and disposition into
`RRContinueObserved`; that function recomputes all four under the current frame
and rejects disagreement before construction.

The repair runtime reference names one already-accepted capability, bounded
fuel, accepted-development standing, and explicit false human-emission
authority. Prolog verifies its structure and the existing G22 candidate/receipt/
closure lineage. It returns the same typed shape for accepted and unavailable
standing. It neither interprets the renderer product nor selects a repair.

PeTTa exposed a material module-order fact during attempts 003–005. Relational
intention/audit definitions must exist before construction and repair; the
public consumer must exist after repair. Re-importing rules is not viable and
caused stack exhaustion. The final acyclic order therefore keeps intention and
audit in `relational_voice.metta`, then loads construction, then defines repair
and its dependent public consumer in `relational_voice_repair_v1.metta`. This is
a source-file placement correction, not a transfer of cognition or a duplicate
implementation. The public bootstrap is the unified runtime boundary.

Causal cuts confirm that removing the one handler call produces typed
incompletion; removing the runtime capability, frame, or joint relation blocks
the certificate; changing request identity or scope produces revalidation; and
supplying a forged observed audit fails recomputation. A faithful rendered
product remains expression-ready and does not enter construction. Reordering
source records preserves the repaired semantic content.

The exact repaired wording is inherited at runtime from R5's independently
constructed product and does not appear in R6 code or fixtures. No model call,
retry policy, first-match policy, response table, scalar winner, or effect
authority was introduced. This remains a finite integration proof rather than
general semantics or complete G33.
