// Resume G31 P3 from the committed attempt-351 response; no model invocation.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync, spawnSync} from 'node:child_process';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp, swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '361';
const sourceTag = process.argv[3] ?? '351';
assert.match(tag, /^3\d{2}$/);
assert.equal(sourceTag, '351');
const dir = `${root}/evidence/G31/p3-${tag}`;
const sourceDir = `${root}/evidence/G31/p3-${sourceTag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/resume-failure.json`, {message:error.message,stack:error.stack,
    model_calls_this_resume:0,local_mattermost_requests:0,
    candidate_promoted:false,candidate_activated:false});
  console.error(error.stack);
  process.exitCode=1;
});

const opening = checkOpen('docs/gates/G31/P3/R7/plan.json');
assert.equal(opening.plan_commit,
  '785acd79a037d633d5d9469bd54ba4a2f78e0371');
save(`${dir}/opening.json`,opening);

const capturedRel = [
  `evidence/G31/p3-${sourceTag}/input.json`,
  `evidence/G31/p3-${sourceTag}/model-observation-native.json`,
  `evidence/G31/p3-${sourceTag}/openrouter-g31-p3-revision-1-request.json`,
  `evidence/G31/p3-${sourceTag}/openrouter-g31-p3-revision-1-raw.json`,
  `evidence/G31/p3-${sourceTag}/openrouter-g31-p3-revision-1-timing.json`,
  `evidence/G31/p3-${sourceTag}/openrouter-g31-p3-revision-1-observation.json`,
  `evidence/G31/p3-${sourceTag}/candidate/extension/mattermost_bridge.pl`,
  `evidence/G31/p3-${sourceTag}/candidate-compile-process.json`,
  `evidence/G31/p3-${sourceTag}/candidate-compile.stderr`,
  `evidence/G31/p3-${sourceTag}/candidate-compile.stdout`,
  `evidence/G31/p3-${sourceTag}/failure-verdict.json`,
  'evidence/G31/P3-call-1.claim/owner.json'
];
for (const relative of capturedRel) {
  const committed = execFileSync('/usr/bin/git',
    ['show',`${opening.plan_commit}:${relative}`],{cwd:root});
  assert(committed.equals(fs.readFileSync(`${root}/${relative}`)),relative);
}

