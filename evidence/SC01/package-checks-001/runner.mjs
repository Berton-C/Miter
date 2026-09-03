// Builder package tests only; never loaded into Miter cognition.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,checkClose,hash} from '../fidelity/check.mjs';
process.chdir(root);
const directory=process.argv[2];
assert.match(directory??'',/^evidence\/SC01\/package-checks-\d{3}$/);
assert(!fs.existsSync(directory),'never overwrite an evidence run');
fs.mkdirSync(directory,{recursive:true});
const save=(name,value)=>fs.writeFileSync(directory+'/'+name,typeof value==='string'?value:JSON.stringify(value,null,2)+'\n');
process.on('uncaughtException',error=>{save('failure.json',{status:'FAIL',message:error.message,stack:error.stack});console.error(error.stack);process.exitCode=1});
save('runner.mjs',fs.readFileSync('scripts/sc01/check-package.mjs','utf8'));
const closurePath='docs/gates/SC01/closure.json';
const closure=JSON.parse(fs.readFileSync(closurePath));
const checks=[];
function reject(name,change,pattern){
  const candidate=structuredClone(closure);change(candidate);
  const p=directory+'/'+name+'.json';save(name+'.json',candidate);
  assert.throws(()=>checkClose(p),pattern);checks.push(name);
}
reject('missing-evidence',c=>c.evidence=[],/evidence required/);
reject('changed-evidence',c=>c.evidence[0].sha256='0'.repeat(64),/evidence changed/);
reject('missing-claim',c=>c.claim_results.pop(),/claim results incomplete/);
reject('unproved-claim',c=>c.claim_results[0].status='PLAUSIBLE',/unproved/);
reject('missing-fidelity-review',c=>delete c.fidelity_review.source_meaning,/incomplete fidelity review/);
reject('missing-review-attribution',c=>c.reviewer='',/review attribution/);
reject('missing-next-plan',c=>{delete c.next_plan;delete c.terminal_reason},/next plan or terminal/);
reject('unlinked-next-plan',()=>{},/next plan not linked/);
const canonical=checkClose(closurePath);assert.equal(canonical.status,'CLOSURE-PACKAGE-VALID');assert.equal(canonical.semantic_fidelity_certified,false);
save('closure-result.json',canonical);checks.push('canonical-package');
for(const [name,args] of [['plan-tests',['--test','scripts/fidelity/check.test.mjs']],['document-audit',['scripts/sc01/validate-docs.cjs']]]){
  const r=spawnSync(process.execPath,args,{encoding:'utf8',timeout:30000});
  save(name+'.stdout',r.stdout??'');save(name+'.stderr',r.stderr??'');
  save(name+'-process.json',{status:r.status,signal:r.signal,error:r.error?.message??null});
  assert.equal(r.status,0,name);assert.equal(r.stderr,'',name+' stderr');
}
save('verdict.json',{status:'PASS',closure_checks:checks,plan_tests:8,document_audit:JSON.parse(fs.readFileSync(directory+'/document-audit.stdout')),checker_sha256:hash(fs.readFileSync('scripts/fidelity/check.mjs')),limits:'Structural packaging, identity and source-document coverage checks only. Not semantic fidelity certification.'});
console.log(JSON.stringify({status:'PASS',closure_checks:checks.length,plan_tests:8,evidence:directory}));
