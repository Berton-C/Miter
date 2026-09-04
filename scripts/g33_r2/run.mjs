// G33 R2 source-grounded continuity repair experiment.
// JavaScript owns isolated fixtures and byte capture only; native MeTTa owns
// semantic admission, scoped project grounding, and exact continuity use.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,pins,swi,petta} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';
assert.match(tag,/^\d{3}$/);
const rel=`evidence/G33/R2/attempt-${tag}`;
const dir=`${root}/${rel}`;
assert(!fs.existsSync(dir),`${rel} already exists`);
fs.mkdirSync(dir,{recursive:true});

const counters={localhost_model_calls:0,external_network_requests:0,credential_lookups:0,
  external_effects:0,chroma_mutations:0,mattermost_operations:0};
process.on('uncaughtException',error=>{
  save(`${dir}/runner-failure.json`,{status:'FAIL',message:error.message,stack:error.stack,...counters});
  console.error(error.stack);process.exitCode=1;
});

const opening=checkOpen('docs/gates/G33/R2/plan.json');
assert.equal(opening.plan_commit,'aba224974d74ca86a6144a524b2170db0ac2e6c9');
save(`${dir}/opening.json`,opening);
assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),
  'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');
assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');

const cases=read(`${root}/tests/fixtures/g33_r2/cases.json`);
const source=`${root}/evidence/20260902T063347Z-G11`;
const modelConfig=`${root}/config/local/g03-model-profiles.json`;
const sha=text=>crypto.createHash('sha256').update(text,'utf8').digest('hex');

const bootstrap=`!(import! &self "${root}/src/bootstrap_continuity_intent_v1.metta")\n`;
const parseBootstrap=`!(import! &self (library lib_import))\n`+
  `!(import_prolog_functions_from_file "${root}/effect_membranes/miter_continuity_intent_v1.pl" `+
  `(miter_continuity_reading_parse))\n`;

function runNative(runDir,name,body,boot=bootstrap,timeout=150000){
  save(`${runDir}/${name}.metta`,boot+body+'\n');
  const started=Date.now();
  const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',
    `${runDir}/${name}.metta`,'silent'],{cwd:root,encoding:'utf8',timeout,maxBuffer:128*1024*1024});
  save(`${runDir}/${name}.stdout`,p.stdout??'');save(`${runDir}/${name}.stderr`,p.stderr??'');
  save(`${runDir}/${name}-process.json`,{status:p.status,signal:p.signal,error:p.error?.message,
    elapsed_ms:Date.now()-started});
  assert.equal(p.status,0,`${name} status`);assert.equal(p.stderr,'',`${name} stderr`);
  const lines=(p.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n')
    .filter(line=>line.startsWith('(result '));
  assert(lines.length>0,`${name} native product`);
  return Object.fromEntries(lines.map(line=>{
    const match=line.match(/^\(result ([^ ]+) (.*)\)$/);assert(match,line);return [match[1],match[2]];
  }));
}

function copyRuntime(runDir,text,requestId,registryOverride=null){
  const runtime=`${runDir}/runtime`,store=`${runtime}/store`,capsules=`${runtime}/capsules`,
    output=`${runtime}/outputs`;
  fs.mkdirSync(store,{recursive:true});fs.mkdirSync(output,{recursive:true});
  for(const name of ['memories','memory-bodies','objects']){
    const from=`${source}/canonical/store/${name}`;
    if(fs.existsSync(from))fs.cpSync(from,`${store}/${name}`,{recursive:true});
  }
  fs.copyFileSync(`${source}/base-trajectory.jsonl`,`${store}/trajectory.jsonl`);
  fs.writeFileSync(`${store}/trajectory.lock`,'');
  fs.cpSync(`${source}/capsules`,capsules,{recursive:true});
  const registry=registryOverride??read(`${source}/outputs/project-registry.json`);
  save(`${runtime}/project-registry.json`,registry);
  const context={schema:'miter-resume-context-v1',text,request_id:requestId,query_tag:requestId,
    occurred_at:'2026-12-01T07:00:00Z',chat_context:[],
    principal_scope:cases.source_scope.principal_scope,
    audience_scope:cases.source_scope.audience_scope,
    registry_ref:`${runtime}/project-registry.json`,
    registry_sha256:hash(fs.readFileSync(`${runtime}/project-registry.json`)),
    memory_store:store,capsule_store:capsules,output_dir:output,
    capsule_output:`${output}/capsule.json`,model_config:modelConfig};
  save(`${runtime}/context.json`,context);
  return {runtime,store,capsules,output,contextPath:`${runtime}/context.json`,context};
}

