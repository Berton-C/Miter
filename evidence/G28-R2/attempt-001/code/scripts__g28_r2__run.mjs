// Offline invocation and independent observations; native MeTTa owns decisions.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,read,save,swi,petta} from '../g22_v2/common.mjs';
const n=process.argv[2];assert.match(n??'',/^00[1-4]$/);const d=root+'/evidence/G28-R2/attempt-'+n,W=root+'/runtime/g27/attempt-282'+n.slice(1);
assert.equal(read(d+'/prepared.json').status,'PREPARED');assert(!fs.existsSync(d+'/execute-process.json'));
process.on('uncaughtException',e=>{save(d+'/run-failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
for(const f of read(d+'/freeze.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
save(d+'/execute.metta',`!(import! &self "${root}/src/bootstrap_executable_development_v3.metta")\n!(add-atom &soul (protected-canary Soul))\n!(result outcome (let $r (ZRun "${d}") (wz_save "${d}" final $r)))\n!(result state (wz_save "${d}" atomspace ((collapse (match &trial $a $a)) (collapse (match &derived $a $a)) (collapse (match &soul $a $a)))))\n`);
const start=Date.now(),p=spawnSync(swi,['--stack_limit=1g','-q','-s',petta+'/src/main.pl','--',d+'/execute.metta','silent'],{encoding:'utf8',timeout:1320000,maxBuffer:128*1024*1024});
save(d+'/execute.stdout',p.stdout??'');save(d+'/execute.stderr',p.stderr??'');save(d+'/execute-process.json',{status:p.status,signal:p.signal,error:p.error?.message,elapsed_ms:Date.now()-start});
assert.equal(p.status,0);assert.equal(p.stderr,'');const final=read(d+'/final.json').native;
save(d+'/native-outcome.json',{kind:final[0],not_promoted:true});
assert.equal(final[0],'executable-awaiting-approval',JSON.stringify(final));const proposal=final[1],C=proposal[2],trial=proposal[3],id=C[1];
assert.equal(trial[2][0],'executable-trial-qualified');assert.equal(trial[4][2],0);assert.equal(trial[5][0],'test-sensitivity');for(const r of trial[5].slice(1))assert(r[2]!==0&&r[5]===false);
const prior=read(d+'/prior-readback.json').native[1],adapter=prior[2].find(f=>f[1]==='extension/adapter.sh');assert.deepEqual(C[2].find(f=>f[1]===adapter[1]),adapter);
for(const f of C[2])assert.equal(hash(fs.readFileSync(W+'/candidates/'+id+'/'+f[1])),f[3]);
const git=args=>execFileSync('/usr/bin/git',['-C',W+'/seed',...args],{encoding:'utf8'}).trim(),base=read(d+'/workshop-grant.json').base_commit;
assert.equal(git(['rev-parse','main']),base);assert.equal(git(['status','--porcelain']),'');
const commit=execFileSync('/usr/bin/git',['-C',W+'/candidates/'+id,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
save(d+'/git-history.txt',git(['log','--all','--graph','--decorate','--format=%H %s']));git(['bundle','create',d+'/candidate-history.bundle','--all']);
for(const sub of ['journal','events','receipts','prepared','states','request-ids'])fs.cpSync(W+'/'+sub,d+'/'+sub,{recursive:true});
for(const f of C[2]){const out=d+'/candidate/'+f[1];fs.mkdirSync(out.slice(0,out.lastIndexOf('/')),{recursive:true});fs.copyFileSync(W+'/candidates/'+id+'/'+f[1],out)}
const calls=fs.readdirSync(d).filter(f=>/^repair-[0-9]+-request\.json$/.test(f));assert(calls.length>=1&&calls.length<=4);
save(d+'/services-after.txt',execFileSync('/Applications/Docker.app/Contents/Resources/bin/docker',['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));assert.equal(fs.readFileSync(d+'/services-after.txt','utf8'),fs.readFileSync(d+'/services-before.txt','utf8'));
for(const f of read(d+'/freeze.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
save(d+'/approval-request.json',{status:'AWAITING-EXPLICIT-CANDIDATE-APPROVAL',candidate:id,commit,parent:base,workshop:W,files:C[2].map(f=>({path:f[1],sha256:f[3]})),scope:'Isolated non-networked laboratory main and registry only; no user service, Miter production main installation, network or credentials',purpose:'UTF-8 argument preserved as stdout plus exactly one LF',tests:'Six independent original cases, corrected smoke and two independent smoke-sensitivity mutants',rollback:'Retain prior laboratory main; additive history, no external effect to undo',not_promoted:true});
save(d+'/verdict.json',{status:'PASS-BOUNDED-AWAITING-APPROVAL',model_calls:calls.length,adapter_preserved:true,independent_tests:6,smoke_pass:true,sensitivity_mutants_rejected:2,main_unchanged:true,prior_failed_history_retained:true,commit,not_promoted:true,limits:'Targeted repair and trial only; G28 approval/additive merge/later use remain required'});
console.log(JSON.stringify(read(d+'/verdict.json')));
