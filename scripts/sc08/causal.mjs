// Frozen diagnostic mutations and independent lifecycle assertions; offline only.
import fs from 'node:fs';import assert from 'node:assert/strict';import {root,capture,source,native,sexp,save,read} from './common.mjs';
process.chdir(root);const rel=process.argv[2];assert.match(rel??'',/^evidence\/SC08\/causal-\d{3}$/);capture(rel);const dir=root+'/'+rel;
try{const input=source(dir),scope=input.frame[1],s=['development-life','cycle-expression-001',scope,'ready','unseen',input.grant,0,['purpose','unformed'],'none','unresolved'];
 const obs=(changes={})=>{const c={...input,worker:'none',control:'none',fp:'source-a',...changes};return ['cycle-observation',c.fp,c.frame,c.receipts,c.surfaces,c.grant,c.worker,c.control]};
 const code=fs.readFileSync(root+'/src/development_cycle.metta','utf8'),dev=fs.readFileSync(root+'/src/development_evidence.metta','utf8');const rows=[];
 const add=(id,state,observation,phase,reason=null)=>rows.push({id,state,observation,phase,reason});
 add('qualified',sexp(s),sexp(obs()),'pending');add('one-family',sexp(s),sexp(obs({receipts:input.receipts.slice(0,1)})),'waiting');
 add('same-family',sexp(s),sexp(obs({receipts:[input.receipts[0],read(dir+'/receipts.json').records[2]]})),'waiting');
 add('neutral-order',sexp(s),sexp(obs({receipts:[...input.receipts].reverse()})),'pending');
 add('malformed-receipt',sexp(s),sexp(obs({receipts:[['bad'],input.receipts[1]]})),'waiting');
 const self=structuredClone(input.receipts);for(const r of self)r[3]='self-trace';add('self-authored-claims',sexp(s),sexp(obs({receipts:self})),'waiting');
 add('no-capability',sexp(s),sexp(obs({surfaces:[]})),'waiting');
 const used=structuredClone(s);used[6]=1;add('consumed-envelope',sexp(used),sexp(obs()),'incomplete','resource-envelope-consumed');
 const g0=[...input.grant];g0[2]=0;const zero=structuredClone(s);zero[5]=g0;add('zero-envelope',sexp(zero),sexp(obs({grant:g0})),'waiting');
 add('foreign-frame',sexp(s),sexp(obs({frame:['voice-frame',['scope','other','other','other','other'],[],[],[],[],'artifact',1,[]]})),'ready',['cycle-fault','malformed-or-foreign-input']);
 add('malformed-frame',sexp(s),sexp(obs({frame:['wrong']})),'ready',['cycle-fault','malformed-frame']);
 const pending='(index-atom $q 1)';add('pending-stable',pending,sexp(obs({worker:'pending'})),'pending','awaiting-model-result');
 add('unknown-result',pending,sexp(obs({worker:'outcome-uncertain'})),'reconciliation','possibly-sent-result-unknown');
 add('source-changed',pending,sexp(obs({worker:'pending',fp:'source-b'})),'revalidation-required','source-or-authority-changed');
 add('grant-changed',pending,sexp(obs({worker:'pending',grant:g0})),'revalidation-required','source-or-authority-changed');
 for(const w of ['model-timeout','model-unavailable','model-truncated','model-refusal','malformed-model-output'])add(w,pending,sexp(obs({worker:w})),'incomplete',['transport-incomplete',w]);
 add('human-pause',pending,sexp(obs({worker:'pending',control:['control',s[1],scope,'pause']})),'paused','human-paused');
 add('human-stop',pending,sexp(obs({worker:'pending',control:['control',s[1],scope,'stop']})),'stopped','human-stopped');
 add('wrong-scope-control',pending,sexp(obs({worker:'pending',control:['control',s[1],['scope','foreign','other','other','other'],'pause']})),'pending','awaiting-model-result');
 const variants={canonical:{},'sever-family':{dev:dev.replace('(DSameFamily (index-atom $a 3) (index-atom $b 3))','true')},'sever-opportunity':{code:code.replace('(if (PShape $rna develop-rna 5)','(if false')},restored:{}};
 const results={};for(const [arm,v]of Object.entries(variants)){save(dir+'/'+arm+'-cycle.metta',v.code??code);save(dir+'/'+arm+'-evidence.metta',v.dev??dev);
 const boot=`!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n!(import_prolog_functions_from_file "${root}/effect_membranes/miter_voice_construction.pl" (vc_word vc_budget vc_sentence vc_module))\n!(import_prolog_functions_from_file "${root}/effect_membranes/miter_development_cycle.pl" (dc_counter))\n!(import! &self "${dir}/${arm}-evidence.metta")\n!(import! &self "${root}/src/voice_construction.metta")\n!(import! &self "${dir}/${arm}-cycle.metta")\n`;
 const use=arm.startsWith('sever')?rows.filter(r=>r.id==='qualified'):rows;
 const entry=boot+use.map(r=>`!(let $q (CStep ${sexp(s)} ${sexp(obs())}) (case-result ${r.id} (CStep ${r.state} ${r.observation})))`).join('\n')+'\n';results[arm]=native(dir,entry,arm);save(dir+'/'+arm+'-results.json',results[arm]);
 }
 for(const r of rows){const actual=results.canonical[r.id];assert.equal(actual[0],'cycle-step');assert.equal(actual[1][3],r.phase,r.id);if(r.reason!==null)assert.deepEqual(actual[3],r.reason,r.id);assert.deepEqual(actual,results.restored[r.id]);}
 for(const arm of ['sever-family','sever-opportunity']){assert.equal(results[arm].qualified[1][3],'waiting');assert.deepEqual(results[arm].qualified[2],[])}
 assert.equal(results.canonical.qualified[2][0][0],'dispatch');assert.equal(results.canonical['neutral-order'][2][0][0],'dispatch');
 save(dir+'/cases.json',rows);save(dir+'/verdict.json',{status:'PASS-BOUNDED',cases:rows.length,arms:Object.keys(variants),model_calls:0,limits:'Native finite lifecycle dispositions; direct worker statuses are synthetic unit observations, not real service outcomes.'});console.log(JSON.stringify({status:'PASS',cases:rows.length,arms:Object.keys(variants)}));
}catch(e){save(dir+'/failure.json',{message:e.message,stack:e.stack});throw e}
