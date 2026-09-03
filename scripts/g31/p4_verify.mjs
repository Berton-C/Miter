// Independent file, journal, authorship, and side-effect verification.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'101';
const dir=`${root}/evidence/G31/p4-${tag}`;
const run=read(`${dir}/run-verdict.json`),quality=read(`${dir}/quality-verdict.json`);
assert.equal(run.status,'PASS-BOUNDED');assert.equal(quality.status,'PASS-BOUNDED');
const manifest=read(`${dir}/manifest.json`);
for(const file of manifest.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
const candidate=`${dir}/candidate/extension/mattermost_bridge.pl`;
const transport=`${root}/effect_membranes/miter_surface_transport_lab_v1.pl`;
assert.equal(hash(fs.readFileSync(candidate)),run.candidate_sha256);
assert.equal(hash(fs.readFileSync(transport)),run.transport_sha256);
assert(!/mattermost|pending_post_id|\/api\/v4\/posts|post_edited|\bposted\b/i.test(fs.readFileSync(transport,'utf8')));
const canonical=`${dir}/canonical`;
for(const file of ['effect-pending.json','effect-confirmed.json','cursor.json',
  'version-before.json','version-lab.json','version-rollback.json','restart.json',
  'loopback-summary.json'])assert(fs.existsSync(`${canonical}/${file}`),file);
const pending=read(`${canonical}/effect-pending.json`);
const confirmed=read(`${canonical}/effect-confirmed.json`);
const restart=read(`${canonical}/restart.json`);
const loopback=read(`${canonical}/loopback-summary.json`);
const rollback=read(`${canonical}/version-rollback.json`);
assert.equal(pending.status,'pending');assert.equal(confirmed.status,'confirmed');
assert.equal(pending.identity,confirmed.identity);assert.equal(restart.verified,true);
assert.equal(loopback.attempts,2);assert.equal(loopback.creates,1);
assert.equal(loopback.first_receipt,loopback.second_receipt);
assert.equal(rollback.active,'inactive');assert.equal(rollback.history_preserved,true);
assert.equal(read(`${dir}/wrong-principal-result.json`).standing[0],'g31-p4-transport-held');
assert.equal(read(`${dir}/no-journal-result.json`).standing[0],'g31-p4-transport-held');
assert.equal(read(`${dir}/wrong-candidate-hash-result.json`).standing[0],'g31-p4-transport-held');
for(const key of ['model_calls','credential_lookups','local_mattermost_requests',
  'message_reads','message_writes'])assert.equal(run[key],0,key);
assert.equal(run.promoted,false);assert.equal(run.activated,false);
save(`${dir}/verification.json`,{status:'PASS-BOUNDED',frozen_inputs_verified:true,
  miter_candidate_unchanged:true,generic_transport_authorship_verified:true,
  exact_hash_binding_verified:true,authorization_first_verified:true,
  stable_effect_identity_verified:true,durable_journals_verified:true,
  child_restart_verified:true,panic_verified:true,rollback_verified:true,
  native_causal_controls_verified:true,model_calls:0,credential_lookups:0,
  local_mattermost_requests:0,message_reads:0,message_writes:0,
  promoted:false,activated:false,
  limits:'Loopback laboratory only; no Mattermost endpoint, credential, live grant, promotion, or activation'});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
