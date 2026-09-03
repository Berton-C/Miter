// Preserve definitive explicit-load/schema-stream failure without copying crash dumps.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'402';const dir=`${root}/evidence/G29/attempt-${tag}`;
const saveOnce=(path,value)=>{const rendered=typeof value==='string'?value:JSON.stringify(value)+'\n';if(fs.existsSync(path))assert.equal(fs.readFileSync(path,'utf8'),rendered,path);else fs.writeFileSync(path,rendered)};
const final=read(`${dir}/final-r4.json`).native;
assert.equal(final[0],'surface-extension-incomplete-r4');
assert.equal(final[1][0],'runtime-recovery-selected');assert.equal(final[1][1],'nemotron-explicit-load');
assert.equal(final[2][0],'surface-extension-incomplete-r4');assert.equal(final[2][1][0],'surface-candidate-incomplete');
const observations=[final[2][1][1],final[2][1][2]];
for(const observation of observations){assert.equal(observation[0],'surface-part-observation');assert.equal(observation[3],'eof');assert.equal(observation[4],200);assert.equal(observation[6],false);assert.equal(observation[8],'schema-mismatch');assert.equal(observation[9],78);assert.equal(observation[10],'')}
for(const id of ['repair-bridge-1','repair-tests-2']){const wire=fs.readFileSync(`${dir}/${id}-wire.json`,'utf8');assert(wire.includes('event: error')&&wire.includes('"terminated"'))}
const load=final[3],unload=final[4];assert.equal(load[0],'model-load-observation');assert.equal(load[2],0);assert.equal(load[3],true);assert(load[6].includes('Model loaded successfully'));assert(load[7].includes('CONTEXT'));assert(load[7].includes('8192'));
assert.equal(unload[0],'model-unload-observation');assert.equal(unload[3],true);assert(unload[7].includes('No models are currently loaded'));
const stateProcess=spawnSync('/Users/bcb/.lmstudio/bin/lms',['ps'],{encoding:'utf8'});assert.equal(stateProcess.status,0);const state=(stateProcess.stdout??'')+(stateProcess.stderr??'');assert(state.includes('No models are currently loaded'));saveOnce(`${dir}/model-state-after.txt`,state);assert.equal(fs.readFileSync(`${dir}/model-state-before.txt`,'utf8'),state);
const crashDir='/Users/bcb/Library/Application Support/LM Studio/Crashpad/pending';
const crashes=fs.readdirSync(crashDir).filter(x=>x.endsWith('.dmp')).map(name=>{const path=`${crashDir}/${name}`,s=fs.statSync(path);return {path,mtime:s.mtime.toISOString(),bytes:s.size,sha256:hash(fs.readFileSync(path))}}).filter(x=>x.mtime>='2026-09-03T18:25:00.000Z').sort((a,b)=>a.mtime.localeCompare(b.mtime));
assert(crashes.length>=2);saveOnce(`${dir}/crash-metadata-r4.json`,{schema:'miter-external-crash-metadata-v1',copied_dump_content:false,records:crashes});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';saveOnce(`${dir}/services-after.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
for(const slot of [1,2])assert(fs.existsSync(`${root}/evidence/G29/R4-call-${slot}.claim/owner.json`));assert(!fs.existsSync(`${root}/runtime/g29/candidates/mattermost-r4`));
saveOnce(`${dir}/r4-failure-verdict.json`,{status:'FAIL-EVIDENCE',selected_recovery:'nemotron-explicit-load',preload_succeeded:true,preload_context:8192,preload_full_gpu:true,speculative_mtp:false,ttl_seconds:900,actual_new_model_calls:2,http_statuses:[200,200],stream_events:['error','error'],terminal_messages:['terminated','terminated'],output_artifacts:0,schema_constrained_requests:true,crash_correlated:true,crash_dump_content_committed:false,cli_preference_write_blocked:true,persistent_model_settings_changed:false,baseline_model_state_restored:true,credentials_used:0,mattermost_network_calls:0,candidate_created:false,candidate_promoted:false,consequence:'Discriminate ordinary inference health from response-schema/grammar failure with one tiny unconstrained Nemotron request before any further artifact rendering.'});
console.log(JSON.stringify(read(`${dir}/r4-failure-verdict.json`)));
