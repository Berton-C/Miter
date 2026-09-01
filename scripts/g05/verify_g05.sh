#!/bin/sh
set -eu

if [ "$#" -ne 10 ]; then
  printf '%s\n' 'usage: verify_g05.sh CORPUS Q_RUN N_RUN METRICS ROLE_MAP NEG_METRICS NEG_RESULT PROTECTED_BEFORE PROTECTED_AFTER PROCESS_SAMPLE' >&2
  exit 64
fi

CORPUS=$1
Q_RUN=$2
N_RUN=$3
METRICS=$4
ROLE_MAP=$5
NEG_METRICS=$6
NEG_RESULT=$7
PROTECTED_BEFORE=$8
PROTECTED_AFTER=$9
PROCESS_SAMPLE=${10}

failure=''
fail() { if [ -z "$failure" ]; then failure=$1; else failure="$failure; $1"; fi; }

jq -e '.schema == "miter-g05-bakeoff-corpus-v1" and .repetitions >= 3 and .decoding.reasoning_effort == "none" and (.cases | length) == 6' "$CORPUS" >/dev/null || fail 'corpus contract'
jq -e '.schema == "miter-g05-bakeoff-run-v1" and .alias == "qwen-local" and .decoding.reasoning_effort == "none" and (.calls | length) == 18' "$Q_RUN" >/dev/null || fail 'Qwen run cardinality'
jq -e '.schema == "miter-g05-bakeoff-run-v1" and .alias == "nemotron-local" and .decoding.reasoning_effort == "none" and (.calls | length) == 18' "$N_RUN" >/dev/null || fail 'Nemotron run cardinality'
jq -e '.schema == "miter-g05-measurements-v1" and (.calls | length) == 36 and (.profiles | length) == 2' "$METRICS" >/dev/null || fail 'measurement cardinality'
jq -e '[.calls[] | .case_id] | group_by(.) | all(length == 6)' "$METRICS" >/dev/null || fail 'three repetitions per model and case'
jq -e '[.calls[] | .alias] | group_by(.) | all(length == 18)' "$METRICS" >/dev/null || fail 'profile repetition balance'
jq -e '[.calls[] | select(.schema_pass == true)] | length >= 18' "$METRICS" >/dev/null || fail 'no profile passed all schema arms'
jq -e 'any(.profiles[]; .schema_rate == 1 and .mean_quality_score == 5)' "$METRICS" >/dev/null || fail 'no profile passed every minimum content arm'
jq -e 'all(.profiles[]; .schema_rate == 1)' "$METRICS" >/dev/null || fail 'profile schema viability'
jq -e '.schema == "miter-model-role-map-v1" and .status == "selected" and (.roles | length) == 6 and ([.roles[].measurements[].repetitions] | all(. == 3))' "$ROLE_MAP" >/dev/null || fail 'role map'
jq -e '.default_profile == "qwen-local" and all(.roles[]; .resources_comparable == false)' "$ROLE_MAP" >/dev/null || fail 'provider-mode comparison guard'
jq -e '.status == "inconsistent_metrics"' "$NEG_RESULT" >/dev/null || fail 'reversed-score control was not rejected'
cmp -s "$PROTECTED_BEFORE" "$PROTECTED_AFTER" || fail 'protected document drift'
rg -q '([[:space:]]|/)swipl([[:space:]]|$)' "$PROCESS_SAMPLE" || fail 'missing SWI process evidence'
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$PROCESS_SAMPLE"; then fail 'Python in Miter bakeoff path'; fi
if rg -q -i 'sread|read_term|atom_to_term|process_metta_string|load_files' effect_membranes/miter_llm.pl; then fail 'provider evaluation surface'; fi
if find "$(dirname "$Q_RUN")" "$(dirname "$N_RUN")" -name '*.raw.json' -o -name 'raw.json' | while IFS= read -r raw; do typed="$(dirname "$raw")/typed.json"; [ "$raw" != "$typed" ] && [ -f "$typed" ] || exit 1; done; then :; else fail 'raw/typed separation'; fi
if cmp -s "$METRICS" "$NEG_METRICS"; then fail 'negative metrics copy was not mutated'; fi

if [ -z "$failure" ]; then
  printf '%s\n' '{"gate":"G05","status":"PASS","profiles":2,"cases":6,"repetitions_per_case":3,"calls":36,"negative_control":"inconsistent_metrics","python_process":false,"protected_documents_unchanged":true}'
  exit 0
fi

printf '{"gate":"G05","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
