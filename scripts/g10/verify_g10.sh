#!/bin/sh
set -eu
run=$1
store="$run/store"
fail() { printf 'G10 FAIL: %s\n' "$1" >&2; exit 1; }
[ "$(rg -c '^memory-admitted[[:blank:]]*$' "$run/raw/admit.stdout")" -eq 3 ] || fail admission
rg -q '^memory-rejected[[:blank:]]*$' "$run/raw/admit.stdout" || fail rejection
[ "$(rg -c '^memory-indexed[[:blank:]]*$' "$run/raw/index.stdout")" -eq 3 ] || fail indexing
[ "$(rg -c '^memory-query-verified[[:blank:]]*$' "$run/raw/recall.stdout")" -eq 5 ] || fail recall
[ ! -f "$store/memories/mem-g10-transient.json" ] || fail 'transient stored'
jq -e '.details.ids|sort==["mem-g10-checkpoint","mem-g10-pref-new","mem-g10-pref-old"]' "$run/outputs/chroma-records.json" >/dev/null || fail 'index IDs'
jq -e 'all(.details.metadatas[]; .embedding_dimension==768 and .embedding_model_id=="text-embedding-nomic-embed-text-v1.5" and .normalization=="provider-l2-unit" and .chunking_version=="miter-chunk-v1" and .distance_metric=="cosine" and (.content_hash|length)==64 and (.source_event_ids|length)>0)' "$run/outputs/chroma-records.json" >/dev/null || fail metadata
jq -e '.details.metadatas[]|select(.memory_id=="mem-g10-pref-old")|.standing=="superseded"' "$run/outputs/chroma-records.json" >/dev/null || fail supersession
jq -e '.results.ids[0]|index("mem-g10-checkpoint")!=null' "$store/derived/g10-book-query/verified.json" >/dev/null || fail 'checkpoint paraphrase'
jq -e '.results.ids[0][0]=="mem-g10-pref-new" and ([.results.metadatas[0][].standing]|all(.=="active"))' "$store/derived/g10-preference-query/verified.json" >/dev/null || fail 'current preference'
jq -e '.results.ids==[["mem-g10-pref-old"]] and .results.metadatas[0][0].standing=="superseded"' "$store/derived/g10-history-query/verified.json" >/dev/null || fail history
jq -e '.results.ids[0][0]=="mem-g10-pref-new" and (.results.distances[0][0]|fabs)<0.00001' "$store/derived/g10-exact-authorized/verified.json" >/dev/null || fail 'closest positive'
jq -e '.results.ids==[[]] and .principal_scope=="principal:g10-other"' "$store/derived/g10-exact-unauthorized/verified.json" >/dev/null || fail 'scope negative'
jq -e '.where["$and"]|length==4 and .[0].principal_scope["$eq"]=="principal:g10-other" and .[1].audience_scope["$eq"]=="scope:g10-other-private"' "$store/derived/g10-exact-unauthorized/query-request.json" >/dev/null || fail 'pre-ranking scope'
for arm in authorized unauthorized; do
  jq -c '.data[0].embedding' "$store/derived/g10-exact-$arm/embedding.json" > "$run/outputs/$arm-vector.json"
done
cmp "$run/outputs/authorized-vector.json" "$run/outputs/unauthorized-vector.json" || fail 'nonidentical negative vector'
jq -e '.status=="valid" and .event_count==12' "$run/outputs/ledger-verification.json" >/dev/null || fail trajectory
/opt/homebrew/bin/swipl -q -s scripts/g10/verify_records.pl -- "$store" > "$run/outputs/independent-record-verification.txt"
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
cmp "$run/hashes/prior_stores_before.sha256" "$run/hashes/prior_stores_after.sha256" || fail 'prior history changed'
cmp "$run/hashes/memories_before_reindex.sha256" "$run/hashes/memories_after_reindex.sha256" || fail 'memory mutated by indexing'
if rg -n 'py-call|janus|process_create|shell\(' effect_membranes/miter_memory.pl src/memory.metta; then fail 'forbidden core seam'; fi
printf '%s\n' '{"gate_id":"G10","status":"PASS","negative_control_difference":true,"admitted":3,"rejected":1,"indexed":3,"source_event_count":12,"scope_filter_before_ranking":true,"superseded_history_retained":true,"canonical_records_unchanged_by_reindex":true}'
