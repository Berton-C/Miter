// Verify immutable sources, native controls, and absence of live effects/secrets.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {root, hash, read, save} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G31/p2-${tag}`;
const preflight = read(`${dir}/preflight-verdict.json`);
const quality = read(`${dir}/quality-verdict.json`);
assert.equal(preflight.status, 'PASS-BOUNDED-HOLD');
assert.equal(quality.status, 'PASS-BOUNDED');
const manifest = read(`${dir}/manifest.json`);
assert.equal(manifest.mattermost.tag, 'v11.7.7');
assert.equal(manifest.mattermost.commit,
  '2045acd92c40353abfc5ffff8ae1e0dd9d2e6737');
for (const file of manifest.files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
const sourceIndex = read(`${dir}/source-index.json`);
for (const row of sourceIndex.observations) {
  const reference = `${dir}/${row.evidence_path}`;
  assert.equal(hash(fs.readFileSync(reference)), row.excerpt_sha256, row.path);
  const lineCount = fs.readFileSync(reference, 'utf8').trimEnd().split('\n').length;
  assert(row.start_line > 0 && row.end_line >= row.start_line);
  assert.equal(lineCount, row.end_line - row.start_line + 1);
}
const candidate = read(`${dir}/candidate-observation.json`);
assert.equal(candidate.pending_post_id_in_request_body, false);
assert.deepEqual(candidate.request_field_maps, []);
for (const key of ['local_mattermost_requests','docker_calls',
  'credential_lookups','message_reads','message_writes','model_calls',
  'candidate_edits']) assert.equal(manifest[key], 0, key);
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
  status:'PASS-BOUNDED-HOLD', source_excerpt_hashes_verified:true,
  source_spans_verified:true, full_source_hashes_recorded:true,
  exact_version_verified:true,
  native_severed_controls_passed:true,
  candidate_unchanged_and_inapplicable:true,
  bounded_destination_mechanism_supported:true,
  exactly_once_unproven:true, credential_values_absent:true,
  local_mattermost_requests:0, docker_calls:0, credential_lookups:0,
  message_reads:0, message_writes:0, model_calls:0,
  candidate_edits:0, activated:false, promoted:false,
  limits:'P2 source audit only; candidate revision and mock causal trial remain required'
});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
