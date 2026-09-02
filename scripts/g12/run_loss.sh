#!/bin/sh
set -eu
cd /Users/claritymiter/miter
run=evidence/20260902T064155Z-G12
transport() { /opt/homebrew/bin/swipl -q -s scripts/g12/transport.pl -- "$@"; }
jq -e '.details.count==3 and .details.collection.name=="miter-ltm-v1"' runtime/g12/before-collection.json >/dev/null
jq -e '.details.ids|sort==["mem-g10-checkpoint","mem-g10-pref-new","mem-g10-pref-old"]' runtime/g12/before-records.json >/dev/null
transport runtime/g12/delete-request.json runtime/g12/deleted.json chroma-disposable-collection-deleted
transport runtime/g12/list-request.json runtime/g12/empty-collections.json chroma-collections-listed
jq -e '.details.collections==[]' runtime/g12/empty-collections.json >/dev/null
/opt/homebrew/bin/swipl -q -s effect_membranes/miter_resume.pl -g "miter_store_verify_ledger('runtime/g10/store','runtime/g12/ledger-without-chroma.json',L),miter_continuity_reconstruct('runtime/g08/continuity','project-g08-glass-archive','runtime/g12/capsule-without-chroma.json',C),writeln(L-C),halt."
transport tests/fixtures/g09_create.json runtime/g12/recreated.json chroma-collection-created
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g12_rebuild.metta > "$run/raw/rebuild.stdout" 2> "$run/raw/rebuild.stderr"
transport runtime/g10/get-request.json runtime/g12/rebuilt-records.json chroma-records-stored
sh /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g10_recall.metta > "$run/raw/after-query.stdout" 2> "$run/raw/after-query.stderr"
mkdir -p "$run/after-queries"
for tag in g10-book-query g10-preference-query g10-history-query g10-exact-authorized g10-exact-unauthorized; do
  cp "runtime/g10/store/derived/$tag/verified.json" "$run/after-queries/$tag.json"
done
sh -x /private/tmp/miter-g06-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/g12_corrupt.metta > "$run/raw/corrupt.stdout" 2> "$run/raw/corrupt.stderr"
transport runtime/g10/get-request.json runtime/g12/after-negative-records.json chroma-records-stored
