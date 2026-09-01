#!/bin/sh
set -u

if [ "$#" -ne 20 ]; then
  printf '%s\n' 'usage: verify_g04.sh STDOUT STATUS CONFIG Q_TEMPLATE N_TEMPLATE MALFORMED Q_REQUEST Q_RAW Q_TYPED Q_TIMING N_REQUEST N_RAW N_TYPED N_TIMING NEG_TYPED PROCESS_TREE CONFIG_BEFORE CONFIG_AFTER PROTECTED_BEFORE PROTECTED_AFTER' >&2
  exit 64
fi

STDOUT_FILE=$1
STATUS_FILE=$2
CONFIG_FILE=$3
Q_TEMPLATE_FILE=$4
N_TEMPLATE_FILE=$5
MALFORMED_FILE=$6
Q_REQUEST_FILE=$7
Q_RAW_FILE=$8
Q_TYPED_FILE=$9
Q_TIMING_FILE=${10}
N_REQUEST_FILE=${11}
N_RAW_FILE=${12}
N_TYPED_FILE=${13}
N_TIMING_FILE=${14}
NEG_TYPED_FILE=${15}
PROCESS_TREE_FILE=${16}
CONFIG_BEFORE_FILE=${17}
CONFIG_AFTER_FILE=${18}
PROTECTED_BEFORE_FILE=${19}
PROTECTED_AFTER_FILE=${20}

for required_file in "$STDOUT_FILE" "$STATUS_FILE" "$CONFIG_FILE" "$Q_TEMPLATE_FILE" "$N_TEMPLATE_FILE" "$MALFORMED_FILE" "$Q_REQUEST_FILE" "$Q_RAW_FILE" "$Q_TYPED_FILE" "$Q_TIMING_FILE" "$N_REQUEST_FILE" "$N_RAW_FILE" "$N_TYPED_FILE" "$N_TIMING_FILE" "$PROCESS_TREE_FILE" "$CONFIG_BEFORE_FILE" "$CONFIG_AFTER_FILE" "$PROTECTED_BEFORE_FILE" "$PROTECTED_AFTER_FILE"
do
  if [ ! -f "$required_file" ]; then
    printf '{"verifier":"g04-verifier-v1","status":"FAIL","reason":"missing input"}\n'
    exit 1
  fi
done

failure=""
fail() {
  if [ -z "$failure" ]; then failure=$1; else failure="$failure; $1"; fi
}

runtime_status=$(tr -d '\r\n ' < "$STATUS_FILE")
[ "$runtime_status" = "0" ] || fail "runtime exit was not zero"
[ ! -e "$NEG_TYPED_FILE" ] || fail "malformed arm created a typed product"

validate_template() {
  template_file=$1
  expected_endpoint=$2
  jq -e --arg endpoint "$expected_endpoint" '
  .schema == "miter-schema-request-v1" and
  .request_id == "g04-fixed-request-001" and
  .endpoint == $endpoint and
  .body.max_tokens == 1024 and
  .body.stream == false and
  .body.response_format.type == "json_schema" and
  .body.response_format.json_schema.strict == true and
  (.body.response_format.json_schema.schema.required | sort) == ["answer","completion_status","evidence_spans","request_id","uncertainty"] and
  .body.response_format.json_schema.schema.additionalProperties == false
' "$template_file" >/dev/null 2>&1
}

validate_template "$Q_TEMPLATE_FILE" "http://127.0.0.1:1234/v1/chat/completions" || fail "qwen fixed request/schema contract"
validate_template "$N_TEMPLATE_FILE" "http://127.0.0.1:1235/v1/chat/completions" || fail "nemotron fixed request/schema contract"

qwen_id=$(jq -r '.profiles[] | select(.alias == "qwen-local") | .id' "$CONFIG_FILE")
nemotron_id=$(jq -r '.profiles[] | select(.alias == "nemotron-local") | .id' "$CONFIG_FILE")
[ -n "$qwen_id" ] || fail "missing qwen profile"
[ -n "$nemotron_id" ] || fail "missing nemotron profile"

