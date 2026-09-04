// G33 R13 builder harness. It prepares public synthetic roots and invokes the
// pinned native runtime; it does not decide trial, consequence, or ranking.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {pins,swi,petta,read,save,parse} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R13/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const fixture=read(`${root}/tests/fixtures/g33_r13/cases.json`),expected=fixture.expected;
const opening=checkOpen('docs/gates/G33/R13/plan.json');
assert.equal(opening.plan_commit,'706e2d4c6b2957f67df90c420ae18476daed7f79');save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const loadBearing=[
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','ACCEPTANCE.md','BUILD_FIDELITY_PROTOCOL.md',
  'docs/gates/G33/R13/plan.json','docs/gates/G33/R12/R3/closure.json',
  'src/bootstrap_modules.metta',
  'src/bootstrap_development_helix_v2.metta','src/development_helix_v2.metta',
  'src/bootstrap_development_helix_v1.metta','src/development_helix_v1.metta',
  'src/bootstrap_development_reactor_v1.metta','src/development_reactor_v1.metta',
  'src/bootstrap_development_cycle.metta','src/development_cycle.metta','src/bootstrap_reactor.metta','src/reactor.metta','src/soul.metta',
  'src/bootstrap_voice_construction.metta','src/voice_construction.metta','src/voice_trials_v2.metta',
  'src/nal_revision_v1.metta','src/nace_v2.metta','src/nace_selection_v1.metta',
  'src/bootstrap_relational_voice.metta','src/relational_voice.metta','src/bootstrap_grounded_language.metta',
  'src/grounded_language.metta','src/development_evidence.metta','src/participation.metta','src/participation_support.metta',
  'constitution/soul.metta','constitution/soul_compass_v02.metta',
  'effect_membranes/miter_development_helix_v1.pl','effect_membranes/miter_development_proof_v1.pl',
  'effect_membranes/miter_development_reactor_v1.pl','effect_membranes/miter_openrouter.pl',
  'effect_membranes/miter_voice_construction.pl','effect_membranes/miter_voice_trials_v2.pl',
  'effect_membranes/miter_reactor.pl','effect_membranes/miter_integrity.pl','effect_membranes/miter_store.pl',
  'effect_membranes/miter_llm.pl','effect_membranes/miter_relational_voice.pl','effect_membranes/miter_language.pl',
  'scripts/g33_r13/run.mjs','scripts/g33_r13/verify.mjs','scripts/fidelity/check.mjs',
  'tests/fixtures/g33_r13/cases.json','tests/fixtures/g33_r13/load.metta',
  'tests/fixtures/g33_r12/authorization.json'
];
const absoluteLoadBearing=loadBearing.map(file=>`${root}/${file}`);
for(const file of absoluteLoadBearing)assert(fs.existsSync(file),file);
for(const source of Object.values(fixture.sources))assert.equal(hash(fs.readFileSync(source.path)),source.sha256,source.path);

