// G33 R11 R2 builder harness: disclosed fixtures, native process control and
// mechanical inspection only. No direct cognitive-stage, selector, model or effect call.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {parse} from '../sc04/fixtures.mjs';

process.chdir(root);
const tag=process.argv[2]??'003';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R11/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const fixture=read(`${root}/tests/fixtures/g33_r11/cases.json`),resources=fixture.resources;
process.on('uncaughtException',error=>{save(`${dir}/runner-failure.json`,{
  status:'FAIL-RUNNER',message:error.message,stack:error.stack,...resources});
  console.error(error.stack);process.exitCode=1;});
const opening=checkOpen('docs/gates/G33/R11/R2/plan.json');
assert.equal(opening.plan_commit,'88b5fcd30a848ccb81a44f8ec878fc8a1c4ac11b');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

// Prolog-only path capability probe. No file operation follows a rejected path.
const acceptedRoots=[`${root}/evidence/G33/R10/probe`,`${root}/evidence/G33/R11/probe`,
  `${root}/runtime/probe`];
const rejectedRoots=[`${root}/evidence/G32/probe`,`${root}/evidence/G33/../G32/probe`,
  `${root}/docs/probe`,`${root}/.miter/probe`,'runtime/probe','/Users/bcb/.miter/probe',
  '/private/tmp/miter-probe',`${root}/evidence/G33/`];
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const rootCases=[...acceptedRoots.map(value=>({value,expected:'qualified'})),
  ...rejectedRoots.map(value=>({value,expected:'rejected'}))];
const rootGoal=rootCases.map((item,index)=>
  `(dr_root(${q(item.value)},_)->R${index}=qualified;R${index}=rejected)`).join(',')+
  `,writeln([${rootCases.map((_,index)=>`R${index}`).join(',')}]),halt`;
const rootRun=spawnSync(swi,['-q','-f','none','-s',
  `${root}/effect_membranes/miter_development_reactor_v1.pl`,'-g',rootGoal],
  {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});
save(`${dir}/root-probe.stdout`,rootRun.stdout);save(`${dir}/root-probe.stderr`,rootRun.stderr);
save(`${dir}/root-probe-process.json`,{status:rootRun.status,signal:rootRun.signal,error:rootRun.error?.message??null});
assert.equal(rootRun.status,0,rootRun.stderr);assert.equal(rootRun.stderr,'');
const observedRootStandings=rootRun.stdout.trim().slice(1,-1).split(',');
assert.deepEqual(observedRootStandings,rootCases.map(item=>item.expected));
save(`${dir}/root-probe.json`,{cases:rootCases.map((item,index)=>({...item,
  observed:observedRootStandings[index]}))});

const source=read(`${root}/evidence/G33/R8/attempt-001/source-contacts.json`);
const contact=(id,kind,frame)=>({contact_id:id,source_kind:kind,frame,clauses:source.clauses});
function inputFor(name){
  const a=contact('r11-a','independent-native-audit',source.first_frame);
  const b=contact('r11-b','independent-native-audit',source.second_frame);
  const input={schema:'miter-development-contact-set-v1',undertaking_id:fixture.undertaking_id,
    scope:source.first_frame[1],contacts:[a,b],surfaces:source.surfaces,grant:source.grant};
  if(name==='neutral-order')input.contacts.reverse();
  if(name==='same-family')input.contacts=[a,contact('r11-same','independent-native-audit',source.first_frame)];
  return input;
}
function prepare(name){
  const runtime=`${dir}/${name}`;
  for(const sub of ['inbox','store'])fs.mkdirSync(`${runtime}/${sub}`,{recursive:true});
  fs.writeFileSync(`${runtime}/store/trajectory.jsonl`,'');
  fs.writeFileSync(`${runtime}/store/trajectory.lock`,'');
  save(`${runtime}/development-contact.json`,inputFor(name));return runtime;
}
function trace(runtime){
  const file=`${runtime}/trace.jsonl`;if(!fs.existsSync(file))return [];
  const bytes=fs.readFileSync(file,'utf8'),parts=bytes.split('\n');
  if(!bytes.endsWith('\n'))parts.pop();return parts.filter(Boolean).map(JSON.parse);
}
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
function stop(runtime,id){save(`${runtime}/inbox/${id}.json`,{schema:'miter-reactor-input-v1',
  id,kind:'stop',provenance:'direct-contact',obligation:'none',steps:1,sent_at:new Date().toISOString()});}
