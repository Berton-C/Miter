#!/bin/sh
set -u

if [ "$#" -ne 9 ]; then
  printf '%s\n' 'usage: verify_g03.sh STDOUT STATUS CONFIG REDACTED_RESPONSE PROCESS_TREE DIRECT_PROLOG CONFIG_HASH PROTECTED_BEFORE PROTECTED_AFTER' >&2
  exit 64
fi

STDOUT_FILE=$1
STATUS_FILE=$2
CONFIG_FILE=$3
REDACTED_RESPONSE_FILE=$4
PROCESS_TREE_FILE=$5
DIRECT_PROLOG_FILE=$6
CONFIG_HASH_FILE=$7
PROTECTED_BEFORE_FILE=$8
PROTECTED_AFTER_FILE=$9

for required_file in "$STDOUT_FILE" "$STATUS_FILE" "$CONFIG_FILE" "$REDACTED_RESPONSE_FILE" "$PROCESS_TREE_FILE" "$DIRECT_PROLOG_FILE" "$CONFIG_HASH_FILE" "$PROTECTED_BEFORE_FILE" "$PROTECTED_AFTER_FILE"
do
  if [ ! -f "$required_file" ]; then
    printf '{"verifier":"g03-verifier-v1","status":"FAIL","reason":"missing input"}\n'
    exit 1
  fi
done

failure=""
runtime_status=$(tr -d '\r\n ' < "$STATUS_FILE")
escape_character=$(printf '\033')
clean_stdout=$(mktemp "${TMPDIR:-/tmp}/miter-g03-stdout.XXXXXX") || exit 1
trap 'rm -f "$clean_stdout"' EXIT HUP INT TERM
sed "s/${escape_character}\\[[0-9;]*m//g" "$STDOUT_FILE" | tr -d '\r' > "$clean_stdout"

[ "$runtime_status" = "0" ] || failure="runtime exit was not zero"
jq -e '.schema == "miter-local-model-profiles-v1" and (.endpoint | type == "string") and (.profiles | type == "array")' "$CONFIG_FILE" >/dev/null 2>&1 || failure="invalid local profile schema"

qwen_id=$(jq -r '.profiles[] | select(.alias == "qwen-local") | .id' "$CONFIG_FILE")
nemotron_id=$(jq -r '.profiles[] | select(.alias == "nemotron-local") | .id' "$CONFIG_FILE")
embedding_id=$(jq -r '.profiles[] | select(.alias == "embedding-local") | .id' "$CONFIG_FILE")

[ -n "$qwen_id" ] || failure="qwen-local did not resolve"
[ -n "$nemotron_id" ] || failure="nemotron-local did not resolve"
[ -n "$embedding_id" ] || failure="embedding-local did not resolve"
[ "$(jq '[.profiles[] | select(.alias == "qwen-local")] | length' "$CONFIG_FILE")" = "1" ] || failure="qwen-local cardinality"
[ "$(jq '[.profiles[] | select(.alias == "nemotron-local")] | length' "$CONFIG_FILE")" = "1" ] || failure="nemotron-local cardinality"
[ "$(jq '[.profiles[] | select(.alias == "embedding-local")] | length' "$CONFIG_FILE")" = "1" ] || failure="embedding-local cardinality"

jq -e --arg id "$qwen_id" 'any(.data[]; .id == $id)' "$REDACTED_RESPONSE_FILE" >/dev/null 2>&1 || failure="qwen ID absent from service response"
jq -e --arg id "$nemotron_id" 'any(.data[]; .id == $id)' "$REDACTED_RESPONSE_FILE" >/dev/null 2>&1 || failure="nemotron ID absent from service response"
jq -e --arg id "$embedding_id" 'any(.data[]; .id == $id)' "$REDACTED_RESPONSE_FILE" >/dev/null 2>&1 || failure="embedding ID absent from service response"
jq -e '(.data | type == "array") and all(.data[]; (keys | sort) == ["id","state","type"])' "$REDACTED_RESPONSE_FILE" >/dev/null 2>&1 || failure="service response was not mechanically redacted"

[ "$(awk '$0 == "model-profile-bound" { count++ } END { print count+0 }' "$clean_stdout")" = "3" ] || failure="profile bind success count"
[ "$(awk -v value="$qwen_id" '$0 == value { count++ } END { print count+0 }' "$clean_stdout")" = "1" ] || failure="qwen exact resolution output"
[ "$(awk -v value="$nemotron_id" '$0 == value { count++ } END { print count+0 }' "$clean_stdout")" = "1" ] || failure="nemotron exact resolution output"
[ "$(awk -v value="$embedding_id" '$0 == value { count++ } END { print count+0 }' "$clean_stdout")" = "1" ] || failure="embedding exact resolution output"
[ "$(awk '$0 == "unknown-model-profile" { count++ } END { print count+0 }' "$clean_stdout")" = "1" ] || failure="missing alias did not fail closed"

grep -Fq "qwen_resolve('$qwen_id',true)" "$DIRECT_PROLOG_FILE" || failure="qwen direct resolution determinism"
grep -Fq "nemotron_resolve('$nemotron_id',true)" "$DIRECT_PROLOG_FILE" || failure="nemotron direct resolution determinism"
grep -Fq "embedding_resolve('$embedding_id',true)" "$DIRECT_PROLOG_FILE" || failure="embedding direct resolution determinism"
grep -Fq "missing_resolve('unknown-model-profile',true)" "$DIRECT_PROLOG_FILE" || failure="missing alias direct determinism"

rg -q '[[:space:]]swipl$' "$PROCESS_TREE_FILE" || failure="missing native swipl process"
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$PROCESS_TREE_FILE"; then failure="Python process in Miter tree"; fi

expected_hash=$(awk 'NR == 1 { print $1 }' "$CONFIG_HASH_FILE")
actual_hash=$(shasum -a 256 "$CONFIG_FILE" | awk '{ print $1 }')
[ "$expected_hash" = "$actual_hash" ] || failure="local config hash mismatch"
cmp -s "$PROTECTED_BEFORE_FILE" "$PROTECTED_AFTER_FILE" || failure="protected document hash mismatch"
git check-ignore -q "$CONFIG_FILE" || failure="local config is not ignored"

if [ -z "$failure" ]; then
  printf '{"verifier":"g03-verifier-v1","status":"PASS","chat_profiles":2,"embedding_profile":1,"missing_alias":"unknown-model-profile","runtime_exit":0,"deterministic":true,"python_process":false,"redaction":"PASS"}\n'
  exit 0
fi

printf '{"verifier":"g03-verifier-v1","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
