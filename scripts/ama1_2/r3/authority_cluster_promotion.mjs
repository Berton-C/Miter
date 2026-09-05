// Builder-side promotion audit. It validates evidence; it cannot choose cognition.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';

const repo = '/Users/claritymiter/miter';
const ledgerRelative = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/authority-runtime-progress-001.json';
const atlasRelative = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/authority-completion-atlas.json';
const reviewRelative = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/checkpoint-c2-promotion-audit-001.md';
const evidenceRelative = 'evidence/AMA-1.2/R3/authority-promotion-audit-001';
const evidence = path.join(repo, evidenceRelative);
const record = process.argv.includes('--record');
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const read = relative => JSON.parse(fs.readFileSync(path.join(repo, relative), 'utf8'));
const git = args => execFileSync('git', ['-C', repo, ...args], {encoding: 'utf8'}).trim();

const ledger = read(ledgerRelative);
const atlas = read(atlasRelative);
assert.equal(ledger.schema, 'miter-ama12-r3-authority-runtime-progress-v1');
assert.equal(ledger.phase, 'AMA-1.2');
assert.equal(ledger.attempt, 'R3');

const atlasIds = new Set(atlas.authorities.flatMap(authority =>
  authority.exports.map(row => row.id)));
const rowIds = ledger.rows.map(row => row.id);
assert.equal(new Set(rowIds).size, rowIds.length, 'duplicate progress row');
assert.equal(rowIds.length, 20);
for (const id of rowIds) assert.ok(atlasIds.has(id), `unknown atlas row ${id}`);

const requiredFields = [
  'id', 'native_representation', 'persistent_runtime_consumer',
  'positive_difference', 'material_severance', 'neutral_perturbation',
  'restoration', 'evidence', 'limit', 'standing'
];
for (const row of ledger.rows) {
  for (const field of requiredFields) assert.ok(Object.hasOwn(row, field),
    `${row.id} missing ${field}`);
  assert.ok(Array.isArray(row.native_representation) && row.native_representation.length > 0,
    `${row.id} missing native representation`);
  assert.ok(Array.isArray(row.evidence) && row.evidence.length > 0,
    `${row.id} missing evidence`);
  assert.ok(['PROVEN-RUNTIME', 'PARTIAL', 'GAP'].includes(row.standing),
    `${row.id} invalid standing`);
  if (row.standing === 'PROVEN-RUNTIME') {
    assert.equal(typeof row.persistent_runtime_consumer, 'string',
      `${row.id} lacks runtime consumer`);
    assert.ok(row.persistent_runtime_consumer.length > 0);
    assert.ok(!row.limit.toLowerCase().includes('lacks'), `${row.id} admits missing proof`);
    assert.ok(!row.limit.toLowerCase().includes('not yet'), `${row.id} admits missing proof`);
  }
}

const promoted = ledger.rows.filter(row => row.standing === 'PROVEN-RUNTIME')
  .map(row => row.id).sort();
assert.deepEqual(promoted, ['M24-E05', 'M260-E05']);
assert.deepEqual(ledger.totals, {
  rows_audited: 20, proven_runtime: 2, partial: 18, gap: 0
});

for (const bundle of ledger.evidence_bundles) {
  const verdict = read(bundle.path);
  assert.equal(verdict.status, bundle.status, bundle.path);
  const introducing = git(['log', '--diff-filter=A', '--format=%H', '--', bundle.path])
    .split('\n').filter(Boolean).at(-1);
  assert.equal(introducing, bundle.introduced_by, `${bundle.path} provenance`);
  const manifestRelative = path.posix.join(path.posix.dirname(bundle.path), 'manifest.json');
  const manifest = JSON.parse(git(['show', `${bundle.introduced_by}:${manifestRelative}`]));
  const entries = manifest.files ?? [];
  assert.ok(entries.length > 0, `${manifestRelative} contains no source files`);
  for (const entry of entries) {
    const bytes = execFileSync('git', ['-C', repo, 'show',
      `${bundle.introduced_by}:${entry.path}`]);
    assert.equal(sha256(bytes), entry.sha256,
      `${manifestRelative} source hash ${entry.path}`);
  }
}

const result = {
  schema: 'miter-ama12-r3-authority-promotion-audit-result-v1',
  status: 'PASS-HONEST-PROMOTION-AUDIT',
  phase: ledger.phase,
  attempt: ledger.attempt,
  checkpoint: ledger.checkpoint,
  rows_audited: ledger.rows.length,
  promoted_rows: promoted,
  partial_rows: ledger.rows.filter(row => row.standing === 'PARTIAL').map(row => row.id),
  evidence_bundles_verified: ledger.evidence_bundles.length,
  live_payload_reads: 0,
  model_calls: 0,
  memory_reads: 0,
  external_effects: 0
};
if (record) {
  assert.equal(fs.existsSync(evidence), false, `${evidenceRelative} already exists`);
  fs.mkdirSync(evidence, {recursive: true});
  fs.writeFileSync(path.join(evidence, 'verdict.json'),
    `${JSON.stringify(result, null, 2)}\n`, {mode: 0o600});
  const files = [ledgerRelative, reviewRelative,
    'scripts/ama1_2/r3/authority_cluster_promotion.mjs'];
  fs.writeFileSync(path.join(evidence, 'manifest.json'), `${JSON.stringify({
    schema: 'miter-ama12-r3-authority-promotion-audit-manifest-v1',
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
