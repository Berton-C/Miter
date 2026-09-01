#!/bin/sh
set -u

RUN_DIR=evidence/20260901T192747Z-G04
failure=""

fail() {
  if [ -z "$failure" ]; then
    failure=$1
  else
    failure="$failure; $1"
  fi
}

jq -e '. == true' "$RUN_DIR/inputs/g03_prerequisite_verifier.json" >/dev/null 2>&1 || fail "G03 prerequisite"
grep -Fxq 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d' "$RUN_DIR/environment/petta_commit.txt" || fail "PeTTa pin"
grep -Fq 'SWI-Prolog version 10.0.2 for arm64-darwin' "$RUN_DIR/environment/swipl_version.txt" || fail "native SWI"

[ "$(tr -d '\r\n ' < "$RUN_DIR/raw/petta_fixture.status")" = "0" ] || fail "PeTTa fixture status"
[ "$(tr -d '\r\n ' < "$RUN_DIR/outputs/g04_verifier.status")" = "0" ] || fail "G04 verifier status"
jq -e '
  .status == "PASS" and
  .models == 2 and
  .semantic_atoms == 2 and
  .malformed_atoms == 0 and
  .missing_or_malformed_rejected == true and
  .request_id_round_trip == true and
  .raw_typed_separate == true and
  .provider_output_evaluated == false and
  .python_process == false
' "$RUN_DIR/outputs/g04_verifier.json" >/dev/null 2>&1 || fail "G04 acceptance verdict"

grep -Fq 'semantic-result g04-fixed-request-001 qwen-local validated' "$RUN_DIR/raw/petta_fixture.stdout" || fail "Qwen semantic atom"
grep -Fq 'semantic-result g04-fixed-request-001 nemotron-local validated' "$RUN_DIR/raw/petta_fixture.stdout" || fail "Nemotron semantic atom"
grep -Fxq '[malformed-model-response]' "$RUN_DIR/raw/direct_negative_parse.stdout" || fail "malformed rejection"
grep -Fxq 'deterministic_true' "$RUN_DIR/raw/direct_negative_parse.stdout" || fail "negative determinism"

jq -e '.request_id == "g04-fixed-request-001" and .completion_status == "complete"' "$RUN_DIR/outputs/typed/qwen.json" >/dev/null 2>&1 || fail "Qwen typed product"
jq -e '.request_id == "g04-fixed-request-001" and .completion_status == "complete"' "$RUN_DIR/outputs/typed/nemotron.json" >/dev/null 2>&1 || fail "Nemotron typed product"
jq -e '.http_status == 200 and .duration_ms > 0' "$RUN_DIR/services/timing/qwen.json" >/dev/null 2>&1 || fail "Qwen timing"
jq -e '.http_status == 200 and .duration_ms > 0' "$RUN_DIR/services/timing/nemotron.json" >/dev/null 2>&1 || fail "Nemotron timing"

cmp -s "$RUN_DIR/hashes/local_model_config_before.sha256" "$RUN_DIR/hashes/local_model_config_after.sha256" || fail "local model config drift"
cmp -s "$RUN_DIR/hashes/protected_documents_before.sha256" "$RUN_DIR/hashes/protected_documents_after.sha256" || fail "protected document drift"
rg -q '[[:space:]]swipl$' "$RUN_DIR/process/process_tree_unique_safe.txt" || fail "SWI process evidence"
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$RUN_DIR/process/process_tree_unique_safe.txt"; then
  fail "Python request process"
fi
if rg -q -i 'sread|read_term|atom_to_term|process_metta_string|load_files' effect_membranes/miter_llm.pl tests/fixtures/g04_schema_inference.metta; then
  fail "provider evaluation surface"
fi

grep -Fq 'llama.cpp-mac-arm64-apple-metal-advsimd@2.32.0' "$RUN_DIR/environment/lmstudio_runtimes_final.txt" || fail "2.32 runtime evidence"
awk '$1 ~ /llama.cpp-mac-arm64-apple-metal-advsimd@2.28.2/ && $2 == "✓" { found=1 } END { exit(found ? 0 : 1) }' "$RUN_DIR/environment/lmstudio_runtimes_restored.txt" || fail "original runtime restoration"
[ "$(tr -d '\r\n ' < "$RUN_DIR/services/nemotron_cpu_service_stopped.status")" != "0" ] || fail "bounded Nemotron service still listening"

git check-ignore -q config/local/g03-model-profiles.json || fail "local model config not ignored"
git check-ignore -q runtime/g04/qwen.raw.json || fail "runtime product not ignored"

if [ -z "$failure" ]; then
  printf '%s\n' '{"gate":"G04","status":"PASS","models":2,"semantic_atoms":2,"malformed_atoms":0,"request_id_round_trip":true,"raw_typed_separate":true,"provider_output_evaluated":false,"python_process":false,"protected_documents_unchanged":true,"local_config_unchanged":true,"external_service_restored":true}'
  exit 0
fi

printf '{"gate":"G04","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
