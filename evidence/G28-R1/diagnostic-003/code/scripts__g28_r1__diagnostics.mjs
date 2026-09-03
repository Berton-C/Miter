// Builder-owned fault server and independent checker, not runtime cognition.
import fs from 'node:fs';import http from 'node:http';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {save,read,native,sexp,swi} from '../g22_v2/common.mjs';
process.chdir(root);const tag=process.argv[2];assert.match(tag??'',/^diagnostic-[0-9]{3}$/);const d=root+'/evidence/G28-R1/'+tag;assert(!fs.existsSync(d));fs.mkdirSync(d,{recursive:true});
save(d+'/opening.json',checkOpen('docs/gates/G28/R1/plan.json'));
const files=['src/participation.metta','src/development_continuation_v1.metta','src/executable_development_v2.metta','src/bootstrap_executable_development_v2.metta','effect_membranes/miter_executable_development_v2.pl','effect_membranes/miter_model_stream_v1.pl','scripts/g28_r1/diagnostics.mjs','scripts/g28_r1/transport-probe.pl'];
save(d+'/freeze.json',{files:files.map(p=>({path:root+'/'+p,sha256:hash(fs.readFileSync(p))})),new_model_calls:0});fs.mkdirSync(d+'/code');for(const f of files)fs.copyFileSync(f,d+'/code/'+f.replaceAll('/','__'));
process.on('uncaughtException',e=>{save(d+'/failure.json',{message:e.message,stack:e.stack});console.error(e);process.exit(1)});
const boot=`!(import! &self "${root}/src/bootstrap_executable_development_v2.metta")\n`;
const facts={fresh:[['edge','request','material'],['edge','grant','usable']],repeat:[['edge','grant','usable']],revision:[['edge','discrepancy','specific'],['edge','grant','usable']],narrow:[['edge','request','verbose'],['edge','grant','usable']],grant:[['edge','request','material'],['edge','grant','inadequate']],trial:[['edge','artifact','ready']],competing:[['edge','artifact','ready'],['edge','request','material'],['edge','grant','usable']]};
const compareBody=Object.entries(facts).map(([k,v])=>`!(result ${k} (let $r (YContinuationCompare ${sexp(v)}) (index-atom $r 1)))`).join('\n');
const results=native(d,'native-comparison',compareBody,boot);const map=Object.fromEntries(results.map(r=>[r[1],r[2]]));
assert.equal(map.fresh,'generate');assert.deepEqual(map.repeat,[]);assert.equal(map.revision,'incorporate');assert.equal(map.narrow,'narrow');assert.equal(map.grant,'request-resources');assert.equal(map.trial,'inspect-trial');assert(Array.isArray(map.competing)&&map.competing.length===2);
const neutral=native(d,'neutral',`!(result reordered (let $r (YContinuationCompare ${sexp([...facts.revision].reverse())}) (index-atom $r 1)))\n!(result renamed (let $r (DCCompare ((edge x available)) ((path x done)) ((operation another-name ((edge x available)) ((edge x done)) ())) 3) (index-atom $r 1)))`,boot);
assert.equal(neutral[0][2],'incorporate');assert.equal(neutral[1][2],'another-name');
const p=fs.readFileSync(root+'/src/participation.metta','utf8'),a=p.indexOf('(= (PRequired '),b=p.indexOf('(= (PDelete ',a);assert(a>=0&&b>a);
save(d+'/severed-participation-code.metta',p.slice(0,a)+'(= (PRequired $state $required $i) true)\n'+p.slice(b));
const severBoot=`!(import! &self "${d}/severed-participation-code.metta")\n!(import! &self "${root}/src/development_continuation_v1.metta")\n!(import! &self "${root}/src/executable_development_v2.metta")\n`;
const severed=native(d,'severed',compareBody,severBoot);assert.notDeepEqual(severed,results);assert.notDeepEqual(severed.find(x=>x[1]==='repeat')[2],[]);assert.deepEqual(native(d,'restored',compareBody,boot),results);
let calls=0;const timers=new Set();const product={adapter:'# synthetic transport probe only\n',smoke:'#  preserve  spaces and Unicode 🌱\n'};
const event=o=>'data: '+JSON.stringify(o)+'\n\n';
const server=http.createServer((req,res)=>{calls++;req.resume();
 if(req.url==='/error'){res.writeHead(503,{'content-type':'application/json'});res.end('{"error":"synthetic unavailable"}');return}
 res.writeHead(200,{'content-type':'text/event-stream'});res.flushHeaders();
 const content=req.url==='/malformed'?'{malformed':JSON.stringify(product);
 if(req.url==='/timeout'){res.write(event({choices:[{delta:{content:content.slice(0,20)},finish_reason:null}]}));const t=setTimeout(()=>{timers.delete(t);res.end()},2500);timers.add(t);return}
 // Split tokens and preserve whitespace inside JSON string data.
 for(const part of [content.slice(0,17),content.slice(17)])res.write(event({choices:[{delta:{content:part},finish_reason:null}]}));
 res.write(event({choices:[{delta:{},finish_reason:req.url==='/length'?'length':'stop'}],usage:{completion_tokens:19}}));res.end('data: [DONE]\n\n');
});await new Promise(r=>server.listen(0,'127.0.0.1',r));const port=server.address().port;
async function probe(kind){const sub=d+'/'+kind;fs.mkdirSync(sub);save(sub+'/request.json',{endpoint:`http://127.0.0.1:${port}/${kind}`,body:{stream:true}});const start=Date.now();const cp=spawn(swi,['-q','-s',root+'/scripts/g28_r1/transport-probe.pl','--',sub+'/request.json',sub,'1']);let out='',err='';cp.stdout.on('data',s=>out+=s);cp.stderr.on('data',s=>err+=s);const status=await new Promise(r=>cp.on('exit',r));save(sub+'/process.json',{status,elapsed_ms:Date.now()-start});save(sub+'/stdout',out);save(sub+'/stderr',err);assert.equal(status,0,err);assert.equal(err,'');return read(sub+'/observation.json').native}
const observed={};try{for(const k of ['good','timeout','length','malformed','error'])observed[k]=await probe(k)}finally{for(const t of timers)clearTimeout(t);server.closeAllConnections();await new Promise(r=>server.close(r))}
assert.equal(observed.good[2],'eof');assert.equal(observed.good[7],'artifact-shaped');assert.equal(observed.good[9],JSON.stringify(product));assert.equal(observed.good[10][1][2],product.smoke);
assert.equal(observed.timeout[2],'timeout');assert.equal(observed.timeout[5],false);assert(observed.timeout[9].length>0);assert(fs.statSync(d+'/timeout/wire.bin').size>0);
assert.equal(observed.length[6],'length');assert.equal(observed.length[7],'artifact-shaped');assert.equal(observed.malformed[7],'malformed-artifact');assert.equal(observed.error[3],503);
const ready=native(d,'observation-readiness',Object.entries(observed).map(([k,v])=>`!(result ${k} (YReady ${sexp(v)}))`).join('\n'),boot);for(const r of ready)assert.equal(r[2],r[1]==='good'?'true':'false');
const partial=structuredClone(observed.malformed);partial[5]=false;const pair=native(d,'same-label-different-evidence',`!(result complete (let $r (YContinuationCompare (PAdd (YFailureFacts ${sexp(observed.malformed)}) ((edge grant usable)) 0)) (index-atom $r 1)))\n!(result incomplete (let $r (YContinuationCompare (PAdd (YFailureFacts ${sexp(partial)}) ((edge grant usable)) 0)) (index-atom $r 1)))`,boot);
assert.equal(pair[0][2],'incorporate');assert.deepEqual(pair[1][2],[]);
save(d+'/verdict.json',{status:'PASS-BOUNDED',native:map,neutral,severed_changes:true,restored:true,typed_transport:Object.fromEntries(Object.entries(observed).map(([k,v])=>[k,{transport:v[2],http:v[3],done:v[5],finish:v[6],parse:v[7],bytes:v[8]}])),paired_evidence:pair,partial_inert:true,truncated_valid_json_inert:true,mock_requests:calls,new_model_calls:0,limits:'Finite means/end construction and transport diagnostics, not all-nine cognition or live executable success'});console.log(JSON.stringify(read(d+'/verdict.json')));
