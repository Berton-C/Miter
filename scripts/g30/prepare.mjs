// Freeze the exact G29 candidate and independent G30 mock before execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp, petta} from '../g22_v2/common.mjs';
import {buildSevered} from './sever.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '001';
assert.match(tag, /^\d{3}$/);
const dir = `${root}/evidence/G30/attempt-${tag}`;
assert(!fs.existsSync(dir), `attempt already exists: ${dir}`);
fs.mkdirSync(dir, {recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/prepare-failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});

const opening = checkOpen('docs/gates/G30/plan.json');
assert.equal(opening.plan_commit,
  '05abb0ee61413b245dbb473462f93c3902eaf457');
save(`${dir}/opening.json`, opening);
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'rev-parse', 'HEAD'],
  {encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');

const closure = read(`${root}/docs/gates/G29/R9/closure.json`);
assert.equal(closure.status, 'PASS-BOUNDED');
const candidateSource = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidateTests = `${root}/evidence/G29/attempt-901/candidate/candidate_tests/mattermost_contract_tests.pl`;
const candidateHash = hash(fs.readFileSync(candidateSource));
assert.equal(candidateHash,
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');
const copiedSource = `${dir}/candidate/extension/mattermost_bridge.pl`;
const copiedTests = `${dir}/candidate/candidate_tests/mattermost_contract_tests.pl`;
fs.mkdirSync(path.dirname(copiedSource), {recursive:true});
fs.mkdirSync(path.dirname(copiedTests), {recursive:true});
fs.copyFileSync(candidateSource, copiedSource);
fs.copyFileSync(candidateTests, copiedTests);
assert.equal(hash(fs.readFileSync(copiedSource)), candidateHash);

const variants = buildSevered(copiedSource, `${dir}/severed`,
  `${dir}/severance.json`);
const input = ['g30-trial-input', candidateHash, candidateHash,
  'quarantined', 'none', 'none'];
save(`${dir}/input.json`, {native:input});
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_mock_trial_v1.metta")\n`;
const rows = native(dir, 'native-preflight',
  `!(result standing (G30TrialStanding ${sexp(input[1])} ${sexp(input[2])} ${input[3]} ${input[4]} ${input[5]}))\n` +
  `!(result wrong-hash (G30TrialStanding ${sexp(input[1])} ${sexp('0'.repeat(64))} ${input[3]} ${input[4]} ${input[5]}))\n` +
  `!(result live-network (G30TrialStanding ${sexp(input[1])} ${sexp(input[2])} ${input[3]} granted ${input[5]}))`,
  boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2]]));
assert.deepEqual(map.standing, ['g30-trial-ready', candidateHash]);
assert.equal(map['wrong-hash'][0], 'g30-trial-held');
assert.equal(map['live-network'][0], 'g30-trial-held');
save(`${dir}/preflight-verdict.json`, {
  status:'PASS-BOUNDED', exact_candidate_admitted:true,
  wrong_hash_held:true, live_network_held:true,
  network:'none', credentials:'none', model_calls:0
});

const sources = [
  'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
  'docs/gates/G29/R9/closure.json', 'docs/gates/G29/R9/outcome.md',
  'docs/gates/G30/plan.json', 'docs/gates/G30/plan.md',
  'src/mattermost_mock_trial_v1.metta',
  'src/bootstrap_mattermost_mock_trial_v1.metta',
  'src/participation.metta', 'src/participation_support.metta',
  'effect_membranes/miter_mattermost_mock_v1.pl',
  'scripts/g30/sever.mjs', 'scripts/g30/prepare.mjs',
  'scripts/g30/run.mjs', 'scripts/g30/quality.mjs',
  'scripts/g30/verify.mjs', 'scripts/fidelity/check.mjs'
];
const artifacts = [candidateSource, candidateTests, copiedSource, copiedTests,
  `${dir}/input.json`, `${dir}/severance.json`,
  `${dir}/preflight-verdict.json`];
save(`${dir}/manifest.json`, {
  schema:'miter-g30-freeze-v1',
  plan:'docs/gates/G30/plan.json',
  plan_commit:opening.plan_commit,
  files:pins([...sources.map(file => `${root}/${file}`), ...artifacts]),
  candidate:{id:'mattermost-r9', sha256:candidateHash,
    standing:'quarantined', source:'G29-R9-exact-model-product'},
  mock:{kind:'deterministic-prolog', network:'none', credentials:'none',
    restart:'fresh-child-swipl-process'},
  severed:variants.map(row => ({name:row.name, sha256:row.sha256,
    severance:row.severance})),
  model_calls:0,
  live_mattermost:false
});
save(`${dir}/prepared.json`, {
  status:'PREPARED', candidate_sha256:candidateHash,
  exact_candidate_admitted:true, severed_variants:variants.length,
  network:'none', credentials:'none', model_calls:0
});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
