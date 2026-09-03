// Requalify already-promoted state after a mechanical receipt-verification repair.
import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,hash,read,save,native} from '../g22_v2/common.mjs';
const old=root+'/evidence/G28-R3/attempt-002',n=process.argv[2]??'003',d=root+'/evidence/G28-R3/attempt-'+n;assert.match(n,/^[0-9]{3}$/);assert(!fs.existsSync(d));fs.mkdirSync(d,{recursive:true});
const changed=new Set(['effect_membranes/miter_workshop_promotion_v1.pl','scripts/g28_r3/replay.mjs']);
const paths=[...read(old+'/freeze.json').files.map(f=>f.path).filter(p=>!changed.has(p.slice(root.length+1))),old+'/decision.json',...changed].map(p=>p.startsWith('/')?p:root+'/'+p);
for(const f of ['input.json','decision.json'])fs.copyFileSync(old+'/'+f,d+'/'+f);
assert.equal(hash(fs.readFileSync(old+'/decision.json')),hash(fs.readFileSync(d+'/decision.json')));
const files=[...new Set([...paths,d+'/input.json'])].map(path=>({path,sha256:hash(fs.readFileSync(path))}));save(d+'/freeze.json',{files,model_calls:0,standing:'Mechanical receipt verification repair; prior authorized movement/source decision preserved'});save(d+'/manifest.json',{files});
const boot=`!(import! &self "${root}/src/bootstrap_executable_promotion_v1.metta")\n`;
const gitBefore=fs.readFileSync(root+'/runtime/g27/attempt-28204/journal/trajectory.jsonl');
const merge=native(d,'merge-replay',`!(result merge (EPRun "${d}"))`,boot);assert.equal(merge[0][2][0],'promotion-committed');assert(fs.readFileSync(root+'/runtime/g27/attempt-28204/journal/trajectory.jsonl').equals(gitBefore));
for(const[id,desired,expected]of [['restore','fb2022d36f7d84e52c26be3906f06c67a73d3028','182361b56dad9fd82b6cd557bea5539574cbac89'],['activate','fb2022d36f7d84e52c26be3906f06c67a73d3028','none']]){
 const result=native(d,id+'-replay',`!(result projection (EPProjection "${d}" ${id} ${desired} ${expected}))`,boot);assert.equal(result[0][2][0],'projection-selected');
}
const use=native(d,'use-replay',`!(result use (let $r (EPUse "${d}" use-restore ordinary) (wp_save "${d}" use-replay $r)))`,boot);assert.equal(use[0][2],'stored');assert.equal(read(d+'/use-replay.json').native[4],true);assert(fs.readFileSync(root+'/runtime/g27/attempt-28204/journal/trajectory.jsonl').equals(gitBefore));
save(d+'/verdict.json',{status:'PASS-BOUNDED',source_decision_preserved:true,merge_receipt_verified:true,projection_receipt_verified:true,uptake_receipt_verified:true,replays_add_no_events:true,new_model_calls:0,limits:'Mechanical cached-receipt integrity only; original semantic admission remains attempt-002 evidence'});console.log(JSON.stringify(read(d+'/verdict.json')));
