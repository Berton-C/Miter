// G33 R8 diagnostic runner. It supplies disclosed source contact, isolation,
// process control and capture. It never invokes CStep/DOpportunity/DDevelop as
// the recurring transition and never writes a development opportunity or RNA.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';
import {cases as constructionCases,frame} from '../sc07/cases.mjs';
import {second,clauses} from '../sc06/cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R8/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);fs.mkdirSync(dir,{recursive:true});
const resources={model_calls:0,external_network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,human_emissions:0,external_effects:0};
process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL-RUNNER',message:error.message,
    stack:error.stack,...resources});console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R8/plan.json');
assert.equal(opening.plan_commit,'f841e665b7abadd4b241ba8b34c5b6ea8acf6fd2');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const fixture=read(`${root}/tests/fixtures/g33_r8/cases.json`);
const joined=constructionCases().find(row=>row.id==='joint-supported');
assert(joined,'joint-supported current source fixture unavailable');
const first=joined.c,secondContact=second(first),scope=first.scope;
const firstFrame=frame(first),secondFrame=frame(secondContact);
const surfaces=[['surface-capability','VoicePolicy','retention-omission',
  'miter-voice-realization-v2',['trial-expression'],[]]];
const grant=['development-grant',scope,1,1024,120];
save(`${dir}/source-contacts.json`,{schema:'miter-g33-r8-source-contacts-v1',
  predecessor:'evidence/G33/R7/attempt-003/runtime/phase-lineage.json',
  first_frame:firstFrame,second_frame:secondFrame,clauses,surfaces,grant,
  standing:'Disclosed fresh R8 contacts; native DObserve determines audit meaning.'});

const predecessor=`${root}/evidence/G33/R7/attempt-003/runtime`;
const runtime=`${dir}/runtime`;
fs.mkdirSync(runtime,{recursive:true});
fs.cpSync(`${predecessor}/store`,`${runtime}/store`,{recursive:true});
fs.cpSync(`${predecessor}/relational-voice`,`${runtime}/relational-voice`,{recursive:true});
fs.copyFileSync(`${predecessor}/phase-lineage.json`,`${runtime}/predecessor-phase-lineage.json`);
fs.copyFileSync(`${predecessor}/reactor-integrity.json`,`${runtime}/reactor-integrity.json`);
fs.mkdirSync(`${runtime}/inbox`,{recursive:true});fs.mkdirSync(`${runtime}/rna`,{recursive:true});
fs.copyFileSync(`${root}/derived/interest-proposals.json`,`${runtime}/interest-proposals.json`);
save(`${runtime}/source-context.json`,{voice_root:`${runtime}/relational-voice`});
save(`${runtime}/obligations.json`,{obligations:[]});

const canonicalA=`(DObserve ${fixture.canonical.first_id} ${fixture.canonical.source_kind} ${sexp(firstFrame)} ${sexp(clauses)})`;
const canonicalB=`(DObserve ${fixture.canonical.second_id} ${fixture.canonical.source_kind} ${sexp(secondFrame)} ${sexp(clauses)})`;
const sameB=`(DObserve ${fixture.same_family.second_id} ${fixture.canonical.source_kind} ${sexp(firstFrame)} ${sexp(clauses)})`;
const selfA=`(DObserve ${fixture.self_authored.first_id} ${fixture.self_authored.source_kind} ${sexp(firstFrame)} ${sexp(clauses)})`;
const selfB=`(DObserve ${fixture.self_authored.second_id} ${fixture.self_authored.source_kind} ${sexp(secondFrame)} ${sexp(clauses)})`;
const opportunity=records=>`(DOpportunity g33-r8-development ${sexp(scope)} ${records} ${sexp(surfaces)} ${sexp(grant)})`;
const program=`!(import! &self "${root}/src/bootstrap_modules.metta")\n`+
  `!(import! &self "${root}/src/bootstrap_development_cycle.metta")\n`+
  `!(let* (($a ${canonicalA}) ($b ${canonicalB}) `+
    `($op ${opportunity('($a $b)')}) ($rna (DDevelop $op)) `+
    `($ha (add-atom &history $a)) ($hb (add-atom &history $b))) `+
    `(case-result calibration (development-calibration $op $rna)))\n`+
  `!(let* (($a ${canonicalA}) ($b ${sameB})) `+
    `(case-result same-family ${opportunity('($a $b)')}))\n`+
  `!(let* (($a ${selfA}) ($b ${selfB})) `+
    `(case-result self-authored ${opportunity('($a $b)')}))\n`+
  `!(case-result registered-hooks `+
    `(collapse (match &rna_hooks $hook $hook)))\n`+
  `!(case-result admitted-current-audits `+
    `(collapse (match &history (audit-observation $id $s $kind $f $c $a) `+
      `(audit-observation $id $s $kind $f $c $a))))\n`+
  `!(ReactorStart "${runtime}" "${runtime}/reactor-integrity.json")\n`;
const metta=`${dir}/current-recurring-ingress.metta`;save(metta,program);

const child=spawn(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',metta,'silent'],
  {cwd:root,stdio:['ignore','pipe','pipe']});
