// Independent R10 verifier. It does not start the reactor or import native standing.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';

process.chdir(root);
const tag=process.argv[2]??'001',dir=`${root}/evidence/G33/R10/attempt-${tag}`;
const read=p=>JSON.parse(fs.readFileSync(p));
const fixture=read(`${root}/tests/fixtures/g33_r10/cases.json`),freeze=read(`${dir}/freeze.json`);
const observations=read(`${dir}/observations.json`),verdict=read(`${dir}/verdict.json`);
assert.equal(freeze.plan_commit,'06b43b9288962d77542e6533780d1f9d51c09972');
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
for(const name of [...fixture.variants,'restart']){
  const process=read(`${dir}/${name}-process.json`);
  assert.equal(process.status,0,name);assert.notEqual(process.timeout,true,name);
  assert.equal(process.boundary_reached,true,name);
  assert.equal(fs.readFileSync(`${dir}/${name}.stderr`,'utf8'),'');
}
const results=read(`${dir}/native-results.json`),resultHead=x=>Array.isArray(x)?x[0]:x;
assert.equal(read(`${dir}/canonical/ledger-report-restart.json`).status,'valid');
const opportunity=x=>x[7][1];
const ordered=x=>[...x].sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
const opportunityProjection=x=>({kind:x[0],scope:x[2],target:x[3],
  soul_ground:['soul-ground',ordered(x[4][1])],source_events:['source-events',ordered(x[5][1])],
  repeated_relations:ordered(x[6][1].map(row=>[row[0],row[1],
    ordered([row[2][1],row[3][1]]),ordered([row[2][3],row[3][3]])])),continuation:x.slice(7)});
for(const name of ['canonical','neutral-order']){
  assert.equal(results[name].state[3],fixture.expected.canonical_phase);
  assert.equal(results[name].state[9],fixture.expected.canonical_result);
  assert.equal(results[name].rna.status,fixture.expected.canonical_rna_status);
  assert.equal(results[name].effect_request[0],'unapplied-effects');
  assert.equal(results[name].effect_request[1].length,1);
  assert.equal(results[name].effect_request[1][0][0],'dispatch');
  assert.equal(results[name].effect_request[2],'authority-awaiting-separate-authorization');
  assert.equal(results[name].ledger.status,'valid');
}
assert.deepEqual(opportunityProjection(opportunity(results['neutral-order'].state)),
  opportunityProjection(opportunity(results.canonical.state)));
for(const [name,expected] of [['same-family',fixture.expected.same_family_result],
  ['self-authored',fixture.expected.self_authored_result],
  ['missing-capability',fixture.expected.missing_capability_result],
  ['exhausted-grant',fixture.expected.exhausted_grant_result]]){
  assert.equal(resultHead(results[name].state[9]),expected,name);assert.equal(results[name].rna,null,name);
  assert.equal(results[name].ledger.status,'valid',name);
}
assert.deepEqual(observations.before_restart_hashes,observations.after_restart_hashes);
assert.equal(observations.development_orientation_count_before_restart,1);
assert.equal(observations.development_orientation_count_after_restart,1);
assert.equal(observations.corrected_hooks_only,true);
assert.equal(observations.registered_hooks.length,2);
assert(!JSON.stringify(observations.registered_hooks).includes('InterestIdle'));
const runner=fs.readFileSync(`${root}/scripts/g33_r10/run.mjs`,'utf8');
assert(!/!\s*\(\s*(?:DObserve|DOpportunity|DDevelop|CStep)\b/.test(runner));
const bootstrap=fs.readFileSync(`${root}/src/bootstrap_development_reactor_v1.metta`,'utf8');
assert(!bootstrap.includes('bootstrap_interests.metta'));assert(!bootstrap.includes('InterestIdle'));
const membrane=fs.readFileSync(`${root}/effect_membranes/miter_development_reactor_v1.pl`,'utf8');
assert(!/['"]?(?:DObserve|DOpportunity|DDevelop|CStep)['"]?\s*\(/.test(membrane));
for(const key of Object.keys(fixture.resources))assert.equal(verdict[key],fixture.resources[key],key);
assert.equal(observations.canonical_passed,true);assert.equal(observations.causal_passed,true);
assert.equal(observations.restart_passed,true);assert.equal(observations.all_processes_clean,true);
assert.equal(verdict.status,'PASS-BOUNDED');
console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R10',claims:4}));
