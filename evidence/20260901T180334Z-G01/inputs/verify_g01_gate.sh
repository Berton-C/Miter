#!/bin/sh
set -u

RUN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REPO_ROOT=$(CDPATH= cd -- "$RUN_ROOT/../.." && pwd)
failures=""

fail() {
  if [ -z "$failures" ]; then
    failures=$1
  else
    failures="$failures; $1"
  fi
}

[ "$(tr -d '\r\n ' < "$RUN_ROOT/environment/host_architecture.txt")" = "arm64" ] || fail "host architecture"
rg -q '^SWI-Prolog version 10\.0\.2 for arm64-darwin$' "$RUN_ROOT/environment/swipl_version_after.txt" || fail "native SWI-Prolog version"
rg -q 'Mach-O 64-bit executable arm64' "$RUN_ROOT/environment/swipl_binary_file.txt" || fail "SWI-Prolog binary architecture"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/environment/petta_commit.txt")" = "ae66fa8e41dcd5539d614706bd4e5cfb34f9608d" ] || fail "PeTTa commit pin"
rg -q '^## HEAD \(no branch\)$' "$RUN_ROOT/raw/petta_source_status_final.txt" || fail "detached clean PeTTa source"
[ "$(wc -l < "$RUN_ROOT/hashes/petta_tracked_files.sha256" | tr -d ' ')" = "230" ] || fail "PeTTa source manifest"

[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/positive.status")" = "0" ] || fail "positive runtime exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/positive_repeat.status")" = "0" ] || fail "repeat runtime exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/diffs/positive_repeat_stdout.cmp.status")" = "0" ] || fail "repeat output equality"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/outputs/verifier_positive.status")" = "0" ] || fail "positive verifier"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/outputs/verifier_severed.status")" = "1" ] || fail "severed verifier"
jq -e '.status == "PASS" and .expected == "5" and .actual == "5" and .runtime_exit == 0' "$RUN_ROOT/outputs/verifier_positive.json" >/dev/null 2>&1 || fail "positive verifier result"
jq -e '.status == "FAIL" and .expected == "6" and .actual == "5"' "$RUN_ROOT/outputs/verifier_severed.json" >/dev/null 2>&1 || fail "severed verifier result"

rg -q '^\+ swipl ' "$RUN_ROOT/process/positive_executable_trace.txt" || fail "native launcher trace"
[ ! -s "$RUN_ROOT/process/python_seam_scan.txt" ] || fail "Python seam appeared in fixture or trace"
cmp -s "$RUN_ROOT/hashes/protected_documents_before.sha256" "$RUN_ROOT/hashes/protected_documents_after.sha256" || fail "protected document drift"
rg -q 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d' "$REPO_ROOT/DECISIONS.md" || fail "decision pin"
[ "$(tr -d '\r\n ' < "$REPO_ROOT/tests/fixtures/minimal.metta")" = "!(+23)" ] || fail "minimal fixture"

if [ -z "$failures" ]; then
  printf '{"verifier":"g01-gate-verifier-v1","status":"PASS","failures":[]}\n'
  exit 0
fi

printf '{"verifier":"g01-gate-verifier-v1","status":"FAIL","failures":"%s"}\n' "$failures"
exit 1
