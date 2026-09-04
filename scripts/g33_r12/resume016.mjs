// No-provider causal-severance recovery for attempt 016. The only R2 call has
// already been consumed; this harness copies its exact quarantined candidate
// into an isolated root and exercises only the native severed arm.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash} from '../fidelity/check.mjs';
import {pins,swi,petta,read,save,parse} from '../g22_v2/common.mjs';

process.chdir(root);
const attempt=`${root}/evidence/G33/R12/attempt-016`;
const canonical=`${attempt}/canonical`,severed=`${attempt}/consequence-severed`;
assert(fs.existsSync(`${root}/evidence/G33/R12/openrouter-call-2.claim/owner.json`));
assert(!fs.existsSync(severed));fs.mkdirSync(severed,{recursive:true});
fs.mkdirSync(`${severed}/store`);fs.mkdirSync(`${severed}/inbox`);
fs.writeFileSync(`${severed}/store/trajectory.jsonl`,'');fs.writeFileSync(`${severed}/store/trajectory.lock`,'');
fs.copyFileSync(`${canonical}/candidate.json`,`${severed}/candidate.json`);
fs.copyFileSync(`${canonical}/candidate-lineage.json`,`${severed}/candidate-lineage.json`);
const input=read(`${canonical}/input.json`);
input.candidate_source={path:`${severed}/candidate.json`,sha256:hash(fs.readFileSync(`${severed}/candidate.json`)),
  standing:'model-candidate-bound',model:'z-ai/glm-5.3'};
input.candidate_lineage={path:`${severed}/candidate-lineage.json`,sha256:hash(fs.readFileSync(`${severed}/candidate-lineage.json`))};
save(`${severed}/input.json`,input);fs.copyFileSync(`${canonical}/authorization.json`,`${severed}/authorization.json`);
const sourceManifest=read(`${canonical}/manifest.json`);
const files=sourceManifest.files.map(x=>x.path).filter(p=>p!==`${canonical}/input.json`&&p!==`${canonical}/authorization.json`);
files.push(`${severed}/input.json`,`${severed}/authorization.json`,`${severed}/candidate.json`,`${severed}/candidate-lineage.json`);
save(`${severed}/manifest.json`,{schema:'miter-g33-r12-manifest-v1',files:pins([...new Set(files)])});
const program=`${attempt}/consequence-severed.metta`;
save(program,`!(import! &self "${root}/src/bootstrap_modules.metta")\n!(result severed (DHSeveredConsequence "${severed}"))\n`);
const run=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:256*1024*1024});
save(`${attempt}/consequence-severed.stdout`,run.stdout??'');save(`${attempt}/consequence-severed.stderr`,run.stderr??'');
save(`${attempt}/consequence-severed-process.json`,{status:run.status,signal:run.signal,error:run.error?.message??null});
assert.equal(run.status,0,run.stderr);assert.equal(run.stderr,'');
const line=run.stdout.split('\n').find(x=>x.startsWith('(result severed '));assert(line);
const result=parse(line)[2];assert.equal(result[0],'consequence-severed-result');
assert.equal(result[1],'candidate-quarantined');assert.equal(result[2][0],'trial-admissible');
assert.equal(result[3][0],'efficacy-ranking');assert.equal(result[3][2].length,2);
save(`${attempt}/consequence-severed-summary.json`,{status:'PASS-BOUNDED',native_tag:result[0],
  quarantine:result[1],trial:result[2][0],maxima:result[3][2],consequence_consumer:result[4],model_calls:0});
console.log(JSON.stringify(read(`${attempt}/consequence-severed-summary.json`)));
