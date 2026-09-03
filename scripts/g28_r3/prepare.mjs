// Offline approval attribution, not a claim of live-authenticated ingress.
import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';import {read,save,native} from '../g22_v2/common.mjs';
const n=process.argv[2];assert.match(n??'',/^[0-9]{3}$/);const d=root+'/evidence/G28-R3/attempt-'+n;assert(!fs.existsSync(d));fs.mkdirSync(d,{recursive:true});
process.on('uncaughtException',e=>{save(d+'/failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
save(d+'/opening.json',checkOpen('docs/gates/G28/R3/plan.json'));
const g=read(root+'/config/workshop-promotion-v1.json'),prior=g.evidence_root,scope=['scope','cut-g28-r3','berton','project-g28','isolated-builder-lab'];
const payload=['promotion-approval',g.target,g.parent,hash(fs.readFileSync(prior+'/candidate-1.json')),scope,'approve'];
const node=['node','approval-source','human-confirmation',['berton'],'project-g28','v1',payload,[]];
const input=['promotion-input','approved-g28-promotion',scope,[node],[['observation',...structuredClone(node.slice(1,7))]],[['at','approval-source','v1']],'approval-source'];
save(d+'/input.json',{native:input,authority_attribution:{user:'Berton',exact_candidate:g.target,scope:g.scope,approval:'please continue.',context:'After exact candidate promotion request and clarification. No network, credentials, production installation or push.',standing:'Builder-attributed conversation confirmation, not live identity-ingress proof'}});
const paths=[...new Set([...read(prior+'/freeze.json').files.map(f=>f.path),...['src/executable_promotion_v1.metta','src/bootstrap_executable_promotion_v1.metta','effect_membranes/miter_workshop_promotion_v1.pl','config/workshop-promotion-v1.json','scripts/g28_r3/prepare.mjs','scripts/g28_r3/quality.mjs','scripts/g28_r3/fixtures.pl','scripts/g28_r3/run.mjs'].map(p=>root+'/'+p),...['candidate-1.json','final.json','trial-1.json','fresh-1-wire.json','fresh-1-timing.json','verdict.json','boundary-verdict.json'].map(p=>prior+'/'+p),d+'/input.json'])];
const files=paths.map(path=>({path,sha256:hash(fs.readFileSync(path))}));save(d+'/freeze.json',{files,model_calls:0,target:g.target,parent:g.parent});save(d+'/manifest.json',{files});
fs.mkdirSync(d+'/code');for(const p of paths.filter(p=>!p.includes('/evidence/')&&!p.includes('/config/local/')))fs.copyFileSync(p,d+'/code/'+p.slice(root.length+1).replaceAll('/','__'));
const boot=`!(import! &self "${root}/src/bootstrap_executable_promotion_v1.metta")\n`;
const rows=native(d,'preflight',`!(result snapshot (let $s (wp_snapshot "${d}") (wp_save "${d}" snapshot $s)))\n!(result admission (let $a (EPAdmission (wp_input "${d}") (wp_snapshot "${d}")) (wp_save "${d}" preflight-admission $a)))`,boot);
assert(rows.length===2&&rows.every(x=>x[2]==='stored'));assert.equal(read(d+'/preflight-admission.json').native[0],'promotion-admitted');
save(d+'/prepared.json',{status:'PREPARED',candidate:g.target,no_promotion_yet:true});console.log(JSON.stringify(read(d+'/prepared.json')));
