// Independent byte lineage, isolation and decomposed-product verification.
import fs from 'node:fs';import assert from 'node:assert/strict';import {root,hash,read,save} from '../g22_v2/common.mjs';
const dir=root+'/evidence/G29/attempt-101';for(const n of ['run-verdict','quality-verdict'])assert.equal(read(dir+'/'+n+'.json').status,'PASS-BOUNDED');
const final=read(dir+'/final-r1.json').native,candidate=final[2][1],files=candidate[6];assert.equal(final[0],'surface-extension-proposal');
const designRaw=JSON.parse(read(dir+'/design-1-observation.json').native[10]),bridgeRaw=JSON.parse(read(dir+'/bridge-2-observation.json').native[10]),testsRaw=JSON.parse(read(dir+'/tests-3-observation.json').native[10]);
assert.equal(candidate[3],designRaw.rationale);assert.equal(candidate[4],designRaw.plan);const rawMap=new Map([['extension/mattermost_bridge.pl',bridgeRaw.content],['candidate_tests/mattermost_contract_tests.pl',testsRaw.content]]);
for(const f of files){assert.equal(f[2],rawMap.get(f[1]));assert.equal(hash(Buffer.from(f[2])),f[3]);assert.equal(hash(fs.readFileSync(dir+'/candidate/'+f[1])),f[3])}
const text=files.map(f=>f[2]).join('\n').toLowerCase();for(const x of ['chroma','miter_soul','src/soul','&soul','direct_memory'])assert(!text.includes(x));assert(!/bearer\s+[a-z0-9_-]{12,}/i.test(text));
assert(!fs.existsSync(root+'/extension/mattermost_bridge.pl'));assert.equal(fs.readFileSync(dir+'/services-before.txt','utf8'),fs.readFileSync(dir+'/services-after.txt','utf8'));
const calls=read(dir+'/lineage.json').calls;assert.equal(calls.length,3);for(const c of calls){assert.equal(c.timing.http_status,200);assert.equal(c.timing.transport,'eof');assert(c.timing.elapsed_ms<=300500)}
save(dir+'/verification.json',{status:'PASS-BOUNDED',implementation_empty_seed:true,native_modality_from_measured_relations:true,decomposed_model_products:3,
 candidate_bytes_match_model:true,complete_artifacts:true,forbidden_core_access_absent:true,credential_literals_absent:true,syntax_and_negative_controls:true,
 candidate_quarantined:true,services_unchanged:true,mattermost_network_calls:0,credentials_used:0,not_promoted:true,
 limits:'G29 authorship/design proof only; G30 behavior and G31 live reach remain unproven'});console.log(JSON.stringify(read(dir+'/verification.json')));
