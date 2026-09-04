// Builder-side verifier for retained G33 R3 raw products.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R3/attempt-${tag}`;
const read=name=>JSON.parse(fs.readFileSync(`${root}/${rel}/${name}`));
const opening=checkOpen('docs/gates/G33/R3/plan.json');
assert.equal(opening.plan_commit,'7c91aab8ec2fceebbfdcc968904491f19d3592ec');
const o=read('observations.json'),v=read('verdict.json'),freeze=read('freeze.json');
assert.equal(o.continuity.passed,true);
assert.equal(o.continuity.native,'continuity-answer-stored');
assert.equal(o.continuity.typed.standing,'generated-source-verified-candidate');
assert.equal(o.continuity.answer.certificate,'exact-continuity');
assert.equal(o.continuity.trajectory_after_lines,o.continuity.trajectory_before_lines+2);
assert.equal(o.voice.intention[0],'voice-intention');
assert.equal(o.voice.faithful_audit[3],'faithful');
assert.equal(o.voice.neutral_audit[3],'faithful');
assert.notEqual(o.voice.distorted_audit[3],'faithful');
assert.equal(o.voice.distorted_disposition[0],'repair-request');
assert.equal(o.voice.distorted_origin,'builder-owned-synthetic-negative-not-model-output');
assert.deepEqual(o.voice.live_product,
  ['expression-storage-fault','intention-storage-or-integrity-failed']);
assert.equal(o.voice.public_entry_started,false);
assert.equal(o.voice.native_repair_continuation_implemented,false);
assert.equal(o.first_semantic_discontinuity,
  'relational-voice-membrane-confined-to-historical-sc05-evidence-root');
assert.equal(v.status,'FAIL');assert.equal(v.continuity_crossed,true);
assert.equal(v.stopped_at_first_semantic_discontinuity,true);
for(const key of ['external_network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','external_effects'])assert.equal(o[key],0,key);
assert.equal(o.localhost_model_calls,1);
assert.equal(o.later_g33_phases_executed,false);
assert.equal(o.legacy_voice_policy_loaded,false);
assert.equal(o.builder_supplied_repair,false);
for(const row of freeze.files)assert.equal(hash(fs.readFileSync(row.path)),row.sha256,row.path);
const summary={status:'PRESERVED-FAILURE-VALID',gate:'G33',revision:'R3',
  continuity_crossed:true,first_semantic_discontinuity:o.first_semantic_discontinuity,
  localhost_model_calls:o.localhost_model_calls,external_effects:0,
  evidence:`${rel}/verdict.json`};
fs.writeFileSync(`${root}/${rel}/verification.json`,JSON.stringify(summary)+'\n');
console.log(JSON.stringify(summary));
