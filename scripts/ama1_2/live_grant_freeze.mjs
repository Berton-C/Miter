// Builder-side AMA-1.2 inactive live-grant construction and causal trial.
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
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R1/plan.json';
const proposal = 'docs/operations/AMA-1.2-LIVE-GRANT.md';
const config = 'config/miter-assistant-mattermost-v1.example.json';
const evidence = path.join(repo, 'evidence/AMA-1.2/R1/inactive-live-grant-004');
const record = process.argv.includes('--record');
const runRoot = record ? evidence : fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama12-grant-'));
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

assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');
assert(!record || !fs.existsSync(evidence), 'recorded evidence is immutable');
fs.mkdirSync(runRoot, {recursive: true});

const grantConfig = JSON.parse(fs.readFileSync(path.join(repo, config), 'utf8'));
assert.equal(grantConfig.schema, 'miter-assistant-mattermost-grant-v1');
assert.equal(grantConfig.status, 'inactive-awaiting-explicit-approval');
assert.equal(grantConfig.approval.standing, 'unresolved');
assert.equal(grantConfig.approval.approved_proposal_sha256, null);
assert.equal(grantConfig.approval.activation_authority, 'unresolved');
assert.equal(grantConfig.surface.origin, 'http://127.0.0.1:8065');
assert.equal(grantConfig.surface.origin_policy, 'loopback-only');
assert.equal(grantConfig.project_bindings.length, 1);
assert.equal(grantConfig.project_bindings[0].project, 'miter-evaluation-v1');
assert.equal(grantConfig.inbound.channel_history_backfill, false);
assert.equal(grantConfig.continuity.chroma.other_collections, 'prohibited');
assert.equal(grantConfig.continuity.chroma.vector_rank_authority, false);
assert.equal(grantConfig.models.raw_model_output_authority, 'none');
assert(grantConfig.models.remote_prohibited_information.includes('personal-content'));
assert.equal(grantConfig.outbound.unknown_outcome,
  'hold-and-reconcile-never-blind-resend');
assert.equal(grantConfig.resource_bounds.activation_hours, 72);
assert.equal(grantConfig.lifecycle.renewal, 'new-explicit-human-approval-required');

const proposalText = fs.readFileSync(path.join(repo, proposal), 'utf8');
for (const required of [
  'awaiting Berton\'s explicit approval; not active',
  'Balance unfolding as movement',
  'R/A/P legibility of that same movement',
  'Fact9 and interconnected Flourishing participation',
  'four-plane Continuity of Mind',
  'There is no channel-history backfill',
  'OpenRouter GLM 5.3 only for public-safe non-personal material',
  '72 hours',
  'unknown outcome is held and reconciled',
  'does not itself activate Miter'
]) assert(proposalText.includes(required), `proposal missing: ${required}`);

