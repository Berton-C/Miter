// Builder-only packaging and runtime-boundary checks, not a semantic judge.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';import {root,hash,validatePlan} from '../fidelity/check.mjs';
process.chdir(root);const out='evidence/SC04/package-checks.json',inventory='evidence/SC04/raw-inventory.json';
const walk=p=>fs.statSync(p).isDirectory()?fs.readdirSync(p).sort().flatMap(n=>walk(p+'/'+n)):[p];
if(process.argv[2]==='verify'){
 const files=walk('evidence/SC04').filter(p=>p!==inventory).map(path=>({path,sha256:hash(fs.readFileSync(path))}));assert.deepEqual(files,JSON.parse(fs.readFileSync(inventory)).files);console.log(JSON.stringify({status:'RAW-INVENTORY-VALID',files:files.length}));
}else{
 assert(!fs.existsSync(out));assert(!fs.existsSync(inventory));const plan=validatePlan(JSON.parse(fs.readFileSync('docs/gates/SC04/plan.json')));validatePlan(JSON.parse(fs.readFileSync('docs/gates/SC05/plan.json')));
 const held=JSON.parse(fs.readFileSync('evidence/SC04/heldout-001/freeze.json'));for(const f of held.files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,'changed held-out interpretation '+f.path);
 const runtime=['src/grounded_language.metta','src/participation_support.metta','src/participation.metta','src/bootstrap_grounded_language.metta','effect_membranes/miter_language.pl'];for(const p of runtime)assert(!/\.mjs\b|\.cjs\b|py-call|janus|process_create|eval\(/i.test(fs.readFileSync(p,'utf8')),p+' unexpected runtime seam');
 const commands=[['scripts/sc01/validate-docs.cjs'],['--test','scripts/fidelity/check.test.mjs']].map(args=>{const r=spawnSync(process.execPath,args,{encoding:'utf8'});assert.equal(r.status,0);return {args,status:r.status,stdout:r.stdout,stderr:r.stderr}});
 fs.writeFileSync(out,JSON.stringify({status:'PASS-PACKAGE',controls:plan.controls,preserved_g22:plan.preserved.length,heldout_frozen_sources:held.files.length,runtime:runtime.map(path=>({path,sha256:hash(fs.readFileSync(path))})),commands,semantic_fidelity_certified:false},null,2)+'\n');
 const files=walk('evidence/SC04').filter(p=>p!==inventory).map(path=>({path,sha256:hash(fs.readFileSync(path))}));fs.writeFileSync(inventory,JSON.stringify({schema:'miter-raw-evidence-inventory-v1',files},null,2)+'\n');console.log(JSON.stringify({status:'PASS-PACKAGE',raw_files:files.length,preserved_g22:plan.preserved.length}));
}
