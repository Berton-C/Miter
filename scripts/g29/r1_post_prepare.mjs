// Freeze successful attempt-101 model bytes into a fresh no-model quality cut.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {save,read,pins} from '../g22_v2/common.mjs';
process.chdir(root);const tag=process.argv[2]??'103';assert.match(tag,/^10[2-9]$/);const origin=root+'/evidence/G29/attempt-101',dir=root+'/evidence/G29/attempt-'+tag;assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
save(dir+'/opening.json',checkOpen('docs/gates/G29/R1/plan.json'));
for(const n of ['input.json','reference-lock.json','design.json','final-r1.json','assessment-r1.json','design-1-observation.json','bridge-2-observation.json','tests-3-observation.json',
 'run-verdict.json','lineage.json','candidate-manifest.json','candidate-rationale.md','candidate-plan.md'])fs.copyFileSync(origin+'/'+n,dir+'/'+n);
fs.cpSync(origin+'/candidate',dir+'/candidate',{recursive:true});
const sources=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
 'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json',
 'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','src/participation_support.metta','src/bootstrap_grounded_language.metta',
 'effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl',
 'scripts/g29/r1_post_prepare.mjs','scripts/g29/r1_quality.mjs','scripts/g29/r1_verify.mjs','scripts/g29/r1_candidate_trial.mjs'];
const copied=fs.readdirSync(dir,{withFileTypes:true}).filter(x=>x.isFile()&&x.name!=='manifest.json').map(x=>dir+'/'+x.name);
const originRaw=['design-1-request.json','design-1-wire.json','design-1-timing.json','bridge-2-request.json','bridge-2-wire.json','bridge-2-timing.json','tests-3-request.json','tests-3-wire.json','tests-3-timing.json'].map(x=>origin+'/'+x);
const candidateFiles=[dir+'/candidate/extension/mattermost_bridge.pl',dir+'/candidate/candidate_tests/mattermost_contract_tests.pl'];
save(dir+'/manifest.json',{schema:'miter-g29-freeze-v1',files:pins([...sources.map(x=>root+'/'+x),...copied,...candidateFiles,...originRaw]),
 source_attempt:origin,new_model_calls:0,standing:'Fresh causal-quality cut over exact successful decomposed products'});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(dir+'/services-before.txt',execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert.equal(fs.readFileSync(origin+'/services-after.txt','utf8'),fs.readFileSync(dir+'/services-before.txt','utf8'));
save(dir+'/prepared.json',{status:'PREPARED',source_attempt:'attempt-101',candidate_files:candidateFiles.map(p=>({path:p,sha256:hash(fs.readFileSync(p))})),new_model_calls:0});
console.log(JSON.stringify(read(dir+'/prepared.json')));
