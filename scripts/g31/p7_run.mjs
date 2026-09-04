// G31 P7 R1: native construction and private materialization of an inactive grant.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'701';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p7-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/run-failure.json`,{message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,post_content_reads:0,
    message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
    promoted:false,activated:false,live_effect_approval:'unresolved'});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G31/P7/R1/plan.json');
assert.equal(opening.plan_commit,'0d13d64bebdb40524b1e7af9d0676c553167d889');
save(`${dir}/opening.json`,opening);
const identityPath=`${root}/config/local/g31/p5-identity-resolution.json`;
const bindingPath=`${root}/config/local/g31/p6-principal-binding.json`;
for(const path of [identityPath,bindingPath]){
  assert(fs.existsSync(path));assert.equal(fs.statSync(path).mode&0o777,0o600);
}
const p5=read(`${root}/evidence/G31/p5-502/identity-redacted.json`);
const p6=read(`${root}/evidence/G31/p6-603/principal-binding-redacted.json`);
const identityHash=hash(fs.readFileSync(identityPath));
const bindingHash=hash(fs.readFileSync(bindingPath));
assert.equal(identityHash,p5.private_record_sha256);
assert.equal(bindingHash,p6.private_binding_sha256);
const candidateHash=p5.candidate_hash,transportHash=p5.transport_hash;
const closurePaths=['docs/gates/G31/P3/R7/closure.json','docs/gates/G31/P4/R3/closure.json',
  'docs/gates/G31/P5/R1/closure.json','docs/gates/G31/P6/R1/closure.json'];
const closureHashes=closurePaths.map(path=>hash(fs.readFileSync(`${root}/${path}`)));
const identityHashes={server:p5.identity_sha256.server,team:p5.identity_sha256.team,
  allow_channel:p5.identity_sha256.allow_channel,
  denied_channel:p5.identity_sha256.denied_channel,bot:p5.identity_sha256.bot,
  human_principal:p6.principal_id_sha256};
const args=[candidateHash,transportHash,identityHash,bindingHash,
  identityHashes.server,identityHashes.team,identityHashes.allow_channel,
  identityHashes.denied_channel,identityHashes.human_principal,identityHashes.bot,
  ...closureHashes];
assert.equal(args.length,14);for(const value of args)assert.match(value,/^[a-f0-9]{64}$/);
const p7Sexp=value=>Array.isArray(value)
  ?`(${value.map(p7Sexp).join(' ')})`
  :typeof value==='string'&&/^[a-f0-9]{64}$/.test(value)
    ?JSON.stringify(value)
    :value==='ai.bgi.miter.mattermost'?value:sexp(value);
