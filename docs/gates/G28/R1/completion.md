# G28 R1 — diagnostic repair proven in bounded tests; executable trial incomplete

2026-09-03. **BLOCKED**, not a passing G28 closure. Plan commit: `d631d2e9a5a50e15546a0ff1ccb733d1f6090b13`. Both control hashes, both Soul copies, historical G28, immutable provenance and the thirteen unfinished G22 files remain unchanged.

## Actual result

Two new qwen-local calls completed normally, in **28,426 ms** and **28,736 ms**, with complete streamed products and `stop` completion. Neither timed out or reached the output limit. Provider token-usage totals were not present in these streams; do not infer actual token counts from the grant. These timings are observations, not an isolated benchmark proving which change caused the improvement.

Both generated adapters passed the same six independent byte-contract cases: ordinary text, empty input, Unicode, embedded/newline-terminated text, literal shell syntax and whitespace. Both candidate-authored smoke tests failed with exit 1. The second response returned byte-identical adapter and smoke files despite receiving a materially different revision request containing the first trial and its failure receipt.

The smoke test pipes text to an adapter whose contract takes one argument, so the adapter receives no argument. Its command substitutions also discard trailing newlines, making its proposed string comparison unsuitable for proving the exact final LF. This is builder source inspection corroborated by actual failed execution, not native discovery of those shell-language causes. No builder patch to either generated file was substituted for Miter authorship.

Native continuation actually formed `generate → inspect-trial → incorporate discrepancy → generate → inspect-trial → request-resources`. Both failed candidate commits were retained on isolated branches; main stayed unchanged. No promotion proposal, approval, merge, activation or G29 progression occurred. The R1 grant permits two calls in total, not two per fresh directory; both durable spending claims remain occupied.

## Diagnostic mechanism and evidence

The Prolog membrane captures bounded HTTP/SSE bytes as they arrive, flushes/fsyncs complete lines and retains received prefixes on failure. Timing, HTTP status, transport outcome, completion marker, finish reason, parse result and inert content reach MeTTa. Raw capture is limited to 2 MiB. The supported endpoint remains local LM Studio; no persistent model setting changed.

The local fault server exercises a complete response, timeout with a partial response, length truncation of otherwise valid JSON, malformed artifact and HTTP 503. Native admission rejects the latter four. Completion evidence changes the continuation even when the malformed-artifact classification is held constant. Unknown/prepared-without-response outcomes do not authorize another HTTP request. The harness identified and repaired timeout cleanup/read-failure handling; actual exceptions are retained, and a silent read failure is classified as deadline exhaustion only when the measured deadline has elapsed.

Native construction reuses finite relational search over declared operator preconditions/effects and protected obligations. It constructs competing plans instead of looking up a behavior by failure label. Shorter supported plans toward the same bounded goal are preferred; equal supported alternatives remain explicit. These are hypothetical affordances, never success evidence. Removing the material premise reader changes the outcome; restoring it restores behavior. Reordering relations and renaming an operator preserve meaning. An unchanged request without new material has no supported retry.

## Post-trial fidelity repairs — no additional inference

The actual experiment exposed an incomplete failure projection: its revision request carried the smoke failure receipt, but not the process exit/stdout/stderr. This is not excused by the model's failure. The repaired trial record includes those fields and their receipt lineage. A concrete observed mismatch or nonzero process exit can support revision; an unavailable observation cannot be relabelled a counterexample. Truncated smoke output cannot establish success.

The manifest now explicitly includes negative controls, pinned runtime dependencies and candidate/source lineage, in addition to purpose, input/output contracts, permissions/paths, effects, network, credentials, language, memory scope, tests, rollback and approval. MeTTa assembles this from supported records and captured runtime configuration; the model generates only the two file bodies. Full manifest identity is bound to the durable native candidate record as well as exact raw-model file bytes.

