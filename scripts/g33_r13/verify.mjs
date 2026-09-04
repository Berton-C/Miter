// Independent offline G33 R13 verifier. No PeTTa, provider, Keychain, service,
// or effect call is available through this script.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);
const tag=process.argv[2]??'001',dir=`${root}/evidence/G33/R13/attempt-${tag}`;
const read=file=>JSON.parse(fs.readFileSync(file));
const expected=read(`${root}/tests/fixtures/g33_r13/cases.json`).expected;
const freeze=read(`${dir}/freeze.json`),o=read(`${dir}/observations.json`),v=read(`${dir}/verdict.json`);
assert.equal(freeze.plan_commit,'706e2d4c6b2957f67df90c420ae18476daed7f79');
assert.equal(freeze.model_calls,0);assert.equal(freeze.credential_lookups,0);assert.equal(freeze.external_effects,0);
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
assert.equal(o.candidate_sha256,expected.candidate_sha256);assert.equal(o.trial.standing,expected.trial_standing);
assert.equal(o.trial.cases,expected.trial_cases);assert.equal(o.trial.expansions,expected.expansions);
for(const key of ['parent_report_sha256','candidate_report_sha256','decision_sha256'])assert.match(o.trial[key],/^[a-f0-9]{64}$/);
assert.match(o.efficacy.before_sha256,/^[a-f0-9]{64}$/);assert.match(o.efficacy.after_sha256,/^[a-f0-9]{64}$/);
assert.equal(o.efficacy.before_maxima.length,expected.before_maxima);assert.equal(o.efficacy.after_maxima.length,1);
assert.equal(o.efficacy.after_maxima[0][2],expected.after_maximum);assert.equal(o.severed_maxima.length,expected.before_maxima);
assert.equal(o.neutral_same_candidate,true);assert.equal(o.neutral_same_trial_standing,true);assert.equal(o.neutral_same_after_maxima,true);
assert.equal(o.restart.standing,'development-helix-v2-rehydrated');assert.equal(o.restart.maxima.length,1);
assert.equal(o.restart.maxima[0][2],expected.after_maximum);assert.equal(o.restart.generation,'no-generation-replay');
assert.deepEqual(o.same_process_stop,{status:0,signal:null,timeout:false,
  post_final_stop_ms:o.same_process_stop.post_final_stop_ms,event_kind:'reactor-stopped'});
assert(o.same_process_stop.post_final_stop_ms<=expected.max_post_final_stop_ms);
assert.equal(o.roots.canonical,'qualified-development-root');assert.equal(o.roots.r12,'qualified-development-root');
assert.equal(o.roots.other_gate,'rejected-development-root');assert.equal(o.roots.traversal,'rejected-development-root');
assert.equal(o.malformed_candidate_held,true);assert.equal(o.historical_provider_claims,2);
assert(o.sizes.final<=expected.max_final_bytes);assert(o.sizes.trial<=expected.max_trial_bytes);
assert(o.sizes.before<=expected.max_ranking_bytes);assert(o.sizes.after<=expected.max_ranking_bytes);
assert(o.sizes.restart<=expected.max_restart_bytes);assert(o.sizes.stdout<=expected.max_stdout_bytes);
assert(o.sizes.runtime<=expected.max_runtime_bytes);
for(const key of ['model_calls','credential_lookups','mattermost_requests','chroma_requests','private_memory_reads','human_emissions','external_effects'])assert.equal(o[key],0,key);
assert.equal(v.status,'PASS-BOUNDED');
for(const key of ['native_semantics_produce_compact_hash_bound_proofs','compact_proof_retains_trial_and_consequence_causality',
  'same_process_stop_exits_cleanly_after_final_proof','restart_rehydrates_changed_ranking_without_generation_replay'])assert.equal(v[key],true,key);
const all=fs.readdirSync(dir,{recursive:true}).filter(name=>fs.statSync(`${dir}/${name}`).isFile());
for(const name of all){const text=fs.readFileSync(`${dir}/${name}`,'utf8');assert(!/sk-or-v1-[A-Za-z0-9._-]+/i.test(text),name);}
console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R13',claims:4,sizes:o.sizes,
  limit:'Exact R12 candidate/cases; compact projection and same-process stop only.'}));
