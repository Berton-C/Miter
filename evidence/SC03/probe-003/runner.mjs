import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawn,spawnSync} from 'node:child_process';
import {root,checkOpen} from '../fidelity/check.mjs';
import {prepare} from './prepare.mjs';
process.chdir(root);
const rel=process.argv[2];assert.match(rel??'',/^evidence\/SC03\/probe-\d{3}$/);
const p=prepare(rel,{delay:0.02,poll:0.01,turns:500});
fs.writeFileSync(p.dir+'/opening.json',JSON.stringify(checkOpen('docs/gates/SC03/plan.json'))+'\n');
for(const [to,from] of [['membrane.pl','effect_membranes/miter_undertaking.pl'],['main.pl','scripts/sc03/main.pl'],['preparer.mjs','scripts/sc03/prepare.mjs'],['runner.mjs','scripts/sc03/probe.mjs']])fs.copyFileSync(from,p.dir+'/'+to);
const init=spawnSync('/opt/homebrew/bin/swipl',['-q','-s','scripts/sc03/main.pl','--','init',p.dir,'silent'],{encoding:'utf8'});
fs.writeFileSync(p.dir+'/init.stdout',init.stdout??'');fs.writeFileSync(p.dir+'/init.stderr',init.stderr??'');assert.equal(init.status,0);
const out=fs.openSync(p.dir+'/run.stdout','w'),err=fs.openSync(p.dir+'/run.stderr','w');
const child=spawn('/opt/homebrew/bin/swipl',['--stack_limit=1g','-q','-s','scripts/sc03/main.pl','--',p.dir,'silent'],{stdio:['ignore',out,err]});fs.closeSync(out);fs.closeSync(err);
const timer=setTimeout(()=>child.kill('SIGTERM'),12000);
const result=await new Promise(resolve=>child.on('close',(code,signal)=>resolve({code,signal})));
clearTimeout(timer);fs.writeFileSync(p.dir+'/process.json',JSON.stringify(result)+'\n');
let world;try{world=JSON.parse(fs.readFileSync(p.dir+'/world.json')).body}catch{}
const summary={...result,status:world?.state?.[6],receipts:world?.receipts?.length,evidence:rel};fs.writeFileSync(p.dir+'/probe-result.json',JSON.stringify(summary)+'\n');console.log(JSON.stringify(summary));
