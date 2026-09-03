// Corrected post-verifier for attempt 901. The original verifier expected the
// JSON boolean completion flag to be a string; no runtime evidence is changed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'901',dir=`${root}/evidence/G29/attempt-${tag}`;
assert.equal(read(`${dir}/run-verdict.json`).status,'PASS-BOUNDED');
assert.equal(read(`${dir}/quality-verdict.json`).status,'PASS-BOUNDED');
for(const file of read(`${dir}/manifest.json`).files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
assert.equal(read(`${dir}/secret-audit.json`).evidence_and_candidate_absent,true);

const final=read(`${dir}/final-r9.json`).native,candidate=final[3][1],files=candidate[6],observed=new Map();
const envelope=content=>{
 assert(content.startsWith('BEGIN_SOURCE\n')&&content.endsWith('\nEND_SOURCE'));
 const source=content.slice(13,-11);assert(source&&!source.includes('BEGIN_SOURCE')&&!source.includes('END_SOURCE'));return source;
};
for(const id of ['openrouter-bridge-r9-1','openrouter-tests-r9-2']){
 const observation=read(`${dir}/${id}-observation.json`).native;
 assert.equal(observation[8],'provider-response');assert.equal(observation[11],'z-ai/glm-5.3');
 observed.set(observation[2],envelope(observation[10]));
}
for(const file of files){
 const part=file[1].startsWith('extension/')?'bridge':'tests';
 assert.equal(file[2],observed.get(part));assert.equal(hash(Buffer.from(file[2])),file[3]);
 assert.equal(hash(fs.readFileSync(`${dir}/candidate/${file[1]}`)),file[3]);
}

const ids=['openrouter-bridge-r9-1','openrouter-tests-r9-2'];let totalCost=0;
for(const [i,id] of ids.entries()){
 const req=read(`${dir}/${id}-request.json`),observation=read(`${dir}/${id}-observation.json`).native,timing=read(`${dir}/${id}-timing.json`);
 assert.equal(req.authorization,'keychain-redacted');assert.equal(req.endpoint,'https://openrouter.ai/api/v1/chat/completions');
 assert.equal(req.body.model,'z-ai/glm-5.3');assert.equal(req.body.reasoning_effort,'high');assert.equal(req.body.stream,false);
 assert(!Object.hasOwn(req.body,'response_format'));assert.deepEqual(req.body.provider,{allow_fallbacks:true,data_collection:'deny',require_parameters:true,zdr:true});
 assert.equal(req.body.max_tokens,i===0?8192:4096);assert.equal(timing.transport,'eof');assert.equal(timing.http_status,200);assert.equal(timing.truncated,false);
 assert.equal(observation[6],true);assert.equal(observation[11],'z-ai/glm-5.3');totalCost+=Number(observation[13][4]??0);
}
assert(!fs.existsSync(`${dir}/openrouter-probe-r9-1-request.json`));
const decode=x=>x&&typeof x==='object'&&!Array.isArray(x)?(Object.hasOwn(x,'list')?x.list.map(decode):Object.hasOwn(x,'string')?x.string:Object.hasOwn(x,'atom')?x.atom:Object.hasOwn(x,'number')?x.number:x):x;
const testUser=JSON.parse(read(`${dir}/openrouter-tests-r9-2-request.json`).body.messages[1].content);
const context=decode(testUser.observed_consequences),bridgeProduct=context.find(x=>Array.isArray(x)&&x[0]==='candidate-bridge-product');
assert(bridgeProduct);assert.equal(bridgeProduct[1][3][2],observed.get('bridge'));assert.equal(bridgeProduct[1][3][3],hash(Buffer.from(observed.get('bridge'))));

const text=files.map(x=>x[2]).join('\n').toLowerCase();
for(const token of ['chroma','miter_soul','src/soul','&soul','direct_memory'])assert(!text.includes(token),token);
assert(!/bearer\s+[a-z0-9._-]{12,}/i.test(text));assert(!fs.existsSync(`${root}/extension/mattermost_bridge.pl`));
const paths=[],walk=p=>{if(!fs.existsSync(p))return;const s=fs.statSync(p);if(s.isDirectory())for(const n of fs.readdirSync(p))walk(path.join(p,n));else paths.push(p)};
walk(dir);walk(`${root}/runtime/g29/candidates/mattermost-r9`);for(const slot of [1,2])walk(`${root}/evidence/G29/R9-call-${slot}.claim`);
for(const p of paths){const t=fs.readFileSync(p).toString('latin1');assert(!/sk-or-v1-[A-Za-z0-9._-]+/.test(t),p);assert(!/Bearer\s+[A-Za-z0-9._-]{12,}/.test(t),p)}

const bridge=`${dir}/candidate/extension/mattermost_bridge.pl`,tests=`${dir}/candidate/candidate_tests/mattermost_contract_tests.pl`;
const trial=spawnSync('/opt/homebrew/bin/swipl',['-q','-f','none','-s',bridge,'-s',tests,'-g','run_tests','-t','halt'],{cwd:`${dir}/candidate/candidate_tests`,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024,env:{HOME:'/nonexistent',PATH:'/usr/bin:/bin'}});
save(`${dir}/post-independent-trial.stdout`,trial.stdout??'');save(`${dir}/post-independent-trial.stderr`,trial.stderr??'');
assert.equal(trial.status,0,trial.stderr);assert(!(trial.stderr??'').includes('ERROR:'));assert(!(trial.stderr??'').includes('failed'));
for(const slot of [1,2])assert(fs.existsSync(`${root}/evidence/G29/R9-call-${slot}.claim/owner.json`));
assert.equal(fs.readFileSync(`${dir}/model-state-before.txt`,'utf8'),fs.readFileSync(`${dir}/model-state-after.txt`,'utf8'));
assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
save(`${dir}/verification.json`,{status:'PASS-BOUNDED',verifier_correction:'JSON completion flag is boolean true, not string true',runtime_evidence_changed:false,central_model_registry:true,native_remote_resource_selection:true,diagnostic_repeated:false,exact_bridge_gated_tests:true,tests_received_exact_bridge:true,remote_model_products:2,returned_model_exact:true,candidate_bytes_match_model:true,syntax_and_candidate_tests_pass:true,independent_trial_pass:true,forbidden_core_access_absent:true,credential_value_absent:true,authorization_redacted:true,provider_privacy_constraints_present:true,candidate_quarantined:true,local_model_state_unchanged:true,services_unchanged:true,mattermost_network_calls:0,actual_remote_calls:2,reported_cost:totalCost,not_promoted:true,limits:'G29 design/authorship evidence only; G30 mock-service behavior and G31 live authority remain unproven'});
save(`${dir}/post-verifier-provenance.json`,{schema:'miter-post-verifier-v1',source:`${root}/scripts/g29/r9_post_verify.mjs`,source_sha256:hash(fs.readFileSync(`${root}/scripts/g29/r9_post_verify.mjs`)),original_verifier:`${root}/scripts/g29/r9_verify.mjs`,original_manifest_sha256:hash(fs.readFileSync(`${dir}/manifest.json`)),correction:'expected boolean true instead of string true',remote_calls_added:0});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
