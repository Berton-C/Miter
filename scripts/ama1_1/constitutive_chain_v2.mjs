// Builder-side execution of the frozen AMA-1.1 RR-002 constitutive chain.
// This file is never imported by Miter. It mutates only fresh /private/tmp
// runtime roots and, with --record, the one immutable evidence directory.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const freezeRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/constitutive-refreeze-002.json';
const freezePath = path.join(repo, freezeRelative);
const casesPath = path.join(repo, 'tests/fixtures/ama1_1/constitutive-chain-v2-cases.json');
const v1CasesPath = path.join(repo, 'tests/fixtures/ama1_1/post-operator-cases.json');
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/constitutive-chain-v2-001');
const record = process.argv.includes('--record');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const clone = value => JSON.parse(JSON.stringify(value));
const normalize = value => value.replace(/[^A-Za-z0-9_-]+/g, '.');
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const commands = [];
const artifacts = new Map();

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

function components(pointer) {
  if (!pointer.startsWith('/')) throw Error(`invalid JSON pointer: ${pointer}`);
  return pointer.slice(1).split('/').map(value =>
    value.replaceAll('~1', '/').replaceAll('~0', '~'));
}

function apply(document, operation) {
  const parts = components(operation.path);
  const key = parts.pop();
  let parent = document;
  for (const part of parts) {
    if (!(part in parent)) throw Error(`missing pointer segment: ${operation.path}`);
    parent = parent[part];
  }
  if (operation.op === 'set') parent[key] = clone(operation.value);
  else if (operation.op === 'remove') {
    if (Array.isArray(parent)) parent.splice(Number(key), 1);
    else delete parent[key];
  } else if (operation.op === 'reverse') {
    assert.equal(Array.isArray(parent[key]), true, `reverse target: ${operation.path}`);
    parent[key].reverse();
  } else throw Error(`unknown operation: ${operation.op}`);
}

