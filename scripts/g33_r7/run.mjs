// G33 R7 clean-start re-entry diagnostic. This launcher supplies isolation,
// disclosed contact, timing and capture only. Current native consumers own all
// continuity, expression, readiness, wake, lifecycle and stop products.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';
import {sourceFrame,reorderedFrame} from '../g33_r5/cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R7/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const resources={localhost_model_calls:0,external_network_requests:0,
  credential_lookups:0,chroma_mutations:0,mattermost_operations:0,
  human_emissions:0,external_effects:0};
process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL-RUNNER',message:error.message,
    stack:error.stack,...resources});console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R7/plan.json');
assert.equal(opening.plan_commit,'30991942c7ff5c0cd433b5aafd0996b0e7b89262');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const fixture=read(`${root}/tests/fixtures/g33_r7/cases.json`);
const runtime=`${dir}/runtime`,store=`${runtime}/store`,capsules=`${runtime}/capsules`;
const output=`${runtime}/outputs`,voiceRoot=`${runtime}/relational-voice`;
fs.mkdirSync(store,{recursive:true});fs.mkdirSync(output,{recursive:true});
const continuitySource=`${root}/evidence/20260902T063347Z-G11`;
for(const name of ['memories','memory-bodies','objects']){
  const from=`${continuitySource}/canonical/store/${name}`;
  if(fs.existsSync(from))fs.cpSync(from,`${store}/${name}`,{recursive:true});
}
fs.copyFileSync(`${continuitySource}/base-trajectory.jsonl`,`${store}/trajectory.jsonl`);
fs.writeFileSync(`${store}/trajectory.lock`,'');
fs.cpSync(`${continuitySource}/capsules`,capsules,{recursive:true});
fs.copyFileSync(`${continuitySource}/outputs/project-registry.json`,`${runtime}/project-registry.json`);
const beforeLines=fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
const context={schema:'miter-resume-context-v1',text:fixture.continuity.text,
  request_id:`g33-r7-continuity-${tag}`,query_tag:`g33-r7-continuity-${tag}`,
  occurred_at:'2026-12-01T07:00:00Z',chat_context:[],
  principal_scope:'principal:g08-human',audience_scope:'scope:g08-private-project',
  registry_ref:`${runtime}/project-registry.json`,
  registry_sha256:hash(fs.readFileSync(`${runtime}/project-registry.json`)),
  memory_store:store,capsule_store:capsules,output_dir:output,
  capsule_output:`${output}/capsule.json`,
  model_config:`${root}/config/local/g03-model-profiles.json`};
save(`${runtime}/context.json`,context);

function runNative(name,program,timeout=140000){
  const metta=`${dir}/${name}.metta`;save(metta,program);const started=Date.now();
  const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',metta,'silent'],
    {cwd:root,encoding:'utf8',timeout,maxBuffer:256*1024*1024});
  save(`${dir}/${name}.stdout`,p.stdout??'');save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,
    error:p.error?.message,elapsed_ms:Date.now()-started});
  const products={};
  for(const line of (p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;const row=parse(line);products[row[1]]=row[2];
  }
  save(`${dir}/${name}-products.json`,products);
  return {process:p,products};
}

const continuityRun=runNative('continuity',
  `!(import! &self "${root}/src/bootstrap_continuity_intent_v1.metta")\n`+
  `!(result continuity (ContinuityRNA "${runtime}/context.json" canonical))\n`);
if(fs.existsSync(`${output}/continuity-reading-timing.json`))resources.localhost_model_calls=1;
const typed=fs.existsSync(`${output}/continuity-reading-typed.json`)?
  read(`${output}/continuity-reading-typed.json`):null;
const answer=fs.existsSync(`${output}/answer.json`)?read(`${output}/answer.json`):null;
const afterContinuityLines=fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
const continuityPassed=continuityRun.process.status===0&&continuityRun.process.stderr===''&&
  continuityRun.products.continuity==='continuity-answer-stored'&&
  typed?.standing==='generated-source-verified-candidate'&&
  answer?.certificate==='exact-continuity'&&afterContinuityLines===beforeLines+2;

