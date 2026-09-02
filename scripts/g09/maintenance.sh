#!/bin/sh
# Human-approved G09 service maintenance only; never migrate the legacy store.
set -eu
umask 077
cd /Users/claritymiter/miter
run=/Users/claritymiter/miter/evidence/20260902T060235Z-G09
legacy=/Users/bcb/Documents/ClarityOmega/clarityomega/volumes/omegaclaw/chroma_db
backup=/Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline/chroma_db
image=docker.io/chromadb/chroma:1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6
test ! -e "$backup"
test ! -L "$legacy"
test "$(docker inspect clarity_omega --format '{{.State.Running}}')" = true
if docker inspect miter-chroma >/dev/null 2>&1; then exit 1; fi
if docker volume inspect miter-chroma-v1 >/dev/null 2>&1; then exit 1; fi
identity() {
  docker inspect clarity_omega --format '{"id":{{json .Id}},"image":{{json .Image}},"mounts":{{json .Mounts}}}'
}
counts() {
  sqlite3 -readonly -header -tabs "$legacy/chroma.sqlite3" 'SELECT c.id,c.name,c.dimension,COUNT(e.id) AS embedding_count FROM collections c LEFT JOIN segments s ON s.collection=c.id LEFT JOIN embeddings e ON e.segment_id=s.id GROUP BY c.id,c.name,c.dimension;'
}
hashes() { (cd "$1" && find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort); }
identity > "$run/raw/legacy_identity_before.json"
counts > "$run/raw/legacy_live_before.tsv"
hashes "$legacy" > "$run/hashes/legacy_live_before.sha256"
docker ps --format '{{.Names}} {{.Status}}' > "$run/raw/services_before.txt"
stopped=false
restore() {
  if [ "$stopped" = true ]; then
    docker start clarity_omega > "$run/raw/legacy_restart.txt"
    docker inspect clarity_omega --format '{{json .State}}' > "$run/raw/legacy_restarted_state.json"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$run/raw/maintenance_end.txt"
  fi
}
trap restore EXIT
trap 'exit 130' INT TERM HUP
date -u +%Y-%m-%dT%H:%M:%SZ > "$run/raw/maintenance_start.txt"
stopped=true
docker stop -t 20 clarity_omega > "$run/raw/legacy_stop.txt"
test "$(docker inspect clarity_omega --format '{{.State.Running}}')" = false
docker inspect clarity_omega --format '{{json .State}}' > "$run/raw/legacy_stopped_state.json"
lsof -F paftn +D "$legacy" > "$run/raw/legacy_open_files.txt" 2> "$run/raw/legacy_lsof.stderr" || test "$?" -eq 1
# Docker's macOS VM retains read-only file-sharing handles after the guest
# writer exits. Those cannot mutate the files. Reject write/read-write/unknown
# access; never stop the VM (which also owns the user's Mattermost service).
if rg -q '^a($|[^r])' "$run/raw/legacy_open_files.txt"; then exit 1; fi
test ! -s "$run/raw/legacy_lsof.stderr"
# Check every remaining container for a shared source mount; do not print env.
for cid in $(docker ps -q); do
  docker inspect "$cid" --format '{{json .Mounts}}' | jq -e --arg p "$legacy" 'all(.[]; (.Source|startswith($p)|not))' >/dev/null
done
hashes "$legacy" > "$run/hashes/legacy_before.sha256"
counts > "$run/raw/legacy_before.tsv"
sqlite3 -readonly "$legacy/chroma.sqlite3" 'PRAGMA quick_check;' > "$run/raw/legacy_sqlite_check.txt"
# Preserve source-health diagnostics, including failures. G09 proves exact
# backup and isolation, not repair or health of the user's existing database.
# Never alter the source to make this diagnostic pass.
mkdir -p /Users/bcb/Documents/Miter-Backups/clarityomega-chroma-g00-baseline
ditto "$legacy" "$backup"
chmod 700 "$backup"
hashes "$backup" > "$run/hashes/backup.sha256"
cmp "$run/hashes/legacy_before.sha256" "$run/hashes/backup.sha256"
docker volume create --label miter.purpose=isolated-semantic-index miter-chroma-v1 > "$run/raw/volume_create.txt"
docker run -d --name miter-chroma --publish 127.0.0.1:8001:8000 --mount type=volume,source=miter-chroma-v1,target=/data "$image" > "$run/raw/container_create.txt"
ready=false
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if curl --fail --silent --show-error --max-time 3 http://127.0.0.1:8001/api/v2/heartbeat > "$run/raw/heartbeat.json" 2> "$run/raw/heartbeat.stderr"; then ready=true; break; fi
  sleep 1
done
test "$ready" = true
docker inspect miter-chroma --format '{"id":{{json .Id}},"image":{{json .Image}},"mounts":{{json .Mounts}},"ports":{{json .HostConfig.PortBindings}}}' > "$run/raw/miter_identity.json"
docker image inspect "$image" --format '{"id":{{json .Id}},"architecture":{{json .Architecture}},"digests":{{json .RepoDigests}}}' > "$run/raw/image_identity.json"
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g09_create.metta > "$run/raw/create.stdout" 2> "$run/raw/create.stderr"
jq -e '.result=="chroma-collection-created"' runtime/g09/create.json >/dev/null
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g09_verify.metta > "$run/raw/verify.stdout" 2> "$run/raw/verify.stderr"
cp runtime/g09/*.json "$run/outputs/"
identity > "$run/raw/legacy_identity_after.json"
counts > "$run/raw/legacy_after.tsv"
hashes "$legacy" > "$run/hashes/legacy_after.sha256"
sqlite3 -readonly "$legacy/chroma.sqlite3" 'PRAGMA quick_check;' > "$run/raw/legacy_sqlite_check_after.txt"
cmp "$run/raw/legacy_sqlite_check.txt" "$run/raw/legacy_sqlite_check_after.txt"
shasum -a 256 CONSTITUTION.md ACCEPTANCE.md AUTHORITY_MAP.md POC_SPEC.md DECISIONS.md WORK_PROTOCOL.md > "$run/hashes/protected_after.sha256"
docker logs miter-chroma > "$run/raw/service_logs.txt" 2>&1
ps -axo pid=,ppid=,comm= > "$run/raw/processes.txt"
sh scripts/g09/verify_g09.sh "$run" > "$run/verdict.json.tmp"
mv "$run/verdict.json.tmp" "$run/verdict.json"
