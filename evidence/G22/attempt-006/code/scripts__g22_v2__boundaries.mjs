// Fault injection affects only freshly created isolated copies. Every mutated
// artifact has an independently retained pre-injection copy. No historical raw
// evidence or control document is changed.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
import {root,read,save,native,bind,sexp,hash,swi} from './common.mjs';
const dir=root+'/'+process.argv[2];assert.match(dir,/\/evidence\/G22\/attempt-\d{3}$/);assert.equal(read(dir+'/verdict.json').status,'PASS-BOUNDED');
const base=dir+'/canonical',out=dir+'/boundaries';assert(!fs.existsSync(out));fs.mkdirSync(out);const checks=[];
process.on('uncaughtException',e=>{save(out+'/failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
function copy(name){const d=out+'/'+name;fs.mkdirSync(d);for(const f of ['input','parent','candidate','parent-report','candidate-report'])fs.copyFileSync(base+'/'+f+'.json',d+'/'+f+'.json');bind(d);return d}
function mutate(d,file,fn){const p=d+'/'+file;fs.copyFileSync(p,d+'/before-injection-'+file.replaceAll('/','__'));const value=fs.readFileSync(p);save(p,fn(value));}
function result(d,name,expr){return native(d,name,`!(result check ${expr})`)[0][2]}
for(const [name,file,change]of [
 ['candidate-hash','candidate.json',b=>{const x=JSON.parse(b);x.constructions[0].tokens=['@execute'];return x}],
 ['source-hash','input.json',b=>{const x=JSON.parse(b);x.native[1][0][2][4][0][2]='stale';return x}],
 ['report-hash','candidate-report.json',b=>{const x=JSON.parse(b);x.native[3].pop();return x}],
 ['missing-participant','manifest.json',b=>{const x=JSON.parse(b);x.files=x.files.filter(f=>!f.path.endsWith('/src/relational_voice.metta'));return x}],
 ['forged-lineage','lineage.json',b=>{const x=JSON.parse(b);x.candidate_hash='0'.repeat(64);return x}]
]){const d=copy(name);mutate(d,file,change);assert.deepEqual(result(d,'check',`(TVExecute "${d}")`),['trial-not-admitted','trial-integrity-failed']);assert(!fs.existsSync(d+'/store'));checks.push(name)}
const w=copy('unstaged-writer');assert.equal(result(w,'check',`(tv_commit "${w}" (development-intent fake))`),'development-commit-incomplete');assert(!fs.existsSync(w+'/store'));checks.push('unstaged-writer');
for(const name of ['active-tamper','ledger-tamper','missing-projection']){const d=copy(name);assert.equal(result(d,'commit',`(TVExecute "${d}")`)[2],'development-durable');const ledger=d+'/store/trajectory.jsonl';const old=hash(fs.readFileSync(ledger));
 if(name==='active-tamper')mutate(d,'active.json',b=>{const x=JSON.parse(b);x.native[3][2]='unearned';return x});
 if(name==='ledger-tamper')mutate(d,'store/trajectory.jsonl',b=>b.toString().replace('accepted-development','counterfeit-development'));
 if(name==='missing-projection')fs.renameSync(d+'/active.json',d+'/before-injection-active.json');
 assert.equal(result(d,'recover',`(tv_restore "${d}")`),'development-recovery-incomplete');
 if(name==='missing-projection'){assert.equal(result(d,'retry',`(TVExecute "${d}")`)[2],'development-durable');assert.equal(hash(fs.readFileSync(ledger)),old);assert.equal(result(d,'readback',`(TVHydrate "${d}" (tv_restore "${d}"))`),'active-projection-restored')}
 else assert.equal(result(d,'retry',`(TVExecute "${d}")`)[0],'trial-persistence-incomplete');checks.push(name);
}
const repeated=copy('same-runtime-repeat');const repeatedOut=native(repeated,'repeat',`!(result first (TVExecute "${repeated}"))\n!(result second (TVExecute "${repeated}"))\n!(result staged (size-atom (collapse (match &derived (pending-trial-commit "${repeated}" $i) $i))))\n!(result active (size-atom (collapse (match &derived (active-voice-v2 "${repeated}" $p $c $pin) $c))))`);assert.equal(repeatedOut[0][2][2],'development-durable');assert.equal(repeatedOut[1][2][2],'development-durable');assert.equal(repeatedOut[2][2],'1');assert.equal(repeatedOut[3][2],'1');assert.equal(fs.readFileSync(repeated+'/store/trajectory.jsonl','utf8').trim().split('\n').length,1);checks.push('same-runtime-repeat');
const q=copy('quarantine');const good=read(q+'/candidate.json');const mutants={valid:m=>{},'forbidden-write':m=>m.allowed_writes=['&soul'],'forbidden-effect':m=>m.allowed_effects=['http-post'],'legacy-schema':m=>m.schema='miter-voice-policy-v1','unknown-slot':m=>m.constructions[0].tokens=['@execute'],'duplicate-constructor':m=>m.constructions[1].id=m.constructions[0].id};
for(const [name,edit]of Object.entries(mutants)){const d=q+'/'+name;fs.mkdirSync(d);const m=structuredClone(good);edit(m);save(d+'/candidate.json',m);const r=native(d,'quarantine',`!(result admit (let $m (tv_module "${d}" candidate) (VQuarantine (index-atom $m 2) $m model-candidate-bound)))\n!(result trial (size-atom (collapse (match &trial (trial-voice-realization $id $m) $m))))\n!(tv_snapshot "${d}" after)`);assert.equal(r[1][2],name==='valid'?'1':'0');if(name==='valid')assert.equal(r[0][2],'candidate-quarantined');else assert.notEqual(r[0][2],'candidate-quarantined');const s=read(d+'/after-spaces.json');assert.equal(s.compass.length,129);assert.deepEqual(s.soul,[['protected-canary','Soul']]);assert.deepEqual(s.history,[['protected-canary','adverse-history']]);checks.push('quarantine-'+name)}
const outside=dir+'/../outside';assert.equal(result(q,'path-escape',`(tv_verify "${outside}")`),'trial-integrity-failed');checks.push('path-escape');
const link=q+'/symlink';fs.symlinkSync(base,link,'dir');assert.equal(result(q,'symlink-check',`(tv_verify "${link}")`),'trial-integrity-failed');save(q+'/symlink-test.json',{target:base,rejected:true});fs.unlinkSync(link);checks.push('symlink-escape');
save(out+'/verdict.json',{status:'PASS-BOUNDED',checks,limits:'Local deterministic fault injection and missing-projection simulation, not a power-loss or disk durability certification'});console.log(JSON.stringify({status:'PASS-BOUNDED',checks:checks.length}));
