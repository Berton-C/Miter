#!/bin/sh
set -eu

if [ "$#" -ne 18 ]; then
  printf '%s\n' 'usage: verify_g08.sh PRIOR_BEFORE PRIOR_AFTER CURRENT INDEX RECONSTRUCTION PRIOR_ACCESS INDEXLESS_REPORT NEGATIVE_RECONSTRUCTION PRIOR_STDOUT CURRENT_STDOUT RECONSTRUCT_STDOUT NEGATIVE_STDOUT PROTECTED_BEFORE PROTECTED_AFTER INDEXLESS_PRIOR INDEXLESS_CURRENT G07_BEFORE G07_AFTER' >&2
  exit 64
fi

PRIOR_BEFORE=$1
PRIOR_AFTER=$2
CURRENT=$3
INDEX=$4
RECONSTRUCTION=$5
PRIOR_ACCESS=$6
INDEXLESS_REPORT=$7
NEGATIVE_RECONSTRUCTION=$8
PRIOR_STDOUT=$9
CURRENT_STDOUT=${10}
RECONSTRUCT_STDOUT=${11}
NEGATIVE_STDOUT=${12}
PROTECTED_BEFORE=${13}
PROTECTED_AFTER=${14}
INDEXLESS_PRIOR=${15}
INDEXLESS_CURRENT=${16}
G07_BEFORE=${17}
G07_AFTER=${18}

failure=''
fail() { if [ -z "$failure" ]; then failure=$1; else failure="$failure; $1"; fi; }

cmp -s "$PRIOR_BEFORE" "$PRIOR_AFTER" || fail 'prior capsule was rewritten'
cmp -s "$PRIOR_AFTER" "$INDEXLESS_PRIOR" || fail 'prior capsule changed in indexless copy'
cmp -s "$CURRENT" "$INDEXLESS_CURRENT" || fail 'current capsule changed in indexless copy'
cmp -s "$G07_BEFORE" "$G07_AFTER" || fail 'G07 trajectory changed during continuity gate'
[ "$(shasum -a 256 tests/fixtures/g08_manuscript.md | awk '{print $1}')" = "5a8433e2d94034aa79c3098353acd1d5e55db6e54d8e9edab969261a4d4e34a3" ] || fail 'manuscript byte hash'
jq -e '.schema_version == "miter-project-continuity-v1" and .capsule_id == "capsule-g08-001" and .project_id == "project-g08-glass-archive" and .status == "active" and (.content_hash|length) == 64' "$PRIOR_AFTER" >/dev/null || fail 'prior capsule contract'
jq -e '.schema_version == "miter-project-continuity-v1" and .capsule_id == "capsule-g08-002" and .previous_capsule_id == "capsule-g08-001" and .supersedes_capsule_id == "capsule-g08-001" and .status == "current" and (.content_hash|length) == 64' "$CURRENT" >/dev/null || fail 'current capsule/supersession contract'
jq -e '.schema == "miter-continuity-current-index-v1" and .project_id == "project-g08-glass-archive" and .capsule_id == "capsule-g08-002" and .selected_by == "explicit-metta-decision" and .timestamp_fallback == false' "$INDEX" >/dev/null || fail 'explicit current index'
jq -e '.schema == "miter-continuity-reconstruction-v1" and .status == "reconstructed" and .current_capsule_id == "capsule-g08-002" and .current_artifact_ref == "tests/fixtures/g08_manuscript.md" and .current_artifact_hash == "5a8433e2d94034aa79c3098353acd1d5e55db6e54d8e9edab969261a4d4e34a3" and .exact_location == "Chapter 3 / The Observatory / paragraph 4 decision beat" and .unresolved_question == "Should Mara reveal the archive key to Jonas before the storm breaks?" and .next_intended_movement == "Draft Mara\u0027s decision beat, then test the reveal against chapter-one foreshadowing." and .prior_capsule_id == "capsule-g08-001" and .prior_effective_standing == "superseded" and .prior_capsule_accessible == true and .selection_policy == "explicit-current-index" and .timestamp_fallback == false' "$RECONSTRUCTION" >/dev/null || fail 'exact current-state reconstruction'
jq -e '.schema_version == "miter-project-continuity-v1" and .capsule_id == "capsule-g08-001" and .status == "active" and (.content_hash|length) == 64' "$PRIOR_ACCESS" >/dev/null || fail 'direct prior capsule access'
jq -e '.schema == "miter-g08-indexless-copy-v1" and .removed_pointer == "current.json" and .destination_pointer_exists == false and .capsule_count == 2 and .capsules_retained == true and .timestamp_selection_permitted == false' "$INDEXLESS_REPORT" >/dev/null || fail 'indexless copy contract'
jq -e '.schema == "miter-continuity-reconstruction-v1" and .status == "ambiguous" and .reason == "current-index-missing" and .candidate_count == 2 and ([.candidates[].capsule_id] == ["capsule-g08-001","capsule-g08-002"]) and .selected_capsule_id == null and .selection_policy == "explicit-index-required" and .timestamp_fallback == false' "$NEGATIVE_RECONSTRUCTION" >/dev/null || fail 'indexless ambiguity/no timestamp selection'
rg -q '^capsule-appended$' "$PRIOR_STDOUT" || fail 'prior append result'
rg -q '^capsule-appended$' "$CURRENT_STDOUT" || fail 'current append result'
rg -q '^current-capsule-selected$' "$CURRENT_STDOUT" || fail 'current selection result'
rg -q '^continuity-reconstructed$' "$RECONSTRUCT_STDOUT" || fail 'reconstruction result'
rg -q '^capsule-retrieved$' "$RECONSTRUCT_STDOUT" || fail 'prior access result'
rg -q '^continuity-ambiguous$' "$NEGATIVE_STDOUT" || fail 'negative ambiguity result'
cmp -s "$PROTECTED_BEFORE" "$PROTECTED_AFTER" || fail 'protected document drift'
if rg -q -i 'timestamp.*(max|sort|latest)|created_at.*(max|sort|latest)' effect_membranes/miter_continuity.pl; then fail 'timestamp fallback implementation'; fi
if rg -q -i 'shell\(|process_create|system\(|[[:space:]](python|python3)([[:space:]]|$)|janus|py-call' effect_membranes/miter_continuity.pl src/continuity.metta scripts/g08/make_indexless_copy.pl; then fail 'forbidden core execution path'; fi

if [ -z "$failure" ]; then
  printf '%s\n' '{"gate":"G08","status":"PASS","project_id":"project-g08-glass-archive","capsules":2,"current_capsule":"capsule-g08-002","prior_capsule_accessible":true,"prior_effective_standing":"superseded","prior_bytes_unchanged":true,"artifact_hash_verified":true,"exact_location_recovered":true,"unresolved_question_recovered":true,"next_movement_recovered":true,"indexless_result":"ambiguous","candidate_count":2,"timestamp_fallback":false,"python_process":false,"protected_documents_unchanged":true}'
  exit 0
fi

printf '{"gate":"G08","status":"FAIL","reason":"%s"}\n' "$failure"
exit 1
