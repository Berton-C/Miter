#!/bin/sh
set -u

RUN_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REPO_ROOT=$(CDPATH= cd -- "$RUN_ROOT/../.." && pwd)
failures=""

fail() {
  if [ -z "$failures" ]; then failures=$1; else failures="$failures; $1"; fi
}

jq -e '.status == "PASS"' "$RUN_ROOT/inputs/g01_prerequisite_verifier.json" >/dev/null 2>&1 || fail "G01 prerequisite"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/environment/petta_commit.txt")" = "ae66fa8e41dcd5539d614706bd4e5cfb34f9608d" ] || fail "PeTTa pin"
rg -q '^SWI-Prolog version 10\.0\.2 for arm64-darwin$' "$RUN_ROOT/environment/swipl_version.txt" || fail "native SWI runtime"
rg -q '^## HEAD \(no branch\)$' "$RUN_ROOT/raw/petta_source_status_after.txt" || fail "clean detached PeTTa source"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_fixture.status")" = "0" ] || fail "fixture exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/petta_fixture_monitored.status")" = "0" ] || fail "monitored fixture exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/raw/direct_prolog_probe.status")" = "0" ] || fail "direct Prolog proof exit"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/diffs/petta_repeat_stdout.cmp.status")" = "0" ] || fail "repeat output equality"
[ "$(tr -d '\r\n ' < "$RUN_ROOT/outputs/verifier.status")" = "0" ] || fail "G02 verifier exit"
jq -e '.status == "PASS" and .success_count == 1 and .malformed_count == 1 and .deterministic == true and .python_process == false' "$RUN_ROOT/outputs/verifier.json" >/dev/null 2>&1 || fail "G02 verifier result"
rg -q '^positive_solutions\(\[miter_int_42\]\)$' "$RUN_ROOT/raw/direct_prolog_probe.stdout" || fail "positive solution cardinality"
rg -q '^malformed_solutions\(\[miter_error_expected_integers\]\)$' "$RUN_ROOT/raw/direct_prolog_probe.stdout" || fail "malformed solution cardinality"
rg -q '^positive_determinism\(miter_int_42,true\)$' "$RUN_ROOT/raw/direct_prolog_probe.stdout" || fail "positive determinism"
rg -q '^malformed_determinism\(miter_error_expected_integers,true\)$' "$RUN_ROOT/raw/direct_prolog_probe.stdout" || fail "malformed determinism"
rg -q '[[:space:]]sh$' "$RUN_ROOT/process/process_tree_unique_safe.txt" || fail "shell process proof"
rg -q '[[:space:]]swipl$' "$RUN_ROOT/process/process_tree_unique_safe.txt" || fail "SWI process proof"
if rg -q -i 'python|janus' "$RUN_ROOT/process/process_tree_unique_safe.txt"; then fail "Python process"; fi
if rg -q -i 'py-call|python|janus' "$REPO_ROOT/effect_membranes/miter_probe.pl" "$REPO_ROOT/tests/fixtures/g02_prolog_import.metta"; then fail "Python seam in G02 source"; fi
cmp -s "$RUN_ROOT/hashes/protected_documents_before.sha256" "$RUN_ROOT/hashes/protected_documents_after.sha256" || fail "protected document drift"

if [ -z "$failures" ]; then
  printf '{"verifier":"g02-gate-verifier-v1","status":"PASS","failures":[]}\n'
  exit 0
fi

printf '{"verifier":"g02-gate-verifier-v1","status":"FAIL","failures":"%s"}\n' "$failures"
exit 1