function prepare(runtime,sources=fixture.sources,reverseManifest=false){
  fs.mkdirSync(runtime,{recursive:true});fs.mkdirSync(`${runtime}/store`);fs.mkdirSync(`${runtime}/inbox`);
  const localSources=structuredClone(sources);
  fs.copyFileSync(sources.candidate_source.path,`${runtime}/candidate.json`);
  fs.copyFileSync(sources.candidate_lineage.path,`${runtime}/candidate-lineage.json`);
  localSources.candidate_source.path=`${runtime}/candidate.json`;
  localSources.candidate_lineage.path=`${runtime}/candidate-lineage.json`;
  fs.writeFileSync(`${runtime}/store/trajectory.jsonl`,'');fs.writeFileSync(`${runtime}/store/trajectory.lock`,'');
  save(`${runtime}/input.json`,{schema:'miter-g33-r13-input-v1',...localSources});
  fs.copyFileSync(`${root}/tests/fixtures/g33_r12/authorization.json`,`${runtime}/authorization.json`);
  const paths=[...absoluteLoadBearing,`${runtime}/input.json`,`${runtime}/authorization.json`,
    ...Object.values(localSources).map(source=>source.path)];
  const files=pins([...new Set(paths)]);if(reverseManifest)files.reverse();
  save(`${runtime}/manifest.json`,{schema:'miter-g33-r13-manifest-v1',files});
}
function outputs(stdout){
  const result={};for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;const row=parse(line);result[row[1]]=row[2];
  }return result;
}
function native(name,body,timeout=240000){
  const program=`${dir}/${name}.metta`;save(program,
    `!(import! &self "${root}/src/bootstrap_modules.metta")\n${body}\n`);
  const started=Date.now(),run=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,encoding:'utf8',timeout,maxBuffer:16*1024*1024});
  save(`${dir}/${name}.stdout`,run.stdout??'');save(`${dir}/${name}.stderr`,run.stderr??'');
  save(`${dir}/${name}-process.json`,{status:run.status,signal:run.signal,error:run.error?.message??null,
    elapsed_ms:Date.now()-started,stdout_bytes:Buffer.byteLength(run.stdout??'')});
  assert.equal(run.status,0,run.stderr);assert.equal(run.stderr,'');return outputs(run.stdout??'');
}
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function reactor(runtime){
  const program=`${dir}/canonical.metta`;save(program,
    `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
    `!(ReactorStart "${runtime}" "${runtime}/integrity-report.json")\n`);
  const started=Date.now(),child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,stdio:['ignore','pipe','pipe']});let stdout='',stderr='',closed=false,finalAt=null;
  child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const completion=new Promise(resolve=>child.on('close',(status,signal)=>{closed=true;resolve({status,signal});}));
  const finalDeadline=Date.now()+240000;
  while(Date.now()<finalDeadline&&!closed&&!fs.existsSync(`${runtime}/final.json`))await wait(50);
  const finalPresent=fs.existsSync(`${runtime}/final.json`);
  if(finalPresent&&!closed){finalAt=Date.now();save(`${runtime}/inbox/stop-r13.json`,{
    schema:'miter-reactor-input-v1',id:'stop-r13',kind:'stop',provenance:'direct-contact',
    obligation:'none',steps:1,sent_at:new Date().toISOString()});}
  let processResult=await Promise.race([completion,wait(expected.max_post_final_stop_ms).then(()=>({timeout:true}))]);
  if(processResult.timeout){child.kill('SIGTERM');processResult={...await completion,timeout:true};}
  const stoppedAt=Date.now();save(`${dir}/canonical.stdout`,stdout);save(`${dir}/canonical.stderr`,stderr);
  processResult={...processResult,elapsed_ms:stoppedAt-started,final_present:finalPresent,
    post_final_stop_ms:finalAt===null?null:stoppedAt-finalAt,stdout_bytes:Buffer.byteLength(stdout)};
  save(`${dir}/canonical-process.json`,processResult);
  assert(finalPresent,'compact final absent');assert.equal(processResult.timeout,undefined,'same-process stop timed out');
  assert.equal(processResult.status,0,stderr);assert.equal(stderr,'');return processResult;
}
function treeBytes(path){let n=0;for(const entry of fs.readdirSync(path,{withFileTypes:true})){
  const p=`${path}/${entry.name}`;n+=entry.isDirectory()?treeBytes(p):fs.statSync(p).size;}return n;}
function lastEvent(path){const rows=fs.readFileSync(path,'utf8').trim().split('\n').filter(Boolean).map(JSON.parse);return rows.at(-1);}

const canonical=`${dir}/canonical`,neutral=`${dir}/neutral`,severed=`${dir}/consequence-severed`,malformed=`${dir}/malformed`;
prepare(canonical);prepare(neutral,fixture.sources,true);prepare(severed);
const badSources=structuredClone(fixture.sources);badSources.candidate_source.sha256='0'.repeat(64);prepare(malformed,badSources);

const probes=native('preflight',
  `!(result root-canonical (dh2_root_probe "${canonical}"))\n`+
  `!(result root-r12 (dh2_root_probe "${root}/evidence/G33/R12/attempt-016/canonical"))\n`+
  `!(result root-other-gate (dh2_root_probe "${root}/evidence/G33/R14/not-authorized"))\n`+
  `!(result root-traversal (dh2_root_probe "${root}/evidence/G33/R13/../R12/attempt-016"))\n`+
  `!(result canonical-input (dh2_input "${canonical}"))\n`+
  `!(result neutral-input (dh2_input "${neutral}"))\n`+
  `!(result malformed-input (dh2_input "${malformed}"))`);
assert.equal(probes['root-canonical'],'qualified-development-root');assert.equal(probes['root-r12'],'qualified-development-root');
assert.equal(probes['root-other-gate'],'rejected-development-root');assert.equal(probes['root-traversal'],'rejected-development-root');
assert.equal(probes['canonical-input'][0],'development-helix-v2-input');assert.deepEqual(probes['neutral-input'],probes['canonical-input']);
assert.deepEqual(probes['malformed-input'],['development-helix-v2-input-unavailable']);

const canonicalProcess=await reactor(canonical);
const final=read(`${canonical}/final.json`).native,trial=read(`${canonical}/trial.json`).native;
const before=read(`${canonical}/efficacy-before.json`).native,after=read(`${canonical}/efficacy-after.json`).native;
assert.equal(final[0],'development-helix-proof');assert.equal(final[1],expected.candidate_sha256);
assert.equal(final[2],'candidate-quarantined');assert.equal(trial[0],'helix-trial-proof');
assert.equal(trial[3][1],expected.trial_standing);assert.equal(trial[3][3][2],expected.trial_cases);
assert.equal(trial[3][4][2],expected.expansions);assert.equal(trial[4],'helix-v2-development-durable');
assert.equal(before[0],'efficacy-ranking-proof');assert.equal(before[3].length,expected.before_maxima);
assert.equal(after[3].length,1);assert.equal(after[3][0][2],expected.after_maximum);
const stopEvent=lastEvent(`${canonical}/store/trajectory.jsonl`);assert.equal(stopEvent.event_kind,'reactor-stopped');

const restart=native('restart',`!(result restart (DH2Restart "${canonical}"))`).restart;
assert.equal(restart[0],'development-helix-v2-rehydrated');assert.equal(restart[2][3].length,1);
assert.equal(restart[2][3][0][2],expected.after_maximum);assert.equal(restart[3],'no-generation-replay');
const severedResult=native('severed',`!(result severed (DH2SeveredConsequence "${severed}"))`).severed;
assert.equal(severedResult[0],'consequence-severed-proof');assert.equal(severedResult[1],'candidate-quarantined');
assert.equal(severedResult[2][1],expected.trial_standing);assert.equal(severedResult[3][3].length,expected.before_maxima);
const neutralResult=native('neutral',`!(result neutral (DH2Run "${neutral}"))`).neutral;
assert.equal(neutralResult[0],'development-helix-proof');assert.equal(neutralResult[1],final[1]);
assert.equal(neutralResult[3][3][1],trial[3][1]);assert.deepEqual(neutralResult[4][4][3],after[3]);

const sizes={final:fs.statSync(`${canonical}/final.json`).size,trial:fs.statSync(`${canonical}/trial.json`).size,
  before:fs.statSync(`${canonical}/efficacy-before.json`).size,after:fs.statSync(`${canonical}/efficacy-after.json`).size,
  restart:fs.statSync(`${canonical}/restart.json`).size,stdout:canonicalProcess.stdout_bytes,runtime:treeBytes(canonical)};
assert(sizes.final<=expected.max_final_bytes);assert(sizes.trial<=expected.max_trial_bytes);
assert(sizes.before<=expected.max_ranking_bytes);assert(sizes.after<=expected.max_ranking_bytes);
assert(sizes.restart<=expected.max_restart_bytes);assert(sizes.stdout<=expected.max_stdout_bytes);
assert(sizes.runtime<=expected.max_runtime_bytes);
const callClaims=fs.readdirSync(`${root}/evidence/G33/R12`).filter(x=>x.startsWith('openrouter-call-')&&x.endsWith('.claim')).length;
assert.equal(callClaims,2);
const observations={schema:'miter-g33-r13-observations-v1',candidate_sha256:final[1],
  trial:{standing:trial[3][1],parent_report_sha256:trial[1][2],candidate_report_sha256:trial[2][2],
    decision_sha256:trial[3][2],cases:trial[3][3][2],expansions:trial[3][4][2],commit:trial[4]},
  efficacy:{before_sha256:before[1],before_maxima:before[3],after_sha256:after[1],after_maxima:after[3],
    parent_consequence:final[4][2][1],candidate_consequence:final[4][3][1]},
  severed_maxima:severedResult[3][3],neutral_same_candidate:true,neutral_same_trial_standing:true,
  neutral_same_after_maxima:true,restart:{standing:restart[0],intent_sha256:restart[1],maxima:restart[2][3],generation:restart[3]},
  same_process_stop:{status:canonicalProcess.status,signal:canonicalProcess.signal??null,
    timeout:false,post_final_stop_ms:canonicalProcess.post_final_stop_ms,event_kind:stopEvent.event_kind},
  roots:{canonical:probes['root-canonical'],r12:probes['root-r12'],other_gate:probes['root-other-gate'],traversal:probes['root-traversal']},
  malformed_candidate_held:probes['malformed-input'][0]==='development-helix-v2-input-unavailable',sizes,
  historical_provider_claims:callClaims,...fixture.resources};save(`${dir}/observations.json`,observations);
const freezeFiles=[...absoluteLoadBearing,...Object.values(fixture.sources).map(x=>x.path),
  `${dir}/opening.json`,`${dir}/preflight.stdout`,`${dir}/canonical.stdout`,`${dir}/canonical.stderr`,
  `${dir}/canonical-process.json`,`${canonical}/input.json`,`${canonical}/manifest.json`,`${canonical}/trial.json`,
  `${canonical}/efficacy-before.json`,`${canonical}/efficacy-after.json`,`${canonical}/final.json`,
  `${canonical}/restart.json`,`${canonical}/development-intent-v2.json`,`${canonical}/active-v2.json`,
  `${canonical}/store/trajectory.jsonl`,`${dir}/severed.stdout`,`${dir}/neutral.stdout`,`${dir}/observations.json`];
save(`${dir}/freeze.json`,{schema:'miter-g33-r13-freeze-v1',git_head:execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',files:pins(freezeFiles),...fixture.resources});
save(`${dir}/verdict.json`,{status:'PASS-BOUNDED',gate:'G33',revision:'R13',
  native_semantics_produce_compact_hash_bound_proofs:true,compact_proof_retains_trial_and_consequence_causality:true,
  same_process_stop_exits_cleanly_after_final_proof:true,restart_rehydrates_changed_ranking_without_generation_replay:true,
  sizes,...fixture.resources,limits:'Exact previously admitted synthetic R12 candidate and trial family; no new semantic generalization, model call, live effect, final G33 integration, or whole-PoC claim.'});
console.log(JSON.stringify(read(`${dir}/verdict.json`)));
