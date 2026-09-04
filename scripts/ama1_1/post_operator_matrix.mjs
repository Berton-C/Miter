// Builder-side post-operator constitutive matrix. It applies only the generic
// JSON operations frozen in post-operator-cases.json and observes the supported
// assistant; it is never imported by Miter and performs no semantic selection.
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const manifestPath = path.join(repo, 'tests/fixtures/ama1_1/post-operator-cases.json');
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/post-operator-matrix-001');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const normalize = text => text.replace(/[^A-Za-z0-9_-]+/g, '.');
const results = [];
const commands = [];
const roots = new Map();
const stimuli = new Map();

function writeJson(file, value) { fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`); }
function clone(value) { return JSON.parse(JSON.stringify(value)); }
function components(pointer) {
  if (!pointer.startsWith('/')) throw Error(`invalid JSON pointer: ${pointer}`);
  return pointer.slice(1).split('/').map(x => x.replaceAll('~1', '/').replaceAll('~0', '~'));
}
function locate(document, pointer) {
  const parts = components(pointer); const key = parts.pop();
  let parent = document;
  for (const part of parts) {
    if (!(part in parent)) throw Error(`missing JSON pointer segment: ${pointer}`);
    parent = parent[part];
  }
  return {parent, key};
}
function apply(document, operation) {
  const {parent, key} = locate(document, operation.path);
  if (operation.op === 'set') parent[key] = clone(operation.value);
  else if (operation.op === 'remove') {
    if (Array.isArray(parent)) parent.splice(Number(key), 1); else delete parent[key];
  } else if (operation.op === 'reverse') {
    if (!Array.isArray(parent[key])) throw Error(`reverse target is not an array: ${operation.path}`);
    parent[key].reverse();
  } else throw Error(`unknown generic operation: ${operation.op}`);
}
function run(name, args) {
  const value = spawnSync(operator, args, {cwd: repo, encoding: 'utf8', timeout: 15000});
  commands.push({name, args, status: value.status, signal: value.signal,
    stdout: value.stdout, stderr: value.stderr});
  let reply = null;
  try { reply = JSON.parse(value.stdout); } catch {}
  return {code: value.status, signal: value.signal, stderr: value.stderr, reply};
}
async function waitCheckpoint(root, inputId, timeout = 8000) {
  const receipt = path.join(root, 'receipts', `${inputId}.json`);
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (fs.existsSync(receipt)) {
      const value = JSON.parse(fs.readFileSync(receipt, 'utf8'));
      if (value.standing === 'native-checkpointed') return true;
    }
    await sleep(50);
  }
  return false;
}
function observe(root) {
  const checkpointPath = path.join(root, 'checkpoints/active.term');
  const checkpoint = fs.existsSync(checkpointPath) ? fs.readFileSync(checkpointPath, 'utf8') : '';
  const outbox = fs.readdirSync(path.join(root, 'outbox')).filter(x => x.endsWith('.json')).sort();
  return {checkpoint, normalized: normalize(checkpoint), outbox,
    checkpoint_sha256: checkpoint ? fileHash(checkpointPath) : null};
}

if (fs.existsSync(evidence)) throw Error('matrix evidence is immutable once recorded');
if (manifest.schema !== 'miter-ama11-post-operator-cases-v1') throw Error('case schema');
if (checkOpen(plan).status !== 'OPEN-PACKAGE-VALID') throw Error('phase package is not open');
if (fileHash(path.join(repo, manifest.base_fixture.path)) !== manifest.base_fixture.sha256) throw Error('base fixture changed');
if (fileHash(path.join(repo, manifest.consequence_fixture.path)) !== manifest.consequence_fixture.sha256) throw Error('consequence fixture changed');
for (const [relative, expected] of Object.entries(manifest.implementation_pins)) {
  if (fileHash(path.join(repo, relative)) !== expected) throw Error(`post-disclosure implementation change: ${relative}`);
}
execFileSync('git', ['merge-base', '--is-ancestor', manifest.frozen_against_commit, 'HEAD'],
  {cwd: repo, encoding: 'utf8'});

const base = JSON.parse(fs.readFileSync(path.join(repo, manifest.base_fixture.path), 'utf8'));
const consequence = path.join(repo, manifest.consequence_fixture.path);

for (const testCase of manifest.cases) {
  const failures = [];
  const root = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama11-matrix-${testCase.id}-`));
  const stimulusRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama11-stimulus-${testCase.id}-`));
  roots.set(testCase.id, root);
  const stimulus = clone(base);
  for (const operation of testCase.operations) apply(stimulus, operation);
  const stimulusPath = path.join(stimulusRoot, 'stimulus.json');
  writeJson(stimulusPath, stimulus);
  stimuli.set(testCase.id, stimulusPath);

  const bootstrap = run(`${testCase.id}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  if (bootstrap.code !== 0 || bootstrap.reply?.status !== 'bootstrapped') failures.push('bootstrap failed');
  const start = run(`${testCase.id}:start`, ['start', '--runtime-root', root]);
  let active = start.code === 0 && start.reply?.status === 'started';
  if (!active) failures.push('start failed');
  const submit = run(`${testCase.id}:submit`, ['submit', '--runtime-root', root, '--event', stimulusPath]);
  if (submit.reply?.status !== testCase.expected_submit) {
    failures.push(`submit standing ${submit.reply?.status ?? 'unreadable'} != ${testCase.expected_submit}`);
  }
  if (testCase.expected_submit === 'queued') {
    if (!await waitCheckpoint(root, stimulus.input_id)) failures.push('native checkpoint not reached');
  } else await sleep(150);

  let observed = observe(root);
  if (observed.outbox.length !== testCase.expected_outbox) {
    failures.push(`outbox count ${observed.outbox.length} != ${testCase.expected_outbox}`);
  }
  for (const required of testCase.require) {
    if (!observed.normalized.includes(required)) failures.push(`missing ${required}`);
  }
  for (const forbidden of testCase.forbid) {
    if (observed.normalized.includes(forbidden)) failures.push(`forbidden ${forbidden}`);
  }

  let sequence = null;
  if (testCase.restart_and_consequence && observed.checkpoint) {
    const before = {checkpoint: observed.checkpoint_sha256,
      effect: observed.outbox.length === 1 ? fileHash(path.join(root, 'outbox', observed.outbox[0])) : null};
    const stop = run(`${testCase.id}:stop`, ['stop', '--runtime-root', root]); active = false;
    if (stop.code !== 0 || stop.reply?.status !== 'stopped') failures.push('clean stop failed');
    const restart = run(`${testCase.id}:restart`, ['start', '--runtime-root', root]);
    active = restart.code === 0 && restart.reply?.status === 'started';
    if (!active) failures.push('restart failed');
    await sleep(700);
    const afterRestart = observe(root);
    if (afterRestart.checkpoint_sha256 !== before.checkpoint) failures.push('restart manufactured or changed cut');
    if (afterRestart.outbox.length !== 1 || fileHash(path.join(root, 'outbox', afterRestart.outbox[0])) !== before.effect) {
      failures.push('restart replayed or changed local effect');
    }
    const returned = run(`${testCase.id}:consequence`, ['submit', '--runtime-root', root, '--event', consequence]);
    if (returned.reply?.status !== 'queued') failures.push('consequence not queued');
    if (!await waitCheckpoint(root, 'input-consequence-one')) failures.push('consequence checkpoint not reached');
    observed = observe(root);
    if (observed.checkpoint_sha256 === before.checkpoint) failures.push('consequence did not change next cut');
    if (!observed.normalized.includes('consequence-incorporated')) failures.push('consequence standing absent');
    if (observed.outbox.length !== 1) failures.push('consequence fabricated an effect');
    sequence = {before, after_restart: afterRestart.checkpoint_sha256,
      after_consequence: observed.checkpoint_sha256};
  }

  if (active) run(`${testCase.id}:panic`, ['panic', '--runtime-root', root]);
  results.push({id: testCase.id, claim: testCase.claim,
    stimulus_sha256: fileHash(stimulusPath), submit_status: submit.reply?.status ?? null,
    checkpoint_sha256: observed.checkpoint_sha256, outbox_count: observed.outbox.length,
    sequence, status: failures.length ? 'FAIL' : 'PASS', failures});
}

