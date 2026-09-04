// G31 P8 R1: bind exact human approval and prove the bounded native voice contract.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'801';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p8-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/run-failure.json`,{message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,post_content_reads:0,
    message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
    approved:true,active:false,network_allowed:false,activation:'unresolved'});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G31/P8/R1/plan.json');
assert.equal(opening.plan_commit,'070e5ffbed1f82b5c19e6a625f40a501d3fdebc0');
save(`${dir}/opening.json`,opening);
const approvalPath=`${root}/docs/gates/G31/P8/R1/approval-record.md`;
const proposalPath=`${root}/docs/gates/G31/P7/R1/live-grant-proposal.md`;
const closurePath=`${root}/docs/gates/G31/P7/R1/closure.json`;
const grantPath=`${root}/config/local/g31/p7-inactive-live-grant-v3.json`;
const p7Public=read(`${root}/evidence/G31/p7-707/grant-materialization-redacted.json`);
assert(fs.existsSync(grantPath));assert.equal(fs.statSync(grantPath).mode&0o777,0o600);
const grantHash=hash(fs.readFileSync(grantPath));
assert.equal(grantHash,p7Public.private_grant_sha256);
const approvalHash=hash(fs.readFileSync(approvalPath));
const proposalHash=hash(fs.readFileSync(proposalPath));
const closureHash=hash(fs.readFileSync(closurePath));
assert.equal(approvalHash,'85e16a0ea44a5bc98762612ede5b33f961d9a1d036e601a76b9796a5fe98ee72');
assert.equal(proposalHash,'bd1147f9d25e1e5ead6907e347f27a587866699237b614951b6176525a71bdc1');
assert.equal(closureHash,'dab4a3483ad4fb36d67ecd2c1e95cafe6ceade56cca21cdc3033a9dc5c7b363f');
const candidateHash=p7Public.candidate_hash,transportHash=p7Public.transport_hash;
const approvalArgs=[approvalHash,proposalHash,closureHash,grantHash,candidateHash,transportHash];
for(const value of approvalArgs)assert.match(value,/^[a-f0-9]{64}$/);
const p8Sexp=value=>Array.isArray(value)
  ?`(${value.map(p8Sexp).join(' ')})`
  :typeof value==='string'&&/^[a-f0-9]{64}$/.test(value)
    ?JSON.stringify(value):sexp(value);
const mettaApprovalArgs=approvalArgs.map(p8Sexp).join(' ');
const approvalCall=`(G31LiveEffectApprovalV1 ${mettaApprovalArgs})`;
const approvalStandingCall=approval=>
  `(G31LiveEffectApprovalStanding ${approval} ${mettaApprovalArgs})`;
const boot=`!(import! &self "${root}/src/bootstrap_mattermost_live_canary_v1.metta")\n`;
const constructed=native(dir,'native-approval-construction',
  `!(result approval ${approvalCall})\n`+
  `!(let $approval ${approvalCall} (result standing ${approvalStandingCall('$approval')}))`,boot);
assert.equal(constructed.length,2);
const approval=constructed[0][2],approvalStanding=constructed[1][2];
assert.equal(approval[0],'live-effect-approval-v1');assert.equal(approval.length,15);
assert.equal(approvalStanding[0],'g31-live-effect-approval-bound-awaiting-activation');
save(`${dir}/native-approval.json`,{native:approval});
save(`${dir}/native-approval-standing.json`,{native:approvalStanding});

const requestPath=`${dir}/approval-materialization-request.json`;
save(requestPath,{schema:'miter-g31-approval-materialization-request-v1',
  plan_commit:opening.plan_commit,private_inactive_grant_sha256:grantHash,
  approval_record_sha256:approvalHash,p7_proposal_sha256:proposalHash,
  p7_closure_sha256:closureHash,candidate_hash:candidateHash,
  transport_hash:transportHash,active:false,network_allowed:false,
  activation:'unresolved',approval});
const probe=`${root}/effect_membranes/miter_mattermost_approval_materialize_v1.pl`;
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const goal=`miter_mattermost_approval_materialize_v1:g31_materialize_approval(${q(dir)},${q(requestPath)},${q(grantPath)},${q(grantHash)},${q(approvalHash)},${q(proposalHash)},${q(closureHash)},${q(candidateHash)},${q(transportHash)},R),writeln(R),halt`;
const started=Date.now();
const processResult=spawnSync(swi,['-q','-f','none','-s',probe,'-g',goal],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:8*1024*1024});
save(`${dir}/materialization-process.json`,{status:processResult.status,
  signal:processResult.signal,error:processResult.error?.message??null,
  elapsed_ms:Date.now()-started,stdout:processResult.stdout?.trim()??'',
  stderr:processResult.stderr?.trim()??''});
