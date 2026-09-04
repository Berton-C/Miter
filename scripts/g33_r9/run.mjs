// R9 R1 offline native bootstrap qualification. No model or external effect.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';
import {cases as constructionCases,frame} from '../sc07/cases.mjs';
import {second,clauses} from '../sc06/cases.mjs';
import {sourceFrame,reorderedFrame} from '../g33_r5/cases.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R9/attempt-${tag}`,dir=`${root}/${rel}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
const resources={model_calls:0,external_network_requests:0,credential_lookups:0,
  chroma_mutations:0,mattermost_operations:0,human_emissions:0,external_effects:0};
const opening=checkOpen('docs/gates/G33/R9/R1/plan.json');
assert.equal(opening.plan_commit,'bdb6823675748ba7e6d8bc2d181ce35b8b741748');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');
const fixture=read(`${root}/tests/fixtures/g33_r9/cases.json`);

function native(name,program){
  const path=`${dir}/${name}.metta`;save(path,program);const started=Date.now();
  const run=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',path,'silent'],
    {cwd:root,encoding:'utf8',timeout:90000,maxBuffer:256*1024*1024});
  save(`${dir}/${name}.stdout`,run.stdout??'');save(`${dir}/${name}.stderr`,run.stderr??'');
  save(`${dir}/${name}-process.json`,{status:run.status,signal:run.signal,
    error:run.error?.message,elapsed_ms:Date.now()-started});
  const products={};
  for(const line of (run.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')){
    if(!line.startsWith('(case-result '))continue;const row=parse(line);products[row[1]]=row[2];
  }
  save(`${dir}/${name}-products.json`,products);return {run,products};
}

const joined=constructionCases().find(row=>row.id==='joint-supported');assert(joined);
const first=joined.c,other=second(first),scope=first.scope;
const firstFrame=frame(first),secondFrame=frame(other);
const surfaces=[['surface-capability','VoicePolicy','retention-omission',
  'miter-voice-realization-v2',['trial-expression'],[]]];
const grant=['development-grant',scope,1,1024,120];
const observe=(id,kind,f)=>`(DObserve ${id} ${kind} ${sexp(f)} ${sexp(clauses)})`;
const opportunity=(records,s=surfaces,g=grant)=>
  `(DOpportunity g33-r9-development ${sexp(scope)} ${records} ${sexp(s)} ${sexp(g)})`;
const casesBody=`!(let* (($a ${observe('r9-a','independent-native-audit',firstFrame)}) `+
  `($b ${observe('r9-b','independent-native-audit',secondFrame)})) `+
  `(case-result canonical ${opportunity('($a $b)')}))\n`+
  `!(let* (($a ${observe('r9-a','independent-native-audit',firstFrame)}) `+
  `($b ${observe('r9-b','independent-native-audit',secondFrame)})) `+
  `(case-result neutral ${opportunity('($b $a)')}))\n`+
  `!(let* (($a ${observe('r9-a','independent-native-audit',firstFrame)}) `+
  `($b ${observe('r9-same','independent-native-audit',firstFrame)})) `+
  `(case-result same-family ${opportunity('($a $b)')}))\n`+
  `!(let* (($a ${observe('r9-self-a','self-trace',firstFrame)}) `+
  `($b ${observe('r9-self-b','self-trace',secondFrame)})) `+
  `(case-result self-authored ${opportunity('($a $b)')}))\n`+
  `!(let* (($a ${observe('r9-a','independent-native-audit',firstFrame)}) `+
  `($b ${observe('r9-b','independent-native-audit',secondFrame)})) `+
  `(case-result missing-capability ${opportunity('($a $b)',[])}))\n`+
  `!(let* (($a ${observe('r9-a','independent-native-audit',firstFrame)}) `+
  `($b ${observe('r9-b','independent-native-audit',secondFrame)})) `+
  `(case-result exhausted-grant ${opportunity('($a $b)',surfaces,['development-grant',scope,0,1024,120])}))\n`;
const boots={
  'relational-voice':`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`,
  'voice-construction':`!(import! &self "${root}/src/bootstrap_voice_construction.metta")\n`,
  'development-cycle':`!(import! &self "${root}/src/bootstrap_development_cycle.metta")\n`,
  'minimal-reference':`!(import! &self "${root}/src/bootstrap_grounded_language.metta")\n`+
    `!(import! &self "${root}/src/relational_voice.metta")\n`+
    `!(import! &self "${root}/src/development_evidence.metta")\n`
};
const runs={};for(const name of fixture.bootstrap_variants)runs[name]=native(name,boots[name]+casesBody);

const voiceFixture=read(`${root}/tests/fixtures/g33_r7/cases.json`),voiceFrame=sourceFrame();
for(const name of ['canonical','missing-frame','neutral','restored'])
  fs.mkdirSync(`${dir}/voice/${name}`,{recursive:true});
const intention=f=>`(RIntend ${voiceFixture.voice.request_id} (DGround ${sexp(f)}))`;
const state=(f=voiceFrame)=>`(rendered ${voiceFixture.voice.request_id} ${sexp(f[1])} `+
  `${sexp(voiceFixture.voice.returned_clauses)} "g33-r9-disclosed-returned-state")`;
const returned=(name,f=voiceFrame,source=sexp(f))=>
  `(RWaitReturned ${JSON.stringify(`${dir}/voice/${name}`)} ${intention(f)} ${source} ${state(f)})`;
