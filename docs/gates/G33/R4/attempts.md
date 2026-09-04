# G33 R4 attempt history

The final bounded PASS preserves the mechanical failures that established the actual runtime boundary.

- **Attempt 001 — public-entry failure, zero model calls.** The first v2 membrane returned `intention-storage-or-integrity-failed`. A later manual diagnostic wrote an intention into this same attempt root, so the directory is retained as contaminated diagnostic provenance and is not acceptance evidence.
- **Attempt 002 — root conversion defect, zero model calls.** The authority check passed the same variable as both the incoming MeTTa string and canonical Prolog atom. Their representations could not unify, so a valid root was rejected.
- **Attempt 003 — differentiated root failure, zero model calls.** Typed standing exposed the preceding defect as `runtime-root-invalid`; this confirmed that transport had not begun but did not yet repair the conversion.
- **Attempt 004 — lost canonical binding, zero model calls.** Negated validation discarded the converted root binding before grant and manifest checks. Replacing it with nested positive checks retained the canonical root and preserved differentiated failures.
- **Attempt 005 — successful public entry; stale verifier expectation.** The actual `RRun` path made one localhost call, returned an `expression-ready` native audit, rejected every original adversarial authority case before transport, and rejected a second call. The runner nevertheless failed because it still expected the old undifferentiated failure token instead of the new typed `runtime-root-invalid`, `runtime-grant-invalid`, and `runtime-integrity-manifest-invalid` products.
- **Attempt 006 — original suite passed.** One localhost call, eleven pre-transport rejection arms, and replay prevention all passed. Closure review then found that the plan's malformed-document claim had not been exercised directly.
- **Attempt 007 — final bounded PASS.** JSON reading was made fail-closed and three additional cuts exercised malformed grant JSON, a missing required grant root, and malformed manifest JSON. The public entry made one localhost call, all fourteen invalid or tampered authority cases failed before a worker started, and the second call was rejected.

Attempts 001–007 remain in `evidence/G33/R4/`. No failed root was reused as final evidence, and no attempt emitted to a human or obtained external-effect authority.
