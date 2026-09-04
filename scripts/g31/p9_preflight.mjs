// Builder-side G31 P9 preflight. It never receives a credential or performs HTTP.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'901';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p9-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/preflight-failure.json`,{message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,post_content_reads:0,
    message_reads:0,message_writes:0,api_mutations:0,active:false});
  console.error(error.stack);process.exitCode=1;
});
const opening=checkOpen('docs/gates/G31/P9/R1/plan.json');
assert.equal(opening.plan_commit,'4f81d42e53ce8985238a2a56927778689e9628f4');
save(`${dir}/opening.json`,opening);
const live=`${root}/effect_membranes/miter_mattermost_live_canary_v1.pl`;
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const goal=`miter_mattermost_live_canary_v1:g31_live_preflight(${q(dir)},R),write_canonical(R),nl,halt`;
const started=Date.now();
const processResult=spawnSync(swi,['-q','-f','none','-s',live,'-g',goal],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:16*1024*1024});
save(`${dir}/preflight-process.json`,{status:processResult.status,
  signal:processResult.signal,error:processResult.error?.message??null,
  elapsed_ms:Date.now()-started,stdout:processResult.stdout?.trim()??'',
  stderr:processResult.stderr?.trim()??''});
assert.equal(processResult.status,0,processResult.error?.message??processResult.stderr);
assert.equal(processResult.stderr,'');
assert(processResult.stdout.startsWith("['g31-live-preflight-pass',"),processResult.stdout);
const preflight=read(`${dir}/preflight-redacted.json`);
assert.equal(preflight.status,'PASS-BOUNDED');
for(const key of ['candidate_ingest','candidate_denied_before_payload','candidate_effect',
  'candidate_panic','native_certificate'])assert.equal(preflight[key],true,key);
for(const key of ['credential_lookups','network_requests','post_content_reads',
  'message_reads','message_writes','api_mutations'])assert.equal(preflight[key],0,key);
assert.equal(preflight.active,false);
const certificate=read(`${dir}/native-certificate-preflight.json`);
assert.equal(certificate.standing,'certified-utterance');
assert.equal(certificate.voice,'VoiceRNA');assert.equal(certificate.model_calls,0);
assert.equal(certificate.raw_model_output,false);
const privateGrant=read(`${root}/config/local/g31/p7-inactive-live-grant-v3.json`);
const privateApproval=read(`${root}/config/local/g31/p8-live-effect-approval-v1.json`);
for(const path of [`${root}/config/local/g31/p7-inactive-live-grant-v3.json`,
  `${root}/config/local/g31/p8-live-effect-approval-v1.json`])
  assert.equal(fs.statSync(path).mode&0o777,0o600,path);
assert.equal(hash(fs.readFileSync(`${root}/config/local/g31/p7-inactive-live-grant-v3.json`)),
  'afc96d0e1705779f6f1a2eb084b5e6d3c8d77e66b7706a248389ea906d2deb6c');
assert.equal(hash(fs.readFileSync(`${root}/config/local/g31/p8-live-effect-approval-v1.json`)),
  'ad51106cbc657fabd8e15d1d3caadd8a9e728245a551149befadb7243b5ff02f');
assert.equal(privateGrant.active,false);assert.equal(privateApproval.active,false);
const publicText=fs.readdirSync(dir).map(name=>fs.readFileSync(`${dir}/${name}`,'utf8')).join('\n');
const bindings=privateGrant.identity_bindings;
for(const value of [bindings.server.id,bindings.team.id,bindings.allowlisted_channel.id,
  bindings.denied_control_channel.id,bindings.human.id,bindings.human.username,bindings.bot.id])
  assert(!publicText.includes(value),'private identity in preflight evidence');
const liveSource=fs.readFileSync(live,'utf8');
assert(!/python|py-call|janus/i.test(liveSource));
assert(!/miter_chroma|\/api\/v1\/collections|chroma_query|prior_memory_read|history_read/i.test(liveSource));
for(const required of ['127\\\\.0\\\\.0\\\\.1','/api/v4/users/me',
  '/api/v4/channels/~w/posts?since=~d','/api/v4/posts/~w','/api/v4/posts'])
  assert(liveSource.includes(required),`missing bounded route ${required}`);
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P8/R1/closure.json','docs/gates/G31/P9/R1/plan.json',
  'docs/gates/G31/P9/R1/plan.md','src/mattermost_live_canary_v1.metta',
  'src/bootstrap_mattermost_live_canary_v1.metta',
  'effect_membranes/miter_mattermost_live_canary_v1.pl',
  'evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl',
  'effect_membranes/miter_surface_transport_lab_v1.pl','scripts/g31/p9_preflight.mjs',
  'scripts/fidelity/check.mjs'];
save(`${dir}/preflight-manifest.json`,{schema:'miter-g31-p9-preflight-freeze-v1',
  plan:'docs/gates/G31/P9/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),
    `${dir}/preflight-redacted.json`,`${dir}/native-certificate-preflight.json`,
    `${dir}/slot-preflight-native-request-redacted.json`,`${dir}/preflight-process.json`]),
  private_records:[
    {location:'config/local/ignored',sha256:preflight.private_grant_sha256,mode:'0600'},
    {location:'config/local/ignored',sha256:preflight.private_approval_sha256,mode:'0600'}],
  credentials_observed_by_builder:false,actual_identity_public:false,
  network_requests:0,active:false});
save(`${dir}/preflight-verdict.json`,{status:'PASS-BOUNDED-LIVE-ACTIVATION-READY',
  candidate_sha256:preflight.candidate_sha256,transport_sha256:preflight.transport_sha256,
  private_grant_sha256:preflight.private_grant_sha256,
  private_approval_sha256:preflight.private_approval_sha256,
  candidate_controls:true,native_certificate:true,denied_before_payload:true,
  panic_gate:true,credential_lookups:0,network_requests:0,
  post_content_reads:0,message_reads:0,message_writes:0,api_mutations:0,
  active:false,activation_started:false});
console.log(JSON.stringify(read(`${dir}/preflight-verdict.json`)));
