# G09 — PASS, with a separate legacy-health warning

## Proven result

Pinned native-arm64 Miter Chroma runs on `127.0.0.1:8001`, with its own named
volume `miter-chroma-v1`. Collection `miter-ltm-v1` was created through the native
PeTTa-to-Prolog HTTP boundary and read back in another PeTTa process. It has the
G06 Nomic 768-dimension profile, full profile fingerprint, normalization/chunking
metadata, cosine distance, source-store link, schema and creation version.

The wrong-profile insertion and both legacy-target controls returned typed
rejections with **zero HTTP requests**, before any service contact. The real
legacy deployment is embedded and has no HTTP endpoint: one control targets its
actual persistence URI; the additional HTTP control rejects the historically
considered but unauthorized localhost port 8000. Neither is represented as a
successful connection to a legacy HTTP server. Miter's record count stayed zero.

During the final live isolation test, ClarityOmega remained running. Its exact
container/image/mount identity, all six persistence-file hashes, and collection
count **44,703** matched before and after. Mattermost was not stopped.

## Backup and maintenance

The six-file byte-for-byte backup is outside Git at
`/Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline/chroma_db`.
`hashes/backup_source.sha256` and `hashes/backup.sha256` independently match.
The stopped writer, absence of other writers, and source counts are recorded.
The private database contents were not copied into evidence or Git.

Three short maintenance attempts took 21, 22, and 25 seconds respectively. Each
exit trap restarted only `clarity_omega`; its stopped state reported exit 137
after Docker's 20-second shutdown timeout. The first attempt stopped at a
read-only-handle check, the second at a source-health diagnostic, and the third
completed the backup but exposed a version-string assumption. Raw failed probes
are retained under attempt1/, attempt2/, and attempt3/.

## Warning — legacy health is NOT proven

SQLite reported `malformed inverted index for FTS5 table
main.embedding_fulltext_search` before any copy or Miter data write. The cause,
age, and effect are unknown. No repair, migration, or legacy collection write
was performed. The backup preserves the observed bytes, including any existing
fault; it is not claimed to be a healthy or application-restored database.
This warning does not affect the separate, fresh Miter index.

## Version distinction

Image digest `sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6`
is unchanged from G00. Official 1.5.9 release source confirms the API hardcodes
`1.0.0` and the CLI package declares `1.4.4`. Config records these independently;
the API version string is not treated as an image attestation.

## Verification and boundaries

`scripts/g09/verify_g09.sh` independently checks saved mutation/readback evidence,
negative controls, deployment isolation, backup manifests, and protected hashes.
The MeTTa core uses Prolog HTTP, with no Python/helper-shell service seam.
No `initial_canon`, source authority, licensed VAD asset, credential, or
`~/.miter` path was modified. The earlier blocked preflight is preserved.

Rollback: stop only `miter-chroma` if needed; preserve its volume and the legacy
backup. Do not remove or restore over ClarityOmega as part of this gate.
Next eligible gate: **G10**, governed admission and scoped semantic recall.
