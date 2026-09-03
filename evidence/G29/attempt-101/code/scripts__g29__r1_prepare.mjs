// G29 R1 freeze after the decomposed-rendering plan commit; no model call.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {native,save,read,pins,swi,petta} from '../g22_v2/common.mjs';
process.chdir(root);const dir=root+'/evidence/G29/attempt-101';assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',e=>{save(dir+'/prepare-failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
save(dir+'/opening.json',checkOpen('docs/gates/G29/R1/plan.json'));
const base=root+'/evidence/G29/attempt-008';for(const n of ['input.json','reference-lock.json'])fs.copyFileSync(base+'/'+n,dir+'/'+n);
const priorScan=spawnSync('/usr/bin/git',['-C',root,'grep','-l','-F','surface_ingest(','33250f450fd261ed71ad64662edceef281fcba4f','--','src','effect_membranes'],{encoding:'utf8'});
assert([0,1].includes(priorScan.status));assert.equal((priorScan.stdout??'').trim(),'');assert(!fs.existsSync(root+'/extension/mattermost_bridge.pl'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
 'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json','config/local/g03-model-profiles.json',
 'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta',
 'src/participation_support.metta','src/bootstrap_grounded_language.metta','effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl',
 'effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl',
 'scripts/g29/r1_prepare.mjs','scripts/g29/r1_run.mjs','scripts/g29/r1_quality.mjs','scripts/g29/r1_verify.mjs'];
const retained=['mattermost-1-timing.json','mattermost-1-observation.json','mattermost-1-wire.json','final.json','run-failure.json'].map(n=>base+'/'+n);
const refs=read(dir+'/reference-lock.json').files.map(x=>x.path),frozen=pins([...sources.map(x=>root+'/'+x),...refs,dir+'/input.json',dir+'/reference-lock.json',...retained]);
save(dir+'/manifest.json',{schema:'miter-g29-freeze-v1',files:frozen,plan:'docs/gates/G29/R1/plan.json',model_alias:'qwen-local',
 max_new_calls:4,max_output_tokens_per_call:2048,deadline_seconds:300,parts:['design','bridge','tests'],credentials:[],mattermost_network:false,
 retained_initial_failure:{wire_sha256:hash(fs.readFileSync(base+'/mattermost-1-wire.json')),bytes:fs.statSync(base+'/mattermost-1-wire.json').size}});
fs.mkdirSync(dir+'/code');for(const p of sources)fs.copyFileSync(root+'/'+p,dir+'/code/'+p.replaceAll('/','__'));
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(dir+'/services-before.txt',execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
const boot=`!(import! &self "${root}/src/bootstrap_surface_design_v1.metta")\n`,rows=native(dir,'native-design-r1',`!(result design (SDRun "${dir}"))\n!(result runtime (sd_runtime "${dir}"))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));assert.equal(map.design[0],'surface-design');assert.equal(map.design[8][1][1],'swi-prolog');
save(dir+'/prepared.json',{status:'PREPARED',design_id:map.design[1],native_modality:'swi-prolog',model_calls:0,seed_implementation_empty:true,
 prior_failure_retained:true,parts:['design','bridge','tests']});console.log(JSON.stringify(read(dir+'/prepared.json')));
