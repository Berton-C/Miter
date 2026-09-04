// Independent, offline AMA-1.1 regression and package verifier. It validates
// frozen evidence and current source identity, exercises syntax/import checks,
// and records mechanics. It does not assign semantic F-09 standing.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const repo = '/Users/claritymiter/miter';
const freezeRelative =
  'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/final-review-freeze-001.json';
const freezePath = path.join(repo, freezeRelative);
const evidenceRelative = 'evidence/AMA-1.1/R1/final-review-001';
const evidence = path.join(repo, evidenceRelative);
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const petta = '/private/tmp/miter-g06-petta-ae66fa8/src/main.pl';
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const fileHash = file => sha256(fs.readFileSync(file));
const writeJson = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
const commands = [];

function run(name, executable, args, timeout = 30000) {
  const result = spawnSync(executable, args, {
    cwd: repo, encoding: 'utf8', timeout, maxBuffer: 32 * 1024 * 1024
  });
  const observation = {name, executable, args, status: result.status, signal: result.signal,
    stdout: result.stdout ?? '', stderr: result.stderr ?? '', error: result.error?.message ?? null};
  commands.push(observation);
  assert.equal(result.status, 0, `${name}: ${observation.error ?? observation.stderr}`);
  assert.equal(result.signal, null, `${name}: unexpected signal`);
  return observation;
}

function verifyClosure(relative) {
  const closure = JSON.parse(fs.readFileSync(path.join(repo, relative), 'utf8'));
  assert.equal(closure.status, 'PASS-BOUNDED', `${relative}: predecessor is not passing`);
  const checked = [];
  for (const item of closure.evidence) {
    const absolute = path.join(repo, item.path);
    assert.equal(fs.existsSync(absolute), true, `${relative}: missing ${item.path}`);
    assert.equal(fileHash(absolute), item.sha256, `${relative}: changed ${item.path}`);
    checked.push(item.path);
  }
  return {path: relative, status: closure.status, evidence_files_verified: checked.length};
}

function walk(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const item = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...walk(item));
    else files.push(item);
  }
  return files;
}

assert.equal(fs.existsSync(evidence), false, 'final-review evidence is immutable once recorded');
const freeze = JSON.parse(fs.readFileSync(freezePath, 'utf8'));
assert.equal(freeze.schema, 'miter-ama11-final-review-freeze-v1');
assert.equal(freeze.phase, 'AMA-1.1');
assert.equal(freeze.attempt, 'R1');
assert.equal(freeze.semantic_standing_assigned_by_script, false);
const committedFreeze = execFileSync('git', ['show', `HEAD:${freezeRelative}`], {cwd: repo});
assert.equal(sha256(committedFreeze), fileHash(freezePath), 'review freeze not committed unchanged');
for (const item of freeze.files) {
  assert.equal(fileHash(path.join(repo, item.path)), item.sha256, `review input changed: ${item.path}`);
}

const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');
const fidelity = run('active-fidelity-tests', process.execPath,
  ['--test', 'scripts/fidelity/check.test.mjs']);
