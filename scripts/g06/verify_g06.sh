#!/bin/sh
set -eu

if [ "$#" -ne 13 ]; then
  printf '%s\n' 'usage: verify_g06.sh PROFILE SUMMARY META1 META2 NEGATIVE CATALOG PROTECTED_BEFORE PROTECTED_AFTER LOCAL_BEFORE LOCAL_AFTER PROCESS_SAMPLE PETTA_STDOUT PETTA_STATUS' >&2
  exit 64
fi

PROFILE=$1
SUMMARY=$2
META_ONE=$3
META_TWO=$4
NEGATIVE=$5
CATALOG=$6
PROTECTED_BEFORE=$7
PROTECTED_AFTER=$8
LOCAL_BEFORE=$9
LOCAL_AFTER=${10}
PROCESS_SAMPLE=${11}
PETTA_STDOUT=${12}
PETTA_STATUS=${13}

failure=''
fail() { if [ -z "$failure" ]; then failure=$1; else failure="$failure; $1"; fi; }

jq -e '.schema == "miter-embedding-profile-v1" and .profile_id == "embedding-local" and .model_id == "text-embedding-nomic-embed-text-v1.5" and .dimension == 768 and .normalization.policy == "provider-l2-unit" and .chunking.version == "miter-chunk-v1" and .distance_metric == "cosine" and .collection_schema_version == "miter-ltm-v1" and .status == "pinned"' "$PROFILE" >/dev/null || fail 'embedding profile contract'
jq -e '.schema == "miter-g06-run-summary-v1" and .first_result == "embedding-vector-stored" and .second_result == "embedding-vector-stored" and .dimension == 768 and .deterministic == true and .input_hashes_equal == true and .service_requests == 2 and .chroma_requests == 0' "$SUMMARY" >/dev/null || fail 'deterministic run summary'
jq -e '.schema == "miter-embedding-vector-metadata-v1" and .profile_id == "embedding-local" and .dimension == 768 and .normalization.policy == "provider-l2-unit" and ((.normalization.observed_l2_norm - 1) | fabs) <= .normalization.tolerance and .distance_metric == "cosine"' "$META_ONE" >/dev/null || fail 'first vector metadata'
jq -e '.schema == "miter-embedding-vector-metadata-v1" and .profile_id == "embedding-local" and .dimension == 768 and .normalization.policy == "provider-l2-unit" and ((.normalization.observed_l2_norm - 1) | fabs) <= .normalization.tolerance and .distance_metric == "cosine"' "$META_TWO" >/dev/null || fail 'second vector metadata'
[ "$(jq -r '.vector_sha256' "$META_ONE")" = "$(jq -r '.vector_sha256' "$META_TWO")" ] || fail 'vector checksum instability'
[ "$(jq -r '.input_sha256' "$META_ONE")" = "$(jq -r '.input_sha256' "$META_TWO")" ] || fail 'input checksum instability'
jq -e '.schema == "miter-g06-negative-control-v1" and .expected_dimension == 767 and .observed_dimension == 768 and .result == "embedding-dimension-mismatch" and .rejected_before_chroma_insertion == true and .chroma_requests == 0' "$NEGATIVE" >/dev/null || fail 'wrong-dimension fail-closed control'
jq -e 'any(.data[]; .id == "text-embedding-nomic-embed-text-v1.5" and .type == "embeddings")' "$CATALOG" >/dev/null || fail 'embedding model absent from service catalog'
cmp -s "$PROTECTED_BEFORE" "$PROTECTED_AFTER" || fail 'protected document drift'
cmp -s "$LOCAL_BEFORE" "$LOCAL_AFTER" || fail 'local model profile drift'
rg -q '([[:space:]]|/)swipl([[:space:]]|$)' "$PROCESS_SAMPLE" || fail 'missing SWI process evidence'
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$PROCESS_SAMPLE"; then fail 'Python in embedding path'; fi
if rg -q -i '/collections|/add|/upsert|/delete' effect_membranes/miter_chroma.pl scripts/g06/run_embedding_profile.pl; then fail 'Chroma mutation surface present before G09'; fi
if rg -q -i 'sread|read_term|atom_to_term|process_metta_string|load_files' effect_membranes/miter_chroma.pl tests/fixtures/g06_embedding_profile.metta; then fail 'provider evaluation surface'; fi
[ "$(tr -d '\r\n ' < "$PETTA_STATUS")" = "0" ] || fail 'PeTTa fixture exit'
rg -q '^embedding-vector-stored$' "$PETTA_STDOUT" || fail 'PeTTa embedding result'
rg -q '^embedding-dimension-mismatch$' "$PETTA_STDOUT" || fail 'PeTTa negative result'

if [ -z "$failure" ]; then
  printf '%s\n' '{"gate":"G06","status":"PASS","profile":"embedding-local","model_id":"text-embedding-nomic-embed-text-v1.5","dimension":768,"normalization":"provider-l2-unit","chunking_version":"miter-chunk-v1","distance_metric":"cosine","deterministic":true,"petta_boundary":true,"wrong_dimension":"rejected_before_chroma_insertion","chroma_requests":0,"python_process":false,"protected_documents_unchanged":true}'
  exit 0
fi

printf '{"gate":"G06","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
