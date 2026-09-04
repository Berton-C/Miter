// Independent verifier for the preserved R8 attempt-001 failure.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';

process.chdir(root);
const dir=`${root}/evidence/G33/R8/attempt-001`;
const read=p=>JSON.parse(fs.readFileSync(p));
const opening=read(`${dir}/opening.json`),freeze=read(`${dir}/freeze.json`);
const verdict=read(`${dir}/verdict.json`),observations=read(`${dir}/observations.json`);
const isolation=read(`${dir}/isolation/summary.json`);
assert.equal(opening.plan_commit,'f841e665b7abadd4b241ba8b34c5b6ea8acf6fd2');
assert.equal(freeze.plan_commit,opening.plan_commit);
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
assert.equal(verdict.status,'FAIL');
assert.equal(verdict.first_discontinuity,'current-native-development-calibration');
assert.equal(observations.process.status,0);assert.equal(observations.process.idle_reached,true);
assert.deepEqual(observations.registered_hooks,[
  ['rna-advancer','DevelopRNA','DevelopBoundary'],['idle-promoter','InterestIdle']]);
assert.equal(observations.corrected_hook_present,false);
assert.equal(observations.recurring_products.present,false);
for(const name of ['current-development-bootstrap','current-voice-construction-bootstrap',
  'current-relational-voice-bootstrap'])
  assert.equal(isolation.variants[name].product_head,'development-held',name);
assert.equal(isolation.variants['minimal-current-semantic-imports'].product_head,
  'development-opportunity');
for(const key of ['model_calls','external_network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','human_emissions','external_effects'])assert.equal(verdict[key],0,key);
console.log(JSON.stringify({status:'VERIFIED-FAIL',gate:'G33',revision:'R8',
  first_discontinuity:verdict.first_discontinuity,
  isolation:'same contacts pass with single dependency-ordered semantic imports; current public bootstraps hold them',
  downstream_observation:'only historical InterestIdle/DevelopBoundary hooks are registered'}));
