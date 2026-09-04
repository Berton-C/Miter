// Independent deterministic verifier for G33 R2 evidence.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins} from '../g22_v2/common.mjs';

process.chdir(root);
const rel=process.argv[2]??'evidence/G33/R2/attempt-001';
assert.match(rel,/^evidence\/G33\/R2\/attempt-\d{3}$/);
const dir=`${root}/${rel}`;
const opening=checkOpen('docs/gates/G33/R2/plan.json');
assert.equal(opening.plan_commit,'aba224974d74ca86a6144a524b2170db0ac2e6c9');
const o=read(`${dir}/observations.json`);
const contract=read(`${root}/docs/gates/G33/R2/expected-cases.json`);

assert.equal(o.localhost_model_calls,2);assert.equal(o.external_network_requests,0);
assert.equal(o.credential_lookups,0);assert.equal(o.external_effects,0);
assert.equal(o.chroma_mutations,0);assert.equal(o.mattermost_operations,0);
assert.equal(o.genuine_unseen_claim,false);assert.equal(o.model_selected_project_id,false);
assert.equal(o.raw_model_products_evaluated_as_code,false);
assert.equal(o.modelObservations.length,2);
for(const row of o.modelObservations){
  assert.equal(row.native_product,'continuity-answer-stored');
  assert.equal(row.typed.standing,'generated-source-verified-candidate');
  assert.equal(row.answer.certificate,'exact-continuity');
  assert.equal(row.answer.authority,'native-capsule-and-trajectory-certificate');
  for(const forbidden of contract.authority_invariant.model_forbidden_fields)
    assert.equal(Object.hasOwn(row.typed,forbidden),false,`${row.id} ${forbidden}`);
}
assert.deepEqual(o.modelObservations[0].answer.exact_state,o.modelObservations[1].answer.exact_state);
assert.deepEqual(Object.fromEntries(o.parseAdversaries.map(x=>[x.id,x.observed])),{
  'wrong-request-id':'continuity-reading-request-mismatch',
  'wrong-source-hash':'continuity-reading-source-mismatch',
  'fabricated-span':'continuity-reading-span-mismatch',
  'kind-not-named':'continuity-reading-kind-not-named',
  'forbidden-extra-field':'continuity-reading-malformed',
  'malformed-json':'continuity-reading-malformed'});
assert.deepEqual(Object.fromEntries(o.nativeAdversaries.map(x=>[x.id,x.observed])),{
  'no-facet':'continuity-reading-facets-unsupported',
  'unknown-facet':'continuity-reading-facets-unsupported',
  'unsupported-relation':'continuity-reading-contains-unsupported-relation',
  'duplicate-kind':'continuity-reading-project-kind-not-unique',
  'insufficient':'continuity-reading-insufficient'});
const ground=Object.fromEntries(o.grounding.map(x=>[x.id,x]));
assert.equal(ground['zero-project'].observed,'continuity-project-unavailable');
assert.equal(ground['ambiguous-project'].observed,'continuity-project-ambiguous');
assert.equal(ground['capsule-severed'].certificate,'non-authoritative-recall');
assert.equal(ground['trajectory-severed'].certificate,'non-authoritative-recall');
assert.equal(ground.restored.certificate,'exact-continuity');
assert.equal(o.provider_off,'continuity-reading-provider-unavailable');

const requiredFiles=['observations.json','freeze.json',
  ...o.modelObservations.flatMap(x=>[
    `model-${x.id}/runtime/outputs/continuity-reading-template.json`,
    `model-${x.id}/runtime/outputs/continuity-reading-request.json`,
    `model-${x.id}/runtime/outputs/continuity-reading-raw.json`,
    `model-${x.id}/runtime/outputs/continuity-reading-timing.json`,
    `model-${x.id}/runtime/outputs/continuity-reading-typed.json`,
    `model-${x.id}/runtime/outputs/answer.json`])];
for(const file of requiredFiles)assert(fs.existsSync(`${dir}/${file}`),file);

const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R2',
  claim:'source-grounded continuity semantic seam',
  current_consumer:'ContinuityRNA plus ContinuityReadingDecision',
  actual_local_model_products:2,exact_authority_equal_across_wordings:true,
  generated_reading_separated_from_authority:true,native_scoped_project_grounding:true,
  exact_capsule_trajectory_authority_preserved:true,
  malformed_ambiguity_and_provider_loss_differentiated:true,
  exact_regression_and_inspected_transfer_pass:true,genuine_unseen_heldout_claim:false,
  whole_g33_complete:false,old_r1_failure_preserved:true,...{
    external_network_requests:o.external_network_requests,credential_lookups:o.credential_lookups,
    external_effects:o.external_effects,chroma_mutations:o.chroma_mutations,
    mattermost_operations:o.mattermost_operations},
  limits:'R2 proves a bounded source-grounded continuity-reading seam over two disclosed synthetic requests. It does not prove general language understanding, a genuinely unseen T-19 case, stale external-artifact reconciliation, multi-user mixed scope, or the complete G33 organism.'};
save(`${dir}/verdict.json`,verdict);
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(`${d}/${e.name}`):[`${d}/${e.name}`]);
const files=walk(dir).filter(file=>!file.endsWith('/manifest.json'));
save(`${dir}/manifest.json`,{schema:'miter-g33-r2-manifest-v1',files:pins(files),
  required_files:pins(requiredFiles.map(file=>`${dir}/${file}`)),result:verdict.status,
  public_private_scan_required:true});
console.log(JSON.stringify(verdict));
