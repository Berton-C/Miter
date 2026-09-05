// Builder-side AMA-1.2 four-plane Continuity of Mind trial.
// It uses controlled local fixtures only and is never imported by Miter.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const operator = path.join(repo, 'bin/miter');
const service = path.join(repo, 'effect_membranes/miter_assistant_service_v1.pl');
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R1/plan.json';
const contactFixture = path.join(repo, 'tests/fixtures/ama1_2/scope-contact-v3.json');
const manuscriptFixture = path.join(repo, 'tests/fixtures/g08_manuscript.md');
const evidence = path.join(repo, 'evidence/AMA-1.2/R1/four-plane-continuity-001');
const record = process.argv.includes('--record');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const clone = value => JSON.parse(JSON.stringify(value));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const commands = [];
const observations = new Map();

function writeJson(file, value) {
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
}

function writeText(file, value) {
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, value, {mode: 0o600});
}

function run(name, executable, args, timeout = 30000) {
  const result = spawnSync(executable, args, {
    cwd: repo, encoding: 'utf8', timeout, maxBuffer: 64 * 1024 * 1024
  });
  let reply = null;
  try { reply = JSON.parse(result.stdout); } catch {}
  commands.push({name, executable, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', reply});
  return {code: result.status, signal: result.signal, reply,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''};
}

function op(name, args, timeout = 30000) {
  return run(name, operator, args, timeout);
}

function prologAtom(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function mechanic(name, predicate, args, expected) {
  const goal = `${predicate}(${args.map(prologAtom).join(',')},R),write_canonical(R),nl,halt`;
  const result = run(name, '/opt/homebrew/bin/swipl', ['-q', '-s', service, '-g', goal]);
  assert.equal(result.code, 0, `${name}: Prolog process`);
  assert.equal(result.stderr, '', `${name}: Prolog stderr`);
  const observed = result.stdout.trim().replace(/^'(.*)'$/, '$1');
  assert.equal(observed, expected, `${name}: unexpected standing`);
  return observed;
}

const bindingAlpha = {
  binding_id: 'binding-fixture-alpha', carrier_kind: 'controlled-fixture',
  server_id: 'fixture-server-alpha', team_id: 'fixture-team-alpha',
  channel_id: 'fixture-channel-alpha', principal_id: 'fixture-user-alpha',
  principal: 'principal-alpha', audience: 'audience-alpha', project: 'project-alpha',
  standing: 'authorized'
};

const bindingBeta = {
  binding_id: 'binding-fixture-beta', carrier_kind: 'controlled-fixture',
  server_id: 'fixture-server-alpha', team_id: 'fixture-team-alpha',
  channel_id: 'fixture-channel-beta', principal_id: 'fixture-user-beta',
  principal: 'principal-beta', audience: 'audience-beta', project: 'project-beta',
  standing: 'authorized'
};

function continuitySource(root) {
  return {
    source_id: 'continuity-source-alpha',
    principal: 'principal-alpha', audience: 'audience-alpha', project: 'project-alpha',
    capsule_store: path.join(root, 'continuity/capsules'),
    trajectory_store: path.join(root, 'continuity/trajectory'),
    semantic_collection: 'miter-ltm-alpha',
    embedding_profile: 'nomic-embed-text-v1.5',
    semantic_standing: 'unavailable',
    undertaking_id: 'thread-undertaking-alpha',
    attention_id: 'attention-observatory-decision',
    rna_id: 'rna-observatory-continuation',
    relationships: ['relationship-human-book-collaboration'],
    open_alternatives: ['alternative-reveal-key', 'alternative-withhold-key'],
    pending_consequences: ['consequence-reader-trust-unobserved'],
    learned_relations: ['relation-key-warmth-foreshadows-access']
  };
}

function scopeDocument(root, bindings = [bindingAlpha], sources = [continuitySource(root)],
    semanticSources = []) {
  return {schema: 'miter-assistant-scope-bindings-v1',
    authority_mode: 'controlled-fixture-only', bindings, continuity_sources: sources,
    semantic_sources: semanticSources};
}

function setupRoot(id, options = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-continuity-${id}-`));
  const stimulusRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-continuity-input-${id}-`));
  const boot = op(`${id}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  assert.equal(boot.code, 0, `${id}: bootstrap process`);
  assert.equal(boot.reply?.status, 'bootstrapped', `${id}: bootstrap standing`);

  const artifact = path.join(root, 'artifacts/glass-archive.md');
  fs.mkdirSync(path.dirname(artifact), {recursive: true});
  fs.copyFileSync(manuscriptFixture, artifact);
  fs.chmodSync(artifact, 0o600);
  const artifactHash = fileHash(artifact);
  const eventId = 'evt-continuity-alpha-0001';
  const trajectory = path.join(root, 'continuity/trajectory');
  const capsuleStore = path.join(root, 'continuity/capsules');
  const extension = path.join(root, 'lib/libmiter_store_posix.dylib');
  const setup = path.join(root, 'setup');
  const intentPath = path.join(setup, 'trajectory-intent.json');
  writeJson(intentPath, {
    schema: 'miter-event-intent-v1', event_id: eventId,
    event_kind: 'continuity-checkpoint', occurred_at: '2026-06-02T10:00:00Z',
    recorded_at: '2026-06-02T10:00:01Z', source_surface: 'controlled-fixture',
    source_principal: 'principal-alpha', audience_scope: 'audience-alpha',
    project_scope: 'project-alpha', provenance_kind: 'direct-project-contact',
    correlation_id: 'corr-continuity-alpha', parent_event_ids: [],
    payload: {standing: 'unfinished-book-undertaking', artifact_sha256: artifactHash}
  });
  mechanic(`${id}:append-trajectory`, 'miter_store_append_event',
    [trajectory, extension, intentPath], 'event-appended');

  const baseCapsule = {
    schema: 'miter-project-continuity-fixture-v1', project_id: 'project-alpha',
    project_name: 'The Glass Archive',
    project_purpose: 'Continue a continuity-preserving speculative novel draft.',
    current_artifact_ref: artifact, current_artifact_hash: artifactHash,
    open_questions: ['Should Mara reveal the archive key to Jonas before the storm breaks?'],
    live_tensions: ['Trust Jonas versus protecting the archive secret.',
      'Urgency of the storm versus deliberate disclosure.'],
    blocked_by: [],
    commitments: ['Keep the key warmth consistent with chapter-one foreshadowing.',
      'Do not resolve Jonas trustworthiness in this scene.'],
    relevant_memory_ids: [], relevant_event_ids: [eventId],
    principal_scope: 'principal-alpha', audience_scope: 'audience-alpha'
  };
  const prior = {...baseCapsule, capsule_id: 'capsule-alpha-prior',
    current_goal: 'Establish Mara arrival at the observatory.',
    exact_location: 'Chapter 3 / The Observatory / paragraph 1',
    last_completed_work: 'Drafted Mara reaching the ruined observatory before the storm.',
    next_intended_movement: 'Draft the observatory threshold.',
    previous_capsule_id: 'none', supersedes_capsule_id: 'none',
    created_at: '2026-06-01T10:00:00Z', status: 'active'};
  const current = {...baseCapsule, capsule_id: 'capsule-alpha-current',
    current_goal: 'Resolve Mara choice about revealing the archive key.',
    exact_location: 'Chapter 3 / The Observatory / paragraph 4 decision beat',
    last_completed_work: 'Revised the observatory entrance and added the stair beneath the silent telescope.',
    next_intended_movement: 'Draft Mara decision beat and test it against chapter-one foreshadowing.',
    previous_capsule_id: 'capsule-alpha-prior',
    supersedes_capsule_id: 'capsule-alpha-prior',
    created_at: '2026-06-02T10:05:00Z', status: 'current'};
  const priorPath = path.join(setup, 'capsule-prior.json');
  const currentPath = path.join(setup, 'capsule-current.json');
  writeJson(priorPath, prior);
  writeJson(currentPath, current);
  mechanic(`${id}:append-prior-capsule`, 'miter_continuity_write_capsule',
    [capsuleStore, extension, priorPath], 'capsule-appended');
  mechanic(`${id}:append-current-capsule`, 'miter_continuity_write_capsule',
    [capsuleStore, extension, currentPath], 'capsule-appended');
  mechanic(`${id}:select-current-capsule`, 'miter_continuity_set_current',
    [capsuleStore, extension, 'project-alpha', 'capsule-alpha-current'],
    'current-capsule-selected');

  const bindings = options.bindings ?? [bindingAlpha];
  const sources = options.sources ? options.sources(root) : [continuitySource(root)];
  writeJson(path.join(root, 'scope-bindings.json'), scopeDocument(root, bindings, sources));
  if (options.mutate) options.mutate({root, artifact, trajectory, capsuleStore,
    artifactHash, eventId, setup});
  return {root, stimulusRoot, artifact, artifactHash, trajectory, capsuleStore,
    eventId, setup};
}

function restoreProjection(id, root) {
  const goal = `miter_assistant_continuity_restore(${prologAtom(root)},R),write_canonical(R),nl,halt`;
  const result = run(`${id}:restore-projection`, '/opt/homebrew/bin/swipl',
    ['-q', '-s', service, '-g', goal]);
  assert.equal(result.code, 0, `${id}: restore probe process`);
  assert.equal(result.stderr, '', `${id}: restore probe stderr`);
  return result.stdout.trim();
}

function start(root, id) {
  const result = op(`${id}:start`, ['start', '--runtime-root', root]);
  assert.equal(result.code, 0, `${id}: start process`);
  assert.equal(result.reply?.status, 'started', `${id}: start standing`);
  return result.reply.pid;
}

function submit(root, stimulusRoot, id, stimulus) {
  const file = path.join(stimulusRoot, `${id}.json`);
  writeJson(file, stimulus);
  const result = op(`${id}:submit`, ['submit', '--runtime-root', root, '--event', file]);
  return {file, result};
}

async function waitCheckpoint(root, inputId, timeout = 15000) {
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

function jsonFiles(directory) {
  return fs.existsSync(directory)
    ? fs.readdirSync(directory).filter(name => name.endsWith('.json')).sort() : [];
}

function serviceOutput(root) {
  const directory = path.join(root, 'logs');
  const files = fs.existsSync(directory)
    ? fs.readdirSync(directory).filter(name => /^service-.*\.(?:stdout|stderr)$/.test(name)).sort()
    : [];
  return files.map(name => ({name, text: fs.readFileSync(path.join(directory, name), 'utf8')}));
}

function stop(root, id, command = 'panic') {
  const result = op(`${id}:${command}`, [command, '--runtime-root', root]);
  assert.ok(['panicked', 'stopped'].includes(result.reply?.status), `${id}: ${command} standing`);
  return result;
}

async function positiveCase() {
  const id = 'positive-long-gap';
  const state = setupRoot(id);
  const projection = restoreProjection(id, state.root);
  for (const required of ['continuity-source-set-v1', 'continuity-projection-v1',
    'capsule-alpha-current', state.artifactHash, 'exact-authoritative',
    'semantic-plane', 'unavailable', 'index-not-authority']) {
    assert.ok(projection.includes(required), `${id}: restore projection missing ${required}`);
  }
  start(state.root, id);
  const stimulus = clone(JSON.parse(fs.readFileSync(contactFixture, 'utf8')));
  const sent = submit(state.root, state.stimulusRoot, id, stimulus);
  assert.equal(sent.result.reply?.status, 'queued', `${id}: contact not queued`);
  assert.equal(await waitCheckpoint(state.root, stimulus.input_id), true,
    `${id}: native checkpoint not reached`);
  const checkpointPath = path.join(state.root, 'checkpoints/active.term');
  const checkpoint = fs.readFileSync(checkpointPath, 'utf8');
  for (const required of [
    'capsule-alpha-current', state.artifactHash,
    'Chapter 3 / The Observatory / paragraph 4 decision beat',
    'Should Mara reveal the archive key to Jonas before the storm breaks?',
    'continuity-trajectory-current', 'continuity-capsule-current',
    'continuity-artifact-current', 'continuity-undertaking-current',
    'continuity-attention-current', 'continuity-rna-current',
    'relationship-human-book-collaboration',
    'relation-key-warmth-foreshadows-access',
    'alternative-reveal-key', 'alternative-withhold-key',
    'consequence-reader-trust-unobserved',
    'continuity-exact-vs-semantic', 'interface-exact-continuity',
    'relation-continuity-of-mind', 'TimeCoherence', 'AttentionStewardship',
    'balance-unfolding-as-intelligence', 'fact9-participation',
    'flourishing-participation', 'rap-readings', 'movement-plural-live'
  ]) assert.ok(checkpoint.includes(required), `${id}: checkpoint missing ${required}`);
  assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 1,
    `${id}: local effect count`);
  const before = fileHash(checkpointPath);
  const effectPath = path.join(state.root, 'outbox', jsonFiles(path.join(state.root, 'outbox'))[0]);
  const effectBefore = fileHash(effectPath);
  assert.equal(op(`${id}:stop`, ['stop', '--runtime-root', state.root]).reply?.status,
    'stopped', `${id}: clean stop`);
  assert.equal(op(`${id}:restart`, ['start', '--runtime-root', state.root]).reply?.status,
    'started', `${id}: restart`);
  await sleep(700);
  assert.equal(fileHash(checkpointPath), before, `${id}: restart changed checkpoint`);
  assert.equal(fileHash(effectPath), effectBefore, `${id}: restart changed effect`);
  assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 1,
    `${id}: restart replayed local effect`);
  stop(state.root, id);
  observations.set(id, {state, projection, checkpointPath, checkpointHash: before});
  return {id, standing: 'continuity-constitutively-incorporated',
    semantic_index: 'unavailable-without-amnesia', exact_capsule: 'capsule-alpha-current',
    exact_artifact_sha256: state.artifactHash,
    movement: 'plural-live-from-continuity-relations-and-open-alternatives',
    restart_stable: true, replayed_effects: 0};
}

async function noSourceScopeCase() {
  const id = 'scope-isolation';
  const state = setupRoot(id, {bindings: [bindingAlpha, bindingBeta]});
  start(state.root, id);
  const stimulus = clone(JSON.parse(fs.readFileSync(contactFixture, 'utf8')));
  stimulus.input_id = 'input-scope-contact-beta';
  stimulus.surface.channel_id = bindingBeta.channel_id;
  stimulus.surface.principal_id = bindingBeta.principal_id;
  stimulus.surface.post_id = 'contact-scope-beta';
  stimulus.surface.thread_id = 'fixture-thread-beta';
  stimulus.contact.id = 'contact-scope-beta';
  stimulus.contact.principal = bindingBeta.principal;
  stimulus.contact.audience = bindingBeta.audience;
  stimulus.contact.project = bindingBeta.project;
  stimulus.contact.occurrence = 'occurrence-scope-beta';
  stimulus.contact.proto = 'proto-scope-beta';
  stimulus.contact.payload_ref = 'payload-scope-beta';
  stimulus.contact.configuration.weave[0].id = 'thread-undertaking-beta';
  stimulus.contact.configuration.present.context = 'present-scope-beta';
  stimulus.contact.configuration.fact_views[0].id = 'fact-view-scope-beta';
  const sent = submit(state.root, state.stimulusRoot, id, stimulus);
  assert.equal(sent.result.reply?.status, 'queued', `${id}: contact not queued`);
  assert.equal(await waitCheckpoint(state.root, stimulus.input_id), true,
    `${id}: native checkpoint not reached`);
  const checkpointPath = path.join(state.root, 'checkpoints/active.term');
  const checkpoint = fs.readFileSync(checkpointPath, 'utf8');
  assert.ok(checkpoint.includes('continuity-standing') &&
    checkpoint.includes('no-source-for-scope'),
    `${id}: no-source standing absent`);
  assert.ok(!checkpoint.includes('capsule-alpha-current'), `${id}: cross-project capsule leak`);
  assert.ok(!checkpoint.includes(state.artifactHash), `${id}: cross-project artifact leak`);
  stop(state.root, id);
  return {id, standing: 'no-source-for-beta-scope', alpha_continuity_leaked: false,
    beta_contact_incorporated: true};
}

async function heldCase(id, mutate, requiredStanding = 'continuity-source-set-held') {
  const state = setupRoot(id, {mutate});
  const projection = restoreProjection(id, state.root);
  assert.ok(projection.includes(requiredStanding), `${id}: restore did not hold`);
  const attempted = op(`${id}:start`, ['start', '--runtime-root', state.root]);
  assert.equal(attempted.reply?.status, 'start-failed', `${id}: startup did not fail closed`);
  await sleep(650);
  const status = op(`${id}:status`, ['status', '--runtime-root', state.root]);
  assert.ok(['stopped', 'panicked'].includes(status.reply?.status), `${id}: held service still running`);
  assert.equal(fs.existsSync(path.join(state.root, 'checkpoints/active.term')), false,
    `${id}: held source reached checkpoint`);
  assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 0,
    `${id}: held source produced effect`);
  const output = serviceOutput(state.root).map(row => row.text).join('\n');
  assert.ok(output.includes('assistant-service-held'), `${id}: held startup not observable`);
  observations.set(id, {state, projection, output});
  return {id, standing: 'startup-held-before-ordinary-cognition',
    checkpoint: false, local_effects: 0};
}

assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');
if (record && fs.existsSync(evidence)) throw Error('four-plane evidence already exists');

const results = [];
results.push(await positiveCase());
results.push(await noSourceScopeCase());
results.push(await heldCase('artifact-changed', ({artifact}) => {
  fs.appendFileSync(artifact, '\nUnadmitted change after capsule selection.\n');
}));
results.push(await heldCase('artifact-missing', ({artifact}) => {
  fs.renameSync(artifact, `${artifact}.unavailable`);
}));
results.push(await heldCase('trajectory-corrupt', ({trajectory}) => {
  fs.appendFileSync(path.join(trajectory, 'trajectory.jsonl'), '{"malformed":true}\n');
}));
results.push(await heldCase('continuity-scope-unbound', ({root}) => {
  writeJson(path.join(root, 'scope-bindings.json'),
    scopeDocument(root, [bindingBeta], [continuitySource(root)]));
}));

const status = results.every(row =>
  row.standing === 'continuity-constitutively-incorporated' ||
  row.standing === 'no-source-for-beta-scope' ||
  row.standing === 'startup-held-before-ordinary-cognition') ? 'PASS-BOUNDED' : 'FAIL';
assert.equal(status, 'PASS-BOUNDED');

if (record) {
  fs.mkdirSync(path.join(evidence, 'raw'), {recursive: true});
  const positive = observations.get('positive-long-gap');
  fs.copyFileSync(positive.checkpointPath,
    path.join(evidence, 'raw/positive-checkpoint.term'));
  writeText(path.join(evidence, 'raw/positive-restore-projection.term'),
    `${positive.projection}\n`);
  for (const id of ['artifact-changed', 'artifact-missing', 'trajectory-corrupt',
    'continuity-scope-unbound']) {
    const observation = observations.get(id);
    writeText(path.join(evidence, `raw/${id}-restore.term`), `${observation.projection}\n`);
    writeText(path.join(evidence, `raw/${id}-service-output.txt`), observation.output);
  }
  writeJson(path.join(evidence, 'commands.json'), commands);
  writeJson(path.join(evidence, 'results.json'), {
    schema: 'miter-ama12-four-plane-continuity-results-v1', status, results
  });
  const sourcePaths = [
    'config/miter-assistant-continuity-v1.json',
    'effect_membranes/miter_assistant_continuity_v1.pl',
    'effect_membranes/miter_assistant_service_v1.pl',
    'effect_membranes/miter_assistant_operator_v1.pl',
    'effect_membranes/miter_continuity.pl',
    'effect_membranes/miter_store.pl',
    'src/assistant_scope_continuity_v1.metta',
    'src/assistant_reactor_v1.metta',
    'src/constitutive_participation_v1.metta',
    'src/bootstrap_assistant_v1.metta',
    'tests/fixtures/ama1_2/scope-bindings.json',
    'tests/fixtures/ama1_2/scope-contact-v3.json',
    'tests/fixtures/g08_manuscript.md',
    'scripts/ama1_2/four_plane_continuity.mjs'
  ];
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama12-four-plane-continuity-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    plan_commit: '61c1c21fc19b0b1d8bb84b46e717be2642c52499',
    simulated_gap: '2026-06-02 to 2026-09-05',
    external_network_calls: 0, model_calls: 0, chroma_calls: 0,
    private_memory_reads: 0, external_effects: 0,
    sources: sourcePaths.map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}))
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama12-four-plane-continuity-verdict-v1', status,
    facts: {
      exact_capsule_trajectory_and_artifact_are_joined_before_contact_cognition: true,
      declared_semantic_unavailability_does_not_cause_amnesia: true,
      continuity_relations_change_D_I_W_C_flourishing_and_RAP_movement_material: true,
      balance_fact9_flourishing_and_RAP_remain_one_forming_movement: true,
      restart_preserves_the_exact_developmental_cut_without_effect_replay: true,
      another_authorized_scope_cannot_inherit_the_alpha_capsule: true,
      changed_or_missing_artifacts_hold_startup_before_ordinary_cognition: true,
      corrupt_trajectory_holds_startup_before_ordinary_cognition: true,
      unbound_continuity_source_holds_startup_before_ordinary_cognition: true,
      no_live_private_model_or_network_authority_was_exercised: true
    },
    standing: 'Controlled-fixture proof that exact operational continuity is a constitutive participant in the supported persistent assistant. Semantic memory is represented only by an unavailable standing in this checkpoint; no Chroma retrieval, general language, live Mattermost, or full AMA-1.2 claim is established.',
    next_boundary: 'Introduce bounded semantic-memory products as non-authoritative participant readings, including degradation and same-lineage controls, through this same running assistant.'
  });
}

console.log(JSON.stringify({status, cases: results.length,
  evidence: record ? evidence : null}));