const input = read(`${sourceDir}/input.json`).native;
const [, source, version, current, oldFile] = input;
assert.equal(current[1],
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');
const observation = read(`${sourceDir}/model-observation-native.json`).native;
assert.deepEqual(observation.slice(0,9),
  ['openrouter-observation','openrouter-g31-p3-revision-1','bridge','eof',
    200,23484,true,'stop','provider-response']);
assert.equal(observation[11],'z-ai/glm-5.3');
const envelope = observation[10].match(/^BEGIN_SOURCE\n([\s\S]+)\nEND_SOURCE\n?$/);
assert(envelope);
const oldText = 'body:_{channel_id:CID, message:M}';
const newText = 'body:_{channel_id:CID, message:M, pending_post_id:IK}';
const expectedSource = oldFile[2].replace(oldText,newText);
assert.equal(envelope[1],expectedSource);
const capturedCandidate = fs.readFileSync(
  `${sourceDir}/candidate/extension/mattermost_bridge.pl`,'utf8');
assert.equal(capturedCandidate,expectedSource);
const candidateHash = hash(Buffer.from(capturedCandidate));
assert.equal(candidateHash,
  'cf771e7bdfa571f695a3949177cb33ed6fb04431999e88401163b21a328efca3');
save(`${dir}/input.json`,{native:input,source_attempt:`p3-${sourceTag}`});
save(`${dir}/model-observation-native.json`,{native:observation,
  source_attempt:`p3-${sourceTag}`,model_calls_this_resume:0});

const candidatePath = `${dir}/candidate/extension/mattermost_bridge.pl`;
fs.mkdirSync(path.dirname(candidatePath),{recursive:true});
fs.writeFileSync(candidatePath,capturedCandidate);
const compile = spawnSync(swi,['-q','-f','none','-s',candidatePath,'-g','halt'],
  {encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024,
    env:{HOME:'/nonexistent',PATH:'/usr/bin:/bin'}});
save(`${dir}/candidate-compile.stdout`,compile.stdout??'');
save(`${dir}/candidate-compile.stderr`,compile.stderr??'');
save(`${dir}/candidate-compile-process.json`,{status:compile.status,
  signal:compile.signal,error:compile.error?.message});
assert.equal(compile.status,0,compile.stderr);
assert.equal(compile.stderr,'');

const view = ['effect-descriptor-view',candidateHash,'v11-7-7',
  ['body-fields','channel-id','message','pending-post-id'],
  ['envelope-fields','idempotency-key'],
  ['field-maps',['map','idempotency-key','pending-post-id']],true,30,true];
save(`${dir}/candidate-view.json`,{native:view});
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_candidate_revision_v1.metta")\n`;
const canonicalRows = native(dir,'native-canonical-trial',
  `!(let $mock (g31_p3_mock_trial ${sexp(candidatePath)} ${sexp(candidateHash)}) (result mock $mock))\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(candidatePath)} ${sexp(candidateHash)}) (result standing (G31P3TrialStanding ${sexp(source)} ${version} ${sexp(view)} $mock)))`,boot);
const canonical = Object.fromEntries(canonicalRows.map(row=>[row[1],row[2]]));
assert.equal(canonical.mock[0],'g31-p3-mock-observation');
assert.equal(canonical.standing[0],'g31-p3-candidate-qualified');
save(`${dir}/canonical-result.json`,canonical);

const severedPath = `${dir}/severed/extension/mattermost_bridge.pl`;
fs.mkdirSync(path.dirname(severedPath),{recursive:true});
const severedSource = capturedCandidate.replace(newText,oldText);
fs.writeFileSync(severedPath,severedSource);
const severedHash = hash(Buffer.from(severedSource));
assert.equal(severedHash,current[1]);
const severedView = ['effect-descriptor-view',severedHash,'v11-7-7',
  ['body-fields','channel-id','message'],['envelope-fields','idempotency-key'],
  ['field-maps'],true,30,true];
const severedRows = native(dir,'native-severed-trial',
  `!(let $mock (g31_p3_mock_trial ${sexp(severedPath)} ${sexp(severedHash)}) (result mock $mock))\n`+
  `!(let $mock (g31_p3_mock_trial ${sexp(severedPath)} ${sexp(severedHash)}) (result standing (G31P3TrialStanding ${sexp(source)} ${version} ${sexp(severedView)} $mock)))`,boot);
const severed = Object.fromEntries(severedRows.map(row=>[row[1],row[2]]));
assert.equal(severed.mock[0],'g31-p3-mock-failure');
assert.equal(severed.standing[0],'g31-p3-candidate-held');
save(`${dir}/severed-result.json`,severed);

const secretPattern = /sk-or-v1-[A-Za-z0-9._-]+|Bearer\s+[A-Za-z0-9._-]{12,}/;
for (const relative of capturedRel) {
  const bytes = fs.readFileSync(`${root}/${relative}`).toString('latin1');
  assert(!secretPattern.test(bytes),relative);
}
for (const file of [candidatePath,severedPath])
  assert(!secretPattern.test(fs.readFileSync(file).toString('latin1')),file);
save(`${dir}/secret-audit.json`,{status:'PASS-BOUNDED',
  keychain_lookups:0,key_material_returned:false,
  known_openrouter_and_bearer_patterns_absent:true});

const capturedModelFiles = capturedRel.slice(1,6).map(file=>`${root}/${file}`);
save(`${dir}/lineage.json`,{
  schema:'miter-g31-p3-r7-lineage-v1',source_attempt:`p3-${sourceTag}`,
  source_candidate_sha256:current[1],candidate_sha256:candidateHash,
  exact_source_transform:{from:oldText,to:newText,other_byte_changes:0},
  selected_resource:'openrouter-glm53',selected_model:'z-ai/glm-5.3',
  actual_model_calls:1,model_calls_this_resume:0,
  returned_model:observation[11],provider:observation[12],usage:observation[13],
  files:pins([...capturedModelFiles,candidatePath,severedPath,
    `${dir}/candidate-view.json`,`${dir}/canonical-result.json`,
    `${dir}/severed-result.json`]),
  openrouter_credential:'not-read-on-resume',mattermost_credentials:null,
  local_mattermost_requests:0,standing:'quarantined-candidate-not-promotion'
});
save(`${dir}/run-verdict.json`,{
  status:'PASS-BOUNDED',candidate_sha256:candidateHash,
  exact_single_transform:true,model_calls:1,model_calls_this_resume:0,
  captured_observation_reused:true,model_product_quarantined:true,
  syntax_passed:true,prior_bridge_contract_passed:true,
  exact_repeat_stale_cursor_suppressed:true,
  pending_post_id_equals_stable_effect_key:true,
  same_key_within_window_server_creates:canonical.mock[4],
  same_receipt_returned:canonical.mock[5],
  in_flight_duplicate_typed:canonical.mock[6],
  expiry_can_duplicate:canonical.mock[7],restart_can_duplicate:canonical.mock[8],
  native_standing:canonical.standing[0],severed_mapping_held:true,
  universal_exactly_once_claimed:false,local_mattermost_requests:0,
  mattermost_credential_lookups:0,message_reads:0,message_writes:0,
  docker_calls:0,activated:false,promoted:false
});

const sources = [
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
  'docs/gates/G31/P3/R7/plan.json','docs/gates/G31/P3/R7/plan.md',
  'docs/gates/G31/P3/R6/attempt-361-outcome.md',
  'src/participation.metta','src/mattermost_live_reconciliation_v1.metta',
  'src/mattermost_candidate_revision_v1.metta',
  'src/bootstrap_mattermost_candidate_revision_v1.metta',
  'effect_membranes/miter_store.pl','effect_membranes/miter_surface_design_v1.pl',
  'effect_membranes/miter_openrouter.pl','effect_membranes/miter_mattermost_mock_v2.pl',
  'scripts/g31/p3_resume.mjs','scripts/g31/p3_quality.mjs',
  'scripts/g31/p3_verify.mjs','scripts/fidelity/check.mjs'
];
save(`${dir}/manifest.json`,{
  schema:'miter-g31-p3-r7-resume-v1',plan:'docs/gates/G31/P3/R7/plan.json',
  plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),
    ...capturedRel.map(file=>`${root}/${file}`),`${dir}/input.json`,
    `${dir}/model-observation-native.json`,candidatePath,severedPath,
    `${dir}/candidate-compile-process.json`,`${dir}/candidate-compile.stderr`,
    `${dir}/candidate-view.json`,`${dir}/canonical-result.json`,
    `${dir}/severed-result.json`,`${dir}/secret-audit.json`,
    `${dir}/lineage.json`,`${dir}/run-verdict.json`]),
  source_attempt:`p3-${sourceTag}`,model_calls_this_resume:0,
  local_mattermost_requests:0,candidate_promotions:0,candidate_activations:0
});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
