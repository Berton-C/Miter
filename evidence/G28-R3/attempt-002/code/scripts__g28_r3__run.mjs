// Offline invocation/readback; native MeTTa forms each effect decision.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {root,hash,read,save,native} from '../g22_v2/common.mjs';
const n=process.argv[2],d=root+'/evidence/G28-R3/attempt-'+n,G=read(root+'/config/workshop-promotion-v1.json'),W=G.workshop_root;
assert.equal(read(d+'/quality-verdict.json').status,'PASS-BOUNDED');assert(!fs.existsSync(d+'/merge-first.stdout'));
process.on('uncaughtException',e=>{save(d+'/run-failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
for(const f of read(d+'/freeze.json').files)assert.equal(hash(fs.readFileSync(f.path)),f.sha256);
const git=args=>execFileSync('/usr/bin/git',['-C',W+'/seed',...args],{encoding:'utf8'}).trim();save(d+'/before-history.txt',git(['log','--all','--graph','--decorate','--format=%H %s']));
const boot=`!(import! &self "${root}/src/bootstrap_executable_promotion_v1.metta")\n`;
const first=native(d,'merge-first',`!(result merge (EPRun "${d}"))`,boot);assert.deepEqual(first[0][2],['promotion-incomplete','injected-after-git-before-receipt']);
const merged=git(['rev-parse','main']);assert.notEqual(merged,G.parent);assert.equal(git(['show','-s','--format=%P',merged]),G.parent+' '+G.target);assert(!fs.existsSync(W+'/promotion/merge-result.json'));
const recovered=native(d,'merge-recovered',`!(result merge (EPRun "${d}"))`,boot);assert.equal(recovered[0][2][0],'promotion-committed');assert.equal(recovered[0][2][1],merged);
const ledger=()=>fs.readFileSync(W+'/journal/trajectory.jsonl');const beforeReplay=ledger();assert.deepEqual(native(d,'merge-replayed',`!(result merge (EPRun "${d}"))`,boot),recovered);assert(ledger().equals(beforeReplay));assert.equal(git(['rev-parse','main']),merged);
const projected=[];
for(const[id,desired,expected]of [['activate',G.target,'none'],['rollback',G.parent,G.target],['restore',G.target,G.parent]]){
 const expr=`!(result projection (EPProjection "${d}" ${id} ${desired} ${expected}))`;
 const p=native(d,id+'-interrupted',expr,boot);assert.deepEqual(p[0][2],['projection-incomplete','injected-after-projection-before-receipt']);
 const r=native(d,id+'-recovered',expr,boot);assert.equal(r[0][2][0],'projection-selected');const snap=ledger();assert.deepEqual(native(d,id+'-replayed',expr,boot),r);assert(ledger().equals(snap));
 const use=native(d,id+'-later-use',`!(result use (let $r (EPUse "${d}" use-${id} ordinary) (wp_save "${d}" use-${id} $r)))`,boot);assert.equal(use[0][2],'stored');const result=read(d+'/use-'+id+'.json').native;assert.equal(result[0],'later-uptake');assert.equal(result[4],id==='rollback'?false:true);projected.push({id,revision:desired,contract_holds:result[4]});
}
assert.equal(git(['rev-parse','main']),merged);assert.equal(git(['status','--porcelain']),'');for(const f of read(G.evidence_root+'/candidate-1.json').native[2])assert.equal(hash(fs.readFileSync(W+'/seed/'+f[1])),f[3]);
save(d+'/after-history.txt',git(['log','--all','--graph','--decorate','--format=%H %s']));git(['bundle','create',d+'/promoted-history.bundle','--all']);
save(d+'/verdict.json',{status:'PASS-BOUNDED',candidate:G.target,merge:merged,parent:G.parent,explicit_approval:true,additive_parents:true,interrupted_merge_reconciled:true,merge_replay_no_change:true,projection_recovery_and_replay:true,later_uptake:projected,main_source_unchanged_by_tests:true,no_model_calls:true,no_live_reach:true});console.log(JSON.stringify(read(d+'/verdict.json')));
