// G33 R10 builder harness: disclosed contact files, process control and capture.
// It never invokes native development cognition or writes its products.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {parse} from '../sc04/fixtures.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R10/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const fixture=read(`${root}/tests/fixtures/g33_r10/cases.json`);
const resources=fixture.resources;
const opening=checkOpen('docs/gates/G33/R10/plan.json');
assert.equal(opening.plan_commit,'06b43b9288962d77542e6533780d1f9d51c09972');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');
const source=read(`${root}/evidence/G33/R8/attempt-001/source-contacts.json`);

function contact(id,kind,frame){return {contact_id:id,source_kind:kind,frame,clauses:source.clauses};}
function inputFor(name){
  const first=contact('r10-a','independent-native-audit',source.first_frame);
  const second=contact('r10-b','independent-native-audit',source.second_frame);
  const input={schema:'miter-development-contact-set-v1',undertaking_id:fixture.undertaking_id,
    scope:source.first_frame[1],contacts:[first,second],surfaces:source.surfaces,grant:source.grant};
  if(name==='neutral-order')input.contacts.reverse();
  if(name==='same-family')input.contacts=[first,contact('r10-same','independent-native-audit',source.first_frame)];
  if(name==='self-authored')input.contacts=[contact('r10-self-a','self-trace',source.first_frame),
    contact('r10-self-b','self-trace',source.second_frame)];
  if(name==='missing-capability')input.surfaces=[];
  if(name==='exhausted-grant')input.grant=['development-grant',source.first_frame[1],0,1024,120];
  return input;
}
function prepare(name){
  const runtime=`${dir}/${name}`;
  for(const sub of ['inbox','store'])fs.mkdirSync(`${runtime}/${sub}`,{recursive:true});
  fs.writeFileSync(`${runtime}/store/trajectory.jsonl`,'');
  fs.writeFileSync(`${runtime}/store/trajectory.lock`,'');
  save(`${runtime}/development-contact.json`,inputFor(name));
  return runtime;
}
function trace(runtime){
  const path=`${runtime}/trace.jsonl`;
  if(!fs.existsSync(path))return [];
  const bytes=fs.readFileSync(path,'utf8'),parts=bytes.split('\n');
  // A concurrent append is not a malformed record until its terminating LF.
  if(!bytes.endsWith('\n'))parts.pop();
  return parts.filter(Boolean).map(JSON.parse);
}
function sendStop(runtime,id){
  save(`${runtime}/inbox/${id}.json`,{schema:'miter-reactor-input-v1',id,kind:'stop',
    provenance:'direct-contact',obligation:'none',steps:1,sent_at:new Date().toISOString()});
}
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function runDriver(name,runtime,ready,stopId){
  const metta=`${dir}/${name}.metta`;
  save(metta,`!(import! &self "${root}/src/bootstrap_development_reactor_v1.metta")\n`+
    `!(case-result registered-hooks (collapse (match &rna_hooks $hook $hook)))\n`+
    `!(ReactorStart "${runtime}" "${runtime}/integrity-report.json")\n`);
  const started=Date.now(),child=spawn(swi,['--stack_limit=2g','-q','-s',
    `${petta}/src/main.pl`,'--',metta,'silent'],{cwd:root,stdio:['ignore','pipe','pipe']});
  let stdout='',stderr='',closed=false;
  child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
  const completion=new Promise(resolve=>child.on('close',(status,signal)=>{
    closed=true;resolve({status,signal});
  }));
  const end=Date.now()+20000;while(Date.now()<end&&!closed&&!ready())await wait(20);
  const boundaryReached=ready();
  if(!closed)sendStop(runtime,stopId);
  let processResult=await Promise.race([completion,wait(10000).then(()=>({timeout:true}))]);
  if(processResult.timeout){child.kill('SIGTERM');processResult={...await completion,timeout:true};}
  save(`${dir}/${name}.stdout`,stdout);save(`${dir}/${name}.stderr`,stderr);
  save(`${dir}/${name}-process.json`,{...processResult,boundary_reached:boundaryReached,
    elapsed_ms:Date.now()-started});
  const products={};for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(case-result '))continue;const row=parse(line);products[row[1]]=row[2];
  }
  save(`${dir}/${name}-products.json`,products);
  return {process:processResult,boundaryReached,stdout,stderr,products};
}
function development(runtime,file){return `${runtime}/development/${fixture.undertaking_id}/${file}`;}
function native(runtime,file){return read(development(runtime,file)).native;}
function verifyLedger(runtime,name='ledger-report.json'){
  const report=`${runtime}/${name}`;
  const goal=`miter_store_verify_ledger('${runtime}/store','${report}',R),writeln(R),halt`;
  const p=spawnSync(swi,['-q','-f','none','-s',`${root}/effect_membranes/miter_store.pl`,'-g',goal],
    {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});
  assert.equal(p.status,0,p.stderr);assert.equal(p.stderr,'');assert.equal(p.stdout.trim(),'trajectory-valid');
  return read(report);
}

