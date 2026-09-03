// Native resource, target and admission controls over the passing R3 product.
import assert from 'node:assert/strict';
import {root,read,save,native,sexp} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'301';const dir=`${root}/evidence/G29/attempt-${tag}`;
const final=read(`${dir}/final-r3.json`).native,design=final[1],qualified=final[3],candidate=qualified[1],syntax=qualified[4];
const input=read(`${dir}/input.json`).native,resources=input[6],deps=input[4],obs=input[5];
const removed=resources.filter(x=>x[1]!=='nemotron-local');
const ambiguous=structuredClone(resources);ambiguous[0][5]='supported';ambiguous[0][6]='available';
const compactDesign=['surface-design',design[1],'scope','request','contract','api','prior','grant',design[8],'obligations','basis'];
const compactCandidate=structuredClone(candidate);compactCandidate[3]='rationale';compactCandidate[4]='plan';compactCandidate[6][0][2]='bridge-source';compactCandidate[6][0][3]='bridge-hash';compactCandidate[6][1][2]='tests-source';compactCandidate[6][1][3]='tests-hash';
const reversedCandidate=structuredClone(compactCandidate);reversedCandidate[6]=[...reversedCandidate[6]].reverse();
const scan=['surface-candidate-scan','mattermost-r3',[],[],'exact-files'],badScan=['surface-candidate-scan','mattermost-r3',[['forbidden-core-access','extension/mattermost_bridge.pl','chroma']],[],'exact-files'];
const trial=['surface-candidate-trial',0,0,0,false,'','', 'exit-zero'];
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const rows=native(dir,'r3-quality-controls',
  `!(result resource (SXSelectResource ${sexp(resources)}))\n`+
  `!(result resource-reordered (SXSelectResource ${sexp([...resources].reverse())}))\n`+
  `!(result resource-removed (SXSelectResource ${sexp(removed)}))\n`+
  `!(result resource-ambiguous (SXSelectResource ${sexp(ambiguous)}))\n`+
  `!(result targets (SXRepairTargets ${sexp(deps)} ${sexp(obs)}))\n`+
  `!(result canonical (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(scan)} ${sexp(syntax)} ${sexp(trial)} (bridge tests)))\n`+
  `!(result reordered (SXAssessR2 ${sexp(compactDesign)} ${sexp(reversedCandidate)} ${sexp(scan)} ${sexp(syntax)} ${sexp(trial)} (tests bridge)))\n`+
  `!(result direct-core (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(badScan)} ${sexp(syntax)} ${sexp(trial)} (bridge tests)))\n`+
  `!(result syntax-failure (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(scan)} (surface-candidate-syntax 1 0 false) ${sexp(trial)} (bridge tests)))\n`+
  `!(result test-failure (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(scan)} ${sexp(syntax)} (surface-candidate-trial 1 1 1 false "" "error" exit-one) (bridge tests)))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.equal(map.resource[1],'nemotron-local');assert.equal(map['resource-reordered'][1],'nemotron-local');
assert.equal(map['resource-removed'][0],'model-resource-unresolved');assert.equal(map['resource-ambiguous'][0],'model-resource-unresolved');
assert.deepEqual(new Set(map.targets),new Set(['bridge','tests']));
for(const key of ['canonical','reordered'])assert.equal(map[key][0],'surface-candidate-qualified-r2',key);
for(const key of ['direct-core','syntax-failure','test-failure'])assert.equal(map[key][0],'surface-candidate-unqualified-r2',key);
save(`${dir}/quality-verdict.json`,{status:'PASS-BOUNDED',native_resource_pivot:true,reordering_neutral:true,removal_holds:true,ambiguity_unresolved:true,
  evidence_selected_targets:true,direct_core_rejected:true,syntax_failure_rejected:true,test_failure_rejected:true,model_calls_added:0,
  limits:'Finite G29 candidate authorship/qualification; G30 mock service behavior remains unproven'});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