const modelObservations=[];
for(const row of cases.model_cases){
  const runDir=`${dir}/model-${row.id}`;fs.mkdirSync(runDir,{recursive:true});
  const rt=copyRuntime(runDir,row.text,`g33-r2-${tag}-${row.id}`);
  let products;
  try {
    products=runNative(runDir,'continuity',
      `!(result continuity (ContinuityRNA "${rt.contextPath}" ${row.mode}))`);
  } finally {
    if(fs.existsSync(`${rt.output}/continuity-reading-timing.json`))
      counters.localhost_model_calls++;
  }
  const typed=read(`${rt.output}/continuity-reading-typed.json`);
  const answer=read(`${rt.output}/answer.json`);
  const timing=read(`${rt.output}/continuity-reading-timing.json`);
  assert.equal(timing.timeout_seconds,120);assert.equal(timing.http_status,200);
  assert.equal(products.continuity,'continuity-answer-stored');
  assert.equal(typed.standing,'generated-source-verified-candidate');
  assert.equal(typed.source_sha256,sha(row.text));
  assert(!Object.keys(typed).some(key=>read(`${root}/config/continuity-reading-schema-v1.json`)
    .forbidden_model_fields.includes(key)));
  for(const claim of typed.claims)for(const span of claim.evidence_spans)assert(row.text.includes(span));
  assert.equal(typed.claims.filter(c=>c.relation==='project-kind'&&c.value===row.required_kind).length,1);
  for(const facet of row.required_facets)
    assert(typed.claims.some(c=>c.relation==='continuity-facet'&&c.value===facet),`${row.id} ${facet}`);
  assert.equal(answer.certificate,'exact-continuity');
  assert.equal(answer.authority,'native-capsule-and-trajectory-certificate');
  assert.equal(answer.question,row.text);
  modelObservations.push({id:row.id,standing:row.standing,mode:row.mode,
    native_product:products.continuity,typed,answer,timing,raw_sha256:hash(fs.readFileSync(
      `${rt.output}/continuity-reading-raw.json`))});
}
assert.equal(counters.localhost_model_calls,2);
assert.deepEqual(modelObservations[0].answer.exact_state,modelObservations[1].answer.exact_state);

function providerEnvelope(product){
  return {choices:[{finish_reason:'stop',message:{content:typeof product==='string'?product:JSON.stringify(product)}}]};
}
function baseProduct(text,requestId){
  return {request_id:`${requestId}-continuity-reading`,source_sha256:sha(text),
    claims:[
      {relation:'project-kind',value:'book',evidence_spans:['book']},
      {relation:'continuity-facet',value:'current-position',evidence_spans:['where we paused']}],
    alternatives:[],uncertainty:'The source directly names a book and asks for the paused position.',
    completion_status:'complete'};
}
function parseAdversary(id,mutate,expected){
  const runDir=`${dir}/parse-${id}`;fs.mkdirSync(runDir,{recursive:true});
  const text=cases.model_cases[0].text,requestId=`g33-r2-${tag}-parse-${id}`;
  const rt=copyRuntime(runDir,text,requestId);
  const product=mutate(baseProduct(text,requestId));
  save(`${rt.output}/continuity-reading-raw.json`,providerEnvelope(product));
  const products=runNative(runDir,'parse',
    `!(result parse (miter_continuity_reading_parse "${rt.contextPath}"))`,parseBootstrap);
  assert.equal(products.parse,expected);return {id,product,observed:products.parse};
}
const parseAdversaries=[
  parseAdversary('wrong-request-id',p=>({...p,request_id:'wrong'}),'continuity-reading-request-mismatch'),
  parseAdversary('wrong-source-hash',p=>({...p,source_sha256:'0'.repeat(64)}),'continuity-reading-source-mismatch'),
  parseAdversary('fabricated-span',p=>({...p,claims:[...p.claims.slice(0,1),
    {...p.claims[1],evidence_spans:['words absent from source']}]}),'continuity-reading-span-mismatch'),
  parseAdversary('kind-not-named',p=>({...p,claims:[
    {...p.claims[0],value:'codebase'},...p.claims.slice(1)]}),
    'continuity-reading-kind-not-named'),
  parseAdversary('forbidden-extra-field',p=>({...p,project_id:'model-chosen-project'}),'continuity-reading-malformed'),
  parseAdversary('malformed-json',_=>'{not-json','continuity-reading-malformed')
];

function typedCandidate(text,requestId,claims,completion='complete'){
  return {schema:'miter-continuity-reading-v1',standing:'generated-source-verified-candidate',
    request_id:`${requestId}-continuity-reading`,source_sha256:sha(text),claims,alternatives:[],
    uncertainty:'Synthetic adversarial typed candidate for native discrimination.',
    completion_status:completion};
}
function nativeDecision(id,claims,expected,completion='complete'){
  const runDir=`${dir}/native-${id}`;fs.mkdirSync(runDir,{recursive:true});
  const text=cases.model_cases[0].text,requestId=`g33-r2-${tag}-native-${id}`;
  const rt=copyRuntime(runDir,text,requestId);
  save(`${rt.output}/continuity-reading-typed.json`,typedCandidate(text,requestId,claims,completion));
  const products=runNative(runDir,'decision',
    `!(result decision (ContinuityReadingDecision "${rt.contextPath}"))`);
  assert.equal(products.decision,expected);return {id,observed:products.decision};
}
const kind={relation:'project-kind',value:'book',evidence_spans:['book']};
const position={relation:'continuity-facet',value:'current-position',evidence_spans:['where we paused']};
const nativeAdversaries=[
  nativeDecision('no-facet',[kind],'continuity-reading-facets-unsupported'),
  nativeDecision('unknown-facet',[kind,{...position,value:'requested-summary'}],
    'continuity-reading-facets-unsupported'),
  nativeDecision('unsupported-relation',[kind,position,
    {relation:'authority',value:'granted',evidence_spans:['book']}],
    'continuity-reading-contains-unsupported-relation'),
  nativeDecision('duplicate-kind',[kind,{...kind},position],
    'continuity-reading-project-kind-not-unique'),
  nativeDecision('insufficient',[],'continuity-reading-insufficient','insufficient_evidence')
];

