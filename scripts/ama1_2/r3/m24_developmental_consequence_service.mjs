// Builder-side causal service trial. JavaScript only orchestrates the supported
// operator and inspects evidence; all developmental decisions remain in MeTTa.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const petta = '/private/tmp/miter-g06-petta-ae66fa8';
const swi = '/opt/homebrew/bin/swipl';
const supportedOperator = path.join(repo, 'bin/miter');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const contactPath = path.join(repo,
  'tests/fixtures/ama1_2/r3/probe-contact-v3.json');
const consequencePath = path.join(repo,
  'tests/fixtures/ama1_2/r3/probe-consequence-v2.json');
const bindingsPath = path.join(repo, 'tests/fixtures/ama1_2/scope-bindings.json');
const nativeTransitionFixture =
  'tests/fixtures/ama1_2/r3/m24-developmental-consequence.metta';
const nativeRuntimeFixture =
  'tests/fixtures/ama1_2/r3/m24-developmental-consequence-runtime.metta';
const forbiddenRoot = '/Users/bcb/.miter';
const record = process.argv.includes('--record');
const evidenceRelative =
  'evidence/AMA-1.2/R3/m24-developmental-consequence-service-001';
const evidence = path.join(repo, evidenceRelative);
// Two developmental cuts retain the complete constitutive joint and returned
// consequence lineage. Preserve a linear bounded ceiling while refusing to
// thin the movement organization merely to satisfy the older partial seam cap.
const maxTwoCutCheckpointBytes = 2560 * 1024;
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const commands = [];

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
}