if(!continuityPassed){
  const verdict={status:'FAIL',gate:'G33',revision:'R7',
    first_discontinuity:'current-continuity-reentry',stopped_at_first_discontinuity:true,
    later_phases_executed:false,...resources};
  save(`${dir}/observations.json`,{schema:'miter-g33-r7-observations-v1',continuity:{
    process_status:continuityRun.process.status,native:continuityRun.products.continuity,
    typed,answer,trajectory_before_lines:beforeLines,
    trajectory_after_lines:afterContinuityLines,passed:false},verdict});
  save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));process.exit(1);
}

const frame=sourceFrame(),neutralFrame=reorderedFrame();
const request=fixture.voice.request_id,clauses=fixture.voice.returned_clauses,scope=frame[1];
for(const name of ['canonical','missing-frame','neutral','restored'])
  fs.mkdirSync(`${voiceRoot}/${name}`,{recursive:true});
const intention=f=>`(RIntend ${request} (DGround ${sexp(f)}))`;
const state=(stateScope=scope)=>`(rendered ${request} ${sexp(stateScope)} ${sexp(clauses)} "g33-r7-disclosed-returned-state")`;
const returned=(name,f=frame,source=sexp(f))=>
  `(RWaitReturned ${JSON.stringify(`${voiceRoot}/${name}`)} ${intention(f)} ${source} ${state(f[1])})`;
const voiceProgram=`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`+
  `!(result canonical ${returned('canonical')})\n`+
  `!(result missing-frame ${returned('missing-frame',frame,'source-frame-unavailable')})\n`+
  `!(result neutral ${returned('neutral',neutralFrame)})\n`+
  `!(result restored ${returned('restored')})\n`;
const voiceRun=runNative('voice',voiceProgram,90000);
const head=x=>Array.isArray(x)?x[0]:null;
const disposition=x=>head(x)==='voice-result'?x[2]:x;
const field=(x,name)=>x.find(value=>Array.isArray(value)&&value[0]===name);
const semantic=x=>{
  const i=field(x,'intention')[1],o=field(x,'selected-expression')[1];
  const a=field(x,'fresh-audit')[1];
  return {wanted:i[4].map(value=>JSON.stringify(value[1])).sort(),
    clauses:o[1].slice().sort(),standing:a[3],authority:x.at(-1)};
};
const certificate=disposition(voiceRun.products.canonical);
const restoredCertificate=disposition(voiceRun.products.restored);
const voicePassed=voiceRun.process.status===0&&voiceRun.process.stderr===''&&
  head(certificate)==='expression-certificate-v1'&&certificate.at(-1)==='no-emission-authority'&&
  head(disposition(voiceRun.products['missing-frame']))==='expression-incomplete'&&
  head(disposition(voiceRun.products.neutral))==='expression-certificate-v1'&&
  JSON.stringify(semantic(disposition(voiceRun.products.neutral)))===JSON.stringify(semantic(certificate))&&
  JSON.stringify(restoredCertificate)===JSON.stringify(certificate);

if(!voicePassed){
  const verdict={status:'FAIL',gate:'G33',revision:'R7',continuity_crossed:true,
    first_discontinuity:'current-relational-voice-reentry',stopped_at_first_discontinuity:true,
    later_phases_executed:false,...resources};
  save(`${dir}/observations.json`,{schema:'miter-g33-r7-observations-v1',
    continuity:{native:continuityRun.products.continuity,typed,answer,passed:true},
    voice:{products:voiceRun.products,passed:false},verdict});save(`${dir}/verdict.json`,verdict);
  console.log(JSON.stringify(verdict));process.exit(1);
}

