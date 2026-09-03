// Native assembly controls over decomposed products; no candidate service use.
import assert from 'node:assert/strict';import {root,read,save,native,sexp} from '../g22_v2/common.mjs';
const tag=process.argv[2]??'103',dir=root+'/evidence/G29/attempt-'+tag,final=read(dir+'/final-r1.json').native,design=final[1],qualified=final[2],candidate=qualified[1],scan=qualified[3],syntax=qualified[4];
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
// Project the exact candidate into a compact native causal fixture. The real
// bytes and hashes are checked independently by r1_verify; MeTTa only needs the
// fields consumed by SXAssess. This also prevents long hexadecimal strings that
// begin with a digit from being parsed as overflowing numeric literals.
const compactDesign=['surface-design',design[1],'scope-fixture','request-fixture','contract-fixture','api-fixture','prior-fixture','grant-fixture',design[8],'obligations-fixture','basis-fixture'];
const compactCandidate=structuredClone(candidate);compactCandidate[3]='rationale-fixture';compactCandidate[4]='plan-fixture';
compactCandidate[6][0][2]='bridge-source';compactCandidate[6][0][3]='bridge-hash';compactCandidate[6][1][2]='tests-source';compactCandidate[6][1][3]='tests-hash';
const reversed=structuredClone(compactCandidate);reversed[6]=[...reversed[6]].reverse();
const missing=structuredClone(compactCandidate);missing[5][8]=missing[5][8].filter(x=>x!=='cursor');
const direct=structuredClone(compactCandidate);direct[6][0][2]+='-forbidden-core-import-marker';
const compactScan=['surface-candidate-scan',compactCandidate[2],[],[],'exact-files'];
const badScan=['surface-candidate-scan',compactCandidate[2],[['forbidden-core-access',direct[6][0][1],'chroma']],[],'exact-files'];
const expr=`!(result canonical (SXAssess ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(compactScan)} ${sexp(syntax)}))\n`+
 `!(result neutral-order (SXAssess ${sexp(compactDesign)} ${sexp(reversed)} ${sexp(compactScan)} ${sexp(syntax)}))\n`+
 `!(result missing-identity (SXAssess ${sexp(compactDesign)} ${sexp(missing)} ${sexp(compactScan)} ${sexp(syntax)}))\n`+
 `!(result direct-core (SXAssess ${sexp(compactDesign)} ${sexp(direct)} ${sexp(badScan)} ${sexp(syntax)}))\n`+
 `!(result syntax-failure (SXAssess ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(compactScan)} (surface-candidate-syntax 1 0 false)))`;
const rows=native(dir,'candidate-controls-r1',expr,boot),map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.equal(map.canonical[0],'surface-candidate-qualified');assert.equal(map['neutral-order'][0],'surface-candidate-qualified');
for(const k of ['missing-identity','direct-core','syntax-failure'])assert.equal(map[k][0],'surface-candidate-unqualified',k);
const parts=['design-1','bridge-2','tests-3'].map(id=>structuredClone(read(dir+'/'+id+'-observation.json').native));
for(const p of parts)p[10]='{}';
parts[1][11][3][2]='bridge-source';parts[1][11][3][3]='bridge-hash';
parts[2][11][3][2]='tests-source';parts[2][11][3][3]='tests-hash';
const assembly=native(dir,'assembly-controls-r1',
 `!(result restored (SXAssemble ${sexp(compactDesign)} ${sexp(parts[0])} ${sexp(parts[1])} ${sexp(parts[2])}))\n`+
 `!(result severed (SXAssemble ${sexp(compactDesign)} ${sexp(parts[0])} ${sexp(parts[1])} (surface-part-unavailable severed)))`,boot);
const am=Object.fromEntries(assembly.map(x=>[x[1],x[2]]));assert.equal(am.restored[0],'surface-extension-candidate');assert.equal(am.severed[0],'surface-candidate-incomplete');
save(dir+'/quality-verdict.json',{status:'PASS-BOUNDED',canonical_qualified:true,neutral_part_order_preserved:true,missing_product_defeats_assembly:true,
 missing_identity_rejected:true,direct_core_access_rejected:true,syntax_failure_rejected:true,restored_products_qualified:true,model_calls_added:0,
 limits:'Finite source/manifest/syntax qualification; runtime behavior awaits G30'});console.log(JSON.stringify(read(dir+'/quality-verdict.json')));
