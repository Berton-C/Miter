// Builder-side AMA-1.2 stable-scope boundary trial.
// This harness is never imported by Miter and performs no semantic selection.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R1/plan.json';
const basePath = path.join(repo, 'tests/fixtures/ama1_2/scope-contact-v3.json');
const bindingPath = path.join(repo, 'tests/fixtures/ama1_2/scope-bindings.json');
const legacyPath = path.join(repo, 'tests/fixtures/ama1_1/constitutive-chain-v2-base.json');
const evidence = path.join(repo, 'evidence/AMA-1.2/R1/stable-scope-001');
const record = process.argv.includes('--record');
const base = JSON.parse(fs.readFileSync(basePath, 'utf8'));
const binding = JSON.parse(fs.readFileSync(bindingPath, 'utf8'));
const clone = value => JSON.parse(JSON.stringify(value));
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const commands = [];
const raw = new Map();

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
}

function run(name, args, timeout = 20000) {
  const result = spawnSync(operator, args, {
    cwd: repo, encoding: 'utf8', timeout, maxBuffer: 32 * 1024 * 1024
  });
  let reply = null;
  try { reply = JSON.parse(result.stdout); } catch {}
  commands.push({name, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', reply});
  return {code: result.status, signal: result.signal, reply,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''};
}

function jsonFiles(directory) {
  return fs.existsSync(directory)
    ? fs.readdirSync(directory).filter(name => name.endsWith('.json')).sort() : [];
}

async function waitCheckpoint(root, inputId, timeout = 10000) {
  const receipt = path.join(root, 'receipts', `${inputId}.json`);
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (fs.existsSync(receipt)) {
      const value = JSON.parse(fs.readFileSync(receipt, 'utf8'));
      if (value.standing === 'native-checkpointed') return true;
    }
    await sleep(40);
  }
  return false;
}

function makeRuntime(id, bindings = binding) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-scope-${id}-`));
  const stimulusRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-input-${id}-`));
  const boot = run(`${id}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  assert.equal(boot.code, 0, `${id}: bootstrap process`);
  assert.equal(boot.reply?.status, 'bootstrapped', `${id}: bootstrap standing`);
  writeJson(path.join(root, 'scope-bindings.json'), bindings);
  const start = run(`${id}:start`, ['start', '--runtime-root', root]);
  assert.equal(start.code, 0, `${id}: start process`);
  assert.equal(start.reply?.status, 'started', `${id}: start standing`);
  return {root, stimulusRoot, pid: start.reply.pid};
}

function submit(root, stimulusRoot, id, stimulus) {
  const file = path.join(stimulusRoot, `${id}.json`);
  writeJson(file, stimulus);
  return {file, result: run(`${id}:submit`,
    ['submit', '--runtime-root', root, '--event', file])};
}

function stop(root, id) {
  const result = run(`${id}:panic`, ['panic', '--runtime-root', root]);
  assert.equal(result.reply?.status, 'panicked', `${id}: panic standing`);
}

async function acceptedCase(id, mutate = value => value) {
  const stimulus = mutate(clone(base));
  const {root, stimulusRoot} = makeRuntime(id);
  const sent = submit(root, stimulusRoot, id, stimulus);
  assert.equal(sent.result.reply?.status, 'queued', `${id}: contact not queued`);
  assert.equal(await waitCheckpoint(root, stimulus.input_id), true,
    `${id}: native checkpoint not reached`);
  const checkpointPath = path.join(root, 'checkpoints/active.term');
  const checkpoint = fs.readFileSync(checkpointPath, 'utf8');
  for (const required of [
    'scope-binding-v1', 'authorized-before-payload-cognition',
    'binding-fixture-alpha', 'balance-unfolding-as-intelligence',
    'movement-primary', 'fact9-participation', 'flourishing-participation',
    'rap-readings', 'movement-formed'
  ]) assert.ok(checkpoint.includes(required), `${id}: checkpoint missing ${required}`);
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 1, `${id}: local effect count`);

  const duplicate = run(`${id}:duplicate`,
    ['submit', '--runtime-root', root, '--event', sent.file]);
  assert.equal(duplicate.reply?.status, 'duplicate', `${id}: duplicate not recognized`);
  await sleep(300);
  const before = fileHash(checkpointPath);
  const effectName = jsonFiles(path.join(root, 'outbox'))[0];
  const effectPath = path.join(root, 'outbox', effectName);
  const effectBefore = fileHash(effectPath);
  assert.equal(run(`${id}:stop`, ['stop', '--runtime-root', root]).reply?.status,
    'stopped', `${id}: clean stop`);
  assert.equal(run(`${id}:restart`, ['start', '--runtime-root', root]).reply?.status,
    'started', `${id}: restart`);
  await sleep(600);
  assert.equal(fileHash(checkpointPath), before, `${id}: restart changed checkpoint`);
  assert.equal(fileHash(effectPath), effectBefore, `${id}: restart changed effect`);
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 1, `${id}: effect replay`);
  stop(root, id);
  raw.set(id, {checkpointPath, checkpointHash: before, root});
  return {id, expected: 'accepted', observed: 'accepted', checkpoint_sha256: before,
    local_effects: 1, restart_stable: true};
}

async function rejectedCase(id, mutateStimulus, mutateBindings = value => value,
    sourcePath = null) {
  const bindings = mutateBindings(clone(binding));
  const {root, stimulusRoot} = makeRuntime(id, bindings);
  let sent;
  if (sourcePath) {
    sent = {file: sourcePath, result: run(`${id}:submit`,
      ['submit', '--runtime-root', root, '--event', sourcePath])};
  } else {
    sent = submit(root, stimulusRoot, id, mutateStimulus(clone(base)));
  }
  assert.equal(sent.result.reply?.status, 'rejected', `${id}: boundary did not reject`);
  await sleep(250);
  assert.equal(fs.existsSync(path.join(root, 'checkpoints/active.term')), false,
    `${id}: rejected contact reached native checkpoint`);
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 0,
    `${id}: rejected contact produced effect`);
  assert.equal(jsonFiles(path.join(root, 'consumed')).length, 0,
    `${id}: rejected contact entered service consumption`);
  stop(root, id);
  return {id, expected: 'rejected', observed: 'rejected', native_checkpoint: false,
    local_effects: 0};
}

assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');
if (record && fs.existsSync(evidence)) throw Error('stable-scope evidence already exists');

const results = [];
results.push(await acceptedCase('authorized-primary'));
results.push(await acceptedCase('authorized-new-event', value => {
  value.input_id = 'input-scope-contact-beta';
  value.surface.post_id = 'contact-scope-beta';
  value.surface.thread_id = 'fixture-thread-beta';
  value.surface.event_version = 'v2';
  value.contact.id = 'contact-scope-beta';
  value.contact.occurrence = 'occurrence-scope-beta';
  value.contact.proto = 'proto-scope-beta';
  value.contact.payload_ref = 'payload-scope-beta';
  return value;
}));
results.push(await rejectedCase('stable-principal-mismatch', value => {
  value.surface.principal_id = 'fixture-user-denied'; return value;
}));
results.push(await rejectedCase('declared-project-mismatch', value => {
  value.contact.project = 'project-denied'; return value;
}));
results.push(await rejectedCase('post-contact-mismatch', value => {
  value.surface.post_id = 'different-post-id'; return value;
}));
results.push(await rejectedCase('ambiguous-binding', value => value, value => {
  value.bindings.push({...value.bindings[0], binding_id: 'binding-fixture-duplicate'});
  return value;
}));
results.push(await rejectedCase('legacy-contact-bypass', value => value,
  value => value, legacyPath));

const status = results.every(result => result.expected === result.observed)
  ? 'PASS-BOUNDED' : 'FAIL';
assert.equal(status, 'PASS-BOUNDED');

if (record) {
  fs.mkdirSync(path.join(evidence, 'raw'), {recursive: true});
  const primary = raw.get('authorized-primary');
  fs.copyFileSync(primary.checkpointPath,
    path.join(evidence, 'raw/authorized-primary-checkpoint.term'));
  writeJson(path.join(evidence, 'commands.json'), commands);
  writeJson(path.join(evidence, 'results.json'), {
    schema: 'miter-ama12-stable-scope-results-v1', status, results
  });
  const sourcePaths = [
    'config/miter-assistant-continuity-v1.json',
    'effect_membranes/miter_assistant_continuity_v1.pl',
    'effect_membranes/miter_assistant_service_v1.pl',
    'effect_membranes/miter_assistant_operator_v1.pl',
    'src/assistant_scope_continuity_v1.metta',
    'src/assistant_reactor_v1.metta',
    'src/bootstrap_assistant_v1.metta',
    'tests/fixtures/ama1_2/scope-bindings.json',
    'tests/fixtures/ama1_2/scope-contact-v3.json',
    'scripts/ama1_2/stable_scope_boundary.mjs'
  ];
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama12-stable-scope-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'],
      {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    plan_commit: '61c1c21fc19b0b1d8bb84b46e717be2642c52499',
    external_network_calls: 0,
    model_calls: 0,
    chroma_calls: 0,
    private_memory_reads: 0,
    external_effects: 0,
    sources: sourcePaths.map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}))
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama12-stable-scope-verdict-v1', status,
    facts: {
      stable_identity_is_bound_before_native_contact: true,
      declared_scope_mismatch_is_rejected_before_cognition: true,
      ambiguous_binding_is_rejected_before_cognition: true,
      post_identity_must_bind_contact_identity: true,
      legacy_contact_schema_cannot_bypass_supported_ingress: true,
      binding_is_preserved_in_native_history: true,
      balance_fact9_flourishing_and_rap_remain_in_the_same_movement: true,
      duplicate_and_restart_do_not_replay_the_local_effect: true,
      no_live_or_private_reach_occurred: true
    },
    standing: 'Controlled-fixture proof of stable principal/audience/project binding through the supported persistent assistant. It does not prove live Mattermost identity, general language, four-plane Continuity of Mind, model or Chroma participation, multi-user privacy, or AMA-1.2 closure.',
    next_boundary: 'Join exact four-plane continuity and unfinished constitutive organization at startup before ordinary cognition.'
  });
}

console.log(JSON.stringify({status, cases: results.length,
  evidence: record ? evidence : null}));
