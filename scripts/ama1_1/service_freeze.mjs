// Builder-side AMA-1.1 explicit-root service proof. Never imported by Miter.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/service-freeze-001');
const contact = path.join(repo, 'tests/fixtures/ama1_1/contact-unfamiliar.json');
const consequence = path.join(repo, 'tests/fixtures/ama1_1/consequence-unfamiliar.json');
const invalid = path.join(repo, 'tests/fixtures/ama1_1/contact-invalid.json');
const forbiddenRoot = '/Users/bcb/.miter';
const runs = [];

const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const writeJson = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const lines = file => fs.existsSync(file) ? fs.readFileSync(file, 'utf8').trim().split('\n').filter(Boolean) : [];

function run(name, args, expected = 0) {
  const result = spawnSync(operator, args, {cwd: repo, encoding: 'utf8', timeout: 15000});
  runs.push({name, args, status: result.status, signal: result.signal, stdout: result.stdout, stderr: result.stderr});
  assert.equal(result.status, expected, `${name}: ${result.stderr || result.stdout}`);
  assert.equal(result.signal, null, name);
  assert.equal(result.stderr, '', name);
  return JSON.parse(result.stdout);
}

async function waitFor(label, predicate, timeout = 6000) {
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (predicate()) return;
    await sleep(50);
  }
  assert.fail(`timed out waiting for ${label}`);
}