const runs={},roots={};
for(const name of fixture.variants){
  const runtime=roots[name]=prepare(name),rna=development(runtime,'rna.json'),step=development(runtime,'cycle-step.json');
  runs[name]=await runDriver(name,runtime,()=>fs.existsSync(step)&&
    (name==='canonical'||name==='neutral-order'?fs.existsSync(rna)&&read(rna).status===fixture.expected.canonical_rna_status:!fs.existsSync(rna))&&
    trace(runtime).some(row=>row.kind==='quiescent-ready'),`stop-${name}`);
  assert.equal(runs[name].boundaryReached,true,name);assert.equal(runs[name].process.status,0,name);
  assert.equal(runs[name].stderr,'',name);verifyLedger(runtime);
}

const canonicalRoot=roots.canonical;
const preservedFiles=['state.json','effect-request.json','cycle-step.json','rna.json'];
const beforeRestart=Object.fromEntries(preservedFiles.map(file=>[file,hash(fs.readFileSync(development(canonicalRoot,file)))]));
const beforeTrace=trace(canonicalRoot),beforeOrientation=beforeTrace.filter(x=>x.kind==='development-orientation').length;
fs.mkdirSync(`${canonicalRoot}/consumed-inbox`,{recursive:true});
fs.renameSync(`${canonicalRoot}/inbox/stop-canonical.json`,`${canonicalRoot}/consumed-inbox/stop-canonical.json`);
const readyCount=beforeTrace.filter(row=>row.kind==='quiescent-ready').length;
runs.restart=await runDriver('restart',canonicalRoot,
  ()=>trace(canonicalRoot).filter(row=>row.kind==='quiescent-ready').length>readyCount,'stop-restart');
assert.equal(runs.restart.boundaryReached,true);assert.equal(runs.restart.process.status,0);
assert.equal(runs.restart.stderr,'');verifyLedger(canonicalRoot,'ledger-report-restart.json');
const afterRestart=Object.fromEntries(preservedFiles.map(file=>[file,hash(fs.readFileSync(development(canonicalRoot,file)))]));

const results={};for(const name of fixture.variants){
  const runtime=roots[name],state=native(runtime,'state.json'),step=native(runtime,'cycle-step.json');
  results[name]={state,step,effect_request:native(runtime,'effect-request.json'),
    rna:fs.existsSync(development(runtime,'rna.json'))?read(development(runtime,'rna.json')):null,
    trace:trace(runtime),ledger:read(`${runtime}/ledger-report.json`)};
}
save(`${dir}/native-results.json`,results);
const canonical=results.canonical,neutral=results['neutral-order'];
const resultHead=value=>Array.isArray(value)?value[0]:value;
const causalPassed=resultHead(results['same-family'].state[9])===fixture.expected.same_family_result&&
  resultHead(results['self-authored'].state[9])===fixture.expected.self_authored_result&&
  resultHead(results['missing-capability'].state[9])===fixture.expected.missing_capability_result&&
  resultHead(results['exhausted-grant'].state[9])===fixture.expected.exhausted_grant_result&&
  ['same-family','self-authored','missing-capability','exhausted-grant'].every(name=>results[name].rna===null);
