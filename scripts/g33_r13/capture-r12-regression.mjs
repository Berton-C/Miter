// Preserve the expected historical-source mismatch after v2 default promotion.
// This is evidence for the version-boundary correction, not a passing result.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root} from '../fidelity/check.mjs';
const dir=`${root}/evidence/G33/R13/attempt-005`;
const p=spawnSync(process.execPath,[`${root}/scripts/g33_r12/verify.mjs`,'016'],
  {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:4*1024*1024});
fs.writeFileSync(`${dir}/r12-current-tree-verifier.stdout`,p.stdout??'');
fs.writeFileSync(`${dir}/r12-current-tree-verifier.stderr`,p.stderr??'');
fs.writeFileSync(`${dir}/r12-current-tree-verifier-process.json`,JSON.stringify({
  status:p.status,signal:p.signal,error:p.error?.message??null,
  expected_historical_source_mismatch:true
})+'\n');
assert.equal(p.status,1);assert.match(p.stderr,/src\/bootstrap_modules\.metta/);
console.log(JSON.stringify({status:'EXPECTED-HISTORICAL-SOURCE-MISMATCH',process_status:p.status,
  path:'src/bootstrap_modules.metta'}));
