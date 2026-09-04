// G33 R4 bounded mechanical membrane experiment. Native MeTTa forms and
// audits meaning; this builder creates synthetic grants/manifests and captures.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {base,sexp,parse} from '../sc04/fixtures.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R4/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} exists`);fs.mkdirSync(dir,{recursive:true});
const counters={localhost_model_calls:0,external_network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,external_effects:0};
process.on('uncaughtException',error=>{save(`${dir}/runner-failure.json`,
  {status:'FAIL-RUNNER',message:error.message,stack:error.stack,...counters});
  console.error(error.stack);process.exitCode=1});
const opening=checkOpen('docs/gates/G33/R4/plan.json');
assert.equal(opening.plan_commit,'01bc72946cb758c835f8b4adabbc7928b69449ac');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const required=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md',
  'constitution/soul_compass_v02.metta','src/participation.metta',
  'src/participation_support.metta','src/grounded_language.metta',
  'src/bootstrap_grounded_language.metta','src/relational_voice.metta',
  'src/bootstrap_relational_voice.metta','effect_membranes/miter_language.pl',
  'effect_membranes/miter_relational_voice_v2.pl','effect_membranes/miter_store.pl',
  'effect_membranes/miter_llm.pl','config/relational-voice-runtime-grant-v1.json',
  'config/local/g03-model-profiles.json'];
const fixture=read(`${root}/tests/fixtures/g33_r4/cases.json`),c=base();
const scope=c.scope,id='g33-r4-live';
const args=[scope,c.nodes,c.registry,c.current,c.operations,c.target,c.budget,c.proposals]
  .map(sexp).join(' '),ground=`(GroundLanguage ${args})`,intent=`(RIntend ${id} ${ground})`;

function manifest(){
  return {schema:'miter-relational-voice-integrity-manifest-v2',source_root:`${root}/`,
    files:required.map(logical_path=>({logical_path,path:`${root}/${logical_path}`,
      sha256:hash(fs.readFileSync(`${root}/${logical_path}`))}))};
}
function grant(caseRoot,overrides={}){const now=Date.now()/1000;return {
  schema:'miter-relational-voice-runtime-grant-v1',root:caseRoot,request_id:id,scope,
  purpose:'bounded-relational-expression-rendering',model_alias:'qwen-local',
  endpoint:'http://127.0.0.1:1234/v1/chat/completions',max_calls:1,
  external_human_emission:false,issued_at_epoch:now,expires_at_epoch:now+600,...overrides};}
