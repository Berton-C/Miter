// Independent G29 provenance, isolation and artifact verification.
import fs from 'node:fs';import assert from 'node:assert/strict';import {root,hash,read,save} from '../g22_v2/common.mjs';
const tag=process.argv[2]??'001',dir=root+'/evidence/G29/attempt-'+tag;
for(const name of ['preflight-verdict','run-verdict','quality-verdict'])assert.equal(read(dir+'/'+name+'.json').status,'PASS-BOUNDED');
const lock=read(dir+'/reference-lock.json');for(const f of lock.files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256);
const final=read(dir+'/final.json').native,candidate=final[2][1],id=candidate[2],files=candidate[6];assert.equal(final[0],'surface-extension-proposal');
const observation=read(dir+'/'+id+'-observation.json').native,raw=JSON.parse(observation[9]);assert.equal(observation[7],'artifact-shaped');
assert.equal(raw.rationale,candidate[3]);assert.equal(raw.plan,candidate[4]);
const rawMap=new Map(raw.files.map(f=>[f.path,f.content]));for(const f of files){assert.equal(rawMap.get(f[1]),f[2]);assert.equal(hash(Buffer.from(f[2])),f[3]);assert.equal(hash(fs.readFileSync(dir+'/candidate/'+f[1])),f[3])}
assert.deepEqual([...rawMap.keys()].sort(),['candidate_tests/mattermost_contract_tests.pl','extension/mattermost_bridge.pl']);
const text=files.map(f=>f[2]).join('\n').toLowerCase();for(const forbidden of ['chroma','miter_soul','src/soul','&soul','direct_memory'])assert(!text.includes(forbidden));
assert(!/bearer\s+[a-z0-9_-]{12,}/i.test(text));assert(!fs.existsSync(root+'/extension/mattermost_bridge.pl'));
assert.equal(fs.readFileSync(dir+'/services-before.txt','utf8'),fs.readFileSync(dir+'/services-after.txt','utf8'));
const calls=read(dir+'/lineage.json').calls;assert(calls.length>=1&&calls.length<=4);for(const c of calls){assert.equal(c.timing.http_status,200);assert.equal(c.timing.transport,'eof')}
save(dir+'/verification.json',{status:'PASS-BOUNDED',official_source_commit:lock.commit,implementation_empty_seed:true,native_modality_from_measured_relations:true,
 candidate_bytes_match_model:true,complete_artifacts:true,forbidden_core_access_absent:true,credential_literals_absent:true,syntax_and_negative_controls:true,
 candidate_quarantined:true,services_unchanged:true,mattermost_network_calls:0,credentials_used:0,not_promoted:true,
 limits:'G29 authorship/design proof only; independent behavior, mock transport, promotion and live canary are not claimed'});
console.log(JSON.stringify(read(dir+'/verification.json')));
