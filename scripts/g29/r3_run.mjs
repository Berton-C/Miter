// Execute the frozen native-selected Nemotron repair.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';
import {root,hash,read,save,swi,petta} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'301';assert.match(tag,/^3[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
assert.equal(read(`${dir}/prepared.json`).status,'PREPARED');
for(const file of read(`${dir}/manifest.json`).files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
process.on('uncaughtException',error=>{save(`${dir}/run-failure.json`,{message:error.message,stack:error.stack});console.error(error.stack);process.exitCode=1});
save(`${dir}/execute-r3.metta`,
  `!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`+
  `!(add-atom &soul (protected-canary Soul))\n`+
  `!(result outcome (SXR3Run "${dir}"))\n`+
  `!(result state ((collapse (match &derived $a $a)) (collapse (match &soul $a $a))))\n`);
const started=Date.now();
const p=spawnSync(swi,['--stack_limit=1g','-q','-s',`${petta}/src/main.pl`,'--',`${dir}/execute-r3.metta`,'silent'],{encoding:'utf8',timeout:700000,maxBuffer:256*1024*1024});
save(`${dir}/execute-r3.stdout`,p.stdout??'');save(`${dir}/execute-r3.stderr`,p.stderr??'');
save(`${dir}/execute-r3-process.json`,{status:p.status,signal:p.signal,error:p.error?.message,started_at:new Date(started).toISOString(),elapsed_ms:Date.now()-started});
assert.equal(p.status,0);assert.equal(p.stderr,'');
const final=read(`${dir}/final-r3.json`).native;
assert.equal(final[0],'surface-extension-proposal-r3',JSON.stringify(final));
const selection=final[2],assessment=final[3];
assert.equal(selection[1],'nemotron-local');assert.equal(assessment[0],'surface-candidate-qualified-r2');
const candidate=assessment[1];assert.equal(candidate[2],'mattermost-r3');
const base=`${root}/runtime/g29/candidates/mattermost-r3`;
for(const file of candidate[6]){const path=`${base}/${file[1]}`;assert.equal(hash(fs.readFileSync(path)),file[3]);const out=`${dir}/candidate/${file[1]}`;fs.mkdirSync(out.slice(0,out.lastIndexOf('/')),{recursive:true});fs.copyFileSync(path,out)}
const calls=fs.readdirSync(dir).filter(x=>/^repair-(bridge|tests)-[12]-request\.json$/.test(x)).sort();assert.equal(calls.length,2);
const lineage=calls.map(name=>{const id=name.slice(0,-13),timing=read(`${dir}/${id}-timing.json`),wire=`${dir}/${id}-wire.json`;assert.equal(hash(fs.readFileSync(wire)),timing.wire_sha256);return {id,request_sha256:hash(fs.readFileSync(`${dir}/${name}`)),wire_sha256:timing.wire_sha256,timing}});
save(`${dir}/lineage-r3.json`,{schema:'miter-g29-r3-lineage-v1',selected_model:'nemotron-local',prior_candidate:'mattermost-r2',accepted_candidate:'mattermost-r3',calls:lineage,
  candidate_files:candidate[6].map(x=>({path:x[1],sha256:x[3]})),standing:'quarantined-candidate-not-promotion'});
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';save(`${dir}/services-after.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
save(`${dir}/run-verdict.json`,{status:'PASS-BOUNDED',selected_model:'nemotron-local',native_targets:['bridge','tests'],actual_new_model_calls:2,candidate:'mattermost-r3',
  syntax:assessment[4],trial_status:assessment[5][1],trial_errors:assessment[5][2],trial_failures:assessment[5][3],quarantined:true,not_promoted:true,
  mattermost_network_calls:0,credentials_used:0,next:'independent G29 controls then G30 plan'});
console.log(JSON.stringify(read(`${dir}/run-verdict.json`)));
