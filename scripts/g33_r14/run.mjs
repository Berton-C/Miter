// G33 R14 final clean-start builder harness. It supplies isolation, frozen
// stimuli, process lifecycle and capture. Current native consumers supply the
// semantic products. Historical generation and live effects are only re-read.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta,parse,sexp} from '../g22_v2/common.mjs';
import {sourceFrame,reorderedFrame} from '../g33_r5/cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R14/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const fixture=read(`${root}/tests/fixtures/g33_r14/cases.json`);
const resources={localhost_model_calls:0,chroma_read_queries:0,chroma_mutations:0,
  openrouter_calls:0,mattermost_requests:0,credential_lookups:0,
  private_memory_reads:0,human_emissions:0,external_effects:0};
process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL-RUNNER',message:error.message,
    stack:error.stack,...resources});console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R14/plan.json');
assert.equal(opening.plan_commit,'32e8b7153387491007818038513fb91848ebe61f');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const clean=execFileSync('git',['status','--short'],{cwd:root,encoding:'utf8'}).split('\n').filter(Boolean);
const expectedUserChanges=[
  ' M docs/gates/G28/R1/completion.md','?? effect_membranes/miter_trials.pl',
  '?? evidence/20260902T090100Z-G22/','?? scripts/g22/','?? src/bootstrap_trials.metta',
  '?? src/trials.metta','?? tests/fixtures/g22_canonical.metta','?? tests/fixtures/g22_cases.json',
  '?? tests/fixtures/g22_parent.metta','?? tests/fixtures/g22_severed.metta'];
for(const line of clean)assert(expectedUserChanges.includes(line)||
  line.startsWith(' M effect_membranes/miter_development_helix_v1.pl')||
  line.startsWith('?? effect_membranes/miter_final_integration_v1.pl')||
  line.startsWith('?? src/bootstrap_final_integration_v1.metta')||
  line.startsWith('?? src/final_integration_v1.metta')||
  line.startsWith('?? docs/gates/G33/R14/')||
  line.startsWith('?? scripts/g33_r14/')||line.startsWith('?? tests/fixtures/g33_r14/')||
  line.startsWith('?? evidence/G33/R14/'),`unexpected pre-run change: ${line}`);

function products(stdout){const out={};for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
  if(!line.startsWith('(result '))continue;const row=parse(line);out[row[1]]=row[2];}return out;}
function runNative(name,program,timeout=180000,maxBuffer=256*1024*1024){
  const path=`${dir}/${name}.metta`;save(path,program);const started=Date.now();
  const p=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',path,'silent'],
    {cwd:root,encoding:'utf8',timeout,maxBuffer});
  save(`${dir}/${name}.stdout`,p.stdout??'');save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,error:p.error?.message??null,
    elapsed_ms:Date.now()-started,stdout_bytes:Buffer.byteLength(p.stdout??'')});
  assert.equal(p.status,0,`${name}: ${p.stderr}`);assert.equal(p.stderr,'',name);
  const result=products(p.stdout??'');save(`${dir}/${name}-products.json`,result);return result;
}
const bootFinal=`!(import! &self "${root}/src/bootstrap_final_integration_v1.metta")\n`;
const truth=value=>value===true||value==='true';
// The general fixture serializer intentionally emits symbol-like strings bare.
// A SHA-256 beginning with digits and containing "e" can instead be parsed as
// an overflowing number, so the final evidence join quotes exact hash strings.
const traceSexp=value=>Array.isArray(value)?`(${value.map(traceSexp).join(' ')})`:
  typeof value==='string'&&/^[0-9a-f]{64}$/.test(value)?JSON.stringify(value):sexp(value);

// Phase 1: current protected Soul consumer and an exact genome-severed arm.
const soulBoot=`!(import! &self "${root}/src/bootstrap_reactor.metta")\n`;
const soul=runNative('soul',soulBoot+
  `!(result rationality (SoulRationalityAudit))\n`+
  `!(result startup (SoulBoot "${dir}/soul-integrity.json"))\n`);