const planHash = fileHash(plan);
const proposalHash = fileHash(proposal);
const configHash = fileHash(config);
const args = [
  planHash,
  proposalHash,
  configHash,
  grantConfig.authority_lineage.g31_closure_sha256,
  grantConfig.authority_lineage.candidate_sha256,
  grantConfig.authority_lineage.transport_sha256,
  grantConfig.authority_lineage.private_identity_record_sha256,
  grantConfig.authority_lineage.private_principal_binding_sha256,
  fileHash('config/model-resources-v1.json'),
  fileHash('config/chroma-service.json')
];
for (const value of args) assert.match(value, /^[a-f0-9]{64}$/);
const mettaArgs = args.map(asMetta).join(' ');
const constructor = `(AMA12InactiveGrantV1 ${mettaArgs})`;
const standing = grant => `(AMA12InactiveGrantStanding ${grant} ${mettaArgs})`;
const boot = `!(import! &self "${repo}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const constructed = native(runRoot, 'native-grant-construction',
  `!(result grant ${constructor})\n` +
  `!(let $grant ${constructor} (result standing ${standing('$grant')}))`, boot);
assert.equal(constructed.length, 2);
const grant = constructed[0][2];
const canonicalStanding = constructed[1][2];
assert.equal(grant[0], 'ama12-live-grant-v1');
assert.equal(canonicalStanding[0], 'ama12-inactive-live-grant-ready-for-human-review');

const change = (index, value) => {
  const next = clone(grant);
  next[index] = value;
  return next;
};
const remoteDisclosureSevered = clone(grant);
remoteDisclosureSevered[12][3] = 'personal-content-eligible';
const movementAuthoritySevered = clone(grant);
movementAuthoritySevered[13][4] = 'movement-authority';
const cases = {
  canonical: grant,
  'neutral-json-roundtrip': clone(grant),
  restored: grant,
  'approval-conflated': change(22, ['approval', 'berton-explicit', 'approved']),
  'activation-conflated': change(23,
    ['activation', 'active', 'network-enabled', 'credentials-enabled',
      'model-enabled', 'chroma-enabled', 'message-read-enabled', 'message-write-enabled']),
  'surface-severed': change(3, ['surface', ['mattermost', 'http://127.0.0.1:9999',
    'loopback-only']]),
  'continuity-severed': change(7, ['continuity', 'transcript-only']),
  'remote-disclosure-severed': remoteDisclosureSevered,
  'model-authority-severed': movementAuthoritySevered,
  'effect-reconciliation-severed': change(15,
    ['effect-reconciliation', 'blind-retry'])
};
const trialBody = Object.entries(cases).map(([id, value]) =>
  `!(result ${id} ${standing(asMetta(value))})`).join('\n');
const trialRows = native(runRoot, 'native-grant-trials', trialBody, boot);
assert.equal(trialRows.length, Object.keys(cases).length);
const standings = Object.fromEntries(trialRows.map(row => [row[1], row[2]]));
for (const id of ['canonical', 'neutral-json-roundtrip', 'restored'])
  assert.equal(standings[id][0], 'ama12-inactive-live-grant-ready-for-human-review', id);
for (const id of ['approval-conflated', 'activation-conflated', 'surface-severed',
  'continuity-severed', 'remote-disclosure-severed', 'model-authority-severed',
  'effect-reconciliation-severed'])
  assert.equal(standings[id][0], 'ama12-inactive-live-grant-held', id);

const results = {
  schema: 'miter-ama12-inactive-live-grant-results-v1',
  status: 'PASS-BOUNDED-INACTIVE-AWAITING-HUMAN',
  proposal_sha256: proposalHash,
  config_sha256: configHash,
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
  approval: 'unresolved'
};

if (record) {
  writeJson('native-grant.json', {native: grant});
  writeJson('native-standing.json', {native: canonicalStanding});
  writeJson('native-trial-standings.json', {native: standings});
  writeJson('results.json', results);
  const sources = [
    plan,
    proposal,
    config,
    'CONSTITUTION.md',
    'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
    'BUILD_FIDELITY_PROTOCOL.md',
    'WORK_PROTOCOL.md',
    'ACCEPTANCE.md',
    'src/mattermost_live_grant_v1.metta',
    'src/bootstrap_mattermost_live_grant_v1.metta',
    'config/model-resources-v1.json',
    'config/chroma-service.json',
    'docs/gates/G31/P9/R1/closure.json',
    'scripts/ama1_2/live_grant_freeze.mjs'
  ];
  writeJson('runtime.json', {
    schema: 'miter-ama12-inactive-live-grant-runtime-v1',
    swipl: execFileSync('/opt/homebrew/bin/swipl', ['--version'], {encoding: 'utf8'}).trim(),
    petta_commit: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
    checkpoint_base_commit: '28c0a0c6',
    external_network_calls: 0,
    credential_lookups: 0,
    model_calls: 0,
    chroma_calls: 0,
    message_reads: 0,
    message_writes: 0,
    sources: sources.map(relative => ({path: relative, sha256: fileHash(relative)}))
  });
  writeJson('verdict.json', {
    schema: 'miter-ama12-inactive-live-grant-verdict-v1',
    status: results.status,
    facts: {
      grant_is_complete_and_publicly_reviewable: true,
      approval_and_activation_remain_separate_unresolved_events: true,
      balance_rap_fact9_and_flourishings_remain_constitutive_not_grant_logic: true,
      four_plane_continuity_is_exactly_scoped: true,
      local_models_are_private_contact_eligible: true,
      remote_model_is_public_safe_only: true,
      voice_and_effect_reconciliation_are_required: true,
      causal_severance_holds_the_native_grant: true,
      no_live_authority_was_exercised: true
    },
    next_boundary: 'Berton must approve the exact proposal hash before an approval overlay, live preflight, or activation plan can be constructed.'
  });
}

console.log(JSON.stringify({status: results.status, cases: Object.keys(cases).length,
  proposal_sha256: proposalHash, evidence: record ? evidence : null}));
