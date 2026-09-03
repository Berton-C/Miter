// Verify an unsuccessful package without relabelling it a passing gate.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,validatePlan} from '../fidelity/check.mjs';import {read,save} from '../g22_v2/common.mjs';
process.chdir(root);const C=read(root+'/docs/gates/G28/R1/closure.json'),P=validatePlan(read(root+'/'+C.plan));assert.equal(C.status,'BLOCKED');
assert.equal(hash(execFileSync('git',['show',C.plan_commit+':'+C.plan])),hash(fs.readFileSync(root+'/'+C.plan)));
for(const f of [...C.evidence,...read(root+'/evidence/G28-R1/all-attempts.json').files])assert.equal(hash(fs.readFileSync(root+'/'+f.path)),f.sha256,f.path);
for(const f of read(root+'/evidence/G28-R1/attempt-003/freeze.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
const changed=execFileSync('git',['diff',C.plan_commit,'--name-only'],{encoding:'utf8'}).trim().split('\n');
changed.push(...execFileSync('git',['ls-files','--others','--exclude-standard'],{encoding:'utf8'}).trim().split('\n'));
for(const p of changed.filter(Boolean))assert(P.preserved.some(f=>f.path===p)||P.allowed_paths.some(a=>a.endsWith('/')?p.startsWith(a):a===p),p);
const close=spawnSync(process.execPath,['scripts/fidelity/check.mjs','close','docs/gates/G28/R1/closure.json'],{encoding:'utf8'});assert.equal(close.status,1);assert(close.stderr.includes('cannot progress from unsuccessful closure'));
const tests=spawnSync(process.execPath,['--test','scripts/fidelity/check.test.mjs'],{encoding:'utf8'});assert.equal(tests.status,0,tests.stderr);
save(root+'/evidence/G28-R1/fidelity-close.stdout',close.stdout);save(root+'/evidence/G28-R1/fidelity-close.stderr',close.stderr);save(root+'/evidence/G28-R1/fidelity-tests.stdout',tests.stdout);save(root+'/evidence/G28-R1/fidelity-tests.stderr',tests.stderr);
save(root+'/evidence/G28-R1/package-verification.json',{status:'BLOCKED-PACKAGE-VERIFIED',hashes_valid:true,scope_valid:true,controls_valid:true,preserved_valid:true,latest_runtime_pins_valid:true,expected_close_exit:close.status,fidelity_tests_exit:tests.status,gate_passed:false});console.log('BLOCKED package verified; progression correctly refused.');
