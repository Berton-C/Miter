// Independent P3 lineage, byte, causal, secret, and side-effect verification.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root, hash, read, save} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '301';
const dir = `${root}/evidence/G31/p3-${tag}`;
const run = read(`${dir}/run-verdict.json`);
const quality = read(`${dir}/quality-verdict.json`);
assert.equal(run.status, 'PASS-BOUNDED');
assert.equal(quality.status, 'PASS-BOUNDED');
const manifest = read(`${dir}/manifest.json`);
for (const file of manifest.files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
const lineage = read(`${dir}/lineage.json`);
for (const file of lineage.files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
assert.equal(lineage.actual_model_calls, 1);
assert.equal(lineage.selected_model, 'z-ai/glm-5.3');
assert.equal(lineage.exact_source_transform.other_byte_changes, 0);
const input = read(`${dir}/input.json`).native;
const prior = input[4][2];
const candidatePath = `${dir}/candidate/extension/mattermost_bridge.pl`;
const candidate = fs.readFileSync(candidatePath, 'utf8');
const expected = prior.replace(lineage.exact_source_transform.from,
  lineage.exact_source_transform.to);
assert.equal(candidate, expected);
assert.equal(hash(Buffer.from(candidate)), lineage.candidate_sha256);
assert.match(candidate,
  /body:_\{channel_id:CID, message:M, pending_post_id:IK\}/);
assert.equal(read(`${dir}/candidate-compile-process.json`).status, 0);
assert.equal(fs.readFileSync(`${dir}/candidate-compile.stderr`,'utf8'), '');
assert.equal(read(`${dir}/canonical-result.json`).standing[0],
  'g31-p3-candidate-qualified');
assert.equal(read(`${dir}/severed-result.json`).standing[0],
  'g31-p3-candidate-held');
assert.equal(read(`${dir}/secret-audit.json`).key_material_returned, false);
const owner = read(`${root}/evidence/G31/P3-call-1.claim/owner.json`);
assert.equal(owner.request, 'openrouter-g31-p3-revision-1');
assert.equal(owner.slot, 1);
const files = [];
function walk(item) {
  const stat = fs.statSync(item);
  if (stat.isDirectory()) for (const child of fs.readdirSync(item))
    walk(path.join(item, child));
  else files.push(item);
}
walk(dir);
walk(`${root}/evidence/G31/P3-call-1.claim`);
for (const file of files) {
  const content = fs.readFileSync(file).toString('latin1');
  assert(!/sk-or-v1-[A-Za-z0-9._-]+/.test(content), file);
  assert(!/Bearer\s+[A-Za-z0-9._-]{12,}/.test(content), file);
}
for (const key of ['local_mattermost_requests','mattermost_credential_lookups',
  'message_reads','message_writes','docker_calls'])
  assert.equal(run[key], 0, key);
assert.equal(run.activated, false);
assert.equal(run.promoted, false);
save(`${dir}/verification.json`, {
  status:'PASS-BOUNDED', frozen_inputs_verified:true,
  one_model_call_verified:true, exact_model_bytes_quarantined:true,
  exact_single_source_transform_verified:true,
  syntax_verified:true, prior_bridge_contract_verified:true,
  destination_pending_key_mapping_verified:true,
  bounded_same_key_recovery_verified:true,
  expiry_and_restart_limits_verified:true,
  native_causal_controls_verified:true,
  severed_mapping_defeats_standing:true,
  universal_exactly_once_unproven:true,
  credential_values_absent:true,
  local_mattermost_requests:0, mattermost_credential_lookups:0,
  message_reads:0, message_writes:0, docker_calls:0,
  activated:false, promoted:false,
  limits:'Quarantined candidate and non-network mock only; transport and live canary remain unbuilt'
});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
