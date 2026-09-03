// Offline test preparation and evidence collection, never a runtime reasoner.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawn,spawnSync,execFileSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {sexp,parse} from '../sc04/fixtures.mjs';import {cases,frame} from '../sc07/cases.mjs';import {second,clauses} from '../sc06/cases.mjs';
export {root,hash,sexp,parse};export const swi='/opt/homebrew/bin/swipl',petta='/private/tmp/miter-g06-petta-ae66fa8';
export const read=p=>JSON.parse(fs.readFileSync(p));export const save=(p,x)=>{fs.mkdirSync(p.slice(0,p.lastIndexOf('/')),{recursive:true});fs.writeFileSync(p,typeof x==='string'?x:JSON.stringify(x)+'\n')};
export const pause=ms=>new Promise(r=>setTimeout(r,ms));export async function until(f,ms=15000){const start=performance.now();for(;;){const x=f();if(x)return x;assert(performance.now()-start<ms,'condition wait exhausted');await pause(5)}}
export function capture(rel){assert(!fs.existsSync(root+'/'+rel));fs.mkdirSync(root+'/'+rel,{recursive:true});save(root+'/'+rel+'/opening.json',checkOpen('docs/gates/SC08/plan.json'));assert.equal(execFileSync('git',['-C',petta,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d');assert.equal(execFileSync('git',['-C',petta,'status','--porcelain'],{encoding:'utf8'}).trim(),'');
 const files=['src/development_cycle.metta','src/bootstrap_development_cycle.metta','effect_membranes/miter_development_cycle.pl','effect_membranes/miter_voice_construction.pl'];
 for(const p of files)save(root+'/'+rel+'/'+p.replaceAll('/','__'),fs.readFileSync(root+'/'+p,'utf8'));
 save(root+'/'+rel+'/freeze.json',{files:files.map(path=>({path,sha256:hash(fs.readFileSync(root+'/'+path))})),at:new Date().toISOString(),standing:'Synthetic laboratory sources; no natural incidence or general Soul claim'});
 for(const p of ['src/development_cycle.metta']){const ast=parse('('+fs.readFileSync(root+'/'+p,'utf8').replace(/^;.*$/gm,'')+')');const check=x=>{if(!Array.isArray(x))return;if(['if','let'].includes(x[0]))assert.equal(x.length,4);if(x[0]==='let*')assert.equal(x.length,3);x.forEach(check)};check(ast)}
}
export function native(dir,entry,name='probe'){
 save(dir+'/'+name+'.metta',entry);const p=spawnSync(swi,['--stack_limit=1g','-q','-s',petta+'/src/main.pl','--',dir+'/'+name+'.metta','silent'],{encoding:'utf8',timeout:60000,maxBuffer:32*1024*1024});
 save(dir+'/'+name+'.stdout',p.stdout??'');save(dir+'/'+name+'.stderr',p.stderr??'');save(dir+'/'+name+'-process.json',{status:p.status,signal:p.signal});assert.equal(p.status,0);assert.equal(p.stderr,'');
 return Object.fromEntries(p.stdout.replace(/\x1b\[[0-9;]*m/g,'').split('\n').filter(l=>l.startsWith('(case-result ')).map(l=>{const x=parse(l);return[x[1],x[2]]}));
}
export const bootstrap=`!(import! &self "${root}/src/bootstrap_development_cycle.metta")\n`;
export function source(dir){const row=cases().find(r=>r.id==='joint-supported'),a=row.c,b=second(a);save(dir+'/case.json',row);
 native(dir,bootstrap+`!(let* (($a (DObserve receipt-a independent-native-audit ${sexp(frame(a))} ${sexp(clauses)})) ($b (DObserve receipt-b independent-native-audit ${sexp(frame(b))} ${sexp(clauses)})) ($same (DObserve new-id independent-native-audit ${sexp(frame(a))} ${sexp(clauses)}))) (vc_record_receipts "${dir}" ($a $b $same)))\n`,'prepare');
 const receipts=read(dir+'/receipts.json').records;assert.equal(receipts.length,3);
 return {frame:frame(a),receipts:receipts.slice(0,2),surfaces:[['surface-capability','VoicePolicy','retention-omission','miter-voice-realization-v2',['trial-expression'],[]]],grant:['development-grant',a.scope,1,1024,120]};
}
export const state=p=>read(p+'/checkpoint.json').state;
export const trace=p=>{if(!fs.existsSync(p+'/trace.jsonl'))return[];const s=fs.readFileSync(p+'/trace.jsonl','utf8');return s.slice(0,s.lastIndexOf('\n')+1).split('\n').filter(Boolean).map(JSON.parse)};
export function atomic(p,x){save(p+'.new',x);fs.renameSync(p+'.new',p)}
export function control(p,action,scope=null){const s=state(p);const event=['control',s[1],scope??s[2],action];const at=Date.now()/1000;const record={event,sent_at:at};save(p+'/sent-controls/'+String(at)+'-'+action+'.json',record);atomic(p+'/control.json',record);return at}
export function prepare(p,input,options={}){
 fs.mkdirSync(p,{recursive:true});const id=options.id??'cycle-expression-001';const seed=['development-life',id,input.frame[1],'ready','unseen',input.grant,0,['purpose','unformed'],'none','unresolved'];
 save(p+'/seed.json',{native:seed});save(p+'/input.json',input);save(p+'/profile.json',{poll_seconds:options.poll??0.01,idle_cap_seconds:options.cap??0.01,watchdog_turns:options.turns??'none'});
 const canaries=['soul','history','derived'].map(s=>`!(add-atom &${s} (sc08-protected-canary ${s} immutable-test-content))`).join('\n');save(p+'/bootstrap.metta',bootstrap+canaries+'\n');
 const paths=read(root+'/evidence/SC07/live-001/manifest.json').files.map(f=>f.path).filter(x=>!x.includes('/evidence/'));
 paths.push(root+'/src/development_cycle.metta',root+'/src/bootstrap_development_cycle.metta',root+'/effect_membranes/miter_development_cycle.pl',p+'/seed.json',p+'/profile.json',p+'/bootstrap.metta');
 const files=paths.map(path=>({path,sha256:hash(fs.readFileSync(path))}));const semantic=hash(files.map(f=>f.sha256).join('\n'));save(p+'/manifest.json',{files,semantic,bootstrap:p+'/bootstrap.metta'});return {p,seed,input};
}
export function launch(p,label='run',timeout=15000){const out=fs.openSync(p+'/'+label+'.stdout','w'),err=fs.openSync(p+'/'+label+'.stderr','w');const start=performance.now();const child=spawn(swi,['--stack_limit=1g','-q','-s',root+'/scripts/sc08/main.pl','--',p,'silent'],{stdio:['ignore',out,err]});fs.closeSync(out);fs.closeSync(err);const timer=setTimeout(()=>child.kill('SIGTERM'),timeout);
 const done=new Promise(resolve=>child.on('close',(code,signal)=>{clearTimeout(timer);const r={code,signal,elapsed_ms:performance.now()-start};save(p+'/'+label+'-process.json',r);resolve(r)}));return {child,done,label};
}
export async function stopped(p,run){const at=control(p,'stop'),r=await run.done;assert.equal(r.code,0,fs.readFileSync(p+'/'+run.label+'.stderr','utf8'));assert.equal(fs.readFileSync(p+'/'+run.label+'.stderr','utf8'),'');const events=trace(p).filter(e=>e.kind==='native_transition'&&e.reason==='human-stopped');const latency=1000*(events.at(-1).wall_time-at);assert(latency<500);return latency}