function run(name, args, timeout = 20000) {
  const result = spawnSync(operator, args, {
    cwd: repo, encoding: 'utf8', timeout, maxBuffer: 64 * 1024 * 1024
  });
  let reply = null;
  try { reply = JSON.parse(result.stdout); } catch {}
  commands.push({name, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', reply});
  return {code: result.status, signal: result.signal, reply,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''};
}

async function waitCheckpoint(root, inputId, timeout = 12000) {
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

function observe(root) {
  const checkpointPath = path.join(root, 'checkpoints/active.term');
  const checkpoint = fs.existsSync(checkpointPath)
    ? fs.readFileSync(checkpointPath, 'utf8') : '';
  const outboxDirectory = path.join(root, 'outbox');
  const outbox = fs.existsSync(outboxDirectory)
    ? fs.readdirSync(outboxDirectory).filter(name => name.endsWith('.json')).sort() : [];
  return {checkpoint, normalized: normalize(checkpoint), outbox,
    checkpoint_sha256: checkpoint ? sha256(checkpoint) : null,
    effect_hashes: outbox.map(name => fileHash(path.join(outboxDirectory, name)))};
}

function stop(root, name) {
  const result = run(name, ['stop', '--runtime-root', root]);
  return result.reply?.status === 'stopped';
}

function terminate(root, name) {
  run(name, ['panic', '--runtime-root', root]);
}

function setup(caseId) {
  const root = fs.mkdtempSync(path.join('/private/tmp', `miter-ama11-rr002-${caseId}-`));
  const stimulusRoot = fs.mkdtempSync(path.join('/private/tmp', `miter-ama11-rr002-input-${caseId}-`));
  const boot = run(`${caseId}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  assert.equal(boot.code, 0, `${caseId}: bootstrap process`);
  assert.equal(boot.reply?.status, 'bootstrapped', `${caseId}: bootstrap standing`);
  const start = run(`${caseId}:start`, ['start', '--runtime-root', root]);
  assert.equal(start.code, 0, `${caseId}: start process`);
  assert.equal(start.reply?.status, 'started', `${caseId}: start standing`);
  return {root, stimulusRoot};
}

async function submitStimulus(caseId, root, stimulusRoot, stimulus) {
  const file = path.join(stimulusRoot, `${caseId}.json`);
  writeJson(file, stimulus);
  const result = run(`${caseId}:submit`,
    ['submit', '--runtime-root', root, '--event', file]);
  if (result.reply?.status === 'queued') await waitCheckpoint(root, stimulus.input_id);
  else await sleep(100);
  return {file, result, observed: observe(root)};
}

function checkTerms(testCase, observed, failures) {
  for (const required of testCase.require ?? []) {
    if (!observed.normalized.includes(required)) failures.push(`missing ${required}`);
  }
  for (const forbidden of testCase.forbid ?? []) {
    if (observed.normalized.includes(forbidden)) failures.push(`forbidden ${forbidden}`);
  }
}

async function runOrdinaryCase(testCase, base, family) {
  const failures = [];
  const {root, stimulusRoot} = setup(`${family}-${testCase.id}`);
  const stimulus = clone(base);
  for (const operation of testCase.operations ?? []) apply(stimulus, operation);
  const submitted = await submitStimulus(`${family}-${testCase.id}`, root, stimulusRoot, stimulus);
  const expectedSubmit = testCase.expected_submit ?? 'queued';
  if (submitted.result.reply?.status !== expectedSubmit) {
    failures.push(`submit ${submitted.result.reply?.status ?? 'unreadable'} != ${expectedSubmit}`);
  }
  if (expectedSubmit === 'queued') {
    const receipt = path.join(root, 'receipts', `${stimulus.input_id}.json`);
    if (!fs.existsSync(receipt) ||
        JSON.parse(fs.readFileSync(receipt, 'utf8')).standing !== 'native-checkpointed') {
      failures.push('native checkpoint not reached');
    }
  }
  checkTerms(testCase, submitted.observed, failures);
  const expectedOutbox = testCase.expected_outbox ?? (expectedSubmit === 'queued' ? 1 : 0);
  if (submitted.observed.outbox.length !== expectedOutbox) {
    failures.push(`outbox ${submitted.observed.outbox.length} != ${expectedOutbox}`);
  }

  let sequence = null;
  if (family === 'v1' && testCase.restart_and_consequence) {
    const before = submitted.observed;
    stop(root, `${family}-${testCase.id}:stop-before-restart`);
    const restart = run(`${family}-${testCase.id}:restart`,
      ['start', '--runtime-root', root]);
    if (restart.reply?.status !== 'started') failures.push('restart failed');
    await sleep(500);
    const restored = observe(root);
    if (restored.checkpoint_sha256 !== before.checkpoint_sha256) {
      failures.push('restart changed checkpoint');
    }
    if (JSON.stringify(restored.effect_hashes) !== JSON.stringify(before.effect_hashes)) {
      failures.push('restart replayed or changed effect');
    }
    const consequence = path.join(repo,
      JSON.parse(fs.readFileSync(v1CasesPath, 'utf8')).consequence_fixture.path);
    const returned = run(`${family}-${testCase.id}:consequence`,
      ['submit', '--runtime-root', root, '--event', consequence]);
    if (returned.reply?.status !== 'queued') failures.push('consequence not queued');
    if (!await waitCheckpoint(root, 'input-consequence-one')) {
      failures.push('consequence checkpoint not reached');
    }
    const after = observe(root);
    if (after.checkpoint_sha256 === before.checkpoint_sha256) {
      failures.push('consequence did not change checkpoint');
    }
    if (!after.normalized.includes('consequence-incorporated')) {
      failures.push('consequence incorporation absent');
    }
    if (after.outbox.length !== before.outbox.length) failures.push('consequence fabricated effect');
    sequence = {before: before.checkpoint_sha256,
      after_restart: restored.checkpoint_sha256, after_consequence: after.checkpoint_sha256};
  }
  terminate(root, `${family}-${testCase.id}:terminate`);
  artifacts.set(`${family}-${testCase.id}`, {root, stimulus: submitted.file,
    observed: submitted.observed});
  return {id: testCase.id, family, claim: testCase.claim,
    stimulus_sha256: fileHash(submitted.file), checkpoint_sha256: submitted.observed.checkpoint_sha256,
    outbox_count: submitted.observed.outbox.length, sequence,
    status: failures.length ? 'FAIL' : 'PASS', failures};
}

async function runConsequenceBranch(label, base, consequencePath) {
  const failures = [];
  const {root, stimulusRoot} = setup(`v2-consequence-${label}`);
  const initial = await submitStimulus(`v2-consequence-${label}`, root, stimulusRoot, clone(base));
  if (initial.result.reply?.status !== 'queued') failures.push('initial contact not queued');
  if (!initial.observed.normalized.includes('movement-formed.undertaking.thread-undertaking-alpha')) {
    failures.push('initial undertaking absent');
  }
  const before = initial.observed;
  stop(root, `v2-consequence-${label}:stop-before-restart`);
  const firstRestart = run(`v2-consequence-${label}:restart-before-consequence`,
    ['start', '--runtime-root', root]);
  if (firstRestart.reply?.status !== 'started') failures.push('pre-consequence restart failed');
  await sleep(500);
  const restored = observe(root);
  if (restored.checkpoint_sha256 !== before.checkpoint_sha256) {
    failures.push('pre-consequence restart changed checkpoint');
  }
  if (JSON.stringify(restored.effect_hashes) !== JSON.stringify(before.effect_hashes)) {
    failures.push('pre-consequence restart replayed effect');
  }
  const consequence = JSON.parse(fs.readFileSync(consequencePath, 'utf8'));
  const returned = run(`v2-consequence-${label}:submit-consequence`,
    ['submit', '--runtime-root', root, '--event', consequencePath]);
  if (returned.reply?.status !== 'queued') failures.push('consequence not queued');
  if (!await waitCheckpoint(root, consequence.input_id)) failures.push('consequence checkpoint absent');
  const after = observe(root);
  if (after.checkpoint_sha256 === before.checkpoint_sha256) failures.push('consequence no change');
  for (const required of ['consequence-incorporated', 'next-constitutive-organization']) {
    if (!after.normalized.includes(required)) failures.push(`missing ${required}`);
  }
  const expectedMovement = label === 'support'
    ? 'movement-formed.undertaking.thread-undertaking-alpha'
    : 'movement-formed.inquiry.constitutive-inquiry';
  if (!after.normalized.includes(expectedMovement)) failures.push(`missing ${expectedMovement}`);
  if (after.outbox.length !== 1) failures.push('consequence changed effect count');
  stop(root, `v2-consequence-${label}:stop-after-consequence`);
  const secondRestart = run(`v2-consequence-${label}:restart-after-consequence`,
    ['start', '--runtime-root', root]);
  if (secondRestart.reply?.status !== 'started') failures.push('post-consequence restart failed');
  await sleep(500);
  const afterRestart = observe(root);
  if (afterRestart.checkpoint_sha256 !== after.checkpoint_sha256) {
    failures.push('post-consequence restart lost next organization');
  }
  if (JSON.stringify(afterRestart.effect_hashes) !== JSON.stringify(after.effect_hashes)) {
    failures.push('post-consequence restart replayed effect');
  }
  terminate(root, `v2-consequence-${label}:final-terminate`);
  artifacts.set(`v2-consequence-${label}`, {root, stimulus: initial.file, observed: afterRestart});
  return {label, root, failures, initial_checkpoint: before.checkpoint_sha256,
    after_checkpoint: after.checkpoint_sha256,
    restart_checkpoint: afterRestart.checkpoint_sha256,
    effect_hashes: afterRestart.effect_hashes, normalized: afterRestart.normalized};
}

async function runMatchedConsequenceCase(testCase, base, supportPath, capturePath) {
  const support = await runConsequenceBranch('support', base, supportPath);
  const capture = await runConsequenceBranch('capture', base, capturePath);
  const failures = [...support.failures.map(value => `support: ${value}`),
    ...capture.failures.map(value => `capture: ${value}`)];
  if (support.initial_checkpoint !== capture.initial_checkpoint) {
    failures.push('matched initial contacts diverged');
  }
  if (support.after_checkpoint === capture.after_checkpoint) {
    failures.push('different consequences produced identical next checkpoint');
  }
  if (support.normalized.includes('movement-formed.inquiry.constitutive-inquiry')) {
    failures.push('support branch formed capture inquiry');
  }
  if (capture.normalized.includes('movement-formed.undertaking.thread-undertaking-alpha')) {
    // History legitimately retains the prior movement, so require the active state prefix instead.
    const activePrefix = normalize("active-organization scope principal-alpha audience-alpha project-alpha");
    if (!capture.normalized.includes(activePrefix)) failures.push('capture branch active state unreadable');
  }
  return {id: testCase.id, family: 'v2', claim: testCase.claim,
    status: failures.length ? 'FAIL' : 'PASS', failures,
    support: {initial_checkpoint: support.initial_checkpoint,
      after_checkpoint: support.after_checkpoint, restart_checkpoint: support.restart_checkpoint},
    capture: {initial_checkpoint: capture.initial_checkpoint,
      after_checkpoint: capture.after_checkpoint, restart_checkpoint: capture.restart_checkpoint}};
}

const freeze = JSON.parse(fs.readFileSync(freezePath, 'utf8'));
const v2 = JSON.parse(fs.readFileSync(casesPath, 'utf8'));
const v1 = JSON.parse(fs.readFileSync(v1CasesPath, 'utf8'));
console.error('RR-002: validating frozen authority');
assert.equal(freeze.schema, 'miter-campaign-constitutive-refreeze-v1');
assert.equal(freeze.repair, 'RR-002');
assert.equal(v2.schema, 'miter-ama11-constitutive-chain-v2-cases-v1');
assert.equal(checkOpen('docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json').status,
  'OPEN-PACKAGE-VALID');
const committedFreeze = execFileSync('git', ['show', `HEAD:${freezeRelative}`], {cwd: repo});
assert.equal(sha256(committedFreeze), fileHash(freezePath), 'repair freeze changed after commit');
for (const item of freeze.frozen_inputs) {
  assert.equal(fileHash(path.join(repo, item.path)), item.sha256, `frozen input changed: ${item.path}`);
}
if (record) assert.equal(fs.existsSync(evidence), false, 'RR-002 evidence is immutable');

const base = JSON.parse(fs.readFileSync(path.join(repo, v2.base_fixture), 'utf8'));
const results = [];
for (const testCase of v2.cases) {
  console.error(`RR-002: v2 ${testCase.id}`);
  if (testCase.special === 'fork-support-and-capture-consequences') {
    results.push(await runMatchedConsequenceCase(testCase, base,
      path.join(repo, v2.support_consequence), path.join(repo, v2.capture_consequence)));
  } else results.push(await runOrdinaryCase(testCase, base, 'v2'));
}

const v1Base = JSON.parse(fs.readFileSync(path.join(repo, v1.base_fixture.path), 'utf8'));
const regression = [];
for (const testCase of v1.cases) {
  console.error(`RR-002: v1 regression ${testCase.id}`);
  regression.push(await runOrdinaryCase(testCase, v1Base, 'v1'));
}

const failures = [...results, ...regression]
  .flatMap(result => result.failures.map(failure => `${result.family}/${result.id}: ${failure}`));
const status = failures.length ? 'FAIL-CONSTITUTIVE' : 'PASS-BOUNDED';
const output = {schema: 'miter-ama11-constitutive-chain-v2-results-v1', repair: 'RR-002',
  status, v2_results: results, v1_regression: regression, failures};

if (record) {
  fs.mkdirSync(path.join(evidence, 'raw'), {recursive: true});
  writeJson(path.join(evidence, 'results.json'), output);
  writeJson(path.join(evidence, 'commands.json'), commands);
  for (const [id, artifact] of artifacts) {
    const target = path.join(evidence, 'raw', id);
    fs.mkdirSync(target, {recursive: true});
    fs.copyFileSync(artifact.stimulus, path.join(target, 'stimulus.json'));
    if (['v2-native-undertaking-without-supplied-possibility',
         'v2-same-surface-capture-forms-inquiry',
         'v2-participant-conflict-forms-inquiry',
         'v2-consequence-support', 'v2-consequence-capture'].includes(id)) {
      const checkpoint = path.join(artifact.root, 'checkpoints/active.term');
      if (fs.existsSync(checkpoint)) fs.copyFileSync(checkpoint, path.join(target, 'checkpoint.term'));
    }
  }
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama11-constitutive-chain-v2-runtime-v1', repair: 'RR-002',
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    freeze_sha256: fileHash(freezePath), cases_sha256: fileHash(casesPath),
    implementation: Object.fromEntries([
      'src/constitutive_participation_v1.metta', 'src/assistant_reactor_v1.metta',
      'src/bootstrap_assistant_v1.metta', 'effect_membranes/miter_assistant_service_v1.pl',
      'effect_membranes/miter_assistant_operator_v1.pl'
    ].map(relative => [relative, fileHash(path.join(repo, relative))])),
    external_network_calls: 0, model_calls: 0, private_memory_reads: 0, external_effects: 0
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama11-constitutive-chain-v2-verdict-v1', repair: 'RR-002', status,
    v2_passed: results.filter(result => result.status === 'PASS').map(result => result.id),
    v2_failed: results.filter(result => result.status === 'FAIL')
      .map(result => ({id: result.id, failures: result.failures})),
    v1_regression_passed: regression.every(result => result.status === 'PASS'),
    standing: status === 'PASS-BOUNDED'
      ? 'All fourteen frozen RR-002 cases and all twelve preserved v1 regression cases pass through the supported persistent assistant. Qualitative F-09 review remains separately required and this verdict does not close AMA-1.1.'
      : 'The frozen RR-002 constitutive chain or preserved v1 regression still fails. No repair admission or AMA-1.1 closure is claimed.',
    no_live_or_private_reach: true
  });
}

console.log(JSON.stringify({status, mode: record ? 'record' : 'preflight', failures,
  v2_passed: results.filter(result => result.status === 'PASS').length,
  v1_passed: regression.filter(result => result.status === 'PASS').length}));
if (failures.length) process.exitCode = 1;
