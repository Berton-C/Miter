// G33 R1 first clean-start experiment. Stop at the first semantic discontinuity.
// Builder code creates an empty evidence-owned root and captures native products;
// it does not translate an unsupported product into a passing standing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';
assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R1/attempt-${tag}`;
const dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);
fs.mkdirSync(dir,{recursive:true});

process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL',phase:'builder-runner',message:error.message,
    stack:error.stack,external_network_requests:0,credential_lookups:0,
    model_calls:0,external_effects:0});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R1/plan.json');
assert.equal(opening.plan_commit,'5ecb9b1e94bed0b5672cf0b80360035ee5c03e73');
save(`${dir}/opening.json`,opening);

const gitHead=execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim();
const pettaHead=execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
assert.equal(pettaHead,'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
const swiVersion=execFileSync(swi,['--version'],{encoding:'utf8'}).trim();

function localGet(name,url){
  const p=spawnSync('/usr/bin/curl',['-sS','--max-time','5',url],
    {cwd:root,encoding:'utf8',maxBuffer:4*1024*1024});
  save(`${dir}/${name}.stdout`,p.stdout??'');
  save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,url});
  return {ready:p.status===0,status:p.status};
}
const lm=localGet('lm-studio-health','http://127.0.0.1:1234/v1/models');
const chroma=localGet('chroma-health','http://127.0.0.1:8001/api/v2/heartbeat');

const source=`${root}/evidence/20260902T063347Z-G11`;
const runtime=`${dir}/runtime`;
const store=`${runtime}/store`;
const capsuleStore=`${runtime}/capsules`;
const output=`${runtime}/outputs`;
fs.mkdirSync(store,{recursive:true});fs.mkdirSync(output,{recursive:true});
for(const name of ['memories','memory-bodies','objects']){
  const from=`${source}/canonical/store/${name}`;
  if(fs.existsSync(from))fs.cpSync(from,`${store}/${name}`,{recursive:true});
}
fs.copyFileSync(`${source}/base-trajectory.jsonl`,`${store}/trajectory.jsonl`);
fs.writeFileSync(`${store}/trajectory.lock`,'');
fs.cpSync(`${source}/capsules`,capsuleStore,{recursive:true});
fs.copyFileSync(`${source}/outputs/project-registry.json`,`${runtime}/project-registry.json`);

const encounter=read(`${root}/tests/fixtures/g33_r1/heldout-continuity.json`);
assert.notEqual(encounter.text,'Where was I with the book?');
const registryHash=hash(fs.readFileSync(`${runtime}/project-registry.json`));
const context={schema:'miter-resume-context-v1',text:encounter.text,
  request_id:`g33-r1-${tag}`,query_tag:`g33-r1-${tag}`,
  occurred_at:'2026-12-01T07:00:00Z',chat_context:[],
  principal_scope:'principal:g08-human',audience_scope:'scope:g08-private-project',
  registry_ref:`${runtime}/project-registry.json`,registry_sha256:registryHash,
  memory_store:store,capsule_store:capsuleStore,output_dir:output,
  capsule_output:`${output}/capsule.json`};
save(`${runtime}/context.json`,context);

const program=`!(import! &self (library lib_import))\n`+
  `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_resume.pl" `+
  `(miter_resume_field miter_resume_registry_count miter_resume_registry_project `+
  `miter_resume_begin miter_resume_witness miter_resume_answer miter_memory_query `+
  `miter_continuity_reconstruct))\n`+
  `!(import! &self "${root}/src/memory.metta")\n`+
  `!(import! &self "${root}/src/continuity.metta")\n`+
  `!(result continuity (ContinuityRNA "${runtime}/context.json" canonical))\n`;
save(`${dir}/continuity.metta`,program);
const started=Date.now();
const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',
  `${dir}/continuity.metta`,'silent'],{cwd:root,encoding:'utf8',timeout:120000,
  maxBuffer:128*1024*1024});
save(`${dir}/continuity.stdout`,p.stdout??'');
save(`${dir}/continuity.stderr`,p.stderr??'');
save(`${dir}/continuity-process.json`,{status:p.status,signal:p.signal,
  error:p.error?.message,elapsed_ms:Date.now()-started});
assert.equal(p.status,0,'continuity process');
assert.equal(p.stderr,'','continuity stderr');
const row=(p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')
  .find(line=>line.startsWith('(result continuity '));
assert(row,'native continuity product missing');
const product=row.slice('(result continuity '.length,-1);
save(`${dir}/observations.json`,{schema:'miter-g33-r1-first-discontinuity-observation-v1',
  clean_runtime_root:true,empty_chat_context:true,heldout_text:encounter.text,
  product,answer_written:fs.existsSync(`${output}/answer.json`),
  startup_written:fs.existsSync(`${output}/startup.json`),
  trajectory_before_lines:fs.readFileSync(`${source}/base-trajectory.jsonl`,'utf8').trim().split('\n').length,
  trajectory_after_lines:fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length,
  localhost_health_requests:2,external_network_requests:0,credential_lookups:0,
  model_calls:0,external_effects:0});

const sourceFiles=['docs/gates/G33/R1/plan.json','docs/gates/G33/R1/expected-run-contract.json',
  'docs/gates/G33/R1/prerequisite-ledger.json','tests/fixtures/g33_r1/heldout-continuity.json',
  'scripts/g33/run.mjs','src/memory.metta','src/continuity.metta',
  'effect_membranes/miter_resume.pl','evidence/20260902T063347Z-G11/base-trajectory.jsonl',
  'evidence/20260902T063347Z-G11/outputs/project-registry.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r1-attempt-freeze-v1',git_head:gitHead,
  petta_commit:pettaHead,swi_version:swiVersion,local_services:{lm_studio:lm,chroma},
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),external_network_requests:0,
  credential_lookups:0,model_calls:0,external_effects:0});
console.log(JSON.stringify(read(`${dir}/observations.json`)));