async function drive(name,runtime,ready,bootstrap=`${root}/src/bootstrap_modules.metta`){
  const metta=`${dir}/${name}.metta`;
  save(metta,`!(import! &self "${bootstrap}")\n`+
    `!(case-result registered-hooks (collapse (match &rna_hooks $hook $hook)))\n`+
    `!(ReactorStart "${runtime}" "${runtime}/integrity-report.json")\n`);
  const child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',metta,'silent'],
    {cwd:root,stdio:['ignore','pipe','pipe']});
  let stdout='',stderr='',closed=false;child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
  child.stdout.on('data',data=>stdout+=data);child.stderr.on('data',data=>stderr+=data);
  const completion=new Promise(resolve=>child.on('close',(status,signal)=>{closed=true;resolve({status,signal});}));
  const end=Date.now()+20000;while(Date.now()<end&&!closed&&!ready())await wait(20);
  const boundaryReached=ready();if(!closed)stop(runtime,`stop-${name}`);
  let processResult=await Promise.race([completion,wait(10000).then(()=>({timeout:true}))]);
  if(processResult.timeout){child.kill('SIGTERM');processResult={...await completion,timeout:true};}
  processResult={...processResult,boundary_reached:boundaryReached};
  save(`${dir}/${name}.stdout`,stdout);save(`${dir}/${name}.stderr`,stderr);
  save(`${dir}/${name}-process.json`,processResult);
  const products={};for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(case-result '))continue;const row=parse(line);products[row[1]]=row[2];
  }
  save(`${dir}/${name}-products.json`,products);return {processResult,stderr,products};
}
const development=(runtime,file)=>`${runtime}/development/${fixture.undertaking_id}/${file}`;
const native=(runtime,file)=>read(development(runtime,file)).native;
function ledger(runtime,file='ledger-report.json'){
  const report=`${runtime}/${file}`;
  const goal=`miter_store_verify_ledger('${runtime}/store','${report}',R),writeln(R),halt`;
  const run=spawnSync(swi,['-q','-f','none','-s',`${root}/effect_membranes/miter_store.pl`,'-g',goal],
    {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});
  assert.equal(run.status,0,run.stderr);assert.equal(run.stderr,'');
  assert.equal(run.stdout.trim(),'trajectory-valid');return read(report);
}

const roots={},runs={};
for(const name of fixture.recurring_variants){
  const runtime=roots[name]=prepare(name),step=development(runtime,'cycle-step.json'),rna=development(runtime,'rna.json');
  runs[name]=await drive(name,runtime,()=>fs.existsSync(step)&&
    (name==='same-family'?!fs.existsSync(rna):fs.existsSync(rna)&&read(rna).status===fixture.expected.canonical_rna_status)&&
    trace(runtime).some(row=>row.kind==='quiescent-ready'));
  assert.equal(runs[name].processResult.status,0,name);assert.equal(runs[name].stderr,'',name);
  assert.equal(runs[name].processResult.boundary_reached,true,name);ledger(runtime);
}
const canonicalRoot=roots.canonical,checkpointFiles=['state.json','effect-request.json','cycle-step.json','rna.json'];
const before=Object.fromEntries(checkpointFiles.map(file=>[file,hash(fs.readFileSync(development(canonicalRoot,file)))]));
const beforeOrientation=trace(canonicalRoot).filter(row=>row.kind==='development-orientation').length;
fs.mkdirSync(`${canonicalRoot}/consumed-inbox`,{recursive:true});
fs.renameSync(`${canonicalRoot}/inbox/stop-canonical.json`,`${canonicalRoot}/consumed-inbox/stop-canonical.json`);
const readyCount=trace(canonicalRoot).filter(row=>row.kind==='quiescent-ready').length;
runs.restart=await drive('restart',canonicalRoot,
  ()=>trace(canonicalRoot).filter(row=>row.kind==='quiescent-ready').length>readyCount);
