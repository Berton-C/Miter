// Independent G33 R1 verifier for the first clean-start semantic discontinuity.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins} from '../g22_v2/common.mjs';

process.chdir(root);
const rel=process.argv[2]??'evidence/G33/R1/attempt-001';
assert.match(rel,/^evidence\/G33\/R1\/attempt-\d{3}$/);
const dir=`${root}/${rel}`;
assert.equal(checkOpen('docs/gates/G33/R1/plan.json').plan_commit,
  '5ecb9b1e94bed0b5672cf0b80360035ee5c03e73');
const o=read(`${dir}/observations.json`);
const encounter=read(`${root}/tests/fixtures/g33_r1/heldout-continuity.json`);
assert.equal(o.clean_runtime_root,true);
assert.equal(o.empty_chat_context,true);
assert.equal(o.heldout_text,encounter.text);
assert.notEqual(encounter.text,'Where was I with the book?');
assert.equal(o.startup_written,true);
assert.equal(o.trajectory_after_lines,o.trajectory_before_lines+2);
assert.equal(o.external_network_requests,0);
assert.equal(o.credential_lookups,0);
assert.equal(o.model_calls,0);
assert.equal(o.external_effects,0);

const passed=o.product==='continuity-answer-stored' && o.answer_written===true;
const verdict={status:passed?'PASS-PHASE':'FAIL',gate:'G33',revision:'R1',
  first_phase:'held-out-ninety-day-continuity',
  clean_runtime_root:true,empty_model_context:true,current_consumer:'ContinuityRNA',
  native_product:o.product,authoritative_answer_written:o.answer_written,
  expected_intent:encounter.expected_intent,
  classification:passed?'current-consumer-supported-heldout-intent':'exact-prompt-dispatch-blocked-heldout-intent',
  stopped_at_first_semantic_discontinuity:!passed,later_phases_executed:false,
  old_gate_verdicts_used_as_native_products:false,builder_selected_semantic_answer:false,
  localhost_health_requests:o.localhost_health_requests,external_network_requests:0,
  credential_lookups:0,model_calls:0,external_effects:0,
  limits:'This verdict tests the first required G33 semantic phase only. Failure prevents all later G33 claims; it is not evidence that those later mechanisms failed.'};
save(`${dir}/verdict.json`,verdict);
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(`${d}/${e.name}`):[`${d}/${e.name}`]);
const files=walk(dir).filter(file=>!file.endsWith('/manifest.json'));
save(`${dir}/manifest.json`,{schema:'miter-g33-r1-attempt-manifest-v1',files:pins(files),
  result:verdict.status,first_semantic_discontinuity:verdict.classification,
  public_private_scan_required:true});
console.log(JSON.stringify(verdict));
if(!passed)process.exitCode=2;
