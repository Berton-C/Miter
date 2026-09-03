// Execute the one authorized rendering, quarantine it, and run causal mocks.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root, hash, read, save, pins, native, sexp, swi} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '301';
const dir = `${root}/evidence/G31/p3-${tag}`;
assert.equal(read(`${dir}/prepared.json`).status, 'PREPARED');
for (const file of read(`${dir}/manifest.json`).files)
  assert.equal(hash(fs.readFileSync(file.path)), file.sha256, file.path);
process.on('uncaughtException', error => {
  save(`${dir}/run-failure.json`, {message:error.message, stack:error.stack,
    candidate_promoted:false, candidate_activated:false,
    local_mattermost_requests:0});
  console.error(error.stack);
  process.exitCode = 1;
});
const input = read(`${dir}/input.json`).native;
const [, source, version, current, oldFile] = input;
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_candidate_revision_v1.metta")\n`;
const rows = native(dir, 'native-render',
  `!(result rendered (G31P3Run ${sexp(dir)} ${sexp(source)} ${version} ${sexp(current)} ${sexp(oldFile)}))`, boot);
assert.equal(rows.length, 1);
const product = rows[0][2];
assert.equal(product[0], 'g31-p3-model-candidate');
const observation = product[2];
save(`${dir}/model-observation-native.json`, {native:observation});
assert.equal(observation[0], 'openrouter-observation');
assert.equal(observation[1], 'openrouter-g31-p3-revision-1');
assert.equal(observation[2], 'bridge');
assert.equal(observation[3], 'eof');
assert.equal(observation[4], 200);
assert.equal(observation[6], 'true');
assert.equal(observation[8], 'provider-response');
assert.equal(observation[11], 'z-ai/glm-5.3');
const envelope = observation[10].match(/^BEGIN_SOURCE\n([\s\S]+)\nEND_SOURCE\n?$/);
assert(envelope, 'model source envelope');
const candidateSource = envelope[1];
const priorSource = oldFile[2];
const oldText = 'body:_{channel_id:CID, message:M}';
const newText = 'body:_{channel_id:CID, message:M, pending_post_id:IK}';
assert.equal(priorSource.split(oldText).length, 2);
const expectedSource = priorSource.replace(oldText, newText);
assert.equal(candidateSource, expectedSource,
  'candidate must differ only by the source-required body mapping');
const candidateDir = `${dir}/candidate`;
const candidatePath = `${candidateDir}/extension/mattermost_bridge.pl`;
fs.mkdirSync(`${candidateDir}/extension`, {recursive:true});
fs.writeFileSync(candidatePath, candidateSource);
const candidateHash = hash(Buffer.from(candidateSource));
assert.notEqual(candidateHash, current[1]);

const compile = spawnSync(swi, ['-q','-f','none','-s',candidatePath,
  '-g','halt'], {encoding:'utf8', timeout:30000, maxBuffer:8*1024*1024,
  env:{HOME:'/nonexistent', PATH:'/usr/bin:/bin'}});
save(`${dir}/candidate-compile.stdout`, compile.stdout ?? '');
save(`${dir}/candidate-compile.stderr`, compile.stderr ?? '');
save(`${dir}/candidate-compile-process.json`, {status:compile.status,
  signal:compile.signal, error:compile.error?.message});
assert.equal(compile.status, 0, compile.stderr);
assert.equal(compile.stderr, '');

const view = ['effect-descriptor-view', candidateHash, 'v11-7-7',
  ['body-fields','channel-id','message','pending-post-id'],
  ['envelope-fields','idempotency-key'],
  ['field-maps',['map','idempotency-key','pending-post-id']], true, 30, true];
save(`${dir}/candidate-view.json`, {native:view});
const canonicalRows = native(dir, 'native-canonical-trial',
  `!(let $mock (g31_p3_mock_trial ${sexp(candidatePath)} ${sexp(candidateHash)}) (result mock $mock))\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(candidatePath)} ${sexp(candidateHash)}) (result standing (G31P3TrialStanding ${sexp(source)} ${version} ${sexp(view)} $mock)))`, boot);
