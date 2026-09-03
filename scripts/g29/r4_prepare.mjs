// Freeze the transient-load recovery operation and unchanged candidate obligations.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,petta,sexp} from '../g22_v2/common.mjs';

process.chdir(root);const tag=process.argv[2]??'402';assert.match(tag,/^4[0-9]{2}$/);const dir=`${root}/evidence/G29/attempt-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{save(`${dir}/prepare-failure.json`,{message:error.message,stack:error.stack});console.error(error.stack);process.exitCode=1});
save(`${dir}/opening.json`,checkOpen('docs/gates/G29/R4/plan.json'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
const r2dir=`${root}/evidence/G29/attempt-210`,r3dir=`${root}/evidence/G29/attempt-301`,r1dir=`${root}/evidence/G29/attempt-101`;
const r2final=read(`${r2dir}/final-r2.json`).native,priorCandidate=r2final[1][1],r2input=read(`${r2dir}/input.json`).native,design=r2input[1],designPart=r2input[2];
const r3failure=read(`${r3dir}/r3-failure-verdict.json`);assert.equal(r3failure.status,'FAIL-EVIDENCE');assert(r3failure.on_demand_load_crash_correlated);
const dependencies=[
 ['artifact-obligation','bridge','valid-dict-runtime'],['artifact-obligation','bridge','authorization-before-payload'],['artifact-obligation','bridge','stable-identity'],['artifact-obligation','bridge','idempotency'],
 ['artifact-obligation','tests','syntax'],['artifact-obligation','tests','valid-dict-runtime'],['artifact-obligation','tests','public-contract-exercise']
];
const ref=file=>['evidence-ref',file,`sha256-${hash(fs.readFileSync(`${r2dir}/${file}`))}`];
const observations=[
 ['obligation-observation','r2-bridge-dict','valid-dict-runtime','violated',ref('trial-r2.json')],
 ['obligation-observation','r2-tests-syntax','syntax','violated',ref('trial-r2.json')],
 ['obligation-observation','r2-tests-dict','valid-dict-runtime','violated',ref('trial-r2.json')],
 ['representation-example','swi-dict','Config = _{server_id:s1}, get_dict(server_id, Config, SID).'],
 ['representation-example','quoted-path',"Path = '/api/v4/posts'."]
];
const operations=[
 ['runtime-recovery-operation','nemotron-on-demand','nemotron-local','on-demand','reversible','defeated','exhausted','bounded'],
 ['runtime-recovery-operation','nemotron-explicit-load','nemotron-local','explicit-load-8192-full-gpu-no-mtp-ttl900','reversible','supported','available','bounded'],
 ['runtime-recovery-operation','remote-provider','remote-model','remote-api','reversible','unsupported','not-authorized','bounded'],
 ['runtime-recovery-operation','builder-hand-edit','builder','direct-source-edit','irreversible','unsupported','not-authorized','unbounded']
];
const input=['surface-runtime-repair-input',design,designPart,priorCandidate,dependencies,observations,operations,
 ['surface-repair-grant','G29-R4',2,2048,300,'nemotron-local','explicit-load-8192-full-gpu-no-mtp-ttl900','no-credentials'],
 ['repair-provenance','G29-R3','attempt-301','on-demand-startup-defeated']];
save(`${dir}/input.json`,{native:input});fs.copyFileSync(`${r3dir}/reference-lock.json`,`${dir}/reference-lock.json`);
const stateProcess=spawnSync('/Users/bcb/.lmstudio/bin/lms',['ps'],{encoding:'utf8'});assert.equal(stateProcess.status,0);const baseline=(stateProcess.stdout??'')+(stateProcess.stderr??'');assert(baseline.includes('No models are currently loaded'));save(`${dir}/model-state-before.txt`,baseline);
const sources=[
 'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','docs/gates/G29/R4/plan.json','docs/gates/G29/R4/plan.md','docs/gates/G29/R3/outcome.md',
 'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json','config/local/g03-model-profiles.json',
 'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','src/participation_support.metta','src/bootstrap_grounded_language.metta',
 'effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl',
 'scripts/g29/r4_prepare.mjs','scripts/g29/r4_run.mjs','scripts/g29/r4_quality.mjs','scripts/g29/r4_verify.mjs'
];
const retained=[`${r3dir}/r3-failure-verdict.json`,`${r3dir}/crash-metadata.json`,`${r3dir}/load-estimate-combined.txt`,`${r3dir}/model-state-after-combined.txt`,
 `${r2dir}/r2-failure-verdict.json`,`${r2dir}/trial-r2.json`,`${r2dir}/candidate/extension/mattermost_bridge.pl`,`${r2dir}/candidate/candidate_tests/mattermost_contract_tests.pl`,
 `${r1dir}/design-1-observation.json`,`${r1dir}/design-1-wire.json`,...read(`${dir}/reference-lock.json`).files.map(x=>x.path)];
save(`${dir}/manifest.json`,{schema:'miter-g29-freeze-v1',files:pins([...sources.map(x=>`${root}/${x}`),...retained,`${dir}/input.json`,`${dir}/reference-lock.json`,`${dir}/model-state-before.txt`]),
 plan:'docs/gates/G29/R4/plan.json',plan_commit:'b2619c67a3bec16a541e069036323b59903d2b24',recovery_selection:'native',max_new_calls:2,max_output_tokens_per_call:2048,deadline_seconds:300,capture_bytes:2097152,
 load:{model:'nemotron-3.5-30b-a3b-antislop-ftpo-i1',gpu:'max',context:8192,ttl:900,speculative_mtp:false},credentials:[],mattermost_network:false,prior_candidate:'mattermost-r2'});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(`${dir}/services-before.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert(!fs.existsSync(`${root}/runtime/g29/candidates/mattermost-r4`));for(const slot of [1,2])assert(!fs.existsSync(`${root}/evidence/G29/R4-call-${slot}.claim`));