let stdout='',stderr='';child.stdout.setEncoding('utf8');child.stderr.setEncoding('utf8');
child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);
const closed=new Promise(resolve=>child.on('close',(status,signal)=>resolve({status,signal})));
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
const trace=()=>fs.existsSync(`${runtime}/trace.jsonl`)?fs.readFileSync(`${runtime}/trace.jsonl`,'utf8')
  .split('\n').filter(Boolean).map(line=>JSON.parse(line)):[];
const end=Date.now()+20000;
while(Date.now()<end&&trace().filter(row=>row.kind==='idle-wait').length<fixture.runtime.minimum_idle_waits)
  await wait(20);
const idleReached=trace().filter(row=>row.kind==='idle-wait').length>=fixture.runtime.minimum_idle_waits;
save(`${runtime}/inbox/${fixture.runtime.stop_id}.json`,{schema:'miter-reactor-input-v1',
  id:fixture.runtime.stop_id,kind:'stop',provenance:'direct-contact',obligation:'none',steps:1,
  sent_at:new Date().toISOString()});
let processResult=await Promise.race([closed,wait(10000).then(()=>({timeout:true}))]);
if(processResult.timeout){child.kill('SIGTERM');processResult={...await closed,timeout:true};}
save(`${dir}/current-recurring-ingress.stdout`,stdout);save(`${dir}/current-recurring-ingress.stderr`,stderr);
save(`${dir}/current-recurring-ingress-process.json`,{...processResult,idle_reached:idleReached});

const results={};
for(const line of stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
  if(!line.startsWith('(case-result '))continue;const row=parse(line);results[row[1]]=row[2];
}
save(`${dir}/native-products.json`,results);
const rows=trace();save(`${dir}/reactor-trace.json`,rows);
const opportunityFiles=fs.existsSync(`${runtime}/interests`)?
  fs.readdirSync(`${runtime}/interests`,{recursive:true}).filter(x=>String(x).endsWith('opportunity.json')):[];
const rnaFiles=fs.readdirSync(`${runtime}/rna`).filter(x=>x.endsWith('.json'));
const head=x=>Array.isArray(x)?x[0]:null;
const calibration=results.calibration;
const calibrationPassed=head(calibration)==='development-calibration'&&
  head(calibration[1])===fixture.canonical.expected_opportunity_head&&
  head(calibration[2])===fixture.canonical.expected_rna_head&&
  head(results['same-family'])===fixture.same_family.expected_head&&
  head(results['self-authored'])===fixture.self_authored.expected_head;
const correctedHook=Array.isArray(results['registered-hooks'])&&
  results['registered-hooks'].some(h=>Array.isArray(h)&&
    (String(h).includes('CStep')||String(h).includes('DOpportunity')||String(h).includes('DDevelop')));
const recurringProduct=opportunityFiles.length>0&&rnaFiles.length>0;
const crossed=calibrationPassed&&correctedHook&&recurringProduct;
const observations={schema:'miter-g33-r8-observations-v1',
  predecessor_phase_lineage_sha256:hash(fs.readFileSync(`${runtime}/predecessor-phase-lineage.json`)),
  calibration:{passed:calibrationPassed,product:calibration},
  controls:{same_family:results['same-family'],self_authored:results['self-authored']},
  admitted_current_audits:results['admitted-current-audits'],
  registered_hooks:results['registered-hooks'],corrected_hook_present:correctedHook,
  recurring_products:{opportunity_files:opportunityFiles,rna_files:rnaFiles,present:recurringProduct},
  process:{...processResult,idle_reached:idleReached,stderr},
  trace_kinds:rows.map(row=>row.kind),...resources};
save(`${dir}/observations.json`,observations);

const sourceFiles=['docs/gates/G33/R8/plan.json','docs/gates/G33/R8/plan.md',
  'docs/gates/G33/R8/reassessment.md','tests/fixtures/g33_r8/cases.json',
  'scripts/g33_r8/run.mjs','scripts/g33_r8/verify.mjs','src/bootstrap_modules.metta',
  'src/bootstrap_interests.metta','src/interests.metta','effect_membranes/miter_interests.pl',
  'src/bootstrap_development_cycle.metta','src/development_cycle.metta',
  'src/development_evidence.metta','effect_membranes/miter_development_cycle.pl',
  'src/bootstrap_reactor.metta','src/reactor.metta','effect_membranes/miter_reactor.pl',
  'constitution/authority-manifest.json','derived/interest-proposals.json',
  'config/reactor-profile.json'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r8-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
const verdict={status:crossed?'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R8',
  current_contact_audits_have_native_developmental_bite:calibrationPassed,
  recurring_reactor_reaches_corrected_development_without_stage_command:crossed,
  developmental_undertaking_preserves_material_source_and_soul_relations:crossed,
  duplicate_and_self_authored_support_do_not_originate_development:calibrationPassed,
  first_discontinuity:calibrationPassed&&!correctedHook?
    'corrected-development-consumer-not-registered-with-recurring-reactor':
    calibrationPassed&&!recurringProduct?'corrected-development-observations-not-consumed':
    calibrationPassed?'none-observed':'current-native-development-calibration',
  stopped_at_first_discontinuity:!crossed,later_g33_phases_executed:false,...resources,
  limits:'A FAIL after passing native calibration identifies an integration boundary, not absent native developmental meaning.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));
if(!crossed)process.exitCode=1;
