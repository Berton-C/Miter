// Builder-side verifier for the first authority cluster's native assistant join.
// It observes compact MeTTa results and cannot choose or supply a cognitive result.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const petta = '/private/tmp/miter-g06-petta-ae66fa8';
const swi = '/opt/homebrew/bin/swipl';
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const fixtureRoot = 'tests/fixtures/ama1_2/r3';
const record = process.argv.includes('--record');
const evidenceRelative = 'evidence/AMA-1.2/R3/authority-runtime-join-002';
const evidence = path.join(repo, evidenceRelative);
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const hashFile = relative => sha256(fs.readFileSync(path.join(repo, relative)));
const clean = value => value.replace(/\x1b\[[0-9;]*m/g, '');

function runFixture(relative) {
  const started = Date.now();
  const result = spawnSync(swi, ['--stack_limit=2g', '-q', '-s',
    path.join(petta, 'src/main.pl'), '--', path.join(repo, relative), 'silent'], {
    cwd: repo, encoding: 'utf8', timeout: 30000, maxBuffer: 32 * 1024 * 1024
  });
  return {
    relative, status: result.status, signal: result.signal,
    error: result.error?.message ?? null, elapsed_ms: Date.now() - started,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''
  };
}

function lines(run, prefix) {
  assert.equal(run.status, 0, run.error ?? run.stderr);
  assert.equal(run.stderr, '');
  return clean(run.stdout).trim().split('\n').filter(line => line.startsWith(prefix));
}

const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
assert.equal(execFileSync('git', ['-C', petta, 'rev-parse', 'HEAD'],
  {encoding: 'utf8'}).trim(), 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git', ['-C', petta, 'status', '--porcelain'],
  {encoding: 'utf8'}).trim(), '');

const files = [
  'src/constitutive_participation_v2.metta',
  'src/assistant_reactor_v2.metta',
  'src/bootstrap_assistant_v2.metta',
  `${fixtureRoot}/authority-runtime-data.metta`,
  `${fixtureRoot}/authority-runtime-join-smoke.metta`,
  `${fixtureRoot}/authority-runtime-causal-matrix.metta`,
  `${fixtureRoot}/authority-runtime-footprint.metta`,
  `${fixtureRoot}/authority-runtime-restore.metta`,
  `${fixtureRoot}/authority-runtime-restore-severed.metta`,
  'scripts/ama1_2/r3/authority_runtime_join.mjs',
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/swift-high-fidelity-procedure.md'
];

for (const relative of files.filter(file => file.endsWith('.metta'))) {
  const source = fs.readFileSync(path.join(repo, relative), 'utf8').toLowerCase();
  for (const forbidden of ['python', 'node:', '.mjs', '.cjs']) {
    assert.equal(source.includes(forbidden), false, `${relative}: ${forbidden}`);
  }
}

const smoke = runFixture(`${fixtureRoot}/authority-runtime-join-smoke.metta`);
assert.deepEqual(lines(smoke, '(join-'), [
  '(join-incorporated true assistant-contact-incorporated constitutive-encounter)',
  '(join-history-count 1)',
  '(join-history-valid true)',
  '(join-active true (movement-standing formed thread-undertaking-alpha undertaking))'
]);

const matrix = runFixture(`${fixtureRoot}/authority-runtime-causal-matrix.metta`);
assert.deepEqual(lines(matrix, '(runtime-case '), [
  '(runtime-case m24-sever false assistant-contact-held 0)',
  '(runtime-case m260-sever false assistant-contact-held 0)',
  '(runtime-case malformed-contact assistant-contact-rejected 0)',
  '(runtime-case neutral-order assistant-contact-incorporated 1 1)',
  '(runtime-case duplicate assistant-contact-duplicate 1 1)'
]);

