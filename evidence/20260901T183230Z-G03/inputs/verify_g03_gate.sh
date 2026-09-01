#!/bin/sh
set -u

RUN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REPO_ROOT=$(CDPATH= cd -- "$RUN_ROOT/../.." && pwd)
failures=""

fail() {
  if [ -z "$failures" ]; then failures=$1; else failures="$failures; $1"; fi
}

jq -e '.status == "PASS"' "$REPO_ROOT/evidence/20260901T181843Z-G02/verdict.json" >/dev/null 2>&1 || fail "G02 prerequisite"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/environment/petta_commit.txt")" = "ae66fa8e41dcd5539d614706bd4e5cfb34f9608d" ] || fail "PeTTa pin"
rg -q '^SWI-Prolog version 10\.0\.2 for arm64-darwin$' "$RUN_ROOT/environment/swipl_version.txt" || fail "native SWI runtime"
rg -q '^## HEAD \(no branch\)$' "$RUN_ROOT/raw/petta_source_status_after.txt" || fail "clean detached PeTTa source"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_fixture.status")" = "0" ] || fail "fixture exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_fixture_repeat.status")" = "0" ] || fail "repeat fixture exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/direct_prolog_resolve.status")" = "0" ] || fail "separate config read exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/direct_prolog_unavailable.status")" = "0" ] || fail "unavailable-service probe exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/diffs/petta_repeat_stdout.cmp.status")" = "0" ] || fail "repeat output equality"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/diffs/local_config_repeat_hash.cmp.status")" = "0" ] || fail "repeat config equality"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/outputs/verifier.status")" = "0" ] || fail "G03 verifier exit"
jq -e '.status == "PASS" and .chat_profiles == 2 and .missing_alias == "unknown-model-profile" and .deterministic == true and .python_process == false and .redaction == "PASS"' "$RUN_ROOT/outputs/verifier.json" >/dev/null 2>&1 || fail "G03 verifier result"
rg -q "^missing_resolve\('unknown-model-profile',true\)$" "$RUN_ROOT/raw/direct_prolog_resolve.stdout" || fail "missing alias determinism"
rg -q "^unavailable_service\('lm-studio-unavailable',true\)$" "$RUN_ROOT/raw/direct_prolog_unavailable.stdout" || fail "unavailable-service totality"
rg -q '[[:space:]]swipl$' "$RUN_ROOT/process/process_tree_unique_safe.txt" || fail "SWI process proof"
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$RUN_ROOT/process/process_tree_unique_safe.txt"; then fail "Python process"; fi
if rg -q -i 'py-call|python|janus' "$REPO_ROOT/effect_membranes/miter_llm.pl" "$REPO_ROOT/tests/fixtures/g03_lmstudio_discovery.metta"; then fail "Python seam in G03 source"; fi
cmp -s "$RUN_ROOT/hashes/protected_documents_before.sha256" "$RUN_ROOT/hashes/protected_documents_after.sha256" || fail "protected document drift"
git -C "$REPO_ROOT" check-ignore -q config/local/g03-model-profiles.json || fail "local profile not ignored"

if [ -z "$failures" ]; then
  printf '{"verifier":"g03-gate-verifier-v1","status":"PASS","failures":[]}\n'
  exit 0
fi

printf '{"verifier":"g03-gate-verifier-v1","status":"FAIL","failures":"%s"}\n' "$failures"
exit 1
