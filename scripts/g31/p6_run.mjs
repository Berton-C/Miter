// G31 P6 R1: bind an explicitly selected principal; no live effects.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'601';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G31/p6-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/run-failure.json`,{message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,post_content_reads:0,
    message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
    promoted:false,activated:false});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G31/P6/R1/plan.json');
assert.equal(opening.plan_commit,'68303fadaa0e050e43364ebbf3e0336d9d8cf78b');
save(`${dir}/opening.json`,opening);
const identityPath=`${root}/config/local/g31/p5-identity-resolution.json`;
const selectionPath=`${root}/config/local/g31/p6-selection-request.json`;
for(const path of [identityPath,selectionPath]){
  assert(fs.existsSync(path));assert.equal(fs.statSync(path).mode&0o777,0o600);
}
const p5Public=read(`${root}/evidence/G31/p5-502/identity-redacted.json`);
const identityHash=hash(fs.readFileSync(identityPath));
assert.equal(identityHash,p5Public.private_record_sha256);
const candidateHash=p5Public.candidate_hash,transportHash=p5Public.transport_hash;
const probe=`${root}/effect_membranes/miter_mattermost_principal_binding_v1.pl`;
const q=value=>`'${String(value).replaceAll("'","''")}'`;
const goal=`miter_mattermost_principal_binding_v1:g31_bind_principal(${q(dir)},${q(selectionPath)},${q(identityPath)},${q(identityHash)},${q(candidateHash)},${q(transportHash)},R),writeln(R),halt`;
const started=Date.now();
const processResult=spawnSync(swi,['-q','-f','none','-s',probe,'-g',goal],
  {cwd:root,encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024});
save(`${dir}/binding-process.json`,{status:processResult.status,
  signal:processResult.signal,error:processResult.error?.message??null,
  elapsed_ms:Date.now()-started,stdout:processResult.stdout?.trim()??'',
  stderr:processResult.stderr?.trim()??''});
assert.equal(processResult.status,0,processResult.error?.message??processResult.stderr);
assert.equal(processResult.stderr,'');

const publicResult=read(`${dir}/principal-binding-redacted.json`);
const observationDoc=read(`${dir}/principal-binding-observation.json`);
const privateBindingPath=`${root}/config/local/g31/p6-principal-binding.json`;
assert(fs.existsSync(privateBindingPath));
assert.equal(fs.statSync(privateBindingPath).mode&0o777,0o600);
assert.equal(hash(fs.readFileSync(privateBindingPath)),publicResult.private_binding_sha256);
const identity=read(identityPath),selection=read(selectionPath),binding=read(privateBindingPath);
assert.equal(binding.live_effect_approval,'unresolved');
assert.equal(binding.authority,'berton-explicit');
assert.equal(binding.selected_human.username,selection.selected_username);
const matching=identity.human_candidates.filter(x=>x.username===selection.selected_username);
assert.equal(matching.length,1);assert.deepEqual(binding.selected_human,matching[0]);
const trackedText=JSON.stringify(publicResult)+JSON.stringify(observationDoc);
for(const value of [binding.selected_human.id,binding.selected_human.username])
  assert(!trackedText.includes(value),'private human identity leaked');

const observation=observationDoc.native;
const authoritySevered=structuredClone(observation);authoritySevered[8]='self-inferred';
const effectSevered=structuredClone(observation);effectSevered[9]='approved';
const disclosureSevered=structuredClone(observation);disclosureSevered[10]=true;
const neutral=JSON.parse(JSON.stringify(observation));
const wrongSource='0'.repeat(64);
const boot=`!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const body=[
  ['canonical',observation,identityHash],
  ['wrong-source',observation,wrongSource],
  ['inferred-authority',authoritySevered,identityHash],
  ['effect-authority-conflated',effectSevered,identityHash],
  ['identity-disclosed',disclosureSevered,identityHash],
  ['neutral-roundtrip',neutral,identityHash],
  ['restored',observation,identityHash]
].map(([name,value,source])=>
  `!(result ${name} (G31PrincipalBindingStanding ${sexp(value)} ${candidateHash} ${transportHash} ${source}))`).join('\n');
const rows=native(dir,'native-principal-binding',body,boot);
assert.equal(rows.length,7);
const standings=Object.fromEntries(rows.map(row=>[row[1],row[2]]));
for(const name of ['canonical','neutral-roundtrip','restored'])
  assert.equal(standings[name][0],'g31-human-principal-bound-awaiting-live-grant');
for(const name of ['wrong-source','inferred-authority','effect-authority-conflated','identity-disclosed'])
  assert.equal(standings[name][0],'g31-human-principal-binding-held');
save(`${dir}/native-standings.json`,{native:standings});

const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','POC_SPEC.md','DECISIONS.md',
  'docs/gates/G31/P5/R1/closure.json','docs/gates/G31/P6/R1/plan.json',
  'docs/gates/G31/P6/R1/plan.md','src/mattermost_live_grant_v1.metta',
  'src/bootstrap_mattermost_live_grant_v1.metta',
  'effect_membranes/miter_mattermost_principal_binding_v1.pl','scripts/g31/p6_run.mjs',
  'scripts/fidelity/check.mjs'];
save(`${dir}/manifest.json`,{schema:'miter-g31-p6-r1-freeze-v1',
  plan:'docs/gates/G31/P6/R1/plan.json',plan_commit:opening.plan_commit,
  files:pins([...sources.map(file=>`${root}/${file}`),
    `${dir}/principal-binding-redacted.json`,
    `${dir}/principal-binding-observation.json`,`${dir}/binding-process.json`,
    `${dir}/native-standings.json`]),
  private_records:[
    {tracked:false,location:'config/local/ignored',sha256:identityHash},
    {tracked:false,location:'config/local/ignored',sha256:publicResult.private_binding_sha256}
  ],actual_identity_public:false,credential_values_returned:false});
save(`${dir}/run-verdict.json`,{status:'PASS-BOUNDED-AWAITING-LIVE-GRANT',
  candidate_sha256:candidateHash,transport_sha256:transportHash,
  source_identity_sha256:identityHash,selection_supplied:true,match_count:1,
  authority:'berton-explicit',actual_identity_public:false,
  private_binding_mode:'0600',live_effect_approval:'unresolved',
  network_requests:0,credential_lookups:0,post_content_reads:0,
  message_reads:0,message_writes:0,api_mutations:0,model_calls:0,
  promoted:false,activated:false,
  native_standing:standings.canonical[0],severed_held:true,
  neutral_preserved:true,restored:true});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