save(`${runtime}/phase-lineage.json`,{schema:'miter-g33-r7-phase-lineage-v1',
  runtime_identity:`g33-r7-${tag}`,
  continuity_product_sha256:hash(Buffer.from(JSON.stringify(continuityRun.products.continuity))),
  continuity_answer_sha256:hash(fs.readFileSync(`${output}/answer.json`)),
  voice_product_sha256:hash(Buffer.from(JSON.stringify(voiceRun.products.canonical))),
  standing:'mechanical-causal-join-not-semantic-authority'});

const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
const traceRows=reactorRoot=>{
  const path=`${reactorRoot}/trace.jsonl`;if(!fs.existsSync(path))return [];
  return fs.readFileSync(path,'utf8').split('\n').filter(Boolean).map(line=>JSON.parse(line));
};
async function waitTrace(reactorRoot,predicate,label,timeout=15000){
  const end=Date.now()+timeout;
  while(Date.now()<end){const rows=traceRows(reactorRoot);if(predicate(rows))return rows;await wait(20);}
  throw Error(`timeout waiting for ${label}`);
}
function sendEvent(reactorRoot,event){
  const inbox=`${reactorRoot}/inbox`;fs.mkdirSync(inbox,{recursive:true});
  save(`${inbox}/${event.id}.json`,{schema:'miter-reactor-input-v1',...event,
    sent_at:new Date().toISOString()});
}
function prepareReactor(reactorRoot,copyLineage){
  fs.mkdirSync(`${reactorRoot}/inbox`,{recursive:true});fs.mkdirSync(`${reactorRoot}/store`,{recursive:true});
  if(copyLineage){
    if(reactorRoot!==runtime)throw Error('canonical reactor must reuse integrated runtime');
  }else{
    fs.writeFileSync(`${reactorRoot}/store/trajectory.jsonl`,'');
    fs.writeFileSync(`${reactorRoot}/store/trajectory.lock`,'');
  }
  save(`${reactorRoot}/obligations.json`,{obligations:[]});
}
async function runReactor(name,reactorRoot,event,expectWake){
  prepareReactor(reactorRoot,name==='canonical');
  const metta=`${dir}/reactor-${name}.metta`;
  save(metta,`!(import! &self "${root}/src/bootstrap_reactor.metta")\n`+
    `!(ReactorStart "${reactorRoot}" "${reactorRoot}/reactor-integrity.json")\n`);
  const started=Date.now(),child=spawn(swi,['--stack_limit=2g','-q','-s',
    `${petta}/src/main.pl`,'--',metta,'silent'],{cwd:root,stdio:['ignore','pipe','pipe']});
  let stdout='',stderr='';child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const closed=new Promise(resolve=>child.on('close',(status,signal)=>resolve({status,signal})));
  await waitTrace(reactorRoot,rows=>rows.filter(x=>x.kind==='quiescent-ready').length>=1,
    `${name} initial readiness`);
  sendEvent(reactorRoot,event);
  if(expectWake){
    await waitTrace(reactorRoot,rows=>rows.some(x=>x.kind==='wake')&&
      rows.filter(x=>x.kind==='quiescent-ready').length>=2,`${name} wake and renewed readiness`);
  }else{
    await waitTrace(reactorRoot,rows=>rows.some(x=>x.kind==='unauthorized-event'),
      `${name} unauthorized provenance`);
  }
  sendEvent(reactorRoot,{...fixture.reactor.stop,id:`${fixture.reactor.stop.id}-${name}`});
  const timeout=wait(10000).then(()=>({timeout:true}));
  let result=await Promise.race([closed,timeout]);
  if(result.timeout){child.kill('SIGTERM');result=await closed;result.timeout=true;}
  save(`${dir}/reactor-${name}.stdout`,stdout);save(`${dir}/reactor-${name}.stderr`,stderr);
  save(`${dir}/reactor-${name}-process.json`,{...result,elapsed_ms:Date.now()-started});
  const rows=traceRows(reactorRoot);save(`${dir}/reactor-${name}-trace.json`,rows);
  return {process:result,stdout,stderr,rows};
}

