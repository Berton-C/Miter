// G33 R5 deterministic native repair experiment. JavaScript only isolates,
// launches, severs one participant, captures products, and records resources.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,pins,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';
import {sourceFrame,withoutJoint,withoutMaterialRelation,reorderedFrame,
  changedScope,projectCapability,reorderedCapability} from './cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R5/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const resources={model_calls:0,network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,human_emissions:0,external_effects:0};
process.on('uncaughtException',error=>{save(`${dir}/runner-failure.json`,{
  status:'FAIL-RUNNER',message:error.message,stack:error.stack,...resources});
  console.error(error.stack);process.exitCode=1;});

const opening=checkOpen('docs/gates/G33/R5/plan.json');
assert.equal(opening.plan_commit,'dc64f3a35e5681e2b421500238e1208ebedf6428');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const fixture=JSON.parse(fs.readFileSync(`${root}/tests/fixtures/g33_r5/cases.json`));
const candidate=`${root}/${fixture.accepted_capability}`;
const first=fixture.controlled_first_candidate,fuel=fixture.construction_fuel;
const tampered=`${dir}/tampered-candidate.json`;
const tamperedJson=JSON.parse(fs.readFileSync(candidate));tamperedJson.purpose+=' changed';
save(tampered,tamperedJson);
const alias=`${dir}/candidate-alias.json`;fs.symlinkSync(candidate,alias);

function execute(name,body,repairSource=`${root}/src/relational_voice_repair_v1.metta`){
  const entry=`${dir}/${name}.metta`;
  const bootstrap=`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`+
    `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_relational_voice_repair_v1.pl" (rr_capability vc_word vc_budget vc_sentence))\n`+
    `!(import! &self "${root}/src/development_evidence.metta")\n`+
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
  const products={};
  for(const line of (p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;
    const row=parse(line);products[row[1]]=row[2];
  }
  assert(Object.keys(products).length,`${name} products`);
  save(`${dir}/${name}-products.json`,products);return products;
}

const canonicalFrame=sourceFrame(),neutralFrame=reorderedFrame(),noJoint=withoutJoint();
const noRelation=withoutMaterialRelation(),newScope=changedScope();
const call=(frame,path=candidate)=>`(RRContinue ${sexp(frame)} ${sexp(first)} ${JSON.stringify(path)} ${fuel})`;
const body=
  `!(result capability (rr_capability ${JSON.stringify(candidate)}))\n`+
  `!(result canonical ${call(canonicalFrame)})\n`+
  `!(let $c ${call(canonicalFrame)} (result canonical-verification (RRVerify ${sexp(canonicalFrame)} ${sexp(first)} ${JSON.stringify(candidate)} ${fuel} $c)))\n`+
  `!(result neutral-source-order ${call(neutralFrame)})\n`+
  `!(result sever-joint ${call(noJoint)})\n`+
  `!(result sever-material-relation ${call(noRelation)})\n`+
  `!(result changed-scope ${call(newScope)})\n`+
  `!(result tampered-capability ${call(canonicalFrame,tampered)})\n`+
  `!(result symlink-capability ${call(canonicalFrame,alias)})\n`+
  `!(result defective-bypass (RRVerify ${sexp(canonicalFrame)} ${sexp(first)} ${JSON.stringify(candidate)} ${fuel} ${sexp(first)}))\n`+
  `!(let* (($m ${sexp(projectCapability())}) ($c (VConstruct ${sexp(canonicalFrame)} $m ${fuel}))) (result construction-order-original (VEligible $c)))\n`+
  `!(let* (($m ${sexp(reorderedCapability())}) ($c (VConstruct ${sexp(canonicalFrame)} $m ${fuel}))) (result construction-order-neutral (VEligible $c)))\n`;
const products=execute('native',body);

// A stale certificate is supplied under a different current cut; RRVerify must
// recompute against that cut rather than accept the old artifact.
const stale=execute('stale-certificate',
  `!(result stale-certificate (RRVerify ${sexp(newScope)} ${sexp(first)} ${JSON.stringify(candidate)} ${fuel} ${sexp(products.canonical)}))\n`);

// Remove the fresh semantic re-audit at one explicit source location.
const repairText=fs.readFileSync(`${root}/src/relational_voice_repair_v1.metta`,'utf8');
const needle='(RAudit $intention $scope $scope (index-atom $option 1))';
assert.equal(repairText.split(needle).length,2);
const severedText=repairText.replace(needle,
  '(voice-audit expression (index-atom $frame 1) semantic-reaudit-severed (intention $intention) (expression-readings ()) (alterations (semantic-reaudit-severed)))');
const severedPath=`${dir}/sever-reaudit-source.metta`;save(severedPath,severedText);
const severed=execute('sever-reaudit',
  `!(result sever-reaudit ${call(canonicalFrame)})\n`,severedPath);

const sourceFiles=['docs/gates/G33/R5/plan.json','docs/gates/G33/R5/case-lock.json',
  'docs/gates/G33/R5/expected-run-contract.json','tests/fixtures/g33_r5/cases.json',
  'src/bootstrap_relational_voice_repair_v1.metta','src/relational_voice_repair_v1.metta',
  'effect_membranes/miter_relational_voice_repair_v1.pl','scripts/g33_r5/cases.mjs',
  'scripts/g33_r5/run.mjs','scripts/g33_r5/verify.mjs','src/voice_construction.metta',
  'src/relational_voice.metta','evidence/SC07/live-001/frame.json',
  'evidence/G22/g26-001/accepted/candidate.json',
  'evidence/G22/g26-001/accepted/active.json','docs/gates/G22/closure.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r5-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
save(`${dir}/raw-summary.json`,{schema:'miter-g33-r5-raw-summary-v1',
  products:Object.keys(products),stale:stale['stale-certificate']?.[0],
  severed_reaudit:severed['sever-reaudit']?.[0],...resources});
console.log(JSON.stringify({status:'RAW-EVIDENCE-CAPTURED',evidence:rel,
  products:Object.keys(products).length,...resources}));
