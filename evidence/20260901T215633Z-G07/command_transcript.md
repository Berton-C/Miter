# G07 command transcript

1. Confirmed a clean `main` at G06 commit `4e2cc232032918fdeaa44bcc3e0210c2795f748e`, equal to `origin/main`.
2. Added MeTTa event semantics, a typed Prolog append/verify/readback membrane, and a 43-line POSIX fsync runtime extension with no Python or shell fallback.
3. Compiled the extension locally as an ignored arm64 Mach-O shared library; no binary is committed.
4. Started a fresh ignored test store and ran three separate pinned-PeTTa processes: append three events; restart/verify/readback/append fork; restart/verify/readback.
5. Preserved the three-line ledger before fork, four-line ledger after fork, and unchanged final ledger after restart.
6. Produced a separate corrupted copy by changing only old line 2; the canonical test ledger remained untouched.
7. Ran the negative copy through a fourth pinned-PeTTa process and recorded the first broken event and surviving later-line count.
8. Replayed the complete verifier, checksums, protected-file comparison, process trace, and public-safety scan before commit.