assert.equal(runs.restart.processResult.status,0);assert.equal(runs.restart.stderr,'');
assert.equal(runs.restart.processResult.boundary_reached,true);ledger(canonicalRoot,'ledger-report-restart.json');
const after=Object.fromEntries(checkpointFiles.map(file=>[file,hash(fs.readFileSync(development(canonicalRoot,file)))]));

const severedBootstrap=`${dir}/bootstrap-dependency-severed.metta`;
save(severedBootstrap,`!(import! &self "${root}/src/bootstrap_reactor.metta")\n`+
  `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_module_transport.pl" `+
  `(miter_module_source miter_module_source_field miter_module_requests_used miter_module_prior_rejections miter_module_field miter_module_rule miter_module_count miter_module_shape miter_module_intention miter_module_generate miter_module_provenance miter_module_reject miter_module_manifest miter_module_snapshot miter_module_dump))\n`+
  `!(import! &self "${root}/src/modules.metta")\n`);
const severedRoot=prepare('dependency-severed');
runs['dependency-severed']=await drive('dependency-severed',severedRoot,
  ()=>trace(severedRoot).some(row=>row.kind==='quiescent-ready'),severedBootstrap);
assert.equal(runs['dependency-severed'].processResult.status,0);
assert.equal(runs['dependency-severed'].stderr,'');
assert.equal(runs['dependency-severed'].processResult.boundary_reached,true);ledger(severedRoot);

// Archived actual-model candidate bytes requalify containment, never behavior.
const moduleRoot=`${dir}/module-mechanics`,archived=`${root}/${fixture.module_fixture.source}`;
for(const sub of ['store','modules/candidate-b',`modules/${fixture.module_fixture.forbidden_id}`])
  fs.mkdirSync(`${moduleRoot}/${sub}`,{recursive:true});
fs.writeFileSync(`${moduleRoot}/store/trajectory.jsonl`,'');fs.writeFileSync(`${moduleRoot}/store/trajectory.lock`,'');
for(const file of ['candidate.json','raw.json','request.json','timing.json'])
  fs.copyFileSync(`${archived}/${file}`,`${moduleRoot}/modules/candidate-b/${file}`);
for(const file of ['source-opportunity.json','source-request.json'])
  fs.copyFileSync(`${root}/evidence/20260902T084500Z-G21/runtime/${file}`,`${moduleRoot}/${file}`);
const opportunity=read(`${moduleRoot}/source-opportunity.json`),request=read(`${moduleRoot}/source-request.json`);
const base={schema:'miter-event-intent-v1',occurred_at:'2026-09-04T00:00:00Z',recorded_at:'2026-09-04T00:00:00Z',
  source_surface:'g33-r11-mechanical-fixture',source_principal:'builder-disclosed-archived-source',
  audience_scope:'scope:g16-private',project_scope:'g16-voice',
  provenance_kind:'historical-evidence-requalification',correlation_id:opportunity.opportunity_id};
const intents=[{...base,event_id:`${opportunity.opportunity_id}-development-opportunity`,
  event_kind:'development-opportunity',parent_event_ids:[],payload:opportunity},
{...base,event_id:`${opportunity.opportunity_id}-candidate-request`,event_kind:'candidate-request',
  parent_event_ids:[`${opportunity.opportunity_id}-development-opportunity`],payload:request}];
