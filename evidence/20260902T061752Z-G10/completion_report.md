# G10 — PASS

MeTTa-native `MemoryCandidateRNA` reads candidate fields and mechanical source
verification, then makes the admission decision. Three candidates were admitted:
one book checkpoint and two successive private relationship preferences. The
transient sentence was rejected. All four decisions are append-only events;
the rejected sentence has no memory document and no Chroma record.

`MemoryStanding` derives supersession from explicit links without rewriting the
old canonical record. `IndexAdmittedMemoryRNA` indexes only separately verified
durable records. Each Chroma record carries its ID, scope, standing, content/body
hashes, source events/capsule/artifact, and complete embedding profile metadata.
The initial indexing probe lacked expanded profile metadata; it is retained in
initial-index/. Final idempotent indexing adds that metadata while preserving
all three canonical memory files byte for byte.

Five real-embedding recall probes passed in a fresh PeTTa process:

- Book paraphrase returned the checkpoint (ranked second, not first).
- Current preference paraphrase ranked the corrected preference first.
- Historical recall returned only the superseded preference.
- Exact authorized preference query ranked it first, distance -0.00000035762787
  (floating-point noise within the predeclared 0.00001 tolerance).
- Identical text and identical vector under another principal/audience returned
  no records. Exact scope filters were sent to Chroma before ranking.

Every returned body/metadata record was checked against its durable document,
source links, and hashes. The independent verifier recalculates memory/body
hashes without importing Miter's memory implementation. The trajectory has 12
valid events, including its preserved G07 prefix. G07 history and G08 capsules
remain byte-identical. No legacy service, licensed asset, or ~/.miter path was
changed, and the runtime path contains no Python or shell service adapter.

The test identity is an explicit trusted-harness identity. This does not claim
that external-surface authentication or the complete reactor is implemented.
Semantic similarity is not exact-continuity authority; G11 must resolve capsules.

Reproduce the evidence check with `sh scripts/g10/verify_g10.sh
evidence/20260902T061752Z-G10`. Raw responses, requests, vector metadata, admission
events, memory bodies, and native outputs are retained. All content is synthetic.

Rollback keeps the immutable test records and history; Chroma remains a
replaceable projection. Next eligible gate: **G11**.