const canonical = Object.fromEntries(canonicalRows.map(row => [row[1],row[2]]));
assert.equal(canonical.mock[0], 'g31-p3-mock-observation');
assert.equal(canonical.standing[0], 'g31-p3-candidate-qualified');
save(`${dir}/canonical-result.json`, canonical);

const severedPath = `${dir}/severed/extension/mattermost_bridge.pl`;
fs.mkdirSync(`${dir}/severed/extension`, {recursive:true});
const severedSource = candidateSource.replace(newText,
  'body:_{channel_id:CID, message:M}');
fs.writeFileSync(severedPath, severedSource);
const severedHash = hash(Buffer.from(severedSource));
assert.equal(severedHash, current[1]);
const severedView = ['effect-descriptor-view', severedHash, 'v11-7-7',
  ['body-fields','channel-id','message'],
  ['envelope-fields','idempotency-key'], ['field-maps'], true, 30, true];
const severedRows = native(dir, 'native-severed-trial',
  `!(let $mock (g31_p3_mock_trial ${sexp(severedPath)} ${sexp(severedHash)}) (result mock $mock))\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(severedPath)} ${sexp(severedHash)}) (result standing (G31P3TrialStanding ${sexp(source)} ${version} ${sexp(severedView)} $mock)))`, boot);
const severed = Object.fromEntries(severedRows.map(row => [row[1],row[2]]));
assert.equal(severed.mock[0], 'g31-p3-mock-failure');
assert.equal(severed.standing[0], 'g31-p3-candidate-held');
save(`${dir}/severed-result.json`, severed);

const secretRows = native(dir, 'native-secret-audit',
  `!(result absent (g31_p3_secret_absent ${sexp(dir)} ${sexp(candidatePath)}))`, boot);
assert.equal(secretRows[0][2], 'true');
save(`${dir}/secret-audit.json`, {status:'PASS-BOUNDED',
  actual_openrouter_key_compared_in_memory:true,
  key_material_returned:false, key_absent_from_evidence_and_candidate:true});

const requestId = 'openrouter-g31-p3-revision-1';
const modelFiles = ['request','raw','timing','observation'].map(kind =>
  `${dir}/${requestId}-${kind}.json`);
for (const file of modelFiles) assert(fs.existsSync(file), file);
save(`${dir}/lineage.json`, {
  schema:'miter-g31-p3-lineage-v1',
  source_candidate_sha256:current[1], candidate_sha256:candidateHash,
  exact_source_transform:{from:oldText,to:newText,other_byte_changes:0},
  selected_resource:'openrouter-glm53', selected_model:'z-ai/glm-5.3',
  actual_model_calls:1, returned_model:observation[11],
  provider:observation[12], usage:observation[13],
  files:pins([...modelFiles, candidatePath, severedPath,
    `${dir}/candidate-view.json`, `${dir}/canonical-result.json`,
    `${dir}/severed-result.json`]),
  openrouter_credential:'keychain-redacted-and-absent',
  mattermost_credentials:null, local_mattermost_requests:0,
  standing:'quarantined-candidate-not-promotion'
});
save(`${dir}/run-verdict.json`, {
  status:'PASS-BOUNDED', candidate_sha256:candidateHash,
  exact_single_transform:true, model_calls:1,
  model_product_quarantined:true, syntax_passed:true,
  prior_bridge_contract_passed:true,
  pending_post_id_equals_stable_effect_key:true,
  same_key_within_window_server_creates:canonical.mock[4],
  same_receipt_returned:canonical.mock[5],
  in_flight_duplicate_typed:canonical.mock[6],
  expiry_can_duplicate:canonical.mock[7],
  restart_can_duplicate:canonical.mock[8],
  native_standing:canonical.standing[0],
  severed_mapping_held:true, universal_exactly_once_claimed:false,
  local_mattermost_requests:0, mattermost_credential_lookups:0,
  message_reads:0, message_writes:0, docker_calls:0,
  activated:false, promoted:false
});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
