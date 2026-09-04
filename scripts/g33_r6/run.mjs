// G33 R6 current-consumer integration experiment. JavaScript supplies only
// disclosed rendered states, source cuts, process isolation, and capture.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,pins,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';
import {sourceFrame,withoutJoint,reorderedFrame,changedScope} from '../g33_r5/cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R6/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const resources={model_calls:0,network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,human_emissions:0,external_effects:0};
process.on('uncaughtException',error=>{save(`${dir}/runner-failure.json`,{
  status:'FAIL-RUNNER',message:error.message,stack:error.stack,...resources});
  console.error(error.stack);process.exitCode=1;});

const opening=checkOpen('docs/gates/G33/R6/plan.json');
assert.equal(opening.plan_commit,'3aba0601a078d4e87a43ee158421091a4193a2f9');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const fixture=JSON.parse(fs.readFileSync(`${root}/tests/fixtures/g33_r6/cases.json`));
const prior=JSON.parse(fs.readFileSync(`${root}/${fixture.faithful_source}`));
const certificate=prior.canonical;
const selected=certificate.find(x=>Array.isArray(x)&&x[0]==='selected-expression')[1];
const faithful=selected[1],first=fixture.controlled_first_candidate,id=fixture.request_id;
const frame=sourceFrame(),scope=frame[1],noJoint=withoutJoint(),neutral=reorderedFrame();
const changed=changedScope();
save(`${dir}/stimulus-lineage.json`,{schema:'miter-g33-r6-stimulus-lineage-v1',
  defective:{source:'docs/gates/G33/R6/case-lock.json',clauses:first},
  faithful:{source:fixture.faithful_source,source_sha256:hash(fs.readFileSync(`${root}/${fixture.faithful_source}`)),
    selected_expression_sha256:hash(Buffer.from(JSON.stringify(selected)))},
  repaired_wording_builder_authored:false});

function execute(name,body,{relational=`${root}/src/relational_voice.metta`,
    repairSource=`${root}/src/relational_voice_repair_v1.metta`,
    repairMembrane=`${root}/effect_membranes/miter_relational_voice_repair_v1.pl`,
    publicBootstrap=false}={}){
  const entry=`${dir}/${name}.metta`;
  const bootstrap=publicBootstrap?
   `!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`:
   `!(import! &self "${root}/src/bootstrap_grounded_language.metta")\n`+
   `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_relational_voice_v2.pl" (rv_save_intention rv_start rv_control rv_poll rv_pace rv_cancel rv_save_result))\n`+
   `!(import_prolog_functions_from_file "${repairMembrane}" (rr_capability rr_runtime_capability vc_word vc_budget vc_sentence))\n`+
   `!(import! &self "${root}/src/development_evidence.metta")\n`+
   `!(import! &self "${relational}")\n`+
   `!(import! &self "${root}/src/voice_construction.metta")\n`+
   `!(import! &self "${repairSource}")\n`;
  save(entry,bootstrap+body);
  const started=Date.now();
  const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',entry,'silent'],
    {cwd:root,encoding:'utf8',timeout:90000,maxBuffer:256*1024*1024});
  save(`${dir}/${name}.stdout`,p.stdout??'');save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,
    error:p.error?.message,elapsed_ms:Date.now()-started});
  assert.equal(p.status,0,`${name} status`);assert.equal(p.stderr,'',`${name} stderr`);
  const products={};for(const line of (p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;const row=parse(line);products[row[1]]=row[2];
  }
  assert(Object.keys(products).length,`${name} products`);
  save(`${dir}/${name}-products.json`,products);return products;
}

const runtime=name=>{const p=`${dir}/runtime/${name}`;fs.mkdirSync(p,{recursive:true});return p};
const intention=f=>`(RIntend ${id} (DGround ${sexp(f)}))`;
const state=(clauses=first,request=id,stateScope=scope)=>
  `(rendered ${request} ${sexp(stateScope)} ${sexp(clauses)} "bounded-rendered-state")`;
const returned=(name,f=frame,s=state())=>
  `(RWaitReturned ${JSON.stringify(runtime(name))} ${intention(f)} ${sexp(f)} ${s})`;