jq -e --arg model "$qwen_id" '.schema == "miter-prepared-model-request-v1" and .request_id == "g04-fixed-request-001" and .alias == "qwen-local" and .endpoint == "http://127.0.0.1:1234/v1/chat/completions" and .body.model == $model' "$Q_REQUEST_FILE" >/dev/null 2>&1 || fail "qwen prepared request"
jq -e --arg model "$nemotron_id" '.schema == "miter-prepared-model-request-v1" and .request_id == "g04-fixed-request-001" and .alias == "nemotron-local" and .endpoint == "http://127.0.0.1:1235/v1/chat/completions" and .body.model == $model' "$N_REQUEST_FILE" >/dev/null 2>&1 || fail "nemotron prepared request"

q_body=$(mktemp "${TMPDIR:-/tmp}/miter-g04-q-body.XXXXXX") || exit 1
n_body=$(mktemp "${TMPDIR:-/tmp}/miter-g04-n-body.XXXXXX") || exit 1
clean_stdout=$(mktemp "${TMPDIR:-/tmp}/miter-g04-stdout.XXXXXX") || exit 1
q_template_body=$(mktemp "${TMPDIR:-/tmp}/miter-g04-q-template.XXXXXX") || exit 1
n_template_body=$(mktemp "${TMPDIR:-/tmp}/miter-g04-n-template.XXXXXX") || exit 1
trap 'rm -f "$q_body" "$n_body" "$clean_stdout" "$q_template_body" "$n_template_body"' EXIT HUP INT TERM
jq -S '.body | del(.model)' "$Q_REQUEST_FILE" > "$q_body"
jq -S '.body | del(.model)' "$N_REQUEST_FILE" > "$n_body"
cmp -s "$q_body" "$n_body" || fail "model requests differ beyond exact model ID"
jq -S '.body' "$Q_TEMPLATE_FILE" > "$q_template_body"
jq -S '.body' "$N_TEMPLATE_FILE" > "$n_template_body"
cmp -s "$q_template_body" "$n_template_body" || fail "fixture bodies differ"

validate_product() {
  typed_file=$1
  jq -e '
    (keys | sort) == ["answer","completion_status","evidence_spans","request_id","uncertainty"] and
    .request_id == "g04-fixed-request-001" and
    (.answer | type == "string" and length >= 1 and length <= 240) and
    (.uncertainty | type == "number" and . >= 0 and . <= 1) and
    (.evidence_spans | type == "array" and length >= 1 and length <= 3) and
    all(.evidence_spans[]; type == "string" and length >= 1 and length <= 160) and
    (.completion_status == "complete" or .completion_status == "insufficient_evidence")
  ' "$typed_file" >/dev/null 2>&1
}

validate_provider() {
  raw_file=$1
  expected_model=$2
  jq -e --arg model "$expected_model" '
    .model == $model and
    .choices[0].finish_reason == "stop" and
    (.choices[0].message.content | type == "string" and length > 0) and
    (.choices[0].message.content | fromjson | type == "object")
  ' "$raw_file" >/dev/null 2>&1
}

validate_product "$Q_TYPED_FILE" || fail "qwen typed product"
validate_product "$N_TYPED_FILE" || fail "nemotron typed product"
validate_provider "$Q_RAW_FILE" "$qwen_id" || fail "qwen provider envelope"
validate_provider "$N_RAW_FILE" "$nemotron_id" || fail "nemotron provider envelope"
jq -e --slurpfile typed "$Q_TYPED_FILE" '(.choices[0].message.content | fromjson) == $typed[0]' "$Q_RAW_FILE" >/dev/null 2>&1 || fail "qwen raw/typed separation"
jq -e --slurpfile typed "$N_TYPED_FILE" '(.choices[0].message.content | fromjson) == $typed[0]' "$N_RAW_FILE" >/dev/null 2>&1 || fail "nemotron raw/typed separation"

jq -e --arg model "$qwen_id" '.schema == "miter-model-timing-v1" and .request_id == "g04-fixed-request-001" and .model == $model and .http_status == 200 and .duration_ms > 0' "$Q_TIMING_FILE" >/dev/null 2>&1 || fail "qwen timing"
jq -e --arg model "$nemotron_id" '.schema == "miter-model-timing-v1" and .request_id == "g04-fixed-request-001" and .model == $model and .http_status == 200 and .duration_ms > 0' "$N_TIMING_FILE" >/dev/null 2>&1 || fail "nemotron timing"

