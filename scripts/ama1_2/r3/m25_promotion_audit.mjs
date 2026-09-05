// Builder-side row promotion audit. It verifies evidence and cannot choose cognition.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';

const repo = '/Users/claritymiter/miter';
const ledgerRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/m25-runtime-progress-001.json';
const atlasRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/authority-completion-atlas.json';
const reviewRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/checkpoint-c2-m25-promotion-audit-001.md';
const evidenceRelative = 'evidence/AMA-1.2/R3/m25-promotion-audit-001';
const evidence = path.join(repo, evidenceRelative);
const record = process.argv.includes('--record');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const read = relative => JSON.parse(fs.readFileSync(path.join(repo, relative), 'utf8'));
const git = args => execFileSync('git', ['-C', repo, ...args], {encoding: 'utf8'}).trim();

const ledger = read(ledgerRelative);
const atlas = read(atlasRelative);
assert.equal(ledger.schema, 'miter-ama12-r3-m25-runtime-progress-v1');
assert.equal(ledger.phase, 'AMA-1.2');
assert.equal(ledger.attempt, 'R3');
assert.equal(ledger.checkpoint, 'R3-C2-in-progress');

const m25 = atlas.authorities.find(authority => authority.id === 'M25');
assert.ok(m25, 'M25 authority absent from atlas');
const atlasIds = m25.exports.map(row => row.id).sort();
const rowIds = ledger.rows.map(row => row.id).sort();
assert.deepEqual(rowIds, atlasIds, 'ledger must audit all and only M25 exports');
assert.equal(new Set(rowIds).size, rowIds.length, 'duplicate M25 progress row');

const requiredFields = [
  'id', 'required_runtime_consumer', 'native_representation',
  'persistent_runtime_consumer', 'positive_difference', 'material_severance',
  'neutral_perturbation', 'restoration', 'evidence', 'limit', 'standing'
];
for (const row of ledger.rows) {
  for (const field of requiredFields) assert.ok(Object.hasOwn(row, field),
    `${row.id} missing ${field}`);
  assert.ok(Array.isArray(row.native_representation) && row.native_representation.length > 0,
    `${row.id} missing native representation`);
  assert.ok(typeof row.required_runtime_consumer === 'string' &&
    row.required_runtime_consumer.length > 0, `${row.id} missing required consumer`);
  assert.ok(Array.isArray(row.evidence) && row.evidence.length > 0,
    `${row.id} missing evidence trace`);
  assert.ok(['PROVEN-RUNTIME', 'PARTIAL', 'GAP'].includes(row.standing),
    `${row.id} invalid standing`);
  if (row.standing === 'PROVEN-RUNTIME') {
    assert.ok(typeof row.persistent_runtime_consumer === 'string' &&
      row.persistent_runtime_consumer.length > 0, `${row.id} lacks runtime consumer`);
    assert.ok(!row.limit.toLowerCase().includes('not yet'),
      `${row.id} admits incomplete proof`);
    assert.ok(!row.limit.toLowerCase().includes('remain absent'),
      `${row.id} admits missing proof`);
  }
}

const promoted = ledger.rows.filter(row => row.standing === 'PROVEN-RUNTIME')
  .map(row => row.id).sort();
assert.deepEqual(promoted, ['M25-E01', 'M25-E03', 'M25-E04', 'M25-E10']);
assert.deepEqual(ledger.totals,
  {rows_audited: 19, proven_runtime: 4, partial: 15, gap: 0});

for (const bundle of ledger.evidence_bundles) {
  const verdict = read(bundle.path);
  assert.equal(verdict.status, bundle.status, bundle.path);
  assert.equal(verdict.movement_primary, true);
  assert.equal(verdict.one_contact_surface_one_rap_read, true);
  assert.equal(verdict.balance_unfolding_is_one_contact_movement_organization, true);
  assert.equal(verdict.fact9_flourishing_joint_is_material_to_primary_movement, true);
  assert.equal(verdict.same_fact9_flourishing_joint_is_material_to_rap_surface, true);
  assert.equal(verdict.fresh_process_restore, true);
  const introducing = git(['log', '--diff-filter=A', '--format=%H', '--', bundle.path])
    .split('\n').filter(Boolean).at(-1);
  assert.equal(introducing, bundle.introduced_by, `${bundle.path} provenance`);
  const manifestRelative = path.posix.join(path.posix.dirname(bundle.path), 'manifest.json');
  const manifest = JSON.parse(git(['show', `${bundle.introduced_by}:${manifestRelative}`]));
  assert.ok((manifest.files ?? []).length > 0, `${manifestRelative} has no sources`);
  for (const entry of manifest.files) {
    const bytes = execFileSync('git', ['-C', repo, 'show',
      `${bundle.introduced_by}:${entry.path}`]);
    assert.equal(sha256(bytes), entry.sha256,
      `${manifestRelative} source hash ${entry.path}`);
  }
}

const result = {
  schema: 'miter-ama12-r3-m25-promotion-audit-result-v1',
  status: 'PASS-HONEST-M25-PROMOTION-AUDIT',
  phase: ledger.phase,
  attempt: ledger.attempt,
  checkpoint: ledger.checkpoint,
  rows_audited: ledger.rows.length,
  promoted_rows: promoted,
  partial_rows: ledger.rows.filter(row => row.standing === 'PARTIAL')
    .map(row => row.id),
  evidence_bundles_verified: ledger.evidence_bundles.length,
  one_movement_one_rap_read_bound: true,
  fact9_flourishing_joint_bound: true,
  remaining_rows_are_mandatory: true,
  live_payload_reads: 0,
  model_calls: 0,
  memory_reads: 0,
  network_calls: 0,
  external_effects: 0
};

if (record) {
  assert.equal(fs.existsSync(evidence), false, `${evidenceRelative} already exists`);
  fs.mkdirSync(evidence, {recursive: true});
  fs.writeFileSync(path.join(evidence, 'verdict.json'),
    `${JSON.stringify(result, null, 2)}\n`, {mode: 0o600});
  const files = [ledgerRelative, reviewRelative,
    'scripts/ama1_2/r3/m25_promotion_audit.mjs'];
  fs.writeFileSync(path.join(evidence, 'manifest.json'), `${JSON.stringify({
    schema: 'miter-ama12-r3-m25-promotion-audit-manifest-v1',
    files: files.map(relative => ({
      path: relative,
      sha256: sha256(fs.readFileSync(path.join(repo, relative)))
    })),
    source_evidence_bundles: ledger.evidence_bundles,
    artifacts: ['verdict.json'],
    contains_credentials: false,
    contains_private_content: false
  }, null, 2)}\n`, {mode: 0o600});
}

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
