// Replay SC01's unchanged assertions, relocating output only into this gate.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);
const dir=process.argv[2];assert.match(dir??'',/^evidence\/SC02\/regression-\d{3}$/);
assert(!fs.existsSync(dir));
const original=fs.readFileSync('scripts/sc01/run.mjs','utf8');
const adapted=original.replace("from '../fidelity/check.mjs'","from '../../scripts/fidelity/check.mjs'").replace('^evidence\\/SC01\\/attempt-','^evidence\\/SC02\\/regression-');
assert.notEqual(original,adapted);
const entry='evidence/SC02/sc01-regression-runner.mjs';
if(fs.existsSync(entry))assert.equal(fs.readFileSync(entry,'utf8'),adapted);else fs.writeFileSync(entry,adapted);
const r=spawnSync(process.execPath,[entry,dir],{encoding:'utf8',timeout:30000});
fs.writeFileSync(dir+'/regression.stdout',r.stdout??'');fs.writeFileSync(dir+'/regression.stderr',r.stderr??'');
fs.writeFileSync(dir+'/relocation.json',JSON.stringify({original_sha256:hash(original),adapted_sha256:hash(adapted),changes:'Only import location and evidence path regex; original acceptance assertions unchanged.',status:r.status,signal:r.signal})+'\n');
assert.equal(r.status,0);assert.equal(r.stderr,'');console.log(r.stdout.trim());
