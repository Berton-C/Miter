// Independent packaging and raw consequence review. Does not judge Soul fidelity.
import fs from 'node:fs';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
import {root,hash,validatePlan} from '../fidelity/check.mjs';import {read,save} from '../g22_v2/common.mjs';
process.chdir(root);const E=root+'/evidence/G28-R2';assert(!fs.existsSync(E+'/verification.json'));
const plan=validatePlan(read(root+'/docs/gates/G28/R2/P1/plan.json'));
const reports=[];
for(const n of ['001','002','003','004']){
 const d=E+'/attempt-'+n,W=root+'/runtime/g27/attempt-282'+n.slice(1),g=read(W+'/grant.json');
 const git=args=>execFileSync('/usr/bin/git',['-C',W+'/seed',...args],{encoding:'utf8'}).trim();
 assert.equal(git(['rev-parse','main']),g.base_commit);assert.equal(git(['status','--porcelain']),'');
 for(const f of read(d+'/freeze.json').files){const copy=d+'/code/'+f.path.slice(root.length+1).replaceAll('/','__');
  if(fs.existsSync(copy))assert.equal(hash(fs.readFileSync(copy)),f.sha256,copy);
  else assert.equal(hash(fs.readFileSync(f.path)),f.sha256,f.path);
 }
 const journal=W+'/journal/trajectory.jsonl',commits=[];let count=0;
 if(fs.existsSync(journal)){
  const lines=fs.readFileSync(journal,'utf8').trim().split('\n');let previous='GENESIS',parents=[];
  for(const [i,line]of lines.entries()){
   const r=JSON.parse(line);assert.equal(r.local_sequence,i+1);assert.equal(r.previous_event_hash,previous);assert.deepEqual(r.parent_event_ids,parents);
   assert.equal(hash(line.replace(/"event_hash":"[a-f0-9]{64}",/,'')),r.event_hash);
   const object=fs.readFileSync(W+'/journal/objects/sha256/'+r.payload_hash+'.json','utf8').replace(/\n$/,'');assert.equal(hash(object),r.payload_hash);
   const event=read(W+'/events/'+r.event_id+'.json');assert.deepEqual(JSON.parse(object),event.payload);assert.equal(r.event_id,'workshop-'+r.payload_hash);
   previous=r.event_hash;parents=[r.event_id];assert(!['merged','activated'].includes(event.payload.status));
   if(event.payload.status==='candidate-committed')commits.push({id:event.payload.request.candidate_id,commit:event.payload.details.commit});
  }count=lines.length;
  assert.equal(hash(fs.readFileSync(d+'/post-review/journal/trajectory.jsonl')),hash(fs.readFileSync(journal)));
 }
 for(const c of commits){const N=c.id.split('-').at(-1),C=read(d+'/candidate-'+N+'.json').native;
  for(const f of C[2])assert.equal(hash(fs.readFileSync(W+'/candidates/'+c.id+'/'+f[1])),f[3]);
  assert.equal(execFileSync('/usr/bin/git',['-C',W+'/candidates/'+c.id,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),c.commit);
 }
 reports.push({attempt:n,events:count,main_unchanged:true,commits});
}
const calls=[...['1','2','3'].map(i=>({d:E+'/attempt-002',id:'repair-'+i})),{d:E+'/attempt-004',id:'fresh-1'}];
for(const c of calls){const t=read(c.d+'/'+c.id+'-timing.json'),o=read(c.d+'/'+c.id+'-observation.json').native;
 assert.equal(hash(fs.readFileSync(c.d+'/'+c.id+'-wire.json')),t.wire_sha256);assert.equal(t.transport,'eof');assert.equal(t.http_status,200);assert.equal(o[5],true);assert.equal(o[6],'stop');assert.equal(o[7],'artifact-shaped');
 const b=read(c.d+'/'+c.id+'-request.json').body;assert.equal(b.max_tokens,2048);assert.equal(b.stream,true);
}
assert.deepEqual(read(E+'/attempt-002/candidate-2.json').native[2],read(E+'/attempt-002/candidate-3.json').native[2]);
const d=E+'/attempt-004',v=read(d+'/verdict.json'),C=read(d+'/candidate-1.json').native;
assert.equal(v.status,'PASS-BOUNDED-AWAITING-APPROVAL');assert.equal(read(d+'/boundary-verdict.json').status,'PASS-BOUNDED');assert.equal(read(d+'/budget-verdict.json').no_fifth_request,true);
for(const n of ['1','2','3','4'])assert(fs.existsSync(E+'/call-'+n+'.claim/owner.json'));
assert.equal(C[2][0][3],'ba699acc64161dad6124c66677188d14352bee869c94e91514f5db7f707252b4');
assert.equal(C[2][1][3],'3ab694434b5873a33f286df224bd0399fcab9040a3029496d42d7f8659c79d0f');
const oldText=read(E+'/attempt-002/candidate-2.json').native[2][1][2],question=read(d+'/fresh-1-generation.json').native;
assert(!JSON.stringify(question[6]).includes(JSON.stringify(oldText).slice(1,-1)));assert.equal(question[6][1][0],'write-fresh');
assert.equal(read(E+'/quality-006/verdict.json').status,'PASS-BOUNDED');assert.equal(read(E+'/diagnostics-002/verdict.json').status,'PASS-BOUNDED');
const services=execFileSync('/Applications/Docker.app/Contents/Resources/bin/docker',['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8'});assert.equal(services,fs.readFileSync(d+'/services-before.txt','utf8'));save(E+'/services-final.txt',services);
save(E+'/verification.json',{status:'PASS-BOUNDED-AWAITING-APPROVAL',actual_local_calls:4,model_ms:calls.map(c=>read(c.d+'/'+c.id+'-timing.json').elapsed_ms),reports,contract_only_request:true,adapter_preserved:true,independent_tests:6,smoke_sensitive_to_two_mutants:true,raw_lineages_verified:true,services_unchanged:true,control_hashes:plan.controls,not_promoted:true,g28_complete:false,limits:'Finite native partial repair and independent trial; full approval/additive merge/later uptake still required. No general shell reasoning, whole Soul or Mattermost claim.'});
console.log(JSON.stringify(read(E+'/verification.json')));