const supported=operations[1],removed=operations.filter(x=>x[1]!==supported[1]),ambiguous=structuredClone(operations);ambiguous[0][5]='supported';ambiguous[0][6]='available';
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const rows=native(dir,'r4-native-preflight',
 `!(result recovery (SXSelectRecovery ${sexp(operations)}))\n`+
 `!(result recovery-reordered (SXSelectRecovery ${sexp([...operations].reverse())}))\n`+
 `!(result recovery-removed (SXSelectRecovery ${sexp(removed)}))\n`+
 `!(result recovery-ambiguous (SXSelectRecovery ${sexp(ambiguous)}))\n`+
 `!(result targets (SXRepairTargets ${sexp(dependencies)} ${sexp(observations)}))\n`+
 `!(let $input (sd_input "${dir}") (result bridge-file-valid (PShape (SXTargetFile (index-atom $input 3) bridge) surface-candidate-file 4)))\n`+
 `!(let $input (sd_input "${dir}") (result tests-file-valid (PShape (SXTargetFile (index-atom $input 3) tests) surface-candidate-file 4)))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));assert.equal(map.recovery[0],'runtime-recovery-selected');assert.equal(map.recovery[1],'nemotron-explicit-load');assert.equal(map.recovery[2],'nemotron-local');
assert.equal(map['recovery-reordered'][1],'nemotron-explicit-load');assert.equal(map['recovery-removed'][0],'runtime-recovery-unresolved');assert.deepEqual(map['recovery-removed'][1],[]);assert.equal(map['recovery-ambiguous'][0],'runtime-recovery-unresolved');assert.equal(map['recovery-ambiguous'][1].length,2);
assert.deepEqual(new Set(map.targets),new Set(['bridge','tests']));assert.equal(map['bridge-file-valid'],'true');assert.equal(map['tests-file-valid'],'true');
save(`${dir}/preflight-verdict.json`,{status:'PASS-BOUNDED',selected_recovery:'nemotron-explicit-load',selected_model:'nemotron-local',reordering_neutral:true,removal_holds:true,ambiguity_unresolved:true,native_targets:map.targets,new_model_calls:0});
save(`${dir}/prepared.json`,{status:'PREPARED',selected_recovery:'nemotron-explicit-load',selected_model:'nemotron-local',native_targets:map.targets,new_model_calls:0,baseline_model_state:'empty'});console.log(JSON.stringify(read(`${dir}/prepared.json`)));
