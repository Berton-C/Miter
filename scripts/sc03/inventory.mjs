// Offline inventory of raw evidence; never a runtime dependency.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);
const out='evidence/SC03/raw-inventory.json';
const walk=p=>fs.statSync(p).isDirectory()?fs.readdirSync(p).sort().flatMap(n=>walk(p+'/'+n)):[p];
const files=walk('evidence/SC03').filter(p=>p!==out);
const current=files.map(path=>({path,sha256:hash(fs.readFileSync(path))}));
if(process.argv[2]==='create'){
  assert(!fs.existsSync(out));fs.writeFileSync(out,JSON.stringify({schema:'miter-raw-evidence-inventory-v1',files:current},null,2)+'\n');
}else{assert.deepEqual(JSON.parse(fs.readFileSync(out)).files,current);}
console.log(JSON.stringify({status:'RAW-INVENTORY-VALID',files:files.length,scope:'evidence/SC03/',semantic_fidelity_certified:false}));
