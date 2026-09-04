// Independent structural verifier; no native semantic implementation is loaded.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';

process.chdir(root);const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R6/attempt-${tag}`;
const read=name=>JSON.parse(fs.readFileSync(`${root}/${rel}/${name}`));
const p=read('native-products.json'),handler=read('sever-handler-products.json'),
 runtime=read('sever-runtime-products.json'),publicProducts=read('public-bootstrap-products.json'),
 freeze=read('freeze.json'),
 lineage=read('stimulus-lineage.json');
const opening=checkOpen('docs/gates/G33/R6/plan.json');
assert.equal(opening.plan_commit,'3aba0601a078d4e87a43ee158421091a4193a2f9');
const head=x=>Array.isArray(x)?x[0]:null;
const disposition=x=>head(x)==='voice-result'?x[2]:x;
const field=(x,name)=>x.find(v=>Array.isArray(v)&&v[0]===name);
const cert=disposition(p.canonical);
assert.equal(head(p.canonical),'voice-result');assert.equal(p.canonical[1],'native-result-stored');
assert.equal(head(cert),'expression-certificate-v1');assert.equal(cert.at(-1),'no-emission-authority');
assert.equal(head(disposition(publicProducts['public-bootstrap'])),'expression-certificate-v1');
assert.equal(field(cert,'first-audit')[1][3],'meaning-altered');
assert.equal(field(cert,'fresh-audit')[1][3],'faithful');
assert.equal(head(disposition(p.faithful)),'expression-ready');
assert.notEqual(head(disposition(p.faithful)),'expression-certificate-v1');
assert.equal(head(disposition(p['no-joint'])),'expression-repair-alternatives');
assert.equal(head(disposition(p['missing-frame'])),'expression-incomplete');
assert.equal(head(p['identity-mismatch']),'expression-revalidation');
assert.equal(head(disposition(p['scope-mismatch'])),'expression-revalidation');
assert.equal(head(p['malformed-state']),'expression-transport-incomplete');
assert.equal(p['language-input-frame'],'source-frame-unavailable');
assert.equal(p['language-input-preserved'],'true');
assert.equal(head(p['observed-products-valid']),'expression-certificate-v1');
assert.equal(head(p['observed-products-forged']),'expression-revalidation-required');
assert.notEqual(head(disposition(handler['sever-handler'])),'expression-certificate-v1');
assert.equal(head(disposition(runtime['sever-runtime'])),'expression-repair-incomplete');

function semantic(c){
 const i=field(c,'intention')[1],o=field(c,'selected-expression')[1],a=field(c,'fresh-audit')[1];
 return {wanted:i[4].map(x=>JSON.stringify(x[1])).sort(),clauses:o[1].slice().sort(),
  standing:a[3],authority:c.at(-1)};
}
assert.deepEqual(semantic(disposition(p['neutral-source-order'])),semantic(cert));
const repaired=field(cert,'selected-expression')[1][1];
const authored=['config/relational-voice-repair-runtime-v1.json','src/relational_voice.metta',
 'src/relational_voice_repair_v1.metta','effect_membranes/miter_relational_voice_repair_v1.pl',
 'tests/fixtures/g33_r6/cases.json','scripts/g33_r6/run.mjs','scripts/g33_r6/verify.mjs'];
for(const clause of repaired)for(const file of authored)
 assert(!fs.readFileSync(`${root}/${file}`,'utf8').includes(clause),`repaired clause supplied by ${file}`);
const rv=fs.readFileSync(`${root}/src/relational_voice_repair_v1.metta`,'utf8');
assert.equal((rv.match(/\(let \$handled \(RRenderedContinuation \$frame \$i \$state\)/g)??[]).length,1);
assert(rv.includes('(RWaitReturned $root $i $frame $state)'));
for(const required of ['src/development_evidence.metta','src/voice_construction.metta',
 'src/relational_voice_repair_v1.metta','effect_membranes/miter_relational_voice_repair_v1.pl',
 'config/relational-voice-repair-runtime-v1.json'])
 assert(fs.readFileSync(`${root}/effect_membranes/miter_relational_voice_v2.pl`,'utf8').includes(required));
assert.equal(lineage.repaired_wording_builder_authored,false);
for(const row of freeze.files)assert.equal(hash(fs.readFileSync(row.path)),row.sha256,row.path);
for(const key of ['model_calls','network_requests','credential_lookups','chroma_mutations',
 'mattermost_operations','human_emissions','external_effects'])assert.equal(freeze[key],0,key);

const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R6',
 claims:{current_wait_path_delegates_to_single_native_handler:true,
  altered_rendering_crosses_r5_repair_continuation:true,
  faithful_and_uncertain_products_remain_differentiated:true,
  public_integration_retains_zero_emission_authority:true},
 first_standing:field(cert,'first-audit')[1][3],fresh_standing:field(cert,'fresh-audit')[1][3],
 authority:cert.at(-1),faithful_control:head(disposition(p.faithful)),
 no_joint:head(disposition(p['no-joint'])),missing_frame:head(disposition(p['missing-frame'])),
 forged_observation:head(p['observed-products-forged']),
 severed_handler:head(disposition(handler['sever-handler'])),
 severed_runtime_capability:head(disposition(runtime['sever-runtime'])),
 neutral_source_order_invariant:true,exact_repaired_wording_absent_from_builder_inputs:true,
 legacy_voice_policy_loaded:false,builder_selected_semantic_winner:false,...Object.fromEntries(
  ['model_calls','network_requests','credential_lookups','chroma_mutations',
   'mattermost_operations','human_emissions','external_effects'].map(k=>[k,freeze[k]])),
 limits:'Exact native handler called by RWait under disclosed rendered states; no fresh model, actual poll loop, human emission, effect eligibility, general semantics, or complete G33 claim.'};
fs.writeFileSync(`${root}/${rel}/verdict.json`,JSON.stringify(verdict,null,2)+'\n');
console.log(JSON.stringify(verdict));
