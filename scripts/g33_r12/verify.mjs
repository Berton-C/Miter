// Independent offline verifier. No PeTTa, provider, Keychain, service, or effect call.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);
const tag=process.argv[2]??'016',dir=`${root}/evidence/G33/R12/attempt-${tag}`;
const read=file=>JSON.parse(fs.readFileSync(file));
const fixture=read(`${root}/tests/fixtures/g33_r12/cases.json`),freeze=read(`${dir}/freeze.json`);
const observation=read(`${dir}/observations.json`),verdict=read(`${dir}/verdict.json`);
assert.equal(freeze.plan_commit,'17be857f2f0bd4a30bc5afd3c4ac2d98da63ebcb');
assert.equal(freeze.model_calls,1);assert.equal(freeze.model,fixture.expected.model);
assert.equal(freeze.max_output_tokens,4096);assert.equal(freeze.deadline_seconds,120);
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
for(const name of ['resource-cases','consequence-severed']){
  const process=read(`${dir}/${name}-process.json`);assert.equal(process.status,0,name);
  assert.notEqual(process.timeout,true,name);assert.equal(fs.readFileSync(`${dir}/${name}.stderr`,'utf8'),'');
}
const initial=read(`${dir}/canonical-process.json`);assert.equal(initial.final_present,true);
assert.equal(initial.status,null);assert.equal(initial.signal,'SIGTERM');assert.equal(initial.timeout,true);
const stopRestart=read(`${dir}/stop-restart-process.json`);assert.equal(stopRestart.status,0);
assert.equal(stopRestart.observed_trajectory_event,'reactor-stopped');assert.equal(stopRestart.generation_replayed,false);
const request=read(`${dir}/canonical/g33-r12-generation-2-request.json`);
assert.equal(request.body.max_tokens,4096);const disclosed=JSON.parse(request.body.messages[1].content);
assert.equal(disclosed.required_schema_sha256,hash(fs.readFileSync(`${root}/config/voice-realization-schema-v2.json`)));
assert.deepEqual(disclosed.required_schema,read(`${root}/config/voice-realization-schema-v2.json`));
const s=observation.selection;assert.equal(s.canonical[0],'resource-selected');
assert.equal(s.canonical[1],fixture.expected.selected_resource);
assert.equal(s.neutral[0],s.canonical[0]);assert.equal(s.neutral[1],s.canonical[1]);
assert.equal(s.neutral[2],s.canonical[2]);assert.deepEqual(s.neutral[3],s.canonical[3]);
assert.equal(s.absent_authorization,'resource-selection-unresolved');assert.equal(s.ambiguous,'resource-selection-unresolved');
assert.deepEqual(s.wrong_model_product,['model-candidate-unavailable']);
const final=read(`${dir}/canonical/final.json`).native;assert.equal(final[0],'development-helix-result');
assert.equal(final[2][11],fixture.expected.model);assert.equal(final[3][1][2],fixture.expected.candidate_id);
assert.equal(final[4],'candidate-quarantined');assert.equal(final[5][3][0],'trial-admissible');
assert.equal(final[5][4],'helix-development-durable');assert.equal(final[6][1][2].length,2);
assert.equal(final[6][4][2].length,1);assert.equal(final[6][4][2][0][2],fixture.expected.after_maximum);
assert.equal(observation.consequence_severed.maxima.length,2);
assert.equal(observation.restart.maxima.length,1);assert.equal(observation.restart.generation,'no-generation-replay');
for(const key of ['resource_order_neutral','unauthorized_and_ambiguous_held','model_product_quarantined',
  'trial_admissible_without_material_loss','consequence_changes_later_ranking','consequence_severance_retains_tie',
  'restart_preserves_changed_ranking_without_replay'])assert.equal(observation[key],true,key);
for(const key of Object.keys(fixture.resources))assert.equal(observation[key],fixture.resources[key],key);
assert.equal(verdict.status,'PASS-BOUNDED');
for(const key of ['waiting_undertaking_resumes_through_native_resource_comparison',
  'exact_schema_and_calibrated_model_product_remain_non_authoritative',
  'model_product_remains_quarantined_until_independent_v2_trial','native_consequence_and_nal_revision_change_later_ranking',
  'development_and_changed_possibility_survive_restart','explicit_stop_recognized_on_fresh_process'])assert.equal(verdict[key],true,key);
const raw=fs.readFileSync(`${dir}/canonical/g33-r12-generation-2-raw.json`,'utf8');
assert(!/sk-or-v1-[A-Za-z0-9._-]+/i.test(raw));
const all=fs.readdirSync(dir,{recursive:true}).filter(name=>fs.statSync(`${dir}/${name}`).isFile());
for(const name of all){const text=fs.readFileSync(`${dir}/${name}`,'utf8');assert(!/sk-or-v1-[A-Za-z0-9._-]+/i.test(text),name);}
console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R12-R2',claims:4,
  disclosed_limit:'Initial daemon required harness SIGTERM after final serialization; fresh-process stop and no-generation-replay passed.'}));
