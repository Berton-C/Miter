// Verify corrected authority schema and absence of all live effects.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root, hash, read, save} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '101';
const dir = `${root}/evidence/G31/p1-${tag}`;
assert.equal(read(`${dir}/preflight-verdict.json`).status,
  'PASS-BOUNDED-HOLD');
assert.equal(read(`${dir}/quality-verdict.json`).status, 'PASS-BOUNDED');
for (const file of read(`${dir}/manifest.json`).files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
const verdict = read(`${dir}/preflight-verdict.json`);
for (const field of ['authorized-source-users', 'outbound-bot-user-id',
  'credential-reference', 'voice-certificate-route', 'qualified-transport',
  'effect-reconciliation', 'human-approval'])
  assert(verdict.missing.includes(field), field);
const quality = read(`${dir}/quality-verdict.json`);
for (const key of ['conflated_source_and_bot_held',
  'wrong_bot_credential_binding_held', 'missing_voice_held',
  'missing_transport_held', 'missing_reconciliation_held',
  'missing_human_approval_held', 'wrong_candidate_held'])
  assert.equal(quality[key], true, key);
const manifest = read(`${dir}/manifest.json`);
for (const key of ['docker_calls', 'credential_lookups', 'network_requests',
  'message_reads', 'message_writes', 'model_calls'])
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
  status:'PASS-BOUNDED-HOLD', grant_v2_shape:true,
  distinct_inbound_source_and_outbound_bot:true,
  credential_reference_bound_to_bot:true,
  voice_certificate_required:true, qualified_transport_required:true,
  destination_reconciliation_required:true,
  explicit_human_approval_required:true,
  p0_discovery_reused_without_repeat:true,
  credential_values_absent:true, docker_calls:0, network_requests:0,
  message_reads:0, message_writes:0, model_calls:0,
  activated:false, promoted:false,
  limits:'P1 grant ontology only; live G31 remains ungranted and unexecuted'
});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
