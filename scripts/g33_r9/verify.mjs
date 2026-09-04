// Independent R9 R1 verifier; never imported by Miter cognition.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';

process.chdir(root);
const tag=process.argv[2]??'001',dir=`${root}/evidence/G33/R9/attempt-${tag}`;
const read=p=>JSON.parse(fs.readFileSync(p));
const ordered=x=>[...x].sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
const opportunityProjection=x=>x[0]==='development-opportunity'?{
  kind:x[0],scope:x[2],target:x[3],soul_ground:['soul-ground',ordered(x[4][1])],
  source_events:['source-events',ordered(x[5][1])],
  repeated_relations:ordered(x[6][1].map(row=>[row[0],row[1],
    ordered([row[2][1],row[3][1]]),ordered([row[2][3],row[3][3]])])),
  continuation:x.slice(7)
}:x;
const certificateProjection=x=>x[0]==='expression-certificate-v1'?{
  kind:x[0],scope:x[1],accepted_capability:x[6],
  selected_expression:[x[8][0],x[8][1][0],x[8][1][1],x[8][1][2],x[8][1][4]],
  fresh_disposition:x[9][1][3],authority:x[10]
}:x;
const fixture=read(`${root}/tests/fixtures/g33_r9/cases.json`),opening=read(`${dir}/opening.json`);
const freeze=read(`${dir}/freeze.json`),observations=read(`${dir}/observations.json`),verdict=read(`${dir}/verdict.json`);
assert.equal(opening.plan_commit,'bdb6823675748ba7e6d8bc2d181ce35b8b741748');
for(const file of freeze.files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
for(const name of fixture.bootstrap_variants){
  const process=read(`${dir}/${name}-process.json`),products=read(`${dir}/${name}-products.json`);
  assert.equal(process.status,0,name);assert.equal(fs.readFileSync(`${dir}/${name}.stderr`,'utf8'),'');
  assert.equal(products.canonical[0],fixture.expected.canonical);
  assert.equal(products.neutral[0],fixture.expected.neutral);
  assert.equal(products['same-family'][0],fixture.expected.same_family);
  assert.equal(products['self-authored'][0],fixture.expected.self_authored);
  assert.equal(products['missing-capability'][0],fixture.expected.missing_capability);
  assert.equal(products['exhausted-grant'][0],fixture.expected.exhausted_grant);
}
const reference=opportunityProjection(read(`${dir}/minimal-reference-products.json`).canonical);
for(const name of fixture.bootstrap_variants.filter(x=>x!=='minimal-reference'))
  assert.deepEqual(opportunityProjection(read(`${dir}/${name}-products.json`).canonical,reference),reference,name);
for(const name of fixture.bootstrap_variants){
  const products=read(`${dir}/${name}-products.json`);
  assert.deepEqual(opportunityProjection(products.neutral),opportunityProjection(products.canonical),`${name}-neutral`);
}
const voice=read(`${dir}/voice-consumer-products.json`);
const disposition=x=>x[0]==='voice-result'?x[2]:x;
assert.equal(disposition(voice.canonical)[0],fixture.expected.voice_canonical);
assert.equal(disposition(voice.canonical).at(-1),'no-emission-authority');
assert.deepEqual(certificateProjection(disposition(voice.neutral)),
  certificateProjection(disposition(voice.canonical)));
assert.equal(disposition(voice['missing-frame'])[0],fixture.expected.voice_missing_frame);
assert.deepEqual(disposition(voice.restored),disposition(voice.canonical));
assert.equal(fs.readFileSync(`${dir}/voice-consumer.stderr`,'utf8'),'');
assert.equal(observations.bootstrap_passed,true);assert.equal(observations.voice_passed,true);
assert.equal(observations.mechanical_collision_absent,true);assert.equal(verdict.status,'PASS-BOUNDED');
for(const key of ['model_calls','external_network_requests','credential_lookups','chroma_mutations',
  'mattermost_operations','human_emissions','external_effects'])assert.equal(verdict[key],0,key);
console.log(JSON.stringify({status:'PASS-BOUNDED',gate:'G33',revision:'R9-R1',claims:4}));
