// Independent builder readback; never imported by the native runtime.
import assert from 'node:assert/strict';
import {meanings,set} from '../sc05/verify.mjs';
import {walk} from '../sc04/verify.mjs';
import {frame} from './cases.mjs';
export function verify(rows,mods,compilers,runs){
 for(const r of rows){const a=runs.canonical[r.id];assert.equal(a[3][0],r.expected,r.id);assert.deepEqual(a,runs.restored[r.id]);if(r.expected==='development-opportunity'){
  const o=a[3];assert.equal(o.length,12);assert.deepEqual(o[2],r.a.scope);assert.deepEqual(o[3],['target','VoicePolicy']);assert.deepEqual(o[4],['soul-ground',['SharedUnderstanding']]);assert.deepEqual(new Set(o[5][1]),new Set(['receipt-a','receipt-b']));assert.equal(a[4][0],'develop-rna');assert.deepEqual(a[4][3],['opportunity',o]);assert.deepEqual(o[9],['allowed-effects',[]]);
  const basis=o[6][1];assert(basis.length);for(const b of basis){assert.deepEqual(b[1],['retention-omission','inspection']);assert.notEqual(b[2][3][2],b[3][3][2]);for(const e of [b[2],b[3]]){
   const c=e[1]==='receipt-a'?r.a:r.b,cs=e[1]==='receipt-a'?r.ca:r.cb,receipt=e[4],audit=receipt[6];assert.deepEqual(receipt[4],JSON.parse(JSON.stringify(frame(c)),(_,v)=>typeof v==='number'?String(v):v));assert.deepEqual(receipt[5],cs);assert.equal(receipt[3],'independent-native-audit');assert.equal(audit[3],'meaning-altered');
   const want=[['reported-request',['path',c.target,'revised']],...['choice','inspection','recovery'].map((role,j)=>['retain',c.target,c.target==='artifact'?'person':'person-two',role,['choose','inspect','recover'][j]])];
   const actual=cs.flatMap(t=>{const m=meanings(c,t);assert(m);return m}),missing=want.filter(x=>!set(actual).has(JSON.stringify(x)));assert.equal(missing.length,1);assert.equal(missing[0][3],'inspection');assert.deepEqual(set(audit[4][1][4].map(x=>x[1])),set(want));assert.deepEqual(set(audit[6][1].filter(x=>x[0]==='omitted-meaning').map(x=>x[1])),set(missing));
   assert(e[2].every(x=>x[3].some(y=>y[1]==='SharedUnderstanding')));walk(audit,p=>{if(p[0]==='root'){const n=c.nodes.find(n=>n[1]===p[1]);assert(n);assert.equal(n[2],p[3]);assert.equal(n[5],p[2])}});
  }}
 }}
 for(const m of mods){assert.equal(runs.canonical['module-'+m.id],m.expected);assert.deepEqual(runs.restored['module-'+m.id],m.expected)}
 assert.equal(runs['sever-source']['self-claims'][3][0],'development-opportunity');assert.equal(runs['sever-revalidation']['tampered-candidate'][3][0],'development-opportunity');assert.equal(runs['sever-family']['same-family-new-audit'][3][0],'development-opportunity');
 const call=runs.canonical['trial-call'];assert.equal(call[1],'candidate-quarantined');assert.equal(call[2],'duplicate-trial-id');assert.deepEqual(call[3],['rendering-plan','approved-clause-plan','1']);assert.equal(call[4],'trial-unavailable');assert.equal(call[5],'unproven-candidate-lineage');assert.deepEqual(call,runs.restored['trial-call']);
 for(const r of compilers)for(const v of [0,1]){const id=`compiler-${r.id}-${v}`,result=runs.canonical[id];assert.deepEqual(result,runs.restored[id]);assert.equal(result[2][3],'faithful');const actual=result[1].flatMap(t=>{const m=meanings(r.c,t);assert(m);return m});assert.deepEqual(set(actual),set(r.intended));assert.deepEqual(set(result[2][4][1][4].map(x=>x[1])),set(r.intended));}
 return {status:'PASS-BOUNDED',opportunity_cases:rows.length,module_schema_cases:mods.length,compiler_cases:compilers.length*2,trial_callability_checks:5,arms:Object.keys(runs),scope:'Synthetic finite inputs, recomputed native audits plus separate source/meaning oracle; no candidate-quality trial, promotion or model call.'};
}
