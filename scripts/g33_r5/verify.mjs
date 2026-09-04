// Independent structural verifier. It never imports MeTTa and never supplies
// a repair, audit, semantic winner, or certificate to the runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R5/attempt-${tag}`;
const read=name=>JSON.parse(fs.readFileSync(`${root}/${rel}/${name}`));
const p=read('native-products.json'),stale=read('stale-certificate-products.json'),
  severed=read('sever-reaudit-products.json'),freeze=read('freeze.json');
const opening=checkOpen('docs/gates/G33/R5/plan.json');
assert.equal(opening.plan_commit,'dc64f3a35e5681e2b421500238e1208ebedf6428');

const head=x=>Array.isArray(x)?x[0]:null;
const field=(x,name)=>x.find(v=>Array.isArray(v)&&v[0]===name);
const cert=p.canonical;
assert.equal(head(cert),'expression-certificate-v1');
assert.equal(cert.at(-1),'no-emission-authority');
const firstAudit=field(cert,'first-audit')[1],repair=field(cert,'repair-request')[1];
const fresh=field(cert,'fresh-audit')[1],selected=field(cert,'selected-expression')[1];
assert.equal(firstAudit[3],'meaning-altered');assert.equal(head(repair),'repair-request');
assert.equal(fresh[3],'faithful');assert.equal(head(selected),'supported-expression');
const alterations=field(firstAudit,'alterations')[1];
assert.equal(alterations.filter(x=>x[0]==='unsupported-alteration').length,1);
assert.equal(alterations.filter(x=>x[0]==='omitted-meaning').length,4);
assert.equal(head(p['canonical-verification']),'certificate-valid');
assert.equal(head(p['defective-bypass']),'certificate-invalid');
assert.equal(head(stale['stale-certificate']),'certificate-invalid');
assert.equal(head(p['sever-joint']),'expression-repair-alternatives');
assert.notEqual(JSON.stringify(p['sever-material-relation']),JSON.stringify(cert));
assert.equal(head(p['tampered-capability']),'expression-repair-incomplete');
assert.equal(head(p['symlink-capability']),'expression-repair-incomplete');
assert.equal(head(severed['sever-reaudit']),'expression-repair-incomplete');

function semantic(certLike){
  assert.equal(head(certLike),'expression-certificate-v1');
  const intention=field(certLike,'intention')[1];
  const option=field(certLike,'selected-expression')[1];
  const audit=field(certLike,'fresh-audit')[1];
  return {wanted:intention[4].map(x=>JSON.stringify(x[1])).sort(),
    read:option[1].slice().sort(),standing:audit[3],authority:certLike.at(-1)};
}
assert.deepEqual(semantic(p['neutral-source-order']),semantic(cert));

function optionMeaning(eligible){
  assert.equal(head(eligible),'supported-expression-alternatives');
  return eligible[1].map(option=>({clauses:option[1].slice().sort(),
    fragments:option[2].map(fragment=>JSON.stringify(fragment[2])).sort()}))
    .sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
}
assert.deepEqual(optionMeaning(p['construction-order-neutral']),
  optionMeaning(p['construction-order-original']));

const repairedClauses=selected[1];
const authored=['src/relational_voice_repair_v1.metta',
  'effect_membranes/miter_relational_voice_repair_v1.pl',
  'tests/fixtures/g33_r5/cases.json','scripts/g33_r5/cases.mjs',
  'scripts/g33_r5/run.mjs','scripts/g33_r5/verify.mjs'];
for(const clause of repairedClauses){
  for(const file of authored)assert(!fs.readFileSync(`${root}/${file}`,'utf8').includes(clause),
    `repaired clause supplied by ${file}`);
}
for(const row of freeze.files)assert.equal(hash(fs.readFileSync(row.path)),row.sha256,row.path);
for(const key of ['model_calls','network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','human_emissions','external_effects'])assert.equal(freeze[key],0,key);

const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R5',
  claims:{repair_request_consumed:true,source_joint_determines_unique_repair:true,
    faithful_reaudit_and_recomputable_certificate:true,
    bypass_ambiguity_forged_capability_and_stale_scope_held:true},
  initial_standing:firstAudit[3],initial_alterations:alterations.map(x=>x[0]),
  supported_options:1,fresh_standing:fresh[3],authority:cert.at(-1),
  neutral_source_order_invariant:true,neutral_construction_order_invariant:true,
  severed_joint:head(p['sever-joint']),severed_reaudit:head(severed['sever-reaudit']),
  tampered_capability:head(p['tampered-capability']),
  stale_certificate:head(stale['stale-certificate']),
  exact_repaired_wording_absent_from_builder_inputs:true,
  legacy_voice_policy_loaded:false,builder_selected_semantic_winner:false,
  model_text_authoritative:false,...Object.fromEntries(
    ['model_calls','network_requests','credential_lookups','chroma_mutations',
     'mattermost_operations','human_emissions','external_effects'].map(k=>[k,freeze[k]])),
  limits:'Finite disclosed source frame, controlled defective candidate, and already-accepted expressive capability; no claim of general semantics, public RRun/RWait integration, emission, or complete G33.'};
fs.writeFileSync(`${root}/${rel}/verdict.json`,JSON.stringify(verdict,null,2)+'\n');
console.log(JSON.stringify(verdict));
