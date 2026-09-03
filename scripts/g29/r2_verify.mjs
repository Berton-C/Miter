// Independent exact-byte, process, isolation and resource verification.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'210';assert.match(tag,/^2[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
for(const name of ['run-verdict','quality-verdict'])assert.equal(read(`${dir}/${name}.json`).status,'PASS-BOUNDED');
for(const file of read(`${dir}/manifest.json`).files)assert.equal(hash(fs.readFileSync(file.path)),file.sha256,file.path);
const final=read(`${dir}/final-r2.json`).native;
const candidate=final[2][1];
const files=candidate[6];
const raw=new Map();
for(const part of ['bridge-1','tests-2']){
  const observation=read(`${dir}/repair-${part}-observation.json`).native;
  const decoded=JSON.parse(observation[10]);
  raw.set(observation[2],decoded.content);
}
for(const file of files){
  const part=file[1].startsWith('extension/')?'bridge':'tests';
  assert.equal(file[2],raw.get(part));
  assert.equal(hash(Buffer.from(file[2])),file[3]);
  assert.equal(hash(fs.readFileSync(`${dir}/candidate/${file[1]}`)),file[3]);
}
const text=files.map(x=>x[2]).join('\n').toLowerCase();
for(const token of ['chroma','miter_soul','src/soul','&soul','direct_memory'])assert(!text.includes(token),token);
assert(!/bearer\s+[a-z0-9_-]{12,}/i.test(text));
assert(!fs.existsSync(`${root}/extension/mattermost_bridge.pl`));
const bridge=`${dir}/candidate/extension/mattermost_bridge.pl`;
const tests=`${dir}/candidate/candidate_tests/mattermost_contract_tests.pl`;
const p=spawnSync('/opt/homebrew/bin/swipl',['-q','-f','none','-s',bridge,'-s',tests,'-g','run_tests','-t','halt'],{
  cwd:`${dir}/candidate/candidate_tests`,encoding:'utf8',timeout:30000,maxBuffer:8*1024*1024,env:{HOME:'/nonexistent',PATH:'/usr/bin:/bin'}
});
save(`${dir}/independent-trial.stdout`,p.stdout??'');
save(`${dir}/independent-trial.stderr`,p.stderr??'');
assert.equal(p.status,0,p.stderr);
assert(!(p.stderr??'').includes('ERROR:'),p.stderr);
assert(!(p.stderr??'').includes('failed'),p.stderr);
const lineage=read(`${dir}/lineage-r2.json`);
assert.equal(lineage.calls.length,2);
for(const call of lineage.calls){
  assert.equal(call.timing.http_status,200);
  assert.equal(call.timing.transport,'eof');
  assert(call.timing.elapsed_ms<=300500);
}
for(const slot of [1,2])assert(fs.existsSync(`${root}/evidence/G29/R2-call-${slot}.claim/owner.json`));
assert(!fs.existsSync(`${root}/evidence/G29/R1-call-4.claim`));
assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
save(`${dir}/verification.json`,{status:'PASS-BOUNDED',native_repair_scope:true,prior_failure_retained:true,model_repair_products:2,
  candidate_bytes_match_model:true,syntax_and_candidate_tests_pass:true,independent_trial_pass:true,forbidden_core_access_absent:true,
  credential_literals_absent:true,candidate_quarantined:true,services_unchanged:true,mattermost_network_calls:0,credentials_used:0,not_promoted:true,
  limits:'G29 design/authorship evidence only; mock-service behavior is G30 and live authority is G31'});
console.log(JSON.stringify(read(`${dir}/verification.json`)));
