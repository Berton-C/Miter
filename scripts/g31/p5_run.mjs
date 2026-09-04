// G31 P5 R1: authorized read-only identity resolution; no message effects.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'501';
const resume=process.argv.includes('--resume');
assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p5-${tag}`;
if(resume)assert(fs.existsSync(dir));
else {assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});}
process.on('uncaughtException',error=>{
  save(`${dir}/${resume?'resume-failure':'run-failure'}.json`,{message:error.message,stack:error.stack,
    credential_values_returned:false,post_content_reads:0,message_writes:0,
    api_mutations:0,model_calls:0,promoted:false,activated:false});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G31/P5/R1/plan.json');
assert.equal(opening.plan_commit,'3c64d18ad23166fe272fd9e40958209e4be91414');
if(resume)assert.deepEqual(read(`${dir}/opening.json`),opening);
else save(`${dir}/opening.json`,opening);
const candidate=`${root}/evidence/G31/p3-371/candidate/extension/mattermost_bridge.pl`;
const transport=`${root}/effect_membranes/miter_surface_transport_lab_v1.pl`;
const candidateHash=hash(fs.readFileSync(candidate));
const transportHash=hash(fs.readFileSync(transport));
assert.equal(candidateHash,'cf771e7bdfa571f695a3949177cb33ed6fb04431999e88401163b21a328efca3');
assert.equal(transportHash,'81d2ee5d219e2cdadeb231202d698f0a5cf10a6f50a633cbcf7ccd21e40da4d6');
const probe=`${root}/effect_membranes/miter_mattermost_identity_probe_v1.pl`;
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const goal=`miter_mattermost_identity_probe_v1:g31_identity_probe(${q(dir)},${q(candidateHash)},${q(transportHash)},${q('http://127.0.0.1:8065')},${q('clarityclaw')},${q('miter-g31-canary')},${q('miter-g31-denied')},${q('miter')},${q('ai.bgi.miter.mattermost')},R),writeln(R),halt`;
if(!resume){
  const started=Date.now();
  const processResult=spawnSync(swi,['-q','-f','none','-s',probe,'-g',goal],
    {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024});
  save(`${dir}/probe-process.json`,{status:processResult.status,signal:processResult.signal,
    error:processResult.error?.message??null,elapsed_ms:Date.now()-started,
    stdout:processResult.stdout?.trim()??'',stderr:processResult.stderr?.trim()??''});
  assert.equal(processResult.status,0,processResult.error?.message??processResult.stderr);
  assert.equal(processResult.stderr,'');
} else {
  const priorProbe=read(`${dir}/probe-process.json`);
  assert.equal(priorProbe.status,0);assert.equal(priorProbe.stderr,'');
}
const publicResult=read(`${dir}/identity-redacted.json`);
const observationDoc=read(`${dir}/identity-observation.json`);
const observation=observationDoc.native;
const privatePath=`${root}/config/local/g31/p5-identity-resolution.json`;
assert(fs.existsSync(privatePath));
assert.equal(fs.statSync(privatePath).mode&0o777,0o600);
assert.equal(hash(fs.readFileSync(privatePath)),publicResult.private_record_sha256);
const privateResult=read(privatePath);
assert.equal(privateResult.credential_value,null);
const publicText=JSON.stringify(publicResult)+JSON.stringify(observationDoc);
for(const value of [privateResult.server.id,privateResult.team.id,
  privateResult.allowlisted_channel.id,privateResult.denied_control_channel.id,
  privateResult.bot.id,...privateResult.human_candidates.flatMap(x=>[x.id,x.username])])
  if(value!=='unresolved')assert(!publicText.includes(value),`private value leaked: ${value}`);

const boot=`!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const nativeName=resume?'native-identity-standing-repair':'native-identity-standing';
const rows=native(dir,nativeName,
  `!(result standing (G31IdentityResolutionStanding ${sexp(observation)} ${sexp(candidateHash)} ${sexp(transportHash)}))`,boot);
assert.equal(rows.length,1);const standing=rows[0][2];
const nativeStandingPath=`${dir}/${resume?'native-standing-repair':'native-standing'}.json`;
save(nativeStandingPath,{native:standing});
const expectedComplete=publicResult.resolved.server_id&&publicResult.resolved.team&&
  publicResult.resolved.allow_channel&&publicResult.resolved.allow_bot_member&&
  publicResult.resolved.denied_channel&&publicResult.resolved.denied_bot_member&&
  publicResult.human_candidate_count>0;
assert.equal(standing[0],expectedComplete?
  'g31-identity-resolution-complete-awaiting-human':'g31-identity-resolution-held');
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P4/R3/closure.json','docs/gates/G31/P5/R1/plan.json',
  'docs/gates/G31/P5/R1/plan.md','src/mattermost_live_grant_v1.metta',
  'src/bootstrap_mattermost_live_grant_v1.metta',
  'effect_membranes/miter_mattermost_identity_probe_v1.pl','scripts/g31/p5_run.mjs',
  'scripts/fidelity/check.mjs'];
save(`${dir}/manifest.json`,{schema:'miter-g31-p5-r1-freeze-v1',
  plan:'docs/gates/G31/P5/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),candidate,transport,
    `${dir}/identity-redacted.json`,`${dir}/identity-observation.json`,
    `${dir}/probe-process.json`,nativeStandingPath,
    ...(resume?[`${dir}/run-failure.json`]:[])]),
  private_record:{tracked:false,location:'config/local/ignored',
    sha256:publicResult.private_record_sha256},credential_values_returned:false});
save(`${dir}/run-verdict.json`,{status:expectedComplete?
  'PASS-BOUNDED-AWAITING-HUMAN':'PASS-BOUNDED-HOLD',
  candidate_sha256:candidateHash,transport_sha256:transportHash,
  get_only:publicResult.get_only,request_count:publicResult.request_count,
  resolved:publicResult.resolved,statuses:publicResult.statuses,
  human_candidate_count:publicResult.human_candidate_count,
  human_principal:'unresolved',actual_ids_public:false,
  private_record_mode:'0600',credential_lookups:1,credential_values_returned:false,
  post_content_reads:0,message_reads:0,message_writes:0,api_mutations:0,
  model_calls:0,promoted:false,activated:false,native_standing:standing[0]});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
