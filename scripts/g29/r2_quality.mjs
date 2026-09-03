// Native causal controls for repair selection and revised candidate admission.
import assert from 'node:assert/strict';
import {root,read,save,native,sexp} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'210';assert.match(tag,/^2[0-9]{2}$/);
const dir=`${root}/evidence/G29/attempt-${tag}`;
const final=read(`${dir}/final-r2.json`).native;
const design=final[1],qualified=final[2],candidate=qualified[1],scan=qualified[3],syntax=qualified[4],trial=qualified[5];
const input=read(`${dir}/input.json`).native;
const deps=input[4],obs=input[5];
const bridgeObs=obs.filter(x=>['syntax','public-export'].includes(x[2]));
const testsObs=obs.filter(x=>['plunit-structure','public-contract-exercise'].includes(x[2]));
const unknown=[['obligation-observation','unknown','unrelated-obligation','unresolved','no-contact']];
const severed=deps.filter(x=>x[1]!=='tests');
const boot=`!(import! &self "${root}/src/bootstrap_surface_extension_v1.metta")\n`;
const rows=native(dir,'repair-target-controls',
  `!(result canonical (SXRepairTargets ${sexp(deps)} ${sexp(obs)}))\n`+
  `!(result reordered (SXRepairTargets ${sexp([...deps].reverse())} ${sexp([...obs].reverse())}))\n`+
  `!(result bridge-only (SXRepairTargets ${sexp(deps)} ${sexp(bridgeObs)}))\n`+
  `!(result tests-only (SXRepairTargets ${sexp(deps)} ${sexp(testsObs)}))\n`+
  `!(result unknown (SXRepairTargets ${sexp(deps)} ${sexp(unknown)}))\n`+
  `!(result severed (SXRepairTargets ${sexp(severed)} ${sexp(obs)}))`,boot);
const map=Object.fromEntries(rows.map(x=>[x[1],x[2]]));
assert.deepEqual(new Set(map.canonical),new Set(['bridge','tests']));
assert.deepEqual(new Set(map.reordered),new Set(['bridge','tests']));
assert.deepEqual(map['bridge-only'],['bridge']);
assert.deepEqual(map['tests-only'],['tests']);
assert.deepEqual(map.unknown,[]);
assert.deepEqual(map.severed,['bridge']);

const compactDesign=['surface-design',design[1],'scope','request','contract','api','prior','grant',design[8],'obligations','basis'];
const compactCandidate=structuredClone(candidate);
compactCandidate[3]='rationale';compactCandidate[4]='plan';
compactCandidate[6][0][2]='bridge-source';compactCandidate[6][0][3]='bridge-hash';
compactCandidate[6][1][2]='tests-source';compactCandidate[6][1][3]='tests-hash';
const compactScan=['surface-candidate-scan','mattermost-r2',[],[],'exact-files'];
const badScan=['surface-candidate-scan','mattermost-r2',[['forbidden-core-access','extension/mattermost_bridge.pl','chroma']],[],'exact-files'];
const compactTrial=['surface-candidate-trial',0,0,0,false,'','', 'exit-zero'];
const reorderedCandidate=structuredClone(compactCandidate);reorderedCandidate[6]=[...reorderedCandidate[6]].reverse();
const controls=native(dir,'repair-admission-controls',
  `!(result canonical (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(compactScan)} ${sexp(syntax)} ${sexp(compactTrial)} (bridge tests)))\n`+
  `!(result reordered (SXAssessR2 ${sexp(compactDesign)} ${sexp(reorderedCandidate)} ${sexp(compactScan)} ${sexp(syntax)} ${sexp(compactTrial)} (tests bridge)))\n`+
  `!(result direct-core (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(badScan)} ${sexp(syntax)} ${sexp(compactTrial)} (bridge tests)))\n`+
  `!(result syntax-failure (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(compactScan)} (surface-candidate-syntax 1 0 false) ${sexp(compactTrial)} (bridge tests)))\n`+
  `!(result test-failure (SXAssessR2 ${sexp(compactDesign)} ${sexp(compactCandidate)} ${sexp(compactScan)} ${sexp(syntax)} (surface-candidate-trial 1 1 1 false "" "error" exit-one) (bridge tests)))`,boot);
const cm=Object.fromEntries(controls.map(x=>[x[1],x[2]]));
for(const key of ['canonical','reordered'])assert.equal(cm[key][0],'surface-candidate-qualified-r2',key);
for(const key of ['direct-core','syntax-failure','test-failure'])assert.equal(cm[key][0],'surface-candidate-unqualified-r2',key);
save(`${dir}/quality-verdict.json`,{status:'PASS-BOUNDED',evidence_selected_targets:true,reordering_neutral:true,unknown_not_violation:true,
  severed_dependency_defeats_target:true,restored_targets:true,direct_core_rejected:true,syntax_failure_rejected:true,test_failure_rejected:true,
  model_calls_added:0,limits:'Finite G29 authored-candidate qualification; G30 mock behavior remains separate'});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
