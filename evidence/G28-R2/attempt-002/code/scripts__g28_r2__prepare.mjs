// Offline grant, immutable test fixtures and frozen source preparation. No model
// implementation is authored here; inherited adapter/smoke remain model bytes.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {read,save,native,sexp} from '../g22_v2/common.mjs';
process.chdir(root);const n=process.argv[2];assert.match(n??'',/^00[1-4]$/);
const dir=root+'/evidence/G28-R2/attempt-'+n,W=root+'/runtime/g27/attempt-282'+n.slice(1),old=root+'/evidence/G28-R1/attempt-003';
assert(!fs.existsSync(dir)&&!fs.existsSync(W));fs.mkdirSync(dir,{recursive:true});fs.mkdirSync(W,{recursive:true});
process.on('uncaughtException',e=>{save(dir+'/failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
save(dir+'/opening.json',checkOpen('docs/gates/G28/R2/plan.json'));
const sources=[...new Set([...read(old+'/freeze.json').files.map(f=>f.path),
 ...['src/executable_partial_revision_v1.metta','src/executable_development_v3.metta','src/bootstrap_executable_development_v3.metta','effect_membranes/miter_executable_development_v3.pl','config/executable-candidate-schema-v3.json','scripts/g28_r2/prepare.mjs','scripts/g28_r2/run.mjs','scripts/g28_r2/quality.mjs'].map(p=>root+'/'+p),
 ...['candidate-1.json','trial-1.json','executable-1-wire.json','executable-1-timing.json','executable-1-request.json','executable-1-observation.json','candidate-history.bundle'].map(p=>old+'/'+p)])];
const pins=sources.map(path=>({path,sha256:hash(fs.readFileSync(path))}));save(dir+'/freeze.json',{files:pins,model_alias:'qwen-local',max_calls:4,max_tokens:2048,deadline_seconds:300,standing:'R2 scoped continuation under user approval; fixture human contract, real historical model/test evidence'});
fs.mkdirSync(dir+'/code');for(const p of sources.filter(p=>!p.includes('/config/local/')&&!p.includes('/evidence/')))fs.copyFileSync(p,dir+'/code/'+p.slice(root.length+1).replaceAll('/','__'));
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(dir+'/services-before.txt',execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
const seed=W+'/seed';fs.mkdirSync(seed);const git=args=>execFileSync('/usr/bin/git',['-c','core.hooksPath=/dev/null','-C',seed,...args],{encoding:'utf8'}).trim();
git(['init','-b','unborn']);git(['fetch',old+'/candidate-history.bundle','refs/heads/*:refs/heads/*']);git(['checkout','main']);const base=git(['rev-parse','HEAD']);
assert.equal(base,read(old+'/workshop-grant.json').base_commit);assert.equal(git(['status','--porcelain']),'');
save(dir+'/prior-history.txt',git(['log','--all','--graph','--decorate','--format=%H %s']));
const contracts=W+'/contracts';fs.mkdirSync(contracts);const oldGrant=read(old+'/workshop-grant.json');
for(const {id} of oldGrant.tests)fs.copyFileSync(oldGrant.contracts+'/'+id+'.sh',contracts+'/'+id+'.sh');
const mutants={'smoke-no-output':'exit 0\n','smoke-no-lf':"printf '%s' \"$1\"\n"};
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
for(const[id,body]of Object.entries(mutants))save(contracts+'/'+id+'.sh',
 'set -eu\nbak=$(mktemp /tmp/adapter-preserved.XXXXXX)\ncp /workspace/extension/adapter.sh "$bak"\ntrap \'cp "$bak" /workspace/extension/adapter.sh; rm -f "$bak"\' EXIT\n'+
 'printf %s '+quote(body)+' > /workspace/extension/adapter.sh\ncd /workspace\n/bin/sh /workspace/candidate_tests/smoke.sh\n');
const tests=[...oldGrant.tests,{id:'smoke-no-output'},{id:'smoke-no-lf'}],grantId='g28-r2-'+n;
const grant={...oldGrant,grant_id:grantId,repository:seed,contracts,tests,integrity:[...pins,...tests.map(({id})=>({path:contracts+'/'+id+'.sh',sha256:hash(fs.readFileSync(contracts+'/'+id+'.sh'))}))]};save(W+'/grant.json',grant);save(dir+'/workshop-grant.json',grant);
const input=read(old+'/input.json').native;for(const rows of [input[3],input[4]]){const g=rows.find(r=>r[1]==='grant-source');g[6][2]=grantId;g[6][3]=4;}input[1]='native-stdout-partial-repair';
save(dir+'/input.json',{native:input,standing:'Builder fixture admission of continuing local repair authority; old contract unchanged'});
save(dir+'/context.json',{schema:'miter-executable-context-v3',workshop_root:W,prior_root:old,chat_context:[]});
save(dir+'/manifest.json',{files:[...pins,...['input.json','context.json'].map(f=>({path:dir+'/'+f,sha256:hash(fs.readFileSync(dir+'/'+f))}))]});
const boot=`!(import! &self "${root}/src/bootstrap_executable_development_v3.metta")\n`;
const pre=native(dir,'native-preflight',`
!(result source (let $o (ZOpportunity (wz_input "${dir}")) (wz_save "${dir}" opportunity $o)))
!(result prior (let $p (wz_prior "${dir}") (wz_save "${dir}" prior-readback $p)))
!(result revision (let* (($p (wz_prior "${dir}")) ($rows (ZObligations (index-atom $p 2))) ($r (PRConstruct (index-atom (index-atom $p 1) 2) $rows))) (wz_save "${dir}" prior-revision $r)))
`,boot);assert(pre.length===3&&pre.every(r=>r[2]==='stored'));const o=read(dir+'/opportunity.json').native;assert.equal(o[0],'executable-opportunity');
const revision=read(dir+'/prior-revision.json').native;assert.equal(revision[0],'partial-revision');assert.deepEqual(revision[1].map(f=>f[1]),['candidate_tests/smoke.sh']);assert.deepEqual(revision[2].map(f=>f[1]),['extension/adapter.sh']);assert.deepEqual(revision[3],[]);
const wb=`!(import! &self "${root}/src/bootstrap_workshop_boundary_v1.metta")\n`;
const request=(id,operation,extra={})=>{save(W+'/request-'+id+'.json',{schema:'miter-workshop-request-v1',request_id:id,idempotency_key:id,grant_id:grantId,operation,candidate_id:'parent-r2',...extra});return native(dir,id,`!(result broker (WorkshopRequest "${W}" "request-${id}.json"))`,wb)[0][2]};
assert.equal(request('parent-create','create_candidate_worktree')[2],'candidate-created');assert.equal(request('parent-missing','run_declared_test',{test_id:'ordinary'})[2],'test-failed');assert.equal(request('direct-main','write_candidate_file',{path:'../seed/CONTROL.txt',contents:'forbidden'})[2],'operation-denied');
save(dir+'/prepared.json',{status:'PREPARED',target:revision[1].map(f=>f[1]),preserved:revision[2].map(f=>({path:f[1],sha256:f[3]})),prior_history_preserved:true,independent_tests_unchanged:true,negative_tests:Object.keys(mutants),model_calls:0});console.log(JSON.stringify(read(dir+'/prepared.json')));