const soulSevered=runNative('soul-severed',
  `!(import! &self "${root}/tests/fixtures/g32_r2/soul_severed.metta")\n`+
  `!(result rationality (SoulRationalityAudit))\n`);
const soulRestored=runNative('soul-restored',soulBoot+`!(result rationality (SoulRationalityAudit))\n`);
assert.equal(truth(soul.rationality),true);assert.equal(soul.startup,'soul-ready');
assert.equal(truth(soulSevered.rationality),false);assert.equal(truth(soulRestored.rationality),true);

// Phase 2: fresh empty-context continuity over an evidence-owned copy.
const continuitySource=`${root}/evidence/20260902T063347Z-G11`;
function prepareContinuity(name){
  const runtime=`${dir}/runtime/${name}`,store=`${runtime}/store`,capsules=`${runtime}/capsules`;
  const output=`${runtime}/outputs`;fs.mkdirSync(store,{recursive:true});fs.mkdirSync(output,{recursive:true});
  for(const item of ['memories','memory-bodies','objects']){
    const from=`${continuitySource}/canonical/store/${item}`;
    if(fs.existsSync(from))fs.cpSync(from,`${store}/${item}`,{recursive:true});
  }
  fs.copyFileSync(`${continuitySource}/base-trajectory.jsonl`,`${store}/trajectory.jsonl`);
  fs.writeFileSync(`${store}/trajectory.lock`,'');fs.cpSync(`${continuitySource}/capsules`,capsules,{recursive:true});
  fs.copyFileSync(`${continuitySource}/outputs/project-registry.json`,`${runtime}/project-registry.json`);
  const context={schema:'miter-resume-context-v1',text:fixture.continuity.text,
    request_id:`g33-r14-${name}-${tag}`,query_tag:`g33-r14-${name}-${tag}`,
    occurred_at:'2026-12-03T07:00:00Z',chat_context:[],principal_scope:'principal:g08-human',
    audience_scope:'scope:g08-private-project',registry_ref:`${runtime}/project-registry.json`,
    registry_sha256:hash(fs.readFileSync(`${runtime}/project-registry.json`)),memory_store:store,
    capsule_store:capsules,output_dir:output,capsule_output:`${output}/capsule.json`,
    model_config:`${root}/config/local/g03-model-profiles.json`};
  save(`${runtime}/context.json`,context);return {runtime,store,capsules,output,context:`${runtime}/context.json`};
}
const canonicalMemory=prepareContinuity('canonical');
const beforeContinuity=fs.readFileSync(`${canonicalMemory.store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
const continuity=runNative('continuity',
  `!(import! &self "${root}/src/bootstrap_continuity_intent_v1.metta")\n`+
  `!(result continuity (ContinuityRNA "${canonicalMemory.context}" canonical))\n`,180000);
if(fs.existsSync(`${canonicalMemory.output}/continuity-reading-timing.json`))resources.localhost_model_calls=1;
assert.equal(continuity.continuity,'continuity-answer-stored');
const answer=read(`${canonicalMemory.output}/answer.json`),typed=read(`${canonicalMemory.output}/continuity-reading-typed.json`);
assert.equal(answer.certificate,'exact-continuity');assert.equal(answer.chat_model_context.length,0);
assert.equal(answer.semantic_available,true);assert.equal(typed.standing,'generated-source-verified-candidate');
for(const [key,value] of Object.entries(fixture.continuity))if(key!=='text')assert.equal(answer.exact_state[key],value,key);
resources.chroma_read_queries=1;
const afterContinuity=fs.readFileSync(`${canonicalMemory.store}/trajectory.jsonl`,'utf8').trim().split('\n').length;
assert.equal(afterContinuity,beforeContinuity+2);

function continuityArm(name,mode){
  const memory=prepareContinuity(name);
  const p=runNative(`continuity-${name}`,
    `!(import! &self "${root}/src/bootstrap_continuity_intent_v1.metta")\n`+
    `!(result product (BookContinuityRNA "${memory.context}" ${mode}))\n`,120000);
  const armAnswer=read(`${memory.output}/answer.json`);return {native:p.product,answer:armAnswer,memory};
}
const capsuleSevered=continuityArm('capsule-severed','capsule-off');resources.chroma_read_queries++;
const chromaSevered=continuityArm('chroma-severed','chroma-off');
const continuityRestored=continuityArm('restored','canonical');resources.chroma_read_queries++;
assert.equal(capsuleSevered.answer.certificate,'non-authoritative-recall');
assert.equal(capsuleSevered.answer.semantic_available,true);
assert.equal(chromaSevered.answer.certificate,'exact-continuity');
assert.equal(chromaSevered.answer.semantic_available,false);
assert.equal(continuityRestored.answer.certificate,'exact-continuity');
const continuityProof=['continuity-proof','exact-continuity',
  hash(fs.readFileSync(`${canonicalMemory.output}/answer.json`)),answer.semantic_result,'empty-model-context'];

// Phase 3: current relational VoiceRNA repair over a disclosed altered return.
const frame=sourceFrame(),neutralFrame=reorderedFrame(),scope=frame[1];
const voiceRoot=`${dir}/runtime/relational-voice`;for(const name of ['canonical','missing','neutral','restored'])
  fs.mkdirSync(`${voiceRoot}/${name}`,{recursive:true});
const request=fixture.voice.request_id,clauses=fixture.voice.returned_clauses;
const intention=f=>`(RIntend ${request} (DGround ${sexp(f)}))`;
const state=f=>`(rendered ${request} ${sexp(f[1])} ${sexp(clauses)} "g33-r14-disclosed-returned-state")`;
const returned=(name,f=frame,source=sexp(f))=>
  `(RWaitReturned ${JSON.stringify(`${voiceRoot}/${name}`)} ${intention(f)} ${source} ${state(f)})`;
const voiceArm=(name,expression)=>runNative(`voice-${name}`,
  `!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`+
  `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_final_integration_v1.pl" `+
  `(g33_r14_voice_projection))\n`+
  `!(let $v ${expression} (result observation (g33_r14_voice_projection $v)))\n`,180000).observation;
