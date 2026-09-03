// Run the three native-requested, separately bounded semantic products.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,read,save,swi,petta} from '../g22_v2/common.mjs';
const dir=root+'/evidence/G29/attempt-101';assert.equal(read(dir+'/prepared.json').status,'PREPARED');
process.on('uncaughtException',e=>{save(dir+'/run-failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
for(const f of read(dir+'/manifest.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
save(dir+'/execute-r1.metta',`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n!(add-atom &soul (protected-canary Soul))\n!(result outcome (SXR1Run "${dir}"))\n!(result state ((collapse (match &derived $a $a)) (collapse (match &soul $a $a))))\n`);
const started=Date.now(),p=spawnSync(swi,['--stack_limit=1g','-q','-s',petta+'/src/main.pl','--',dir+'/execute-r1.metta','silent'],{encoding:'utf8',timeout:1320000,maxBuffer:256*1024*1024});
save(dir+'/execute-r1.stdout',p.stdout??'');save(dir+'/execute-r1.stderr',p.stderr??'');save(dir+'/execute-r1-process.json',{status:p.status,signal:p.signal,error:p.error?.message,elapsed_ms:Date.now()-started});
assert.equal(p.status,0);assert.equal(p.stderr,'');const final=read(dir+'/final-r1.json').native;assert.equal(final[0],'surface-extension-proposal',JSON.stringify(final));
const design=final[1],assessment=final[2],candidate=assessment[1];assert.equal(assessment[0],'surface-candidate-qualified');assert.equal(candidate[0],'surface-extension-candidate');
const id=candidate[2],base=root+'/runtime/g29/candidates/'+id;for(const f of candidate[6]){const path=base+'/'+f[1];assert.equal(hash(fs.readFileSync(path)),f[3]);const out=dir+'/candidate/'+f[1];fs.mkdirSync(out.slice(0,out.lastIndexOf('/')),{recursive:true});fs.copyFileSync(path,out)}
save(dir+'/candidate-rationale.md',candidate[3]);save(dir+'/candidate-plan.md',candidate[4]);save(dir+'/candidate-manifest.json',{native:candidate[5]});
const calls=fs.readdirSync(dir).filter(x=>/^(design|bridge|tests)-[1-4]-request\.json$/.test(x)).sort();assert(calls.length===3,calls);
const lineages=calls.map(name=>{const id=name.slice(0,-13),timing=read(dir+'/'+id+'-timing.json'),wire=dir+'/'+id+'-wire.json';assert.equal(hash(fs.readFileSync(wire)),timing.wire_sha256);return {id,request:hash(fs.readFileSync(dir+'/'+name)),wire:timing.wire_sha256,timing}});
save(dir+'/lineage.json',{schema:'miter-g29-r1-lineage-v1',design_sha256:hash(fs.readFileSync(dir+'/design.json')),calls:lineages,accepted_candidate:id,
 candidate_files:candidate[6].map(f=>({path:f[1],sha256:f[3]})),standing:'Three decomposed local-model products assembled and qualified by native MeTTa; no product is promotion'});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(dir+'/services-after.txt',execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert.equal(fs.readFileSync(dir+'/services-before.txt','utf8'),fs.readFileSync(dir+'/services-after.txt','utf8'));
for(const f of read(dir+'/manifest.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
save(dir+'/run-verdict.json',{status:'PASS-BOUNDED',native_design:true,modality:'swi-prolog',actual_new_model_calls:3,decomposed_products:['design','bridge','tests'],
 candidate:id,manifest:true,plan:true,rationale:true,code_files:2,syntax:true,boundary_scan:true,quarantined:true,not_promoted:true,
 live_mattermost:false,credentials:false,next:'G30 independent adversarial mock round trip'});console.log(JSON.stringify(read(dir+'/run-verdict.json')));
