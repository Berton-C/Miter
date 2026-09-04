import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
process.chdir(root);const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G33/R4/attempt-${tag}`,read=n=>JSON.parse(fs.readFileSync(`${dir}/${n}`));
const opening=checkOpen('docs/gates/G33/R4/plan.json');
assert.equal(opening.plan_commit,'01bc72946cb758c835f8b4adabbc7928b69449ac');
const o=read('observations.json'),v=read('verdict.json'),f=read('freeze.json');
assert.equal(v.status,'PASS-BOUNDED');assert.equal(o.positive.valid_public_product,true);
assert.equal(o.positive.worker_started,true);assert.equal(o.positive.request_written,true);
assert.equal(o.positive.raw_written,true);assert.equal(o.positive.human_emission,false);
assert.equal(o.positive.external_effect_authority,false);
assert.equal(o.invalid.length,o.frozen_case_names.length);
for(const row of o.invalid){assert.equal(row.product,row.expected,row.name);
  assert.equal(row.worker_started,false);}
assert.deepEqual(o.second_call,['expression-storage-fault','intention-storage-failed']);
assert.equal(o.localhost_model_calls,1);for(const key of ['external_network_requests',
  'credential_lookups','chroma_mutations','mattermost_operations','external_effects'])
  assert.equal(o[key],0,key);
assert.equal(o.old_sc05_membrane_modified,false);assert.equal(o.pure_relational_source_modified,false);
for(const row of f.files)assert.equal(hash(fs.readFileSync(row.path)),row.sha256,row.path);
const result={status:'PASS-BOUNDED',gate:'G33',revision:'R4',cases:o.invalid.length+2,
  localhost_model_calls:1,external_effects:0,evidence:`evidence/G33/R4/attempt-${tag}/verdict.json`};
fs.writeFileSync(`${dir}/verification.json`,JSON.stringify(result)+'\n');console.log(JSON.stringify(result));
