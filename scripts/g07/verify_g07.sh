#!/bin/sh
set -eu

if [ "$#" -ne 15 ]; then
  printf '%s\n' 'usage: verify_g07.sh BEFORE AFTER FINAL REPORT_BEFORE REPORT_FINAL READBACK_BEFORE READBACK_FINAL MUTATION NEGATIVE_REPORT APPEND_STDOUT FORK_STDOUT RESTART_STDOUT PROTECTED_BEFORE PROTECTED_AFTER PROCESS_TRACE' >&2
  exit 64
fi

BEFORE=$1
AFTER=$2
FINAL=$3
REPORT_BEFORE=$4
REPORT_FINAL=$5
READBACK_BEFORE=$6
READBACK_FINAL=$7
MUTATION=$8
NEGATIVE_REPORT=$9
APPEND_STDOUT=${10}
FORK_STDOUT=${11}
RESTART_STDOUT=${12}
PROTECTED_BEFORE=${13}
PROTECTED_AFTER=${14}
PROCESS_TRACE=${15}

failure=''
fail() { if [ -z "$failure" ]; then failure=$1; else failure="$failure; $1"; fi; }

[ "$(wc -l < "$BEFORE" | tr -d ' ')" = "3" ] || fail 'pre-fork event count'
[ "$(wc -l < "$AFTER" | tr -d ' ')" = "4" ] || fail 'post-fork event count'
before_bytes=$(wc -c < "$BEFORE" | tr -d ' ')
if head -c "$before_bytes" "$AFTER" | cmp -s "$BEFORE" -; then :; else fail 'existing lines changed during fork append'; fi
cmp -s "$AFTER" "$FINAL" || fail 'ledger changed during restart readback'
jq -s -e 'length == 3 and ([.[].local_sequence] == [1,2,3]) and (.[0].parent_event_ids == []) and (.[1].parent_event_ids == ["evt-g07-contact-0001"]) and (.[2].parent_event_ids == ["evt-g07-internal-movement-0002"]) and all(.[]; (.event_hash|length)==64 and (.payload_hash|length)==64)' "$BEFORE" >/dev/null || fail 'pre-fork envelope/lineage contract'
jq -s -e 'length == 4 and .[3].local_sequence == 4 and .[3].event_kind == "development-opportunity" and .[3].parent_event_ids == ["evt-g07-internal-movement-0002"] and all(.[]; (.event_hash|length)==64 and (.payload_hash|length)==64)' "$AFTER" >/dev/null || fail 'fork envelope/lineage contract'
jq -e '.status == "valid" and .event_count == 3 and .validated_prefix == 3' "$REPORT_BEFORE" >/dev/null || fail 'pre-fork integrity report'
jq -e '.status == "valid" and .event_count == 4 and .validated_prefix == 4' "$REPORT_FINAL" >/dev/null || fail 'final integrity report'
jq -e '.schema == "miter-trajectory-readback-v1" and .event_count == 3 and ([.events[].local_sequence] == [1,2,3])' "$READBACK_BEFORE" >/dev/null || fail 'restart readback before fork'
jq -e '.schema == "miter-trajectory-readback-v1" and .event_count == 4 and ([.events[].local_sequence] == [1,2,3,4])' "$READBACK_FINAL" >/dev/null || fail 'restart readback after fork'
jq -e '.schema == "miter-g07-ledger-mutation-v1" and .modified_line == 2 and .hashes_differ == true and .original_line_sha256 != .mutated_line_sha256' "$MUTATION" >/dev/null || fail 'negative mutation record'
jq -e '.status == "invalid" and .first_broken_sequence == 2 and .first_broken_event_id == "evt-g07-internal-movement-0002" and .failure_code == "event-hash-mismatch" and .later_lines_preserved == 2' "$NEGATIVE_REPORT" >/dev/null || fail 'first broken hash identification'
rg -q '^event-appended$' "$APPEND_STDOUT" || fail 'initial append results'
[ "$(rg -c '^event-appended$' "$APPEND_STDOUT")" = "3" ] || fail 'initial append cardinality'
rg -q '^trajectory-valid$' "$FORK_STDOUT" || fail 'restart verification before fork'
rg -q '^trajectory-readback-stored$' "$FORK_STDOUT" || fail 'restart readback before fork result'
rg -q '^event-appended$' "$FORK_STDOUT" || fail 'fork append result'
rg -q '^trajectory-valid$' "$RESTART_STDOUT" || fail 'final restart verification'
rg -q '^trajectory-readback-stored$' "$RESTART_STDOUT" || fail 'final restart readback result'
cmp -s "$PROTECTED_BEFORE" "$PROTECTED_AFTER" || fail 'protected document drift'
rg -q '([[:space:]]|/)swipl([[:space:]]|$)' "$PROCESS_TRACE" || fail 'missing SWI process evidence'
if rg -q -i '[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' "$PROCESS_TRACE" effect_membranes/miter_store.pl effect_membranes/runtime_extensions/miter_store_posix.c; then fail 'Python in trajectory path'; fi
rg -q 'lock\(write\)' effect_membranes/miter_store.pl || fail 'missing cross-process file lock'
rg -q 'miter_posix_fsync_stream' effect_membranes/miter_store.pl effect_membranes/runtime_extensions/miter_store_posix.c || fail 'missing fsync boundary'
if rg -q -i 'shell\(|process_create|system\(' effect_membranes/miter_store.pl; then fail 'shell workaround in core store'; fi

if [ -z "$failure" ]; then
  printf '%s\n' '{"gate":"G07","status":"PASS","initial_events":3,"fork_events":1,"event_hashes":true,"payload_hashes":true,"sequence":true,"parent_links":true,"byte_identical_prefix":true,"restart_byte_identical":true,"locking":"fcntl-write","durability":"posix-fsync","negative_first_broken_sequence":2,"negative_failure":"event-hash-mismatch","python_process":false,"protected_documents_unchanged":true}'
  exit 0
fi

printf '{"gate":"G07","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
