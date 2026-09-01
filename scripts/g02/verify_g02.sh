#!/bin/sh
set -u

if [ "$#" -ne 5 ]; then
  printf '%s\n' 'usage: verify_g02.sh STDOUT STATUS DIRECT_PROLOG PROCESS_TREE STDERR_TRACE' >&2
  exit 64
fi

STDOUT_FILE=$1
STATUS_FILE=$2
DIRECT_PROLOG_FILE=$3
PROCESS_TREE_FILE=$4
STDERR_TRACE_FILE=$5

for required_file in "$STDOUT_FILE" "$STATUS_FILE" "$DIRECT_PROLOG_FILE" "$PROCESS_TREE_FILE" "$STDERR_TRACE_FILE"
do
  if [ ! -f "$required_file" ]; then
    printf '{"verifier":"g02-verifier-v1","status":"FAIL","reason":"missing input"}\n'
    exit 1
  fi
done

escape_character=$(printf '\033')
runtime_status=$(tr -d '\r\n ' < "$STATUS_FILE")
success_count=$(sed "s/${escape_character}\\[[0-9;]*m//g" "$STDOUT_FILE" | awk '$0 == "miter_int_42" { count++ } END { print count+0 }')
error_count=$(sed "s/${escape_character}\\[[0-9;]*m//g" "$STDOUT_FILE" | awk '$0 == "miter_error_expected_integers" { count++ } END { print count+0 }')

failure=""
[ "$runtime_status" = "0" ] || failure="runtime exit was not zero"
[ "$success_count" = "1" ] || failure="typed success count was not one"
[ "$error_count" = "1" ] || failure="typed error count was not one"
rg -q '^positive_solutions\(\[miter_int_42\]\)$' "$DIRECT_PROLOG_FILE" || failure="positive solution cardinality"
rg -q '^malformed_solutions\(\[miter_error_expected_integers\]\)$' "$DIRECT_PROLOG_FILE" || failure="malformed solution cardinality"
rg -q '^positive_determinism\(miter_int_42,true\)$' "$DIRECT_PROLOG_FILE" || failure="positive choice point"
rg -q '^malformed_determinism\(miter_error_expected_integers,true\)$' "$DIRECT_PROLOG_FILE" || failure="malformed choice point"
rg -q '[[:space:]]swipl$' "$PROCESS_TREE_FILE" || failure="missing swipl process"
if rg -q -i 'python|janus' "$PROCESS_TREE_FILE"; then failure="Python process in Miter tree"; fi
rg -q '^\+ swipl ' "$STDERR_TRACE_FILE" || failure="launcher did not invoke swipl directly"

if [ -z "$failure" ]; then
  printf '{"verifier":"g02-verifier-v1","status":"PASS","success":"miter_int_42","malformed":"miter_error_expected_integers","success_count":1,"malformed_count":1,"runtime_exit":0,"deterministic":true,"python_process":false}\n'
  exit 0
fi

printf '{"verifier":"g02-verifier-v1","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
