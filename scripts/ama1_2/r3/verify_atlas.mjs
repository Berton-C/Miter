// Builder-side structural verification for AMA-1.2 R3-C1.
// This file is never imported by Miter and makes no semantic fidelity claim.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {checkOpen} from '../../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const relativePlan =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const relativeAtlas =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/authority-completion-atlas.json';
const relativeChoices =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/experimental-choice-inventory.json';
const read = relative => fs.readFileSync(path.join(repo, relative));
const json = relative => JSON.parse(read(relative));
const hash = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const text = value => typeof value === 'string' && value.trim().length > 0;

const opening = checkOpen(relativePlan);
const plan = json(relativePlan);
const atlas = json(relativeAtlas);
const choices = json(relativeChoices);

assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
assert.equal(atlas.schema, 'miter-authority-completion-atlas-v1');
assert.match(atlas.baseline_commit, /^[0-9a-f]{40}$/);
execFileSync('git', ['-C', repo, 'merge-base', '--is-ancestor',
  atlas.baseline_commit, opening.plan_commit]);
const baselinePlan = execFileSync('git', ['-C', repo, 'show',
  `${atlas.baseline_commit}:${relativePlan}`]);
assert.equal(hash(baselinePlan), opening.plan_sha256,
  'R3 plan changed after the atlas baseline');
assert.equal(choices.schema, 'miter-poc-experimental-choice-inventory-v1');

const expectedAuthorities = Object.entries(plan.authority_sources);
assert.equal(atlas.authorities.length, expectedAuthorities.length);
const rows = [];
for (const [id, expected] of expectedAuthorities) {
  const authority = atlas.authorities.find(value => value.id === id);
  assert.ok(authority, `missing authority ${id}`);
  assert.equal(authority.source, expected.path, `${id} source`);
  assert.equal(authority.sha256, expected.sha256, `${id} declared hash`);
  assert.equal(hash(read(authority.source)), expected.sha256, `${id} actual hash`);
  assert.equal(authority.expected_exports, expected.export_count, `${id} expected count`);
  assert.equal(authority.exports.length, expected.export_count, `${id} actual count`);
  rows.push(...authority.exports);
}

assert.equal(rows.length, 114);
assert.equal(new Set(rows.map(row => row.id)).size, rows.length);
for (const row of rows) {
  for (const field of ['id', 'meaning', 'kind', 'baseline', 'baseline_reason', 'test_family']) {
    assert.ok(text(row[field]), `${row.id} missing ${field}`);
  }
  assert.ok(['PARTIAL', 'GAP', 'REJECTED'].includes(row.baseline),
    `${row.id} invalid baseline ${row.baseline}`);
}
const baselineCounts = Object.fromEntries(['PARTIAL', 'GAP', 'REJECTED'].map(standing => [
  standing.toLowerCase(), rows.filter(row => row.baseline === standing).length
]));
assert.equal(atlas.totals.exports, rows.length);
assert.equal(atlas.totals.baseline_partial, baselineCounts.partial);
assert.equal(atlas.totals.baseline_gap, baselineCounts.gap);
assert.equal(atlas.totals.baseline_rejected, baselineCounts.rejected);
assert.equal(atlas.totals.operational_completion_claimed, 0);

assert.equal(choices.choices.length, choices.totals.choices);
assert.equal(new Set(choices.choices.map(choice => choice.id)).size, choices.choices.length);
const allowed = new Set(choices.allowed_standings);
const knownExports = new Set(rows.map(row => row.id));
for (const choice of choices.choices) {
  for (const field of ['id', 'question', 'scope', 'uncertainty', 'standing']) {
    assert.ok(text(choice[field]), `${choice.id} missing ${field}`);
  }
  for (const field of ['basis', 'alternatives', 'consumers', 'predictions', 'falsifiers',
    'consequences', 'lineage']) {
    assert.ok(Array.isArray(choice[field]), `${choice.id} ${field} is not an array`);
  }
  assert.ok(choice.alternatives.length >= 2, `${choice.id} needs competing alternatives`);
  assert.ok(choice.predictions.length > 0 && choice.falsifiers.length > 0,
    `${choice.id} lacks discrimination`);
  assert.ok(allowed.has(choice.standing), `${choice.id} invalid standing`);
  assert.ok(choice.basis.some(item => knownExports.has(item)),
    `${choice.id} lacks exact inherited basis`);
  assert.equal(choice.standing, 'unresolved', `${choice.id} was selected by the builder`);
}
assert.equal(choices.totals.unresolved, choices.choices.length);

assert.ok(read('MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md').equals(
  read('docs/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md')), 'Soul copies differ');

process.stdout.write(`${JSON.stringify({
  schema: 'miter-ama12-r3-c1-atlas-structural-verdict-v1',
  status: 'PASS-STRUCTURAL-BASELINE-NOT-SEMANTIC-COMPLETION',
  phase: 'AMA-1.2',
  attempt: 'R3',
  checkpoint: 'R3-C1',
  plan_commit: opening.plan_commit,
  atlas_baseline_commit: atlas.baseline_commit,
  plan_sha256: opening.plan_sha256,
  authority_exports: rows.length,
  authority_counts: Object.fromEntries(atlas.authorities.map(authority => [
    authority.id, authority.exports.length
  ])),
  baseline_counts: baselineCounts,
  experimental_choices: choices.choices.length,
  experimental_choice_standings: {unresolved: choices.choices.length},
  implementation_complete_claimed: false,
  semantic_fidelity_certified: false,
  live_activation: false,
  mattermost_payload_reads: 0,
  external_effects: 0
}, null, 2)}\n`);
