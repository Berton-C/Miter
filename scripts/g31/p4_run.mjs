// G31 P4 R2 generic loopback transport laboratory with lossless state journal.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'102';
assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p4-${tag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/run-failure.json`,{message:error.message,stack:error.stack,
    model_calls:0,credential_lookups:0,local_mattermost_requests:0,
    promoted:false,activated:false});
  console.error(error.stack);process.exitCode=1;
});
const opening=checkOpen('docs/gates/G31/P4/R2/plan.json');
assert.equal(opening.plan_commit,'e9ad6dcbc09f4966fc06bcf9cc6488a3cbbd11bf');
save(`${dir}/opening.json`,opening);

const sourceCandidateRel='evidence/G31/p3-371/candidate/extension/mattermost_bridge.pl';
const sourceCandidate=`${root}/${sourceCandidateRel}`;
const committed=execFileSync('/usr/bin/git',['show',`${opening.plan_commit}:${sourceCandidateRel}`],{cwd:root});
assert(committed.equals(fs.readFileSync(sourceCandidate)));
const candidateHash=hash(committed);
assert.equal(candidateHash,'cf771e7bdfa571f695a3949177cb33ed6fb04431999e88401163b21a328efca3');
const candidate=`${dir}/candidate/extension/mattermost_bridge.pl`;
fs.mkdirSync(path.dirname(candidate),{recursive:true});
fs.writeFileSync(candidate,committed);
const transport=`${root}/effect_membranes/miter_surface_transport_lab_v1.pl`;
const transportHash=hash(fs.readFileSync(transport));
const fixture=`${root}/tests/fixtures/g31/p4_loopback_fixture.json`;

const transportSource=fs.readFileSync(transport,'utf8');
const forbidden=/mattermost|pending_post_id|\/api\/v4\/posts|post_edited|\bposted\b/i;
assert(!forbidden.test(transportSource));
save(`${dir}/authorship-audit.json`,{
  status:'PASS-BOUNDED',candidate_sha256:candidateHash,
  candidate_matches_miter_authored_p3:true,transport_sha256:transportHash,
  generic_transport_forbidden_destination_literals_absent:true,
  destination_specific_fixture:`${fixture}`,
  candidate_modified_by_builder:false,model_calls:0
});

const boot=`!(import! &self "${root}/src/bootstrap_surface_transport_qualification_v1.metta")\n`;
function trial(name,mode,expectedHead){
  const arm=`${dir}/${name}`;fs.mkdirSync(arm,{recursive:true});
  const rows=native(arm,'native-trial',
    `!(let $observation (p4_trial ${sexp(arm)} ${sexp(candidate)} ${sexp(candidateHash)} ${sexp(transport)} ${sexp(transportHash)} ${sexp(fixture)} ${mode}) (result ${name} $observation (P4TransportStanding $observation ${sexp(candidateHash)} ${sexp(transportHash)})))`,boot);
  assert.equal(rows.length,1);
  const observation=rows[0][2],standing=rows[0][3];
  assert.equal(observation[0],expectedHead);
  save(`${dir}/${name}-result.json`,{observation,standing});
  return {observation,standing};
}
const canonical=trial('canonical','canonical','p4-transport-observation');
assert.equal(canonical.standing[0],'g31-p4-transport-qualified');
const wrongPrincipal=trial('wrong-principal','wrong-principal','p4-severed-observation');
assert.equal(wrongPrincipal.standing[0],'g31-p4-transport-held');
const noJournal=trial('no-journal','no-journal','p4-severed-observation');
assert.equal(noJournal.standing[0],'g31-p4-transport-held');

const wrongHashArm=`${dir}/wrong-candidate-hash`;fs.mkdirSync(wrongHashArm,{recursive:true});
const wrongRows=native(wrongHashArm,'native-trial',
  `!(let $observation (p4_trial ${sexp(wrongHashArm)} ${sexp(candidate)} ${'0'.repeat(64)} ${sexp(transport)} ${sexp(transportHash)} ${sexp(fixture)} canonical) (result wrong-candidate-hash $observation (P4TransportStanding $observation ${sexp(candidateHash)} ${sexp(transportHash)})))`,boot);
assert.equal(wrongRows.length,1);
assert.equal(wrongRows[0][2][0],'p4-trial-failure');
assert.equal(wrongRows[0][3][0],'g31-p4-transport-held');
save(`${dir}/wrong-candidate-hash-result.json`,{
  observation:wrongRows[0][2],standing:wrongRows[0][3]});

const sources=[
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P3/R7/closure.json','docs/gates/G31/P4/assessment.md',
  'docs/gates/G31/P4/R1/plan.json','docs/gates/G31/P4/R1/plan.md',
  'docs/gates/G31/P4/R1/attempt-101-outcome.md',
  'docs/gates/G31/P4/R2/plan.json','docs/gates/G31/P4/R2/plan.md',
  'src/participation.metta','src/surface_transport_qualification_v1.metta',
  'src/bootstrap_surface_transport_qualification_v1.metta',
  'effect_membranes/miter_store.pl','effect_membranes/miter_surface_transport_lab_v1.pl',
  'tests/fixtures/g31/p4_loopback_fixture.json','scripts/g31/p4_run.mjs',
  'scripts/g31/p4_quality.mjs','scripts/g31/p4_verify.mjs','scripts/fidelity/check.mjs'
];
save(`${dir}/manifest.json`,{
  schema:'miter-g31-p4-r2-freeze-v1',plan:'docs/gates/G31/P4/R2/plan.json',
  plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),sourceCandidate,candidate,
    fixture,`${dir}/authorship-audit.json`,`${dir}/canonical-result.json`,
    `${dir}/wrong-principal-result.json`,`${dir}/no-journal-result.json`,
    `${dir}/wrong-candidate-hash-result.json`]),
  candidate_sha256:candidateHash,transport_sha256:transportHash,
  model_calls:0,credential_lookups:0,local_mattermost_requests:0,
  promoted:false,activated:false
});
save(`${dir}/run-verdict.json`,{
  status:'PASS-BOUNDED',candidate_sha256:candidateHash,
  transport_sha256:transportHash,candidate_unchanged:true,
  generic_transport:true,authorized_events:canonical.observation[3],
  unauthorized_events:canonical.observation[4],
  authorization_preceded_payload:canonical.observation[5],
  descriptor_path_preserved:canonical.observation[6],
  effect_identity_preserved:canonical.observation[7],
  loopback_attempts:canonical.observation[8],loopback_creates:canonical.observation[9],
  same_receipt:canonical.observation[10],journal_before_send:canonical.observation[11],
  restart_verified:canonical.observation[12],panic_no_request:canonical.observation[13],
  rollback_inactive:canonical.observation[14],loopback_only:canonical.observation[15],
  credential_used:canonical.observation[16],transport_generic:canonical.observation[17],
  evidence_complete:canonical.observation[18],wrong_principal_held:true,
  no_journal_held:true,wrong_candidate_hash_held:true,
  native_standing:canonical.standing[0],model_calls:0,
  credential_lookups:0,local_mattermost_requests:0,message_reads:0,message_writes:0,
  promoted:false,activated:false
});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
