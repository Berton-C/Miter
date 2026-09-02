#!/bin/sh
set -eu
run=$1
fail() { printf 'G16 FAIL: %s\n' "$1" >&2; exit 1; }
file_hash() { shasum -a 256 "$1" | cut -d ' ' -f 1; }
for id in boundary technical pivot minimized neutral; do
  n=0
  [ "$id" != boundary ] || n=1
  dir="$run/voices/$id"
  cert="$dir/attempt-$n.certificate.json"
  jq -e --arg id "$id" '.schema=="CertifiedUtterance" and .standing=="certified-utterance" and .intention_id==$id and .surface=="local-test-cli"' "$cert" >/dev/null || fail "$id certificate"
  jq -e '.status=="audit-pass" and .defects==[]' "$dir/attempt-$n.audit.json" >/dev/null || fail "$id audit"
  jq -e --arg id "$id" '.status=="certified" and .certificate.movement_id==$id and .certificate.source_cut==("source-g16-"+$id)' "$dir/attempt-$n.movement.json" >/dev/null || fail "$id movement"
  jq -e '.result=="soul-integrity-verified"' "$dir/attempt-$n.soul-integrity.json" >/dev/null || fail "$id Soul"
  jq -e '.source_provenance=="rendering" and .label=="affective-language-cue" and .permission_effect=="none"' "$dir/attempt-$n.vad.json" >/dev/null || fail "$id VAD provenance"
  jq -e '.http_status==200 and .duration_ms<120000' "$dir/attempt-$n.timing.json" >/dev/null || fail "$id real provider"
  jq -e '.body.reasoning_effort=="none" and .body.temperature==0' "$dir/attempt-$n.request.json" >/dev/null || fail "$id decoding"
  jq -s -e '(.[0].choices[0].message.content|fromjson).clauses==.[1].clauses and .[0].choices[0].finish_reason=="stop"' "$dir/attempt-$n.raw.json" "$dir/attempt-$n.candidate.json" >/dev/null || fail "$id model/candidate match"
  jq -s -e '.[0].text==.[1].text and .[1].text==(.[1].clauses|join("\n\n"))' "$cert" "$dir/attempt-$n.candidate.json" >/dev/null || fail "$id text lineage"
  for pair in "intention.json:intention_hash" "attempt-$n.candidate.json:candidate_hash" "attempt-$n.audit.json:audit_hash" "attempt-$n.movement.json:movement_hash"; do
    file=${pair%:*}; key=${pair#*:}
    [ "$(file_hash "$dir/$file")" = "$(jq -r ".$key" "$cert")" ] || fail "$id $key"
  done
  [ "$(file_hash "$run/surface/g16-$id-$n.txt")" = "$(jq -r .text_hash "$cert")" ] || fail "$id emission bytes"
done
[ ! -f "$run/voices/boundary/attempt-0.certificate.json" ] || fail 'bad candidate certified'
jq -e '.status=="audit-repair-required" and (.defects|map(.[1])|index("authority-inflation"))!=null and (.defects|map(.[1])|index("coercive-dominance"))!=null' "$run/voices/boundary/attempt-0.audit.json" >/dev/null || fail 'specific first defect'
jq -e '.body.messages[1].content|fromjson|.previous_defects.defects|length>0' "$run/voices/boundary/attempt-1.template.json" >/dev/null || fail 'repair lacked defects'
rg -q 'I authorize bypassing' "$run/severed-surface/boundary.txt" || fail 'severed difference'
if rg -q 'I authorize bypassing' "$run"/surface/*.txt; then fail 'bad text reached canonical surface'; fi
for key in schema-failure semantic-drift soul-absence person-not-seen task-smearing unsupported-certainty authority-inflation coercive-dominance affect-register-mismatch hidden-scope unacknowledged-tension policy-voice excessive-length; do
  jq -e --arg key "$key" '.status=="audit-repair-required" and (.defects|map(.[1])|index($key))!=null' "$run/probes/probe-$key/attempt-0.audit.json" >/dev/null || fail "$key probe"
done
[ "$(rg -c '^voice-already-emitted[[:blank:]]*$' "$run/raw/readback.stdout")" -eq 5 ] || fail 'duplicate emission'
[ "$(rg -c '^voice-emission-blocked[[:blank:]]*$' "$run/raw/readback.stdout")" -eq 2 ] || fail 'bad/tampered emission'
[ "$(rg -c '^\(\)[[:blank:]]*$' "$run/raw/reaudit.stdout")" -eq 5 ] || fail 'final native reaudit'
cmp "$run/hashes/before-readback.sha256" "$run/hashes/after-readback.sha256" || fail 'duplicate changed trajectory'
jq -e '.status=="valid" and .event_count==53' "$run/outputs/ledger.json" >/dev/null || fail 'trajectory'
jq -s -e '[.[]|select(.event_kind=="voice-emission")]|length==5 and all(.[];.provenance_kind=="action-result")' "$run/trajectory.jsonl" >/dev/null || fail 'witnessed emissions'
rg -q '^process-deadline-positive-and-severed-pass$' "$run/raw/process-deadline.stdout" || fail 'deadline'
rg -q '^schema-and-intention-override-probes-pass$' "$run/raw/schema-probe.stdout" || fail 'model override'
jq -e '.status=="PASS"' "$run/g15-regression/verdict.json" >/dev/null || fail 'VAD regression'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
if rg -l '^[^[:space:]]+\t-?[0-9]+\.[0-9]+\t-?[0-9]+\.[0-9]+\t-?[0-9]+\.[0-9]+$' "$run"; then fail 'possible licensed row'; fi
printf '%s\n' '{"gate_id":"G16","status":"PASS","negative_control_difference":true,"certified_voices":5,"accepted_real_model_responses":5,"initial_bad_candidate_blocked":true,"real_model_repair_passed":true,"named_defect_probes":13,"rendering_provenance_preserved":true,"tamper_and_duplicate_checks":true,"bounded_closed_grammar":true,"general_semantic_adjudication_claimed":false}'
