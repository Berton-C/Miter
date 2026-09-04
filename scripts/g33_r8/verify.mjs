// Independent evidence verifier. It never imports into Miter cognition.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G33/R8/attempt-${tag}`;
const read=p=>JSON.parse(fs.readFileSync(p));
const fixture=read(`${root}/tests/fixtures/g33_r8/cases.json`);
const opening=read(`${dir}/opening.json`),freeze=read(`${dir}/freeze.json`);
const products=read(`${dir}/native-products.json`),observations=read(`${dir}/observations.json`);
const verdict=read(`${dir}/verdict.json`),processResult=read(`${dir}/current-recurring-ingress-process.json`);
assert.equal(opening.plan_commit,'f841e665b7abadd4b241ba8b34c5b6ea8acf6fd2');
assert.equal(freeze.plan_commit,opening.plan_commit);
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
const head=x=>Array.isArray(x)?x[0]:null;
assert.equal(head(products.calibration),'development-calibration');
assert.equal(head(products.calibration[1]),fixture.canonical.expected_opportunity_head);
assert.equal(head(products.calibration[2]),fixture.canonical.expected_rna_head);
assert.equal(head(products['same-family']),fixture.same_family.expected_head);
assert.equal(head(products['self-authored']),fixture.self_authored.expected_head);
assert(observations.admitted_current_audits.length===2,'canonical audits were not admitted');
assert.equal(processResult.status,0);assert.equal(processResult.timeout,undefined);
assert.equal(processResult.idle_reached,true);assert.equal(observations.process.stderr,'');
assert(observations.trace_kinds.includes('quiescent-ready'));
assert(observations.trace_kinds.includes('reactor-stopped'));
for(const key of ['model_calls','external_network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','human_emissions','external_effects'])assert.equal(verdict[key],0,key);
if(verdict.status==='FAIL'){
  assert.equal(verdict.current_contact_audits_have_native_developmental_bite,true);
  assert.equal(verdict.recurring_reactor_reaches_corrected_development_without_stage_command,false);
  assert.equal(observations.corrected_hook_present,false);
  assert.equal(observations.recurring_products.present,false);
  assert.equal(verdict.first_discontinuity,
    'corrected-development-consumer-not-registered-with-recurring-reactor');
  console.log(JSON.stringify({status:'VERIFIED-FAIL',gate:'G33',revision:'R8',
    first_discontinuity:verdict.first_discontinuity,
    standing:'Native source-grounded development has causal bite but is unreachable from the current recurring reactor without a builder stage call.'}));
}else{
  assert.equal(verdict.status,'PASS-BOUNDED');
  assert.equal(observations.corrected_hook_present,true);
  assert.equal(observations.recurring_products.present,true);
  console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R8'}));
}
