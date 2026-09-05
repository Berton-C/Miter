// Builder-side AMA-1.2 bounded semantic-participation trial.
// Controlled local fixtures only; never imported by Miter.

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
const evidence = path.join(repo, 'evidence/AMA-1.2/R1/semantic-participation-002');
const record = process.argv.includes('--record');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const clone = value => JSON.parse(JSON.stringify(value));
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const commands = [];
const observations = new Map();

const bindingAlpha = {
  binding_id: 'binding-fixture-alpha', carrier_kind: 'controlled-fixture',
  server_id: 'fixture-server-alpha', team_id: 'fixture-team-alpha',
  channel_id: 'fixture-channel-alpha', principal_id: 'fixture-user-alpha',
  principal: 'principal-alpha', audience: 'audience-alpha', project: 'project-alpha',
  standing: 'authorized'
};

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
  assert.equal(observed, expected, `${name}: mechanical standing`);
  return observed;
}

function probe(name, predicate, root) {
  const goal = `${predicate}(${prologAtom(root)},R),write_canonical(R),nl,halt`;
  const result = run(name, '/opt/homebrew/bin/swipl', ['-q', '-s', service, '-g', goal]);
  assert.equal(result.code, 0, `${name}: probe process`);
  assert.equal(result.stderr, '', `${name}: probe stderr`);
  return result.stdout.trim();
}

function continuitySource(root, semanticStanding) {
  return {
    source_id: 'continuity-source-alpha',
    principal: 'principal-alpha', audience: 'audience-alpha', project: 'project-alpha',
    capsule_store: path.join(root, 'continuity/capsules'),
    trajectory_store: path.join(root, 'continuity/trajectory'),
    semantic_collection: 'miter-ltm-alpha',
    embedding_profile: 'nomic-embed-text-v1.5',
    semantic_standing: semanticStanding,
    undertaking_id: 'thread-undertaking-alpha',
    attention_id: 'attention-observatory-decision',
    rna_id: 'rna-observatory-continuation',
    relationships: ['relationship-human-book-collaboration'],
    open_alternatives: ['alternative-reveal-key', 'alternative-withhold-key'],
    pending_consequences: ['consequence-reader-trust-unobserved'],
    learned_relations: ['relation-key-warmth-foreshadows-access']
  };
}

function memoryResult(root, spec) {
  const sourceRef = path.join(root, 'semantic/material', `${spec.id}-source.txt`);
  const bodyRef = path.join(root, 'semantic/material', `${spec.id}-body.txt`);
  writeText(sourceRef, `Controlled canonical source for ${spec.id}.\n`);
  writeText(bodyRef, `Controlled participant material for ${spec.id}.\n`);
  return {
    memory_id: spec.id,
    principal: 'principal-alpha', audience: 'audience-alpha', project: 'project-alpha',
    source_kind: spec.source_kind ?? 'canonical-memory',
    source_ref: sourceRef, source_sha256: fileHash(sourceRef),
    body_ref: bodyRef, body_sha256: fileHash(bodyRef),
    lineage: spec.lineage,
    claim: {kind: 'relation', target: spec.target ?? 'relation-opportunity',
      proposed_standing: spec.proposed ?? 'support', evidence: spec.evidence},
    standing: spec.standing ?? 'supported'
  };
}

