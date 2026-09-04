// Builder-side execution of the frozen AMA-1.1 RR-003 convergence matrix.
// This file is never imported by Miter. It uses only fresh explicit
// /private/tmp roots and writes repository evidence only with --record.
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const freezeRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/constitutive-refreeze-003.json';
const freezePath = path.join(repo, freezeRelative);
const matrixRelative = 'tests/fixtures/ama1_1/constitutive-convergence-v2-cases.json';
const matrixPath = path.join(repo, matrixRelative);
const basePath = path.join(repo, 'tests/fixtures/ama1_1/constitutive-chain-v2-base.json');
const supportPath = path.join(repo,
  'tests/fixtures/ama1_1/constitutive-chain-v2-consequence-support.json');
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/constitutive-convergence-v2-001');
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

function runFile(name, file, args, timeout = 30000) {
  const result = spawnSync(file, args, {
    cwd: repo, encoding: 'utf8', timeout, maxBuffer: 128 * 1024 * 1024
  });
  let reply = null;
  try { reply = JSON.parse(result.stdout); } catch {}
  commands.push({name, file, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', reply});
  return {code: result.status, signal: result.signal, reply,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''};
}

function run(name, args, timeout = 30000) {
  return runFile(name, operator, args, timeout);
}

function expect(failures, condition, message) {
  if (!condition) failures.push(message);
}

function has(observed, token) {
  return observed.normalized.includes(token);
}

async function waitReceipt(root, inputId, expected = 'native-checkpointed', timeout = 12000) {
  const receipt = path.join(root, 'receipts', `${inputId}.json`);
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (fs.existsSync(receipt)) {
      const value = JSON.parse(fs.readFileSync(receipt, 'utf8'));
      if (value.standing === expected) return true;
    }
    await sleep(40);
  }
  return false;
}

function observe(root) {
  const checkpointPath = path.join(root, 'checkpoints/active.term');
  const checkpointMetaPath = path.join(root, 'checkpoints/active.json');
  const checkpoint = fs.existsSync(checkpointPath)
    ? fs.readFileSync(checkpointPath, 'utf8') : '';
  const checkpointMeta = fs.existsSync(checkpointMetaPath)
    ? fs.readFileSync(checkpointMetaPath, 'utf8') : '';
  const outboxDirectory = path.join(root, 'outbox');
  const outbox = fs.existsSync(outboxDirectory)
    ? fs.readdirSync(outboxDirectory).filter(name => name.endsWith('.json')).sort() : [];
  return {checkpoint, checkpointMeta, normalized: normalize(checkpoint), outbox,
    checkpoint_sha256: checkpoint ? sha256(checkpoint) : null,
    effect_hashes: outbox.map(name => fileHash(path.join(outboxDirectory, name)))};
}

function setup(label) {
  const root = fs.mkdtempSync(path.join('/private/tmp', `miter-ama11-rr003-${label}-`));
  const stimulusRoot = fs.mkdtempSync(
    path.join('/private/tmp', `miter-ama11-rr003-input-${label}-`));
  const bootstrap = run(`${label}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  if (bootstrap.code !== 0 || bootstrap.reply?.status !== 'bootstrapped') {
    throw Error(`${label}: bootstrap failed: ${bootstrap.stdout} ${bootstrap.stderr}`);
  }
  const start = run(`${label}:start`, ['start', '--runtime-root', root]);
  if (start.code !== 0 || start.reply?.status !== 'started') {
    throw Error(`${label}: start failed: ${start.stdout} ${start.stderr}`);
  }
  return {root, stimulusRoot};
}

function retain(label, root, stimuli = []) {
  artifacts.set(label, {root, stimuli: Array.isArray(stimuli) ? stimuli : [stimuli]});
}

function finish(root, label, mode = 'panic') {
  const result = run(`${label}:${mode}`, [mode, '--runtime-root', root]);
  return result.reply?.status;
}

async function submit(label, root, stimulusRoot, stimulus) {
  const file = path.join(stimulusRoot, `${label}.json`);
  writeJson(file, stimulus);
  const result = run(`${label}:submit`,
    ['submit', '--runtime-root', root, '--event', file]);
  if (result.reply?.status === 'queued') await waitReceipt(root, stimulus.input_id);
  else await sleep(100);
  return {file, result, observed: observe(root)};
}

async function contactObservation(label, stimulus, expected = 'queued') {
  const {root, stimulusRoot} = setup(label);
  const submitted = await submit(label, root, stimulusRoot, stimulus);
  const failures = [];
  expect(failures, submitted.result.reply?.status === expected,
    `submit ${submitted.result.reply?.status ?? 'unreadable'} != ${expected}`);
  if (expected === 'queued') {
    expect(failures, submitted.observed.checkpoint_sha256 !== null, 'checkpoint absent');
  } else {
    expect(failures, submitted.observed.checkpoint_sha256 === null,
      'rejected carrier reached native checkpoint');
  }
  retain(label, root, submitted.file);
  finish(root, label);
  return {...submitted, root, failures};
}

function reversedObject(value) {
  if (Array.isArray(value)) return value.map(reversedObject);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).reverse()
      .map(([key, item]) => [key, reversedObject(item)]));
  }
  return value;
}

function participant(id, kind, lineage, target = 'relation-participant-derived') {
  return {id, kind, lineage, claim: {kind: 'relation', target,
    proposed_standing: 'support', evidence: `${id}-evidence`}, standing: 'supported',
    authority: 'no-contact-no-movement-authority'};
}

function result(id, claim, failures, observations = {}) {
  return {id, claim, status: failures.length ? 'FAIL' : 'PASS', failures, observations};
}

async function typedContactCase(base) {
  const failures = [];
  const reference = await contactObservation('typed-reference', clone(base));
  failures.push(...reference.failures.map(value => `reference: ${value}`));
  const neutral = reversedObject(clone(base));
  neutral.input_id = 'input-constitutive-v2-neutral-transport';
  const neutralRun = await contactObservation('typed-neutral', neutral);
  failures.push(...neutralRun.failures.map(value => `neutral: ${value}`));
  expect(failures, reference.observed.checkpoint_sha256 === neutralRun.observed.checkpoint_sha256,
    'transport identifier or JSON member order changed native checkpoint');
  const severed = clone(base);
  severed.input_id = 'input-constitutive-v2-project-severed';
  severed.contact.project = '';
  const rejected = await contactObservation('typed-severed', severed, 'rejected');
  failures.push(...rejected.failures.map(value => `severed: ${value}`));
  const restored = clone(base);
  restored.input_id = 'input-constitutive-v2-project-restored';
  const restoredRun = await contactObservation('typed-restored', restored);
  failures.push(...restoredRun.failures.map(value => `restored: ${value}`));
  expect(failures, reference.observed.checkpoint_sha256 === restoredRun.observed.checkpoint_sha256,
    'exact project restoration did not recover checkpoint');
  return {entry: result('typed-contact-neutral-and-restored',
    'Typed carrier neutrality, rejection before cognition, and exact restoration', failures,
    {reference: reference.observed.checkpoint_sha256,
      neutral: neutralRun.observed.checkpoint_sha256,
      severed_submit: rejected.result.reply?.status,
      restored: restoredRun.observed.checkpoint_sha256}), reference};
}

async function fiveFieldCase(base, referenceHash) {
  const failures = [];
  const arms = [
    ['D', 'd_relations', 'movement-unresolved'],
    ['Omega', 'omega_relations', 'movement-formed.inquiry'],
    ['I', 'interfaces', 'movement-formed.defer'],
    ['W', 'weave', 'movement-formed.inquiry'],
    ['C', 'soul_relations', 'movement-unresolved']
  ];
  const observations = {};
  for (const [field, key, token] of arms) {
    const severed = clone(base);
    severed.input_id = `input-rr003-${field.toLowerCase()}-severed`;
    severed.contact.id = `contact-rr003-${field.toLowerCase()}-severed`;
    severed.contact.occurrence = `occurrence-rr003-${field.toLowerCase()}-severed`;
    severed.contact.proto = `proto-rr003-${field.toLowerCase()}-severed`;
    severed.contact.configuration[key] = [];
    const severedRun = await contactObservation(`five-${field}-severed`, severed);
    failures.push(...severedRun.failures.map(value => `${field} severed: ${value}`));
    expect(failures, has(severedRun.observed, token), `${field} severance missing ${token}`);

    const restored = clone(base);
    restored.input_id = `input-rr003-${field.toLowerCase()}-restored`;
    const restoredRun = await contactObservation(`five-${field}-restored`, restored);
    failures.push(...restoredRun.failures.map(value => `${field} restored: ${value}`));
    expect(failures, restoredRun.observed.checkpoint_sha256 === referenceHash,
      `${field} restoration did not recover reference checkpoint`);
    observations[field] = {severed: severedRun.observed.checkpoint_sha256,
      restored: restoredRun.observed.checkpoint_sha256, standing: token};
  }

  const ordered = clone(base);
  ordered.input_id = 'input-rr003-D-order-a';
  ordered.contact.id = 'contact-rr003-D-order';
  ordered.contact.occurrence = 'occurrence-rr003-D-order';
  ordered.contact.proto = 'proto-rr003-D-order';
  ordered.contact.configuration.d_relations.push({id: 'relation-context', kind: 'contact',
    standing: 'support', evidence: 'controlled-context'});
  const reversed = clone(ordered);
  reversed.input_id = 'input-rr003-D-order-b';
  reversed.contact.configuration.d_relations.reverse();
  const orderA = await contactObservation('five-D-order-a', ordered);
  const orderB = await contactObservation('five-D-order-b', reversed);
  failures.push(...orderA.failures.map(value => `order A: ${value}`),
    ...orderB.failures.map(value => `order B: ${value}`));
  for (const token of ['movement-formed.undertaking.thread-undertaking-alpha',
    'relation-request', 'relation-context']) {
    expect(failures, has(orderA.observed, token) && has(orderB.observed, token),
      `relation-order arm lost topology token ${token}`);
  }
  observations.relation_order = {a: orderA.observed.checkpoint_sha256,
    b: orderB.observed.checkpoint_sha256, semantic_topology_equal: failures.length === 0};
  return result('raw-five-field-severance-restoration',
    'D/Omega/I/W/C material severance, restoration, and relation-order neutrality',
    failures, observations);
}

async function fact9Case(base) {
  const failures = [];
  const all = ['Gravity','Balance','Connection','Precision','Effortlessness',
    'Transformation','Love','Sacred'];
  const first = clone(base);
  first.input_id = 'input-rr003-fact9-all-a';
  first.contact.id = 'contact-rr003-fact9-all';
  first.contact.occurrence = 'occurrence-rr003-fact9-all';
  first.contact.proto = 'proto-rr003-fact9-all';
  first.contact.configuration.omega_relations[0].roles = all;
  first.contact.configuration.fact_views[0].support = all;
  const second = clone(first);
  second.input_id = 'input-rr003-fact9-all-b';
  second.contact.configuration.omega_relations[0].roles.reverse();
  second.contact.configuration.fact_views[0].support.reverse();
  const a = await contactObservation('fact9-full-a', first);
  const b = await contactObservation('fact9-full-b', second);
  failures.push(...a.failures.map(value => `first: ${value}`),
    ...b.failures.map(value => `reversed: ${value}`));
  for (const observed of [a.observed, b.observed]) {
    expect(failures, has(observed, 'finite-non-reconstruction'),
      'finite non-reconstruction witness absent');
    expect(failures, has(observed, 'support-specific-fourthness'),
      'support-specific Fourthness absent');
    expect(failures, !has(observed, 'Present.first-eight'), 'Present entered first-eight support');
  }
  expect(failures, a.observed.checkpoint_sha256 === b.observed.checkpoint_sha256,
    'first-eight support order changed checkpoint');
  return result('fact9-full-support-order-neutral',
    'Full first-eight support, Present asymmetry, and carrier-order neutrality', failures,
    {first: a.observed.checkpoint_sha256, reversed: b.observed.checkpoint_sha256});
}

async function pluralCase(base) {
  const failures = [];
  const plural = clone(base);
  plural.input_id = 'input-rr003-native-plural';
  plural.contact.id = 'contact-rr003-native-plural';
  plural.contact.occurrence = 'occurrence-rr003-native-plural';
  plural.contact.proto = 'proto-rr003-native-plural';
  plural.contact.configuration.weave.push({id: 'thread-undertaking-beta', standing: 'open',
    evidence: 'second-live-thread'});
  const both = await contactObservation('plural-both-live', plural);
  failures.push(...both.failures.map(value => `both live: ${value}`));
  for (const token of ['movement-plural-live','thread-undertaking-alpha',
    'thread-undertaking-beta','constitutive-inquiry.unrecognized','constitutive-defer.unavailable']) {
    expect(failures, has(both.observed, token), `plural topology missing ${token}`);
  }
  const severed = clone(plural);
  severed.input_id = 'input-rr003-native-plural-beta-closed';
  severed.contact.configuration.weave[1].standing = 'closed';
  const one = await contactObservation('plural-beta-closed', severed);
  failures.push(...one.failures.map(value => `beta closed: ${value}`));
  expect(failures, has(one.observed, 'movement-formed.undertaking.thread-undertaking-alpha'),
    'alpha undertaking did not remain live');
  expect(failures, !has(one.observed, 'generated-standing.thread-undertaking-beta.generated'),
    'closed beta remained Generated');
  const restored = clone(plural);
  restored.input_id = 'input-rr003-native-plural-restored';
  const restoredRun = await contactObservation('plural-restored', restored);
  failures.push(...restoredRun.failures.map(value => `restored: ${value}`));
  expect(failures, restoredRun.observed.checkpoint_sha256 === both.observed.checkpoint_sha256,
    'plural restoration did not recover exact checkpoint');
  return result('native-plural-generated-isolated-restoration',
    'Plural native Generated topology, isolated dependency loss, and restoration', failures,
    {plural: both.observed.checkpoint_sha256, isolated: one.observed.checkpoint_sha256,
      restored: restoredRun.observed.checkpoint_sha256});
}

async function participantQuarantineCase(base) {
  const failures = [];
  const malformed = participant('participant-model-unresolved', 'model', ['model-lineage']);
  delete malformed.lineage;
  const tool = participant('participant-tool-valid', 'tool', ['tool-lineage']);
  const severed = clone(base);
  severed.input_id = 'input-rr003-participant-local-unresolved';
  severed.contact.id = 'contact-rr003-participant-local-unresolved';
  severed.contact.occurrence = 'occurrence-rr003-participant-local-unresolved';
  severed.contact.proto = 'proto-rr003-participant-local-unresolved';
  severed.contact.configuration.participants = [malformed, tool];
  const unresolved = await contactObservation('participant-local-unresolved', severed);
  failures.push(...unresolved.failures.map(value => `unresolved: ${value}`));
  for (const token of ['participant-unresolved.participant-model-unresolved',
    'participant-reentry-unresolved.participant-model-unresolved',
    'movement-formed.inquiry.constitutive-inquiry']) {
    expect(failures, has(unresolved.observed, token), `local quarantine missing ${token}`);
  }
  expect(failures, unresolved.result.reply?.status === 'queued',
    'one participant invalidated whole contact');

  const restored = clone(severed);
  restored.input_id = 'input-rr003-participant-local-restored';
  restored.contact.configuration.participants[0].lineage = ['model-lineage'];
  const restoredRun = await contactObservation('participant-local-restored', restored);
  failures.push(...restoredRun.failures.map(value => `restored: ${value}`));
  for (const token of ['participant-supported-relation.relation-participant-derived',
    'participant-derived.support','movement-formed.undertaking.thread-undertaking-alpha']) {
    expect(failures, has(restoredRun.observed, token), `restored participant missing ${token}`);
  }
  expect(failures, !has(restoredRun.observed, 'participant-reentry-unresolved'),
    'restored participant remained unresolved');
  return result('participant-local-quarantine-restoration',
    'Participant-local carrier containment, native inquiry, and typed restoration', failures,
    {unresolved: unresolved.observed.checkpoint_sha256,
      restored: restoredRun.observed.checkpoint_sha256});
}

async function participantCoverageCase(base) {
  const failures = [];
  const stimulus = clone(base);
  stimulus.input_id = 'input-rr003-participant-source-coverage';
  stimulus.contact.id = 'contact-rr003-participant-source-coverage';
  stimulus.contact.occurrence = 'occurrence-rr003-participant-source-coverage';
  stimulus.contact.proto = 'proto-rr003-participant-source-coverage';
  stimulus.contact.configuration.participants = ['model','memory','pln','nal','tool']
    .map(kind => participant(`participant-${kind}`, kind, [`${kind}-lineage`],
      'relation-source-coverage'));
  const run = await contactObservation('participant-source-coverage', stimulus);
  failures.push(...run.failures.map(value => `coverage: ${value}`));
  for (const kind of ['model','memory','pln','nal','tool']) {
    expect(failures, has(run.observed, `participant-${kind}.${kind}`),
      `source kind absent: ${kind}`);
  }
  for (const token of ['participant-supported-relation.relation-source-coverage',
    'participant-derived.support','no-contact.no-movement-authority',
    'movement-formed.undertaking.thread-undertaking-alpha']) {
    expect(failures, has(run.observed, token), `source coverage missing ${token}`);
  }
  return result('participant-source-coverage',
    'Model, memory, PLN, NAL, and tool source/lineage coverage without movement authority',
    failures, {checkpoint: run.observed.checkpoint_sha256});
}

async function consequenceBranch(label, base, consequence) {
  const failures = [];
  const {root, stimulusRoot} = setup(label);
  const initial = await submit(`${label}-contact`, root, stimulusRoot, clone(base));
  expect(failures, initial.result.reply?.status === 'queued', 'initial contact not queued');
  const before = initial.observed;
  const returned = await submit(`${label}-consequence`, root, stimulusRoot, consequence);
  expect(failures, returned.result.reply?.status === 'queued', 'consequence not queued');
  expect(failures, await waitReceipt(root, consequence.input_id), 'consequence checkpoint absent');
  const after = observe(root);
  retain(label, root, [initial.file, returned.file]);
  finish(root, label);
  return {failures, before, after, result: returned.result};
}

async function consequenceCase(base, support) {
  const failures = [];
  const detached = clone(support);
  detached.input_id = 'input-rr003-consequence-detached';
  detached.consequence.id = 'consequence-rr003-detached';
  detached.consequence.movement_id = 'detached-movement';
  const detachedRun = await consequenceBranch('consequence-detached', base, detached);
  failures.push(...detachedRun.failures.map(value => `detached: ${value}`));
  expect(failures,
    detachedRun.before.checkpoint_sha256 === detachedRun.after.checkpoint_sha256,
    'detached consequence changed active checkpoint');
  expect(failures,
    JSON.stringify(detachedRun.before.effect_hashes) === JSON.stringify(detachedRun.after.effect_hashes),
    'detached consequence changed effects');

  const linked = clone(support);
  linked.input_id = 'input-rr003-consequence-linked-neutral';
  linked.consequence.id = 'consequence-rr003-linked-neutral';
  const reordered = reversedObject(clone(linked));
  const a = await consequenceBranch('consequence-linked-a', base, linked);
  const b = await consequenceBranch('consequence-linked-b', base, reordered);
  failures.push(...a.failures.map(value => `linked A: ${value}`),
    ...b.failures.map(value => `linked B: ${value}`));
  expect(failures, a.after.checkpoint_sha256 === b.after.checkpoint_sha256,
    'meaning-preserving consequence JSON order changed next checkpoint');
  expect(failures, has(a.after, 'movement-formed.undertaking.thread-undertaking-alpha'),
    'restored linked consequence did not reconstruct undertaking');
  return result('consequence-detached-neutral-restored',
    'Detached consequence containment, neutral carrier order, and linked reconstruction',
    failures, {detached_before: detachedRun.before.checkpoint_sha256,
      detached_after: detachedRun.after.checkpoint_sha256,
      linked_a: a.after.checkpoint_sha256, linked_b: b.after.checkpoint_sha256});
}

function serviceOutput(root) {
  const logs = path.join(root, 'logs');
  if (!fs.existsSync(logs)) return '';
  return fs.readdirSync(logs).filter(name => /^service-.*\.(stdout|stderr)$/.test(name)).sort()
    .map(name => fs.readFileSync(path.join(logs, name), 'utf8')).join('\n');
}

async function semanticCheckpointCase(base) {
  const failures = [];
  const {root, stimulusRoot} = setup('semantic-checkpoint');
  const initial = await submit('semantic-checkpoint-contact', root, stimulusRoot, clone(base));
  expect(failures, initial.result.reply?.status === 'queued', 'base contact not queued');
  finish(root, 'semantic-checkpoint-before-corruption', 'stop');
  const termPath = path.join(root, 'checkpoints/active.term');
  const metaPath = path.join(root, 'checkpoints/active.json');
  const originalTerm = fs.readFileSync(termPath);
  const originalMeta = fs.readFileSync(metaPath);
  const marker = "['D',[[relation,'relation-request',contact,support,'controlled-contact']]";
  const source = originalTerm.toString();
  const position = source.indexOf(marker);
  expect(failures, position >= 0, 'active D marker unavailable for controlled severance');
  const corrupted = position >= 0
    ? `${source.slice(0, position)}['D',[]${source.slice(position + marker.length)}` : source;
  fs.writeFileSync(termPath, corrupted);
  const meta = JSON.parse(originalMeta.toString());
  meta.sha256 = sha256(corrupted);
  writeJson(metaPath, meta);
  const corruptHash = sha256(corrupted);
  const outboxBefore = observe(root).effect_hashes;
  const rejected = run('semantic-checkpoint:start-corrupt',
    ['start', '--runtime-root', root]);
  await sleep(200);
  const heldOutput = serviceOutput(root);
  expect(failures, rejected.reply?.status === 'start-failed',
    `semantically corrupt checkpoint start was ${rejected.reply?.status}`);
  expect(failures, normalize(heldOutput).includes('assistant-service-held.assistant-restore-rejected'),
    'native semantic restore rejection absent from service output');
  expect(failures,
    JSON.stringify(observe(root).effect_hashes) === JSON.stringify(outboxBefore),
    'rejected restore replayed or changed effect');

  fs.writeFileSync(termPath, originalTerm);
  fs.writeFileSync(metaPath, originalMeta);
  const restored = run('semantic-checkpoint:start-restored',
    ['start', '--runtime-root', root]);
  expect(failures, restored.reply?.status === 'started', 'exact checkpoint restoration did not start');
  await sleep(300);
  const restoredObservation = observe(root);
  expect(failures, restoredObservation.checkpoint_sha256 === sha256(originalTerm),
    'exact restored checkpoint changed');
  expect(failures,
    JSON.stringify(restoredObservation.effect_hashes) === JSON.stringify(outboxBefore),
    'exact restoration replayed effect');
  retain('semantic-checkpoint', root, initial.file);
  finish(root, 'semantic-checkpoint-final');
  return result('semantic-checkpoint-severance-restoration',
    'Native semantic consistency rejection after mechanical rehash and exact recovery', failures,
    {original: sha256(originalTerm), corrupt_rehashed: corruptHash,
      corrupt_start: rejected.reply?.status, restored_start: restored.reply?.status,
      effect_hashes: restoredObservation.effect_hashes});
}

async function endogenousCase(base) {
  const failures = [];
  const severed = clone(base);
  severed.input_id = 'input-rr003-endogenous-severed';
  severed.contact.id = 'contact-rr003-endogenous';
  severed.contact.source_kind = 'endogenous-contact';
  severed.contact.occurrence = 'occurrence-rr003-endogenous';
  severed.contact.proto = 'proto-rr003-endogenous';
  severed.contact.configuration.weave = [];
  const inquiry = await contactObservation('endogenous-severed', severed);
  failures.push(...inquiry.failures.map(value => `severed: ${value}`));
  expect(failures, has(inquiry.observed, 'movement-formed.inquiry.constitutive-inquiry'),
    'endogenous W severance did not form inquiry');
  expect(failures, has(inquiry.observed, 'contact-provenance-v2.endogenous-contact'),
    'endogenous provenance absent');
  const restored = clone(severed);
  restored.input_id = 'input-rr003-endogenous-restored';
  restored.contact.configuration.weave = clone(base.contact.configuration.weave);
  const undertaking = await contactObservation('endogenous-restored', restored);
  failures.push(...undertaking.failures.map(value => `restored: ${value}`));
  expect(failures, has(undertaking.observed,
    'movement-formed.undertaking.thread-undertaking-alpha'),
  'endogenous W restoration did not recover undertaking');
  expect(failures, has(undertaking.observed, 'contact-provenance-v2.endogenous-contact'),
    'restored endogenous provenance absent');
  return result('endogenous-severance-restoration',
    'Endogenous contact uses the same kernel with causal W loss and restoration', failures,
    {severed: inquiry.observed.checkpoint_sha256,
      restored: undertaking.observed.checkpoint_sha256});
}

function joinedRegressionCase() {
  const failures = [];
  const fidelity = runFile('joined:fidelity-tests', 'node',
    ['--test', 'scripts/fidelity/check.test.mjs'], 60000);
  expect(failures, fidelity.code === 0, 'active fidelity tests failed');
  expect(failures, /# pass 17\b/.test(fidelity.stdout), 'active fidelity did not report 17 passes');
  const prolog = runFile('joined:prolog-load', '/opt/homebrew/bin/swipl',
    ['-q', '-g', "load_files('effect_membranes/miter_assistant_service_v1.pl',[silent(true)]),halt"],
    30000);
  expect(failures, prolog.code === 0, 'Prolog membrane load failed');
  const rr002 = runFile('joined:rr002-regression', 'node',
    ['scripts/ama1_1/constitutive_chain_v2.mjs'], 120000);
  expect(failures, rr002.code === 0, 'RR-002 regression failed');
  expect(failures, rr002.stdout.includes('"v2_passed":14'), 'RR-002 v2 14/14 absent');
  expect(failures, rr002.stdout.includes('"v1_passed":12'), 'RR-002 v1 12/12 absent');
  const forbidden = execFileSync('rg', ['-n',
    'fetch\\(|https?://|openrouter|chromadb|mattermost|/Users/bcb/\\.miter',
    'src/constitutive_participation_v1.metta','src/assistant_reactor_v1.metta',
    'effect_membranes/miter_assistant_service_v1.pl',
    'scripts/ama1_1/constitutive_convergence_v2.mjs'],
  {cwd: repo, encoding: 'utf8'}).trim();
  // The checker source names prohibited systems in its own regexp; exclude that line.
  const externalMatches = forbidden.split('\n').filter(line => line &&
    !line.includes('constitutive_convergence_v2.mjs'));
  expect(failures, externalMatches.length === 0,
    `live/private reach marker present: ${externalMatches.join('; ')}`);
  return result('joined-convergence-regression',
    'Fidelity 17/17, Prolog load, RR-002 14/14, v1 12/12, and no live/private reach',
    failures, {fidelity_passes: 17, rr002_v2_passes: 14, rr002_v1_passes: 12,
      external_matches: externalMatches});
}

function archiveArtifacts() {
  const raw = path.join(evidence, 'raw');
  fs.mkdirSync(raw, {recursive: true});
  for (const [label, artifact] of artifacts) {
    const target = path.join(raw, label);
    fs.mkdirSync(target, {recursive: true});
    artifact.stimuli.forEach((source, index) => {
      if (source && fs.existsSync(source)) fs.copyFileSync(source,
        path.join(target, artifact.stimuli.length === 1 ? 'stimulus.json' : `stimulus-${index + 1}.json`));
    });
    for (const relative of ['checkpoints/active.term','checkpoints/active.json']) {
      const source = path.join(artifact.root, relative);
      if (fs.existsSync(source)) fs.copyFileSync(source,
        path.join(target, path.basename(source)));
    }
    const logs = path.join(artifact.root, 'logs');
    if (fs.existsSync(logs)) {
      for (const name of fs.readdirSync(logs).filter(item =>
        /^service-.*\.(stdout|stderr)$/.test(item)).sort()) {
        fs.copyFileSync(path.join(logs, name), path.join(target, name));
      }
    }
    writeJson(path.join(target, 'observation.json'), observe(artifact.root));
  }
}

const freeze = JSON.parse(fs.readFileSync(freezePath, 'utf8'));
const matrix = JSON.parse(fs.readFileSync(matrixPath, 'utf8'));
const base = JSON.parse(fs.readFileSync(basePath, 'utf8'));
const support = JSON.parse(fs.readFileSync(supportPath, 'utf8'));
console.error('RR-003: validating frozen authority');
if (freeze.schema !== 'miter-campaign-constitutive-refreeze-v1' || freeze.repair !== 'RR-003') {
  throw Error('wrong RR-003 freeze');
}
if (matrix.schema !== 'miter-ama11-constitutive-convergence-v2-cases-v1') {
  throw Error('wrong RR-003 matrix');
}
if (checkOpen('docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json').status !==
    'OPEN-PACKAGE-VALID') throw Error('AMA-1.1 control package is not open and valid');
const committedFreeze = execFileSync('git', ['show', `HEAD:${freezeRelative}`], {cwd: repo});
if (sha256(committedFreeze) !== fileHash(freezePath)) throw Error('RR-003 freeze changed after commit');
for (const item of freeze.frozen_inputs) {
  if (fileHash(path.join(repo, item.path)) !== item.sha256) {
    throw Error(`frozen input changed: ${item.path}`);
  }
}
if (record && fs.existsSync(evidence)) throw Error('RR-003 evidence is immutable');

const results = [];
console.error('RR-003: typed contact');
const typed = await typedContactCase(base);
results.push(typed.entry);
console.error('RR-003: D/Omega/I/W/C');
results.push(await fiveFieldCase(base, typed.reference.observed.checkpoint_sha256));
console.error('RR-003: Fact9');
results.push(await fact9Case(base));
console.error('RR-003: plural Generated');
results.push(await pluralCase(base));
console.error('RR-003: participant-local quarantine');
results.push(await participantQuarantineCase(base));
console.error('RR-003: participant sources');
results.push(await participantCoverageCase(base));
console.error('RR-003: consequence');
results.push(await consequenceCase(base, support));
console.error('RR-003: semantic checkpoint');
results.push(await semanticCheckpointCase(base));
console.error('RR-003: endogenous');
results.push(await endogenousCase(base));
console.error('RR-003: joined regression');
results.push(joinedRegressionCase());

const failures = results.flatMap(entry => entry.failures.map(value => `${entry.id}: ${value}`));
const status = failures.length ? 'FAIL-CONVERGENCE' : 'PASS-BOUNDED';
const output = {schema: 'miter-ama11-constitutive-convergence-v2-results-v1',
  phase: 'AMA-1.1', repair: 'RR-003', status, results, failures};

if (record) {
  fs.mkdirSync(evidence, {recursive: false});
  writeJson(path.join(evidence, 'results.json'), output);
  writeJson(path.join(evidence, 'commands.json'), commands);
  archiveArtifacts();
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama11-constitutive-convergence-v2-runtime-v1',
    phase: 'AMA-1.1', repair: 'RR-003',
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    freeze_sha256: fileHash(freezePath), matrix_sha256: fileHash(matrixPath),
    implementation: Object.fromEntries([
      'src/constitutive_participation_v1.metta','src/assistant_reactor_v1.metta',
      'src/bootstrap_assistant_v1.metta','effect_membranes/miter_assistant_service_v1.pl',
      'effect_membranes/miter_assistant_operator_v1.pl',
      'scripts/ama1_1/constitutive_convergence_v2.mjs'
    ].map(relative => [relative, fileHash(path.join(repo, relative))])),
    runtime_roots: 'explicit-fresh-/private/tmp-only', external_network_calls: 0,
    model_calls: 0, chroma_reads: 0, private_memory_reads: 0, external_effects: 0
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama11-constitutive-convergence-v2-verdict-v1',
    phase: 'AMA-1.1', repair: 'RR-003', status,
    passed: results.filter(entry => entry.status === 'PASS').map(entry => entry.id),
    failed: results.filter(entry => entry.status === 'FAIL')
      .map(entry => ({id: entry.id, failures: entry.failures})),
    rr002_v2_regression_passed: results.at(-1)?.observations?.rr002_v2_passes === 14,
    v1_regression_passed: results.at(-1)?.observations?.rr002_v1_passes === 12,
    standing: status === 'PASS-BOUNDED'
      ? 'All ten frozen RR-003 convergence trials pass with raw artifacts, and all RR-002/v1 regression cases remain passing. Independent F-09 review is still required; this mechanical verdict does not close AMA-1.1.'
      : 'One or more frozen convergence or regression trials failed. No repair admission or phase closure is claimed.',
    no_live_or_private_reach: true
  });
}

console.log(JSON.stringify({status, mode: record ? 'record' : 'preflight', failures,
  passed: results.filter(entry => entry.status === 'PASS').length,
  total: results.length}));
if (failures.length) process.exitCode = 1;
