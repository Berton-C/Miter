# Prospective interruption recheck allocation

The original SC05 allocation used two actual requests: live-002 produced text; live-003 tested a stop during a pending call. live-001 did not evaluate RRun and made no request.

live-003 observed stop in 3.282 ms, but the old Prolog cancellation path then joined the HTTP worker and held process exit until 31.135 seconds from startup. Fast observation is not prompt release of native cognition. This is an implementation defect, not a semantic model failure.

Before another call, remove the blocking join. Native state must say **cancellation requested**, not provider cancellation confirmed, and persist that disposition before returning. A server may continue inference after client exit; no claim about server-side cancellation or recovered GPU capacity is made.

Allocate exactly **one additional local qwen-local request**, live-004, solely to recheck the repaired interruption boundary: at most 1,024 output tokens, a 120-second worker deadline, and a stop after 0.75 seconds of pending worker time. Do not use its text to seek a favorable semantic verdict. No service/model/deployment changes or human-facing effects. Preserve all three original attempts and both cancellation implementations.
