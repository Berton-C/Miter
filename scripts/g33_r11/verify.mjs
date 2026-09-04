// Independent G33 R11 R2 verifier; no native/model/effect execution.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);
const tag=process.argv[2]??'003',dir=`${root}/evidence/G33/R11/attempt-${tag}`;
const read=file=>JSON.parse(fs.readFileSync(file));
const freeze=read(`${dir}/freeze.json`),fixture=read(`${root}/tests/fixtures/g33_r11/cases.json`);
const observation=read(`${dir}/observations.json`),verdict=read(`${dir}/verdict.json`);
assert.equal(freeze.plan_commit,'88b5fcd30a848ccb81a44f8ec878fc8a1c4ac11b');
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
for(const name of [...fixture.recurring_variants,'restart','dependency-severed']){
  const process=read(`${dir}/${name}-process.json`);assert.equal(process.status,0,name);
  assert.notEqual(process.timeout,true,name);assert.equal(process.boundary_reached,true,name);
  assert.equal(fs.readFileSync(`${dir}/${name}.stderr`,'utf8'),'');
}
assert.equal(read(`${dir}/root-probe-process.json`).status,0);
assert.equal(fs.readFileSync(`${dir}/root-probe.stderr`,'utf8'),'');
assert.equal(read(`${dir}/module-mechanics-process.json`).status,0);
assert.equal(fs.readFileSync(`${dir}/module-mechanics.stderr`,'utf8'),'');
assert.equal(read(`${dir}/canonical/ledger-report-restart.json`).status,'valid');
assert.equal(read(`${dir}/module-mechanics/ledger-report.json`).status,'valid');
for(const key of ['qualified_roots_only','corrected_hooks_only','recurring_causal_path',
  'restart_non_replay','dependency_severance','module_containment_requalified','all_processes_clean'])
  assert.equal(observation[key],true,key);
assert.equal(observation.hooks.length,2);assert.equal(observation.severed_hooks.length,0);
assert(!JSON.stringify(observation.hooks).includes('InterestIdle'));
assert(!JSON.stringify(observation.hooks).includes('DevelopBoundary'));
assert.equal(observation.module_products.validation,'module-valid');
assert.equal(observation.module_products.quarantine,'candidate-quarantined');
assert.equal(observation.module_products['forbidden-validation'],'forbidden-effect');
assert.equal(observation.module_products['forbidden-quarantine'],'candidate-rejected');
assert.deepEqual(observation.checkpoint_hashes_before,observation.checkpoint_hashes_after);
assert.equal(observation.orientation_count_before,1);assert.equal(observation.orientation_count_after,1);
const bootstrap=fs.readFileSync(`${root}/src/bootstrap_modules.metta`,'utf8');
assert(bootstrap.includes('bootstrap_development_reactor_v1.metta'));assert(!bootstrap.includes('bootstrap_interests.metta'));
const membrane=fs.readFileSync(`${root}/effect_membranes/miter_development_reactor_v1.pl`,'utf8');
assert(membrane.includes("'/Users/claritymiter/miter/evidence/G33/'"));
assert(membrane.includes("'/Users/claritymiter/miter/runtime/'"));
const runner=fs.readFileSync(`${root}/scripts/g33_r11/run.mjs`,'utf8');
assert(!/!\s*\(\s*(?:DObserve|DOpportunity|DDevelop|CStep|TrialVoicePlan|ModuleGenerationRNA)\b/.test(runner));
assert(!/!\s*\(\s*miter_module_generate\b/.test(runner));
for(const key of Object.keys(fixture.resources)){
  assert.equal(observation[key],fixture.resources[key],key);assert.equal(verdict[key],fixture.resources[key],key);
}
assert.equal(verdict.status,'PASS-BOUNDED');
for(const key of ['development_membrane_admits_only_qualified_repository_roots',
  'default_bootstrap_activates_only_source_grounded_development_hooks',
  'default_bootstrap_preserves_causal_neutral_and_restart_behavior',
  'module_containment_loads_without_behavioral_selection'])assert.equal(verdict[key],true,key);
console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R11-R2',claims:4}));