Attempts 002 and 003 are **no-inference repair replays**, not new authorship. They reuse only the first retained response under its exact original question, retrial that unchanged candidate, construct a revised question carrying the actual process observation, and verify that exhausted global spending claims prevent sending it. The second historical answer is deliberately not reused under that changed question. Attempt 003 validates the final source version. Its six fixed cases still pass, smoke still fails, and the manifest is explicit and traced.

Additional current-source controls reject altered candidate bytes, forged observations, foreign grants, direct-main writes, incorrect promotion commits and invented activation. Candidate-commit replay changes neither the ledger nor commit. Unknown, duplicate and extra observations fail exact contract comparison. A separate counterexample test caught a native evaluation-order defect; explicitly binding the case/observation collections repairs it and restores the required mismatch discrimination.

## Retained failures and scope of evidence

Diagnostic 001 has a harness syntax error; 002 records denied loopback access; 003–008 retain transport failure/cleanup investigations; 009 records a console-serialization failure on quoted partial text. Typed readback replaces reparsing that text as MeTTa. 010–014 contain passing suites at their respective source snapshots; 014 is current. Quality 001 caught the counterexample binding defect, 002 has a probe syntax error, and 003 passes. These are not fourteen model attempts: only attempt-001 made inference, exactly twice.

Raw requests, SSE bytes, typed observations, native derivations, before/after AtomSpace readbacks, test receipts, ledger payloads, candidate diffs and Git bundles are retained. Historical source snapshots are checked against their recorded hashes, not falsely against changed live files. The separate package audit must confirm the ordinary fidelity close rejects this BLOCKED result.

## Builder fidelity review

**Source meaning:** C-004/006/007/009/020–024/060–064/090–104 and S-501–504/605–607/901/1004/1102–1105 require native construction, independent consequences, differentiated uncertainty, complete manifests and truthful limits. Their full applicable clauses and whole-design connections were reread. Resource exhaustion is not completion; model fluency and schema validity are not promotion.

**Causal evidence:** The premise severing/restoration, neutral changes, same-label/different-completion contrast, concrete-versus-missing counterexamples, actual test failures and actual changed next request establish bounded participation. Real failed revision and identical output remain contrary evidence against claiming successful iterative authorship.

**Substitution audit:** Builders supplied a finite supported interface contract, operator affordances, test harness and isolated permissions—not the adapter implementation. This is a finite engineering projection, not all-nine flourishing navigation, complete M25, the five-authority organism, general semantic diagnosis, integrated perpetual cognition or the Mattermost proof. Prolog returns mechanics and identities; JavaScript is offline instrumentation. No Python core seam was added.

**Capability/constraint audit:** No independent test, control, authority, source meaning or grant was weakened to obtain a pass. The two-call ceiling was enforced globally, including during repair replay. Existing user services remained unchanged. Candidate code ran only in the inherited no-network, nonprivileged, resource-limited workshop. No remote provider, credentials or private memory participated.

**Remaining gaps:** Corrected model-authored smoke, effective model revision, a full passing candidate, concrete promotion proposal, approval, merge and later use remain unproven. Typed failure evidence is richer but does not itself provide native shell-program diagnosis. Request narrowing is demonstrated on relational fixtures; a live targeted-file repair has not been proven. Broader resource calibration/selection, duplicate-candidate consequence reuse, asynchronous reactor integration, and the rest of the Soul remain separate work.

## Next bounded hypothesis; authority needed

Do not repeat two whole-file generations or increase the deadline blindly. A leveraged next experiment would retain the independently passing adapter by hash and ask for a smoke-only repair using the now-complete process observations and unchanged argument/byte contract, then rerun every independent test. This needs a newly frozen grant; one local call capped at 2,048 output tokens and 300 seconds is a proposed ceiling, not an invocation made here. Native target construction/partial-file assembly would need its own causal and lineage checks. No model-authorship credit may come from a builder-written smoke implementation.

GLM or another remote model remains a deferred alternative, not an assumed performance improvement or authorized disclosure. A later provider comparison needs explicit data/credential authority and equivalent task/evidence conditions. No push is made under this request.