function setupRuntime(id, options = {}) {
  const standing = options.standing ?? 'available';
  const root = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-semantic-${id}-`));
  const stimulusRoot = fs.mkdtempSync(path.join(os.tmpdir(), `miter-ama12-semantic-input-${id}-`));
  const boot = op(`${id}:bootstrap`, ['bootstrap', '--runtime-root', root]);
  assert.equal(boot.code, 0, `${id}: bootstrap process`);
  assert.equal(boot.reply?.status, 'bootstrapped', `${id}: bootstrap standing`);

  const artifact = path.join(root, 'artifacts/glass-archive.md');
  fs.mkdirSync(path.dirname(artifact), {recursive: true});
  fs.copyFileSync(manuscriptFixture, artifact);
  fs.chmodSync(artifact, 0o600);
  const artifactHash = fileHash(artifact);
  const trajectory = path.join(root, 'continuity/trajectory');
  const capsuleStore = path.join(root, 'continuity/capsules');
  const extension = path.join(root, 'lib/libmiter_store_posix.dylib');
  const setup = path.join(root, 'setup');
  const eventId = 'evt-continuity-alpha-0001';
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

  const capsuleBase = {
    schema: 'miter-project-continuity-fixture-v1', project_id: 'project-alpha',
    project_name: 'The Glass Archive',
    project_purpose: 'Continue a continuity-preserving speculative novel draft.',
    current_artifact_ref: artifact, current_artifact_hash: artifactHash,
    open_questions: ['Should Mara reveal the archive key?'],
    live_tensions: ['Trust versus protecting the archive secret.'], blocked_by: [],
    commitments: ['Keep the key warmth consistent.'], relevant_memory_ids: [],
    relevant_event_ids: [eventId], principal_scope: 'principal-alpha',
    audience_scope: 'audience-alpha'
  };
  const priorPath = path.join(setup, 'capsule-prior.json');
  writeJson(priorPath, {...capsuleBase, capsule_id: 'capsule-alpha-prior',
    current_goal: 'Establish Mara arrival at the observatory.',
    exact_location: 'Chapter 3 / The Observatory / paragraph 1',
    last_completed_work: 'Drafted Mara reaching the ruined observatory.',
    next_intended_movement: 'Draft the observatory threshold.',
    previous_capsule_id: 'none', supersedes_capsule_id: 'none',
    created_at: '2026-06-01T10:00:00Z', status: 'active'});
  const capsulePath = path.join(setup, 'capsule-current.json');
  writeJson(capsulePath, {...capsuleBase, capsule_id: 'capsule-alpha-current',
    current_goal: 'Resolve Mara choice about revealing the archive key.',
    exact_location: 'Chapter 3 / The Observatory / paragraph 4 decision beat',
    last_completed_work: 'Revised the observatory entrance.',
    next_intended_movement: 'Draft and test the decision beat.',
    previous_capsule_id: 'capsule-alpha-prior',
    supersedes_capsule_id: 'capsule-alpha-prior',
    created_at: '2026-06-02T10:05:00Z', status: 'current'});
  mechanic(`${id}:append-prior-capsule`, 'miter_continuity_write_capsule',
    [capsuleStore, extension, priorPath], 'capsule-appended');
  mechanic(`${id}:append-current-capsule`, 'miter_continuity_write_capsule',
    [capsuleStore, extension, capsulePath], 'capsule-appended');
  mechanic(`${id}:select-capsule`, 'miter_continuity_set_current',
    [capsuleStore, extension, 'project-alpha', 'capsule-alpha-current'],
    'current-capsule-selected');

  const results = standing === 'available'
    ? (options.specs ?? []).map(spec => memoryResult(root, spec)) : [];
  let observation = {
    schema: 'miter-assistant-semantic-observation-v1',
    source_id: 'semantic-source-alpha', principal: 'principal-alpha',
    audience: 'audience-alpha', project: 'project-alpha',
    collection: 'miter-ltm-alpha', embedding_profile: 'nomic-embed-text-v1.5',
    standing, reason: options.reason ?? (standing === 'available'
      ? 'verified-controlled-observation' : `semantic-index-${standing}`),
    query_id: `query-${id}`, results
  };
  if (options.mutateObservation) observation = options.mutateObservation(observation, {root}) ?? observation;
  const observationPath = path.join(root, 'semantic/observation.json');
  writeJson(observationPath, observation);
  let semanticSource = {
    source_id: 'semantic-source-alpha', principal: 'principal-alpha',
    audience: 'audience-alpha', project: 'project-alpha',
    observation_path: observationPath, observation_sha256: fileHash(observationPath)
  };
  if (options.mutateSemanticSource) {
    semanticSource = options.mutateSemanticSource(semanticSource, {root}) ?? semanticSource;
  }
  const scopeDocument = {
    schema: 'miter-assistant-scope-bindings-v1',
    authority_mode: 'controlled-fixture-only', bindings: [bindingAlpha],
    continuity_sources: [continuitySource(root, standing)],
    semantic_sources: [semanticSource]
  };
  writeJson(path.join(root, 'scope-bindings.json'), scopeDocument);
  const state = {root, stimulusRoot, artifact, artifactHash, trajectory,
    capsuleStore, eventId, observationPath, observation, semanticSource, results};
  if (options.mutateAfter) options.mutateAfter(state);
  return state;
}

function start(root, id) {
  const result = op(`${id}:start`, ['start', '--runtime-root', root]);
  assert.equal(result.code, 0, `${id}: start process`);
  assert.equal(result.reply?.status, 'started', `${id}: start standing`);
}

function submit(root, stimulusRoot, id) {
  const stimulus = clone(JSON.parse(fs.readFileSync(contactFixture, 'utf8')));
  stimulus.input_id = `input-semantic-${id}`;
  stimulus.surface.post_id = `contact-semantic-${id}`;
  stimulus.surface.thread_id = `thread-semantic-${id}`;
  stimulus.contact.id = `contact-semantic-${id}`;
  stimulus.contact.occurrence = `occurrence-semantic-${id}`;
  stimulus.contact.proto = `proto-semantic-${id}`;
  stimulus.contact.payload_ref = `payload-semantic-${id}`;
  const file = path.join(stimulusRoot, `${id}.json`);
  writeJson(file, stimulus);
  const result = op(`${id}:submit`, ['submit', '--runtime-root', root, '--event', file]);
  return {stimulus, file, result};
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

function stop(root, id, command = 'panic') {
  const result = op(`${id}:${command}`, [command, '--runtime-root', root]);
  assert.ok(['panicked', 'stopped'].includes(result.reply?.status), `${id}: ${command}`);
}

function serviceOutput(root) {
  const directory = path.join(root, 'logs');
  return fs.readdirSync(directory)
    .filter(name => /^service-.*\.(?:stdout|stderr)$/.test(name)).sort()
    .map(name => fs.readFileSync(path.join(directory, name), 'utf8')).join('\n');
}

async function integratedCase(id, options, required, forbidden = [], restart = false) {
  const state = setupRuntime(id, options);
  const semanticProjection = probe(`${id}:semantic-projection`,
    'miter_assistant_semantic_restore', state.root);
  for (const token of ['semantic-source-set-v1', 'semantic-projection-v1',
    'rank-not-authority', options.standing ?? 'available']) {
    assert.ok(semanticProjection.includes(token), `${id}: projection missing ${token}`);
  }
  start(state.root, id);
  const sent = submit(state.root, state.stimulusRoot, id);
  assert.equal(sent.result.reply?.status, 'queued', `${id}: contact not queued`);
  assert.equal(await waitCheckpoint(state.root, sent.stimulus.input_id), true,
    `${id}: native checkpoint not reached`);
  const checkpointPath = path.join(state.root, 'checkpoints/active.term');
  const checkpoint = fs.readFileSync(checkpointPath, 'utf8');
  for (const token of ['capsule-alpha-current', state.artifactHash,
    'exact-authoritative', 'semantic-standing-summary', 'rank-not-authority',
    'no-contact', 'no-movement-authority', 'balance-unfolding-as-intelligence',
    'fact9-participation', 'flourishing-participation', 'rap-readings', ...required]) {
    assert.ok(checkpoint.includes(token), `${id}: checkpoint missing ${token}`);
  }
  for (const token of forbidden) {
    assert.ok(!checkpoint.includes(token), `${id}: checkpoint contains forbidden ${token}`);
  }
  assert.ok(!checkpoint.includes('similarity-score'), `${id}: score entered native state`);
  assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 1,
    `${id}: local effect count`);
  const checkpointHash = fileHash(checkpointPath);
  let replayedEffects = null;
  if (restart) {
    const effectName = jsonFiles(path.join(state.root, 'outbox'))[0];
    const effectPath = path.join(state.root, 'outbox', effectName);
    const effectHash = fileHash(effectPath);
    stop(state.root, id, 'stop');
    const restarted = op(`${id}:restart`, ['start', '--runtime-root', state.root]);
    assert.equal(restarted.reply?.status, 'started', `${id}: restart standing`);
    await sleep(700);
    assert.equal(fileHash(checkpointPath), checkpointHash, `${id}: checkpoint changed`);
    assert.equal(fileHash(effectPath), effectHash, `${id}: effect changed`);
    assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 1,
      `${id}: effect replayed`);
    replayedEffects = 0;
  }
  stop(state.root, id);
  observations.set(id, {state, semanticProjection, checkpointPath, checkpointHash});
  return {id, standing: options.standing ?? 'available',
    observed: 'constitutive-participant-incorporated', exact_continuity: true,
    rank_authority: false, restart_stable: restart, replayed_effects: replayedEffects};
}

async function heldSemanticCase(id, options, reason) {
  const state = setupRuntime(id, options);
  const projection = probe(`${id}:semantic-projection`,
    'miter_assistant_semantic_restore', state.root);
  assert.ok(projection.includes('semantic-source-set-held'), `${id}: source did not hold`);
  assert.ok(projection.includes(reason), `${id}: missing reason ${reason}`);
  const attempted = op(`${id}:start`, ['start', '--runtime-root', state.root]);
  assert.equal(attempted.reply?.status, 'start-failed', `${id}: startup did not fail closed`);
  await sleep(500);
  assert.equal(fs.existsSync(path.join(state.root, 'checkpoints/active.term')), false,
    `${id}: invalid semantic source reached checkpoint`);
  assert.equal(jsonFiles(path.join(state.root, 'outbox')).length, 0,
    `${id}: invalid semantic source produced effect`);
  const output = serviceOutput(state.root);
  assert.ok(output.includes(reason), `${id}: native startup omitted mechanical reason`);
  observations.set(id, {state, semanticProjection: projection, output});
  return {id, standing: 'startup-held-before-ordinary-cognition', reason,
    checkpoint: false, local_effects: 0};
}

function continuityReasonCase(id, mutate, reason) {
  const state = setupRuntime(id, {standing: 'unavailable'});
  mutate(state);
  const projection = probe(`${id}:continuity-projection`,
    'miter_assistant_continuity_restore', state.root);
  assert.ok(projection.includes('continuity-source-set-held'), `${id}: continuity did not hold`);
  assert.ok(projection.includes(reason), `${id}: missing differentiated reason ${reason}`);
  observations.set(id, {state, continuityProjection: projection});
  return {id, standing: 'differentiated-mechanical-hold', reason};
}

assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');
if (record && fs.existsSync(evidence)) throw Error('semantic evidence already exists');

const independentSpecs = [
  {id: 'memory-source-a', lineage: ['source-a', 'revision-one'],
    evidence: 'memory-source-a-evidence'},
  {id: 'memory-source-a-repeat', lineage: ['source-a', 'revision-one'],
    evidence: 'memory-source-a-repeat-evidence'},
  {id: 'memory-consequence-b', lineage: ['consequence-b', 'observation-one'],
    source_kind: 'episode', evidence: 'memory-consequence-b-evidence'}
];
const sameLineageSpecs = independentSpecs.slice(0, 2);

const results = [];
results.push(await integratedCase('independent-support',
  {standing: 'available', specs: independentSpecs},
  ['memory-source-a', 'memory-source-a-repeat', 'memory-consequence-b',
    'participant-supported-relation', 'relation-opportunity', 'independent-lineages'],
  [], true));
results.push(await integratedCase('same-lineage-repetition',
  {standing: 'available', specs: sameLineageSpecs},
  ['participant-proposed-relation', 'same-lineage-not-independent',
    'constitutive-inquiry'],
  ["'participant-supported-relation','relation-opportunity'"]));
results.push(await integratedCase('contradiction-retained',
  {standing: 'available', specs: [independentSpecs[0],
    {id: 'memory-counter-c', lineage: ['counter-c', 'observation-one'],
      evidence: 'memory-counter-c-evidence', proposed: 'contradiction',
      standing: 'contradicted'}]},
  ['participant-relation-conflict', 'support-and-contradiction-retained',
    'constitutive-inquiry']));
for (const standing of ['unavailable', 'degraded', 'incompatible']) {
  results.push(await integratedCase(`semantic-${standing}`,
    {standing, reason: `semantic-index-${standing}`},
    ['semantic-source-alpha', `semantic-index-${standing}`,
      'relation-semantic-memory-availability', 'participant-proposed-relation']));
}
results.push(await heldSemanticCase('wrong-result-scope', {
  standing: 'available', specs: [independentSpecs[0]],
  mutateObservation(value) { value.results[0].principal = 'principal-beta'; return value; }
}, 'semantic-result-scope-lineage-or-standing-invalid'));
results.push(await heldSemanticCase('changed-result-body', {
  standing: 'available', specs: [independentSpecs[0]],
  mutateAfter({results: rows}) { fs.appendFileSync(rows[0].body_ref, 'changed\n'); }
}, 'semantic-result-body-hash-mismatch'));
results.push(await heldSemanticCase('changed-observation', {
  standing: 'available', specs: [independentSpecs[0]],
  mutateAfter({observationPath}) { fs.appendFileSync(observationPath, '\n'); }
}, 'semantic-observation-hash-mismatch'));
results.push(await heldSemanticCase('rank-field-rejected', {
  standing: 'available', specs: [independentSpecs[0]],
  mutateObservation(value) { value.results[0].rank = 1; return value; }
}, 'semantic-result-schema-invalid'));
results.push(await heldSemanticCase('semantic-scope-unbound', {
  standing: 'unavailable',
  mutateSemanticSource(value) {
    value.principal = 'principal-beta'; value.audience = 'audience-beta';
    value.project = 'project-beta'; return value;
  }
}, 'semantic-source-scope-unbound'));

results.push(continuityReasonCase('continuity-artifact-changed', ({artifact}) => {
  fs.appendFileSync(artifact, 'changed\n');
}, 'raw-artifact-hash-mismatch'));
results.push(continuityReasonCase('continuity-artifact-missing', ({artifact}) => {
  fs.renameSync(artifact, `${artifact}.unavailable`);
}, 'raw-artifact-unavailable'));
results.push(continuityReasonCase('continuity-trajectory-corrupt', ({trajectory}) => {
  fs.appendFileSync(path.join(trajectory, 'trajectory.jsonl'), '{"malformed":true}\n');
}, 'trajectory-integrity-or-scope-invalid'));
results.push(continuityReasonCase('continuity-source-unbound', ({root}) => {
  const document = JSON.parse(fs.readFileSync(path.join(root, 'scope-bindings.json'), 'utf8'));
  document.bindings = [{...bindingAlpha, binding_id: 'binding-fixture-beta',
    channel_id: 'fixture-channel-beta', principal_id: 'fixture-user-beta',
    principal: 'principal-beta', audience: 'audience-beta', project: 'project-beta'}];
  writeJson(path.join(root, 'scope-bindings.json'), document);
}, 'continuity-source-scope-unbound'));

const status = results.every(row => [
  'constitutive-participant-incorporated',
  'startup-held-before-ordinary-cognition',
  'differentiated-mechanical-hold'
].includes(row.observed ?? row.standing)) ? 'PASS-BOUNDED' : 'FAIL';
assert.equal(status, 'PASS-BOUNDED');

if (record) {
  fs.mkdirSync(path.join(evidence, 'raw'), {recursive: true});
  for (const id of ['independent-support', 'same-lineage-repetition',
    'contradiction-retained', 'semantic-unavailable', 'semantic-degraded',
    'semantic-incompatible']) {
    const observation = observations.get(id);
    fs.copyFileSync(observation.checkpointPath,
      path.join(evidence, `raw/${id}-checkpoint.term`));
    writeText(path.join(evidence, `raw/${id}-semantic-projection.term`),
      `${observation.semanticProjection}\n`);
  }
  for (const id of ['wrong-result-scope', 'changed-result-body',
    'changed-observation', 'rank-field-rejected', 'semantic-scope-unbound']) {
    const observation = observations.get(id);
    writeText(path.join(evidence, `raw/${id}-semantic-projection.term`),
      `${observation.semanticProjection}\n`);
    writeText(path.join(evidence, `raw/${id}-service-output.txt`), observation.output);
  }
  for (const id of ['continuity-artifact-changed', 'continuity-artifact-missing',
    'continuity-trajectory-corrupt', 'continuity-source-unbound']) {
    writeText(path.join(evidence, `raw/${id}-projection.term`),
      `${observations.get(id).continuityProjection}\n`);
  }
  writeJson(path.join(evidence, 'commands.json'), commands);
  writeJson(path.join(evidence, 'results.json'), {
    schema: 'miter-ama12-semantic-participation-results-v1', status, results
  });
  const sourcePaths = [
    'config/miter-assistant-continuity-v1.json',
    'effect_membranes/miter_assistant_continuity_v1.pl',
    'effect_membranes/miter_assistant_semantic_v1.pl',
    'effect_membranes/miter_assistant_service_v1.pl',
    'effect_membranes/miter_assistant_operator_v1.pl',
    'effect_membranes/miter_continuity.pl',
    'effect_membranes/miter_store.pl',
    'src/assistant_scope_continuity_v1.metta',
    'src/assistant_semantic_participation_v1.metta',
    'src/assistant_reactor_v1.metta',
    'src/constitutive_participation_v1.metta',
    'src/bootstrap_assistant_v1.metta',
    'tests/fixtures/ama1_2/scope-bindings.json',
    'tests/fixtures/ama1_2/scope-contact-v3.json',
    'tests/fixtures/g08_manuscript.md',
    'scripts/ama1_2/semantic_participation.mjs'
  ];
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama12-semantic-participation-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    plan_commit: '61c1c21fc19b0b1d8bb84b46e717be2642c52499',
    checkpoint_base_commit: 'e3d6d189',
    external_network_calls: 0, model_calls: 0, chroma_calls: 0,
    private_memory_reads: 0, external_effects: 0,
    sources: sourcePaths.map(relative => ({path: relative,
      sha256: fileHash(path.join(repo, relative))}))
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama12-semantic-participation-verdict-v1', status,
    facts: {
      exact_scope_source_and_body_hashes_are_verified_before_native_reentry: true,
      semantic_products_reenter_as_memory_participants_without_contact_or_movement_authority: true,
      independent_lineages_can_support_a_relation_without_vector_rank_selecting_movement: true,
      repeated_same_lineage_material_does_not_manufacture_independent_warrant: true,
      contradiction_remains_explicit_and_forms_inquiry: true,
      unavailable_degraded_and_incompatible_sources_remain_differentiated: true,
      exact_continuity_survives_each_nonavailable_semantic_state: true,
      wrong_scope_changed_bytes_and_rank_fields_hold_before_ordinary_cognition: true,
      continuity_mechanical_failures_now_reach_native_startup_with_differentiated_reasons: true,
      restart_preserves_the_constitutive_result_without_effect_replay: true,
      balance_rap_fact9_flourishings_semantic_participants_and_continuity_form_one_movement: true,
      no_live_private_model_chroma_or_network_authority_was_exercised: true
    },
    standing: 'Controlled-fixture proof that verified semantic-memory products participate in the same native constitutive movement as exact Continuity of Mind, with scope, lineage, conflict, degradation, and non-authority preserved. It does not establish live Chroma retrieval, natural-language grounding, model participation, live Mattermost, or AMA-1.2 closure.',
    next_boundary: 'Join bounded language/model participant construction to unfamiliar contact through the same persistent assistant, then freeze the exact live-authority proposal before any provider or Mattermost access.'
  });
}

console.log(JSON.stringify({status, cases: results.length,
  evidence: record ? evidence : null}));
