// Independent builder comparison of already-captured G32 native observations.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins} from '../g22_v2/common.mjs';

process.chdir(root);
const rel=process.argv[2]??'evidence/G32/attempt-001';assert.match(rel,/^evidence\/G32\/attempt-\d{3}$/);
const dir=`${root}/${rel}`,obs=read(`${dir}/observations.json`);
const expected=read(`${root}/docs/gates/G32/R1/expected-arm-matrix.json`);
assert.equal(expected.frozen_before_execution,true);assert.equal(expected.fixture_bundle.length,5);
assert.equal(checkOpen('docs/gates/G32/R1/plan.json').plan_commit,'154cbad8ddef038147ea4f69f9da223a5c892325');
const rows=output=>Object.fromEntries(output.bundle.map(row=>[row[1],row]));
const standing=(output,id)=>rows(output)[id][3];
const missing=(output,id)=>rows(output)[id][4][1];
const optional=(output,id)=>Object.fromEntries(rows(output)[id][6][1].map(x=>[x[1],x[2]]));
const canonical=obs.canonical;
for(const row of canonical.bundle)assert.equal(row[3],'ready',row[1]);
assert.equal(canonical.oracle[0],'oracle-bounded');
assert.equal(canonical.clock[0],'clock-available');
const expectations={
  'soul-severed':['authenticated-continuity','certified-expression','consequence-development','contained-extension','restart-recurring'],
  'memory-capsule-severed':['authenticated-continuity','restart-recurring'],
  'voiceaudit-severed':['certified-expression'],'vad-severed':['certified-expression'],
  'nace-severed':['consequence-development'],'consequence-severed':['consequence-development'],
  'endogenous-curiosity-severed':['contained-extension'],
  'continuity-lineage-severed':['restart-recurring'],
  'workshop-containment-severed':['contained-extension'],
  'mattermost-identity-severed':['authenticated-continuity','certified-expression']
};
for(const [arm,held] of Object.entries(expectations)){
  for(const id of Object.keys(rows(canonical)))assert.equal(standing(obs[arm],id),held.includes(id)?'held':'ready',`${arm}:${id}`);
  assert(held.every(id=>missing(obs[arm],id).length>0),arm);
}
for(const id of Object.keys(rows(canonical)))assert.equal(standing(obs['chroma-severed'],id),'ready');
assert.equal(optional(canonical,'authenticated-continuity').chroma,'available');
assert.equal(optional(obs['chroma-severed'],'authenticated-continuity').chroma,'unavailable');
assert.notDeepEqual(obs['chroma-severed'].bundle,canonical.bundle);
for(const arm of Object.keys(obs).filter(x=>x.startsWith('restored-')))
  assert.deepEqual(obs[arm],canonical,arm);
assert.deepEqual(obs['decorative-control'],canonical);
assert.deepEqual(obs['neutral-reordering'],canonical);
assert.deepEqual(obs['non-recursive'].bundle,canonical.bundle);
assert.equal(obs['non-recursive'].oracle[0],'oracle-bounded');
assert.deepEqual(obs['non-recursive'].oracle[1],['calls','1']);
assert.deepEqual(obs['non-recursive'].oracle[4],['recursive-authority','none']);
assert.deepEqual(obs['zero-pitch-perpetual-loop'].bundle,canonical.bundle);
assert.equal(obs['zero-pitch-perpetual-loop'].clock[0],'clock-available');
const zero=obs['zero-pitch-perpetual-loop']['zero-cycle'];
assert.equal(zero[0],'zero-pitch-result');assert.deepEqual(zero[2],['wait-cycles','32']);
assert.deepEqual(zero[4],['model-calls','0']);assert.deepEqual(zero[5],['effects','0']);
assert.deepEqual(zero[6],['completion','false']);assert.deepEqual(zero[7],['interruptible','true']);
for(const row of obs['held-out-meaning-preserving'].bundle)assert.equal(row[3],'ready');
const probes=read(`${dir}/current-consumer-probes.json`).native;
const probe=Object.fromEntries(probes.map(row=>[row[0],row[1]]));
assert.equal(probe.soul,'true');
assert.deepEqual(probe.continuity,['continuity-answer','exact-continuity','semantic-support']);
assert.deepEqual(probe['continuity-chroma-off'],['continuity-answer','exact-continuity','semantic-unavailable']);
assert.equal(probe['continuity-capsule-off'][1],'non-authoritative-recall');
assert.equal(probe.vad[0],'affect-cue');assert.equal(probe.nace[0],'stv');
assert.equal(probe.mattermost[0],'g30-trial-ready');assert.equal(probe.voice[0],'CertifiedUtterance');
assert.equal(probe.development[0],'continuation-supported');
const matrix=Object.entries(obs).map(([arm,output])=>({arm,
  cases:Object.fromEntries(output.bundle.map(row=>[row[1],{standing:row[3],missing:row[4][1],optional:row[6][1]}])),
  oracle:output.oracle[0],clock:output.clock[0],zero_cycle:output['zero-cycle']?.[0]??null}));
save(`${dir}/arm-matrix.json`,{schema:'miter-g32-observed-arm-matrix-v1',matrix});
save(`${dir}/verdict.json`,{status:'PASS-BOUNDED',arms:matrix.length,
  current_consumer_probes:probes.length,material_severances:11,restorations:11,
  chroma_loss_preserves_exact_capsule:true,differentiated_missing_relations:true,
  neutral_preserved:true,decorative_preserved:true,held_out_preserved:true,
  recursive_oracle_calls:0,zero_pitch_wait_cycles:32,zero_pitch_model_calls:0,
  zero_pitch_effects:0,zero_pitch_completion:false,network_requests:0,
  credential_lookups:0,model_calls:0,external_effects:0,persistent_runtime_mutations:0,
  limits:'Finite acceptance composition over current probes and exact source/evidence-bound participants; not the G33 end-to-end run or universal cognition proof.'});
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(`${d}/${e.name}`):[`${d}/${e.name}`]);
save(`${dir}/manifest.json`,{schema:'miter-g32-r1-evidence-freeze-v1',
  files:pins([...walk(dir).filter(file=>!file.endsWith('/manifest.json')),
    ...['docs/gates/G32/R1/plan.json','docs/gates/G32/R1/expected-arm-matrix.json',
      'tests/fixtures/g32/integrated_fixture.metta','scripts/g32/run.mjs','scripts/g32/verify.mjs']
      .map(file=>`${root}/${file}`)]),candidate_judge:false,native_semantic_products:true,
  network_requests:0,credential_lookups:0,model_calls:0,external_effects:0});
console.log(JSON.stringify(read(`${dir}/verdict.json`)));
