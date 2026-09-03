// Execute the quarantined model-authored candidate without network or credentials.
// SWI can exit zero after load errors, so stderr ERROR records are evidence-bearing.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,save,native} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'104';
assert.match(tag,/^10[3-9]$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
const bridge=`${dir}/candidate/extension/mattermost_bridge.pl`;
const tests=`${dir}/candidate/candidate_tests/mattermost_contract_tests.pl`;
for(const path of [bridge,tests])assert(fs.existsSync(path),path);

const p=spawnSync('/opt/homebrew/bin/swipl',[
  '-q','-f','none','-s',bridge,'-s',tests,'-g','run_tests','-t','halt'
],{
  cwd:`${dir}/candidate/candidate_tests`,
  encoding:'utf8',
  timeout:30000,
  maxBuffer:8*1024*1024,
  env:{HOME:'/nonexistent',PATH:'/usr/bin:/bin'}
});
const stdout=p.stdout??'';
const stderr=p.stderr??'';
fs.writeFileSync(`${dir}/candidate-trial.stdout`,stdout);
fs.writeFileSync(`${dir}/candidate-trial.stderr`,stderr);
const errors=(stderr.match(/^ERROR:.*$/gm)??[]);
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const verifierRows=native(dir,'corrected-syntax-verifier',
  `!(let $syntax (sx_syntax "${dir}" (surface-extension-candidate fixture mattermost-r1 rationale plan manifest files model-products)) (result verifier $syntax))`,boot);
const verifier=verifierRows.find(x=>x[1]==='verifier')?.[2];
assert.deepEqual(verifier,['surface-candidate-syntax','1','1','false']);
const verdict={
  status:(p.status===0&&!p.error&&errors.length===0)?'PASS-BOUNDED':'FAIL-EVIDENCE',
  process_status:p.status,
  signal:p.signal,
  timed_out:p.error?.code==='ETIMEDOUT',
  stderr_error_count:errors.length,
  bridge_syntax_error:stderr.includes('mattermost_bridge.pl:40:64: Syntax error'),
  bridge_export_missing:stderr.includes('surface_effect/5 is not defined'),
  tests_invalid_plunit_form:stderr.includes('Unknown procedure: plunit_mattermost_bridge:test/1'),
  tests_clause_body_errors:stderr.includes('Full stop in clause-body?'),
  corrected_native_syntax_verifier:verifier,
  network_calls:0,
  credentials_used:0,
  candidate_promoted:false,
  consequence:'Both bridge and tests require evidence-specific repair; one single-part R1 repair is insufficient.'
};
save(`${dir}/candidate-trial.json`,verdict);
console.log(JSON.stringify(verdict));
