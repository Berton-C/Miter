// G33 R12 builder harness. JavaScript prepares disclosed evidence and invokes
// pinned native workers; it does not select resources, judge candidates,
// revise efficacy, or construct the later ranking.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {pins,swi,petta,read,save,parse,sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R12/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const fixture=read(`${root}/tests/fixtures/g33_r12/cases.json`);
const opening=checkOpen('docs/gates/G33/R12/R1/plan.json');
assert.equal(opening.plan_commit,'2656e6acb4bbeac69b4f0ec24a4230f0a65aaf48');save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const loadBearing=[
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','ACCEPTANCE.md','BUILD_FIDELITY_PROTOCOL.md',
  'docs/gates/G33/R12/R1/plan.json','docs/gates/G33/R11/R2/closure.json','docs/gates/G22/closure.json',
  'docs/gates/G24/closure.json','docs/gates/G25/closure.json','docs/gates/G26/closure.json','docs/gates/G29/R9/closure.json',
  'config/model-resources-v1.json','config/voice-realization-schema-v2.json',
  'constitution/soul.metta','constitution/soul_compass_v02.metta',
  'src/bootstrap_modules.metta','src/bootstrap_development_helix_v1.metta','src/development_helix_v1.metta',
  'src/bootstrap_development_reactor_v1.metta','src/development_reactor_v1.metta',
  'src/bootstrap_development_cycle.metta','src/development_cycle.metta','src/bootstrap_reactor.metta','src/reactor.metta','src/soul.metta',
  'src/bootstrap_voice_construction.metta','src/voice_construction.metta','src/voice_trials_v2.metta',
  'src/nal_revision_v1.metta','src/nace_v2.metta','src/nace_selection_v1.metta',
  'src/bootstrap_relational_voice.metta','src/relational_voice.metta','src/bootstrap_grounded_language.metta',
  'src/grounded_language.metta','src/development_evidence.metta','src/participation.metta','src/participation_support.metta',
  'effect_membranes/miter_development_helix_v1.pl','effect_membranes/miter_development_reactor_v1.pl',
  'effect_membranes/miter_openrouter.pl','effect_membranes/miter_voice_construction.pl','effect_membranes/miter_voice_trials_v2.pl',
  'effect_membranes/miter_reactor.pl','effect_membranes/miter_integrity.pl','effect_membranes/miter_store.pl',
  'effect_membranes/miter_llm.pl','effect_membranes/miter_relational_voice.pl','effect_membranes/miter_language.pl',
  'scripts/g33_r12/run.mjs','scripts/g33_r12/verify.mjs','scripts/fidelity/check.mjs',
  'tests/fixtures/g33_r12/cases.json','tests/fixtures/g33_r12/authorization.json','tests/fixtures/g33_r12/load.metta'
];
const absoluteLoadBearing=loadBearing.map(file=>`${root}/${file}`);
for(const file of absoluteLoadBearing)assert(fs.existsSync(file),file);
for(const source of Object.values(fixture.sources)){
  assert.equal(hash(fs.readFileSync(source.path)),source.sha256,source.path);
}
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
function prepare(runtime,extra={}){
  fs.mkdirSync(runtime,{recursive:true});fs.mkdirSync(`${runtime}/store`);fs.mkdirSync(`${runtime}/inbox`);
  fs.writeFileSync(`${runtime}/store/trajectory.jsonl`,'');fs.writeFileSync(`${runtime}/store/trajectory.lock`,'');
  save(`${runtime}/input.json`,{schema:'miter-g33-r12-input-v1',...fixture.sources,...extra});
  fs.copyFileSync(`${root}/tests/fixtures/g33_r12/authorization.json`,`${runtime}/authorization.json`);
  const manifestFiles=[...absoluteLoadBearing,`${runtime}/input.json`,`${runtime}/authorization.json`,
    ...Object.values(fixture.sources).map(source=>source.path)];
  for(const value of Object.values(extra))if(value&&typeof value==='object'&&typeof value.path==='string')manifestFiles.push(value.path);
  save(`${runtime}/manifest.json`,{schema:'miter-g33-r12-manifest-v1',files:pins([...new Set(manifestFiles)])});
}
function outputs(stdout,prefix='case-result'){
  const result={};for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith(`(${prefix} `))continue;const row=parse(line);result[row[1]]=row[2];
  }return result;
}
function native(runtime,name,body,timeout=120000){
  const program=`${dir}/${name}.metta`;save(program,`!(import! &self "${root}/src/bootstrap_modules.metta")\n${body}\n`);
  const started=Date.now(),run=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,encoding:'utf8',timeout,maxBuffer:256*1024*1024});
  save(`${dir}/${name}.stdout`,run.stdout??'');save(`${dir}/${name}.stderr`,run.stderr??'');
  save(`${dir}/${name}-process.json`,{status:run.status,signal:run.signal,error:run.error?.message??null,elapsed_ms:Date.now()-started});
  assert.equal(run.status,0,run.stderr);assert.equal(run.stderr,'');return outputs(run.stdout,'result');
}
async function reactor(runtime){
  const program=`${dir}/canonical.metta`;save(program,
    `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
    `!(case-result hooks (collapse (match &rna_hooks $hook $hook)))\n`+
    `!(ReactorStart "${runtime}" "${runtime}/integrity-report.json")\n`);
  const started=Date.now(),child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,stdio:['ignore','pipe','pipe']});let stdout='',stderr='',closed=false;
  child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const completion=new Promise(resolve=>child.on('close',(status,signal)=>{closed=true;resolve({status,signal});}));
  const end=Date.now()+180000;while(Date.now()<end&&!closed&&!fs.existsSync(`${runtime}/final.json`))await wait(100);
  const finalPresent=fs.existsSync(`${runtime}/final.json`);
  if(!closed){save(`${runtime}/inbox/stop-r12.json`,{schema:'miter-reactor-input-v1',id:'stop-r12',kind:'stop',
    provenance:'direct-contact',obligation:'none',steps:1,sent_at:new Date().toISOString()});}
  let processResult=await Promise.race([completion,wait(15000).then(()=>({timeout:true}))]);
  if(processResult.timeout){child.kill('SIGTERM');processResult={...await completion,timeout:true};}
  save(`${dir}/canonical.stdout`,stdout);save(`${dir}/canonical.stderr`,stderr);
  processResult={...processResult,elapsed_ms:Date.now()-started,final_present:finalPresent};
  save(`${dir}/canonical-process.json`,processResult);assert.equal(processResult.status,0,stderr);assert.equal(stderr,'');assert(finalPresent);
  return {processResult,products:outputs(stdout)};
}

// Offline resource cases execute before the only authorized remote call.
const canonical=`${dir}/canonical`;prepare(canonical);
const selection=native(canonical,'resource-cases',
  `!(result canonical (let $i (dh_input "${canonical}") (DHSelectResource $i)))\n`+
  `!(result neutral (let* (($i (dh_input "${canonical}")) ($rs (index-atom (index-atom $i 2) 1)))\n`+
  ` (DHSelectResource (development-helix-input (index-atom $i 1) (model-resources (DHReverse $rs)) (index-atom $i 3) (index-atom $i 4)))))\n`+
  `!(result absent-authorization (let $i (dh_input "${canonical}")\n`+
  ` (DHSelectResource (development-helix-input (index-atom $i 1) (index-atom $i 2) (index-atom $i 3)\n`+
  `  (provider-authorization openrouter-glm53 z-ai/glm-5.3 g33-r12-generation-1 1 1024 120\n`+
  `   (public-synthetic-fixture no-secrets no-mattermost-credential no-private-memory no-personal-content) denied)))))\n`+
  `!(result ambiguous (let* (($i (dh_input "${canonical}")) ($rs (index-atom (index-atom $i 2) 1))\n`+
  ` ($dup (cons-atom (index-atom $rs 3) $rs)))\n`+
  ` (DHSelectResource (development-helix-input (index-atom $i 1) (model-resources $dup) (index-atom $i 3) (index-atom $i 4)))))\n`+
  `!(result wrong-model-product (let* (($i (dh_input "${canonical}")) ($s (DHSelectResource $i))\n`+
  ` ($q (DHQuestion (index-atom $i 1) $s)))\n`+
  ` (dh_candidate "${canonical}" $q (openrouter-observation g33-r12-generation-1 development eof 200 1 true stop provider-response 2 "{}" wrong-model none (usage 0 0 0 0)))))\n`+
  `!(result generation-preflight (let* (($i (dh_input "${canonical}")) ($s (DHSelectResource $i))\n`+
  ` ($q (DHQuestion (index-atom $i 1) $s)) ($pending (add-atom &derived (development-generation-pending "${canonical}" $q)))\n`+
  ` ($audit (dh_generation_audit "${canonical}" $q)) ($clear (remove-atom &derived (development-generation-pending "${canonical}" $q)))) $audit))`);
assert.equal(selection.canonical[0],'resource-selected');assert.equal(selection.canonical[1],fixture.expected.selected_resource);
assert.equal(selection.neutral[0],selection.canonical[0]);
assert.equal(selection.neutral[1],selection.canonical[1]);
assert.equal(selection.neutral[2],selection.canonical[2]);
assert.deepEqual(selection.neutral[4],selection.canonical[4]);
assert.equal(selection['absent-authorization'][0],'resource-selection-unresolved');
assert.equal(selection.ambiguous[0],'resource-selection-unresolved');assert.deepEqual(selection['wrong-model-product'],['model-candidate-unavailable']);
assert.deepEqual(selection['generation-preflight'],['generation-preflight','true','true','true','true','true','true','true','true']);
save(`${dir}/resource-observations.json`,selection);
assert(!fs.existsSync(`${root}/evidence/G33/R12/openrouter-call-1.claim`));

const reactorResult=await reactor(canonical);
const final=read(`${canonical}/final.json`).native;assert.equal(final[0],'development-helix-result');
const selected=final[1],generation=final[2],product=final[3],quarantine=final[4],trial=final[5],efficacy=final[6];
assert.equal(selected[0],'resource-selected');assert.equal(selected[1],fixture.expected.selected_resource);
assert.equal(generation[0],'openrouter-observation');assert.equal(generation[3],'eof');assert.equal(generation[4],200);
assert.equal(generation[6],true);assert.equal(generation[8],'provider-response');assert.equal(generation[11],fixture.expected.model);
assert.equal(product[0],'model-candidate');assert.equal(product[1][2],fixture.expected.candidate_id);
assert.equal(quarantine,'candidate-quarantined');assert.equal(trial[0],'helix-trial');assert.equal(trial[3][0],'trial-admissible');
assert.equal(trial[4],'helix-development-durable');assert.equal(efficacy[0],'helix-efficacy');
const before=efficacy[1],after=efficacy[4];assert.equal(before[0],'efficacy-ranking');assert.equal(after[0],'efficacy-ranking');
assert.equal(before[2].length,fixture.expected.before_maxima);assert.equal(after[2].length,1);
assert.equal(after[2][0][2],fixture.expected.after_maximum);
assert.equal(efficacy[2][0],'efficacy-processed');assert.equal(efficacy[3][0],'efficacy-processed');

// Consequence-severed arm reuses exact generated bytes and the same fixed trial,
// but never invokes DHNProcess. It must retain the pre-consequence tie.
const severed=`${dir}/consequence-severed`;
fs.mkdirSync(severed,{recursive:true});
fs.copyFileSync(`${canonical}/candidate.json`,`${severed}/candidate.json`);
fs.copyFileSync(`${canonical}/candidate-lineage.json`,`${severed}/candidate-lineage.json`);
const candidateSource={path:`${severed}/candidate.json`,sha256:hash(fs.readFileSync(`${severed}/candidate.json`)),
  standing:'model-candidate-bound',model:'z-ai/glm-5.3'};
const candidateLineage={path:`${severed}/candidate-lineage.json`,sha256:hash(fs.readFileSync(`${severed}/candidate-lineage.json`))};
fs.mkdirSync(`${severed}/store`);fs.mkdirSync(`${severed}/inbox`);fs.writeFileSync(`${severed}/store/trajectory.jsonl`,'');fs.writeFileSync(`${severed}/store/trajectory.lock`,'');
save(`${severed}/input.json`,{schema:'miter-g33-r12-input-v1',...fixture.sources,candidate_source:candidateSource,candidate_lineage:candidateLineage});
fs.copyFileSync(`${root}/tests/fixtures/g33_r12/authorization.json`,`${severed}/authorization.json`);
save(`${severed}/manifest.json`,{schema:'miter-g33-r12-manifest-v1',files:pins([...new Set([...absoluteLoadBearing,
  `${severed}/input.json`,`${severed}/authorization.json`,candidateSource.path,candidateLineage.path,
  ...Object.values(fixture.sources).map(source=>source.path)])])});
const severedResult=native(severed,'consequence-severed',`!(result severed (DHSeveredConsequence "${severed}"))`);
assert.equal(severedResult.severed[0],'consequence-severed-result');assert.equal(severedResult.severed[1],'candidate-quarantined');
assert.equal(severedResult.severed[2][0],'trial-admissible');assert.equal(severedResult.severed[3][0],'efficacy-ranking');
assert.equal(severedResult.severed[3][2].length,fixture.expected.before_maxima);

const beforeRawHash=hash(fs.readFileSync(`${canonical}/g33-r12-generation-1-raw.json`));
const restart=native(canonical,'restart',`!(result restart (DHRestart "${canonical}"))`);
assert.equal(restart.restart[0],'development-helix-rehydrated');assert.equal(restart.restart[2][0],'efficacy-ranking');
assert.equal(restart.restart[2][2].length,1);assert.equal(restart.restart[2][2][0][2],fixture.expected.after_maximum);
assert.equal(restart.restart[3],'no-generation-replay');
assert.equal(hash(fs.readFileSync(`${canonical}/g33-r12-generation-1-raw.json`)),beforeRawHash);

const callClaim=`${root}/evidence/G33/R12/openrouter-call-1.claim/owner.json`;
assert(fs.existsSync(callClaim));const claim=read(callClaim);assert.equal(claim.request,'g33-r12-generation-1');
const observations={schema:'miter-g33-r12-observations-v1',selection,reactor_hooks:reactorResult.products.hooks,
  final,consequence_severed:severedResult.severed,restart:restart.restart,
  call_claim:claim,raw_sha256:beforeRawHash,candidate_sha256:hash(fs.readFileSync(`${canonical}/candidate.json`)),
  resource_order_neutral:true,unauthorized_and_ambiguous_held:true,model_product_quarantined:true,
  trial_admissible_without_material_loss:true,consequence_changes_later_ranking:true,
  consequence_severance_retains_tie:true,restart_preserves_changed_ranking_without_replay:true,
  ...fixture.resources};save(`${dir}/observations.json`,observations);
const freezeFiles=[...absoluteLoadBearing,`${canonical}/input.json`,`${canonical}/authorization.json`,`${canonical}/manifest.json`,
  ...Object.values(fixture.sources).map(source=>source.path)];
save(`${dir}/freeze.json`,{schema:'miter-g33-r12-freeze-v1',git_head:execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),files:pins([...new Set(freezeFiles)]),
  model_calls:1,model:fixture.expected.model,max_output_tokens:1024,deadline_seconds:120,...fixture.resources});
const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R12-R1',
  waiting_undertaking_resumes_through_native_resource_comparison:true,
  model_product_remains_quarantined_until_independent_v2_trial:true,
  native_consequence_and_nal_revision_change_later_ranking:true,
  development_and_changed_possibility_survive_restart:true,
  ...fixture.resources,limits:'One synthetic VoicePolicy undertaking, one exact GLM 5.3 call, finite v2 trial and scoped efficacy question; not general Soul cognition, production promotion, live Mattermost, final G33, or whole-PoC acceptance.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));