assert.match(fidelity.stdout, /# pass 17/);
run('prolog-service-syntax', '/opt/homebrew/bin/swipl',
  ['-q', '-g', 'halt', '-l', 'effect_membranes/miter_assistant_service_v1.pl']);
run('prolog-operator-syntax', '/opt/homebrew/bin/swipl',
  ['-q', '-g', 'halt', '-l', 'effect_membranes/miter_assistant_operator_v1.pl']);
run('native-metta-bootstrap', '/opt/homebrew/bin/swipl',
  ['--stack_limit=2g', '-q', '-s', petta, '--', 'src/bootstrap_assistant_v1.metta', 'silent']);
run('git-diff-check', '/usr/bin/git', ['diff', '--check']);

const matrix = JSON.parse(fs.readFileSync(
  path.join(repo, 'evidence/AMA-1.1/R1/post-operator-repair-001/results.json'), 'utf8'));
assert.equal(matrix.status, 'PASS-BOUNDED');
assert.equal(matrix.results.length, 12);
assert.equal(matrix.results.every(item => item.status === 'PASS'), true);
const original = JSON.parse(fs.readFileSync(
  path.join(repo, 'evidence/AMA-1.1/R1/post-operator-matrix-001/verdict.json'), 'utf8'));
assert.equal(original.status, 'FAIL-CONSTITUTIVE');
const requiredVerdicts = [
  'evidence/AMA-1.1/R1/operator-freeze-002/verdict.json',
  'evidence/AMA-1.1/R1/reactor-freeze-002/verdict.json',
  'evidence/AMA-1.1/R1/service-freeze-001/verdict.json',
  'evidence/AMA-1.1/R1/participant-voice-freeze-001/verdict.json',
  'evidence/AMA-1.1/R1/post-operator-repair-001/verdict.json'
];
for (const relative of requiredVerdicts) {
  const verdict = JSON.parse(fs.readFileSync(path.join(repo, relative), 'utf8'));
  assert.equal(verdict.status, 'PASS-BOUNDED', relative);
}

const predecessorClosures = [
  verifyClosure('docs/gates/G31/P9/R1/closure.json'),
  verifyClosure('docs/gates/G32/R2/closure.json'),
  verifyClosure('docs/gates/G33/R14/closure.json')
];
const coreFiles = [...walk(path.join(repo, 'src')), ...walk(path.join(repo, 'effect_membranes'))];
assert.equal(coreFiles.some(file => file.endsWith('.py')), false, 'Python file in core/effect membranes');
assert.equal(fs.existsSync('/Users/bcb/.miter'), false, 'forbidden implicit runtime root exists');

const secretPattern = /sk-or-v1-[A-Za-z0-9._-]+|Bearer\s+[A-Za-z0-9._-]{12,}|BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY|mattermost.{0,20}token/i;
for (const item of freeze.public_scan_paths) {
  for (const file of walk(path.join(repo, item))) {
    assert.equal(secretPattern.test(fs.readFileSync(file).toString('latin1')), false,
      `secret-like material in ${path.relative(repo, file)}`);
  }
}

fs.mkdirSync(evidence, {recursive: true});
writeJson(path.join(evidence, 'commands.json'), commands);
writeJson(path.join(evidence, 'regression.json'), {
  schema: 'miter-ama11-final-regression-v1',
  phase: 'AMA-1.1', attempt: 'R1', status: 'PASS-BOUNDED',
  opening,
  current_evidence: {
    operator: 'PASS-BOUNDED', reactor: 'PASS-BOUNDED', service: 'PASS-BOUNDED',
    participant_voice: 'PASS-BOUNDED', post_operator_repair: 'PASS-BOUNDED',
    disclosed_matrix_failure_preserved: true, unchanged_matrix_cases_passed: 12
  },
  predecessor_closures: predecessorClosures,
  active_fidelity_tests: 17,
  native_metta_bootstrap: 'passed',
  prolog_syntax: 'passed',
  python_core_files: 0,
  forbidden_implicit_runtime_root_absent: true,
  external_network_calls: 0,
  model_calls: 0,
  private_memory_reads: 0,
  external_effects: 0,
  standing: 'Applicable offline predecessor and current-package regressions passed. This mechanical result cannot assign F-09 semantic standing or close AMA-1.1.'
});
writeJson(path.join(evidence, 'verdict.json'), {
  schema: 'miter-ama11-final-review-verdict-v1',
  phase: 'AMA-1.1', attempt: 'R1', status: 'PASS-REGRESSION-ONLY',
  package_and_regression_checks_passed: true,
  semantic_fidelity_certified: false,
  f09_review_required: true,
  no_live_or_private_reach: true,
  limit: 'Independent offline verification of frozen packages, syntax, current bounded evidence and promoted predecessor evidence. It is not a qualitative constitutive review and cannot override an unresolved or partial F-09 row.'
});
console.log(JSON.stringify({status: 'PASS-REGRESSION-ONLY', evidence: evidenceRelative,
  predecessor_evidence_files_verified: predecessorClosures.reduce((sum, item) => sum + item.evidence_files_verified, 0)}));