function groundingCase(id,registry,mode,expected,{severTrajectory=false}={}){
  const runDir=`${dir}/ground-${id}`;fs.mkdirSync(runDir,{recursive:true});
  const text=cases.model_cases[0].text,requestId=`g33-r2-${tag}-ground-${id}`;
  const rt=copyRuntime(runDir,text,requestId,registry);
  save(`${rt.output}/continuity-reading-typed.json`,typedCandidate(text,requestId,[kind,position]));
  if(severTrajectory){
    const rows=fs.readFileSync(`${rt.store}/trajectory.jsonl`,'utf8').trimEnd().split('\n');
    const severed=rows.filter(line=>JSON.parse(line).event_id!=='source-g11-book-pause');
    assert.equal(severed.length,rows.length-1);
    fs.writeFileSync(`${rt.store}/trajectory.jsonl`,severed.join('\n')+'\n');
  }
  const products=runNative(runDir,'ground',
    `!(result ground (ContinuityFromReading "${rt.contextPath}" ${mode} `+
    `(ContinuityReadingDecision "${rt.contextPath}")))`);
  assert.equal(products.ground,expected);
  const answer=fs.existsSync(`${rt.output}/answer.json`)?read(`${rt.output}/answer.json`):null;
  return {id,mode,observed:products.ground,certificate:answer?.certificate??null,
    answer_written:answer!==null};
}
const oneRegistry=read(`${source}/outputs/project-registry.json`);
const zeroRegistry={...oneRegistry,projects:[]};
const twoRegistry={...oneRegistry,projects:[...oneRegistry.projects,
  {...oneRegistry.projects[0],project_id:'project-g08-second-book'}]};
const grounding=[
  groundingCase('zero-project',zeroRegistry,'chroma-off','continuity-project-unavailable'),
  groundingCase('ambiguous-project',twoRegistry,'chroma-off','continuity-project-ambiguous'),
  groundingCase('capsule-severed',oneRegistry,'capsule-off','continuity-answer-stored'),
  groundingCase('trajectory-severed',oneRegistry,'chroma-off','continuity-answer-stored',{severTrajectory:true}),
  groundingCase('restored',oneRegistry,'chroma-off','continuity-answer-stored')
];
assert.equal(grounding.find(x=>x.id==='capsule-severed').certificate,'non-authoritative-recall');
assert.equal(grounding.find(x=>x.id==='trajectory-severed').certificate,'non-authoritative-recall');
assert.equal(grounding.find(x=>x.id==='restored').certificate,'exact-continuity');

const providerRun=`${dir}/provider-off`;fs.mkdirSync(providerRun,{recursive:true});
const providerRt=copyRuntime(providerRun,cases.model_cases[0].text,
  `g33-r2-${tag}-provider-off`);
const providerProducts=runNative(providerRun,'provider-off',
  `!(result provider (ContinuityRNA "${providerRt.contextPath}" provider-off))`);
assert.equal(providerProducts.provider,'continuity-reading-provider-unavailable');

const observations={schema:'miter-g33-r2-observations-v1',modelObservations,
  parseAdversaries,nativeAdversaries,grounding,
  provider_off:providerProducts.provider,...counters,
  exact_authority_equal_across_model_wordings:true,
  builder_selected_semantic_answer:false,model_selected_project_id:false,
  raw_model_products_evaluated_as_code:false,genuine_unseen_claim:false};
save(`${dir}/observations.json`,observations);
const sourceFiles=['docs/gates/G33/R2/plan.json','docs/gates/G33/R2/expected-cases.json',
  'docs/gates/G33/R2/baseline.json','config/continuity-reading-schema-v1.json',
  'tests/fixtures/g33_r2/cases.json','scripts/g33_r2/run.mjs','scripts/g33_r2/verify.mjs',
  'src/continuity.metta','src/continuity_intent_v1.metta',
  'src/bootstrap_continuity_intent_v1.metta','src/memory.metta',
  'effect_membranes/miter_continuity_intent_v1.pl','effect_membranes/miter_resume.pl',
  'effect_membranes/miter_llm.pl'];
save(`${dir}/freeze.json`,{schema:'miter-g33-r2-freeze-v1',git_head:execFileSync('git',
  ['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),plan_commit:opening.plan_commit,
  petta_commit:'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d',
  swi_version:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),...counters});
console.log(JSON.stringify({status:'RAW-EVIDENCE-CAPTURED',attempt:tag,...counters}));
