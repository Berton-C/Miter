#!/bin/sh
set -eu
run=$1
fail() { printf 'G12 FAIL: %s\n' "$1" >&2; exit 1; }
jq -e '.result=="chroma-disposable-collection-deleted"' "$run/outputs/deleted.json" >/dev/null || fail deletion
jq -e '.result=="chroma-collections-listed" and .details.collections==[]' "$run/outputs/empty-collections.json" >/dev/null || fail 'separate absence read'
jq -e '.status=="valid" and .event_count==12' "$run/outputs/ledger-without-chroma.json" >/dev/null || fail 'canonical ledger after loss'
jq -e '.status=="reconstructed" and .current_capsule_id=="capsule-g08-002"' "$run/outputs/capsule-without-chroma.json" >/dev/null || fail 'local capsule after loss'
jq -s -e '.[0].details.collection.id!=.[1].details.id and .[0].details.collection.metadata==.[1].details.metadata' "$run/outputs/before-collection.json" "$run/outputs/recreated.json" >/dev/null || fail 'new instance, same logical profile'
for phase in before rebuilt after-negative; do
  jq -S '.details as $d | [range(0;($d.ids|length)) as $i | {id:$d.ids[$i],document:$d.documents[$i],metadata:$d.metadatas[$i]}] | sort_by(.id)' "$run/outputs/$phase-records.json" > "$run/outputs/$phase-canonical-records.json"
done
jq -e 'length==3 and map(.id)==["mem-g10-checkpoint","mem-g10-pref-new","mem-g10-pref-old"]' "$run/outputs/rebuilt-canonical-records.json" >/dev/null || fail 'rebuilt IDs/count'
cmp "$run/outputs/before-canonical-records.json" "$run/outputs/rebuilt-canonical-records.json" || fail 'document or metadata drift'
cmp "$run/outputs/rebuilt-canonical-records.json" "$run/outputs/after-negative-canonical-records.json" || fail 'negative changed good collection'
for tag in g10-book-query g10-preference-query g10-history-query g10-exact-authorized g10-exact-unauthorized; do
  jq -s -e '.[0] as $a | .[1] as $b | $a.results.ids==$b.results.ids and $a.results.metadatas==$b.results.metadatas and $a.results.documents==$b.results.documents and ([range(0;($a.results.distances[0]|length)) as $i | (($a.results.distances[0][$i]-$b.results.distances[0][$i])|fabs)<=0.000001] | all)' "$run/before-queries/$tag.json" "$run/after-queries/$tag.json" >/dev/null || fail "$tag query tolerance"
done
rg -q '^semantic-index-rebuilt[[:blank:]]*$' "$run/raw/rebuild.stdout" || fail 'native rebuild'
rg -q '^memory-integrity-failed[[:blank:]]*$' "$run/raw/corrupt.stdout" || fail 'corruption rejection'
jq -e '.http_requests_observed==0' "$run/outputs/corrupt-transport.json" >/dev/null || fail 'corrupt preflight issued HTTP'
cmp "$run/hashes/canonical_before.sha256" "$run/hashes/canonical_after.sha256" || fail 'canonical data modified'
cmp "$run/hashes/corrupt_before.sha256" "$run/hashes/corrupt_after.sha256" || fail 'corrupt item silently repaired'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
shasum -a 256 "$run/outputs/before-canonical-records.json" "$run/outputs/rebuilt-canonical-records.json" "$run/outputs/after-negative-canonical-records.json" > "$run/outputs/record-manifest-hashes.txt"
printf '%s\n' '{"gate_id":"G12","status":"PASS","negative_control_difference":true,"rebuilt_records":3,"fixed_queries":5,"absolute_distance_tolerance":0.000001,"ids_bodies_metadata_identical":true,"canonical_sources_unchanged":true,"corrupt_copy_rejected_before_http":true}'
