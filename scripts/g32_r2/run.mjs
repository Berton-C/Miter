// G32 R2: execute actual current consumers under predeclared one-variable cuts.
// Builder code launches/captures/compares only; it never emits a native standing.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp,swi} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G32/R2/attempt-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/failure.json`,{status:'FAIL',message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,model_calls:0,external_effects:0,
    persistent_runtime_mutations:0});
  console.error(error.stack);process.exitCode=1;
});
const opening=checkOpen('docs/gates/G32/R2/plan.json');
assert.equal(opening.plan_commit,'596de65bd3a910686e36816bb8c87b3a346189c4');
save(`${dir}/opening.json`,opening);

const fixture='tests/fixtures/g32_r2/consumers.metta';
const boot=`!(import! &self "${root}/${fixture}")\n`;
const one=(label,expr,entry=boot)=>{
  const rows=native(dir,label,`!(result product ${expr})`,entry);
  assert.equal(rows.length,1,label);return rows[0][2];
};

const observations={};
observations.soul={
  canonical:one('soul-canonical','(SoulRationalityAudit)'),
  severed:one('soul-severed','(SoulRationalityAudit)',
    `!(import! &self "${root}/tests/fixtures/g32_r2/soul_severed.metta")\n`),
  restored:one('soul-restored','(SoulRationalityAudit)')};
observations['memory-capsule']={
  canonical:one('capsule-canonical','(ContinuityRNA g32r2-context live)'),
  severed:one('capsule-severed','(ContinuityRNA g32r2-context capsule-off)'),
  restored:one('capsule-restored','(ContinuityRNA g32r2-context live)')};
observations.chroma={
  canonical:one('chroma-canonical','(ContinuityRNA g32r2-context live)'),
  severed:one('chroma-severed','(ContinuityRNA g32r2-context chroma-off)'),
  restored:one('chroma-restored','(ContinuityRNA g32r2-context live)')};
observations.voiceaudit={
  canonical:one('voice-canonical','(G32R2Voice effect-hash effect-hash)'),
  severed:one('voice-severed','(G32R2Voice effect-hash different-effect-hash)'),
  restored:one('voice-restored','(G32R2Voice effect-hash effect-hash)')};
observations.vad={
  canonical:one('vad-canonical','(VADCue g32r2-vad exact-then-morphology)'),
  severed:one('vad-severed','(VADCue g32r2-vad-off lexicon_off)'),
  restored:one('vad-restored','(VADCue g32r2-vad exact-then-morphology)')};
observations.nace={
  canonical:one('nace-canonical','(NRevision (stv 0.5 0.5) (stv 1 0.5))'),
  severed:one('nace-severed','(G32R2NaceImportStanding)',
    `!(import! &self "${root}/tests/fixtures/g32_r2/nace_severed.metta")\n`),
  restored:one('nace-restored','(NRevision (stv 0.5 0.5) (stv 1 0.5))')};
observations.consequence={
  canonical:one('consequence-canonical','(NRevision (stv 0.5 0.5) (stv 1 0.5))'),
  severed:one('consequence-severed','(NRevision (stv 0.5 0.5) (stv 0 0))'),
  restored:one('consequence-restored','(NRevision (stv 0.5 0.5) (stv 1 0.5))')};
observations['workshop-containment']={
  canonical:one('workshop-canonical','(G30TrialStanding candidate candidate quarantined none none)'),
  severed:one('workshop-severed','(G30TrialStanding candidate candidate quarantined prohibited none)'),
  restored:one('workshop-restored','(G30TrialStanding candidate candidate quarantined none none)')};

const resumeBoot=`!(import! &self "${root}/tests/fixtures/g32_r2/resume.metta")\n`;
observations['continuity-lineage']={
  canonical:one('resume-canonical','(DRResume resume-canonical)',resumeBoot),
  severed:one('resume-severed','(DRResume resume-lineage-severed)',resumeBoot),
  restored:one('resume-restored','(DRResume resume-canonical)',resumeBoot)};

