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
const opening = checkOpen('docs/gates/G31/P3/plan.json');
assert.equal(opening.plan_commit,
  '917da92efe8eda4a257f3a081d224210f01ad46b');
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
  `!(result question (G31P3RevisionQuestion ${sexp(source)} v11-7-7 ${sexp(current)} ${sexp(oldFile)}))`, boot);
assert.equal(rows.length, 1);
const question = rows[0][2];
assert.equal(question[0], 'openrouter-source');
assert.equal(question[1], 'openrouter-g31-p3-revision-1');
assert.equal(question[8], 8192);
assert.equal(question[9], 300);
save(`${dir}/revision-question.json`, {native:question});

const sources = [
  'CONSTITUTION.md', 'MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md', 'WORK_PROTOCOL.md', 'ACCEPTANCE.md',
  'docs/gates/G31/P3/plan.json', 'docs/gates/G31/P3/plan.md',
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
  `${root}/evidence/G31/p2-001/verification.json`];
save(`${dir}/manifest.json`, {
  schema:'miter-g31-p3-freeze-v1', plan:'docs/gates/G31/P3/plan.json',
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
  source_candidate_sha256:candidateHash,
  source_consequence:'pending-post-id-body-map-required',
  maximum_model_calls:1, actual_model_calls:0,
  local_mattermost_requests:0, mattermost_credentials:0,
  promoted:false, activated:false
});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
