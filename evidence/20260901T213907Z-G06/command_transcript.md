# G06 command transcript

1. Confirmed `main` and `origin/main` both pointed at G05 commit `69ba52ac48a0524a4a3b6480e5e5b9aa2052ad00`.
2. Queried LM Studio's loopback model catalog and found exactly one local embedding model: `text-embedding-nomic-embed-text-v1.5`.
3. Measured the fixed test string at dimension 768; two vectors produced equal content checksums and L2 norm `1.000000024807349`.
4. Added the versioned public profile, typed Prolog transport/validation membrane, fixed fixtures, runner, and verifier.
5. The deterministic runner made exactly two embedding requests. A separate pinned-PeTTa fixture made one boundary-conformance request and returned the same vector checksum.
6. Neither path made a Chroma request.
7. The wrong-dimension profile expected 767 and rejected the observed 768-vector before any Chroma insertion surface existed.
8. Replayed the full verifier, checksum manifest, protected-document hashes, machine-local profile hash, and public-safety scan before commit.
