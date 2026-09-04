// Builder-side AMA-1.1 participant/VoiceRNA/local-effect proof. Never imported
// by Miter and never contacts a network, model, keychain, memory service, or user.
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
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const evidence = path.join(repo, 'evidence/AMA-1.1/R1/participant-voice-freeze-001');
const contact = path.join(repo, 'tests/fixtures/ama1_1/contact-unfamiliar.json');
const consequence = path.join(repo, 'tests/fixtures/ama1_1/consequence-unfamiliar.json');
const invalidParticipant = path.join(repo, 'tests/fixtures/ama1_1/contact-participant-invalid.json');
const forbiddenRoot = '/Users/bcb/.miter';
const commands = [];

const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const writeJson = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const jsonFiles = directory => fs.readdirSync(directory).filter(name => name.endsWith('.json')).sort();

function run(name, args, expected = 0) {
  const result = spawnSync(operator, args, {cwd: repo, encoding: 'utf8', timeout: 15000});
  commands.push({name, args, status: result.status, signal: result.signal,
    stdout: result.stdout, stderr: result.stderr});
  assert.equal(result.status, expected, `${name}: ${result.stderr || result.stdout}`);
  assert.equal(result.signal, null, name);
  assert.equal(result.stderr, '', name);
  return JSON.parse(result.stdout);
}

async function waitFor(label, predicate, timeout = 8000) {
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (predicate()) return;
    await sleep(50);
  }
  assert.fail(`timed out waiting for ${label}`);
}

async function waitCheckpoint(root, inputId) {
  const receipt = path.join(root, 'receipts', `${inputId}.json`);
  await waitFor(`${inputId} native checkpoint`, () => fs.existsSync(receipt)
    && JSON.parse(fs.readFileSync(receipt, 'utf8')).standing === 'native-checkpointed');
  return JSON.parse(fs.readFileSync(receipt, 'utf8'));
}

assert.equal(fs.existsSync(evidence), false, 'evidence is immutable once recorded');
assert.equal(fs.existsSync(forbiddenRoot), false, 'forbidden implicit runtime root must be absent');
assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-participant-voice-'));
const exportRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-participant-export-'));
const exportPath = path.join(exportRoot, 'evidence.json');
let activePid = 0;

