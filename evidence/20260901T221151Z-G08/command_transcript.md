# G08 command transcript

1. Confirmed clean `main` at G07 commit `54a77d0fbb9abed6896706478bab751ab9f8794f`, equal to `origin/main`.
2. Added MeTTa continuity semantics and a typed Prolog capsule/index/reconstruction membrane using the G07 lock/fsync runtime boundary.
3. Verified the manuscript's byte-level SHA-256 before capsule admission.
4. In a first pinned-PeTTa process, appended capsule 001 and preserved its bytes.
5. In a second process, appended capsule 002 and explicitly selected it in current.json; capsule 001 remained byte-identical.
6. In a third process, reconstructed exact current state and retrieved capsule 001 directly.
7. Created a separate copy, removed only its current.json, verified both capsule files were byte-identical, and ran a fourth PeTTa reconstruction.
8. Recorded ambiguity with both candidates and no timestamp fallback, then replayed the complete verifier and integrity scans.
