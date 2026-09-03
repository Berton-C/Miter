// Freeze and preflight the credential-isolated OpenRouter discriminator.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,petta,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'703';assert.match(tag,/^7[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{save(`${dir}/prepare-failure.json`,{message:error.message,stack:error.stack});console.error(error.stack);process.exitCode=1});
save(`${dir}/opening.json`,checkOpen('docs/gates/G29/R7/plan.json'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');

const r6dir=`${root}/evidence/G29/attempt-603`,r4dir=`${root}/evidence/G29/attempt-402`,r2dir=`${root}/evidence/G29/attempt-210`,r1dir=`${root}/evidence/G29/attempt-101`;
const r6input=read(`${r6dir}/input.json`).native,r2final=read(`${r2dir}/final-r2.json`).native;
const design=r6input[1],designPart=r6input[2],priorCandidate=r2final[1][1],dependencies=r6input[4],observations=r6input[5];
assert.equal(priorCandidate[2],'mattermost-r2');
const resources=[
 ['remote-model-resource','qwen-local','qwen/qwen3.8-27b','local-profile','prior-authorized','local-only','repeated-invalid-candidate','defeated','exhausted'],
 ['remote-model-resource','nemotron-local','nemotron-3.5-30b-a3b-antislop-ftpo-i1','local-profile','prior-authorized','local-only','startup-and-schema-crash','defeated','exhausted'],
 ['remote-model-resource','openrouter-glm53','z-ai/glm-5.3','openrouter-profile','operator-authorized','zdr-deny','failure-differentiating','supported','available']
];
const input=['surface-remote-repair-input',design,designPart,priorCandidate,dependencies,observations,resources,
 ['surface-remote-grant','G29-R7',3,'diagnostic-64','artifact-2048',300,'openrouter-glm53','no-live-mattermost','keychain-only'],
 ['repair-provenance','G29-R6','attempt-603','operator-authorized-remote-resource']];
save(`${dir}/input.json`,{native:input});fs.copyFileSync(`${r6dir}/reference-lock.json`,`${dir}/reference-lock.json`);

const stateProcess=spawnSync('/Users/bcb/.lmstudio/bin/lms',['ps'],{encoding:'utf8'});assert.equal(stateProcess.status,0);
const baseline=(stateProcess.stdout??'')+(stateProcess.stderr??'');assert(baseline.includes('No models are currently loaded'));save(`${dir}/model-state-before.txt`,baseline);
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(`${dir}/services-before.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert(!fs.existsSync(`${root}/runtime/g29/candidates/mattermost-r7`));for(const slot of [1,2,3])assert(!fs.existsSync(`${root}/evidence/G29/R7-call-${slot}.claim`));

const removed=resources.filter(x=>x[1]!=='openrouter-glm53'),ambiguous=[...resources,['remote-model-resource','openrouter-glm53-peer','z-ai/glm-5.3','openrouter-profile','operator-authorized','zdr-deny','failure-differentiating','supported','available']];
const exact='(openrouter-observation probe diagnostic eof 200 10 true stop provider-response 22 "MITER_OPENROUTER_READY" z-ai/glm-5.3 provider (usage 1 1 2 0))';
const mismatch='(openrouter-observation probe diagnostic eof 200 10 true stop provider-response 5 "READY" z-ai/glm-5.3 provider (usage 1 1 2 0))';
const part='(openrouter-observation probe bridge eof 200 10 true stop provider-response 45 "BEGIN_SOURCE\\n:- module(test, []).\\nEND_SOURCE" z-ai/glm-5.3 provider (usage 1 1 2 0))';
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const rows=native(dir,'r7-native-preflight',
 `!(result canonical (SXSelectRemoteResource ${sexp(resources)}))\n`+
 `!(result reordered (SXSelectRemoteResource ${sexp([...resources].reverse())}))\n`+
 `!(result removed (SXSelectRemoteResource ${sexp(removed)}))\n`+
 `!(result ambiguous (SXSelectRemoteResource ${sexp(ambiguous)}))\n`+
 `!(result exact (SXRemoteDiagnosticValid ${exact}))\n`+
 `!(result mismatch (SXRemoteDiagnosticValid ${mismatch}))\n`+
 `!(result part (SXRemotePartReady ${part} bridge))\n`+
 `!(result targets (SXRepairTargets ${sexp(dependencies)} ${sexp(observations)}))\n`+
 `!(result membrane (or_offline_audit))\n`+
 `!(result keychain (or_keychain_available))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.equal(map.canonical[0],'remote-model-resource-selected');assert.equal(map.canonical[1],'openrouter-glm53');assert.equal(map.canonical[2],'z-ai/glm-5.3');
assert.deepEqual(map.reordered,map.canonical);assert.equal(map.removed[0],'remote-model-resource-unresolved');assert.equal(map.removed[1].length,0);
assert.equal(map.ambiguous[0],'remote-model-resource-unresolved');assert.equal(map.ambiguous[1].length,2);
assert.equal(map.exact,'true');assert.equal(map.mismatch,'false');assert.equal(map.part,'true');assert.deepEqual(new Set(map.targets),new Set(['bridge','tests']));
assert.deepEqual(map.membrane,['openrouter-membrane-audit','true','true','true','true','true','true','true','true']);assert.equal(map.keychain,'true');
save(`${dir}/preflight-verdict.json`,{status:'PASS-BOUNDED',selected_resource:'openrouter-glm53',selected_model:'z-ai/glm-5.3',reordering_neutral:true,removal_holds:true,ambiguity_unresolved:true,exact_diagnostic_admitted:true,mismatch_rejected:true,exact_source_envelope_admitted:true,offline_membrane_negative_controls:8,keychain_available_without_disclosure:true,native_targets:map.targets,new_model_calls:0});

const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md','docs/gates/G29/R7/plan.json','docs/gates/G29/R7/plan.md','docs/gates/G29/R6/outcome.md','config/model-resources-v1.json','config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json','src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','src/participation_support.metta','src/bootstrap_grounded_language.metta','effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_openrouter.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl','scripts/g29/r7_prepare.mjs','scripts/g29/r7_run.mjs','scripts/g29/r7_quality.mjs','scripts/g29/r7_verify.mjs'];
const retained=[`${r6dir}/r6-failure-verdict.json`,`${r6dir}/final-r6.json`,`${r4dir}/r4-failure-verdict.json`,`${r4dir}/crash-metadata-r4.json`,`${r2dir}/r2-failure-verdict.json`,`${r2dir}/trial-r2.json`,`${r2dir}/candidate/extension/mattermost_bridge.pl`,`${r2dir}/candidate/candidate_tests/mattermost_contract_tests.pl`,`${r1dir}/design-1-observation.json`,`${r1dir}/design-1-wire.json`,...read(`${dir}/reference-lock.json`).files.map(x=>x.path)];
save(`${dir}/manifest.json`,{schema:'miter-g29-freeze-v1',files:pins([...sources.map(x=>`${root}/${x}`),...retained,`${dir}/input.json`,`${dir}/reference-lock.json`,`${dir}/model-state-before.txt`,`${dir}/services-before.txt`,`${dir}/preflight-verdict.json`]),plan:'docs/gates/G29/R7/plan.json',plan_commit:'e21d807e497e2610cf13b1f1495277b8ae450398',resource_selection:'native',model_registry:'config/model-resources-v1.json',endpoint:'https://openrouter.ai/api/v1/chat/completions',model:'z-ai/glm-5.3',reasoning_effort:'high',provider:{zdr:true,data_collection:'deny',require_parameters:true,allow_fallbacks:true},diagnostic:{max_calls:1,max_output_tokens:64,deadline_seconds:120,expected:'MITER_OPENROUTER_READY'},artifacts:{contingent_on_exact_diagnostic:true,max_calls:2,max_output_tokens:2048,deadline_seconds:300,capture_bytes:2097152,envelope:['BEGIN_SOURCE','END_SOURCE']},credential:{source:'macOS-Keychain',account:'bcb',service:'ai.bgi.miter.openrouter',serialized:false},local_model_load:false,mattermost_network:false,prior_candidate:'mattermost-r2'});
save(`${dir}/prepared.json`,{status:'PREPARED',selected_resource:'openrouter-glm53',selected_model:'z-ai/glm-5.3',native_targets:map.targets,new_model_calls:0,baseline_model_state:'empty',credential_visible:false});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
