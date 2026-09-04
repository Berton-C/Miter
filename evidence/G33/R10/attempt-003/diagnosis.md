# G33 R10 attempt 003 diagnosis

Attempt 003 is retained as a failed builder-verification run. All six fresh
reactor arms reached their intended boundaries and stopped cleanly. The
canonical and neutral roots persisted a waiting RNA; all four causal arms
persisted their native held result without an RNA. The canonical restart also
reached renewed readiness and stopped cleanly.

The runner then asked the append-only ledger verifier to write its restart
report over the first canonical report. The verifier correctly returned
`trajectory-report-output-exists`, and the runner stopped before assembling its
final observations, freeze, and verdict. Attempt 004 gives the restart check a
distinct write-once report path. No prior report is overwritten or reused as
the new verification result.

No native source, fixture, expected semantic outcome, grant, model setting, or
external service changes. No model call, credential lookup, external network
request, Chroma mutation, Mattermost operation, human emission, or external
effect occurred.
