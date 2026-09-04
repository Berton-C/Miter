// Builder-side replay of the unchanged AMA-1.1 post-operator matrix after the
// explicitly re-frozen RR-001 constitutive standing repair. This harness is
// never imported by Miter and performs no semantic selection.
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const manifestPath = path.join(repo, 'tests/fixtures/ama1_1/post-operator-cases.json');
const refreezePath = path.join(repo,
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/repair-refreeze-001.json');
const predecessorVerdict = path.join(repo,
  'evidence/AMA-1.1/R1/post-operator-matrix-001/verdict.json');
const predecessorResults = path.join(repo,
  'evidence/AMA-1.1/R1/post-operator-matrix-001/results.json');
const repairedSource = path.join(repo, 'src/constitutive_participation_v1.metta');
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/post-operator-repair-001');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const expectedManifestHash = '6d2033ae3cd4c63faee2f614c4c5bbc6fd3ff8a755d234fd0039fb422b3661d1';
const expectedRefreezeHash = '90ce6ea3bf665113fb901b10a823b1bf879b3c4404bf037bc62250678c65a8cf';
const expectedVerdictHash = '3f6064508ad69fa5e2e46924480a5b84d8152180cc5f6890ab342f6b15f9fb54';
const expectedResultsHash = '8cba189a8561d86db0afbd1a9e44c9cca6b770cbd06ad4ec8feee7aa39a25cb8';
const expectedRepairedSourceHash = 'c6a5b93ec64bcc18c88e920b1d8ff695deee2b2e2aa8333899707b1a3cada7a3';
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const refreeze = JSON.parse(fs.readFileSync(refreezePath, 'utf8'));
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
  const parts = components(pointer);
  const key = parts.pop();
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
    if (Array.isArray(parent)) parent.splice(Number(key), 1);
    else delete parent[key];
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

if (fs.existsSync(evidence)) throw Error('repair evidence is immutable once recorded');
if (manifest.schema !== 'miter-ama11-post-operator-cases-v1') throw Error('case schema');
if (refreeze.schema !== 'miter-campaign-repair-refreeze-v1' || refreeze.repair !== 'RR-001') {
  throw Error('repair re-freeze schema');
}
if (checkOpen(plan).status !== 'OPEN-PACKAGE-VALID') throw Error('phase package is not open');
if (fileHash(manifestPath) !== expectedManifestHash) throw Error('frozen case matrix changed');
if (fileHash(refreezePath) !== expectedRefreezeHash) throw Error('repair re-freeze changed');
if (fileHash(predecessorVerdict) !== expectedVerdictHash) throw Error('predecessor verdict changed');
if (fileHash(predecessorResults) !== expectedResultsHash) throw Error('predecessor results changed');
if (fileHash(repairedSource) !== expectedRepairedSourceHash) throw Error('RR-001 source changed after replay freeze');
if (fileHash(path.join(repo, manifest.base_fixture.path)) !== manifest.base_fixture.sha256) {
  throw Error('base fixture changed');
}
if (fileHash(path.join(repo, manifest.consequence_fixture.path)) !== manifest.consequence_fixture.sha256) {
  throw Error('consequence fixture changed');
}
for (const [relative, expected] of Object.entries(manifest.implementation_pins)) {
  if (relative === 'src/constitutive_participation_v1.metta') continue;
  if (fileHash(path.join(repo, relative)) !== expected) throw Error(`preserved implementation changed: ${relative}`);
}
execFileSync('git', ['merge-base', '--is-ancestor', refreeze.predecessor.commit, 'HEAD'],
  {cwd: repo, encoding: 'utf8'});

const base = JSON.parse(fs.readFileSync(path.join(repo, manifest.base_fixture.path), 'utf8'));
const consequence = path.join(repo, manifest.consequence_fixture.path);

for (const testCase of manifest.cases) {
  const failures = [];
  const root = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama11-repair-${testCase.id}-`));
  const stimulusRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama11-repair-stimulus-${testCase.id}-`));
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
    const stop = run(`${testCase.id}:stop`, ['stop', '--runtime-root', root]);
    active = false;
    if (stop.code !== 0 || stop.reply?.status !== 'stopped') failures.push('clean stop failed');
    const restart = run(`${testCase.id}:restart`, ['start', '--runtime-root', root]);
    active = restart.code === 0 && restart.reply?.status === 'started';
    if (!active) failures.push('restart failed');
    await sleep(700);
    const afterRestart = observe(root);
    if (afterRestart.checkpoint_sha256 !== before.checkpoint) failures.push('restart manufactured or changed cut');
    if (afterRestart.outbox.length !== 1 ||
        fileHash(path.join(root, 'outbox', afterRestart.outbox[0])) !== before.effect) {
      failures.push('restart replayed or changed local effect');
    }
    const returned = run(`${testCase.id}:consequence`,
      ['submit', '--runtime-root', root, '--event', consequence]);
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
  const root = roots.get(result.id);
  const target = path.join(evidence, 'raw', result.id);
  fs.mkdirSync(target, {recursive: true});
  fs.copyFileSync(stimuli.get(result.id), path.join(target, 'stimulus.json'));
  for (const [source, name] of [
    ['checkpoints/active.term', 'checkpoint.term'],
    ['checkpoints/active.json', 'checkpoint.json'],
    ['outbox/contact-unfamiliar-one.json', 'outbox.json']
  ]) {
    if (fs.existsSync(path.join(root, source))) {
      fs.copyFileSync(path.join(root, source), path.join(target, name));
    }
  }
}
writeJson(path.join(evidence, 'results.json'), {
  schema: 'miter-ama11-post-operator-repair-results-v1', repair: 'RR-001', status, results
});
writeJson(path.join(evidence, 'commands.json'), commands);
writeJson(path.join(evidence, 'runtime.json'), {
  schema: 'miter-ama11-post-operator-repair-runtime-v1',
  repair: 'RR-001',
  swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
  petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  manifest_sha256: fileHash(manifestPath),
  repair_refreeze_sha256: fileHash(refreezePath),
  repaired_source_sha256: fileHash(repairedSource),
  preserved_implementation_pins: Object.fromEntries(
    Object.entries(manifest.implementation_pins)
      .filter(([relative]) => relative !== 'src/constitutive_participation_v1.metta')),
  external_network_calls: 0,
  model_calls: 0,
  private_memory_reads: 0,
  external_effects: 0
});
writeJson(path.join(evidence, 'verdict.json'), {
  schema: 'miter-ama11-post-operator-repair-verdict-v1', repair: 'RR-001', status,
  predecessor_status: 'FAIL-CONSTITUTIVE',
  passed: results.filter(x => x.status === 'PASS').map(x => x.id),
  failed: results.filter(x => x.status === 'FAIL').map(x => ({id: x.id, failures: x.failures})),
  standing: status === 'PASS-BOUNDED'
    ? 'All twelve unchanged disclosed cases passed through the supported service after the explicitly re-frozen RR-001 standing and totality repair. This is bounded structured evidence, not general semantic sufficiency or full AMA-1.1 closure.'
    : 'The unchanged disclosed matrix still finds a constitutive mismatch. RR-001 is not admitted and no AMA-1.1 closure is claimed.',
  no_live_or_private_reach: true
});
console.log(JSON.stringify({status, evidence, failures: allFailures}));
if (allFailures.length) process.exitCode = 1;
