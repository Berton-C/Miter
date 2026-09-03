# G27 — bounded executable workshop containment

Status: **PASS-BOUNDED**. Plan frozen in eaa914245a802fa46d6d426a2a20379f4f6acb06. Final evidence: evidence/G27/attempt-004. The Constitution, Soul spec, initial canon, existing source corpus and prior gate runtime remain unchanged.

Thirty-three typed operations pass through the native mechanical wrapper and Prolog broker. A pinned isolated seed produces candidate worktrees; scoped write/read/list, declared tests, diffs, artifact lookup and recoverable discard work. Request-ID conflicts, idempotency conflicts, exact replay and prepared-without-receipt recovery are distinct. Exact replay adds neither effect nor journal event. Thirty-three operation events have independently verified byte hashes, sequence and parent chain.

Path traversal, absolute paths, main/control/test/metadata writes, symlink escape, arbitrary commands, forged networking, undeclared tests and missing/foreign identity are denied. The container sees only writable extension/candidate-test subtrees and read-only fixed tests. It does not receive Git authority, host home, the broker grant, actual secrets or the Docker socket. Fixed Git metadata paths and disabled hooks prevent candidate-controlled routing of host commands.

Real Docker execution uses the pinned existing image with an explicit shell entrypoint and declared amd64 platform (external test emulation only; native PeTTa remains arm64). Read-only root, no network, unprivileged UID/GID, dropped capabilities, no-new-privileges, bounded CPU/memory/PIDs and temporary mounts are verified from actual container configuration. The image's default data volume is overridden with bounded tmpfs. Timeout and output-cap tests return typed incompleteness. No anonymous volume remains in the final profile.

A separately constructed invalid profile exposes only a synthetic canary via one extra read-only bind mount. The actual canary becomes readable and the independent profile check detects the extra reach. This path is not exposed by the production broker. Restoring the normal profile makes it inaccessible again. Neutral candidate identity preserves useful execution. All test containers are removed; candidate worktrees are retained in recoverable runtime archives, not deleted. Before/after service IDs and names agree.

## Retained failures and review findings

Attempts 001–003 retain source snapshots and raw request/result history. They exposed premature dictionary-field evaluation during operation routing and missing-ID exceptions; both now become proper typed/logged outcomes. The first network probe incorrectly assumed only a loopback interface would be listed. Docker's no-network namespace also exposed inactive tunnel interfaces; the corrected probe requires no route and blocked connectivity, with NetworkMode=none independently verified. This preserves the original no-network requirement rather than changing it to fit a reachable network.

The image initially allocated two empty anonymous volumes. Their identities were traced to these test containers, absence of remaining references was verified, and only those two were removed. evidence/G27/cleanup.json records that cleanup. The final bounded override prevents recurrence. No database was started and no service volume was removed. The unused empty docker-before placeholder in attempt-001 is not service evidence; actual services-before/after records and later version captures are authoritative for the reported checks.

## Fidelity review and remaining work

C-093–096/S-1004 require these mechanical hands without moving cognition into the broker. The wrapper does not claim to form purposes, make Soul verdicts or generate an extension. Security path/operation limits are capability boundaries, not a behavioral choice table. JavaScript is offline fixture/verification instrumentation; Prolog handles mechanics only. No model call or Python core seam was added.

The severed experiment proves the tested mount boundary matters. It is not a proof against Docker/kernel vulnerabilities or every possible program. The fixed tests are builder-owned; no sample implementation is attributed to Miter. G28 must establish actual native-origin generation, source-grounded undertaking, trial interpretation, commit lineage and a concrete promotion proposal. Its frozen plan keeps promotion and later live reach behind their required approvals. The complete production Soul and Mattermost proofs remain unfinished.
