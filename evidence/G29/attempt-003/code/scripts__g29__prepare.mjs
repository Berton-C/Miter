// Offline source freeze and native modality experiment; no candidate implementation.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {native,save,read,sexp,pins,swi,petta} from '../g22_v2/common.mjs';
process.chdir(root);const tag=process.argv[2]??'001';assert.match(tag,/^00[1-9]$/);
const dir=root+'/evidence/G29/attempt-'+tag;assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',e=>{save(dir+'/prepare-failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
save(dir+'/opening.json',checkOpen('docs/gates/G29/plan.json'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert(!fs.existsSync(root+'/extension/mattermost_bridge.pl'));
const priorScan=spawnSync('/usr/bin/git',['-C',root,'grep','-l','-F','surface_ingest(','33250f450fd261ed71ad64662edceef281fcba4f','--','src','effect_membranes'],{encoding:'utf8'});
assert([0,1].includes(priorScan.status));const authoredSearch=(priorScan.stdout??'').trim().split('\n').filter(Boolean);
assert.deepEqual(authoredSearch,[],'seed already contains Mattermost adapter interface');
const mmCommit='24e436e7ae2a6a45866c9612da3981ea21b2b540';
const refs=[
 {path:root+'/evidence/G29/references/mattermost-introduction-24e436e.yaml',sha256:'580696df1c4ce5e2e78b1f0a66e68825ad7a73405da2d64b2aafb3f8e1eb6b68',url:'https://github.com/mattermost/mattermost/blob/'+mmCommit+'/api/v4/source/introduction.yaml'},
 {path:root+'/evidence/G29/references/mattermost-posts-24e436e.yaml',sha256:'26180adbeaf55681bac94c5735cad76538b7cf99f0c3689742edb1f79a67af8d',url:'https://github.com/mattermost/mattermost/blob/'+mmCommit+'/api/v4/source/posts.yaml'}
];for(const r of refs)assert.equal(hash(fs.readFileSync(r.path)),r.sha256);
save(dir+'/reference-lock.json',{schema:'miter-g29-reference-lock-v1',repository:'https://github.com/mattermost/mattermost',commit:mmCommit,files:refs,
 observed_facts:[{rest_base:'/api/v4',source:'introduction.yaml:52'},{websocket_endpoint:'/api/v4/websocket',source:'introduction.yaml:181-189'},
 {websocket_fields:['event','data','broadcast','seq'],source:'introduction.yaml:216-238'},{create_post:'POST /api/v4/posts',source:'posts.yaml:1-8'}]});
const required=['http-client','json-codec','websocket-client','durable-files','hashing','process-control'];
const obligations=[
 ['stable-identity',['server_id','team_id','channel_id','user_id','post_id','root_id','event_timestamp','cursor']],
 ['authorization-before-cognition'],['outbound-idempotency'],['durable-cursor-and-reconnect'],['credential-isolation'],
 ['core-derived-memory-scope'],['typed-failure-witness'],['fixed-local-panic'],['no-direct-soul-or-chroma-access'],['versioned-rollback']
];
const contract=['surface-contract','surface-event-v1','surface-effect-v1',required,obligations];
const api=['surface-api','Mattermost',mmCommit,refs[0].sha256,refs[1].sha256,
 [['rest-base','/api/v4'],['websocket-endpoint','/api/v4/websocket'],['websocket-fields',['event','data','broadcast','seq']],['create-post','POST /api/v4/posts']]];
const prior=['extension-consequence','G28','complete',['fork-test-merge','later-use'],['model-consequence','qwen-local','qualified-after-specific-repair']];
const grant=['surface-design-grant','G29','no-live','no-credentials',4,4096,300,['swi-prolog']];
const request=['surface-request','Mattermost','first-omitted-tentacle','user-requested'];
const scope=['scope','g29-design',['builder','miter'],'Miter','v1'],aud=['builder','miter'],project='Miter',version='v1';
const sources=[['request-source','human-confirmation',request],['contract-source','testimony',contract],['api-source','action-result',api],
 ['prior-source','action-result',prior],['grant-source','human-confirmation',grant]];
const nodes=sources.map(([id,kind,payload])=>['node',id,kind,aud,project,version,payload,[]]);
const registry=sources.map(([id,kind,payload])=>['observation',id,kind,aud,project,version,payload]);
const current=sources.map(([id])=>['at',id,version]);
const input=['surface-design-input','mattermost-g29-design',scope,nodes,registry,current,'Mattermost',...sources.map(x=>x[0])];
save(dir+'/input.json',{native:input,standing:'User-requested first omitted tentacle; control-defined generic contract; observed official API bytes; no live grant'});
const sourceFiles=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
 'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/local/g03-model-profiles.json',
 'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta',
 'src/participation_support.metta','src/bootstrap_grounded_language.metta','effect_membranes/miter_surface_design_v1.pl',
 'effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl',
 'effect_membranes/miter_process.pl','scripts/g29/prepare.mjs','scripts/g29/run.mjs','scripts/g29/quality.mjs','scripts/g29/verify.mjs'];
const frozen=pins([...sourceFiles.map(p=>root+'/'+p),...refs.map(r=>r.path),dir+'/input.json',dir+'/reference-lock.json']);
save(dir+'/manifest.json',{schema:'miter-g29-freeze-v1',files:frozen,model_alias:'qwen-local',max_calls:4,max_output_tokens:4096,deadline_seconds:300,
 implementation_seed_empty:true,network_scope:'localhost LM Studio only after native design; no Mattermost network',credentials:[]});
fs.mkdirSync(dir+'/code');for(const p of sourceFiles)fs.copyFileSync(root+'/'+p,dir+'/code/'+p.replaceAll('/','__'));
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(dir+'/services-before.txt',execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
save(dir+'/versions.json',{swi:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),petta:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
 node:process.version,rust:execFileSync('/Users/bcb/.cargo/bin/rustc',['--version'],{encoding:'utf8'}).trim()});
const boot=`!(import! &self "${root}/src/bootstrap_surface_design_v1.metta")\n`;
const result=native(dir,'native-design',`!(result design (SDRun "${dir}"))\n!(result runtime (sd_runtime "${dir}"))`,boot);
const map=Object.fromEntries(result.map(x=>[x[1],x[2]]));assert.equal(map.design[0],'surface-design',JSON.stringify(map.design));
assert.equal(map.design[8][0],'modality-selected');assert.equal(map.design[8][1][1],'swi-prolog');
const inventory=map.runtime,options=inventory[1],prolog=options[0];
const neutral=['runtime-inventory',[...options].reverse().map(o=>o[1]==='swi-prolog'?[...o.slice(0,2),[...o[2]].reverse(),...o.slice(3)]:o)];
const severed=structuredClone(inventory);severed[1][0][2]=severed[1][0][2].filter(x=>x[1]!=='websocket-client');
const ambiguous=structuredClone(inventory);ambiguous[1].push(['modality-capability','nodejs',required.map(x=>['capability',x]),'non-cognitive-effect-membrane','runtime-authorized','no-new-runtime-dependency']);
const expr=`!(result canonical (SDConstruct ${sexp(['surface-design-opportunity',...map.design.slice(1,8),map.design[10][1]])} ${sexp(inventory)}))\n`+
 `!(result neutral (SDConstruct ${sexp(['surface-design-opportunity',...map.design.slice(1,8),map.design[10][1]])} ${sexp(neutral)}))\n`+
 `!(result severed (SDConstruct ${sexp(['surface-design-opportunity',...map.design.slice(1,8),map.design[10][1]])} ${sexp(severed)}))\n`+
 `!(result ambiguous (SDConstruct ${sexp(['surface-design-opportunity',...map.design.slice(1,8),map.design[10][1]])} ${sexp(ambiguous)}))`;
const controls=native(dir,'modality-controls',expr,boot),cm=Object.fromEntries(controls.map(x=>[x[1],x[2]]));
assert.equal(cm.canonical[0],'surface-design');assert.deepEqual(cm.neutral,cm.canonical);assert.equal(cm.severed[0],'surface-design-held');assert.equal(cm.ambiguous[0],'surface-design-held');
save(dir+'/preflight-verdict.json',{status:'PASS-BOUNDED',implementation_seed_empty:true,official_sources_pinned:true,native_modality:'swi-prolog',
 reason:'Only observed option satisfying every required mechanic, non-cognitive membrane role, runtime authority and zero-new-runtime dependency',
 neutral_preserved:true,missing_websocket_changes_design:true,additional_equal_option_creates_unresolved_not_first_match:true,model_calls:0,live_reach:false});
save(dir+'/prepared.json',{status:'PREPARED',design_id:map.design[1],model_calls:0,implementation_seed_empty:true});
console.log(JSON.stringify(read(dir+'/preflight-verdict.json')));
