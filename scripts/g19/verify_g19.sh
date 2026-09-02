#!/bin/sh
set -eu
run=$1
fail() { printf 'G19 FAIL: %s\n' "$1" >&2; exit 1; }
for arm in canonical negative; do
 jq -e '.status=="exit(0)" and .elapsed_seconds<8 and .model_calls==0' "$run/outputs/$arm-process.json" >/dev/null || fail "$arm process"
 jq -e '.status=="valid"' "$run/outputs/$arm-ledger.json" >/dev/null || fail "$arm ledger"
 jq -e '.result=="soul-integrity-verified"' "$run/$arm/integrity.json" >/dev/null || fail "$arm Soul"
 rg -q '^reactor-recorded[[:blank:]]*$' "$run/raw/$arm.stdout" || fail "$arm native result"
 if rg -q 'ERROR:' "$run/raw/$arm.stderr"; then fail "$arm runtime"; fi
 jq -s -e '[.[]|select(.kind=="step-witness" and .data[0]=="research")]|length==8' "$run/$arm/trace.jsonl" >/dev/null || fail "$arm finite steps"
 jq -s -e '[.[]|select(.kind=="idle-wait")|.data] as $w | ($w[0:5]|map(.[1]))==[0.05,0.1,0.2,0.4,0.4] and ($w[5:10]|map(.[1]))==[0.05,0.1,0.2,0.4,0.4] and $w[10][1]==0.05 and all($w[];.[2]=="no-progress-claim" and .[3]=="no-model-call")' "$run/$arm/trace.jsonl" >/dev/null || fail "$arm backoff"
 for id in later due; do
  jq -s -e --slurpfile input "$run/$arm/inbox/$id.json" --arg id "$id" '([.[]|select(.kind=="RNA-state" and .data.rna_id==$id)][0].wall_time)-$input[0].sent_at<0.2' "$run/$arm/trace.jsonl" >/dev/null || fail "$arm $id immediate wake"
 done
done
jq -s -e '[.[]|select(.kind=="RNA-state")] as $s | ($s|map(select(.data.status=="suspended"))) as $p | ($s|map(select(.data.status=="resumed"))) as $r | ($p|length)==1 and ($r|length)==1 and ($p[0].data|del(.status))==($r[0].data|del(.status)) and $p[0].data.budget>0 and $p[0].data.budget<8 and $p[0].wall_time<($s|map(select(.data.rna_id=="interrupt" and .data.status=="completed"))|.[0].wall_time) and ($s|map(select(.data.rna_id=="interrupt" and .data.status=="completed"))|.[0].wall_time)<$r[0].wall_time and $r[0].wall_time<($s|map(select(.data.rna_id=="research" and .data.status=="completed"))|.[0].wall_time)' "$run/canonical/trace.jsonl" >/dev/null || fail suspension
jq -s -e '[.[]|select(.kind=="RNA-state" and .data.status=="completed")|.data.rna_id][0:2]==["research","interrupt"] and all(.[];(.kind!="RNA-state" or .data.status!="suspended"))' "$run/negative/trace.jsonl" >/dev/null || fail 'noninterruptible difference'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail protected
printf '%s\n' '{"gate_id":"G19","status":"PASS","negative_control_difference":true,"human_preempts_at_safe_boundary":true,"exact_suspension_state_resumed":true,"idle_schedule_seconds":[0.05,0.1,0.2,0.4,0.4],"contact_and_due_work_reset_backoff":true,"idle_progress_claims":0,"llm_calls":0}'
