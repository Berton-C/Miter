// Builder-side AMA-1.2 R2 ratification and native causal-boundary trial.
// This script performs no network, credential, model, Chroma, or message call.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';
import {native, sexp} from '../g22_v2/common.mjs';

const repo = '/Users/claritymiter/miter';
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R2/plan.json';
const grantDocument = 'docs/operations/AMA-1.2-LIVE-GRANT.md';
const config = 'config/miter-assistant-mattermost-v1.example.json';
const modelConfig = 'config/model-resources-v1.json';
const evidence = path.join(repo, 'evidence/AMA-1.2/R2/ratified-grant-001');
const record = process.argv.includes('--record');
const runRoot = record ? evidence : fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama12-r2-grant-'));
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = relative => sha256(fs.readFileSync(path.join(repo, relative)));
const writeJson = (relative, value) => {
  const target = path.join(runRoot, relative);
  fs.mkdirSync(path.dirname(target), {recursive: true});
  fs.writeFileSync(target, `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
};
const clone = value => JSON.parse(JSON.stringify(value));
const asMetta = value => Array.isArray(value)
  ? `(${value.map(asMetta).join(' ')})`
  : typeof value === 'string' && /^[a-f0-9]{64}$/.test(value)
    ? JSON.stringify(value)
    : sexp(value);

const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
assert(!record || !fs.existsSync(evidence), 'recorded evidence is immutable');
fs.mkdirSync(runRoot, {recursive: true});

const grantConfig = JSON.parse(fs.readFileSync(path.join(repo, config), 'utf8'));
assert.equal(grantConfig.schema, 'miter-assistant-mattermost-grant-v2');
assert.equal(grantConfig.status, 'ratified-awaiting-private-binding-preflight-and-activation');
assert.deepEqual(grantConfig.principals.authorized_humans, ['berton_c', 'haley']);
assert.deepEqual(grantConfig.principals.required_group_membership,
  ['berton_c', 'haley', 'miter']);
assert.equal(grantConfig.consent.berton, 'ratified-2026-09-05');
assert.match(grantConfig.consent.haley, /^required-before-/);
assert.equal(grantConfig.continuity.canonical_retention,
  'durable-no-age-expiry-explicit-authorized-erasure-repair-or-migration-only');
assert.equal(grantConfig.continuity.thirty_day_action,
  'continuity-and-privacy-audit-no-implied-deletion');
assert.equal(grantConfig.models.initial_human_preference, 'openrouter-glm53');
assert.deepEqual(grantConfig.models.direction_scopes,
  ['one-call', 'conversation', 'undertaking', 'until-time']);
assert.equal(grantConfig.models.raw_model_output_authority, 'none');
assert.equal(grantConfig.inbound.channel_history_backfill, false);
assert.equal(grantConfig.inbound.bot_posts_are_contact, false);
assert.equal(grantConfig.continuity.chroma.other_collections, 'prohibited');
assert.equal(grantConfig.continuity.chroma.vector_rank_authority, false);
assert.equal(grantConfig.resource_bounds.first_segment_hours, 72);
assert.equal(grantConfig.resource_bounds.maximum_evaluation_hours, 168);
assert.equal(grantConfig.lifecycle.expiry,
  'pause-new-ingress-model-memory-and-effects-checkpoint-preserve-continuity');
assert.equal(grantConfig.lifecycle.forensic_checkpoint,
  'mandatory-at-72-hours-before-continuation');
assert.equal(grantConfig.approval.authority, 'berton-explicit');
assert.equal(grantConfig.approval.standing, 'ratified-2026-09-05');

const models = JSON.parse(fs.readFileSync(path.join(repo, modelConfig), 'utf8'));
assert.equal(models.selection.mode, 'human-direction-or-native-relational');
assert.equal(models.selection.operator_preference, 'openrouter-glm53');
assert.equal(models.selection.selected_model_output_authority, 'none');
assert.deepEqual(models.selection.direction_scopes,
  ['one-call', 'conversation', 'undertaking', 'until-time']);

const grantText = fs.readFileSync(path.join(repo, grantDocument), 'utf8');
for (const required of [
  'RATIFIED by Berton on 2026-09-05',
  'The grant supplies reach, limits, and mechanical capabilities. It does not decide',
  'one existing Mattermost group conversation whose exact membership is Berton, Haley, and the existing `miter` bot',
  'Missing Haley affirmation keeps payload cognition, memory admission, remote calls, and egress held.',
  'Canonical trajectory, admitted developmental memory, exact capsules, raw artifacts, and their correction/supersession lineage do not expire merely because time passes.',
  'GLM 5.3 is the initial human-preferred default.',
  'At 72 hours the runtime automatically pauses',
  'Miter does not renew or certify its own grant.',
  'The activation timestamp and 72-hour clock begin only when a durable activation witness is successfully committed.'
]) assert(grantText.includes(required), `grant document missing: ${required}`);

const args = [
  fileHash(plan),
  fileHash(grantDocument),
  fileHash(config),
  fileHash(modelConfig),
  grantConfig.authority_lineage.g31_closure_sha256,
  grantConfig.authority_lineage.candidate_sha256,
  grantConfig.authority_lineage.transport_sha256
];
for (const value of args) assert.match(value, /^[a-f0-9]{64}$/);
const mettaArgs = args.map(asMetta).join(' ');
const constructor = `(AMA12RatifiedGrantV2 ${mettaArgs})`;
const standing = value => `(AMA12RatifiedGrantStanding ${value} ${mettaArgs})`;
const boot = `!(import! &self "${repo}/src/bootstrap_mattermost_live_grant_v2.metta")\n`;
const constructed = native(runRoot, 'native-grant-construction',
  `!(result grant ${constructor})\n` +
  `!(let $grant ${constructor} (result standing ${standing('$grant')}))`, boot);
assert.equal(constructed.length, 2);
const grant = constructed[0][2];
const canonicalStanding = constructed[1][2];
assert.equal(grant[0], 'ama12-live-grant-v2');
assert.equal(canonicalStanding[0],
  'ama12-ratified-grant-ready-for-private-binding-and-preflight');

const change = (index, value) => {
  const next = clone(grant);
  next[index] = value;
  return next;
};
const alteredModelAuthority = clone(grant);
alteredModelAuthority[10][6][3] = 'movement-authority';
const alteredContinuity = clone(grant);
alteredContinuity[8][2] = ['retention', 'expires-after-days', 30];
const cases = {
  canonical: grant,
  'neutral-json-roundtrip': clone(grant),
  restored: grant,
  'activation-without-witness': change(20, ['activation', 'active']),
  'haley-consent-bypassed': change(5,
    ['consent', ['berton', 'affirmed-by-ratification'],
      ['haley', 'not-required']]),
  'continuity-age-expiry': alteredContinuity,
  'model-authority-escalation': alteredModelAuthority,
  'direct-model-to-effect': change(12,
    ['voice-effect', 'mattermost-create-post', 'raw-model-output-allowed']),
  'self-renewing-grant': change(15,
    ['forensic-lifecycle', 'automatic-renewal'])
};
const trialRows = native(runRoot, 'native-grant-trials',
  Object.entries(cases).map(([id, value]) =>
    `!(result ${id} ${standing(asMetta(value))})`).join('\n'), boot);
assert.equal(trialRows.length, Object.keys(cases).length);
const standings = Object.fromEntries(trialRows.map(row => [row[1], row[2]]));
for (const id of ['canonical', 'neutral-json-roundtrip', 'restored'])
  assert.equal(standings[id][0],
    'ama12-ratified-grant-ready-for-private-binding-and-preflight', id);
for (const id of ['activation-without-witness', 'haley-consent-bypassed',
  'continuity-age-expiry', 'model-authority-escalation',
  'direct-model-to-effect', 'self-renewing-grant'])
  assert.equal(standings[id][0], 'ama12-ratified-grant-held', id);

const results = {
  schema: 'miter-ama12-r2-ratified-grant-results-v1',
  status: 'PASS-RATIFIED-AWAITING-PRIVATE-BINDING-AND-PREFLIGHT',
  plan_sha256: args[0],
  grant_sha256: args[1],
  config_sha256: args[2],
  model_registry_sha256: args[3],
  native_standing: canonicalStanding[0],
  cases: Object.fromEntries(Object.entries(standings).map(([id, value]) =>
    [id, value[0]])),
  external_network_calls: 0,
  credential_lookups: 0,
  model_calls: 0,
  chroma_calls: 0,
  message_reads: 0,
  message_writes: 0,
  activated: false,
  berton_consent: 'affirmed',
  haley_consent: 'unresolved'
};

if (record) {
  writeJson('native-grant.json', {native: grant});
  writeJson('native-standing.json', {native: canonicalStanding});
  writeJson('native-trial-standings.json', {native: standings});
  writeJson('results.json', results);
  const sources = [
    plan, grantDocument, config, modelConfig,
    'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
    'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
    'src/mattermost_live_grant_v2.metta',
    'src/bootstrap_mattermost_live_grant_v2.metta',
    'scripts/ama1_2/live_grant_ratify.mjs',
    'docs/gates/G31/P9/R1/closure.json'
  ];
  writeJson('runtime.json', {
    schema: 'miter-ama12-r2-ratified-grant-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    opening_plan_commit: opening.plan_commit,
    external_network_calls: 0,
    credential_lookups: 0,
    model_calls: 0,
    chroma_calls: 0,
    message_reads: 0,
    message_writes: 0,
    sources: sources.map(relative => ({path: relative, sha256: fileHash(relative)}))
  });
  writeJson('verdict.json', {
    schema: 'miter-ama12-r2-ratified-grant-verdict-v1',
    status: results.status,
    facts: {
      ratification_and_activation_are_separate: true,
      two_principals_and_exact_shared_carrier_are_required: true,
      haley_disclosure_is_unresolved: true,
      canonical_continuity_has_no_age_expiry: true,
      human_model_direction_selects_a_participant_only: true,
      first_segment_forensic_pause_is_mandatory: true,
      causal_severance_holds_the_native_grant: true,
      no_live_authority_was_exercised: true
    },
    next_boundary: 'Resolve exact private group membership and obtain Haley disclosure affirmation before payload cognition, memory admission, model use, or egress.'
  });
}

console.log(JSON.stringify({status: results.status, cases: Object.keys(cases).length,
  grant_sha256: args[1], evidence: record ? evidence : null}));
