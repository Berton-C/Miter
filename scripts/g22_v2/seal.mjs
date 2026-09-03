// Independent raw-artifact verifier and inventory builder, not Soul cognition.
import fs from 'node:fs';import assert from 'node:assert/strict';import {root,read,save,hash,parse} from './common.mjs';
import {reports,compare} from './verify.mjs';
const rel=process.argv[2],dir=root+'/'+rel;assert.match(rel,/^evidence\/G22\/attempt-\d{3}$/);
assert.equal(read(dir+'/verdict.json').status,'PASS-BOUNDED');assert.equal(read(dir+'/boundaries/verdict.json').status,'PASS-BOUNDED');
for(const f of read(dir+'/freeze.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
const rows=read(dir+'/cases.json'),p=reports(rows,read(dir+'/canonical/parent.json'),read(dir+'/canonical/parent-report.json').native),c=reports(rows,read(dir+'/canonical/candidate.json'),read(dir+'/canonical/candidate-report.json').native);
const b=reports(rows,read(dir+'/hard-floor/candidate.json'),read(dir+'/hard-floor/candidate-report.json').native);assert(compare(p,c).some(r=>r.gain));assert(!compare(p,c).some(r=>r.loss));assert(compare(p,b).some(r=>r.loss));assert(b.filter(r=>r.available).length>p.filter(r=>r.available).length);
function files(d){return fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=d+'/'+e.name;assert(!e.isSymbolicLink());return e.isDirectory()?files(p):[p]})}
const checked=[];for(const path of files(dir).filter(p=>p.endsWith('/store/trajectory.jsonl')&&!p.includes('/ledger-tamper/'))){
 const lines=fs.readFileSync(path,'utf8').trim().split('\n');assert.equal(lines.length,1,path);const e=JSON.parse(lines[0]);assert.equal(e.previous_event_hash,'GENESIS');assert.equal(e.local_sequence,1);assert.deepEqual(e.parent_event_ids,[]);
 const without=lines[0].replace(/"event_hash":"[a-f0-9]{64}",/,'');assert.notEqual(without,lines[0]);assert.equal(hash(without),e.event_hash,path);
 assert.equal(e.payload_ref,'sha256:'+e.payload_hash);const payload=fs.readFileSync(path.replace('/trajectory.jsonl','/objects/sha256/'+e.payload_hash+'.json'),'utf8').replace(/\n$/,'');assert.equal(hash(payload),e.payload_hash,path);
 const process=read(path.replace('/store/trajectory.jsonl',path.includes('/hard-floor/')?'/record-rejection-process.json':path.includes('/boundaries/')?path.includes('/same-runtime-repeat/')?'/repeat-process.json':'/commit-process.json':'/admit-process.json'));
 assert(Math.abs(Date.parse(e.recorded_at)-Date.parse(process.started_at))<120000,'timestamp is actual UTC, not local clock relabelled Z');checked.push(path.slice(root.length+1));
}
const nativeSource=fs.readFileSync(root+'/src/voice_trials_v2.metta','utf8');const ast=parse('('+nativeSource.replace(/^;.*$/gm,'')+')');function shape(x){if(!Array.isArray(x))return;if(['if','let'].includes(x[0]))assert.equal(x.length,4);if(x[0]==='let*')assert.equal(x.length,3);x.forEach(shape)}shape(ast);
save(dir+'/independent-final.json',{status:'PASS-BOUNDED',cases:rows.length,independently_verified_ledgers:checked,hard_floor:compare(p,b).filter(x=>x.loss).map(x=>x.id),scope:'Independent expression enumeration, event/payload byte hashes, UTC, native syntax shape and current code identities; not semantic fidelity certification'});
const all=files(root+'/evidence/G22').filter(p=>!p.endsWith('/raw-inventory.json'));save(root+'/evidence/G22/raw-inventory.json',{files:all.map(p=>({path:p.slice(root.length+1),sha256:hash(fs.readFileSync(p)),bytes:fs.statSync(p).size})),standing:'Includes superseded attempts and injected-fault raw artifacts, not only passing outputs'});console.log(JSON.stringify({status:'PASS-BOUNDED',files:all.length,ledgers:checked.length}));
