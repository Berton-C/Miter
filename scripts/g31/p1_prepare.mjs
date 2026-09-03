// Freeze corrected live-grant ontology and evaluate an incomplete grant.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '101';
assert.match(tag, /^\d{3}$/);
const dir = `${root}/evidence/G31/p1-${tag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(dir, {recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});
const opening = checkOpen('docs/gates/G31/P1/plan.json');
assert.equal(opening.plan_commit,
  '2a44e9d98362f4573bfc85d84d5dd98c817295c6');
save(`${dir}/opening.json`, opening);
const candidate = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidateHash = hash(fs.readFileSync(candidate));
assert.equal(candidateHash,
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');
const p0InventoryPath = `${root}/evidence/G31/p0-001/service-inventory.json`;
const p0InventoryHash = hash(fs.readFileSync(p0InventoryPath));
const inventory = ['g31-service-inventory', 'docker-ps-read-only', 1,
  ['clarityclaw_mattermost'], p0InventoryHash, false, 0, 0];
const grant = ['live-grant-v2', candidateHash,
  'one-bounded-Miter-Mattermost-canary', ...Array(22).fill('unresolved')];
assert.equal(grant.length, 25);
save(`${dir}/grant-input.json`, {
  schema:'miter-g31-live-grant-v2-input', native:grant,
  p0_inventory_sha256:p0InventoryHash, credential_value:null,
  standing:'incomplete-ungranted-template-not-authority'
});
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const rows = native(dir, 'native-preflight',
  `!(result outcome (G31AssessGrant ${sexp(grant)} ${sexp(candidateHash)} ${sexp(inventory)}))`,
  boot);
assert.equal(rows.length, 1);
const outcome = rows[0][2];
assert.equal(outcome[0], 'g31-live-preflight-held');
save(`${dir}/native-result.json`, {native:outcome});
const missing = outcome[1];
for (const field of ['authorized-source-users', 'outbound-bot-user-id',
  'credential-reference', 'voice-certificate-route', 'qualified-transport',
  'effect-reconciliation', 'human-approval']) assert(missing.includes(field));

const sources = [
  'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
  'docs/gates/G30/R2/closure.json', 'docs/gates/G31/P0/plan.json',
  'docs/gates/G31/P0/outcome.md', 'docs/gates/G31/P1/plan.json',
  'docs/gates/G31/P1/plan.md', 'src/mattermost_live_grant_v1.metta',
  'src/bootstrap_mattermost_live_grant_v1.metta',
  'src/participation.metta', 'src/participation_support.metta',
  'scripts/g31/p1_prepare.mjs', 'scripts/g31/p1_quality.mjs',
  'scripts/g31/p1_verify.mjs', 'scripts/fidelity/check.mjs'
];
save(`${dir}/manifest.json`, {
  schema:'miter-g31-p1-freeze-v1', plan:'docs/gates/G31/P1/plan.json',
  plan_commit:opening.plan_commit,
  files:pins([...sources.map(file => `${root}/${file}`), candidate,
    p0InventoryPath, `${dir}/grant-input.json`, `${dir}/native-result.json`]),
  candidate_sha256:candidateHash, p0_inventory_sha256:p0InventoryHash,
  reused_discovery:true, docker_calls:0, credential_lookups:0,
  network_requests:0, message_reads:0, message_writes:0, model_calls:0
});
save(`${dir}/preflight-verdict.json`, {
  status:'PASS-BOUNDED-HOLD', corrected_grant_ontology:true,
  distinct_inbound_source_and_outbound_bot:true,
  voice_transport_reconciliation_required:true,
  live_grant_complete:false, missing,
  reused_p0_discovery:true, docker_calls:0, credential_lookups:0,
  network_requests:0, message_reads:0, message_writes:0,
  activated:false, promoted:false
});
console.log(JSON.stringify(read(`${dir}/preflight-verdict.json`)));
