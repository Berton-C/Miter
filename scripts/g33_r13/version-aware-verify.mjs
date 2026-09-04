// Offline R13 R1 version-boundary verifier. Historical source identity comes
// from Git objects; current v2 meaning comes from the independent R13 evidence
// verifier. No PeTTa, Prolog, provider, Keychain, or service is invoked.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
process.chdir(root);
const read=file=>JSON.parse(fs.readFileSync(file));
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const planCommit='06fcfc406f3e9accbc2806e31d1c331fdd5c4727';
const historical='1b6ffed65aacdca89437f4cc08a967ed0c79771e';
const opening=checkOpen('docs/gates/G33/R13/R1/plan.json');assert.equal(opening.plan_commit,planCommit);
const r12Freeze=read(`${root}/evidence/G33/R12/attempt-016/freeze.json`);
let currentMatches=0,historicalMatches=0;const evolved=[];
for(const entry of r12Freeze.files){
  assert(entry.path.startsWith(`${root}/`),entry.path);const relative=entry.path.slice(root.length+1);
  const current=fs.existsSync(entry.path)?hash(fs.readFileSync(entry.path)):null;
  if(current===entry.sha256){currentMatches++;continue;}
  const bytes=execFileSync('git',['show',`${historical}:${relative}`],{cwd:root,maxBuffer:256*1024*1024});
  assert.equal(hash(bytes),entry.sha256,relative);historicalMatches++;evolved.push(relative);
}
assert(historicalMatches>0);assert(evolved.includes('src/bootstrap_modules.metta'));
const r12Closure=read(`${root}/docs/gates/G33/R12/R3/closure.json`);
for(const entry of r12Closure.evidence)assert.equal(hash(fs.readFileSync(`${root}/${entry.path}`)),entry.sha256,entry.path);
assert.equal(r12Closure.status,'PASS-BOUNDED');assert.equal(r12Closure.claim_results.length,4);
const r13=spawnSync(process.execPath,[`${root}/scripts/g33_r13/verify.mjs`,'005'],
  {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:4*1024*1024});
assert.equal(r13.status,0,r13.stderr);const r13Result=JSON.parse(r13.stdout.trim());
assert.equal(r13Result.status,'PASS-BOUNDED');assert.equal(r13Result.claims,4);
const bootstrap=fs.readFileSync(`${root}/src/bootstrap_modules.metta`,'utf8');
assert.equal((bootstrap.match(/bootstrap_development_helix_v2\.metta/g)??[]).length,1);
assert.equal((bootstrap.match(/bootstrap_development_helix_v1\.metta/g)??[]).length,0);
const mismatch=read(`${root}/evidence/G33/R13/attempt-005/r12-current-tree-verifier-process.json`);
const mismatchStderr=fs.readFileSync(`${root}/evidence/G33/R13/attempt-005/r12-current-tree-verifier.stderr`,'utf8');
assert.equal(mismatch.status,1);assert.equal(mismatch.expected_historical_source_mismatch,true);
assert.match(mismatchStderr,/src\/bootstrap_modules\.metta/);
const observations=read(`${root}/evidence/G33/R13/attempt-005/observations.json`);
for(const key of ['model_calls','credential_lookups','mattermost_requests','chroma_requests','private_memory_reads','human_emissions','external_effects'])assert.equal(observations[key],0,key);
const result={schema:'miter-g33-r13-r1-recheck-v1',status:'PASS-BOUNDED',plan_commit:planCommit,
  r12:{historical_commit:historical,frozen_paths:r12Freeze.files.length,current_matches:currentMatches,
    historical_matches:historicalMatches,evolved_paths:evolved,closure_evidence_files:r12Closure.evidence.length,
    historical_semantic_claims:r12Closure.claim_results.length},
  r13:{independent_verifier:r13Result,default_v2_imports:1,default_v1_imports:0,
    expected_old_current_tree_mismatch_retained:true},
  model_calls:0,credential_lookups:0,network_requests:0,live_service_requests:0,external_effects:0,
  limit:'Version-aware offline closure review only; no new runtime or semantic claim.'};
save(`${root}/docs/gates/G33/R13/R1/recheck.json`,result);console.log(JSON.stringify(result));