[ "$Q_RAW_FILE" != "$Q_TYPED_FILE" ] || fail "qwen raw/typed path collision"
[ "$N_RAW_FILE" != "$N_TYPED_FILE" ] || fail "nemotron raw/typed path collision"
[ "$(shasum -a 256 "$Q_RAW_FILE" | awk '{print $1}')" != "$(shasum -a 256 "$Q_TYPED_FILE" | awk '{print $1}')" ] || fail "qwen raw/typed content collision"
[ "$(shasum -a 256 "$N_RAW_FILE" | awk '{print $1}')" != "$(shasum -a 256 "$N_TYPED_FILE" | awk '{print $1}')" ] || fail "nemotron raw/typed content collision"

jq -e '(.choices[0].message.content | fromjson) as $product | (($product.uncertainty | type) != "number") and ($product | has("completion_status") | not)' "$MALFORMED_FILE" >/dev/null 2>&1 || fail "malformed control is not discriminating"

escape_character=$(printf '\033')
sed "s/${escape_character}\\[[0-9;]*m//g" "$STDOUT_FILE" | tr -d '\r' > "$clean_stdout"
[ "$(awk '$0 == "model-request-prepared" { count++ } END { print count+0 }' "$clean_stdout")" = "2" ] || fail "prepared request success count"
[ "$(awk '$0 == "raw-model-response-stored" { count++ } END { print count+0 }' "$clean_stdout")" = "2" ] || fail "raw response success count"
[ "$(awk '$0 == "semantic-result-admitted" { count++ } END { print count+0 }' "$clean_stdout")" = "2" ] || fail "semantic admission count"
[ "$(awk '$0 == "malformed-model-response" { count++ } END { print count+0 }' "$clean_stdout")" = "1" ] || fail "malformed rejection count"
semantic_line=$(awk '/^\(\(semantic-result / { value=$0 } END { print value }' "$clean_stdout")
printf '%s\n' "$semantic_line" | rg -q 'semantic-result g04-fixed-request-001 qwen-local validated' || fail "qwen semantic atom"
printf '%s\n' "$semantic_line" | rg -q 'semantic-result g04-fixed-request-001 nemotron-local validated' || fail "nemotron semantic atom"
if printf '%s\n' "$semantic_line" | rg -q 'malformed'; then fail "malformed semantic atom"; fi
[ "$(printf '%s\n' "$semantic_line" | awk '{ text=$0; count=0; while (match(text, /semantic-result/)) { count++; text=substr(text, RSTART+RLENGTH) } print count }')" = "2" ] || fail "semantic atom cardinality"

rg -q '[[:space:]]swipl$' "$PROCESS_TREE_FILE" || fail "missing native swipl process"
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$PROCESS_TREE_FILE"; then fail "Python process in Miter request tree"; fi
if rg -q -i 'sread|read_term|atom_to_term|process_metta_string|load_files' effect_membranes/miter_llm.pl tests/fixtures/g04_schema_inference.metta; then fail "provider output evaluation surface"; fi

cmp -s "$CONFIG_BEFORE_FILE" "$CONFIG_AFTER_FILE" || fail "local model config drift"
cmp -s "$PROTECTED_BEFORE_FILE" "$PROTECTED_AFTER_FILE" || fail "protected document drift"

if [ -z "$failure" ]; then
  qwen_ms=$(jq -r '.duration_ms' "$Q_TIMING_FILE")
  nemotron_ms=$(jq -r '.duration_ms' "$N_TIMING_FILE")
  printf '{"verifier":"g04-verifier-v1","status":"PASS","models":2,"semantic_atoms":2,"malformed_atoms":0,"missing_or_malformed_rejected":true,"request_id_round_trip":true,"raw_typed_separate":true,"provider_output_evaluated":false,"python_process":false,"qwen_duration_ms":%s,"nemotron_duration_ms":%s}\n' "$qwen_ms" "$nemotron_ms"
  exit 0
fi

printf '{"verifier":"g04-verifier-v1","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
