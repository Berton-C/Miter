// Test artifacts only. Native code owns runtime decisions.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {root} from '../fidelity/check.mjs';
export const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
export function prepare(relative,{budget=8,delay=0.03,poll=0.01,turns='none',complete=false,variant='canonical'}={}){
  assert(relative.startsWith('evidence/SC03/'));const dir=path.join(root,relative);assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});fs.mkdirSync(dir+'/inbox');
  const save=(name,x)=>fs.writeFileSync(dir+'/'+name,typeof x==='string'?x:JSON.stringify(x)+'\n');
  const base=JSON.parse(fs.readFileSync(root+'/tests/fixtures/sc01/cases.json'));
  let native=fs.readFileSync(root+'/src/undertaking.metta','utf8');
  if(variant==='consequence-severed'){
    const old='(UConsider (USet $s ready none no-cache) $o $fingerprint)';assert.equal(native.split(old).length,3);
    native=native.replaceAll(old,'(turn (USet $s waiting none (decision-frame $fingerprint severed-consequence)) wait severed-consequence)');
  }
  save('undertaking.metta',native);
  for(const [to,from] of [['compass.metta','constitution/soul_compass_v02.metta'],['participation.metta','src/participation.metta'],['support.metta','src/participation_support.metta']])save(to,fs.readFileSync(root+'/'+from,'utf8'));
  const boot=[['compass','compass.metta'],['self','participation.metta'],['self','support.metta'],['self','undertaking.metta']].map(([s,f])=>`!(import! &${s} "${dir}/${f}")`).join('\n')+'\n';save('bootstrap.metta',boot);
  const paths=['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','scripts/sc03/main.pl','effect_membranes/miter_undertaking.pl','effect_membranes/miter_store.pl','runtime/g07/libmiter_store_posix.dylib'].map(p=>root+'/'+p).concat(['bootstrap.metta','compass.metta','participation.metta','support.metta','undertaking.metta'].map(p=>dir+'/'+p));
  const files=paths.map(p=>({path:p,sha256:sha(fs.readFileSync(p))})),semantic=sha(files.map(x=>x.sha256).join('\n'));
  save('manifest.json',{files,semantic,bootstrap:dir+'/bootstrap.metta',limits:'Isolated laboratory bundle; no production authority claim.'});
  const records=base.focus.map((f,i)=>['node','commit-'+i,'human-confirmation',[base.scope[2]],base.scope[3],'v1',['commitment','agreement-'+i,'artifact',f[3],f[2],f[4]],[]]);
  records.push(['node','purpose-source','human-confirmation',[base.scope[2]],base.scope[3],'v1',['purpose','undertaking-one',base.request],[]]);
  const state=['undertaking','undertaking-one',base.scope,base.request,base.operations,budget,'ready','none',semantic,'purpose-source','no-cache',0,[]];
  const seed={schema:'miter-local-undertaking-v1',scope:base.scope,records,registry:records.map(n=>['observation',...n.slice(1,7)]),current:records.map(n=>['at',n[1],n[5]]),edges:base.state,revision:0,receipts:[],history:[],grant:['lab-grant',base.scope[2],base.scope[3],'active'],operations:base.operations,semantic,state,inbox_seen:[]};
  if(complete)seed.edges.push(['edge','artifact','revised']);
  save('seed.json',seed);save('profile.json',{poll_seconds:poll,idle_cap_seconds:Math.max(poll,0.1),worker_delay_seconds:delay,watchdog_turns:turns});
  return{dir,relative,semantic,seed};
}