for(const [index,intent] of intents.entries()){
  const intentFile=`${moduleRoot}/source-intent-${index+1}.json`;save(intentFile,intent);
  const goal=`miter_store_append_event('${moduleRoot}/store','runtime/g07/libmiter_store_posix.dylib','${intentFile}',R),writeln(R),halt`;
  const append=spawnSync(swi,['-q','-f','none','-s',`${root}/effect_membranes/miter_store.pl`,'-g',goal],
    {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024});
  assert.equal(append.status,0,append.stderr);assert.equal(append.stderr,'');assert.equal(append.stdout.trim(),'event-appended');
}
const forbidden=structuredClone(read(`${archived}/candidate.json`));
forbidden.candidate_id=fixture.module_fixture.forbidden_id;forbidden.allowed_effects=['unrestricted-http'];
save(`${moduleRoot}/modules/${fixture.module_fixture.forbidden_id}/candidate.json`,forbidden);
const moduleProgram=`${dir}/module-mechanics.metta`;
save(moduleProgram,`!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(case-result hooks (collapse (match &rna_hooks $hook $hook)))\n`+
  `!(case-result source (miter_module_source "${moduleRoot}"))\n`+
  `!(case-result provenance (miter_module_provenance "${moduleRoot}" candidate-b))\n`+
  `!(case-result validation (ModuleValidation "${moduleRoot}" candidate-b))\n`+
  `!(case-result quarantine (ModuleQuarantine "${moduleRoot}" candidate-b))\n`+
  `!(case-result forbidden-validation (ModuleValidation "${moduleRoot}" ${fixture.module_fixture.forbidden_id}))\n`+
  `!(case-result forbidden-quarantine (ModuleQuarantine "${moduleRoot}" ${fixture.module_fixture.forbidden_id}))\n`+
  `!(case-result trial-space (collapse (match &trial $atom $atom)))\n`);
const moduleRun=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',moduleProgram,'silent'],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:128*1024*1024});
save(`${dir}/module-mechanics.stdout`,moduleRun.stdout);save(`${dir}/module-mechanics.stderr`,moduleRun.stderr);
save(`${dir}/module-mechanics-process.json`,{status:moduleRun.status,signal:moduleRun.signal,error:moduleRun.error?.message??null});
assert.equal(moduleRun.status,0,moduleRun.stderr);assert.equal(moduleRun.stderr,'');
const moduleProducts={};for(const line of moduleRun.stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
  if(!line.startsWith('(case-result '))continue;const row=parse(line);moduleProducts[row[1]]=row[2];
}
save(`${dir}/module-products.json`,moduleProducts);ledger(moduleRoot);

const results={};for(const name of fixture.recurring_variants){const runtime=roots[name];results[name]={
  state:native(runtime,'state.json'),effect_request:native(runtime,'effect-request.json'),
  rna:fs.existsSync(development(runtime,'rna.json'))?read(development(runtime,'rna.json')):null,
  ledger:read(`${runtime}/ledger-report.json`)};}save(`${dir}/native-results.json`,results);
const hooks=runs.canonical.products['registered-hooks']??[],hookText=JSON.stringify(hooks);
const hooksPassed=hooks.length===2&&hookText.includes('SourceGroundedDevelopmentIdle')&&
  hookText.includes('SourceGroundedDevelopmentBoundary')&&!hookText.includes('InterestIdle')&&!hookText.includes('DevelopBoundary');
const recurringPassed=results.canonical.state[3]===fixture.expected.canonical_phase&&
  results.canonical.state[9]===fixture.expected.canonical_result&&
  results.canonical.rna.status===fixture.expected.canonical_rna_status&&
  results['neutral-order'].rna.status===fixture.expected.canonical_rna_status&&
  results['same-family'].state[9][0]===fixture.expected.same_family_result&&results['same-family'].rna===null;
const restartPassed=JSON.stringify(before)===JSON.stringify(after)&&
  trace(canonicalRoot).filter(row=>row.kind==='development-orientation').length===beforeOrientation;
