#!/bin/sh
set -u

RUN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REPO_ROOT=$(CDPATH= cd -- "$RUN_ROOT/../.." && pwd)
failures=""

fail() {
  if [ -z "$failures" ]; then
    failures="$1"
  else
    failures="$failures; $1"
  fi
}

require_file() {
  [ -s "$RUN_ROOT/$1" ] || fail "missing or empty $1"
}

require_file manifest.json
require_file outputs/environment_summary.json
require_file outputs/external_repositories.json
require_file outputs/chroma_backup_and_isolation_plan.md
require_file services/lmstudio_api_v0_models.json
require_file services/chroma_collection_snapshot_final.tsv
require_file services/miter_chroma_candidate_image.txt
require_file hashes/docs_sources.sha256
require_file hashes/ratified_authorities.sha256

jq -e '.run_id == "20260901T172140Z-G00" and .gate_id == "G00" and .git_dirty == false' "$RUN_ROOT/manifest.json" >/dev/null 2>&1 || fail "manifest schema/value check"

[ "$(wc -l < "$RUN_ROOT/hashes/docs_sources.sha256" | tr -d ' ')" = "25" ] || fail "required source count"
[ "$(wc -l < "$RUN_ROOT/hashes/ratified_authorities.sha256" | tr -d ' ')" = "5" ] || fail "authority count"

for model_id in \
  qwen/qwen3.8-27b \
  nemotron-3.5-30b-a3b-antislop-ftpo-i1 \
  text-embedding-nomic-embed-text-v1.5
do
  jq -e --arg id "$model_id" '.data[] | select(.id == $id)' "$RUN_ROOT/services/lmstudio_api_v0_models.json" >/dev/null 2>&1 || fail "missing model $model_id"
done

[ "$(tr -d '\r\n ' < "$RUN_ROOT/services/lmstudio_api_v0_models.status")" = "200" ] || fail "LM Studio API health"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/services/lmstudio_missing_model.status")" = "400" ] || fail "missing-model negative control status"
rg -q -i 'not found' "$RUN_ROOT/services/lmstudio_missing_model.json" || fail "missing-model negative control body"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/services/nonexistent_service.status")" = "000" ] || fail "nonexistent-service negative control"
rg -q 'miter-g00-nonexistent-collection[[:space:]]+unavailable' "$RUN_ROOT/services/chroma_missing_collection.tsv" || fail "missing-collection negative control"

rg -q '^memories[[:space:]]+1024[[:space:]]+44643$' "$RUN_ROOT/services/chroma_collection_snapshot_final.tsv" || fail "completion Chroma collection snapshot"
rg -q 'PersistentClient' "$RUN_ROOT/services/clarity_chroma_client_mode.txt" || fail "Clarity Chroma client mode"
rg -q 'Digest:[[:space:]]+sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6' "$RUN_ROOT/services/miter_chroma_candidate_image.txt" || fail "Miter Chroma image pin"
rg -q 'http://127.0.0.1:8001' "$RUN_ROOT/outputs/chroma_backup_and_isolation_plan.md" || fail "Miter Chroma endpoint plan"
rg -q 'miter-chroma-v1' "$RUN_ROOT/outputs/chroma_backup_and_isolation_plan.md" || fail "Miter Chroma volume plan"

[ "$(tr -d '\r\n ' < "$RUN_ROOT/services/mattermost_ping_after_restart.status")" = "200" ] || fail "Mattermost health"
rg -q '"status":"OK"' "$RUN_ROOT/services/mattermost_ping_after_restart.json" || fail "Mattermost health body"

cmp -s "$RUN_ROOT/hashes/protected_documents_before.sha256" "$RUN_ROOT/hashes/protected_documents_after.sha256" || fail "protected document hash drift"
[ -s "$RUN_ROOT/diffs/chroma_persistence_hashes_completion.diff" ] || fail "missing Chroma restart delta"

[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_container_git_HEAD")" = "6b7f52f064bdbc82fabd0a0998404121fb01d52e" ] || fail "PeTTa container HEAD"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_container_git_shallow")" = "6b7f52f064bdbc82fabd0a0998404121fb01d52e" ] || fail "PeTTa shallow pin"
rg -q 'import_prolog_function' "$RUN_ROOT/raw/petta_pinned_prologimport.metta" || fail "PeTTa Prolog import path"

if rg -n -i '(Serial Number|Hardware UUID|Provisioning UDID|Authorization:[[:space:]]*(Bearer|Basic)|(^|[^A-Za-z])(password|passwd|api[_-]?key|access[_-]?token|refresh[_-]?token|secret)[[:space:]]*[:=][[:space:]]*[^[:space:]]+)' \
  "$RUN_ROOT/environment" "$RUN_ROOT/raw" "$RUN_ROOT/services" "$RUN_ROOT/hashes" "$RUN_ROOT/diffs" "$RUN_ROOT/outputs" >/dev/null 2>&1; then
  fail "possible secret or private hardware identifier in evidence"
fi

if [ -z "$failures" ]; then
  printf '{"verifier":"g00-verifier-v1","status":"PASS","failures":[]}\n'
  exit 0
fi

printf '{"verifier":"g00-verifier-v1","status":"FAIL","failures":"%s"}\n' "$failures"
exit 1