const canonicalVoice=voiceArm('canonical',returned('canonical'));
const missingVoice=voiceArm('missing',returned('missing',frame,'source-frame-unavailable'));
const neutralVoice=voiceArm('neutral',returned('neutral',neutralFrame));
const restoredVoice=voiceArm('restored',returned('restored'));
const canonicalVoiceProof=canonicalVoice[1],neutralVoiceProof=neutralVoice[1];
assert.equal(canonicalVoiceProof[0],'voice-proof');
assert.equal(canonicalVoiceProof[1],'expression-certificate-v1');
assert.equal(canonicalVoiceProof[2],'no-emission-authority');
assert.equal(missingVoice[0],'voice-held-observation');assert.equal(missingVoice[1],'expression-incomplete');
assert.equal(neutralVoiceProof[0],'voice-proof');assert.equal(restoredVoice[1][0],'voice-proof');
const semantic=x=>{assert.equal(x[2][0],'semantic-projection');return {
  wanted:x[2][1].map(value=>JSON.stringify(value)).sort(),
  clauses:x[2][2].map(value=>JSON.stringify(value)).sort(),standing:x[2][3],authority:x[2][4]};};
assert.deepEqual(semantic(neutralVoice),semantic(canonicalVoice));

// Phase 4: actual recurring readiness, contact wake, bounded RNA and stop.
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
const traceRows=r=>{const p=`${r}/trace.jsonl`;return fs.existsSync(p)?fs.readFileSync(p,'utf8').split('\n').filter(Boolean).map(JSON.parse):[];};
async function waitTrace(r,predicate,label,timeout=20000){const end=Date.now()+timeout;while(Date.now()<end){
  const rows=traceRows(r);if(predicate(rows))return rows;await wait(25);}throw Error(`timeout waiting for ${label}`);}
function sendEvent(r,event){fs.mkdirSync(`${r}/inbox`,{recursive:true});save(`${r}/inbox/${event.id}.json`,
  {schema:'miter-reactor-input-v1',...event,sent_at:new Date().toISOString()});}
