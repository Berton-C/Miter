// Independent builder verifier for exact bytes, mock logs and restart evidence.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root, hash, read, save, swi} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G30/attempt-${tag}`;
assert.equal(read(`${dir}/run-verdict.json`).status, 'PASS-BOUNDED');
assert.equal(read(`${dir}/quality-verdict.json`).status, 'PASS-BOUNDED');
for (const file of read(`${dir}/manifest.json`).files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);

const g29 = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidate = `${dir}/candidate/extension/mattermost_bridge.pl`;
assert.equal(hash(fs.readFileSync(candidate)), hash(fs.readFileSync(g29)));
assert.equal(hash(fs.readFileSync(candidate)),
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');

const canonical = `${dir}/canonical`;
const summary = read(`${canonical}/summary.json`);
assert.equal(summary.initial_event_count, 1);
assert.equal(summary.duplicate_event_count, 0);
assert.equal(summary.edited_event_count, 1);
assert.equal(summary.unauthorized_event_count, 0);
assert.equal(summary.authorization_preceded_payload, true);
assert.equal(summary.stable_identity_preserved, true);
assert.equal(summary.restart_cursor, 200);
assert.equal(summary.restart_seen_count, 2);
assert.equal(summary.request_attempt_count, 4);
assert.equal(summary.server_create_count, 2);
assert.equal(summary.same_key_retries, true);
assert.equal(summary.failure_witness_count, 2);
assert.equal(summary.confirmed_failure_witnessed, true);
assert.equal(summary.uncertain_outcome_witnessed, true);
assert.equal(summary.duplicate_effect_suppressed, true);
assert.equal(read(`${canonical}/resume-process.json`).status, 'exit(0)');
const durable = read(`${canonical}/durable-state.json`);
const finalState = read(`${canonical}/final-state.json`);
assert.equal(durable.cursor, 200);
assert.equal(durable.seen.length, 2);
assert.equal(finalState.cursor, 200);
assert.equal(finalState.effects.length, 2);

const requests = read(`${canonical}/request-log.json`).attempts;
assert.deepEqual(requests.filter(row => row.effect_id === 'e1')
  .map(row => row.idempotency_key), ['k1', 'k1']);
assert.deepEqual(requests.filter(row => row.effect_id === 'e2')
  .map(row => row.idempotency_key), ['k2', 'k2']);
assert.equal(requests.filter(row => row.server_created).length, 2);
assert.equal(requests.filter(row => row.deduplicated).length, 1);

const severance = read(`${dir}/severance.json`);
assert.equal(severance.canonical_sha256, hash(fs.readFileSync(candidate)));
for (const variant of severance.variants) {
  assert.equal(hash(fs.readFileSync(variant.path)), variant.sha256);
  assert.notEqual(variant.sha256, severance.canonical_sha256);
}
assert.equal(read(`${dir}/severed-identity/summary.json`)
  .authorization_preceded_payload, false);
assert.equal(read(`${dir}/severed-idempotency/summary.json`)
  .duplicate_effect_suppressed, false);

const test = spawnSync(swi,
  ['-q', '-f', 'none', '-s', candidate, '-s',
   `${dir}/candidate/candidate_tests/mattermost_contract_tests.pl`,
   '-g', 'run_tests', '-t', 'halt'],
  {cwd:`${dir}/candidate/candidate_tests`, encoding:'utf8', timeout:30000,
   maxBuffer:8*1024*1024, env:{HOME:'/nonexistent', PATH:'/usr/bin:/bin'}});
save(`${dir}/independent-candidate-test.stdout`, test.stdout ?? '');
save(`${dir}/independent-candidate-test.stderr`, test.stderr ?? '');
assert.equal(test.status, 0, test.stderr);
assert(!(test.stderr ?? '').includes('ERROR:'));
assert(!(test.stderr ?? '').includes('failed'));

const files = [];
function walk(item) {
  const stat = fs.statSync(item);
  if (stat.isDirectory()) for (const child of fs.readdirSync(item))
    walk(path.join(item, child));
  else files.push(item);
}
walk(dir);
for (const file of files) {
  const content = fs.readFileSync(file).toString('latin1');
  assert(!/sk-or-v1-[A-Za-z0-9._-]+/.test(content), file);
  assert(!/Bearer\s+[A-Za-z0-9._-]{12,}/.test(content), file);
}
assert(!fs.existsSync(`${root}/extension/mattermost_bridge.pl`));
save(`${dir}/verification.json`, {
  status:'PASS-BOUNDED', exact_g29_candidate:true,
  authorized_message_exactly_once:true, duplicate_deduplicated:true,
  edited_message_distinct:true, authorization_before_payload:true,
  failure_witnessed:true, uncertain_outcome_witnessed:true,
  same_key_retry:true, server_create_exactly_once_per_effect:true,
  fresh_process_restart:true, cursor_and_dedupe_restored:true,
  identity_severance_detected:true, idempotency_severance_detected:true,
  native_causal_controls_pass:true, candidate_tests_independently_pass:true,
  credential_absent:true, network_calls:0, model_calls:0,
  candidate_unchanged:true, activated:false, promoted:false,
  limits:'G30 deterministic mock only; G31 exact human live grant remains required'
});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