const body=
 `!(result canonical ${returned('canonical')})\n`+
 `!(result faithful ${returned('faithful',frame,state(faithful))})\n`+
 `!(result no-joint ${returned('no-joint',noJoint,state(first,id,noJoint[1]))})\n`+
 `!(result neutral-source-order ${returned('neutral',neutral,state(first,id,neutral[1]))})\n`+
 `!(result missing-frame (RWaitReturned ${JSON.stringify(runtime('missing-frame'))} ${intention(frame)} source-frame-unavailable ${state()}))\n`+
 `!(result identity-mismatch ${returned('identity',frame,state(first,'other-request'))})\n`+
 `!(result scope-mismatch ${returned('scope',frame,state(first,id,changed[1]))})\n`+
 `!(result malformed-state (RWaitReturned ${JSON.stringify(runtime('malformed'))} ${intention(frame)} ${sexp(frame)} (rendered malformed)))\n`+
 `!(result language-input-frame (RInputFrame (DGround ${sexp(frame)})))\n`+
 `!(result language-input-preserved (== (RInputLanguage (DGround ${sexp(frame)})) (DGround ${sexp(frame)})))\n`+
 `!(let* (($i ${intention(frame)}) ($a (RAudit $i ${sexp(scope)} ${sexp(scope)} ${sexp(first)})) ($d (RDisposition $a 1))) (result observed-products-valid (RRContinueObserved ${sexp(frame)} $i ${sexp(first)} $a $d "/Users/claritymiter/miter/evidence/G22/g26-001/accepted/candidate.json" 256)))\n`+
 `!(let* (($i ${intention(frame)}) ($a (RAudit $i ${sexp(scope)} ${sexp(scope)} ${sexp(first)})) ($d (RDisposition $a 1))) (result observed-products-forged (RRContinueObserved ${sexp(frame)} $i ${sexp(first)} (voice-audit forged) $d "/Users/claritymiter/miter/evidence/G22/g26-001/accepted/candidate.json" 256)))\n`;
const products=execute('native',body);
const publicProducts=execute('public-bootstrap',
  `!(result public-bootstrap ${returned('public-bootstrap')})\n`,{publicBootstrap:true});

const relationalText=fs.readFileSync(`${root}/src/relational_voice_repair_v1.metta`,'utf8');
const delegate='(let $handled (RRenderedContinuation $frame $i $state)';
assert.equal(relationalText.split(delegate).length,2);
const severedRelational=relationalText.replace(delegate,
  '(let $handled (native-expression-result handler-delegation-severed (expression-repair-incomplete handler-delegation-severed no-emission-authority))');
const severedRelationalPath=`${dir}/sever-handler-source.metta`;
save(severedRelationalPath,severedRelational);
const severedHandler=execute('sever-handler',
  `!(result sever-handler ${returned('sever-handler')})\n`,{repairSource:severedRelationalPath});

const membraneText=fs.readFileSync(
  `${root}/effect_membranes/miter_relational_voice_repair_v1.pl`,'utf8');
const runtimeLine="rr_runtime_path('/Users/claritymiter/miter/config/relational-voice-repair-runtime-v1.json').";
assert.equal(membraneText.split(runtimeLine).length,2);
const severedMembrane=membraneText
  .replace(":- ensure_loaded('miter_store.pl').",
    `:- ensure_loaded('${root}/effect_membranes/miter_store.pl').`)
  .replace(runtimeLine,`rr_runtime_path('${dir}/missing-runtime-reference.json').`);
const severedMembranePath=`${dir}/sever-runtime-capability.pl`;save(severedMembranePath,severedMembrane);
const severedRuntime=execute('sever-runtime',
  `!(result sever-runtime ${returned('sever-runtime')})\n`,{repairMembrane:severedMembranePath});

const sourceFiles=['docs/gates/G33/R6/plan.json','docs/gates/G33/R6/case-lock.json',
 'docs/gates/G33/R6/expected-run-contract.json','tests/fixtures/g33_r6/cases.json',
 'config/relational-voice-repair-runtime-v1.json','src/relational_voice.metta',
 'src/bootstrap_relational_voice.metta','src/relational_voice_repair_v1.metta',
 'src/bootstrap_relational_voice_repair_v1.metta','src/voice_construction.metta',
 'effect_membranes/miter_relational_voice_v2.pl',
 'effect_membranes/miter_relational_voice_repair_v1.pl','scripts/g33_r6/run.mjs',
 'scripts/g33_r6/verify.mjs','evidence/G33/R5/attempt-003/native-products.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r6-freeze-v1',
 git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
 plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
 swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
 files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
save(`${dir}/raw-summary.json`,{schema:'miter-g33-r6-raw-summary-v1',
 products:Object.keys(products),public_bootstrap:publicProducts['public-bootstrap']?.[0],
 severed_handler:severedHandler['sever-handler']?.[0],
 severed_runtime:severedRuntime['sever-runtime']?.[0],...resources});
console.log(JSON.stringify({status:'RAW-EVIDENCE-CAPTURED',evidence:rel,
 products:Object.keys(products).length,...resources}));
