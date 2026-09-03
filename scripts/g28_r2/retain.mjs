// Copy raw workshop history without rewriting earlier evidence. No verdict.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';
const n=process.argv[2];assert.match(n??'',/^00[1-4]$/);const d=root+'/evidence/G28-R2/attempt-'+n,W=root+'/runtime/g27/attempt-282'+n.slice(1);
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):[p+'/'+e.name]);
const copy=(src,dst)=>{fs.mkdirSync(dst.slice(0,dst.lastIndexOf('/')),{recursive:true});if(fs.existsSync(dst))assert.equal(hash(fs.readFileSync(dst)),hash(fs.readFileSync(src)),dst);else fs.copyFileSync(src,dst)};
// A later snapshot has a distinct destination: never overwrite the earlier
// trial prefix with the longer post-review journal.
for(const sub of ['journal','events','receipts','prepared','states','request-ids'])if(fs.existsSync(W+'/'+sub))for(const p of walk(W+'/'+sub))copy(p,d+'/post-review'+p.slice(W.length));
for(const p of fs.readdirSync(d).filter(p=>/^candidate-[0-9]+\.json$/.test(p))){const c=read(d+'/'+p).native,dir=W+'/candidates/'+c[1];if(fs.existsSync(dir))for(const f of c[2]){assert.equal(hash(fs.readFileSync(dir+'/'+f[1])),f[3]);copy(dir+'/'+f[1],d+'/candidates/'+c[1]+'/'+f[1])}}
const git=args=>execFileSync('/usr/bin/git',['-c','core.hooksPath=/dev/null','-C',W+'/seed',...args],{encoding:'utf8'}).trim();
if(!fs.existsSync(d+'/candidate-history.bundle'))git(['bundle','create',d+'/candidate-history.bundle','--all']);
if(!fs.existsSync(d+'/retained-history.txt'))save(d+'/retained-history.txt',git(['log','--all','--graph','--decorate','--format=%H %s']));
console.log(JSON.stringify({status:'RAW-HISTORY-RETAINED',attempt:n,main:git(['rev-parse','main'])}));