const canonicalReactor=await runReactor('canonical',runtime,fixture.reactor.contact,true);
const severedRoot=`${dir}/severed-runtime`;
const severedReactor=await runReactor('severed',severedRoot,fixture.reactor.severed,false);
const afterReactorLines=fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
const rna=read(`${runtime}/rna/${fixture.reactor.contact.id}.json`);
const canonicalKinds=canonicalReactor.rows.map(x=>x.kind);
const severedKinds=severedReactor.rows.map(x=>x.kind);
const reactorPassed=canonicalReactor.process.status===0&&!canonicalReactor.process.timeout&&
  canonicalReactor.stderr===''&&canonicalKinds.filter(x=>x==='quiescent-ready').length===2&&
  canonicalKinds.filter(x=>x==='wake').length===1&&canonicalKinds.includes('RNA-created')&&
  canonicalKinds.includes('reactor-stopped')&&rna.status==='completed'&&rna.budget===0&&
  severedReactor.process.status===0&&!severedReactor.process.timeout&&severedReactor.stderr===''&&
  severedKinds.includes('unauthorized-event')&&!severedKinds.includes('RNA-created')&&
  !severedKinds.includes('wake')&&severedKinds.includes('reactor-stopped');

const observations={schema:'miter-g33-r7-observations-v1',runtime_identity:`g33-r7-${tag}`,
  continuity:{native:continuityRun.products.continuity,typed,answer,
    trajectory_before_lines:beforeLines,trajectory_after_lines:afterContinuityLines,passed:true},
  voice:{canonical:voiceRun.products.canonical,missing_frame:voiceRun.products['missing-frame'],
    neutral:voiceRun.products.neutral,restored:voiceRun.products.restored,passed:true},
  reactor:{canonical_kinds:canonicalKinds,severed_kinds:severedKinds,rna,
    trajectory_before_lines:afterContinuityLines,trajectory_after_lines:afterReactorLines,
    passed:reactorPassed},
  phase_lineage:read(`${runtime}/phase-lineage.json`),historical_verdict_used_as_product:false,
  builder_supplied_native_standing:false,core_source_modified:false,...resources};
save(`${dir}/observations.json`,observations);

const sourceFiles=['docs/gates/G33/R7/plan.json','docs/gates/G33/R7/plan.md',
  'docs/gates/G33/R7/reassessment.md','docs/gates/G33/R7/expected-run-contract.json',
  'tests/fixtures/g33_r7/cases.json','scripts/g33_r7/run.mjs','scripts/g33_r7/verify.mjs',
  'src/bootstrap_continuity_intent_v1.metta','src/continuity_intent_v1.metta','src/continuity.metta',
  'effect_membranes/miter_continuity_intent_v1.pl','effect_membranes/miter_resume.pl',
  'src/bootstrap_relational_voice.metta','src/relational_voice.metta',
  'src/relational_voice_repair_v1.metta','src/voice_construction.metta',
  'effect_membranes/miter_relational_voice_v2.pl',
  'effect_membranes/miter_relational_voice_repair_v1.pl','src/bootstrap_reactor.metta',
  'src/reactor.metta','effect_membranes/miter_reactor.pl','effect_membranes/miter_integrity.pl',
  'constitution/authority-manifest.json','config/reactor-profile.json',
  'config/relational-voice-repair-runtime-v1.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r7-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
const verdict={status:reactorPassed?'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R7',
  clean_lineage_crosses_current_continuity_and_repaired_voice:true,
  current_reactor_records_receptive_readiness_without_inference:reactorPassed,
  fresh_contact_wakes_bounded_rna_and_explicit_stop_terminates:reactorPassed,
  provenance_severance_blocks_synthetic_perpetual_work:reactorPassed,
  first_discontinuity:reactorPassed?'none-observed':'current-reactor-readiness-reentry',
  later_g33_development_phases_executed:false,...resources,
  limits:'Clean finite composition through readiness only; historical reactor event species, supplied steps and hash work remain mechanics, not complete Soul navigation or S-606/S-705 cognition.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));
if(!reactorPassed)process.exitCode=1;
