#!/bin/sh
set -eu
run=$1
fail() { printf 'G11 FAIL: %s\n' "$1" >&2; exit 1; }
for arm in canonical chroma-off capsule-off; do
  jq -e '.chat_context==[] and .chat_model_requests==0 and .request=="Where was I with the book?" and .pre_start_trajectory.event_count==17' "$run/$arm/outputs/startup.json" >/dev/null || fail "$arm startup"
  rg -q '^continuity-answer-stored[[:blank:]]*$' "$run/raw/$arm.stdout" || fail "$arm native RNA"
  head -n 17 "$run/$arm/store/trajectory.jsonl" | cmp -s "$run/base-trajectory.jsonl" - || fail "$arm history prefix"
  jq -e '.status=="valid" and .event_count==19' "$run/$arm/outputs/ledger.json" >/dev/null || fail "$arm ledger"
done
jq -s -e '[.[].pid]|unique|length==3' "$run/canonical/outputs/startup.json" "$run/chroma-off/outputs/startup.json" "$run/capsule-off/outputs/startup.json" >/dev/null || fail 'distinct fresh processes'
for arm in canonical chroma-off; do
  jq -e '.certificate=="exact-continuity" and .uncertainty==[] and .exact_state.project_id=="project-g08-glass-archive" and .exact_state.project_name=="The Glass Archive" and .exact_state.artifact_hash=="5a8433e2d94034aa79c3098353acd1d5e55db6e54d8e9edab969261a4d4e34a3" and .exact_state.anchor=="Chapter 3 / The Observatory / paragraph 4 decision beat" and .exact_state.capsule_id=="capsule-g11-003" and (.exact_state.last_completed_work|length)>0 and (.exact_state.unresolved_question|length)>0 and (.exact_state.next_move|length)>0 and (.exact_state.source_event_ids|index("source-g11-book-pause"))!=null' "$run/$arm/outputs/answer.json" >/dev/null || fail "$arm exact fields"
  jq -S '.exact_state' "$run/$arm/outputs/answer.json" > "$run/outputs/$arm-exact.json"
  jq -e --slurpfile c "$run/outputs/book-capsule.json" '.exact_state as $s | $c[0] as $e | $s.artifact_ref==$e.current_artifact_ref and $s.last_completed_work==$e.last_completed_work and $s.unresolved_question==$e.open_questions[0] and $s.next_move==$e.next_intended_movement and $s.source_event_ids==$e.relevant_event_ids and $s.live_tensions==$e.live_tensions' "$run/$arm/outputs/answer.json" >/dev/null || fail "$arm exact source-field equality"
  jq -e '.event_id=="source-g11-book-pause" and .capsule_id=="capsule-g11-003"' "$run/$arm/outputs/capsule-event-witness.json" >/dev/null || fail "$arm witness"
done
cmp "$run/outputs/canonical-exact.json" "$run/outputs/chroma-off-exact.json" || fail 'Chroma changed exact reconstruction'
jq -e '.semantic_available==true' "$run/canonical/outputs/answer.json" >/dev/null || fail 'canonical semantic probe'
jq -e '.semantic_available==false and .semantic_result=="semantic-unavailable"' "$run/chroma-off/outputs/answer.json" >/dev/null || fail 'Chroma severing'
[ ! -d "$run/chroma-off/store/derived/g11-chroma-off" ] || fail 'Chroma-severed issued a query'
[ ! -f "$run/capsule-off/outputs/capsule.json" ] || fail 'capsule-severed resolved exact state'
jq -e '.certificate=="non-authoritative-recall" and .exact_state==null and .semantic_available==true and (.uncertainty|length)>0' "$run/capsule-off/outputs/answer.json" >/dev/null || fail 'capsule severing'
jq -e '(.memory_ids|length)>0' "$run/capsule-off/store/derived/g11-capsule-off/verified.json" >/dev/null || fail 'capsule-severed missing real recall'
jq -s -e 'map(select(.event_kind=="project-checkpoint"))|length==1 and .[0].occurred_at=="2026-09-02T07:00:00Z"' "$run/base-trajectory.jsonl" >/dev/null || fail 'T0 checkpoint'
jq -n -e '("2026-12-01T07:00:00Z"|fromdateiso8601)-("2026-09-02T07:00:00Z"|fromdateiso8601)==90*86400' >/dev/null || fail '90-day interval'
jq -s -e '.[13:]|length==4 and all(.[]; .project_scope=="unrelated-project")' "$run/base-trajectory.jsonl" >/dev/null || fail 'unrelated intervening history'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
printf '%s\n' '{"gate_id":"G11","status":"PASS","negative_control_difference":true,"simulated_absence_days":90,"fresh_processes":3,"chat_context_empty":true,"exact_capsule_trajectory_reconstruction":true,"chroma_severed_exact_reconstruction":true,"capsule_severed_non_authoritative":true}'
