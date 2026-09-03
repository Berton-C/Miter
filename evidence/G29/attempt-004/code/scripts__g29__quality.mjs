// Native causal controls over the accepted model candidate; no service execution.
import fs from 'node:fs';import assert from 'node:assert/strict';import {root,read,save,native,sexp} from '../g22_v2/common.mjs';
const tag=process.argv[2]??'001',dir=root+'/evidence/G29/attempt-'+tag,final=read(dir+'/final.json').native;
const design=final[1],qualified=final[2],candidate=qualified[1],scan=qualified[3],syntax=qualified[4];
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const reversed=structuredClone(candidate);reversed[6]=[...reversed[6]].reverse();
const missing=structuredClone(candidate);missing[5][8]=missing[5][8].filter(x=>x!=='cursor');
const direct=structuredClone(candidate);direct[6][0][2]+='\n% direct chroma access';
const badScan=['surface-candidate-scan',candidate[2],[['forbidden-core-access',direct[6][0][1],'chroma']],[],'exact-files'];
const expr=`!(result canonical (SXAssess ${sexp(design)} ${sexp(candidate)} ${sexp(scan)} ${sexp(syntax)}))\n`+
 `!(result neutral-order (SXAssess ${sexp(design)} ${sexp(reversed)} ${sexp(scan)} ${sexp(syntax)}))\n`+
 `!(result missing-identity (SXAssess ${sexp(design)} ${sexp(missing)} ${sexp(scan)} ${sexp(syntax)}))\n`+
 `!(result direct-core (SXAssess ${sexp(design)} ${sexp(direct)} ${sexp(badScan)} ${sexp(syntax)}))\n`+
 `!(result syntax-failure (SXAssess ${sexp(design)} ${sexp(candidate)} ${sexp(scan)} (surface-candidate-syntax 1 false)))`;
const rows=native(dir,'candidate-controls',expr,boot),map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.equal(map.canonical[0],'surface-candidate-qualified');assert.equal(map['neutral-order'][0],'surface-candidate-qualified');
for(const k of ['missing-identity','direct-core','syntax-failure'])assert.equal(map[k][0],'surface-candidate-unqualified',k);
save(dir+'/quality-verdict.json',{status:'PASS-BOUNDED',canonical_qualified:true,neutral_file_order_preserved:true,
 missing_identity_rejected:true,direct_chroma_or_soul_access_rejected:true,syntax_failure_rejected:true,model_calls_added:0,
 limits:'Finite manifest/source/syntax qualification; behavior awaits G30 independent mock tests'});
console.log(JSON.stringify(read(dir+'/quality-verdict.json')));