const mettaArgs=args.map(p7Sexp).join(' ');
const call=`(G31InactiveGrantV3 ${mettaArgs})`;
const standingCall=grant=>`(G31InactiveGrantStanding ${grant} ${mettaArgs})`;
const boot=`!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const constructed=native(dir,'native-grant-construction',
  `!(result grant ${call})\n!(let $grant ${call} (result standing ${standingCall('$grant')}))`,boot);
assert.equal(constructed.length,2);
const grant=constructed[0][2],standing=constructed[1][2];
assert.equal(grant[0],'live-grant-v3');assert.equal(grant.length,28);
assert.equal(standing[0],'g31-inactive-live-grant-ready-for-human-review');
save(`${dir}/native-grant.json`,{native:grant});
save(`${dir}/native-construction-standing.json`,{native:standing});

const requestPath=`${dir}/grant-materialization-request.json`;
save(requestPath,{schema:'miter-g31-grant-materialization-request-v1',
  plan_commit:opening.plan_commit,candidate_hash:candidateHash,
  transport_hash:transportHash,source_identity_sha256:identityHash,
  source_binding_sha256:bindingHash,identity_hashes:identityHashes,
  live_effect_approval:'unresolved',grant});
const probe=`${root}/effect_membranes/miter_mattermost_grant_materialize_v1.pl`;
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const goal=`miter_mattermost_grant_materialize_v1:g31_materialize_grant(${q(dir)},${q(requestPath)},${q(identityPath)},${q(bindingPath)},${q(identityHash)},${q(bindingHash)},${q(candidateHash)},${q(transportHash)},R),writeln(R),halt`;
const started=Date.now();
const processResult=spawnSync(swi,['-q','-f','none','-s',probe,'-g',goal],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:8*1024*1024});
save(`${dir}/materialization-process.json`,{status:processResult.status,
  signal:processResult.signal,error:processResult.error?.message??null,
  elapsed_ms:Date.now()-started,stdout:processResult.stdout?.trim()??'',
  stderr:processResult.stderr?.trim()??''});
assert.equal(processResult.status,0,processResult.error?.message??processResult.stderr);
assert.equal(processResult.stderr,'');
assert(processResult.stdout.includes('g31-grant-materialization-observation'),
  'materialization-contract');
const materialized=read(`${dir}/grant-materialization-redacted.json`);
const materializationObservation=read(`${dir}/grant-materialization-observation.json`);
const privateGrantPath=`${root}/config/local/g31/p7-inactive-live-grant-v3.json`;
assert(fs.existsSync(privateGrantPath));assert.equal(fs.statSync(privateGrantPath).mode&0o777,0o600);
assert.equal(hash(fs.readFileSync(privateGrantPath)),materialized.private_grant_sha256);
const privateGrant=read(privateGrantPath),identity=read(identityPath),binding=read(bindingPath);
assert.deepEqual(privateGrant.grant,grant);assert.equal(privateGrant.active,false);
assert.equal(privateGrant.network_allowed,false);
assert.equal(privateGrant.live_effect_approval,'unresolved');
assert.equal(privateGrant.credential_value,null);
assert.equal(privateGrant.identity_bindings.human.id,binding.selected_human.id);
assert.equal(privateGrant.identity_bindings.server.id,identity.server.id);
const publicText=JSON.stringify(grant)+JSON.stringify(materialized)+
  JSON.stringify(materializationObservation);
for(const value of [privateGrant.identity_bindings.server.id,
  privateGrant.identity_bindings.team.id,privateGrant.identity_bindings.allowlisted_channel.id,
  privateGrant.identity_bindings.denied_control_channel.id,
  privateGrant.identity_bindings.human.id,privateGrant.identity_bindings.human.username,
  privateGrant.identity_bindings.bot.id])assert(!publicText.includes(value),'private identity leaked');

const changed=(index,value)=>{const copy=structuredClone(grant);copy[index]=value;return copy;};
const wrongAllow=structuredClone(grant);wrongAllow[5][1][2]='0'.repeat(64);
const cases={
  canonical:grant,
  'voice-severed':changed(15,'unresolved'),
  'allowlist-severed':wrongAllow,
  'source-evidence-severed':changed(25,['source-evidence']),
  'approval-conflated':changed(27,['live-effect-approval','approved']),
  'neutral-json-roundtrip':JSON.parse(JSON.stringify(grant)),
  restored:grant
};
const trialBody=Object.entries(cases).map(([name,value])=>
  `!(result ${name} ${standingCall(p7Sexp(value))})`).join('\n');
const trials=native(dir,'native-grant-trials',trialBody,boot);
assert.equal(trials.length,Object.keys(cases).length);
const trialStandings=Object.fromEntries(trials.map(row=>[row[1],row[2]]));
for(const name of ['canonical','neutral-json-roundtrip','restored'])
  assert.equal(trialStandings[name][0],'g31-inactive-live-grant-ready-for-human-review');
for(const name of ['voice-severed','allowlist-severed','source-evidence-severed','approval-conflated'])
  assert.equal(trialStandings[name][0],'g31-inactive-live-grant-held');
save(`${dir}/native-trial-standings.json`,{native:trialStandings});

const proposal=`${root}/docs/gates/G31/P7/R1/live-grant-proposal.md`;
const proposalText=fs.readFileSync(proposal,'utf8');
for(const required of ['not approved and not active','two allowlisted input posts',
  'one denied-control input post','two outbound response effects','30 minutes',
  'VoiceRNA','Existing channel history is outside scope','Ongoing access: none'])
  assert(proposalText.includes(required),`proposal missing ${required}`);
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  ...closurePaths,'docs/gates/G31/P7/R1/plan.json','docs/gates/G31/P7/R1/plan.md',
  'docs/gates/G31/P7/R1/live-grant-proposal.md','src/mattermost_live_grant_v1.metta',
  'src/bootstrap_mattermost_live_grant_v1.metta',
  'effect_membranes/miter_mattermost_grant_materialize_v1.pl','scripts/g31/p7_run.mjs',
  'scripts/fidelity/check.mjs'];
save(`${dir}/manifest.json`,{schema:'miter-g31-p7-r1-freeze-v1',
  plan:'docs/gates/G31/P7/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),
    `${dir}/native-grant.json`,`${dir}/native-construction-standing.json`,
    requestPath,`${dir}/grant-materialization-redacted.json`,
    `${dir}/grant-materialization-observation.json`,`${dir}/materialization-process.json`,
    `${dir}/native-trial-standings.json`]),
  private_grant:{tracked:false,location:'config/local/ignored',
    sha256:materialized.private_grant_sha256,mode:'0600'},
  actual_identity_public:false,credential_values_returned:false});
save(`${dir}/run-verdict.json`,{status:'PASS-BOUNDED-INACTIVE-GRANT-READY-FOR-REVIEW',
  candidate_sha256:candidateHash,transport_sha256:transportHash,
  identity_sha256:identityHash,binding_sha256:bindingHash,
  grant_schema:'live-grant-v3',grant_fields:27,
  public_review:'docs/gates/G31/P7/R1/live-grant-proposal.md',
  actual_identity_public:false,private_grant_mode:'0600',
  live_effect_approval:'unresolved',active:false,network_allowed:false,
  network_requests:0,credential_lookups:0,post_content_reads:0,
  message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
  promoted:false,activated:false,native_standing:standing[0],
  severed_held:true,neutral_preserved:true,restored:true});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