async function reactorRun(name,r,event,expectWake){
  fs.mkdirSync(`${r}/inbox`,{recursive:true});fs.mkdirSync(`${r}/store`,{recursive:true});
  if(!fs.existsSync(`${r}/store/trajectory.jsonl`)){fs.writeFileSync(`${r}/store/trajectory.jsonl`,'');fs.writeFileSync(`${r}/store/trajectory.lock`,'');}
  save(`${r}/obligations.json`,{obligations:[]});const program=`${dir}/reactor-${name}.metta`;
  save(program,`!(import! &self "${root}/src/bootstrap_reactor.metta")\n`+
    `!(ReactorStart "${r}" "${r}/reactor-integrity.json")\n`);
  const started=Date.now(),child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,stdio:['ignore','pipe','pipe']});let stdout='',stderr='';child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const closed=new Promise(resolve=>child.on('close',(status,signal)=>resolve({status,signal})));
  await waitTrace(r,rows=>rows.some(x=>x.kind==='quiescent-ready'),`${name} readiness`);sendEvent(r,event);
  if(expectWake)await waitTrace(r,rows=>rows.some(x=>x.kind==='wake')&&rows.filter(x=>x.kind==='quiescent-ready').length>=2,`${name} wake`);
  else await waitTrace(r,rows=>rows.some(x=>x.kind==='unauthorized-event'),`${name} rejection`);
  sendEvent(r,{...fixture.reactor.stop,id:`${fixture.reactor.stop.id}-${name}`});
  let result=await Promise.race([closed,wait(12000).then(()=>({timeout:true}))]);
  if(result.timeout){child.kill('SIGTERM');result={...await closed,timeout:true};}
  save(`${dir}/reactor-${name}.stdout`,stdout);save(`${dir}/reactor-${name}.stderr`,stderr);
  save(`${dir}/reactor-${name}-process.json`,{...result,elapsed_ms:Date.now()-started});
  const rows=traceRows(r);save(`${dir}/reactor-${name}-trace.json`,rows);return {result,rows,stderr};
}
const readinessRoot=`${dir}/runtime/readiness`,readiness=await reactorRun('canonical',readinessRoot,fixture.reactor.contact,true);
const busySevered=await reactorRun('severed',`${dir}/severed/readiness`,fixture.reactor.severed,false);
const kinds=readiness.rows.map(x=>x.kind),severedKinds=busySevered.rows.map(x=>x.kind);
assert.equal(readiness.result.status,0);assert.equal(readiness.result.timeout,undefined);assert.equal(readiness.stderr,'');
assert.equal(kinds.filter(x=>x==='quiescent-ready').length,2);assert.equal(kinds.filter(x=>x==='wake').length,1);
assert(kinds.includes('RNA-created')&&kinds.includes('reactor-stopped'));
assert(severedKinds.includes('unauthorized-event')&&!severedKinds.includes('RNA-created')&&!severedKinds.includes('wake'));
const readinessProduct=['readiness-observation','quiescent-ready','wake','reactor-stopped',
  ['wait-cycles',kinds.filter(x=>x==='quiescent-ready').length],['model-calls',0]];
const readinessProof=runNative('readiness-proof',bootFinal+
  `!(result proof (G33R14ReadinessProof ${sexp(readinessProduct)}))\n`).proof;
assert.equal(readinessProof[0],'readiness-proof');

// Phases 5-8: current compact development/trial/NAL/NACE and restart.
const devSources=fixture.development_sources;
for(const source of Object.values(devSources))assert.equal(hash(fs.readFileSync(source.path)),source.sha256,source.path);
const devLoadBearing=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','ACCEPTANCE.md','BUILD_FIDELITY_PROTOCOL.md',
  'docs/gates/G33/R14/plan.json','src/bootstrap_modules.metta','src/bootstrap_development_helix_v2.metta',
  'src/development_helix_v2.metta','src/development_helix_v1.metta','src/development_reactor_v1.metta',
  'src/development_cycle.metta','src/reactor.metta','src/soul.metta','src/voice_trials_v2.metta',
  'src/nal_revision_v1.metta','src/nace_v2.metta','src/nace_selection_v1.metta','constitution/soul.metta',
  'effect_membranes/miter_development_helix_v1.pl','effect_membranes/miter_development_proof_v1.pl',
  'effect_membranes/miter_development_reactor_v1.pl','effect_membranes/miter_reactor.pl',
  'effect_membranes/miter_integrity.pl','effect_membranes/miter_store.pl','tests/fixtures/g33_r12/authorization.json'];
