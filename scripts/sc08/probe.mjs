import fs from 'node:fs';import assert from 'node:assert/strict';import {root,capture,source,native,bootstrap,sexp,save} from './common.mjs';
process.chdir(root);const rel=process.argv[2];assert.match(rel??'',/^evidence\/SC08\/probe-\d{3}$/);capture(rel);const dir=root+'/'+rel;
try{const input=source(dir),scope=input.frame[1],s=['development-life','cycle-expression-001',scope,'ready','unseen',input.grant,0,['purpose','unformed'],'none','unresolved'];
const observation=(receipts,worker='none',fp='contact-a',grant=input.grant)=>['cycle-observation',fp,input.frame,receipts,input.surfaces,grant,worker,'none'];
let e=bootstrap;for(const [id,records]of [['one',input.receipts.slice(0,1)],['two',input.receipts],['replay',[input.receipts[0],JSON.parse(fs.readFileSync(dir+'/receipts.json')).records[2]]],['malformed',[['bad-receipt'],input.receipts[1]]]])e+=`!(case-result ${id} (CStep ${sexp(s)} ${sexp(observation(records))}))\n`;
e+=`!(case-result invalid-state (CStep (invalid) ${sexp(observation(input.receipts))}))\n`;
const r=native(dir,e);save(dir+'/results.json',r);assert.equal(r.two[1][3],'pending');assert.equal(r.two[2][0][0],'dispatch');assert.equal(r.one[1][3],'waiting');assert.equal(r.replay[1][3],'waiting');assert.equal(r.malformed[1][3],'waiting');assert.equal(r['invalid-state'][3][0],'cycle-fault');console.log(JSON.stringify({status:'PASS',cases:Object.keys(r).length}));
}catch(e){save(dir+'/failure.json',{message:e.message,stack:e.stack});throw e}