const footprint = runFixture(`${fixtureRoot}/authority-runtime-footprint.metta`);
assert.deepEqual(lines(footprint, '(footprint-case '), [
  '(footprint-case canonical true true true true true true true true true true)',
  '(footprint-case structural-fidelity-severed true true false false)',
  '(footprint-case opacity-severed false false false)',
  '(footprint-case persistent-form-severed true true true false false)',
  '(footprint-case opc-severed true true true false false)',
  '(footprint-case qualified-generated-severed false)',
  '(footprint-case contact-answerability-severed false)'
]);

const restore = runFixture(`${fixtureRoot}/authority-runtime-restore.metta`);
assert.deepEqual(lines(restore, '(restore-case '), [
  '(restore-case canonical assistant-state-restored-v2 1 1 true)'
]);

const severedRestore = runFixture(
  `${fixtureRoot}/authority-runtime-restore-severed.metta`);
assert.deepEqual(lines(severedRestore, '(restore-case '), [
  '(restore-case severed-same-becoming assistant-restore-rejected-v2 0 0)'
]);

const verdict = {
  schema: 'miter-ama12-r3-authority-runtime-join-verdict-v2',
  status: 'PASS-NATIVE-REACTOR-M24-M260-FOOTPRINT-NOT-YET-SUPPORTED-SERVICE',
  phase: 'AMA-1.2', attempt: 'R3', checkpoint: 'R3-C2-in-progress',
  plan_commit: opening.plan_commit, plan_sha256: opening.plan_sha256,
  cluster: 'M24-contact-provenance--M260-occurrence-participation',
  native_runtime_pin: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  constitutive_before_possibility_formation: true,
  assistant_reactor_integration: true,
  exact_authority_joint_in_history: true,
  in_memory_restart_restore: true,
  malformed_rejected: true,
  duplicate_suppressed: true,
  positive: true, severed_m24: true, severed_m260: true,
  severed_same_becoming_restore: true, neutral_order: true,
  contact_answerability_causal: true,
  same_occurrence_causal: true,
  persistent_form_causal: true,
  dws_opc_causal: true,
  observational_opacity_causal: true,
  structural_fidelity_causal: true,
  qualified_generated_causal: true,
  supported_persistent_service: false,
  disk_checkpoint_restart: false,
  atlas_rows_promoted_to_proven_runtime: 0,
  model_calls: 0, memory_reads: 0, mattermost_payload_reads: 0,
  network_calls: 0, external_effects: 0,
  note: 'The cluster now causes the native assistant encounter and restore boundary. It is not yet reachable through the supported operator/service, so its 20 rows remain below PROVEN-RUNTIME.'
};

if (record) {
  assert.equal(fs.existsSync(evidence), false, `${evidenceRelative} already exists`);
  fs.mkdirSync(evidence, {recursive: true});
  const write = (name, value) => fs.writeFileSync(path.join(evidence, name),
    typeof value === 'string' ? value : `${JSON.stringify(value, null, 2)}\n`,
    {mode: 0o600});
  for (const [name, run] of Object.entries({smoke, matrix, restore,
    footprint, 'restore-severed': severedRestore})) {
    write(`${name}.stdout`, run.stdout);
    write(`${name}.stderr`, run.stderr);
    write(`${name}-process.json`, {...run, stdout: undefined, stderr: undefined});
  }
  write('verdict.json', verdict);
  write('manifest.json', {
    schema: 'miter-ama12-r3-authority-runtime-join-manifest-v2',
    files: files.map(relative => ({path: relative, sha256: hashFile(relative)})),
    evidence_files: ['smoke.stdout', 'smoke.stderr', 'smoke-process.json',
      'matrix.stdout', 'matrix.stderr', 'matrix-process.json',
      'footprint.stdout', 'footprint.stderr', 'footprint-process.json',
      'restore.stdout', 'restore.stderr', 'restore-process.json',
      'restore-severed.stdout', 'restore-severed.stderr',
      'restore-severed-process.json', 'verdict.json'],
    contains_credentials: false, contains_private_content: false
  });
}

process.stdout.write(`${JSON.stringify({...verdict,
  evidence: record ? evidenceRelative : null}, null, 2)}\n`);