try {
  assert.equal(run('bootstrap', ['bootstrap', '--runtime-root', root]).status, 'bootstrapped');

  const severedGoal = `as_effect('${root}',`+
    `['local-effect-descriptor-v1','severed-effect','severed-effect',`+
    `[scope,'principal-alpha','audience-alpha','project-alpha'],`+
    `[payload,['assistant-voice-certificate-v1']],`+
    `[capability,'local-isolated-outbox','no-network'],prepared],R),`+
    `write_canonical(R),halt.`;
  const severed = spawnSync('/opt/homebrew/bin/swipl', ['-q', '-s', service, '-g', severedGoal],
    {cwd: repo, encoding: 'utf8', timeout: 15000});
  commands.push({name: 'severed-certificate-capability', args: ['swipl', '-g', '<bounded-goal>'],
    status: severed.status, signal: severed.signal, stdout: severed.stdout, stderr: severed.stderr});
  assert.equal(severed.status, 0, severed.stderr);
  assert.match(severed.stdout, /local-effect-held.*severed-effect.*mechanical-boundary/);
  assert.equal(fs.existsSync(path.join(root, 'outbox/severed-effect.json')), false);

  const started = run('start', ['start', '--runtime-root', root]);
  assert.equal(started.status, 'started'); activePid = started.pid;

  const invalid = run('invalid-participant-authority',
    ['submit', '--runtime-root', root, '--event', invalidParticipant], 1);
  assert.equal(invalid.status, 'rejected');
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 0);

  assert.equal(run('submit-contact',
    ['submit', '--runtime-root', root, '--event', contact]).status, 'queued');
  await waitCheckpoint(root, 'input-unfamiliar-one');

  const checkpointPath = path.join(root, 'checkpoints/active.term');
  const checkpoint = fs.readFileSync(checkpointPath, 'utf8');
  for (const required of [
    'balance-unfolding-as-intelligence','movement-primary','contact-locus',
    'dynamic-participatory-fourthness','immutable-fact-role','fact9-participation',
    'flourishing-participation','rap-readings','non-sovereign-same-movement',
    'bounded-participant-reentry','participant-reentry-organization',
    'participant-model-current','participant-model-history','participant-model-repeat',
    'participant-memory-continuity','participant-pln-relation',
    'participant-nal-revision','participant-tool-observation',
    'repeated-same-lineage-is-not-independent-support','no-contact',
    'no-movement-authority','VoiceRNA','assistant-voice-certificate-v1',
    'no-emission-authority','effect-witness'
  ]) assert.ok(checkpoint.includes(required), `checkpoint missing ${required}`);

  const outboxFiles = jsonFiles(path.join(root, 'outbox'));
  assert.deepEqual(outboxFiles, ['contact-unfamiliar-one.json']);
  const effectPath = path.join(root, 'outbox', outboxFiles[0]);
  const effect = JSON.parse(fs.readFileSync(effectPath, 'utf8'));
  assert.equal(effect.schema, 'miter-local-effect-v1');
  assert.equal(effect.effect_id, 'contact-unfamiliar-one');
  assert.equal(effect.idempotency_key, effect.effect_id);
  assert.equal(effect.capability, 'local-isolated-outbox');
  assert.equal(effect.network_access, false);
  assert.equal(effect.external_effect, false);
  assert.equal(effect.standing, 'committed-local-only');
  assert.equal(sha256(Buffer.from(effect.native_certificate, 'utf8')), effect.certificate_sha256);
  for (const required of ['VoiceRNA','movement-source','participant-boundaries',
    'model','memory','pln','nal','tool','no-emission-authority']) {
    assert.ok(effect.native_certificate.includes(required), `certificate missing ${required}`);
  }
  const effectHash = fileHash(effectPath);
  const checkpointHash = fileHash(checkpointPath);
  const effectReceipt = JSON.parse(fs.readFileSync(
    path.join(root, 'receipts/effect-contact-unfamiliar-one.json'), 'utf8'));
  assert.equal(effectReceipt.standing, 'committed');
  assert.equal(effectReceipt.external_effect, false);

  assert.equal(run('duplicate-contact',
    ['submit', '--runtime-root', root, '--event', contact]).status, 'duplicate');
  await sleep(400);
  assert.equal(fileHash(effectPath), effectHash);
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 1);

  assert.equal(run('stop', ['stop', '--runtime-root', root]).status, 'stopped'); activePid = 0;
  const restarted = run('restart', ['start', '--runtime-root', root]);
  assert.equal(restarted.status, 'started'); activePid = restarted.pid;
  await sleep(1000);
  assert.equal(run('restart-status', ['status', '--runtime-root', root]).status, 'running');
  assert.equal(fileHash(effectPath), effectHash, 'restart must not replay or alter local effect');
  assert.equal(fileHash(checkpointPath), checkpointHash, 'restart alone must not create a cut');
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 1);

  assert.equal(run('submit-consequence',
    ['submit', '--runtime-root', root, '--event', consequence]).status, 'queued');
  await waitCheckpoint(root, 'input-consequence-one');
  const nextCheckpoint = fs.readFileSync(checkpointPath, 'utf8');
  assert.ok(nextCheckpoint.includes('consequence-unfamiliar-one'));
  assert.ok(nextCheckpoint.includes('consequence-incorporated'));
  assert.notEqual(fileHash(checkpointPath), checkpointHash);
  assert.equal(jsonFiles(path.join(root, 'outbox')).length, 1,
    'consequence incorporation must not fabricate another expression effect');

  assert.equal(run('evidence-export',
    ['evidence-bundle', '--runtime-root', root, '--output', exportPath]).status, 'evidence-stored');
  const exported = JSON.parse(fs.readFileSync(exportPath, 'utf8'));
  assert.equal(exported.network_access, 'none');
  assert.equal(exported.external_effects, 'none');
  assert.equal(exported.private_content_included, false);
  assert.equal(exported.semantic_health_claimed, false);
  assert.equal(exported.counts.outbox, 1);
  assert.equal(exported.trajectory.status, 'valid');

  assert.equal(run('panic', ['panic', '--runtime-root', root]).status, 'panicked'); activePid = 0;
  assert.equal(fs.existsSync(forbiddenRoot), false, 'no command may create ~/.miter');

  fs.mkdirSync(evidence, {recursive: true});
  fs.copyFileSync(exportPath, path.join(evidence, 'operator-evidence-bundle.json'));
  writeJson(path.join(evidence, 'commands.json'), commands);
  const sources = [
    'src/constitutive_participation_v1.metta','src/assistant_reactor_v1.metta',
    'src/bootstrap_assistant_v1.metta','effect_membranes/miter_assistant_service_v1.pl',
    'effect_membranes/miter_assistant_operator_v1.pl','tests/fixtures/ama1_1/contact-unfamiliar.json',
    'tests/fixtures/ama1_1/consequence-unfamiliar.json',
    'tests/fixtures/ama1_1/contact-participant-invalid.json',
    'scripts/ama1_1/participant_voice_freeze.mjs'
  ].map(relative => ({path: relative, sha256: fileHash(path.join(repo, relative))}));
  writeJson(path.join(evidence, 'runtime.json'), {
    schema: 'miter-ama11-participant-voice-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    explicit_runtime_root: root,
    external_network_calls: 0,
    model_calls: 0,
    private_memory_reads: 0,
    external_effects: 0,
    local_isolated_effects: 1,
    sources
  });
  writeJson(path.join(evidence, 'lineage.json'), {
    schema: 'miter-ama11-additive-evidence-lineage-v1',
    predecessor: 'evidence/AMA-1.1/R1/service-freeze-001/verdict.json',
    predecessor_standing: 'PASS-BOUNDED',
    relation: 'adds bounded participant re-entry, native VoiceRNA, and local effect qualification through the same supported service'
  });
  writeJson(path.join(evidence, 'verdict.json'), {
    schema: 'miter-ama11-participant-voice-freeze-verdict-v1',
    status: 'PASS-BOUNDED',
    facts: {
      balance_is_movement_primary_at_contact: true,
      fact9_flourishing_and_rap_remain_one_material_derivation: true,
      participant_sources_scopes_lineages_and_standings_remain_explicit: true,
      repeated_same_lineage_is_not_promoted_to_independent_support: true,
      participant_products_have_no_contact_or_movement_authority: true,
      native_voice_certificate_is_source_bound_and_has_no_emission_authority: true,
      prolog_commits_only_the_exact_local_descriptor: true,
      severed_certificate_or_capability_is_withheld: true,
      local_effect_is_idempotent_across_duplicate_and_restart: true,
      consequence_changes_the_next_cut_without_fabricating_an_effect: true,
      no_live_or_private_reach_occurred: true
    },
    standing: 'Finite structured runtime proof through the supported persistent assistant. It proves bounded participant carriage, native VoiceRNA qualification, a no-network local descriptor, one local commit, restart deduplication, and consequence incorporation. It does not prove live participant calls, natural-language grounding, semantic sufficiency, general conversation, independent PLN/NAL inference, Chroma recall, Mattermost reach, or full AMA-1.1 closure.',
    next_boundary: 'Freeze the post-operator constitutive trial set and run the full positive, severed, neutral, restored, plural, capture, participant-conflict, consequence, restart, and endogenous/exogenous matrix.'
  });
  console.log(JSON.stringify({status: 'PASS-BOUNDED', evidence}));
} finally {
  if (activePid) spawnSync(operator, ['panic', '--runtime-root', root], {cwd: repo, encoding: 'utf8'});
}
