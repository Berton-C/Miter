// Verify the P0 hold, redaction and absence of live effects.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root, hash, read, save} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G31/p0-${tag}`;
assert.equal(read(`${dir}/preflight-verdict.json`).status,
  'PASS-BOUNDED-HOLD');
assert.equal(read(`${dir}/quality-verdict.json`).status, 'PASS-BOUNDED');
for (const file of read(`${dir}/manifest.json`).files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
assert.equal(fs.readFileSync(`${dir}/services-before.txt`, 'utf8'),
  fs.readFileSync(`${dir}/services-after.txt`, 'utf8'));
const inventory = read(`${dir}/service-inventory.json`);
assert.equal(inventory.discovery, 'docker-ps-read-only');
assert.equal(inventory.credential_values_read, false);
assert.equal(inventory.network_requests, 0);
assert.equal(inventory.docker_mutations, 0);
assert(inventory.mattermost_candidates.some(row =>
  row.name === 'clarityclaw_mattermost'));
const verdict = read(`${dir}/preflight-verdict.json`);
assert.equal(verdict.live_grant_complete, false);
assert(verdict.missing.includes('server-url'));
assert(verdict.missing.includes('channel-id'));
assert(verdict.missing.includes('credential-reference'));
assert(verdict.missing.includes('human-approval'));
const manifest = read(`${dir}/manifest.json`);
for (const key of ['credential_lookups', 'network_requests',
  'docker_mutations', 'message_reads', 'message_writes', 'model_calls'])
  assert.equal(manifest[key], 0, key);
const files = [];
function walk(item) {
  const stat = fs.statSync(item);
  if (stat.isDirectory()) for (const child of fs.readdirSync(item))
    walk(path.join(item, child));
  else files.push(item);
}
walk(dir);
for (const file of files) {
  const text = fs.readFileSync(file).toString('latin1');
  assert(!/Bearer\s+[A-Za-z0-9._-]{12,}/.test(text), file);
  assert(!/sk-or-v1-[A-Za-z0-9._-]+/.test(text), file);
}
save(`${dir}/verification.json`, {
  status:'PASS-BOUNDED-HOLD', exact_g30_candidate:true,
  read_only_container_discovery:true,
  possible_container:'clarityclaw_mattermost',
  exact_server_team_channel_bot_ids_unresolved:true,
  credential_reference_unresolved:true,
  canary_payload_and_duration_unresolved:true,
  rollback_panic_and_revocation_unresolved:true,
  explicit_mattermost_human_approval_unresolved:true,
  openrouter_authority_not_transferred:true,
  credential_values_absent:true, network_requests:0,
  docker_mutations:0, message_reads:0, message_writes:0,
  model_calls:0, activated:false, promoted:false,
  limits:'P0 authority preflight only; no live G31 behavior'
});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