assert.equal(processResult.status,0,processResult.error?.message??processResult.stderr);
assert.equal(processResult.stderr,'');
assert(processResult.stdout.includes('g31-approval-materialization-observation'));
const materialized=read(`${dir}/approval-materialization-redacted.json`);
const materializationObservation=read(`${dir}/approval-materialization-observation.json`);
const privateApprovalPath=`${root}/config/local/g31/p8-live-effect-approval-v1.json`;
assert(fs.existsSync(privateApprovalPath));
assert.equal(fs.statSync(privateApprovalPath).mode&0o777,0o600);
assert.equal(hash(fs.readFileSync(privateApprovalPath)),materialized.private_approval_sha256);
const privateApproval=read(privateApprovalPath),privateGrant=read(grantPath);
assert.deepEqual(privateApproval.approval,approval);
assert.equal(privateApproval.active,false);assert.equal(privateApproval.network_allowed,false);
assert.equal(privateApproval.activation,'unresolved');assert.equal(privateApproval.expires_at,null);
assert.equal(privateGrant.active,false);assert.equal(privateGrant.network_allowed,false);

const approvalChanged=(index,value)=>{const copy=structuredClone(approval);copy[index]=value;return copy;};
const approvalCases={
  canonical:approval,
  'authority-severed':approvalChanged(1,['authority','self-inferred']),
  'approval-source-severed':approvalChanged(2,['approval-record-sha256','0'.repeat(64)]),
  'grant-lineage-severed':approvalChanged(5,['private-inactive-grant-sha256','0'.repeat(64)]),
  'memory-scope-expanded':approvalChanged(11,['memory-access','history','allowed','chroma','allowed','prior-memory','allowed']),
  'activation-conflated':approvalChanged(14,['activation','active']),
  'neutral-json-roundtrip':JSON.parse(JSON.stringify(approval)),
  restored:approval
};
const approvalTrialBody=Object.entries(approvalCases).map(([name,value])=>
  `!(result ${name} ${approvalStandingCall(p8Sexp(value))})`).join('\n');
const approvalTrials=native(dir,'native-approval-trials',approvalTrialBody,boot);
const approvalStandings=Object.fromEntries(approvalTrials.map(row=>[row[1],row[2]]));
for(const name of ['canonical','neutral-json-roundtrip','restored'])
  assert.equal(approvalStandings[name][0],'g31-live-effect-approval-bound-awaiting-activation');
for(const name of ['authority-severed','approval-source-severed','grant-lineage-severed',
  'memory-scope-expanded','activation-conflated'])
  assert.equal(approvalStandings[name][0],'g31-live-effect-approval-held');
save(`${dir}/native-approval-trial-standings.json`,{native:approvalStandings});

const ids=p7Public.identity_hashes;
const canaryText='Miter G31 bounded live canary';
const utterance='Miter received this bounded G31 canary contact. This response is certified only for the current test; it grants no ongoing access and used no history, Chroma, or prior memory.';
const postHash=hash(Buffer.from('p8-synthetic-new-post'));
const versionHash=hash(Buffer.from('p8-synthetic-post-version'));
const contentHash=hash(Buffer.from(canaryText));
const utteranceHash=hash(Buffer.from(utterance));
const effectHash=hash(Buffer.from(`g31:${postHash}:create-post`));
const contact=['g31-live-canary-contact-v1',
  ['server-sha256',ids.server],['team-sha256',ids.team],
  ['channel-sha256',ids.allow_channel],['principal-sha256',ids.human_principal],
  ['post-sha256',postHash],['version-sha256',versionHash],
  ['content-sha256',contentHash],['event-class','posted'],
  ['contact-scope','exact-current-event-only'],['history-access','false'],
  ['chroma-access','false'],['prior-memory-access','false']];
const voiceArgs=(standing,currentContact,currentUtterance,currentUtteranceHash=utteranceHash,
  currentEffectHash=effectHash)=>[
    p8Sexp(standing),p8Sexp(currentContact),p8Sexp(currentUtterance),
    p8Sexp(currentUtteranceHash),p8Sexp(utteranceHash),p8Sexp(currentEffectHash),
    p8Sexp(effectHash),p8Sexp(ids.server),p8Sexp(ids.team),
    p8Sexp(ids.allow_channel),p8Sexp(ids.human_principal),p8Sexp(postHash),
    p8Sexp(versionHash),p8Sexp(contentHash)].join(' ');
