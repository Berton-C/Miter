// Offline instrumentation; never imported by Miter.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {sexp,parse} from '../sc04/fixtures.mjs';
export {root,hash,sexp,parse};
export const swi='/opt/homebrew/bin/swipl',petta='/private/tmp/miter-g06-petta-ae66fa8';
export const origin=root+'/evidence/SC08/live-001/cycle/request';
export const read=p=>JSON.parse(fs.readFileSync(p)),save=(p,x)=>fs.writeFileSync(p,typeof x==='string'?x:JSON.stringify(x)+'\n');
export const participants=[...fs.readFileSync(root+'/effect_membranes/miter_voice_trials_v2.pl','utf8').matchAll(/^tv_required\('([^']+)'\)/gm)].map(x=>x[1]);
export const pins=paths=>paths.map(path=>({path,sha256:hash(fs.readFileSync(path))}));
export const bootstrap=`!(import! &self "${root}/src/bootstrap_voice_trials_v2.metta")\n!(add-atom &soul (protected-canary Soul))\n!(add-atom &history (protected-canary adverse-history))\n`;
export function native(dir,name,body,boot=bootstrap){
 save(dir+'/'+name+'.metta',boot+body+'\n');const p=spawnSync(swi,['--stack_limit=1g','-q','-s',petta+'/src/main.pl','--',dir+'/'+name+'.metta','silent'],{encoding:'utf8',timeout:120000,maxBuffer:128*1024*1024});
 save(dir+'/'+name+'.stdout',p.stdout??'');save(dir+'/'+name+'.stderr',p.stderr??'');save(dir+'/'+name+'-process.json',{status:p.status,signal:p.signal,error:p.error?.message});
 assert.equal(p.status,0,name);assert.equal(p.stderr,'',name);return p.stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n').filter(x=>x.startsWith('(result ')).map(parse);
}
export function capture(rel){assert.match(rel,/^evidence\/G22\/attempt-\d{3}$/);const dir=root+'/'+rel;assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});save(dir+'/opening.json',checkOpen('docs/gates/G22/plan.json'));
 assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');
 const files=[...new Set([...participants,'scripts/g22_v2/cases.mjs','scripts/g22_v2/common.mjs','scripts/g22_v2/run.mjs','scripts/g22_v2/verify.mjs','scripts/fidelity/check.mjs','scripts/fidelity/check.test.mjs'])];
 save(dir+'/freeze.json',{files:pins(files.map(x=>root+'/'+x)),swi:execFileSync(swi,['--version'],{encoding:'utf8'}).trim(),new_model_calls:0,standing:'Builder-inspected finite fixtures; actual historical model candidate'});
 fs.mkdirSync(dir+'/code');for(const f of files)fs.copyFileSync(root+'/'+f,dir+'/code/'+f.replaceAll('/','__'));return dir;
}
export function prepare(dir,rows,candidate){fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(root+'/derived/voice-realization-seed-v2.json',dir+'/parent.json');
 if(candidate)save(dir+'/candidate.json',candidate);else fs.copyFileSync(origin+'/candidate.json',dir+'/candidate.json');
 const cases=rows.map(r=>['trial-case',r.id,['voice-frame',r.c.scope,r.c.nodes,r.c.registry,r.c.current,r.c.operations,r.c.target,r.c.budget,r.c.proposals],r.fuel]);
 const pin=['trial-pins',hash(fs.readFileSync(dir+'/parent.json')),hash(fs.readFileSync(dir+'/candidate.json')),hash(JSON.stringify(pins(participants.map(x=>root+'/'+x)))),hash(JSON.stringify(cases))];
 save(dir+'/input.json',{native:['trial-input',cases,pin]});return {cases,pin};
}
export function report(dir,kind){const r=native(dir,'observe-'+kind,`!(result stored (let* (($input (tv_input "${dir}" input)) ($m (tv_module "${dir}" ${kind})) ($report (TVReport (index-atom $input 1) $m (index-atom $input 2)))) (tv_save "${dir}" ${kind}-report $report)))`);assert.deepEqual(r,[['result','stored','trial-observation-stored']]);return read(dir+'/'+kind+'-report.json').native;}
export function bind(dir){
 const lineage=read(origin+'/lineage.json');for(const f of lineage.files)assert.equal(hash(fs.readFileSync(origin+'/'+f.file)),f.sha256);
 assert.deepEqual(read(origin+'/raw.json').choices.map(x=>JSON.parse(x.message.content))[0],read(origin+'/candidate.json'));
 assert.equal(read(origin+'/request.json').request_id,read(origin+'/candidate.json').candidate_id);assert.equal(read(origin+'/timing.json').http_status,200);
 const old=read(origin+'/manifest.json');for(const name of participants.filter(x=>!x.includes('trials_v2')&&x!=='ACCEPTANCE.md')){const entry=old.files.find(x=>x.path===root+'/'+name);assert(entry,name);assert.equal(hash(fs.readFileSync(entry.path)),entry.sha256,name)}
 save(dir+'/lineage.json',{standing:'model-candidate-bound',parent_hash:lineage.parent_hash,candidate_hash:hash(fs.readFileSync(origin+'/candidate.json')),files:pins(lineage.files.map(f=>origin+'/'+f.file)),origin});
 save(dir+'/manifest.json',{pins:read(dir+'/input.json').native[2],files:pins([...participants.map(x=>root+'/'+x),...['input','parent','candidate','parent-report','candidate-report','lineage'].map(f=>dir+'/'+f+'.json')])});
}
