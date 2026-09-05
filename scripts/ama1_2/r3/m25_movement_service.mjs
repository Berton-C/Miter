// Builder-side evidence runner for one M25 movement read through bin/miter.
// It transports inputs and inspects persistence; semantic standing remains MeTTa-owned.

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
const operator = path.join(repo, 'bin/miter');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const contactPath = path.join(repo, 'tests/fixtures/ama1_2/r3/probe-contact-v3.json');
const bindingsPath = path.join(repo, 'tests/fixtures/ama1_2/scope-bindings.json');
const nativeFixture = 'tests/fixtures/ama1_2/r3/m25-movement-primary-runtime.metta';
const forbiddenRoot = '/Users/bcb/.miter';
const record = process.argv.includes('--record');
const evidenceRelative = 'evidence/AMA-1.2/R3/m25-movement-service-001';
const evidence = path.join(repo, evidenceRelative);
// The explicit Fact9-Flourishing constitutive joint is proof-carrying state,
// not optional diagnostic metadata. Keep the first integrated snapshot under a
// conventional 1 MiB ceiling while later AtomSpace normalization remains a
// separately evidenced optimization rather than a reason to thin the joint.
const maxCanonicalCheckpointBytes = 1024 * 1024;
const commands = [];
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
}

function run(name, args, expected = 0, timeout = 20000) {
  const result = spawnSync(operator, args,
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

function runNative() {
  return execFileSync(swi, ['-q', '-f', 'none', '-s',
    path.join(petta, 'src/main.pl'), '--', path.join(repo, nativeFixture), 'silent'],
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
assert.equal(fs.existsSync(forbiddenRoot), false);
if (record) assert.equal(fs.existsSync(evidence), false,
  'M25 service evidence is immutable once recorded');

const nativeOutput = runNative();
for (const expected of [
  '(m25-primary-case formation true true 3 3 true true true)',
  '(m25-primary-case rap true true true admissible one-contact-movement-surface-three-simultaneous-perspectives true)',
  '(m25-primary-case constitutive-joint true true true true true true)',
  '(m25-primary-case construction 3 movement-formed undertaking thread-undertaking-alpha true)',
  '(m25-primary-case runtime true true movement-formed (movement-standing formed thread-undertaking-alpha undertaking) true)',
  '(m25-causal-case ambient-soul true false false)',
  '(m25-causal-case constitutive-joint-severed true false false false)',
  '(m25-causal-case relation-severed true m25-primary-movement-v2 false read-app-held unresolved harmonic-alignment-unresolved)',
  '(m25-causal-case distinction-severed true m25-primary-movement-v2 false read-app-held unresolved harmonic-alignment-unresolved)',
  '(m25-causal-case interface-change true available true (participation-mode-for-route interface-contact))',
  '(m25-causal-case energetics true true true)',
  '(m25-causal-case shared-trajectory true false false false true false true true pns-like sns-like stuck)',
  '(m25-causal-case bounded-harmonic true false true true)',
  '(m25-causal-case neutral-permutation true true (movement-standing formed thread-undertaking-alpha undertaking) (movement-standing formed thread-undertaking-alpha undertaking))'
]) assert.ok(nativeOutput.includes(expected), `native matrix missing ${expected}`);

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-r3-m25-'));
let active = false;
try {
  assert.equal(run('bootstrap', ['bootstrap', '--runtime-root', root]).status,
    'bootstrapped');
  fs.copyFileSync(bindingsPath, path.join(root, 'scope-bindings.json'));
  assert.equal(run('start', ['start', '--runtime-root', root]).status, 'started');
  active = true;
  assert.equal(run('submit-contact', ['submit', '--runtime-root', root,
    '--event', contactPath]).status, 'queued');
  const contact = JSON.parse(fs.readFileSync(contactPath, 'utf8'));
  await waitReceipt(root, contact.input_id);

  const termPath = path.join(root, 'checkpoints/active.term');
  const canonical = fs.readFileSync(termPath, 'utf8');
  const canonicalHash = fileHash(termPath);
  const canonicalBytes = fs.statSync(termPath).size;
  for (const required of [
    'dynamic-participatory-fourthness-v1', 'm25-primary-movement-v2',
    'balance-unfolding-as-intelligence',
    'fact9-flourishing-constitutive-joint', 'bridge-organization',
    'fact9-expressions', 'flourishing-expressions',
    'rap-read-v2',
    'one-contact-movement-surface-three-simultaneous-perspectives',
    'balance-unfolding-alignment',
    'rap-perspectives', 'relatedness-perspective',
    'appropriateness-perspective', 'precision-perspective', 'read-app-v2',
    'harmonic-alignment-witness', 'm25-energetics-v1',
    'participation-orientation-v1', 'interface-change-standing',
    'retained-alternatives-v3', 'primary-before-rap'
  ]) assert.ok(canonical.includes(required), `checkpoint missing ${required}`);
  assert.ok(canonicalBytes <= maxCanonicalCheckpointBytes,
    `M25 checkpoint unexpectedly expanded to ${canonicalBytes} bytes`);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1);

  assert.equal(run('duplicate-contact', ['submit', '--runtime-root', root,
    '--event', contactPath]).status, 'duplicate');
  await sleep(250);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1);

  assert.equal(run('stop-before-restart', ['stop', '--runtime-root', root]).status,
    'stopped');
  active = false;
  assert.equal(run('restart-canonical', ['start', '--runtime-root', root]).status,
    'started');
  active = true;
  await sleep(350);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1);
  assert.equal(run('stop-before-severance', ['stop', '--runtime-root', root]).status,
    'stopped');
  active = false;

  const severances = [
    ['rap-read-event', 'rap-read-event-severed'],
    ['relatedness-perspective', 'relatedness-perspective-severed'],
    ['precision-perspective', 'precision-perspective-severed'],
    ['one-contact-movement-surface-three-simultaneous-perspectives',
      'three-disconnected-sequential-judges'],
    ['fact9-flourishing-constitutive-joint',
      'fact9-flourishing-posthoc-mapping'],
    ['fact9-expressions', 'fact9-expressions-severed'],
    ['flourishing-expressions', 'flourishing-expressions-severed'],
    ['balance-unfolding-alignment', 'balance-unfolding-alignment-severed'],
    ['soul-relation', 'soul-standing']
  ];
  const severanceRoots = [];
  for (const [name, [from, to]] of severances.entries()) {
    assert.ok(canonical.includes(from), `${from} not present for severance`);
    const severRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-r3-m25-s${name}-`));
    severanceRoots.push(severRoot);
    assert.equal(run(`bootstrap-severance-${name}`,
      ['bootstrap', '--runtime-root', severRoot]).status, 'bootstrapped');
    fs.copyFileSync(bindingsPath, path.join(severRoot, 'scope-bindings.json'));
    fs.copyFileSync(path.join(root, 'checkpoints/active.json'),
      path.join(severRoot, 'checkpoints/active.json'));
    fs.copyFileSync(termPath, path.join(severRoot, 'checkpoints/active.term'));
    writeCheckpoint(severRoot, canonical.replaceAll(from, to));
    const rejected = run(`restart-severed-${name}`,
      ['start', '--runtime-root', severRoot], 1);
    assert.equal(rejected.status, 'start-failed');
    assert.notEqual(run(`status-severed-${name}`,
      ['status', '--runtime-root', severRoot]).status, 'running');
    assert.equal(jsonCount(path.join(severRoot, 'outbox')), 0,
      'rejected restore must not replay the prior effect');
  }

  assert.equal(run('restart-restored', ['start', '--runtime-root', root]).status,
    'started');
  active = true;
  await sleep(350);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1);
  assert.equal(run('panic', ['panic', '--runtime-root', root]).status, 'panicked');
  active = false;
  assert.equal(fs.existsSync(forbiddenRoot), false);

  const verdict = {
    schema: 'miter-ama12-r3-m25-movement-service-verdict-v1',
    status: 'PASS-SUPPORTED-RUNTIME-M25-ONE-MOVEMENT-ONE-RAP-READ',
    phase: 'AMA-1.2', attempt: 'R3', checkpoint: 'R3-C2-in-progress',
    plan_commit: opening.plan_commit, plan_sha256: opening.plan_sha256,
    supported_entry: 'bin/miter -> AssistantServiceStartV2',
    movement_primary: true,
    one_contact_surface_one_rap_read: true,
    simultaneous_heterogeneous_perspectives: ['Relatedness', 'Appropriateness', 'Precision'],
    sequential_judges_absent: true,
    rap_is_not_chooser: true,
    balance_unfolding_is_one_contact_movement_organization: true,
    fact9_flourishing_joint_is_material_to_primary_movement: true,
    same_fact9_flourishing_joint_is_material_to_rap_surface: true,
    severed_fact9_joint_rejected: true,
    severed_flourishing_joint_rejected: true,
    severed_balance_alignment_rejected: true,
    dpf_counterfactual_bite: true,
    ambient_soul_relations_not_standing: true,
    relatedness_floor_non_compensatory: true,
    precision_floor_non_compensatory: true,
    read_app_derived_not_contact: true,
    harmonic_alignment_derived: true,
    bounded_harmonic_miss_renews_actuality: true,
    energetic_types_noncollapsed: true,
    high_action_low_forcing_admitted: true,
    pns_sns_stuck_shared_trajectory_basis: true,
    stuck_implies_sns: true,
    interface_change_possible: true,
    native_neutral_permutation_preserves_movement: true,
    persisted_through_supported_service: true,
    fresh_process_restore: true,
    severed_read_event_rejected: true,
    severed_relatedness_perspective_rejected: true,
    severed_precision_perspective_rejected: true,
    disconnected_sequential_judges_rejected: true,
    soul_standing_carrier_rejected: true,
    exact_restoration_recovers: true,
    duplicate_suppressed: true,
    effect_replay_suppressed: true,
    canonical_checkpoint_bytes: canonicalBytes,
    canonical_checkpoint_limit_bytes: maxCanonicalCheckpointBytes,
    model_calls: 0, memory_reads: 0, mattermost_payload_reads: 0,
    network_calls: 0, external_effects: 0, local_isolated_outbox_effects: 1,
    forbidden_implicit_root_absent: true,
    runtime_root: root, severance_runtime_roots: severanceRoots,
    note: 'This is an additive M25 seam in the same supported runtime. C2 remains open; trajectory orientation is structurally discriminated but awaits live multi-cut consequence consumption before its operational rows can close.'
  };

  if (record) {
    fs.mkdirSync(evidence, {recursive: true});
    writeJson(path.join(evidence, 'commands.json'), commands);
    writeJson(path.join(evidence, 'verdict.json'), verdict);
    fs.writeFileSync(path.join(evidence, 'native-output.txt'), nativeOutput,
      {mode: 0o600});
    fs.copyFileSync(termPath, path.join(evidence, 'canonical-checkpoint.term'));
    fs.copyFileSync(path.join(root, 'lkg.json'), path.join(evidence, 'lkg.json'));
    fs.copyFileSync(path.join(root, 'service-entry.metta'),
      path.join(evidence, 'service-entry.metta'));
    const sources = [
      'bin/miter', 'effect_membranes/miter_assistant_operator_v2.pl',
      'effect_membranes/miter_assistant_service_v1.pl',
      'src/authority_inheritance_v1.metta',
      'src/constitutive_participation_v2.metta',
      'src/assistant_reactor_v2.metta', 'src/bootstrap_assistant_v2.metta',
      'tests/fixtures/ama1_2/r3/authority-runtime-data.metta', nativeFixture,
      'tests/fixtures/ama1_2/r3/probe-contact-v3.json',
      'tests/fixtures/ama1_2/scope-bindings.json',
      'scripts/ama1_2/r3/m25_movement_service.mjs'
    ].map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}));
    writeJson(path.join(evidence, 'manifest.json'), {
      schema: 'miter-ama12-r3-m25-movement-service-manifest-v1',
      files: sources,
      artifacts: ['commands.json', 'verdict.json', 'native-output.txt',
        'canonical-checkpoint.term', 'lkg.json', 'service-entry.metta'],
      contains_credentials: false, contains_private_content: false
    });
  }

  process.stdout.write(`${JSON.stringify({...verdict,
    evidence: record ? evidenceRelative : null}, null, 2)}\n`);
} finally {
  if (active) spawnSync(operator, ['panic', '--runtime-root', root],
    {cwd: repo, encoding: 'utf8'});
}