async function waitReceipt(root, id) {
  const file = path.join(root, 'receipts', `${id}.json`);
  await waitFor(`${id} native checkpoint`, () => {
    if (!fs.existsSync(file)) return false;
    return JSON.parse(fs.readFileSync(file, 'utf8')).standing === 'native-checkpointed';
  });
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

async function waitDead(pid) {
  await waitFor(`pid ${pid} exit`, () => {
    const result = spawnSync('/bin/kill', ['-0', String(pid)], {stdio: 'ignore'});
    return result.status !== 0;
  });
}

function killIsolated(pid) {
  const result = spawnSync('/bin/kill', ['-KILL', String(pid)], {encoding: 'utf8'});
  assert.equal(result.status, 0, result.stderr);
}

assert.equal(fs.existsSync(evidence), false, 'service evidence is immutable once recorded');
assert.equal(fs.existsSync(forbiddenRoot), false, 'the forbidden implicit runtime root must already be absent');
assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-service-proof-'));
const exportRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-service-export-'));
const exportPath = path.join(exportRoot, 'evidence.json');
let activePid = 0;

try {
  assert.equal(run('bootstrap', ['bootstrap', '--runtime-root', root]).status, 'bootstrapped');
  assert.equal(run('bootstrap-idempotent', ['bootstrap', '--runtime-root', root]).status, 'already-bootstrapped');
  assert.equal(run('initial-status', ['status', '--runtime-root', root]).status, 'stopped');
  const started = run('start', ['start', '--runtime-root', root]);
  assert.equal(started.status, 'started'); activePid = started.pid;
  assert.equal(run('running-status', ['status', '--runtime-root', root]).status, 'running');

  await sleep(1400);
  assert.equal(lines(path.join(root, 'store/trajectory.jsonl')).length, 1,
    'receptive idle cycling must not manufacture trajectory events');
  assert.equal(fs.readdirSync(path.join(root, 'checkpoints')).length, 0,
    'receptive idle cycling must not manufacture checkpoints');

  const invalidResult = run('invalid-submit',
    ['submit', '--runtime-root', root, '--event', invalid], 1);
  assert.equal(invalidResult.status, 'rejected');

  fs.copyFileSync(invalid, path.join(root, 'inbox/direct-invalid.json'));
  await waitFor('direct invalid quarantine', () =>
    fs.readdirSync(path.join(root, 'rejected')).some(name => name.startsWith('direct-invalid.json')));
  assert.equal(fs.existsSync(path.join(root, 'inbox/direct-invalid.json')), false);

  assert.equal(run('submit-contact',
    ['submit', '--runtime-root', root, '--event', contact]).status, 'queued');
  const contactReceipt = await waitReceipt(root, 'input-unfamiliar-one');
  assert.equal(contactReceipt.standing, 'native-checkpointed');
  const checkpoint = path.join(root, 'checkpoints/active.term');
  const contactCheckpoint = fs.readFileSync(checkpoint, 'utf8');
  for (const required of [
    'constitutive-cut','balance-unfolding-as-intelligence','movement-primary',
    'dynamic-participatory-fourthness','immutable-fact-role',"'Balance'",
    'fact9-participation','flourishing-participation','generated-participation',
    'rap-readings','non-sovereign-same-movement','relatedness-reading',
    'appropriateness-reading','precision-reading','movement-unfamiliar-inquiry'
  ]) assert.match(contactCheckpoint, new RegExp(required));
  const contactHash = sha256(checkpoint);
  assert.equal(run('duplicate-contact',
    ['submit', '--runtime-root', root, '--event', contact]).status, 'duplicate');
  await sleep(500);
  assert.equal(sha256(checkpoint), contactHash, 'duplicate carrier must not advance cognition');

  assert.equal(run('submit-consequence',
    ['submit', '--runtime-root', root, '--event', consequence]).status, 'queued');
  const consequenceReceipt = await waitReceipt(root, 'input-consequence-one');
  assert.equal(consequenceReceipt.standing, 'native-checkpointed');
  const consequenceCheckpoint = fs.readFileSync(checkpoint, 'utf8');
  assert.match(consequenceCheckpoint, /consequence-incorporated/);
  assert.match(consequenceCheckpoint, /consequence-unfamiliar-one/);
  assert.match(consequenceCheckpoint, /same-becoming/);
  assert.notEqual(sha256(checkpoint), contactHash);
  const consequenceHash = sha256(checkpoint);

  assert.equal(run('stop', ['stop', '--runtime-root', root]).status, 'stopped'); activePid = 0;
  assert.equal(run('stopped-status', ['status', '--runtime-root', root]).status, 'stopped');
  const restarted = run('restart', ['start', '--runtime-root', root]);
  assert.equal(restarted.status, 'started'); activePid = restarted.pid;
  await sleep(1200);
  assert.equal(run('restarted-status', ['status', '--runtime-root', root]).status, 'running');
  assert.equal(sha256(checkpoint), consequenceHash,
    'restart without contact must preserve rather than manufacture a developmental cut');
  assert.equal(run('restart-duplicate-contact',
    ['submit', '--runtime-root', root, '--event', contact]).status, 'duplicate');
  assert.equal(fs.readdirSync(path.join(root, 'consumed')).filter(name => name.endsWith('.json')).length, 2);
  assert.equal(fs.readdirSync(path.join(root, 'outbox')).length, 0);

  assert.equal(run('evidence-export',
    ['evidence-bundle', '--runtime-root', root, '--output', exportPath]).status, 'evidence-stored');
  const exported = JSON.parse(fs.readFileSync(exportPath, 'utf8'));
  assert.equal(exported.network_access, 'none');
  assert.equal(exported.external_effects, 'none');
  assert.equal(exported.private_content_included, false);
  assert.equal(exported.semantic_health_claimed, false);
  assert.equal(exported.counts.outbox, 0);
  assert.equal(exported.trajectory.status, 'valid');

  assert.equal(run('panic', ['panic', '--runtime-root', root]).status, 'panicked'); activePid = 0;
  assert.equal(run('panic-status', ['status', '--runtime-root', root]).status, 'stopped');
  assert.equal(fs.existsSync(checkpoint), true);
  assert.equal(sha256(checkpoint), consequenceHash);

  const lkgRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-lkg-proof-'));
  assert.equal(run('lkg-bootstrap', ['bootstrap', '--runtime-root', lkgRoot]).status, 'bootstrapped');
  fs.appendFileSync(path.join(lkgRoot, 'service-entry.metta'), '\n; neutral-looking unpinned change\n');
  assert.equal(run('lkg-refusal', ['start', '--runtime-root', lkgRoot], 1).status, 'lkg-mismatch');

  const crashRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-crash-proof-'));
  assert.equal(run('crash-bootstrap', ['bootstrap', '--runtime-root', crashRoot]).status, 'bootstrapped');
  for (let cycle = 1; cycle <= 3; cycle++) {
    const crashStart = run(`crash-start-${cycle}`, ['start', '--runtime-root', crashRoot]);
    assert.equal(crashStart.status, 'started');
    killIsolated(crashStart.pid); await waitDead(crashStart.pid);
  }
  assert.equal(run('crash-contained', ['start', '--runtime-root', crashRoot], 1).status,
    'crash-loop-contained');
  const crashHistory = JSON.parse(fs.readFileSync(path.join(crashRoot, 'crash-history.json'), 'utf8'));
  assert.equal(crashHistory.crashes.length, 3);

  assert.equal(fs.existsSync(forbiddenRoot), false, 'no command may create ~/.miter');

  fs.mkdirSync(evidence, {recursive: true});
  fs.copyFileSync(exportPath, path.join(evidence, 'operator-evidence-bundle.json'));
  writeJson(path.join(evidence, 'commands.json'), runs);
  const sources = [
    'bin/miter','config/constitutive-projection-v1.json','config/miter-assistant-v1.json',
    'constitution/fact9_projection_v1.metta','src/constitutive_participation_v1.metta',
    'src/assistant_reactor_v1.metta','src/bootstrap_assistant_v1.metta',
    'effect_membranes/miter_assistant_service_v1.pl',
    'effect_membranes/miter_assistant_operator_v1.pl',
    'tests/fixtures/ama1_1/contact-unfamiliar.json',
    'tests/fixtures/ama1_1/consequence-unfamiliar.json',
    'tests/fixtures/ama1_1/contact-invalid.json'
  ].map(relative => ({path: relative, sha256: sha256(path.join(repo, relative))}));
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama11-service-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    explicit_runtime_root: root,
    crash_test_root: crashRoot,
    lkg_test_root: lkgRoot,
    external_network_calls: 0,
    model_calls: 0,
    private_memory_reads: 0,
    external_effects: 0,
    sources
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama11-service-freeze-verdict-v1',
    status: 'PASS-BOUNDED',
    facts: {
      explicit_root_only: true,
      forbidden_home_root_absent: true,
      continuously_receptive_process: true,
      idle_cycles_do_not_manufacture_trajectory: true,
      strict_transport_and_invalid_quarantine: true,
      constitutive_contact_checkpointed: true,
      balance_and_rap_participation_checkpointed: true,
      consequence_changes_next_cut: true,
      duplicate_input_suppressed: true,
      native_state_rehydrated_after_restart: true,
      panic_preserves_checkpoint_and_history: true,
      lkg_mismatch_refused: true,
      three_crash_window_contained: true,
      evidence_export_excludes_private_content: true
    },
    standing: 'Supported local process, transport, checkpoint, rehydration and supervision mechanics with a finite structured contact/consequence. No natural-language grounding, local effect descriptor, VoiceRNA, model/memory/PLN/NAL/tool re-entry, live service, or full AMA-1.1 closure is claimed.',
    next_boundary: 'Connect bounded participants, VoiceRNA and a no-network local effect descriptor through this same running process.'
  });
  console.log(JSON.stringify({status: 'PASS-BOUNDED', evidence}));
} finally {
  if (activePid) spawnSync(operator, ['panic', '--runtime-root', root], {cwd: repo, encoding: 'utf8'});
}
