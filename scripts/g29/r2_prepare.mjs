// Freeze G29 R2 controls and retained consequences before any model call.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,petta,sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'210';assert.match(tag,/^2[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/prepare-failure.json`,{message:error.message,stack:error.stack});
  console.error(error.stack);
  process.exitCode=1;
});
save(`${dir}/opening.json`,checkOpen('docs/gates/G29/R2/plan.json'));
assert.equal(execFileSync('/usr/bin/git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');

const priorDir=`${root}/evidence/G29/attempt-107`;
const sourceDir=`${root}/evidence/G29/attempt-101`;
const priorFinal=read(`${sourceDir}/final-r1.json`).native;
const design=priorFinal[1];
const priorCandidate=priorFinal[2][1];
const designPart=read(`${sourceDir}/design-1-observation.json`).native;
const priorTrial=read(`${priorDir}/candidate-trial.json`);
assert.equal(priorTrial.status,'FAIL-EVIDENCE');
assert(priorTrial.bridge_syntax_error&&priorTrial.bridge_export_missing&&priorTrial.tests_invalid_plunit_form&&priorTrial.tests_clause_body_errors);

const dependencies=[
  ['artifact-obligation','bridge','syntax'],
  ['artifact-obligation','bridge','public-export'],
  ['artifact-obligation','bridge','authorization-before-payload'],
  ['artifact-obligation','bridge','stable-identity'],
  ['artifact-obligation','bridge','idempotency'],
  ['artifact-obligation','tests','plunit-structure'],
  ['artifact-obligation','tests','public-contract-exercise'],
  ['artifact-obligation','tests','adversarial-cases']
];
const ref=(file)=>['evidence-ref',file,`sha256-${hash(fs.readFileSync(`${priorDir}/${file}`))}`];
const observations=[
  ['obligation-observation','r1-bridge-syntax','syntax','violated',ref('candidate-trial.stderr')],
  ['obligation-observation','r1-bridge-export','public-export','violated',ref('candidate-trial.stderr')],
  ['obligation-observation','r1-tests-plunit','plunit-structure','violated',ref('candidate-trial.stderr')],
  ['obligation-observation','r1-tests-clauses','public-contract-exercise','violated',ref('candidate-trial.stderr')],
  ['obligation-observation','r1-boundary-scan','authorization-before-payload','unresolved',ref('candidate-trial.json')]
];
const input=['surface-repair-input',design,designPart,priorCandidate,dependencies,observations,
  ['surface-repair-grant','G29-R2',2,2048,300,'qwen-local','no-network','no-credentials'],
  ['repair-provenance','G29-R1','attempt-107','retained-exact-candidate']];
save(`${dir}/input.json`,{native:input});
fs.copyFileSync(`${sourceDir}/reference-lock.json`,`${dir}/reference-lock.json`);

const sources=[
  'CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','ACCEPTANCE.md',
  'docs/gates/G29/R2/plan.json','docs/gates/G29/R2/plan.md','docs/gates/G29/R1/outcome.md',
  'config/surface-event-v1.json','config/surface-effect-v1.json','config/mattermost-design-candidate-v1.json','config/mattermost-design-part-v1.json','config/mattermost-code-part-v1.json','config/local/g03-model-profiles.json',
  'src/surface_design_v1.metta','src/bootstrap_surface_design_v1.metta','src/surface_extension_v1.metta','src/bootstrap_surface_extension_v1.metta','src/participation_support.metta','src/bootstrap_grounded_language.metta',
  'effect_membranes/miter_surface_design_v1.pl','effect_membranes/miter_surface_extension_v1.pl','effect_membranes/miter_model_stream_v1.pl','effect_membranes/miter_llm.pl','effect_membranes/miter_store.pl','effect_membranes/miter_process.pl',
  'scripts/g29/r2_prepare.mjs','scripts/g29/r2_run.mjs','scripts/g29/r2_quality.mjs','scripts/g29/r2_verify.mjs'
];
const retained=[
  `${priorDir}/candidate-trial.json`,`${priorDir}/candidate-trial.stderr`,
  `${priorDir}/candidate/extension/mattermost_bridge.pl`,`${priorDir}/candidate/candidate_tests/mattermost_contract_tests.pl`,
  `${sourceDir}/design-1-observation.json`,`${sourceDir}/design-1-wire.json`,`${sourceDir}/final-r1.json`,
  ...read(`${dir}/reference-lock.json`).files.map(x=>x.path)
];
save(`${dir}/manifest.json`,{
  schema:'miter-g29-freeze-v1',
  files:pins([...sources.map(x=>`${root}/${x}`),...retained,`${dir}/input.json`,`${dir}/reference-lock.json`]),
  plan:'docs/gates/G29/R2/plan.json',plan_commit:'4ec12ec021f3544671501b1bb74d5621f6cc1cd1',
  model_alias:'qwen-local',max_new_calls:2,max_output_tokens_per_call:2048,deadline_seconds:300,capture_bytes:2097152,
  repair_targets:['bridge','tests'],credentials:[],mattermost_network:false,prior_candidate:'mattermost-r1'
});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';
save(`${dir}/services-before.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert(!fs.existsSync(`${root}/runtime/g29/candidates/mattermost-r2`));
for(const slot of [1,2])assert(!fs.existsSync(`${root}/evidence/G29/R2-call-${slot}.claim`));

const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const bridgeObs=observations.filter(x=>['syntax','public-export'].includes(x[2]));
const testsObs=observations.filter(x=>['plunit-structure','public-contract-exercise'].includes(x[2]));
const unknown=[['obligation-observation','unknown','unrelated-obligation','unresolved','no-contact']];
const severed=dependencies.filter(x=>x[1]!=='tests');
const rows=native(dir,'repair-target-preflight',
  `!(result canonical (SXRepairTargets ${sexp(dependencies)} ${sexp(observations)}))\n`+
  `!(result reordered (SXRepairTargets ${sexp([...dependencies].reverse())} ${sexp([...observations].reverse())}))\n`+
  `!(result bridge-only (SXRepairTargets ${sexp(dependencies)} ${sexp(bridgeObs)}))\n`+
  `!(result tests-only (SXRepairTargets ${sexp(dependencies)} ${sexp(testsObs)}))\n`+
  `!(result unknown (SXRepairTargets ${sexp(dependencies)} ${sexp(unknown)}))\n`+
  `!(result severed (SXRepairTargets ${sexp(severed)} ${sexp(observations)}))\n`+
  `!(result ready (SXRepairReady (SXRepairTargets ${sexp(dependencies)} ${sexp(observations)})))\n`+
  `!(let $input (sd_input "${dir}") (result first-path (index-atom (index-atom (index-atom (index-atom $input 3) 6) 0) 1)))\n`+
  `!(result target-path (SXTargetPath bridge))\n`+
  `!(let $input (sd_input "${dir}") (result path-equality (== (index-atom (index-atom (index-atom (index-atom $input 3) 6) 0) 1) (SXTargetPath bridge))))\n`+
  `!(let $input (sd_input "${dir}") (result bridge-file-valid (PShape (SXTargetFile (index-atom $input 3) bridge) surface-candidate-file 4)))\n`+
  `!(let $input (sd_input "${dir}") (result tests-file-valid (PShape (SXTargetFile (index-atom $input 3) tests) surface-candidate-file 4)))\n`+
  `!(result repair-name (sx_repair_name bridge 1))`,boot);
const byName=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.deepEqual(new Set(byName.canonical),new Set(['bridge','tests']));
assert.deepEqual(new Set(byName.reordered),new Set(['bridge','tests']));
assert.deepEqual(byName['bridge-only'],['bridge']);
assert.deepEqual(byName['tests-only'],['tests']);
assert.deepEqual(byName.unknown,[]);
assert.deepEqual(byName.severed,['bridge']);
assert.equal(byName.ready,'true');
assert(byName['first-path']);
assert(byName['target-path']);
assert.equal(byName['path-equality'],'true');
assert.equal(byName['bridge-file-valid'],'true');
assert.equal(byName['tests-file-valid'],'true');
assert.equal(byName['repair-name'],'repair-bridge-1');
save(`${dir}/target-preflight-verdict.json`,{status:'PASS-BOUNDED',canonical:byName.canonical,reordering_neutral:true,
  bridge_evidence_selects_bridge:true,tests_evidence_selects_tests:true,unknown_not_violation:true,severed_dependency_defeats_tests_target:true});
save(`${dir}/prepared.json`,{status:'PREPARED',native_targets:byName.canonical,new_model_calls:0,prior_failure_retained:true,services_unchanged:true});
console.log(JSON.stringify(read(`${dir}/prepared.json`)));