const severedHooks=runs['dependency-severed'].products['registered-hooks']??[];
const severancePassed=severedHooks.length===0&&!fs.existsSync(development(severedRoot,'rna.json'));
const trialAtoms=moduleProducts['trial-space']??[];
const modulePassed=moduleProducts.source==='module-source-verified'&&moduleProducts.provenance==='model-candidate-bound'&&
  moduleProducts.validation==='module-valid'&&moduleProducts.quarantine==='candidate-quarantined'&&
  moduleProducts['forbidden-validation']==='forbidden-effect'&&moduleProducts['forbidden-quarantine']==='candidate-rejected'&&
  trialAtoms.length===3&&trialAtoms.every(atom=>atom[1]==='candidate-b')&&
  !trialAtoms.some(atom=>atom[1]===fixture.module_fixture.forbidden_id);
const rootsPassed=observedRootStandings.every((value,index)=>value===rootCases[index].expected);
const processesPassed=Object.values(runs).every(run=>run.processResult.status===0&&!run.processResult.timeout&&
  run.processResult.boundary_reached&&run.stderr==='')&&moduleRun.status===0&&moduleRun.stderr===''&&rootRun.status===0;
const observations={schema:'miter-g33-r11-r2-observations-v1',qualified_roots_only:rootsPassed,
  root_cases:rootCases.map((item,index)=>({...item,observed:observedRootStandings[index]})),hooks,
  corrected_hooks_only:hooksPassed,recurring_causal_path:recurringPassed,restart_non_replay:restartPassed,
  dependency_severance:severancePassed,severed_hooks:severedHooks,
  module_containment_requalified:modulePassed,module_products:moduleProducts,
  checkpoint_hashes_before:before,checkpoint_hashes_after:after,orientation_count_before:beforeOrientation,
  orientation_count_after:trace(canonicalRoot).filter(row=>row.kind==='development-orientation').length,
  all_processes_clean:processesPassed,...resources};save(`${dir}/observations.json`,observations);
// Freeze executable inputs and load-bearing sources only. The append-only attempt
// ledger is written after a run completes, so pinning it here would make the
// evidence package self-invalidating as soon as that result is recorded.
const sourceFiles=['docs/gates/G33/R11/R2/plan.json','docs/gates/G33/R11/R2/plan.md',
  'tests/fixtures/g33_r11/cases.json','scripts/g33_r11/run.mjs',
  'scripts/g33_r11/verify.mjs','src/bootstrap_modules.metta','src/bootstrap_development_reactor_v1.metta',
  'src/development_reactor_v1.metta','effect_membranes/miter_development_reactor_v1.pl','src/modules.metta',
  'effect_membranes/miter_module_transport.pl','src/bootstrap_interests.metta','src/interests.metta',
  'docs/gates/G33/R10/closure.json','docs/gates/SC07/CONTRACT_CORRECTION.md'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r11-r2-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
const passed=rootsPassed&&hooksPassed&&recurringPassed&&restartPassed&&severancePassed&&modulePassed&&processesPassed;
const verdict={status:passed?'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R11-R2',
  development_membrane_admits_only_qualified_repository_roots:rootsPassed,
  default_bootstrap_activates_only_source_grounded_development_hooks:hooksPassed,
  default_bootstrap_preserves_causal_neutral_and_restart_behavior:recurringPassed&&restartPassed,
  module_containment_loads_without_behavioral_selection:modulePassed,
  first_discontinuity:!rootsPassed?'mechanical-root-qualification':!hooksPassed?'default-hook-registration':
    !recurringPassed?'default-recurring-consumer':!restartPassed?'restart-non-replay':
    !modulePassed?'module-containment-compatibility':!processesPassed?'process-integrity':'none-observed',
  ...resources,limits:'Qualified repository roots, default hook replacement and finite containment requalification only; no v1 behavioral-selection credit, generation, trial quality, promotion, consequence learning, or general purpose formation.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));if(!passed)process.exitCode=1;
