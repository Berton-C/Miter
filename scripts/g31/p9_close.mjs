// Builder-side G31 P9 closure verification. It performs no network or credential operation.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'915';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p9-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/closure-failure.json`,{status:'FAIL',message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,message_reads:0,message_writes:0,api_mutations:0});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G31/P9/R1/plan.json');
assert.equal(opening.plan_commit,'4f81d42e53ce8985238a2a56927778689e9628f4');
save(`${dir}/opening.json`,opening);
const live=`${root}/evidence/G31/p9-913`;
const finalPreflight=read(`${root}/evidence/G31/p9-914/preflight-verdict.json`);
assert.equal(finalPreflight.status,'PASS-BOUNDED-LIVE-ACTIVATION-READY');
for(const key of ['credential_lookups','network_requests','post_content_reads',
  'message_reads','message_writes','api_mutations'])assert.equal(finalPreflight[key],0,key);

const statePath=`${root}/config/local/g31/p9-live-state-v1.json`;
const state=read(statePath);assert.equal(fs.statSync(statePath).mode&0o777,0o600);
assert.equal(state.phase,'terminal-panic');assert.equal(state.active,false);
assert.equal(state.network_allowed,false);assert.equal(state.panic,true);
assert.equal(state.allowlisted_inputs,2);assert.equal(state.denied_inputs,1);
assert.equal(state.outbound_effects,2);assert.equal(state.restarts,1);
assert.equal(state.bridge_generation,2);assert(state.ended_at_ms<state.expires_at_ms);
assert.equal(state.ended_at_ms-state.activated_at_ms,816832);

for(const slot of [1,2]){
  const event=read(`${live}/slot-${slot}-event-redacted.json`);
  const prepare=read(`${live}/slot-${slot}-prepare-redacted.json`);
  const witness=read(`${live}/slot-${slot}-witness-redacted.json`);
  const certificate=read(`${live}/native-certificate-${slot}.json`);
  assert.equal(event.status,'accepted');assert.equal(event.identity_authorized_before_content,true);
  assert.equal(event.history_access,false);assert.equal(event.chroma_access,false);
  assert.equal(event.prior_memory_access,false);
  assert.equal(certificate.standing,'certified-utterance');assert.equal(certificate.voice,'VoiceRNA');
  assert.equal(certificate.raw_model_output,false);assert.equal(certificate.model_calls,0);
  assert.equal(certificate.source_post_sha256,event.source_post_sha256);
  assert.equal(certificate.source_version_sha256,event.version_sha256);
  assert.equal(certificate.content_sha256,event.content_sha256);
  assert.equal(prepare.pending_durable_before_send,true);assert.equal(prepare.status,'pending');
  assert.equal(prepare.effect_id_sha256,certificate.effect_id_sha256);
  assert.equal(prepare.certificate_sha256,certificate.certificate_payload_sha256);
  assert.equal(witness.status,'confirmed');assert.equal(witness.prepare_commit_witness,true);
  assert.equal(witness.effect_id_sha256,prepare.effect_id_sha256);
  assert.equal(witness.certificate_sha256,prepare.certificate_sha256);
  assert.match(witness.external_receipt_sha256,/^[a-f0-9]{64}$/);
  const privateEffect=`${root}/config/local/g31/p9-live/slot-${slot}-effect.json`;
  assert.equal(fs.statSync(privateEffect).mode&0o777,0o600);
  assert.equal(read(privateEffect).status,'confirmed');
}
const restart=read(`${live}/restart-redacted.json`);
assert.equal(restart.status,'resumed');assert.equal(restart.cursor_readback,true);
assert.equal(restart.effect_readback,true);assert.equal(restart.reconnect_accepted,true);
assert.equal(restart.old_effect_candidate_standing,'duplicate-suppressed');
assert.equal(restart.old_effect_replay_requests,0);assert.equal(restart.old_effect_replay_writes,0);
const denied=read(`${live}/denied-redacted.json`);
assert.equal(denied.status,'rejected-before-cognition');assert.equal(denied.content_read,false);
assert.equal(denied.content_persisted,false);assert.equal(denied.native_invocations,0);
assert.equal(denied.cognition_invocations,0);assert.equal(denied.response_effects,0);
const panic=read(`${live}/panic-redacted.json`);
assert.equal(panic.status,'terminal-panic');assert.equal(panic.new_effects_after_panic,0);
assert.equal(panic.active,false);assert.equal(panic.network_allowed,false);
const requests=read(`${live}/request-reconciliation-redacted.json`);
assert.equal(requests.bot_scoped_http_requests,104);
assert.equal(requests.bot_identity_gets+requests.channel_post_polls+
  requests.exact_post_receipt_or_recovery_gets+requests.effect_posts,104);
