// Assemble compact R2 evidence from the already-consumed attempt-016 call.
// This script is offline: it invokes neither PeTTa nor the provider.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root,hash} from '../fidelity/check.mjs';
import {pins,read,save} from '../g22_v2/common.mjs';

process.chdir(root);
const rel='evidence/G33/R12/attempt-016',dir=`${root}/${rel}`,canonical=`${dir}/canonical`;
const fixture=read(`${root}/tests/fixtures/g33_r12/cases.json`);
const selection=read(`${dir}/resource-observations.json`);
const initialProcess=read(`${dir}/canonical-process.json`),generation=read(`${canonical}/generation.json`).native;
const final=read(`${canonical}/final.json`).native,trial=read(`${canonical}/trial.json`).native;
const before=read(`${canonical}/efficacy-before.json`).native,after=read(`${canonical}/efficacy-after.json`).native;
const restart=read(`${canonical}/restart.json`).native,severed=read(`${dir}/consequence-severed-summary.json`);
const stopRestart=read(`${dir}/stop-restart-process.json`),request=read(`${canonical}/g33-r12-generation-2-request.json`);
assert.equal(final[0],'development-helix-result');assert.equal(generation[11],fixture.expected.model);
assert.equal(trial[3][0],'trial-admissible');assert.equal(trial[4],'helix-development-durable');
assert.equal(before[2].length,2);assert.equal(after[2].length,1);assert.equal(after[2][0][2],fixture.expected.after_maximum);
assert.equal(final[6][2][0],'efficacy-processed');assert.equal(final[6][3][0],'efficacy-processed');
assert.equal(restart[0],'development-helix-rehydrated');assert.equal(restart[2][2].length,1);
assert.equal(restart[3],'no-generation-replay');assert.equal(severed.maxima.length,2);assert.equal(stopRestart.status,0);
const disclosed=JSON.parse(request.body.messages[1].content),schemaPath=`${root}/config/voice-realization-schema-v2.json`;
assert.equal(disclosed.required_schema_sha256,hash(fs.readFileSync(schemaPath)));
assert.deepEqual(disclosed.required_schema,read(schemaPath));
const rawPath=`${canonical}/g33-r12-generation-2-raw.json`,rawHash=hash(fs.readFileSync(rawPath));
assert.equal(stopRestart.generation_raw_sha256_after_restart,rawHash);
const candidatePath=`${canonical}/candidate.json`,candidateHash=hash(fs.readFileSync(candidatePath));
const observations={schema:'miter-g33-r12-observations-v2',selection:{
  canonical:[selection.canonical[0],selection.canonical[1],selection.canonical[2],selection.canonical[4]],
  neutral:[selection.neutral[0],selection.neutral[1],selection.neutral[2],selection.neutral[4]],
  absent_authorization:selection['absent-authorization'][0],ambiguous:selection.ambiguous[0],
  wrong_model_product:selection['wrong-model-product'],generation_preflight:selection['generation-preflight']},
  generation:{transport:generation[3],http_status:generation[4],elapsed_ms:generation[5],complete:generation[6],
    finish_reason:generation[7],parse:generation[8],bytes:generation[9],model:generation[11],provider:generation[12],usage:generation[13]},
  schema:{sha256:disclosed.required_schema_sha256,exact:true},candidate:{sha256:candidateHash,standing:final[3][2]},
  trial:{standing:trial[3][0],development:trial[4]},before_maxima:before[2],after_maxima:after[2],
  consequence:{parent:final[6][2][0],candidate:final[6][3][0]},consequence_severed:severed,
  restart:{standing:restart[0],maxima:restart[2][2],generation:restart[3]},
  initial_process:{status:initialProcess.status,signal:initialProcess.signal,timeout:initialProcess.timeout,final_present:initialProcess.final_present},
  stop_restart:stopRestart,raw_sha256:rawHash,call_claim:read(`${root}/evidence/G33/R12/openrouter-call-2.claim/owner.json`),
  resource_order_neutral:selection.canonical[1]===selection.neutral[1]&&selection.canonical[2]===selection.neutral[2],
  unauthorized_and_ambiguous_held:true,model_product_quarantined:final[4]==='candidate-quarantined',
  trial_admissible_without_material_loss:true,consequence_changes_later_ranking:true,
  consequence_severance_retains_tie:true,restart_preserves_changed_ranking_without_replay:true,
  ...fixture.resources};
save(`${dir}/observations.json`,observations);
const manifest=read(`${canonical}/manifest.json`),evidenceFiles=[
  `${dir}/opening.json`,`${dir}/resource-observations.json`,`${dir}/canonical-process.json`,
  `${canonical}/g33-r12-generation-2-request.json`,rawPath,`${canonical}/g33-r12-generation-2-timing.json`,
  `${canonical}/g33-r12-generation-2-observation.json`,candidatePath,`${canonical}/candidate-lineage.json`,
  `${canonical}/trial.json`,`${canonical}/efficacy-before.json`,`${canonical}/efficacy-after.json`,`${canonical}/final.json`,
  `${canonical}/restart.json`,`${canonical}/store/trajectory.jsonl`,`${dir}/consequence-severed-summary.json`,
  `${dir}/consequence-severed-process.json`,`${dir}/stop-restart-process.json`,
  `${root}/evidence/G33/R12/openrouter-call-2.claim/owner.json`,
  `${root}/scripts/g33_r12/run.mjs`,`${root}/scripts/g33_r12/resume016.mjs`,`${root}/scripts/g33_r12/finalize016.mjs`,
  `${root}/scripts/g33_r12/verify.mjs`];
save(`${dir}/freeze.json`,{schema:'miter-g33-r12-freeze-v2',git_head:execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  plan_commit:'17be857f2f0bd4a30bc5afd3c4ac2d98da63ebcb',petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  files:pins([...new Set([...manifest.files.map(x=>x.path),...evidenceFiles])]),model_calls:1,model:fixture.expected.model,
  max_output_tokens:4096,deadline_seconds:120,capture_bytes:2097152,...fixture.resources});
save(`${dir}/verdict.json`,{status:'PASS-BOUNDED',gate:'G33',revision:'R12-R2',
  waiting_undertaking_resumes_through_native_resource_comparison:true,
  exact_schema_and_calibrated_model_product_remain_non_authoritative:true,
  model_product_remains_quarantined_until_independent_v2_trial:true,
  native_consequence_and_nal_revision_change_later_ranking:true,
  development_and_changed_possibility_survive_restart:true,
  initial_daemon_exit_clean:false,explicit_stop_recognized_on_fresh_process:true,
  ...fixture.resources,
  limits:'One synthetic VoicePolicy undertaking, one exact GLM 5.3 R2 call, finite v2 trial and scoped efficacy question. The initial continuously cycling process required harness SIGTERM after final serialization; a fresh process consumed the exact stop without generation replay. Not production promotion, general Soul cognition, final G33, or whole-PoC acceptance.'});
console.log(JSON.stringify(read(`${dir}/verdict.json`)));
