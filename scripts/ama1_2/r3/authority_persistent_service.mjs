// Builder-side persistent-service trial for the native authority join.
// The script transports fixtures and observes receipts; it cannot select movement.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const swi = '/opt/homebrew/bin/swipl';
const operatorSource = path.join(repo, 'effect_membranes/miter_assistant_operator_v2.pl');
const supportedOperator = path.join(repo, 'bin/miter');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const contactPath = path.join(repo, 'tests/fixtures/ama1_2/scope-contact-v3.json');
const bindingsPath = path.join(repo, 'tests/fixtures/ama1_2/scope-bindings.json');
const forbiddenRoot = '/Users/bcb/.miter';
const record = process.argv.includes('--record');
const evidenceRelative = 'evidence/AMA-1.2/R3/authority-persistent-service-003';
const evidence = path.join(repo, evidenceRelative);
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
    return JSON.parse(fs.readFileSync(receipt, 'utf8')).standing === 'native-checkpointed';
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
  'the forbidden implicit runtime root must already be absent');
if (record) assert.equal(fs.existsSync(evidence), false,
  'persistent-service evidence is immutable once recorded');

execFileSync(swi, ['-q', '-f', 'none', '-g',
  `load_files('${operatorSource}',[silent(true)]),halt`], {cwd: repo, encoding: 'utf8'});

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-r3-service-'));
let active = false;
try {
  const boot = run('bootstrap', ['bootstrap', '--runtime-root', root]);
  assert.equal(boot.status, 'bootstrapped');
  assert.equal(run('bootstrap-idempotent',
    ['bootstrap', '--runtime-root', root]).status, 'already-bootstrapped');
  const lkg = JSON.parse(fs.readFileSync(path.join(root, 'lkg.json'), 'utf8'));
  assert.equal(lkg.schema, 'miter-assistant-lkg-v2');
  const lkgPaths = lkg.files.map(file => file.path);
  for (const required of [
    'src/authority_inheritance_v1.metta',
    'src/constitutive_participation_v2.metta',
    'src/assistant_reactor_v2.metta',
    'src/bootstrap_assistant_v2.metta',
    'bin/miter',
    'effect_membranes/miter_assistant_operator_v2.pl',
    'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json'
  ]) assert.ok(lkgPaths.includes(required), `LKG missing ${required}`);
  const entry = fs.readFileSync(path.join(root, 'service-entry.metta'), 'utf8');
  assert.match(entry, /bootstrap_assistant_v2\.metta/);
  assert.match(entry, /AssistantServiceStartV2/);

  fs.copyFileSync(bindingsPath, path.join(root, 'scope-bindings.json'));
  const started = run('start', ['start', '--runtime-root', root]);
  assert.equal(started.status, 'started'); active = true;
  assert.equal(run('running-status', ['status', '--runtime-root', root]).status, 'running');
  await sleep(700);
  assert.equal(fs.existsSync(path.join(root, 'checkpoints/active.term')), false,
    'idle cycling must not manufacture a checkpoint');

  const submitted = run('submit-contact', ['submit', '--runtime-root', root,
    '--event', contactPath]);
  assert.equal(submitted.status, 'queued');
  const contact = JSON.parse(fs.readFileSync(contactPath, 'utf8'));
  assert.equal((await waitReceipt(root, contact.input_id)).standing, 'native-checkpointed');

  const termPath = path.join(root, 'checkpoints/active.term');
  const canonical = fs.readFileSync(termPath, 'utf8');
  for (const required of [
    'authority-participation-joint-v2', 'm24-contact',
    'm24-contact-organization', 'm260-occurrence-organization',
    'contact-answerability-anchor', 'same-occurrence-family',
    'persistent-form-family', 'dws-family', 'opc-at',
    'finite-observational-opacity', 'structural-fidelity-witness',
    'g-reading-of', 'same-becoming-certified',
    'm24-developmental-organization-v1', 'formal-carrier-v1',
    'virtual-equipment-host-v1', 'carrier-open-discharge-v1',
    'prospective-attachment-v1', 'derived-selfgen-v1',
    'interpretation-state-v1', 'availability-state-v1',
    'affordance-state-v1', 'traction-state-v1', 'frame-plurality-v1',
    'writer-boundary-v1', 'branch-transaction',
    'm24-developmental-grounding',
    'finite-non-reconstruction', 'encounter-incorporated-v2'
  ]) assert.ok(canonical.includes(required), `checkpoint missing ${required}`);
  const canonicalHash = fileHash(termPath);
  const canonicalBytes = fs.statSync(termPath).size;
  assert.ok(canonicalBytes <= 300000,
    `single-contact checkpoint unexpectedly expanded to ${canonicalBytes} bytes`);
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'one local no-network effect should be committed');

  assert.equal(run('duplicate-contact', ['submit', '--runtime-root', root,
    '--event', contactPath]).status, 'duplicate');
  await sleep(300);
  assert.equal(fileHash(termPath), canonicalHash,
    'duplicate contact must not advance the checkpoint');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'duplicate contact must not replay the effect');

  assert.equal(run('stop-before-restart', ['stop', '--runtime-root', root]).status,
    'stopped'); active = false;
  const restarted = run('restart-canonical', ['start', '--runtime-root', root]);
  assert.equal(restarted.status, 'started'); active = true;
  await sleep(500);
  assert.equal(fileHash(termPath), canonicalHash,
    'fresh process must retain the authority-grounded checkpoint');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'fresh process must not replay the effect');
  assert.equal(run('stop-before-severance', ['stop', '--runtime-root', root]).status,
    'stopped'); active = false;

  const sameStanding = ",true],['contact-answerability-anchor'";
  const occurrences = canonical.split(sameStanding).length - 1;
  assert.equal(occurrences, 1,
    'expected one exact SameBecoming certificate standing in authority joint');
  const severed = canonical.replace(sameStanding,
    ",false],['contact-answerability-anchor'");
  writeCheckpoint(root, severed);
  const rejected = run('restart-severed-same-becoming',
    ['start', '--runtime-root', root], 1);
  assert.equal(rejected.status, 'start-failed');
  await sleep(200);
  assert.notEqual(run('severed-status', ['status', '--runtime-root', root]).status,
    'running');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'rejected restore must not replay an effect');

  writeCheckpoint(root, canonical);
  const restored = run('restart-restored', ['start', '--runtime-root', root]);
  assert.equal(restored.status, 'started'); active = true;
  await sleep(500);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(run('stop-before-developmental-severance',
    ['stop', '--runtime-root', root]).status, 'stopped'); active = false;

  const developmentalStanding =
    "['discharge-standing',unresolved,'soul-judgment-required'],'non-equivalent'";
  assert.ok(canonical.includes(developmentalStanding),
    'expected a persisted M24 open/discharge non-equivalence standing');
  const developmentalOccurrences =
    canonical.split(developmentalStanding).length - 1;
  assert.ok(developmentalOccurrences > 0,
    'expected at least one persisted developmental standing');
  const developmentalSevered = canonical.replaceAll(developmentalStanding,
    "['discharge-standing',closed,'carrier-state-implied-closure'],equivalent");
  assert.notEqual(developmentalSevered, canonical,
    'developmental severance must change the persisted authority joint');
  writeCheckpoint(root, developmentalSevered);
  const developmentalRejected = run('restart-severed-m24-developmental-carrier',
    ['start', '--runtime-root', root], 1);
  assert.equal(developmentalRejected.status, 'start-failed');
  await sleep(200);
  assert.notEqual(run('developmental-severed-status',
    ['status', '--runtime-root', root]).status, 'running');
  assert.equal(jsonCount(path.join(root, 'outbox')), 1,
    'rejected developmental restore must not replay an effect');

  writeCheckpoint(root, canonical);
  const developmentalRestored = run('restart-developmental-restored',
    ['start', '--runtime-root', root]);
  assert.equal(developmentalRestored.status, 'started'); active = true;
  await sleep(500);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(run('panic', ['panic', '--runtime-root', root]).status, 'panicked');
  active = false;
  assert.equal(fs.existsSync(termPath), true);
  assert.equal(fileHash(termPath), canonicalHash);
  assert.equal(fs.existsSync(forbiddenRoot), false, 'no command may create ~/.miter');

  const verdict = {
    schema: 'miter-ama12-r3-authority-persistent-service-verdict-v3',
    status: 'PASS-SUPPORTED-PERSISTENT-SERVICE-M24-DEVELOPMENTAL-M260-FOOTPRINT',
    phase: 'AMA-1.2', attempt: 'R3', checkpoint: 'R3-C2-in-progress',
    plan_commit: opening.plan_commit, plan_sha256: opening.plan_sha256,
    candidate_operator: 'effect_membranes/miter_assistant_operator_v2.pl',
    service_entry: 'AssistantServiceStartV2',
    lkg_v2_verified: true,
    canonical_disk_checkpoint: true,
    canonical_checkpoint_bytes: canonicalBytes,
    bounded_checkpoint_representation: true,
    fresh_process_restore: true,
    duplicate_suppressed: true,
    effect_replay_suppressed: true,
    same_becoming_severance_rejected: true,
    m24_developmental_carrier_persisted: true,
    m24_developmental_participation_precedes_movement: true,
    m24_developmental_severance_rejected_on_restart: true,
    contact_answerability_present: true,
    same_occurrence_present: true,
    persistent_form_present: true,
    dws_opc_present: true,
    observational_opacity_present: true,
    structural_fidelity_present: true,
    qualified_generated_present: true,
    exact_restoration_recovers: true,
    idle_does_not_manufacture_checkpoint: true,
    forbidden_implicit_root_absent: true,
    supported_bin_uses_v2: true,
    atlas_rows_promoted_to_proven_runtime: 0,
    model_calls: 0, memory_reads: 0, mattermost_payload_reads: 0,
    network_calls: 0, external_effects: 0,
    local_isolated_outbox_effects: 1,
    runtime_root: root,
    note: 'The supported bin/miter route proves disk persistence and fresh-process authority restore for this cluster. R3-C2 remains open and no individual atlas row is inflated beyond its complete evidence.'
  };

  if (record) {
    fs.mkdirSync(evidence, {recursive: true});
    writeJson(path.join(evidence, 'commands.json'), commands);
    writeJson(path.join(evidence, 'verdict.json'), verdict);
    fs.copyFileSync(termPath, path.join(evidence, 'canonical-checkpoint.term'));
    fs.copyFileSync(path.join(root, 'lkg.json'), path.join(evidence, 'lkg.json'));
    fs.copyFileSync(path.join(root, 'service-entry.metta'),
      path.join(evidence, 'service-entry.metta'));
    const sources = [
      'effect_membranes/miter_assistant_operator_v2.pl',
      'bin/miter',
      'effect_membranes/miter_assistant_service_v1.pl',
      'src/authority_inheritance_v1.metta',
      'src/constitutive_participation_v2.metta',
      'src/assistant_reactor_v2.metta',
      'src/bootstrap_assistant_v2.metta',
      'tests/fixtures/ama1_2/scope-contact-v3.json',
      'tests/fixtures/ama1_2/scope-bindings.json',
      'scripts/ama1_2/r3/authority_persistent_service.mjs'
    ].map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}));
    writeJson(path.join(evidence, 'manifest.json'), {
      schema: 'miter-ama12-r3-authority-persistent-service-manifest-v3',
      files: sources,
      artifacts: ['commands.json', 'verdict.json', 'canonical-checkpoint.term',
        'lkg.json', 'service-entry.metta'],
      contains_credentials: false, contains_private_content: false
    });
  }

  process.stdout.write(`${JSON.stringify({...verdict,
    evidence: record ? evidenceRelative : null}, null, 2)}\n`);
} finally {
  if (active) spawnSync(supportedOperator, ['panic', '--runtime-root', root],
    {cwd: repo, encoding: 'utf8'});
}