const canonicalPassed=canonical.state[3]===fixture.expected.canonical_phase&&
  canonical.state[9]===fixture.expected.canonical_result&&canonical.rna.status===fixture.expected.canonical_rna_status&&
  canonical.effect_request[0]==='unapplied-effects'&&canonical.effect_request[1].length===1&&
  canonical.effect_request[1][0][0]==='dispatch'&&canonical.effect_request[2]==='authority-awaiting-separate-authorization';
const restartTrace=trace(canonicalRoot),restartPassed=JSON.stringify(beforeRestart)===JSON.stringify(afterRestart)&&
  restartTrace.filter(x=>x.kind==='development-orientation').length===beforeOrientation;
const hooks=runs.canonical.products['registered-hooks']??[];
const hookPassed=hooks.length===2&&hooks.some(x=>JSON.stringify(x)===JSON.stringify(
  ['idle-promoter','SourceGroundedDevelopmentIdle']))&&hooks.some(x=>JSON.stringify(x)===JSON.stringify(
  ['rna-advancer','SourceGroundedDevelopRNA','SourceGroundedDevelopmentBoundary']))&&
  !JSON.stringify(hooks).includes('InterestIdle');
const allProcesses=Object.values(runs).every(x=>x.process.status===0&&!x.process.timeout&&x.stderr==='');
const observations={schema:'miter-g33-r10-observations-v1',canonical_passed:canonicalPassed,
  causal_passed:causalPassed,restart_passed:restartPassed,corrected_hooks_only:hookPassed,
  all_processes_clean:allProcesses,before_restart_hashes:beforeRestart,after_restart_hashes:afterRestart,
  development_orientation_count_before_restart:beforeOrientation,
  development_orientation_count_after_restart:restartTrace.filter(x=>x.kind==='development-orientation').length,
  canonical_trace_kinds:restartTrace.map(x=>x.kind),
  causal_result_heads:Object.fromEntries(['same-family','self-authored','missing-capability','exhausted-grant']
    .map(name=>[name,resultHead(results[name].state[9])])),registered_hooks:hooks,...resources};
save(`${dir}/observations.json`,observations);
const sourceFiles=['docs/gates/G33/R10/plan.json','docs/gates/G33/R10/plan.md',
  'docs/gates/G33/R10/reassessment.md','tests/fixtures/g33_r10/cases.json','scripts/g33_r10/run.mjs',
  'scripts/g33_r10/verify.mjs','src/bootstrap_development_reactor_v1.metta',
  'src/development_reactor_v1.metta','effect_membranes/miter_development_reactor_v1.pl',
  'src/bootstrap_reactor.metta','src/reactor.metta','effect_membranes/miter_reactor.pl',
  'src/bootstrap_development_cycle.metta','src/development_cycle.metta','src/development_evidence.metta',
  'src/bootstrap_voice_construction.metta','constitution/authority-manifest.json','config/reactor-profile.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r10-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
const passed=canonicalPassed&&causalPassed&&restartPassed&&hookPassed&&allProcesses;
const verdict={status:passed?'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R10',
  recurring_native_contact_forms_durable_source_grounded_undertaking:canonicalPassed,
  causal_severances_block_transcription_with_distinct_native_standing:causalPassed,
  restart_preserves_waiting_undertaking_without_replay_or_duplication:restartPassed,
  explicit_stop_terminates_with_zero_model_or_external_effects:allProcesses,
  first_discontinuity:canonicalPassed?(causalPassed?(restartPassed?(hookPassed&&allProcesses?'none-observed':
    'hook-or-process-boundary'):'restart-replay-boundary'):'causal-transcription-boundary'):
    'recurring-native-development-ingress',...resources,
  limits:'Dedicated corrected bootstrap and finite VoicePolicy contact family only; default bootstrap reconciliation and later development remain unproven.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));if(!passed)process.exitCode=1;
