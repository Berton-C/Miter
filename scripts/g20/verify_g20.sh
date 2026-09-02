#!/bin/sh
set -eu
run=$1
fail() { printf 'G20 FAIL: %s\n' "$1" >&2; exit 1; }
for arm in canonical claims empty forbidden soul-severed alternative; do
 dir="$run/$arm"
 jq -e '.status=="exit(0)" and .elapsed_seconds<10 and .model_calls==0' "$run/outputs/$arm-process.json" >/dev/null || fail "$arm process"
 jq -e '.provider_entry_calls==0' "$dir/provider-counter.json" >/dev/null || fail "$arm model call"
 jq -e '.status=="valid"' "$run/outputs/$arm-ledger.json" >/dev/null || fail "$arm ledger"
 rg -q '^reactor-recorded[[:blank:]]*$' "$run/raw/$arm.stdout" || fail "$arm native termination"
 if rg -q 'ERROR:' "$run/raw/$arm.stderr"; then fail "$arm runtime error"; fi
 jq -s -e '[.[]|select(.event_kind=="interest-considered")]|length==1' "$dir/store/trajectory.jsonl" >/dev/null || fail "$arm repeated busywork"
 jq -s -e '[.[]|select(.kind=="idle-wait")]|length>=3' "$dir/trace.jsonl" >/dev/null || fail "$arm continued waiting"
 [ "$(find "$dir/inbox" -type f | wc -l | tr -d ' ')" -eq 1 ] || fail "$arm unexpected human request"
 jq -e '.kind=="stop"' "$dir/inbox/stop.json" >/dev/null || fail "$arm input"
done
for arm in canonical alternative; do
 dir="$run/$arm"
 [ "$(find "$dir/interests" -name opportunity.json | wc -l | tr -d ' ')" -eq 1 ] || fail "$arm opportunity cardinality"
 opp=$(find "$dir/interests" -name opportunity.json)
 id=$(jq -r .opportunity_id "$opp")
 jq -e '.source_event_ids==["g16-voice-audit-exhaustion-0","g16-voice-audit-exhaustion-1"] and .target_surface=="VoicePolicy" and .resource_budget==["model-calls",2,"trial-runs",8] and .allowed_effects==["candidate-storage","isolated-trial"] and .task_authority=="unchanged" and .interruptibility=="safe-boundary" and .progress_witness=="independent-trial-consequence-or-explicit-hold" and .stop_condition=="one-candidate-or-budget-exhausted-or-ground-withdrawn" and .reading_standing=="proposed-investigation-not-proven-improvement" and .status=="admitted-for-quarantined-development" and (.living_question|length)>20' "$opp" >/dev/null || fail "$arm typed opportunity"
 jq -e --arg id "$id" '.species=="DevelopRNA" and .rna_id==$id and .status=="awaiting-candidate-generator" and .authority=="candidate-storage-and-isolated-trial-only"' "$dir/rna/$id.json" >/dev/null || fail "$arm transcription"
 jq -e --arg id "$id" '.opportunity_id==$id and .status=="awaiting-candidate-generator" and .authority=="quarantined-candidate-only"' "$dir/interests/$id/candidate-request.json" >/dev/null || fail "$arm candidate boundary"
 jq -s -e --arg id "$id" '[.[]|select(.event_kind=="development-opportunity" and .source_surface=="native-InterestRNA")]|length==1 and .[0].correlation_id==$id and .[0].parent_event_ids==["g16-voice-audit-exhaustion-0","g16-voice-audit-exhaustion-1"]' "$dir/store/trajectory.jsonl" >/dev/null || fail "$arm lineage"
 for n in 0 1; do
  hash=$(jq -r --arg id "g16-voice-audit-exhaustion-$n" 'select(.event_id==$id and .provenance_kind=="native-audit" and .audience_scope=="scope:g16-private")|.payload_hash' "$dir/store/trajectory.jsonl")
  [ -n "$hash" ] || fail "$arm source missing"
  jq -s -e '.[0]==.[1] and any(.[0].defects[];.[1]=="policy-voice")' "$dir/store/objects/sha256/$hash.json" "evidence/20260902T080225Z-G17/bounded/exhaustion/attempt-$n.audit.json" >/dev/null || fail "$arm original audit evidence"
 done
done
canonical=$(find "$run/canonical/interests" -name opportunity.json)
alternative=$(find "$run/alternative/interests" -name opportunity.json)
jq -s -e '.[0].soul_ground=="CreativeTranscendence" and .[1].soul_ground=="WonderPreservation" and .[0].source_event_ids==.[1].source_event_ids and .[0].source_cut==.[1].source_cut and .[0].living_question!=.[1].living_question and .[0].opportunity_id!=.[1].opportunity_id' "$canonical" "$alternative" >/dev/null || fail 'derived variation'
for arm in claims empty forbidden soul-severed; do
 [ "$(find "$run/$arm/interests" -name opportunity.json | wc -l | tr -d ' ')" -eq 0 ] || fail "$arm unauthorized opportunity"
 jq -s -e 'all(.[];.kind!="RNA-created")' "$run/$arm/trace.jsonl" >/dev/null || fail "$arm RNA"
done
jq -e 'length>0 and all(.[];.[3]=="self-authored" and .[4]=="hashes-verified")' "$run/claims/observations-before.json" >/dev/null || fail 'claims control isolation'
note=$(find "$run/soul-severed/interests" -name interest-considered-intent.json)
jq -e '.payload.decision=="blocked" and .payload.reason=="soul-ground-unavailable" and (.payload.source_event_ids|length)==2' "$note" >/dev/null || fail 'Soul causal bite'
jq -e '.provider_entry_calls==1' "$run/outputs/counter-positive.json" >/dev/null || fail 'call counter positive control'
jq -e '.status=="PASS" and .malformed_and_missing_fail_closed and .same_sources_changed_proposal_reconsidered' "$run/outputs/probes.json" >/dev/null || fail 'schema/context probes'
for gate in g18 g19; do jq -e '.status=="PASS"' "$run/$gate-regression/verdict.json" >/dev/null || fail "$gate regression"; done
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail protected
printf '%s\n' '{"gate_id":"G20","status":"PASS","negative_control_difference":true,"witnessed_endogenous_development":true,"soul_ground_has_causal_bite":true,"proposal_data_not_scheduler_policy":true,"self_assertions_and_empty_capacity_do_not_license_work":true,"same_context_deduplicated":true,"model_calls":0,"g18_g19_regression_pass":true,"unrestricted_deliberation_claimed":false}'
