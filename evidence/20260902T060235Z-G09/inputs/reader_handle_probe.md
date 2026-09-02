# Backup guard refinement

The first approved maintenance attempt ran from 06:09:02 to 06:09:23 UTC.
Docker stopped clarity_omega (exit 137 after its 20-second shutdown timeout),
then the original any-open-handle guard aborted before any copy. The exit trap
restarted clarity_omega. No Miter service or volume was created.

The retained lsof output shows only read-only handles (`r`) while the container
was stopped. Process 18176 is Apple's Virtualization framework VM used by
Docker; it retains read-only file-sharing handles. After restarting the writer,
the same machine-readable inspection shows read/write handles (`au`) as well.

The revised guard requires the legacy container stopped, no other running
container mounted on the legacy path, no write/read-write/unknown-access host
handle, no lsof diagnostics, SQLite quick_check=ok, and matching complete
source/backup/source-after hash manifests. It permits read-only handles rather
than unnecessarily stopping the shared VM and Mattermost. This does not relax
the no-concurrent-mutation or byte-identical-backup acceptance requirement.