function prepare(name,{grantChanges={},manifestChange=x=>x,malformedGrant=null,
  malformedManifest=null}={}){
  const caseRoot=`${dir}/${name}`;fs.mkdirSync(caseRoot,{recursive:true});
  if(malformedGrant===null)save(`${caseRoot}/runtime-grant.json`,grant(caseRoot,grantChanges));
  else fs.writeFileSync(`${caseRoot}/runtime-grant.json`,malformedGrant);
  if(malformedManifest===null)save(`${caseRoot}/manifest.json`,manifestChange(manifest()));
  else fs.writeFileSync(`${caseRoot}/manifest.json`,malformedManifest);
  return caseRoot;
}
function runNative(name,program,timeout=130000){const path=`${dir}/${name}.metta`;save(path,program);
  const started=Date.now(),p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,
    '--',path,'silent'],{cwd:root,encoding:'utf8',timeout,maxBuffer:128*1024*1024});
  save(`${dir}/${name}.stdout`,p.stdout??'');save(`${dir}/${name}.stderr`,p.stderr??'');
  save(`${dir}/${name}-process.json`,{status:p.status,signal:p.signal,error:p.error?.message,
    elapsed_ms:Date.now()-started});assert.equal(p.status,0,name);assert.equal(p.stderr,'',name);
  const products={};for(const line of p.stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(result '))continue;const row=parse(line);products[row[1]]=row[2];}
  assert(Object.keys(products).length,name);return products;}
const boot=`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`;
const validRoot=prepare('valid');
const positive=runNative('positive',boot+`!(result intended ${intent})\n`+
  `!(result public (RRun "${validRoot}" ${id} ${ground}))\n`);
if(fs.existsSync(`${validRoot}/worker-started.json`))counters.localhost_model_calls++;
assert.equal(counters.localhost_model_calls,1);

const invalid=[];
function rejection(name,options,expected,rootOverride=null){const caseRoot=prepare(name,options);
  const usedRoot=rootOverride??caseRoot;
  const p=runNative(`reject-${name}`,boot+
    `!(result rejected (rv_save_intention "${usedRoot}" ${intent}))\n`,60000);
  invalid.push({name,root:usedRoot,expected,product:p.rejected,
    worker_started:fs.existsSync(`${caseRoot}/worker-started.json`)});}
rejection('root-mismatch',{grantChanges:{root:`${dir}/elsewhere`}},'runtime-grant-invalid');
rejection('scope-mismatch',{grantChanges:{scope:['scope','other-cut','other','other','other']}},
  'runtime-grant-invalid');
rejection('external-emission-true',{grantChanges:{external_human_emission:true}},
  'runtime-grant-invalid');
rejection('call-limit-overbroad',{grantChanges:{max_calls:2}},'runtime-grant-invalid');
rejection('external-endpoint',{grantChanges:{endpoint:'https://example.invalid/v1/chat/completions'}},
  'runtime-grant-invalid');
{const now=Date.now()/1000;rejection('expired-grant',{grantChanges:{issued_at_epoch:now-700,
  expires_at_epoch:now-100}},'runtime-grant-invalid');}
rejection('unknown-grant-schema',{grantChanges:{schema:'unknown'}},'runtime-grant-invalid');
rejection('malformed-grant-json',{malformedGrant:'{'},'runtime-grant-invalid');
rejection('missing-grant-root',{grantChanges:{root:undefined}},'runtime-grant-invalid');
rejection('malformed-manifest-json',{malformedManifest:'{'},
  'runtime-integrity-manifest-invalid');
rejection('missing-manifest-entry',{manifestChange:m=>({...m,
  files:m.files.filter(x=>x.logical_path!=='src/relational_voice.metta')})},
  'runtime-integrity-manifest-invalid');
rejection('tampered-source-hash',{manifestChange:m=>{const copy=structuredClone(m);
  copy.files.find(x=>x.logical_path==='src/relational_voice.metta').sha256='0'.repeat(64);return copy;}},
  'runtime-integrity-manifest-invalid');
const traversalTarget=prepare('traversal-target');
const traversalRoot=`${dir}/traversal-parent/../traversal-target`;
fs.mkdirSync(`${dir}/traversal-parent`,{recursive:true});
rejection('traversal-root-alias',{},'runtime-root-invalid',traversalRoot);
const symlinkTarget=prepare('symlink-target');
const symlinkRoot=`${dir}/symlink-root`;
fs.symlinkSync(symlinkTarget,symlinkRoot,'dir');
const symlinkProgram=runNative('reject-symlink-root-alias',boot+
  `!(result rejected (rv_save_intention "${symlinkRoot}" ${intent}))\n`,60000);
invalid.push({name:'symlink-root-alias',root:symlinkRoot,expected:'runtime-root-invalid',
  product:symlinkProgram.rejected,
  worker_started:false});
const second=runNative('second-call',boot+
  `!(result second (RRun "${validRoot}" ${id} ${ground}))\n`,60000);

const nativeResult=read(`${validRoot}/native-result.json`),candidate=read(`${validRoot}/candidate.json`);
const publicHead=positive.public?.[0],disposition=positive.public?.[2];
const validPublic=publicHead==='voice-result'&&disposition&&
  ['expression-ready','expression-incomplete','repair-request'].includes(disposition[0]);
assert.equal(validPublic,true);
for(const row of invalid){assert.equal(row.product,row.expected,row.name);
  assert.equal(row.worker_started,false,row.name);}
assert.deepEqual(second.second,['expression-storage-fault','intention-storage-failed']);
const observations={schema:'miter-g33-r4-observations-v1',positive:{product:positive.public,
  candidate,native_result:nativeResult,valid_public_product:validPublic,
  worker_started:fs.existsSync(`${validRoot}/worker-started.json`),
  request_written:fs.existsSync(`${validRoot}/request.json`),
  raw_written:fs.existsSync(`${validRoot}/raw.json`),human_emission:false,
  external_effect_authority:false},invalid,second_call:second.second,
  frozen_case_names:fixture.pre_transport_rejections,
  old_sc05_membrane_modified:false,pure_relational_source_modified:false,...counters};
save(`${dir}/observations.json`,observations);
const verdict={status:'PASS-BOUNDED',gate:'G33',revision:'R4',
  runtime_root_capability_verified:true,current_public_entry_ran:true,
  invalid_grants_rejected_before_transport:invalid.length,
  second_call_rejected:true,native_disposition:disposition[0],
  human_emission:false,...counters,
  limits:'One synthetic localhost rendering through current RRun; no claim of repair, certification, human benefit, emission, or later G33 phases.'};
save(`${dir}/verdict.json`,verdict);
const sourceFiles=['docs/gates/G33/R4/plan.json','config/relational-voice-runtime-grant-v1.json',
  'tests/fixtures/g33_r4/cases.json','scripts/g33_r4/run.mjs',
  ...required.filter(x=>x!=='config/local/g03-model-profiles.json')];
save(`${dir}/freeze.json`,{schema:'miter-g33-r4-freeze-v1',plan_commit:opening.plan_commit,
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(x=>`${root}/${x}`)),...counters});
console.log(JSON.stringify(verdict));
