// Independent R7 evidence verifier. It does not load Miter semantic code.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';

process.chdir(root);const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R7/attempt-${tag}`;
const read=name=>JSON.parse(fs.readFileSync(`${root}/${rel}/${name}`));
const observations=read('observations.json'),freeze=read('freeze.json');
const opening=checkOpen('docs/gates/G33/R7/plan.json');
assert.equal(opening.plan_commit,'30991942c7ff5c0cd433b5aafd0996b0e7b89262');
for(const row of freeze.files)assert.equal(hash(fs.readFileSync(row.path)),row.sha256,row.path);
assert.equal(observations.continuity.passed,true);
assert.equal(observations.continuity.native,'continuity-answer-stored');
assert.equal(observations.continuity.typed.standing,'generated-source-verified-candidate');
assert.equal(observations.continuity.answer.certificate,'exact-continuity');
assert.equal(observations.continuity.trajectory_after_lines,
  observations.continuity.trajectory_before_lines+2);

const head=x=>Array.isArray(x)?x[0]:null;
const disposition=x=>head(x)==='voice-result'?x[2]:x;
const field=(x,name)=>x.find(value=>Array.isArray(value)&&value[0]===name);
const semantic=x=>{
  const i=field(x,'intention')[1],o=field(x,'selected-expression')[1];
  const a=field(x,'fresh-audit')[1];
  return {wanted:i[4].map(value=>JSON.stringify(value[1])).sort(),
    clauses:o[1].slice().sort(),standing:a[3],authority:x.at(-1)};
};
const canonical=disposition(observations.voice.canonical);
assert.equal(head(canonical),'expression-certificate-v1');
assert.equal(canonical.at(-1),'no-emission-authority');
assert.equal(head(disposition(observations.voice.missing_frame)),'expression-incomplete');
assert.deepEqual(semantic(disposition(observations.voice.neutral)),semantic(canonical));
assert.deepEqual(disposition(observations.voice.restored),canonical);

const canonicalTrace=read('reactor-canonical-trace.json');
const severedTrace=read('reactor-severed-trace.json');
const kinds=canonicalTrace.map(x=>x.kind),severedKinds=severedTrace.map(x=>x.kind);
assert.equal(kinds.filter(x=>x==='quiescent-ready').length,2);
assert.equal(kinds.filter(x=>x==='wake').length,1);
assert(kinds.includes('RNA-created'));assert(kinds.includes('reactor-stopped'));
assert(severedKinds.includes('unauthorized-event'));
assert(!severedKinds.includes('RNA-created'));assert(!severedKinds.includes('wake'));
assert(severedKinds.includes('reactor-stopped'));
assert.equal(observations.reactor.rna.status,'completed');
assert.equal(observations.reactor.rna.budget,0);
assert(observations.reactor.trajectory_after_lines>
  observations.reactor.trajectory_before_lines);
assert.equal(observations.phase_lineage.runtime_identity,observations.runtime_identity);
assert.equal(observations.builder_supplied_native_standing,false);
assert.equal(observations.historical_verdict_used_as_product,false);
assert.equal(observations.core_source_modified,false);

for(const key of ['external_network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','human_emissions','external_effects']){
  assert.equal(observations[key],0,key);assert.equal(freeze[key],0,key);
}
assert.equal(observations.localhost_model_calls,1);
assert.equal(freeze.localhost_model_calls,1);
const fixture=JSON.parse(fs.readFileSync(`${root}/tests/fixtures/g33_r7/cases.json`));
assert.equal(fixture.voice.returned_clauses.length,1);
const selected=field(canonical,'selected-expression')[1][1];
for(const clause of selected){
  for(const file of ['scripts/g33_r7/run.mjs','tests/fixtures/g33_r7/cases.json',
    'scripts/g33_r7/verify.mjs'])
    assert(!fs.readFileSync(`${root}/${file}`,'utf8').includes(clause),
      `repaired clause supplied by ${file}`);
}

const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R7',claims:{
  clean_lineage_crosses_current_continuity_and_repaired_voice:true,
  current_reactor_records_receptive_readiness_without_inference:true,
  fresh_contact_wakes_bounded_rna_and_explicit_stop_terminates:true,
  provenance_severance_blocks_synthetic_perpetual_work:true},
  continuity_standing:'exact-continuity',voice_standing:'expression-certificate-v1',
  voice_authority:'no-emission-authority',quiescent_ready_count:2,wake_count:1,
  synthetic_perpetual_rna_count:0,later_g33_development_phases_executed:false,
  localhost_model_calls:1,external_network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,human_emissions:0,external_effects:0,
  limits:'One finite clean lineage through current continuity, repaired voice, readiness, contact wake and stop. This does not establish complete Soul navigation, native purpose formation, development, learning, restart, Mattermost integration, or final G33.'};
fs.writeFileSync(`${root}/${rel}/verdict.json`,JSON.stringify(verdict,null,2)+'\n');
console.log(JSON.stringify(verdict));
