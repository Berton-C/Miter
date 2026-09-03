// Freeze the native source-grounded repair question before the model call.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '301';
assert.match(tag, /^3\d{2}$/);
const dir = `${root}/evidence/G31/p3-${tag}`;
assert(!fs.existsSync(dir));
assert(!fs.existsSync(`${root}/evidence/G31/P3-call-1.claim`));
fs.mkdirSync(dir, {recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/prepare-failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});
const opening = checkOpen('docs/gates/G31/P3/R3/plan.json');
assert.equal(opening.plan_commit,
  '4fa88f39c8240f55a975d0516e437d62e2748006');
save(`${dir}/opening.json`, opening);

const p2 = read(`${root}/evidence/G31/p2-001/native-input.json`);
const source = p2.source;
const current = p2.current;
const candidatePath = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidateSource = fs.readFileSync(candidatePath, 'utf8');
const candidateHash = hash(Buffer.from(candidateSource));
assert.equal(candidateHash, current[1]);
const oldFile = ['surface-candidate-file',
  'extension/mattermost_bridge.pl', candidateSource, candidateHash];
save(`${dir}/input.json`, {
  native:['g31-p3-revision-input', source, 'v11-7-7', current, oldFile],
  candidate_sha256:candidateHash,
  model_credential_reference:'macos-keychain:ai.bgi.miter.openrouter:bcb',
  mattermost_credential_reference:null,
  live_mattermost:false
});
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_candidate_revision_v1.metta")\n`;
const rows = native(dir, 'native-question',
  `!(result grounding (g31_p3_renderer_ready))\n`+
  `!(result standing (G31P3QuestionStanding ${sexp(source)} v11-7-7 ${sexp(current)} ${sexp(oldFile)}))`, boot);
assert.equal(rows.length, 2);
const byName = Object.fromEntries(rows.map(row => [row[1],row[2]]));
assert.equal(byName.grounding, 'true');
const standing = byName.standing;
assert.equal(standing[0], 'g31-p3-revision-question-ready');
assert.equal(standing[1][1], 'openrouter-g31-p3-revision-1');
assert.equal(standing[2][1], candidateHash);
const envelope = standing[4].slice(1).map(value => Number(value));
assert(envelope.every(Number.isFinite));
assert(envelope.every(Number.isInteger));
assert.deepEqual(envelope, [8192,300]);
save(`${dir}/revision-question.json`, {native:standing,
  normalized_envelope:{max_output_tokens:envelope[0],
    deadline_seconds:envelope[1]},
  full_request_material:`${dir}/input.json`,
  source_bytes_transport:'durable-json-not-native-stdout'});

const sources = [
  'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
  'docs/gates/G31/P3/plan.json', 'docs/gates/G31/P3/plan.md',
  'docs/gates/G31/P3/R1/plan.json', 'docs/gates/G31/P3/R1/plan.md',
  'docs/gates/G31/P3/R1/attempt-311-outcome.md',
  'docs/gates/G31/P3/R2/plan.json', 'docs/gates/G31/P3/R2/plan.md',
  'docs/gates/G31/P3/R2/attempt-321-outcome.md',
  'docs/gates/G31/P3/R3/plan.json', 'docs/gates/G31/P3/R3/plan.md',
  'docs/gates/G31/P3/attempt-301-outcome.md',
  'docs/gates/G31/P2/outcome.md', 'config/model-resources-v1.json',
  'src/participation.metta', 'src/mattermost_live_reconciliation_v1.metta',
  'src/mattermost_candidate_revision_v1.metta',
  'src/bootstrap_mattermost_candidate_revision_v1.metta',
  'effect_membranes/miter_openrouter.pl',
  'effect_membranes/miter_mattermost_mock_v2.pl',
  'scripts/g31/p3_prepare.mjs', 'scripts/g31/p3_run.mjs',
  'scripts/g31/p3_quality.mjs', 'scripts/g31/p3_verify.mjs',
  'scripts/fidelity/check.mjs'
];
const retained = [candidatePath,
  `${root}/evidence/G29/attempt-901/candidate/candidate_tests/mattermost_contract_tests.pl`,
  `${root}/evidence/G31/p2-001/manifest.json`,
  `${root}/evidence/G31/p2-001/native-result.json`,
  `${root}/evidence/G31/p2-001/verification.json`,
  `${root}/evidence/G31/p3-301/failure-verdict.json`,
  `${root}/evidence/G31/p3-311/failure-verdict.json`,
  `${root}/evidence/G31/p3-321/failure-verdict.json`];
save(`${dir}/manifest.json`, {
  schema:'miter-g31-p3-r3-freeze-v1', plan:'docs/gates/G31/P3/R3/plan.json',
  plan_commit:opening.plan_commit,
  files:pins([...sources.map(file => `${root}/${file}`), ...retained,
    `${dir}/input.json`, `${dir}/revision-question.json`]),
  source_candidate_sha256:candidateHash,
  model:{resource:'openrouter-glm53', model:'z-ai/glm-5.3',
    maximum_calls:1, max_output_tokens:8192, deadline_seconds:300,
    credential:'keychain-reference-only'},
  local_mattermost_requests:0, mattermost_credential_lookups:0,
  message_reads:0, message_writes:0, docker_calls:0,
  candidate_promotions:0, candidate_activations:0
});
save(`${dir}/prepared.json`, {
  status:'PREPARED', native_question:true,
  qualified_renderer_grounding_visible:true,
  compact_stdout_and_durable_source_handoff:true,
  source_candidate_sha256:candidateHash,
  source_consequence:'pending-post-id-body-map-required',
  maximum_model_calls:1, actual_model_calls:0,
  local_mattermost_requests:0, mattermost_credentials:0,
  promoted:false, activated:false
});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
