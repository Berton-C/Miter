# Source health is separate from byte-for-byte backup fidelity

During the second maintenance attempt (06:11:00–06:11:22 UTC), Apple's SQLite
3.51.0 returned `malformed inverted index for FTS5 table
main.embedding_fulltext_search`. No copy or Miter data mutation had occurred.
The safety trap restarted clarity_omega. A subsequent read-only integrity_check
also reported the same error. Its cause, age, and user-visible effect are unknown;
there is no evidence establishing whether it predates the first service stop.

This is not authorization to repair or migrate ClarityOmega. The next attempt
retains this health failure as a diagnostic, verifies that it is unchanged over
the isolation window, and requires exact matching manifests for all source and
backup bytes. A byte-identical backup preserves the original condition, including
any faults. It must not be described as a healthy database backup.

G09's required isolation/unchanged-state test remains strict. Its acceptance
contract does not require repairing the legacy full-text index. Miter uses no
legacy content and shares no persistence with it. G09 will not claim legacy
database integrity is proven. Investigating/repairing the user's legacy index
would be a separate user-directed task and is not performed here.
