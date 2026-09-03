// Replay unchanged SC02 assertions for the factored pure proof consumer.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';import {root,hash} from '../fidelity/check.mjs';
process.chdir(root);const dir=process.argv[2];assert.match(dir??'',/^evidence\/SC04\/regression-\d{3}$/);assert(!fs.existsSync(dir));
const source=fs.readFileSync('scripts/sc02/run.mjs','utf8');
const adapted=source.replace("from '../fidelity/check.mjs'","from '../../scripts/fidelity/check.mjs'").replace("from './verify-traces.mjs'","from '../../scripts/sc02/verify-traces.mjs'").replace("import('./cases.mjs')","import('../../scripts/sc02/cases.mjs')").replace('^evidence\\/SC02\\/attempt-','^evidence\\/SC04\\/regression-');
const entry='evidence/SC04/sc02-regression-runner.mjs';if(fs.existsSync(entry))assert.equal(fs.readFileSync(entry,'utf8'),adapted);else fs.writeFileSync(entry,adapted);
const r=spawnSync(process.execPath,[entry,dir],{encoding:'utf8',timeout:60000});assert(fs.existsSync(dir));
fs.writeFileSync(dir+'/relocation.json',JSON.stringify({source_sha256:hash(source),adapted_sha256:hash(adapted),changes:'Import/evidence locations only; all SC02 acceptance assertions unchanged.',status:r.status,stdout:r.stdout,stderr:r.stderr})+'\n');assert.equal(r.status,0);assert.equal(r.stderr,'');console.log(r.stdout.trim());
