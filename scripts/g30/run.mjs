// Execute canonical native trial, then independent severed processes.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root, hash, read, save, native, swi, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G30/attempt-${tag}`;
const prepared = read(`${dir}/prepared.json`);
assert.equal(prepared.status, 'PREPARED');
for (const file of read(`${dir}/manifest.json`).files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
process.on('uncaughtException', error => {
  save(`${dir}/run-failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});

const candidate = `${dir}/candidate/extension/mattermost_bridge.pl`;
const candidateHash = prepared.candidate_sha256;
const canonicalRoot = `${dir}/canonical`;
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_mock_trial_v1.metta")\n`;
const rows = native(dir, 'execute-canonical',
  `!(result outcome (G30Run ${sexp(canonicalRoot)} ${sexp(candidate)} ${sexp(candidateHash)} ${sexp(candidateHash)} quarantined none none))`,
  boot);
assert.equal(rows.length, 1);
const nativeResult = rows[0][2];
save(`${dir}/native-result.json`, {native:nativeResult});

const severance = read(`${dir}/severance.json`);
for (const variant of severance.variants) {
  const outputRoot = `${dir}/severed-${variant.name}`;
  const goal = `miter_mattermost_mock_v1:g30_mock_trial('${outputRoot}','${variant.path}','${variant.sha256}',R),write_canonical(R),nl`;
  const started = Date.now();
  const process = spawnSync(swi,
    ['-q', '-f', 'none', '-s',
      `${root}/effect_membranes/miter_mattermost_mock_v1.pl`,
      '-g', goal, '-t', 'halt'],
    {encoding:'utf8', timeout:60000, maxBuffer:8*1024*1024});
  save(`${dir}/severed-${variant.name}-process.json`, {
    status:process.status, signal:process.signal,
    error:process.error?.message, elapsed_ms:Date.now()-started
  });
  save(`${dir}/severed-${variant.name}.stdout`, process.stdout ?? '');
  save(`${dir}/severed-${variant.name}.stderr`, process.stderr ?? '');
  assert.equal(process.status, 0, process.stderr);
  assert.equal(process.stderr, '');
}

const assessment = nativeResult[2];
const canonical = read(`${canonicalRoot}/summary.json`);
const identity = read(`${dir}/severed-identity/summary.json`);
const idempotency = read(`${dir}/severed-idempotency/summary.json`);
save(`${dir}/run-verdict.json`, {
  status:assessment[0] === 'g30-mock-qualified' ? 'PASS-BOUNDED' : 'FAIL-EVIDENCE',
  native_assessment:assessment[0],
  candidate_sha256:candidateHash,
  canonical:{
    initial_event_count:canonical.initial_event_count,
    duplicate_event_count:canonical.duplicate_event_count,
    edited_event_count:canonical.edited_event_count,
    unauthorized_event_count:canonical.unauthorized_event_count,
    authorization_preceded_payload:canonical.authorization_preceded_payload,
    request_attempt_count:canonical.request_attempt_count,
    server_create_count:canonical.server_create_count,
    same_key_retries:canonical.same_key_retries,
    failure_witness_count:canonical.failure_witness_count,
    restart_cursor:canonical.restart_cursor,
    duplicate_effect_suppressed:canonical.duplicate_effect_suppressed
  },
  severed_identity_detected:identity.authorization_preceded_payload === false,
  severed_idempotency_detected:idempotency.duplicate_effect_suppressed === false,
  model_calls:0, network_calls:0, credentials_used:0,
  candidate_modified:false, activated:false, promoted:false
});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