const wrongChannel=structuredClone(contact);wrongChannel[3][1]='0'.repeat(64);
const historyExpanded=structuredClone(contact);historyExpanded[10][1]='true';
const heldApproval=approvalStandings['authority-severed'];
const voiceCases={
  canonical:[approvalStanding,contact,utterance],
  'approval-severed':[heldApproval,contact,utterance],
  'contact-identity-severed':[approvalStanding,wrongChannel,utterance],
  'memory-boundary-severed':[approvalStanding,historyExpanded,utterance],
  'utterance-severed':[approvalStanding,contact,utterance+' I can keep listening.'],
  'utterance-hash-severed':[approvalStanding,contact,utterance,'0'.repeat(64)],
  'effect-identity-severed':[approvalStanding,contact,utterance,utteranceHash,'0'.repeat(64)],
  'neutral-json-roundtrip':[JSON.parse(JSON.stringify(approvalStanding)),
    JSON.parse(JSON.stringify(contact)),utterance],
  restored:[approvalStanding,contact,utterance]
};
const voiceTrialBody=Object.entries(voiceCases).map(([name,values])=>{
  const [standing,currentContact,currentUtterance,currentUtteranceHash,currentEffectHash]=values;
  return `!(result ${name} (G31CanaryVoiceCertificate ${voiceArgs(standing,currentContact,
    currentUtterance,currentUtteranceHash,currentEffectHash)}))`;
}).join('\n');
const voiceTrials=native(dir,'native-canary-voice-trials',voiceTrialBody,boot);
const voiceStandings=Object.fromEntries(voiceTrials.map(row=>[row[1],row[2]]));
for(const name of ['canonical','neutral-json-roundtrip','restored'])
  assert.equal(voiceStandings[name][0],'CertifiedUtterance');
for(const name of ['approval-severed','contact-identity-severed','memory-boundary-severed',
  'utterance-severed','utterance-hash-severed','effect-identity-severed'])
  assert.equal(voiceStandings[name][0],'g31-canary-voice-held');
save(`${dir}/native-canary-voice-trial-standings.json`,{native:voiceStandings});
save(`${dir}/bounded-voice-artifact.json`,{schema:'miter-g31-bounded-canary-voice-v1',
  claim_scope:'fixed-live-protocol-acknowledgement-only',canary_content_sha256:contentHash,
  utterance_sha256:utteranceHash,effect_id_sha256:effectHash,
  certificate:voiceStandings.canonical,model_calls:0});

const privateValues=[privateGrant.identity_bindings.server.id,
  privateGrant.identity_bindings.team.id,privateGrant.identity_bindings.allowlisted_channel.id,
  privateGrant.identity_bindings.denied_control_channel.id,
  privateGrant.identity_bindings.human.id,privateGrant.identity_bindings.human.username,
  privateGrant.identity_bindings.bot.id];
const publicText=fs.readdirSync(dir).filter(name=>name.endsWith('.json')||name.endsWith('.stdout')||name.endsWith('.stderr'))
  .map(name=>fs.readFileSync(`${dir}/${name}`,'utf8')).join('\n');
for(const value of privateValues)assert(!publicText.includes(value),`private value leaked: ${value}`);
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P7/R1/closure.json','docs/gates/G31/P7/R1/live-grant-proposal.md',
  'docs/gates/G31/P8/R1/approval-record.md','docs/gates/G31/P8/R1/plan.json',
  'docs/gates/G31/P8/R1/plan.md','src/mattermost_live_canary_v1.metta',
  'src/bootstrap_mattermost_live_canary_v1.metta',
  'effect_membranes/miter_mattermost_approval_materialize_v1.pl',
  'scripts/g31/p8_run.mjs','scripts/fidelity/check.mjs'];
save(`${dir}/manifest.json`,{schema:'miter-g31-p8-r1-freeze-v1',
  plan:'docs/gates/G31/P8/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),
    `${dir}/native-approval.json`,`${dir}/native-approval-standing.json`,requestPath,
    `${dir}/approval-materialization-redacted.json`,
    `${dir}/approval-materialization-observation.json`,`${dir}/materialization-process.json`,
    `${dir}/native-approval-trial-standings.json`,
    `${dir}/native-canary-voice-trial-standings.json`,`${dir}/bounded-voice-artifact.json`]),
  private_records:[
    {tracked:false,location:'config/local/ignored',sha256:grantHash,mode:'0600'},
    {tracked:false,location:'config/local/ignored',
      sha256:materialized.private_approval_sha256,mode:'0600'}],
  actual_identity_public:false,credential_values_returned:false});
save(`${dir}/run-verdict.json`,{status:'PASS-BOUNDED-APPROVAL-BOUND-INACTIVE',
  approval_record_sha256:approvalHash,p7_proposal_sha256:proposalHash,
  p7_closure_sha256:closureHash,private_grant_sha256:grantHash,
  candidate_sha256:candidateHash,transport_sha256:transportHash,
  authority:'berton-explicit',approved:true,active:false,network_allowed:false,
  activation:'unresolved',timer_started:false,private_approval_mode:'0600',
  native_approval_standing:approvalStanding[0],native_voice_contract:'CertifiedUtterance',
  voice_claim_scope:'fixed-live-protocol-acknowledgement-only',
  approval_severed_held:true,voice_severed_held:true,neutral_preserved:true,restored:true,
  network_requests:0,credential_lookups:0,post_content_reads:0,
  message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
  promoted:false,activated:false});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
