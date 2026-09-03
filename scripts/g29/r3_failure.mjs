// Preserve definitive Nemotron on-demand-load failure without copying crash dumps.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'301';const dir=`${root}/evidence/G29/attempt-${tag}`;
const saveOnce=(path,value)=>{const rendered=typeof value==='string'?value:JSON.stringify(value)+'\n';if(fs.existsSync(path))assert.equal(fs.readFileSync(path,'utf8'),rendered,path);else fs.writeFileSync(path,rendered)};
const observations=['repair-bridge-1','repair-tests-2'].map(id=>read(`${dir}/${id}-observation.json`).native);
for(const observation of observations){
  assert.equal(observation[3],'eof');assert.equal(observation[4],200);assert.equal(observation[6],false);
  assert.equal(observation[8],'schema-mismatch');assert.equal(observation[9],78);assert.equal(observation[10],'');
}
const wires=['repair-bridge-1','repair-tests-2'].map(id=>fs.readFileSync(`${dir}/${id}-wire.json`,'utf8'));
for(const wire of wires)assert(wire.includes('event: error')&&wire.includes('"terminated"'));
const crashDir='/Users/bcb/Library/Application Support/LM Studio/Crashpad/pending';
const crashes=fs.readdirSync(crashDir).filter(x=>x.endsWith('.dmp')).map(name=>{const path=`${crashDir}/${name}`,s=fs.statSync(path);return {path,mtime:s.mtime.toISOString(),bytes:s.size,sha256:hash(fs.readFileSync(path))}}).filter(x=>x.mtime>='2026-09-03T18:14:45.000Z').sort((a,b)=>a.mtime.localeCompare(b.mtime));
assert(crashes.length>=2);
saveOnce(`${dir}/crash-metadata.json`,{schema:'miter-external-crash-metadata-v1',copied_dump_content:false,records:crashes});
const estimateProcess=spawnSync('/Users/bcb/.lmstudio/bin/lms',['load','nemotron-3.5-30b-a3b-antislop-ftpo-i1','--estimate-only','--gpu','max','-c','16384','--yes'],{encoding:'utf8'});
assert.equal(estimateProcess.status,0);const estimate=(estimateProcess.stdout??'')+(estimateProcess.stderr??'');
saveOnce(`${dir}/load-estimate-combined.txt`,estimate);
assert(estimate.includes('Estimated Total Memory: 25.18 GiB'));
const stateProcess=spawnSync('/Users/bcb/.lmstudio/bin/lms',['ps'],{encoding:'utf8'});assert.equal(stateProcess.status,0);
const state=(stateProcess.stdout??'')+(stateProcess.stderr??'');saveOnce(`${dir}/model-state-after-combined.txt`,state);assert(state.includes('No models are currently loaded'));
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(`${dir}/services-after.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
save(`${dir}/r3-failure-verdict.json`,{status:'FAIL-EVIDENCE',selected_model:'nemotron-local',actual_new_model_calls:2,http_statuses:[200,200],stream_events:['error','error'],terminal_messages:['terminated','terminated'],
  output_artifacts:0,on_demand_load_crash_correlated:true,crash_dump_content_committed:false,estimated_total_memory_gib:25.18,host_memory_gib:48,models_left_loaded:0,
  credentials_used:0,mattermost_network_calls:0,candidate_created:false,candidate_promoted:false,
  consequence:'Freeze a transient explicit-load experiment with fixed context, full GPU and TTL; do not repeat on-demand loading or alter persistent settings.'});
console.log(JSON.stringify(read(`${dir}/r3-failure-verdict.json`)));
