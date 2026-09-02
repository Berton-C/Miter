# G12 — PASS

Only the known three-record disposable Miter test collection was deleted. A
separate HTTP read returned an empty collection list. While that index was
absent, the local 12-event trajectory verified and the authoritative G08 capsule
reconstructed successfully. No canonical state was recovered from Chroma.

The collection was recreated with a new service UUID and the same logical
metadata. Native `RebuildSemanticIndexRNA` validated the complete durable record
set before indexing, derived standings, and indexed all three records. Sorted
IDs, document bodies, and every metadata field match the pre-deletion snapshot.
All five fixed queries retain their ranking, returned metadata, and distances
within the predeclared absolute tolerance of 0.000001.

The negative arm changed one copied document summary but retained its original
content hash. Native preflight returned `memory-integrity-failed` with zero HTTP
requests. The corrupted copy remains unchanged for diagnosis; the good rebuilt
collection also remains unchanged. The original memory documents, raw bodies,
trajectory, and capsules retained their hashes.

A first transport probe failed before deletion because a Prolog dict-field
expression in a clause head was evaluated before its variable was bound. Its
raw result is retained under preflight-error/. The field is now serialized only
after the collection lookup binds it; no alternate API or relaxed identity
check was substituted.

No volume, ClarityOmega collection, legacy backup, or Mattermost state was
deleted or changed. The only removed material was the disposable Miter semantic
index, and it has already been rebuilt from intact local records. Protected
documents, initial_canon, licensed assets, and ~/.miter remain unchanged.

Verifier: `sh scripts/g12/verify_g12.sh evidence/20260902T064155Z-G12`.
Next eligible gate: **G13**, Soul load and immutability baseline.