function prepareDevelopment(runtime,sources=devSources,reverse=false){
  fs.mkdirSync(runtime,{recursive:true});fs.mkdirSync(`${runtime}/store`);fs.mkdirSync(`${runtime}/inbox`);
  const local=structuredClone(sources);fs.copyFileSync(sources.candidate_source.path,`${runtime}/candidate.json`);
  fs.copyFileSync(sources.candidate_lineage.path,`${runtime}/candidate-lineage.json`);
  local.candidate_source.path=`${runtime}/candidate.json`;local.candidate_lineage.path=`${runtime}/candidate-lineage.json`;
  fs.writeFileSync(`${runtime}/store/trajectory.jsonl`,'');fs.writeFileSync(`${runtime}/store/trajectory.lock`,'');
  save(`${runtime}/input.json`,{schema:'miter-g33-r14-input-v1',...local});
  fs.copyFileSync(`${root}/tests/fixtures/g33_r12/authorization.json`,`${runtime}/authorization.json`);
  const paths=[...devLoadBearing.map(x=>`${root}/${x}`),`${runtime}/input.json`,`${runtime}/authorization.json`,
    ...Object.values(local).map(x=>x.path)];const files=pins([...new Set(paths)]);if(reverse)files.reverse();
  save(`${runtime}/manifest.json`,{schema:'miter-g33-r14-manifest-v1',files});
}
async function developmentReactor(runtime){
  const program=`${dir}/development-reactor.metta`;save(program,
    `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
    `!(ReactorStart "${runtime}" "${runtime}/integrity-report.json")\n`);
  const child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',program,'silent'],
    {cwd:root,stdio:['ignore','pipe','pipe']});let stdout='',stderr='';child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const closed=new Promise(resolve=>child.on('close',(status,signal)=>resolve({status,signal}))),deadline=Date.now()+240000;
  while(Date.now()<deadline&&!fs.existsSync(`${runtime}/final.json`))await wait(50);
  assert(fs.existsSync(`${runtime}/final.json`),'development final absent');
  sendEvent(runtime,{id:'g33-r14-development-stop',kind:'stop',provenance:'direct-contact',obligation:'none',steps:1});
  let result=await Promise.race([closed,wait(30000).then(()=>({timeout:true}))]);
  if(result.timeout){child.kill('SIGTERM');result={...await closed,timeout:true};}
  save(`${dir}/development-reactor.stdout`,stdout);save(`${dir}/development-reactor.stderr`,stderr);
  save(`${dir}/development-reactor-process.json`,result);assert.equal(result.status,0,stderr);assert.equal(result.timeout,undefined);assert.equal(stderr,'');
}
const developmentRoot=`${dir}/development`,neutralRoot=`${dir}/neutral/development`,naceSeveredRoot=`${dir}/severed/nace`;
prepareDevelopment(developmentRoot);prepareDevelopment(neutralRoot,devSources,true);prepareDevelopment(naceSeveredRoot);
const devPreflight=runNative('development-preflight',
  `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(result root (dh2_root_probe "${developmentRoot}"))\n`+
  `!(result input (dh2_input "${developmentRoot}"))\n`+
  `!(result traversal (dh2_root_probe "${root}/evidence/G33/R14/../R13/attempt-005/canonical"))\n`);
assert.equal(devPreflight.root,'qualified-development-root');assert.equal(devPreflight.input[0],'development-helix-v2-input');
assert.equal(devPreflight.traversal,'rejected-development-root');
await developmentReactor(developmentRoot);
const development=read(`${developmentRoot}/final.json`).native,trial=read(`${developmentRoot}/trial.json`).native;
const efficacyBefore=read(`${developmentRoot}/efficacy-before.json`).native,efficacyAfter=read(`${developmentRoot}/efficacy-after.json`).native;
assert.equal(development[0],'development-helix-proof');assert.equal(development[1],fixture.expected.development_candidate_sha256);
assert.equal(development[2],'candidate-quarantined');assert.equal(trial[3][1],fixture.expected.trial_standing);
assert.equal(trial[3][3][2],fixture.expected.trial_cases);assert.equal(trial[3][4][2],fixture.expected.expansions);
assert.equal(efficacyBefore[3].length,fixture.expected.before_maxima);assert.equal(efficacyAfter[3].length,1);
assert.equal(efficacyAfter[3][0][2],fixture.expected.after_maximum);
const restart=runNative('development-restart',
  `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(result restart (DH2Restart "${developmentRoot}"))\n`).restart;
assert.equal(restart[0],'development-helix-v2-rehydrated');assert.equal(restart[3],'no-generation-replay');
assert.equal(restart[2][3].length,1);assert.equal(restart[2][3][0][2],fixture.expected.after_maximum);
const naceSevered=runNative('nace-severed',
  `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(result result (DH2SeveredConsequence "${naceSeveredRoot}"))\n`).result;
assert.equal(naceSevered[0],'consequence-severed-proof');assert.equal(naceSevered[3][3].length,fixture.expected.before_maxima);
const developmentNeutral=runNative('development-neutral',
  `!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(result result (DH2Run "${neutralRoot}"))\n`).result;
assert.equal(developmentNeutral[0],'development-helix-proof');assert.equal(developmentNeutral[1],development[1]);
assert.deepEqual(developmentNeutral[4][4][3],efficacyAfter[3]);

// Phases 9-11: current bridge mock/identity/panic plus immutable prior live witness.
const mm=fixture.mattermost;assert.equal(hash(fs.readFileSync(mm.candidate_path)),mm.candidate_sha256);
const mmInput=read(mm.input_path).native,[,mmSource,mmVersion,,]=mmInput;
const mmView=['effect-descriptor-view',mm.candidate_sha256,'v11-7-7',
  ['body-fields','channel-id','message','pending-post-id'],['envelope-fields','idempotency-key'],
  ['field-maps',['map','idempotency-key','pending-post-id']],true,30,true];
const mattermost=runNative('mattermost-current',
  `!(import! &self "${root}/src/bootstrap_mattermost_candidate_revision_v1.metta")\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)}) (result mock $mock))\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)}) `+
    `(result standing (G31P3TrialStanding ${sexp(mmSource)} ${mmVersion} ${sexp(mmView)} $mock)))\n`);
assert.equal(mattermost.mock[0],'g31-p3-mock-observation');assert.equal(mattermost.standing[0],'g31-p3-candidate-qualified');
const mattermostMechanical=runNative('mattermost-mechanical',bootFinal+
  `!(result identity (g33_r14_identity_probe ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)} canonical))\n`+
  `!(result identity-severed (g33_r14_identity_probe ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)} severed))\n`+
  `!(result identity-restored (g33_r14_identity_probe ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)} restored))\n`+
  `!(result panic (g33_r14_panic_probe ${sexp(mm.candidate_path)} ${sexp(mm.candidate_sha256)}))\n`+
  `!(result live (g33_r14_prior_live_witness))\n`);
assert.equal(mattermostMechanical.identity[3],'accepted');assert.equal(mattermostMechanical['identity-severed'][3],'rejected');
assert.equal(mattermostMechanical['identity-severed'][5],'body-uninspected');assert.equal(mattermostMechanical['identity-restored'][3],'accepted');
assert.equal(mattermostMechanical.panic[0],'mattermost-panic-observation');assert.equal(mattermostMechanical.live[0],'prior-live-witness');
const mattermostProof=runNative('mattermost-proof',bootFinal+
  `!(result proof (G33R14MattermostProof ${sexp(mattermost.standing)} ${sexp(mattermostMechanical.identity)} `+
  `${sexp(mattermostMechanical.panic)} ${sexp(mattermostMechanical.live)}))\n`).proof;
assert.equal(mattermostProof[0],'mattermost-proof');

// Phase 12: native compact join over actual current-consumer products.
const finalTrace=runNative('final-trace',bootFinal+
  `!(result trace (G33R14FinalTrace true ${traceSexp(continuityProof)} ${traceSexp(canonicalVoiceProof)} `+
  `${traceSexp(readinessProof)} ${traceSexp(development)} ${traceSexp(restart)} ${traceSexp(mattermostProof)}))\n`).trace;
assert.equal(finalTrace[0],'g33-final-trace');assert.equal(finalTrace.at(-1),'prior-effects-not-replayed');

const phaseProducts={soul:{rationality:truth(soul.rationality),startup:soul.startup},continuity:continuityProof,
  voice:canonicalVoiceProof,readiness:readinessProof,development,restart,mattermost:mattermostProof,final:finalTrace};
const lineage=[];let parent='0'.repeat(64);for(const [phase,product] of Object.entries(phaseProducts)){
  const product_sha256=hash(Buffer.from(JSON.stringify(product)));const record={phase,parent_sha256:parent,product_sha256};
  record.link_sha256=hash(Buffer.from(JSON.stringify(record)));lineage.push(record);parent=record.link_sha256;}
save(`${dir}/phase-lineage.json`,{schema:'miter-g33-r14-phase-lineage-v1',run:`g33-r14-${tag}`,records:lineage,
  standing:'mechanical-content-addressed-lineage-not-semantic-authority'});

const observations={schema:'miter-g33-r14-observations-v1',run:`g33-r14-${tag}`,
  boot:{soul:truth(soul.rationality),startup:soul.startup,severed:truth(soulSevered.rationality),restored:truth(soulRestored.rationality),
    integrity_sha256:hash(fs.readFileSync(`${dir}/soul-integrity.json`))},
  continuity:{native:continuity.continuity,answer_sha256:continuityProof[2],certificate:answer.certificate,
    semantic_result:answer.semantic_result,empty_model_context:answer.chat_model_context.length===0,
    exact_state:answer.exact_state,trajectory_before:beforeContinuity,trajectory_after:afterContinuity,
    capsule_severed:capsuleSevered.answer.certificate,chroma_severed:{certificate:chromaSevered.answer.certificate,
      semantic_available:chromaSevered.answer.semantic_available},restored:continuityRestored.answer.certificate},
  voice:{proof:canonicalVoiceProof,missing_head:missingVoice[1],neutral:neutralVoiceProof[0],
    restored:restoredVoice[1][0],semantic_neutral_stable:true},
  readiness:{proof:readinessProof,canonical_kinds:kinds,severed_kinds:severedKinds},
  development:{candidate_sha256:development[1],quarantine:development[2],trial_standing:trial[3][1],
    cases:trial[3][3][2],expansions:trial[3][4][2],before_maxima:efficacyBefore[3],after_maxima:efficacyAfter[3],
    severed_maxima:naceSevered[3][3],neutral_same:true,restart:{standing:restart[0],maxima:restart[2][3],generation:restart[3]}},
  mattermost:{candidate_sha256:mm.candidate_sha256,current_trial:mattermost.standing[0],identity:mattermostMechanical.identity,
    identity_severed:mattermostMechanical['identity-severed'],identity_restored:mattermostMechanical['identity-restored'],
    panic:mattermostMechanical.panic,prior_live:mattermostMechanical.live,proof:mattermostProof,
    prior_live_replayed:false},final_trace:finalTrace,...resources};
save(`${dir}/observations.json`,observations);
const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R14',claims:{
  one_clean_current_consumer_lineage:true,development_learning_and_restart_causal_bite:true,
  mattermost_extension_and_terminated_live_witness_lineage:true,five_integrated_severances_and_controls:true,
  evidence_generated_clause_mapped_final_report:'pending-independent-verifier'},
  prior_generation_replayed:false,prior_live_effect_replayed:false,...resources,
  limits:'Final verifier and clause-mapped report still required; this builder verdict cannot close G33.'};
save(`${dir}/run-verdict.json`,verdict);

const sourceFiles=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','README.md','ACCEPTANCE.md','POC_SPEC.md',
  'FINAL_POC_REPORT_TEMPLATE.md','BUILD_FIDELITY_PROTOCOL.md','docs/gates/G33/R1/expected-run-contract.json',
  'docs/gates/G33/R14/plan.json','docs/gates/G33/R13/R1/closure.json','docs/gates/G31/P9/R1/closure.json',
  'docs/gates/G30/R2/closure.json','docs/gates/G32/R2/closure.json','scripts/g33_r14/run.mjs','scripts/g33_r14/verify.mjs',
  'tests/fixtures/g33_r14/cases.json','tests/fixtures/g32_r2/soul_severed.metta',
  'src/bootstrap_final_integration_v1.metta','src/final_integration_v1.metta','src/bootstrap_modules.metta',
  'src/bootstrap_continuity_intent_v1.metta','src/continuity_intent_v1.metta','src/continuity.metta',
  'src/bootstrap_relational_voice.metta','src/relational_voice.metta','src/relational_voice_repair_v1.metta',
  'src/bootstrap_reactor.metta','src/reactor.metta','src/soul.metta','src/development_helix_v2.metta',
  'src/mattermost_candidate_revision_v1.metta','src/bootstrap_mattermost_candidate_revision_v1.metta',
  'constitution/soul.metta','constitution/authority-manifest.json','effect_membranes/miter_final_integration_v1.pl',
  'effect_membranes/miter_development_helix_v1.pl','effect_membranes/miter_development_proof_v1.pl',
  'effect_membranes/miter_continuity_intent_v1.pl','effect_membranes/miter_resume.pl',
  'effect_membranes/miter_relational_voice_v2.pl','effect_membranes/miter_relational_voice_repair_v1.pl',
  'effect_membranes/miter_reactor.pl','effect_membranes/miter_integrity.pl','effect_membranes/miter_mattermost_mock_v2.pl',
  'evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl','evidence/G31/p3-371/input.json',
  'evidence/G31/p9-913/slot-1-witness-redacted.json','evidence/G31/p9-913/slot-2-witness-redacted.json',
  'evidence/G31/p9-913/denied-redacted.json','evidence/G31/p9-913/panic-redacted.json'];
const evidenceFiles=[`${dir}/opening.json`,`${dir}/soul-products.json`,`${dir}/soul-integrity.json`,
  `${canonicalMemory.output}/answer.json`,`${canonicalMemory.output}/continuity-reading-typed.json`,
  `${dir}/continuity-products.json`,`${dir}/voice-canonical-products.json`,
  `${dir}/voice-missing-products.json`,`${dir}/voice-neutral-products.json`,
  `${dir}/voice-restored-products.json`,`${dir}/reactor-canonical-trace.json`,
  `${dir}/reactor-canonical-process.json`,`${developmentRoot}/final.json`,`${developmentRoot}/trial.json`,
  `${developmentRoot}/efficacy-before.json`,`${developmentRoot}/efficacy-after.json`,`${developmentRoot}/restart.json`,
  `${dir}/mattermost-current-products.json`,`${dir}/mattermost-mechanical-products.json`,
  `${dir}/final-trace-products.json`,`${dir}/phase-lineage.json`,`${dir}/observations.json`,`${dir}/run-verdict.json`];
save(`${dir}/freeze.json`,{schema:'miter-g33-r14-freeze-v1',plan_commit:opening.plan_commit,
  execution_git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins([...sourceFiles.map(x=>`${root}/${x}`),...Object.values(devSources).map(x=>x.path),...evidenceFiles]),
  ...resources,prior_generation_replayed:false,prior_live_effect_replayed:false});
console.log(JSON.stringify(verdict));