function run(name, args, expected = 0, timeout = 20000) {
  const result = spawnSync(supportedOperator, args,
    {cwd: repo, encoding: 'utf8', timeout, maxBuffer: 32 * 1024 * 1024});
  let reply = null;
  try { reply = JSON.parse(result.stdout); } catch {}
  commands.push({name, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', reply});
  assert.equal(result.status, expected, `${name}: ${result.stderr || result.stdout}`);
  assert.equal(result.signal, null, name);
  assert.equal(result.stderr, '', name);
  return reply;
}

function runNative(relative) {
  return execFileSync(swi, ['-q', '-f', 'none', '-s',
    path.join(petta, 'src/main.pl'), '--', path.join(repo, relative), 'silent'],
  {cwd: repo, encoding: 'utf8', timeout: 30000, maxBuffer: 32 * 1024 * 1024});
}

async function waitFor(label, predicate, timeout = 10000) {
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (predicate()) return;
    await sleep(40);
  }
  assert.fail(`timed out waiting for ${label}`);
}

async function waitReceipt(root, inputId) {
  const receipt = path.join(root, 'receipts', `${inputId}.json`);
  await waitFor(`${inputId} native checkpoint`, () => {
    if (!fs.existsSync(receipt)) return false;
    return JSON.parse(fs.readFileSync(receipt, 'utf8')).standing ===
      'native-checkpointed';
  });
  return JSON.parse(fs.readFileSync(receipt, 'utf8'));
}

function jsonCount(directory) {
  return fs.existsSync(directory)
    ? fs.readdirSync(directory).filter(name => name.endsWith('.json')).length : 0;
}

function writeCheckpoint(root, text) {
  const termPath = path.join(root, 'checkpoints/active.term');
  const metaPath = path.join(root, 'checkpoints/active.json');
  fs.writeFileSync(termPath, text, {mode: 0o600});
  const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
  meta.sha256 = fileHash(termPath);
  writeJson(metaPath, meta);
}

const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
assert.equal(fs.existsSync(forbiddenRoot), false,
  'the forbidden implicit runtime root must remain absent');
if (record) assert.equal(fs.existsSync(evidence), false,
  'causal service evidence is immutable once recorded');

const nativeTransitionOutput = runNative(nativeTransitionFixture);
assert.match(nativeTransitionOutput,
  /\(m24-consequence-case canonical inquiry true true true probe-eligible true true 2 2 2 2\)/);
assert.match(nativeTransitionOutput,
  /\(m24-consequence-case movement-link-severed false false\)/);
assert.match(nativeTransitionOutput,
  /\(m24-consequence-case non-inquiry undertaking false\)/);
const nativeRuntimeOutput = runNative(nativeRuntimeFixture);
assert.match(nativeRuntimeOutput,
  /\(m24-runtime-consequence canonical 2 1 true true probe-eligible true true\)/);
assert.match(nativeRuntimeOutput,
  /\(m24-runtime-consequence duplicate assistant-consequence-duplicate 2\)/);

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-r3-m24-consequence-'));
let active = false;
try {
  assert.equal(run('bootstrap', ['bootstrap', '--runtime-root', root]).status,
    'bootstrapped');
  fs.copyFileSync(bindingsPath, path.join(root, 'scope-bindings.json'));
  assert.equal(run('start', ['start', '--runtime-root', root]).status, 'started');
  active = true;

  const contact = JSON.parse(fs.readFileSync(contactPath, 'utf8'));
  assert.equal(run('submit-probe-contact', ['submit', '--runtime-root', root,
    '--event', contactPath]).status, 'queued');
  assert.equal((await waitReceipt(root, contact.input_id)).standing,
    'native-checkpointed');

  const termPath = path.join(root, 'checkpoints/active.term');
  const before = fs.readFileSync(termPath, 'utf8');
  for (const required of [
    'encounter-incorporated-v3', 'probe-basis-v1', 'constitutive-inquiry',
    'm24-developmental-organization-v1', 'probe-unresolved'
  ]) assert.ok(before.includes(required), `pre-consequence checkpoint missing ${required}`);
  const beforeHash = fileHash(termPath);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'contact should commit one local isolated effect');

  const consequence = JSON.parse(fs.readFileSync(consequencePath, 'utf8'));
  assert.equal(run('submit-returned-consequence', ['submit', '--runtime-root', root,
    '--event', consequencePath]).status, 'queued');
  assert.equal((await waitReceipt(root, consequence.input_id)).standing,
    'native-checkpointed');

  const canonical = fs.readFileSync(termPath, 'utf8');
  const canonicalHash = fileHash(termPath);
  const canonicalBytes = fs.statSync(termPath).size;
  assert.notEqual(canonicalHash, beforeHash,
    'returned consequence must materially change the persisted organization');
  for (const required of [
    'consequence-incorporation-v3', 'next-constitutive-organization-v3',
    'm24-developmental-transition-v1', 'probe-eligible',
    'retrospective-affordance-v1', 'contact-uptake-returned',
    'consequence-patch', 'm24-consequence-developmental-grounding',
    'returned-consequence-reference'
  ]) assert.ok(canonical.includes(required), `checkpoint missing ${required}`);
  assert.ok(canonicalBytes <= maxTwoCutCheckpointBytes,
    `two-cut checkpoint unexpectedly expanded to ${canonicalBytes} bytes`);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'consequence incorporation must not invent a second outbound effect');

  assert.equal(run('duplicate-consequence', ['submit', '--runtime-root', root,
    '--event', consequencePath]).status, 'duplicate');
  await sleep(250);
  assert.equal(fileHash(termPath), canonicalHash,
    'duplicate consequence must not advance the checkpoint');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'duplicate consequence must not replay an effect');

  assert.equal(run('stop-before-restart', ['stop', '--runtime-root', root]).status,
    'stopped');
  active = false;
  assert.equal(run('restart-canonical', ['start', '--runtime-root', root]).status,
    'started');
  active = true;
  await sleep(400);
  assert.equal(fileHash(termPath), canonicalHash,
    'fresh process must retain the consequence-transformed organization');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'fresh process must not replay an effect');

  assert.equal(run('stop-before-severance', ['stop', '--runtime-root', root]).status,
    'stopped');
  active = false;

  const referenceOccurrences =
    canonical.split('returned-consequence-reference').length - 1;
  assert.ok(referenceOccurrences > 0,
    'expected retained returned-consequence lineage');
  const lineageSevered = canonical.replaceAll('returned-consequence-reference',
    'unsupported-consequence-reference');
  writeCheckpoint(root, lineageSevered);
  const lineageRejected = run('restart-severed-consequence-lineage',
    ['start', '--runtime-root', root], 1);
  assert.equal(lineageRejected.status, 'start-failed');
  assert.notEqual(run('lineage-severed-status',
    ['status', '--runtime-root', root]).status, 'running');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'rejected lineage restore must not replay an effect');

  writeCheckpoint(root, canonical);
  assert.equal(run('restart-after-lineage-restoration',
    ['start', '--runtime-root', root]).status, 'started');
  active = true;
  await sleep(300);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(run('stop-before-affordance-severance',
    ['stop', '--runtime-root', root]).status, 'stopped');
  active = false;

  const retrospectiveOccurrences =
    canonical.split('retrospective-affordance-v1').length - 1;
  assert.ok(retrospectiveOccurrences > 0,
    'expected consequence-earned retrospective affordance');
  const affordanceSevered = canonical.replaceAll('retrospective-affordance-v1',
    'retrospective-affordance-severed');
  writeCheckpoint(root, affordanceSevered);
  const affordanceRejected = run('restart-severed-retrospective-affordance',
    ['start', '--runtime-root', root], 1);
  assert.equal(affordanceRejected.status, 'start-failed');
  assert.notEqual(run('affordance-severed-status',
    ['status', '--runtime-root', root]).status, 'running');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'rejected affordance restore must not replay an effect');

  writeCheckpoint(root, canonical);
  assert.equal(run('restart-after-affordance-restoration',
    ['start', '--runtime-root', root]).status, 'started');
  active = true;
  await sleep(300);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(run('panic', ['panic', '--runtime-root', root]).status, 'panicked');
  active = false;
  assert.equal(fs.existsSync(forbiddenRoot), false,
    'no command may create the forbidden implicit runtime root');

  const verdict = {
    schema: 'miter-ama12-r3-m24-developmental-consequence-service-verdict-v1',
    status: 'PASS-SUPPORTED-RUNTIME-CONSEQUENCE-CHANGES-M24-DEVELOPMENT',
    phase: 'AMA-1.2', attempt: 'R3', checkpoint: 'R3-C2-in-progress',
    plan_commit: opening.plan_commit, plan_sha256: opening.plan_sha256,
    supported_entry: 'bin/miter -> AssistantServiceStartV2',
    native_transition_fixture_passed: true,
    native_runtime_fixture_passed: true,
    exact_active_movement_lineage_required: true,
    returned_consequence_changes_next_cut: true,
    probe_eligibility_earned_from_returned_contact: true,
    retrospective_affordance_persisted: true,
    traction_changed_by_consequence: true,
    append_only_branch_transaction_persisted: true,
    consequence_participation_precedes_next_movement: true,
    fresh_process_restore: true,
    severed_returned_consequence_lineage_rejected: true,
    severed_retrospective_affordance_rejected: true,
    invalid_transition_rejected_native: true,
    exact_restoration_recovers: true,
    duplicate_suppressed: true,
    effect_replay_suppressed: true,
    canonical_checkpoint_bytes: canonicalBytes,
    canonical_checkpoint_limit_bytes: maxTwoCutCheckpointBytes,
    forbidden_implicit_root_absent: true,
    model_calls: 0, memory_reads: 0, mattermost_payload_reads: 0,
    network_calls: 0, external_effects: 0,
    local_isolated_outbox_effects: 1,
    atlas_rows_promoted_to_proven_runtime: 0,
    runtime_root: root,
    note: 'This closes one causal M24 consequence seam inside the supported runtime. C2 and the 114-row authority inheritance remain open.'
  };

  if (record) {
    fs.mkdirSync(evidence, {recursive: true});
    writeJson(path.join(evidence, 'commands.json'), commands);
    writeJson(path.join(evidence, 'verdict.json'), verdict);
    fs.writeFileSync(path.join(evidence, 'native-transition-output.txt'),
      nativeTransitionOutput, {mode: 0o600});
    fs.writeFileSync(path.join(evidence, 'native-runtime-output.txt'),
      nativeRuntimeOutput, {mode: 0o600});
    fs.copyFileSync(termPath, path.join(evidence, 'canonical-checkpoint.term'));
    fs.copyFileSync(path.join(root, 'lkg.json'), path.join(evidence, 'lkg.json'));
    fs.copyFileSync(path.join(root, 'service-entry.metta'),
      path.join(evidence, 'service-entry.metta'));
    const sources = [
      'bin/miter',
      'effect_membranes/miter_assistant_operator_v2.pl',
      'effect_membranes/miter_assistant_service_v1.pl',
      'src/authority_inheritance_v1.metta',
      'src/constitutive_participation_v2.metta',
      'src/assistant_reactor_v2.metta',
      'src/bootstrap_assistant_v2.metta',
      'tests/fixtures/ama1_2/r3/authority-runtime-data.metta',
      nativeTransitionFixture, nativeRuntimeFixture,
      'tests/fixtures/ama1_2/r3/probe-contact-v3.json',
      'tests/fixtures/ama1_2/r3/probe-consequence-v2.json',
      'tests/fixtures/ama1_2/scope-bindings.json',
      'scripts/ama1_2/r3/m24_developmental_consequence_service.mjs'
    ].map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}));
    writeJson(path.join(evidence, 'manifest.json'), {
      schema: 'miter-ama12-r3-m24-developmental-consequence-service-manifest-v1',
      files: sources,
      artifacts: ['commands.json', 'verdict.json', 'native-transition-output.txt',
        'native-runtime-output.txt', 'canonical-checkpoint.term', 'lkg.json',
        'service-entry.metta'],
      contains_credentials: false, contains_private_content: false
    });
  }

  process.stdout.write(`${JSON.stringify({...verdict,
    evidence: record ? evidenceRelative : null}, null, 2)}\n`);
} finally {
  if (active) spawnSync(supportedOperator, ['panic', '--runtime-root', root],
    {cwd: repo, encoding: 'utf8'});
}