const neutralFrame=reorderedFrame();
const voice=native('voice-consumer',boots['relational-voice']+
  `!(case-result canonical ${returned('canonical')})\n`+
  `!(case-result missing-frame ${returned('missing-frame',voiceFrame,'source-frame-unavailable')})\n`+
  `!(case-result neutral ${returned('neutral',neutralFrame)})\n`+
  `!(case-result restored ${returned('restored')})\n`);

const head=x=>Array.isArray(x)?x[0]:null;
const disposition=x=>head(x)==='voice-result'?x[2]:x;
const ordered=x=>[...x].sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
const opportunityProjection=x=>head(x)==='development-opportunity'?{
  kind:x[0],scope:x[2],target:x[3],soul_ground:['soul-ground',ordered(x[4][1])],
  source_events:['source-events',ordered(x[5][1])],
  repeated_relations:ordered(x[6][1].map(row=>[row[0],row[1],
    ordered([row[2][1],row[3][1]]),ordered([row[2][3],row[3][3]])])),
  continuation:x.slice(7)
}:x;
// Evidence-list ordering is not semantic. Preserve the expression, joint basis,
// accepted capability, faithful disposition, and no-emission boundary.
const certificateProjection=x=>head(x)==='expression-certificate-v1'?{
  kind:x[0],scope:x[1],accepted_capability:x[6],
  selected_expression:[x[8][0],x[8][1][0],x[8][1][1],x[8][1][2],x[8][1][4]],
  fresh_disposition:x[9][1][3],authority:x[10]
}:x;
const canonical=opportunityProjection(runs['minimal-reference'].products.canonical);
const bootstrapPassed=fixture.bootstrap_variants.every(name=>{
  const r=runs[name],p=r.products;
  return r.run.status===0&&r.run.stderr===''&&head(p.canonical)===fixture.expected.canonical&&
    JSON.stringify(opportunityProjection(p.canonical))===JSON.stringify(canonical)&&
    JSON.stringify(opportunityProjection(p.neutral))===JSON.stringify(canonical)&&
    head(p['same-family'])===fixture.expected.same_family&&
    head(p['self-authored'])===fixture.expected.self_authored&&
    head(p['missing-capability'])===fixture.expected.missing_capability&&
    head(p['exhausted-grant'])===fixture.expected.exhausted_grant;
});
const voicePassed=voice.run.status===0&&voice.run.stderr===''&&
  head(disposition(voice.products.canonical))===fixture.expected.voice_canonical&&
  disposition(voice.products.canonical).at(-1)==='no-emission-authority'&&
  JSON.stringify(certificateProjection(disposition(voice.products.neutral)))===
    JSON.stringify(certificateProjection(disposition(voice.products.canonical)))&&
  head(disposition(voice.products['missing-frame']))===fixture.expected.voice_missing_frame&&
  JSON.stringify(disposition(voice.products.restored))===JSON.stringify(disposition(voice.products.canonical));
const sourceText=fs.readFileSync(`${root}/effect_membranes/miter_voice_construction.pl`,'utf8');
const mechanicalPassed=!sourceText.includes("ensure_loaded('miter_relational_voice.pl')")&&
  !/^vc_(word|budget|sentence)\(/m.test(sourceText)&&
  runs['development-cycle'].run.stderr===''&&voice.run.stderr==='';

const observations={schema:'miter-g33-r9-observations-v1',bootstrap_passed:bootstrapPassed,
  voice_passed:voicePassed,mechanical_collision_absent:mechanicalPassed,
  variant_heads:Object.fromEntries(Object.entries(runs).map(([name,r])=>[name,
    Object.fromEntries(Object.entries(r.products).map(([id,p])=>[id,head(p)]))])),
  stderr_bytes:Object.fromEntries([...Object.entries(runs),['voice-consumer',voice]].map(([name,r])=>
    [name,Buffer.byteLength(r.run.stderr??'')])),...resources};
save(`${dir}/observations.json`,observations);
const sourceFiles=['docs/gates/G33/R9/R1/plan.json','docs/gates/G33/R9/R1/plan-correction.md',
  'tests/fixtures/g33_r9/cases.json','scripts/g33_r9/run.mjs','scripts/g33_r9/verify.mjs',
  'src/bootstrap_relational_voice.metta','src/bootstrap_voice_construction.metta',
  'src/bootstrap_development_cycle.metta','effect_membranes/miter_voice_construction.pl',
  'effect_membranes/miter_relational_voice_v2.pl','effect_membranes/miter_relational_voice_repair_v1.pl',
  'src/relational_voice.metta','src/development_evidence.metta','src/voice_construction.metta',
  'src/relational_voice_repair_v1.metta'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r9-freeze-v1',
  git_head:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  plan_commit:opening.plan_commit,petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...resources});
const passed=bootstrapPassed&&voicePassed&&mechanicalPassed;
const verdict={status:passed?'PASS-BOUNDED':'FAIL',gate:'G33',revision:'R9-R1',
  public_bootstraps_preserve_current_source_grounded_development_meaning:bootstrapPassed,
  causal_development_controls_remain_distinct:bootstrapPassed,
  current_relational_voice_repair_consumer_remains_intact:voicePassed,
  construction_mechanics_load_without_legacy_v2_collision:mechanicalPassed,
  first_discontinuity:bootstrapPassed?(voicePassed?(mechanicalPassed?'none-observed':'mechanical-collision'):
    'current-relational-voice-repair-consumer'):'public-native-bootstrap',...resources,
  limits:'Bootstrap and existing consumer qualification only; corrected development is not yet connected to the recurring reactor.'};
save(`${dir}/verdict.json`,verdict);console.log(JSON.stringify(verdict));if(!passed)process.exitCode=1;
