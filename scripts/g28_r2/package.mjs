// One-time inventory of retained evidence, before the separately written review.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
import {root,hash,save} from '../g22_v2/common.mjs';
const E=root+'/evidence/G28-R2';assert(!fs.existsSync(E+'/all-attempts.json'));
const tests=spawnSync(process.execPath,['--test','scripts/fidelity/check.test.mjs'],{cwd:root,encoding:'utf8'});
save(E+'/fidelity-tests.stdout',tests.stdout);save(E+'/fidelity-tests.stderr',tests.stderr);assert.equal(tests.status,0);
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):[p+'/'+e.name]);
const files=walk(E).sort().map(path=>({path:path.slice(root.length+1),sha256:hash(fs.readFileSync(path))}));save(E+'/all-attempts.json',{files,scope:'All experiment raw files before closure; later closure checker output is separately identified.'});
console.log(JSON.stringify({status:'INVENTORIED',files:files.length,fidelity_tests_passed:true}));
