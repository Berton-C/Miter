#!/bin/sh
set -eu
run=$1
fail() { printf 'G18 FAIL: %s\n' "$1" >&2; exit 1; }
for arm in canonical negative; do
 jq -e '.status=="exit(0)" and .elapsed_seconds<5 and .model_calls==0 and .model_transport_imported==false' "$run/outputs/$arm-process.json" >/dev/null || fail "$arm process"
 jq -e '.status=="valid"' "$run/outputs/$arm-ledger.json" >/dev/null || fail "$arm ledger"
 jq -e '.result=="soul-integrity-verified"' "$run/$arm/integrity.json" >/dev/null || fail "$arm Soul"
 rg -q '^reactor-recorded[[:blank:]]*$' "$run/raw/$arm.stdout" || fail "$arm native termination"
 if rg -q 'ERROR:' "$run/raw/$arm.stderr"; then fail "$arm runtime error"; fi
done
jq -s -e '[.[]|select(.kind=="RNA-created")|.data[1]]==["first","internal","later"]' "$run/canonical/trace.jsonl" >/dev/null || fail transcription
for id in first internal later; do
 jq -e --arg id "$id" '.rna_id==$id and .status=="completed" and .budget==0 and .current_locus=="Consolidate" and ([keys[]]|length)==11' "$run/canonical/rna/$id.json" >/dev/null || fail "$id lifecycle"
 jq -s -e --arg id "$id" '[.[]|select(.kind=="RNA-state" and .data.rna_id==$id)|.data.current_locus]|unique|sort==["Consolidate","Inquire","Transcribe","Witness"]' "$run/canonical/trace.jsonl" >/dev/null || fail "$id loci"
done
jq -s -e '[.[]|select(.kind=="quiescent-ready")]|length==2' "$run/canonical/trace.jsonl" >/dev/null || fail quiescence
jq -s -e '[.[]|select(.kind=="wake")]|length==1' "$run/canonical/trace.jsonl" >/dev/null || fail wake
jq -s -e '([.[]|select(.kind=="quiescent-ready")][0].wall_time)<([.[]|select(.kind=="wake")][0].wall_time)' "$run/canonical/trace.jsonl" >/dev/null || fail timestamps
jq -s -e '[.[]|select(.kind=="RNA-created")]|length==0' "$run/negative/trace.jsonl" >/dev/null || fail 'perpetual RNA'
jq -s -e 'any(.[];.kind=="unauthorized-event" and .data==["unauthorized","perpetual","continue-autonomous-work","none"]) and any(.[];.kind=="quiescent-ready")' "$run/negative/trace.jsonl" >/dev/null || fail negative
if rg -i 'miter_llm|miter_voice|http_post|http_open|python|janus|py-call' src/bootstrap_reactor.metta src/reactor.metta effect_membranes/miter_reactor.pl; then fail 'unexpected transport'; fi
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail protected
printf '%s\n' '{"gate_id":"G18","status":"PASS","negative_control_difference":true,"native_rna_instances":3,"explicit_loci":true,"persistent_process_woke_on_contact":true,"quiescent_llm_calls":0,"unauthorized_perpetual_source_blocked":true,"external_surface_authentication_claimed":false}'
