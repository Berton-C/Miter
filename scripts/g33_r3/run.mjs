// G33 R3 clean-start integration diagnostic. Builder code owns isolation,
// byte capture and comparison only; current native consumers own products.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {base,sexp,parse} from '../sc04/fixtures.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';
assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R3/attempt-${tag}`;
const dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);
fs.mkdirSync(dir,{recursive:true});

const counts={localhost_model_calls:0,external_network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,external_effects:0};
process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL-RUNNER',message:error.message,
    stack:error.stack,...counts});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R3/plan.json');
assert.equal(opening.plan_commit,'7c91aab8ec2fceebbfdcc968904491f19d3592ec');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const fixture=read(`${root}/tests/fixtures/g33_r3/encounter.json`);
const source=`${root}/evidence/20260902T063347Z-G11`;
const runtime=`${dir}/runtime`,store=`${runtime}/store`,capsules=`${runtime}/capsules`;
const output=`${runtime}/outputs`,voiceRoot=`${runtime}/relational-voice`;
fs.mkdirSync(store,{recursive:true});fs.mkdirSync(output,{recursive:true});
for(const name of ['memories','memory-bodies','objects']){
  const from=`${source}/canonical/store/${name}`;
  if(fs.existsSync(from))fs.cpSync(from,`${store}/${name}`,{recursive:true});
}
fs.copyFileSync(`${source}/base-trajectory.jsonl`,`${store}/trajectory.jsonl`);
fs.writeFileSync(`${store}/trajectory.lock`,'');
fs.cpSync(`${source}/capsules`,capsules,{recursive:true});
fs.copyFileSync(`${source}/outputs/project-registry.json`,`${runtime}/project-registry.json`);
const beforeLines=fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
const context={schema:'miter-resume-context-v1',text:fixture.continuity.text,
  request_id:`g33-r3-${tag}`,query_tag:`g33-r3-${tag}`,
  occurred_at:'2026-12-01T07:00:00Z',chat_context:[],
  principal_scope:'principal:g08-human',audience_scope:'scope:g08-private-project',
  registry_ref:`${runtime}/project-registry.json`,
  registry_sha256:hash(fs.readFileSync(`${runtime}/project-registry.json`)),
  memory_store:store,capsule_store:capsules,output_dir:output,
  capsule_output:`${output}/capsule.json`,
  model_config:`${root}/config/local/g03-model-profiles.json`};
save(`${runtime}/context.json`,context);

function runNative(name,program,timeout=130000){
  const metta=`${dir}/${name}.metta`;
  save(metta,program);
  const started=Date.now();
  const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',metta,'silent'],
    {cwd:root,encoding:'utf8',timeout,maxBuffer:128*1024*1024});
  save(`${dir}/${name}.stdout`,p.stdout??'');save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,error:p.error?.message,
    elapsed_ms:Date.now()-started});
  assert.equal(p.status,0,`${name} status`);assert.equal(p.stderr,'',`${name} stderr`);
  const products={};
  for(const line of (p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;
    const row=parse(line);assert.equal(row[0],'result');products[row[1]]=row[2];
  }
  assert(Object.keys(products).length,`${name} products`);return products;
}

const continuity=runNative('continuity',
  `!(import! &self "${root}/src/bootstrap_continuity_intent_v1.metta")\n`+
  `!(result continuity (ContinuityRNA "${runtime}/context.json" canonical))\n`);
if(fs.existsSync(`${output}/continuity-reading-timing.json`))counts.localhost_model_calls++;
const typed=fs.existsSync(`${output}/continuity-reading-typed.json`)?
  read(`${output}/continuity-reading-typed.json`):null;
const answer=fs.existsSync(`${output}/answer.json`)?read(`${output}/answer.json`):null;
const afterLines=fs.readFileSync(`${store}/trajectory.jsonl`,'utf8').trim().split('\n').length;

const c=base();
const request=c.nodes.find(x=>x[1]==='request-source')[6][2];
const participation=c.nodes.find(x=>x[1]==='commitment-source')[6][2];
assert.equal(request,fixture.voice.request_source);
assert.equal(participation,fixture.voice.participation_source);
const args=[c.scope,c.nodes,c.registry,c.current,c.operations,c.target,c.budget,c.proposals]
  .map(sexp).join(' ');
const ground=`(GroundLanguage ${args})`;
const intent=`(RIntend g33-r3-voice ${ground})`;
const auditProgram=`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`+
  `!(result grounding ${ground})\n`+
  `!(result intention ${intent})\n`+
  `!(result faithful (RAudit ${intent} ${sexp(c.scope)} ${sexp(c.scope)} ${sexp(fixture.voice.faithful_clauses)}))\n`+
  `!(result neutral (RAudit ${intent} ${sexp(c.scope)} ${sexp(c.scope)} ${sexp(fixture.voice.neutral_order_clauses)}))\n`+
  `!(result distorted (RAudit ${intent} ${sexp(c.scope)} ${sexp(c.scope)} ${sexp(fixture.voice.distorting_clauses)}))\n`+
  `!(result disposition (RDisposition (RAudit ${intent} ${sexp(c.scope)} ${sexp(c.scope)} ${sexp(fixture.voice.distorting_clauses)}) 1))\n`;
const audits=runNative('voice-audit',auditProgram,60000);

// Observe the actual current public relational voice entry as a separate
// generated rendering. It remains an audit product and has no emission authority.
const live=runNative('voice-live',
  `!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`+
  `!(result live (RRun "${voiceRoot}" g33-r3-live ${ground}))\n`);
if(fs.existsSync(`${voiceRoot}/worker-started.json`)||fs.existsSync(`${voiceRoot}/raw.json`))
  counts.localhost_model_calls++;

const repairRefs=[];
for(const file of ['src/relational_voice.metta','src/voice_construction.metta']){
  fs.readFileSync(`${root}/${file}`,'utf8').split('\n').forEach((line,index)=>{
    if(line.includes('repair-request'))repairRefs.push({file,line:index+1,text:line.trim()});
  });
}
const continuationImplemented=repairRefs.some(row=>
  row.file!=='src/relational_voice.metta'||row.line!==141);
const membraneRefs=[];
fs.readFileSync(`${root}/effect_membranes/miter_relational_voice.pl`,'utf8')
  .split('\n').forEach((line,index)=>{
    if(line.includes('evidence/SC05/')||line.includes('rv_verified'))
      membraneRefs.push({file:'effect_membranes/miter_relational_voice.pl',
        line:index+1,text:line.trim()});
  });
const continuityPassed=continuity.continuity==='continuity-answer-stored'&&
  typed?.standing==='generated-source-verified-candidate'&&
  answer?.certificate==='exact-continuity'&&afterLines===beforeLines+2;
const voiceObserved=audits.intention?.[0]==='voice-intention'&&
  audits.faithful?.[3]==='faithful'&&audits.neutral?.[3]==='faithful'&&
  audits.distorted?.[3]!=='faithful'&&audits.disposition?.[0]==='repair-request';
const publicEntryStarted=live.live?.[0]!=='expression-storage-fault'&&
  live.live?.[0]!=='expression-transport-incomplete';
const firstDiscontinuity=!publicEntryStarted?
  'relational-voice-membrane-confined-to-historical-sc05-evidence-root':
  (!continuationImplemented?
    'relational-voice-repair-construction-comparison-reaudit-certification':'none-observed');

const observations={schema:'miter-g33-r3-observations-v1',clean_runtime_root:true,
  empty_model_context:true,continuity:{native:continuity.continuity,typed,answer,
    trajectory_before_lines:beforeLines,trajectory_after_lines:afterLines,passed:continuityPassed},
  voice:{grounding:audits.grounding,intention:audits.intention,faithful_audit:audits.faithful,
    neutral_audit:audits.neutral,distorted_audit:audits.distorted,
    distorted_disposition:audits.disposition,distorted_origin:fixture.voice.distorting_origin,
    live_product:live.live,repair_request_references:repairRefs,
    membrane_boundary_references:membraneRefs,public_entry_started:publicEntryStarted,
    native_repair_continuation_implemented:continuationImplemented,observed:voiceObserved},
  first_semantic_discontinuity:firstDiscontinuity,later_g33_phases_executed:false,
  legacy_voice_policy_loaded:false,builder_supplied_repair:false,
  historical_verdict_used_as_native_product:false,...counts};
save(`${dir}/observations.json`,observations);
const verdict={status:continuityPassed&&voiceObserved&&publicEntryStarted&&continuationImplemented?
  'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R3',continuity_crossed:continuityPassed,
  relational_voice_pure_consumers_observed:voiceObserved,
  relational_voice_public_entry_started:publicEntryStarted,
  first_semantic_discontinuity:firstDiscontinuity,
  stopped_at_first_semantic_discontinuity:!publicEntryStarted||!continuationImplemented,
  later_phases_executed:false,...counts,
  limits:'R3 integrates only clean-start continuity and the corrected relational voice boundary. A FAIL at native repair continuation makes no claim about later G33 phases.'};
save(`${dir}/verdict.json`,verdict);
const sourceFiles=['docs/gates/G33/R3/plan.json','docs/gates/G33/R3/expected-run-contract.json',
  'tests/fixtures/g33_r3/encounter.json','scripts/g33_r3/run.mjs',
  'src/bootstrap_continuity_intent_v1.metta','src/continuity_intent_v1.metta','src/continuity.metta',
  'effect_membranes/miter_continuity_intent_v1.pl','effect_membranes/miter_resume.pl',
  'src/bootstrap_relational_voice.metta','src/grounded_language.metta','src/relational_voice.metta',
  'effect_membranes/miter_relational_voice.pl','effect_membranes/miter_llm.pl'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r3-freeze-v1',git_head:execFileSync('git',
  ['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),plan_commit:opening.plan_commit,
  petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...counts});
console.log(JSON.stringify(verdict));