assert.equal(requests.effect_posts,2);assert.equal(requests.other_bot_routes,0);
assert.equal(requests.durable_state_recorded_http_requests,state.network_requests);
assert.equal(requests.bot_scoped_http_requests-requests.durable_state_recorded_http_requests,
  requests.diagnostic_and_recovery_delta);

const walk=directory=>fs.readdirSync(directory,{withFileTypes:true}).flatMap(entry=>{
  const full=path.join(directory,entry.name);return entry.isDirectory()?walk(full):[full];
});
const publicFiles=[...walk(`${root}/evidence/G31`).filter(file=>/\/p9-\d{3}\//.test(file)),
  `${root}/docs/gates/G31/P9/R1/outcome.md`];
const publicText=publicFiles.map(file=>fs.readFileSync(file,'utf8')).join('\n');
const grant=read(`${root}/config/local/g31/p7-inactive-live-grant-v3.json`);
const b=grant.identity_bindings;
for(const value of [b.server.id,b.team.id,b.allowlisted_channel.id,
  b.denied_control_channel.id,b.human.id,b.human.username,b.bot.id])
  assert(!publicText.includes(value),'private Mattermost identity in public P9 evidence');
assert(!/Authorization\s*[:=]|Bearer\s+[A-Za-z0-9._-]+/i.test(publicText),'credential material');

const sourceFiles=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P8/R1/closure.json','docs/gates/G31/P9/R1/plan.json',
  'docs/gates/G31/P9/R1/plan.md','docs/gates/G31/P9/R1/outcome.md',
  'src/mattermost_live_canary_v1.metta','src/bootstrap_mattermost_live_canary_v1.metta',
  'effect_membranes/miter_mattermost_live_canary_v1.pl',
  'evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl',
  'effect_membranes/miter_surface_transport_lab_v1.pl','scripts/g31/p9_preflight.mjs',
  'scripts/g31/p9_close.mjs','scripts/fidelity/check.mjs'];
const evidenceFiles=[...walk(live),...walk(`${root}/evidence/G31/p9-914`)];
save(`${dir}/manifest.json`,{schema:'miter-g31-p9-r1-freeze-v1',
  plan:'docs/gates/G31/P9/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sourceFiles.map(file=>`${root}/${file}`),...evidenceFiles]),
  private_records:[{tracked:false,location:'config/local/ignored',mode:'0600',
    terminal_phase:state.phase,active:state.active,network_allowed:state.network_allowed}],
  stable_ids_public:false,credential_values_returned:false,raw_api_responses_public:false});
save(`${dir}/run-verdict.json`,{status:'PASS-BOUNDED-LIVE-CANARY',
  duration_ms:requests.duration_ms,maximum_duration_ms:requests.maximum_duration_ms,
  allowlisted_inputs:2,certified_voice_effects:2,confirmed_effect_posts:2,
  restart_count:1,old_effect_replay_writes:0,denied_inputs:1,
  denied_cognition_invocations:0,denied_response_effects:0,
  terminal_phase:state.phase,active:false,network_allowed:false,
  bot_scoped_http_requests:104,durable_state_recorded_http_requests:69,
  diagnostic_and_recovery_delta:35,request_count_reconciled_from_local_server_log:true,
  credential_values_returned:false,history_access:false,chroma_access:false,
  prior_memory_access:false,final_offline_preflight:finalPreflight.status,
  network_requests_by_closure_verifier:0,credential_lookups_by_closure_verifier:0,
  message_reads_by_closure_verifier:0,message_writes_by_closure_verifier:0,
  api_mutations_by_closure_verifier:0});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