function identity(label,mode){
  const p=spawnSync(swi,['-q','-s',`${root}/scripts/g32_r2/identity_probe.pl`,'--',mode],
    {cwd:root,encoding:'utf8',timeout:30000,maxBuffer:4*1024*1024});
  save(`${dir}/${label}.stdout`,p.stdout??'');save(`${dir}/${label}.stderr`,p.stderr??'');
  save(`${dir}/${label}-process.json`,{status:p.status,signal:p.signal});
  assert.equal(p.status,0,label);assert.equal(p.stderr,'',label);
  return JSON.parse(p.stdout);
}
observations['mattermost-identity']={
  canonical:identity('identity-canonical','canonical'),
  severed:identity('identity-severed','severed'),
  restored:identity('identity-restored','canonical')};

// Reuse admitted synthetic receipts, but recompute them inside the current CStep/DRead
// consumer on every arm. The prior file is input provenance, never an inherited pass.
const developmentInput='evidence/SC08/live-001/cycle/input.json';
const developmentReceipts='evidence/SC08/live-001/receipts.json';
const d=read(`${root}/${developmentInput}`),id='g32r2-development';
const state=['development-life',id,d.frame[1],'ready','unseen',d.grant,0,['purpose','unformed'],'none','unresolved'];
const obs=receipts=>['cycle-observation','fixture-fingerprint',d.frame,receipts,d.surfaces,d.grant,'pending','none'];
const developmentBoot=`!(import! &self "${root}/src/bootstrap_development_cycle.metta")\n`;
const step=(label,receipts,surfaces=d.surfaces)=>{
  const observation=['cycle-observation','fixture-fingerprint',d.frame,receipts,surfaces,d.grant,'pending','none'];
  return one(label,`(CStep ${sexp(state)} ${sexp(observation)})`,developmentBoot);
};
observations['endogenous-curiosity']={
  canonical:step('development-canonical',d.receipts),
  severed:step('development-severed',d.receipts.slice(0,1)),
  restored:step('development-restored',d.receipts),
  decorative:step('development-decorative',d.receipts,d.surfaces.concat([['decorative-observation','unconsumed']])),
  neutral:step('development-neutral',d.receipts.toReversed()),
  held_out:step('development-held-out',d.receipts.concat([read(`${root}/${developmentReceipts}`).records[2]]))};

// A model-like product requesting another call is rejoined as data through CStep.
const pending=observations['endogenous-curiosity'].canonical[1];
const product=['product',['rendered-candidate',['request','invoke-oracle-again']],'model-candidate-bound'];
const rejoin=['cycle-observation','fixture-fingerprint',d.frame,d.receipts,d.surfaces,d.grant,product,'none'];
observations['non-recursive']={product:one('non-recursive',`(CStep ${sexp(pending)} ${sexp(rejoin)})`,developmentBoot),
  oracle_calls:1,recursive_oracle_calls:0};

observations['zero-pitch-perpetual-loop']={
  product:one('zero-pitch','(G32R2ZeroPitch)'),model_calls:0,external_effects:0};

save(`${dir}/observations.json`,observations);
const sourceFiles=[fixture,'tests/fixtures/g32_r2/soul_severed.metta',
  'tests/fixtures/g32_r2/nace_severed.metta','tests/fixtures/g32_r2/resume.metta',
  'scripts/g32_r2/identity_probe.pl','scripts/g32_r2/run.mjs',developmentInput,developmentReceipts,
  'docs/gates/G32/R2/plan.json','docs/gates/G32/R2/expected-consumer-matrix.json'];
save(`${dir}/freeze.json`,{schema:'miter-g32-r2-execution-freeze-v1',
  files:pins(sourceFiles.map(file=>`${root}/${file}`)),
  consumer_products_drive_matrix:true,builder_availability_standings:false,
  network_requests:0,credential_lookups:0,model_calls:0,external_effects:0,
  persistent_runtime_mutations:0});
console.log(JSON.stringify({status:'OBSERVED',consumers:Object.keys(observations).length}));
