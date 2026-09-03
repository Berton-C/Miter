// Freeze and execute G31 P0 no-contact authority preflight.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp, petta} from '../g22_v2/common.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '001';
assert.match(tag, /^\d{3}$/);
const dir = `${root}/evidence/G31/p0-${tag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(dir, {recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});
const opening = checkOpen('docs/gates/G31/P0/plan.json');
assert.equal(opening.plan_commit,
  'e574e5e76abdf1177408cfda77930397ca6ba349');
save(`${dir}/opening.json`, opening);
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'rev-parse', 'HEAD'],
  {encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');

const candidate = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidateHash = hash(fs.readFileSync(candidate));
assert.equal(candidateHash,
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');
const g30 = read(`${root}/docs/gates/G30/R2/closure.json`);
assert.equal(g30.status, 'PASS-BOUNDED');
const grant = ['live-grant', candidateHash,
  'one-bounded-Miter-Mattermost-canary',
  'unresolved', 'unresolved', 'unresolved', 'unresolved', 'unresolved',
  'unresolved', 'unresolved', 'unresolved', 'unresolved', 'unresolved',
  'unresolved', 'unresolved', 'unresolved', 'unresolved', 'unresolved',
  'unresolved', 'unresolved', 'unresolved'];
assert.equal(grant.length, 21);
save(`${dir}/grant-input.json`, {
  schema:'miter-g31-live-grant-input-v1', native:grant,
  credential_value:null,
  standing:'incomplete-ungranted-template-not-authority'
});
const docker = '/Applications/Docker.app/Contents/Resources/bin/docker';
const before = execFileSync(docker, ['ps', '--format',
  '{{.ID}} {{.Names}} {{.Image}} {{.Ports}}'], {encoding:'utf8'});
save(`${dir}/services-before.txt`, before);

const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const output = `${dir}/service-inventory.json`;
const rows = native(dir, 'native-preflight',
  `!(result outcome (G31Run ${sexp(output)} ${sexp(grant)} ${sexp(candidateHash)} ${sexp(candidateHash)} G30-PASS-BOUNDED))\n` +
  `!(result wrong-candidate (G31DiscoveryStanding ${sexp('0'.repeat(64))} ${sexp(candidateHash)} G30-PASS-BOUNDED))`,
  boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2]]));
assert.equal(map.outcome[0], 'g31-preflight-result');
assert.equal(map.outcome[2][0], 'g31-live-preflight-held');
assert.equal(map['wrong-candidate'][0], 'g31-read-only-discovery-held');
const inventory = read(output);
const after = execFileSync(docker, ['ps', '--format',
  '{{.ID}} {{.Names}} {{.Image}} {{.Ports}}'], {encoding:'utf8'});
save(`${dir}/services-after.txt`, after);
assert.equal(after, before);
save(`${dir}/native-result.json`, {native:map.outcome});

const sources = [
  'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
  'docs/gates/G29/R9/closure.json', 'docs/gates/G30/R2/closure.json',
  'docs/gates/G31/P0/plan.json', 'docs/gates/G31/P0/plan.md',
  'src/mattermost_live_grant_v1.metta',
  'src/bootstrap_mattermost_live_grant_v1.metta',
  'src/participation.metta', 'src/participation_support.metta',
  'effect_membranes/miter_mattermost_live_preflight_v1.pl',
  'scripts/g31/p0_prepare.mjs', 'scripts/g31/p0_quality.mjs',
  'scripts/g31/p0_verify.mjs', 'scripts/fidelity/check.mjs'
];
save(`${dir}/manifest.json`, {
  schema:'miter-g31-p0-freeze-v1',
  plan:'docs/gates/G31/P0/plan.json', plan_commit:opening.plan_commit,
  files:pins([...sources.map(file => `${root}/${file}`), candidate,
    `${dir}/grant-input.json`, `${dir}/services-before.txt`,
    `${dir}/service-inventory.json`, `${dir}/services-after.txt`,
    `${dir}/native-result.json`]),
  candidate:{id:'mattermost-r9', sha256:candidateHash,
    g30_status:g30.status},
  authority:{mattermost:'not-granted', openrouter:'not-transferable'},
  credential_lookups:0, network_requests:0, docker_mutations:0,
  message_reads:0, message_writes:0, model_calls:0
});
save(`${dir}/preflight-verdict.json`, {
  status:'PASS-BOUNDED-HOLD', exact_candidate_bound:true,
  g30_bound:true, possible_mattermost_containers:
    inventory.mattermost_candidates.map(row => row.name),
  live_grant_complete:false,
  missing:map.outcome[2][1],
  credential_lookups:0, network_requests:0, docker_mutations:0,
  activated:false, promoted:false,
  next:'Berton exact Mattermost discovery/canary grant required'
});
console.log(JSON.stringify(read(`${dir}/preflight-verdict.json`)));
