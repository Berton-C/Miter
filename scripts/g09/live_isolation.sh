#!/bin/sh
# G09 continuation after the separately verified stopped-writer backup.
set -eu
umask 077
cd /Users/claritymiter/miter
run=/Users/claritymiter/miter/evidence/20260902T060235Z-G09
legacy=/Users/bcb/Documents/ClarityOmega/clarityomega/volumes/omegaclaw/chroma_db
hashes() { (cd "$legacy" && find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort); }
counts() { sqlite3 -readonly -header -tabs "$legacy/chroma.sqlite3" 'SELECT c.id,c.name,c.dimension,COUNT(e.id) AS embedding_count FROM collections c LEFT JOIN segments s ON s.collection=c.id LEFT JOIN embeddings e ON e.segment_id=s.id GROUP BY c.id,c.name,c.dimension;'; }
identity() { docker inspect clarity_omega --format '{"id":{{json .Id}},"image":{{json .Image}},"mounts":{{json .Mounts}}}'; }
test "$(docker inspect clarity_omega --format '{{.State.Running}}')" = true
cmp "$run/hashes/backup_source.sha256" "$run/hashes/backup.sha256"
hashes > "$run/hashes/legacy_before.sha256"
counts > "$run/raw/legacy_before.tsv"
identity > "$run/raw/legacy_identity_before.json"
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g09_create.metta > "$run/raw/create.stdout" 2> "$run/raw/create.stderr"
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g09_verify.metta > "$run/raw/verify.stdout" 2> "$run/raw/verify.stderr"
hashes > "$run/hashes/legacy_after.sha256"
counts > "$run/raw/legacy_after.tsv"
identity > "$run/raw/legacy_identity_after.json"
cp runtime/g09/*.json "$run/outputs/"
shasum -a 256 CONSTITUTION.md ACCEPTANCE.md AUTHORITY_MAP.md POC_SPEC.md DECISIONS.md WORK_PROTOCOL.md > "$run/hashes/protected_after.sha256"
docker logs miter-chroma > "$run/raw/service_logs.txt" 2>&1
docker ps --format '{{.Names}} {{.Status}} {{.Ports}}' > "$run/raw/services_after.txt"
ps -axo pid=,ppid=,comm= > "$run/raw/processes.txt"
sh scripts/g09/verify_g09.sh "$run" > "$run/verdict.json.tmp"
mv "$run/verdict.json.tmp" "$run/verdict.json"