const allFailures = results.flatMap(result => result.failures.map(failure => `${result.id}: ${failure}`));
const status = allFailures.length ? 'FAIL-CONSTITUTIVE' : 'PASS-BOUNDED';
fs.mkdirSync(path.join(evidence, 'raw'), {recursive: true});
for (const result of results) {
  const root = roots.get(result.id); const target = path.join(evidence, 'raw', result.id);
  fs.mkdirSync(target, {recursive: true});
  fs.copyFileSync(stimuli.get(result.id), path.join(target, 'stimulus.json'));
  for (const [source, name] of [
    ['checkpoints/active.term', 'checkpoint.term'],
    ['checkpoints/active.json', 'checkpoint.json'],
    ['outbox/contact-unfamiliar-one.json', 'outbox.json']
  ]) if (fs.existsSync(path.join(root, source))) fs.copyFileSync(path.join(root, source), path.join(target, name));
}
writeJson(path.join(evidence, 'results.json'), {schema: 'miter-ama11-post-operator-results-v1', status, results});
writeJson(path.join(evidence, 'commands.json'), commands);
writeJson(path.join(evidence, 'runtime.json'), {
  schema: 'miter-ama11-post-operator-runtime-v1',
  swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
  petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  manifest_sha256: fileHash(manifestPath),
  implementation_pins: manifest.implementation_pins,
  external_network_calls: 0, model_calls: 0, private_memory_reads: 0, external_effects: 0
});
writeJson(path.join(evidence, 'verdict.json'), {
  schema: 'miter-ama11-post-operator-verdict-v1', status,
  passed: results.filter(x => x.status === 'PASS').map(x => x.id),
  failed: results.filter(x => x.status === 'FAIL').map(x => ({id: x.id, failures: x.failures})),
  standing: status === 'PASS-BOUNDED'
    ? 'The disclosed finite constitutive matrix passed through the supported service; this remains bounded structured evidence, not general semantic sufficiency.'
    : 'The disclosed matrix found a constitutive mismatch. No AMA-1.1 closure or semantic fidelity is claimed; operator meaning must not be changed under this frozen case set without preserving this result and opening an explicit repair plan.',
  no_live_or_private_reach: true
});
console.log(JSON.stringify({status, evidence, failures: allFailures}));
if (allFailures.length) process.exitCode = 1;
