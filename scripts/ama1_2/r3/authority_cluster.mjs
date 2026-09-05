// Builder-side causal verifier for the first AMA-1.2 R3 authority cluster.
// This harness is never imported by Miter and cannot select a semantic result.

import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../../fidelity/check.mjs';
import {parse} from '../../sc04/fixtures.mjs';

const repo = '/Users/claritymiter/miter';
const petta = '/private/tmp/miter-g06-petta-ae66fa8';
const swi = '/opt/homebrew/bin/swipl';
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R3/plan.json';
const fixtureRoot = 'tests/fixtures/ama1_2/r3';
const record = process.argv.includes('--record');
const evidenceRelative = 'evidence/AMA-1.2/R3/authority-cluster-001';
const evidence = path.join(repo, evidenceRelative);
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const hashFile = relative => sha256(fs.readFileSync(path.join(repo, relative)));
const clean = value => value.replace(/\x1b\[[0-9;]*m/g, '');

function runFixture(relative) {
  const started = Date.now();
  const result = spawnSync(swi, ['--stack_limit=2g', '-q', '-s',
    path.join(petta, 'src/main.pl'), '--', path.join(repo, relative), 'silent'], {
    cwd: repo, encoding: 'utf8', timeout: 30000, maxBuffer: 32 * 1024 * 1024
  });
  return {
    relative, status: result.status, signal: result.signal,
    error: result.error?.message ?? null, elapsed_ms: Date.now() - started,
    stdout: result.stdout ?? '', stderr: result.stderr ?? ''
  };
}

function results(run, head) {
  return clean(run.stdout).split('\n').filter(line => line.startsWith(`(${head} `))
    .map(parse);
}

const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
assert.equal(execFileSync('git', ['-C', petta, 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git', ['-C', petta, 'status', '--porcelain'],
  {encoding: 'utf8'}).trim(), '');

const files = [
  'src/authority_inheritance_v1.metta',
  `${fixtureRoot}/authority-cluster-data.metta`,
  `${fixtureRoot}/authority-cluster-smoke.metta`,
  `${fixtureRoot}/authority-cluster-canonical.metta`,
  `${fixtureRoot}/authority-cluster-causal-matrix.metta`,
  'scripts/ama1_2/r3/authority_cluster.mjs'
];
const source = fs.readFileSync(path.join(repo, files[0]), 'utf8');
for (const forbidden of ['import_prolog', 'miter_llm', 'miter_chroma', 'http_', 'shell(',
  'process_create', 'python']) assert.equal(source.includes(forbidden), false, forbidden);

const smoke = runFixture(`${fixtureRoot}/authority-cluster-smoke.metta`);
assert.equal(smoke.status, 0, smoke.error ?? smoke.stderr);
assert.equal(smoke.stderr, '');
assert.deepEqual(clean(smoke.stdout).trim().split('\n').slice(-5),
  ['true', 'true', 'true', 'true', 'true']);

const canonical = runFixture(`${fixtureRoot}/authority-cluster-canonical.metta`);
assert.equal(canonical.status, 0, canonical.error ?? canonical.stderr);
assert.equal(canonical.stderr, '');
const canonicalRows = results(canonical, 'cluster-result');
assert.equal(canonicalRows.length, 21);
const canonicalById = Object.fromEntries(canonicalRows.map(row => [row[1], row[2]]));
for (const [id, expected] of Object.entries({
  'contact-valid': 'true',
  'infer-is-not-contact': 'false',
  'pressure-does-not-change-warrant-a': 'provisional',
  'pressure-does-not-change-warrant-b': 'provisional',
  'interpretation-use-valid': 'true',
  'interpretation-renderer-cannot-write': 'false',
  'scoped-joint-retained-tension': 'true',
  'scoped-joint-no-witness': 'false',
  'branch-commit-valid': 'true',
  'branch-recommit-rejected': 'false',
  'occurrence-valid': 'true',
  'same-occurrence': 'true',
  'same-becoming': 'true',
  'structural-fidelity-forward': 'true',
  'structural-fidelity-reverse': 'false'
})) assert.equal(canonicalById[id], expected, id);
for (const [id, head] of Object.entries({
  'contact-organization': 'm24-contact-organization',
  'orphan-generated': 'g-reading-unresolved',
  'generated-reading': 'g-reading-of',
  'persistent-form': 'persistent-form',
  dws: 'dws-family', opc: 'opc-at'
})) assert.equal(canonicalById[id]?.[0], head, id);

const matrix = runFixture(`${fixtureRoot}/authority-cluster-causal-matrix.metta`);
assert.equal(matrix.status, 0, matrix.error ?? matrix.stderr);
assert.equal(matrix.stderr, '');
const matrixRows = results(matrix, 'case-result');
assert.equal(matrixRows.length, 11);
const matrixById = Object.fromEntries(matrixRows.map(row => [row[1], row[2]]));
assert.equal(matrixById['m24-canonical'], 'true');
assert.equal(matrixById['m24-sever-seal'], 'false');
assert.equal(matrixById['m24-sever-frame-partiality'], 'false');
assert.equal(matrixById['m24-sever-direct-contact-standing'], 'false');
assert.equal(matrixById['m24-restored'], 'true');
assert.deepEqual(matrixById['m260-sever-manifestation'], ['result', 'false', 'false']);
assert.equal(matrixById['m260-sever-boundary-change'][1], 'true');
assert.equal(matrixById['m260-sever-boundary-change'][2][0], 'persistent-form-unresolved');
assert.equal(matrixById['m260-sever-l2425'], 'false');
assert.deepEqual(matrixById['m260-neutral-order'], matrixById['m260-restored']);
assert.deepEqual(matrixById['m260-canonical'], matrixById['m260-restored'].slice(0, 4));

const advancedRows = [
  'M24-E02', 'M24-E03', 'M24-E04', 'M24-E05', 'M24-E07', 'M24-E12',
  'M24-E16', 'M24-E17',
  'M260-E01', 'M260-E02', 'M260-E03', 'M260-E04', 'M260-E05', 'M260-E06',
  'M260-E07', 'M260-E08', 'M260-E11', 'M260-E12', 'M260-E13', 'M260-E16'
];
const verdict = {
  schema: 'miter-ama12-r3-authority-cluster-verdict-v1',
  status: 'PASS-NATIVE-HARNESS-NOT-RUNTIME-INTEGRATION',
  phase: 'AMA-1.2', attempt: 'R3', checkpoint: 'R3-C2-in-progress',
  plan_commit: opening.plan_commit, plan_sha256: opening.plan_sha256,
  cluster: 'M24-contact-provenance--M260-occurrence-participation',
  native_runtime_pin: 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  advanced_atlas_rows: advancedRows,
  advanced_row_count: advancedRows.length,
  canonical_assertions: canonicalRows.length,
  causal_matrix_cases: matrixRows.length,
  positive: true, severed: true, neutral: true, restored: true,
  persistent_runtime_integration: false,
  semantic_completion_claimed: false,
  model_calls: 0, memory_reads: 0, mattermost_payload_reads: 0,
  network_calls: 0, external_effects: 0,
  note: 'The rows are advanced by native discrimination but remain below PROVEN-RUNTIME until consumed through assistant v2.'
};

if (record) {
  assert.equal(fs.existsSync(evidence), false, `${evidenceRelative} already exists`);
  fs.mkdirSync(evidence, {recursive: true});
  const write = (name, value) => fs.writeFileSync(path.join(evidence, name),
    typeof value === 'string' ? value : `${JSON.stringify(value, null, 2)}\n`, {mode: 0o600});
  write('smoke.stdout', smoke.stdout); write('smoke.stderr', smoke.stderr);
  write('smoke-process.json', {...smoke, stdout: undefined, stderr: undefined});
  write('canonical.stdout', canonical.stdout); write('canonical.stderr', canonical.stderr);
  write('canonical-process.json', {...canonical, stdout: undefined, stderr: undefined});
  write('causal-matrix.stdout', matrix.stdout); write('causal-matrix.stderr', matrix.stderr);
  write('causal-matrix-process.json', {...matrix, stdout: undefined, stderr: undefined});
  write('verdict.json', verdict);
  write('manifest.json', {
    schema: 'miter-ama12-r3-authority-cluster-manifest-v1',
    files: files.map(relative => ({path: relative, sha256: hashFile(relative)})),
    evidence_files: ['smoke.stdout', 'smoke.stderr', 'smoke-process.json',
      'canonical.stdout', 'canonical.stderr', 'canonical-process.json',
      'causal-matrix.stdout', 'causal-matrix.stderr', 'causal-matrix-process.json',
      'verdict.json'],
    contains_credentials: false, contains_private_content: false
  });
}

process.stdout.write(`${JSON.stringify({...verdict,
  evidence: record ? evidenceRelative : null}, null, 2)}\n`);
