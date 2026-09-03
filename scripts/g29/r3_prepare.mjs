// Freeze G29 R3 resource and repair relations before inference.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,petta,sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'301';assert.match(tag,/^3[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{save(`${dir}/prepare-failure.json`,{message:error.message,stack:error.stack});console.error(error.stack);process.exitCode=1});
save(`${dir}/opening.json`,checkOpen('docs/gates/G29/R3/plan.json'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');

const r2dir=`${root}/evidence/G29/attempt-210`;
const r1dir=`${root}/evidence/G29/attempt-101`;
const r2final=read(`${r2dir}/final-r2.json`).native;
assert.equal(r2final[0],'surface-extension-incomplete-r2');
const priorCandidate=r2final[1][1];
const r2input=read(`${r2dir}/input.json`).native;
const design=r2input[1],designPart=r2input[2];
const failure=read(`${r2dir}/r2-failure-verdict.json`);
assert.equal(failure.status,'FAIL-EVIDENCE');

const dependencies=[
  ['artifact-obligation','bridge','valid-dict-runtime'],
  ['artifact-obligation','bridge','authorization-before-payload'],
  ['artifact-obligation','bridge','stable-identity'],
  ['artifact-obligation','bridge','idempotency'],
  ['artifact-obligation','tests','syntax'],
  ['artifact-obligation','tests','valid-dict-runtime'],
  ['artifact-obligation','tests','public-contract-exercise']
];
const ref=file=>['evidence-ref',file,`sha256-${hash(fs.readFileSync(`${r2dir}/${file}`))}`];
const observations=[
  ['obligation-observation','r2-bridge-dict','valid-dict-runtime','violated',ref('trial-r2.json')],
  ['obligation-observation','r2-tests-syntax','syntax','violated',ref('trial-r2.json')],
  ['obligation-observation','r2-tests-dict','valid-dict-runtime','violated',ref('trial-r2.json')],
  ['obligation-observation','r2-auth-order','authorization-before-payload','unresolved',ref('r2-failure-verdict.json')],
  ['representation-example','swi-dict','Config = _{server_id:s1}, get_dict(server_id, Config, SID).'],
  ['representation-example','quoted-path',"Path = '/api/v4/posts'."]
];
const resources=[
  ['model-resource','qwen-local','local','configured','schema-compatible','defeated','exhausted',['resource-evidence','attempt-210','repeated-invalid-dict']],
  ['model-resource','nemotron-local','local','configured','schema-compatible','untried','available',['resource-evidence','user-tested-full-gpu','profile-pinned']]
];
const input=['surface-resource-repair-input',design,designPart,priorCandidate,dependencies,observations,resources,
  ['surface-repair-grant','G29-R3',2,2048,300,'native-selected-local-model','no-network','no-credentials'],
  ['repair-provenance','G29-R2','attempt-210','retained-exact-candidate']];
save(`${dir}/input.json`,{native:input});
fs.copyFileSync(`${r2dir}/reference-lock.json`,`${dir}/reference-lock.json`);
const inventory=JSON.parse(execFileSync('/usr/bin/curl',['--silent','--show-error','--max-time','10','http://127.0.0.1:1234/api/v0/models'],{encoding:'utf8'}));
const ids=(inventory.data??[]).map(x=>x.id);
assert(ids.includes('qwen/qwen3.8-27b'));
assert(ids.includes('nemotron-3.5-30b-a3b-antislop-ftpo-i1'));
save(`${dir}/model-inventory.json`,{schema:'miter-local-model-inventory-observation-v1',ids,credentials_used:0,inference_calls:0});

const sources=[
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
  'docs/gates/G29/R3/plan.json','docs/gates/G29/R3/plan.md','docs/gates/G29/R2/outcome.md',
  'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json','config/local/g03-model-profiles.json',
  'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','src/participation_support.metta','src/bootstrap_grounded_language.metta',
  'effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl',
  'scripts/g29/r3_prepare.mjs','scripts/g29/r3_run.mjs','scripts/g29/r3_quality.mjs','scripts/g29/r3_verify.mjs'
];
const retained=[
  `${r2dir}/r2-failure-verdict.json`,`${r2dir}/trial-r2.json`,`${r2dir}/final-r2.json`,
  `${r2dir}/candidate/extension/mattermost_bridge.pl`,`${r2dir}/candidate/candidate_tests/mattermost_contract_tests.pl`,
  `${r1dir}/design-1-observation.json`,`${r1dir}/design-1-wire.json`,
  ...read(`${dir}/reference-lock.json`).files.map(x=>x.path)
];
save(`${dir}/manifest.json`,{schema:'miter-g29-freeze-v1',files:pins([...sources.map(x=>`${root}/${x}`),...retained,`${dir}/input.json`,`${dir}/reference-lock.json`,`${dir}/model-inventory.json`]),
  plan:'docs/gates/G29/R3/plan.json',plan_commit:'7f006db2fecaa2c43afabd30da22d1254a144077',model_selection:'native',max_new_calls:2,
  max_output_tokens_per_call:2048,deadline_seconds:300,capture_bytes:2097152,credentials:[],mattermost_network:false,prior_candidate:'mattermost-r2'});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';
save(`${dir}/services-before.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert(!fs.existsSync(`${root}/runtime/g29/candidates/mattermost-r3`));
for(const slot of [1,2])assert(!fs.existsSync(`${root}/evidence/G29/R3-call-${slot}.claim`));

const reversed=[...resources].reverse();
const removed=resources.filter(x=>x[1]!=='nemotron-local');
const ambiguous=structuredClone(resources);ambiguous[0][5]='supported';ambiguous[0][6]='available';
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const rows=native(dir,'r3-native-preflight',
  `!(result resource (SXSelectResource ${sexp(resources)}))\n`+
  `!(result resource-reordered (SXSelectResource ${sexp(reversed)}))\n`+
  `!(result resource-removed (SXSelectResource ${sexp(removed)}))\n`+
  `!(result resource-ambiguous (SXSelectResource ${sexp(ambiguous)}))\n`+
  `!(result targets (SXRepairTargets ${sexp(dependencies)} ${sexp(observations)}))\n`+
  `!(let $input (sd_input "${dir}") (result bridge-file-valid (PShape (SXTargetFile (index-atom $input 3) bridge) surface-candidate-file 4)))\n`+
  `!(let $input (sd_input "${dir}") (result tests-file-valid (PShape (SXTargetFile (index-atom $input 3) tests) surface-candidate-file 4)))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.equal(map.resource[0],'model-resource-selected');assert.equal(map.resource[1],'nemotron-local');
assert.equal(map['resource-reordered'][1],'nemotron-local');
assert.equal(map['resource-removed'][0],'model-resource-unresolved');assert.deepEqual(map['resource-removed'][1],[]);
assert.equal(map['resource-ambiguous'][0],'model-resource-unresolved');assert.equal(map['resource-ambiguous'][1].length,2);
assert.deepEqual(new Set(map.targets),new Set(['bridge','tests']));
assert.equal(map['bridge-file-valid'],'true');assert.equal(map['tests-file-valid'],'true');
save(`${dir}/preflight-verdict.json`,{status:'PASS-BOUNDED',selected_model:'nemotron-local',reordering_neutral:true,removal_holds:true,
  ambiguity_unresolved:true,native_targets:map.targets,exact_prior_files:true,new_model_calls:0});
save(`${dir}/prepared.json`,{status:'PREPARED',selected_model:'nemotron-local',native_targets:map.targets,new_model_calls:0,prior_failure_retained:true});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
