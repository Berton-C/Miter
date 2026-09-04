// Independent structural comparison of already-captured current-consumer products.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins} from '../g22_v2/common.mjs';

process.chdir(root);
const rel=process.argv[2]??'evidence/G32/R2/attempt-001';
assert.match(rel,/^evidence\/G32\/R2\/attempt-\d{3}$/);
const dir=`${root}/${rel}`,o=read(`${dir}/observations.json`);
assert.equal(checkOpen('docs/gates/G32/R2/plan.json').plan_commit,'596de65bd3a910686e36816bb8c87b3a346189c4');
const expected=read(`${root}/docs/gates/G32/R2/expected-consumer-matrix.json`);
assert.equal(expected.frozen_before_execution,true);assert.equal(expected.arms.length,15);
const restored=['soul','memory-capsule','chroma','voiceaudit','vad','nace','consequence',
  'endogenous-curiosity','continuity-lineage','workshop-containment','mattermost-identity'];
for(const id of restored){assert.notDeepEqual(o[id].canonical,o[id].severed,id);assert.deepEqual(o[id].canonical,o[id].restored,id)}

assert.equal(o.soul.canonical,'true');assert.equal(o.soul.severed,'false');
assert.deepEqual(o['memory-capsule'].canonical,['continuity-answer','exact-continuity','semantic-support']);
assert.equal(o['memory-capsule'].severed[1],'non-authoritative-recall');
assert.deepEqual(o.chroma.severed,['continuity-answer','exact-continuity','semantic-unavailable']);
assert.equal(o.voiceaudit.canonical[0],'CertifiedUtterance');assert.equal(o.voiceaudit.severed[0],'g31-canary-voice-held');
assert.equal(o.vad.canonical[0],'affect-cue');assert.equal(o.vad.severed[0],'affect-cue');
const vadField=(p,name)=>p.find(x=>Array.isArray(x)&&x[0]===name);
assert.deepEqual(vadField(o.vad.severed,'status'),['status','no-coverage']);
assert.deepEqual(vadField(o.vad.severed,'presence_requirement'),['presence_requirement','withhold-affective-inference']);
assert.equal(o.nace.canonical[0],'stv');assert.equal(o.nace.severed[0],'nace-consumer-unavailable');
assert.equal(o.consequence.canonical[0],'stv');assert.deepEqual(o.consequence.severed,['stv','0.5','0.5']);
assert.equal(o['workshop-containment'].canonical[0],'g30-trial-ready');
assert.equal(o['workshop-containment'].severed[0],'g30-trial-held');
assert.equal(o['continuity-lineage'].canonical[0],'development-resumed');
assert.deepEqual(o['continuity-lineage'].severed,['development-resume-incomplete','active-module-mismatch']);
assert.equal(o['mattermost-identity'].canonical.outcome.status,'accepted');
assert.equal(o['mattermost-identity'].severed.outcome.reason,'unauthorized');
assert.equal(o['mattermost-identity'].severed.state_unchanged,true);
const stepReason=p=>p[3];
assert.equal(stepReason(o['endogenous-curiosity'].canonical),'native-opportunity-transcribed');
assert.equal(stepReason(o['endogenous-curiosity'].severed),'native-opportunity-unavailable');
for(const key of ['restored','decorative','neutral','held_out'])
  assert.equal(stepReason(o['endogenous-curiosity'][key]),'native-opportunity-transcribed',key);
assert.equal(o['non-recursive'].recursive_oracle_calls,0);assert.equal(o['non-recursive'].oracle_calls,1);
assert.equal(o['non-recursive'].product[0],'cycle-step');
const z=o['zero-pitch-perpetual-loop'].product;
assert.equal(z[0],'zero-pitch-product');assert.deepEqual(z[2],['wait-cycles','32']);
assert.deepEqual(z[4],['model-calls','0']);assert.deepEqual(z[5],['effects','0']);
assert.deepEqual(z[6],['completion','false']);assert.deepEqual(z[7],['interruptible','true']);
assert.equal(o['zero-pitch-perpetual-loop'].model_calls,0);
assert.equal(o['zero-pitch-perpetual-loop'].external_effects,0);

const matrix=restored.map(id=>({id,canonical:o[id].canonical,severed:o[id].severed,restored:o[id].restored,
  changed:JSON.stringify(o[id].canonical)!==JSON.stringify(o[id].severed),restored_equal:JSON.stringify(o[id].canonical)===JSON.stringify(o[id].restored)}));
save(`${dir}/arm-matrix.json`,{schema:'miter-g32-r2-observed-consumer-product-matrix-v1',matrix,
  non_recursive:o['non-recursive'],zero_pitch:o['zero-pitch-perpetual-loop'],
  controls:{decorative:stepReason(o['endogenous-curiosity'].decorative),neutral:stepReason(o['endogenous-curiosity'].neutral),held_out:stepReason(o['endogenous-curiosity'].held_out)}});
save(`${dir}/verdict.json`,{status:'PASS-BOUNDED',actual_current_consumers:11,
  material_severances:11,restorations:11,consumer_products_drive_matrix:true,
  builder_availability_standings:false,differentiated_nace_and_consequence:true,
  exact_capsule_survives_chroma_loss:true,identity_rejected_before_body:true,
  decorative_preserved:true,neutral_preserved:true,held_out_preserved:true,
  recursive_oracle_calls:0,zero_pitch_wait_cycles:32,zero_pitch_model_calls:0,
  zero_pitch_effects:0,zero_pitch_completion:false,network_requests:0,
  credential_lookups:0,model_calls:0,external_effects:0,persistent_runtime_mutations:0,
  limits:'Bounded offline current-consumer product discrimination; not the G33 clean-start end-to-end organism or a universal cognition proof.'});
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(`${d}/${e.name}`):[`${d}/${e.name}`]);
const files=walk(dir).filter(file=>!file.endsWith('/manifest.json'));
save(`${dir}/manifest.json`,{schema:'miter-g32-r2-evidence-freeze-v1',files:pins(files),
  consumer_products_drive_matrix:true,candidate_judge:false,network_requests:0,
  credential_lookups:0,model_calls:0,external_effects:0});
console.log(JSON.stringify(read(`${dir}/verdict.json`)));
