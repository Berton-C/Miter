// G32 native observation builder. No network, model, credential, or external effect.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {root,hash,checkOpen} from '../fidelity/check.mjs';
import {native,save,read,pins,sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag=process.argv[2]??'001';assert.match(tag,/^\d{3}$/);
const dir=`${root}/evidence/G32/attempt-${tag}`;
assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',error=>{
  save(`${dir}/failure.json`,{status:'FAIL',message:error.message,stack:error.stack,
    network_requests:0,credential_lookups:0,model_calls:0,external_effects:0});
  console.error(error.stack);process.exitCode=1;
});
const opening=checkOpen('docs/gates/G32/R1/plan.json');
assert.equal(opening.plan_commit,'154cbad8ddef038147ea4f69f9da223a5c892325');
save(`${dir}/opening.json`,opening);

const definitions={
  soul:{consumer:'SoulRationalityAudit',sources:['constitution/soul.metta','src/soul.metta'],evidence:'evidence/20260902T070002Z-G13/verdict.json'},
  'memory-capsule':{consumer:'ContinuityRNA',sources:['src/memory.metta','src/continuity.metta','effect_membranes/miter_continuity.pl'],evidence:'evidence/20260902T063347Z-G11/verdict.json'},
  chroma:{consumer:'RecallRNA',sources:['src/memory.metta','effect_membranes/miter_chroma.pl'],evidence:'evidence/20260902T064155Z-G12/verdict.json'},
  voiceaudit:{consumer:'G31CanaryVoiceCertificate',sources:['src/mattermost_live_canary_v1.metta','src/voice.metta'],evidence:'evidence/G31/p9-916/run-verdict.json'},
  vad:{consumer:'VADCue',sources:['src/vad.metta','effect_membranes/miter_vad.pl'],evidence:'evidence/20260902T071616Z-G15/verdict.json'},
  nace:{consumer:'NRevision',sources:['src/nace_v2.metta','src/nal_revision_v1.metta','effect_membranes/miter_nace_v2.pl'],evidence:'evidence/G24/g25-002/verdict.json'},
  consequence:{consumer:'NApply',sources:['src/nace_v2.metta','src/nace_selection_v1.metta'],evidence:'evidence/G24/g25-002/verdict.json'},
  'endogenous-curiosity':{consumer:'CStep',sources:['src/development_cycle.metta','src/development_evidence.metta','src/development_continuation_v1.metta'],evidence:'evidence/SC08/package-verdict.json'},
  'continuity-lineage':{consumer:'DRResume',sources:['src/development_resume_v1.metta','effect_membranes/miter_development_resume_v1.pl'],evidence:'evidence/G24/g26-003/repair-003/verdict.json'},
  'workshop-containment':{consumer:'WorkshopRequest',sources:['src/workshop_boundary_v1.metta','effect_membranes/miter_workshop_v1.pl'],evidence:'evidence/G27/attempt-004/verdict.json'},
  'mattermost-identity':{consumer:'surface_ingest/5',sources:['evidence/G31/p3-351/candidate/extension/mattermost_bridge.pl','src/mattermost_mock_trial_v1.metta'],evidence:'evidence/G31/p9-916/run-verdict.json'},
  clock:{consumer:'ReactorCycleWith',sources:['src/reactor.metta','effect_membranes/miter_reactor.pl'],evidence:'evidence/20260902T081730Z-G19/verdict.json'},
  oracle:{consumer:'bounded-derived-product',sources:['effect_membranes/miter_llm.pl','src/development_cycle.metta'],evidence:'evidence/SC08/package-verdict.json'}
};
const records=[];
for(const [id,d] of Object.entries(definitions)){
  const sourcePins=pins(d.sources.map(file=>`${root}/${file}`));
  const evidence=read(`${root}/${d.evidence}`);assert.match(evidence.status,/^PASS/);
  const evidenceHash=hash(fs.readFileSync(`${root}/${d.evidence}`));
  const sourceHash=hash(JSON.stringify(sourcePins));
  records.push({id,consumer:d.consumer,sources:sourcePins,evidence:d.evidence,
    evidence_sha256:evidenceHash,source_bundle_sha256:sourceHash});
}
save(`${dir}/participant-sources.json`,{schema:'miter-g32-source-bound-participants-v1',participants:records});
const participantTerm=r=>['participant',r.id,'available',
  ['source-bundle-sha256',r.source_bundle_sha256],
  ['evidence-sha256',r.evidence_sha256],['consumer',r.consumer]];
const canonical=records.map(participantTerm);
const cases=[
  ['g32-case','authenticated-continuity','exact-capsule-continuity',
    ['soul','memory-capsule','mattermost-identity'],['chroma','vad']],
  ['g32-case','certified-expression','voice-effect-eligibility',
    ['soul','voiceaudit','vad','mattermost-identity'],['oracle']],
  ['g32-case','consequence-development','later-selection-change',
    ['soul','consequence','nace'],[]],
  ['g32-case','contained-extension','development-and-trial',
    ['soul','endogenous-curiosity','workshop-containment'],['oracle']],
  ['g32-case','restart-recurring','lineage-and-clock-availability',
    ['soul','memory-capsule','continuity-lineage','clock'],[]]
];
const boot=`!(import! &self "${root}/tests/fixtures/g32/integrated_fixture.metta")\n`;
const probes=native(dir,'current-consumer-probes','!(result probes (G32CurrentProbes))',boot);
assert.equal(probes.length,1);save(`${dir}/current-consumer-probes.json`,{native:probes[0][2]});
const run=(name,participants,{product='ordinary-derived-reading',calls=1,pitch='material-pitch',zero=false,caseRows=cases}={})=>{
  const armDir=`${dir}/${name}`;fs.mkdirSync(armDir);
  let body=`!(result bundle (G32Bundle ${sexp(participants)} ${sexp(caseRows)} 0))\n`+
    `!(result oracle (G32OracleBoundary ${sexp(product)} ${calls}))\n`+
    `!(result clock (G32ClockDisposition ${pitch}))`;
  if(zero)body+='\n!(result zero-cycle (G32ZeroPitchRun))';
  const raw=native(armDir,'run',body,boot),out=Object.fromEntries(raw.map(row=>[row[1],row[2]]));
  save(`${armDir}/observation.json`,out);return out;
};
const observations={canonical:run('canonical',canonical)};
const severed=['soul','memory-capsule','chroma','voiceaudit','vad','nace','consequence',
  'endogenous-curiosity','continuity-lineage','workshop-containment','mattermost-identity'];
for(const id of severed)observations[`${id}-severed`]=run(`${id}-severed`,canonical.filter(row=>row[1]!==id));
for(const id of severed)observations[`restored-${id}`]=run(`restored-${id}`,canonical);
observations['decorative-control']=run('decorative-control',canonical.concat([
  ['participant','decorative-note','available',['source-bundle-sha256','decorative'],
    ['evidence-sha256','decorative'],['consumer','none']]]));
observations['neutral-reordering']=run('neutral-reordering',canonical.toReversed());
observations['non-recursive']=run('non-recursive',canonical,
  {product:['rendered-candidate',['request','invoke-oracle-again']],calls:1});
observations['zero-pitch-perpetual-loop']=run('zero-pitch-perpetual-loop',canonical,
  {pitch:'no-material-pitch',zero:true});
const heldOut=cases.map(row=>structuredClone(row));
for(const row of heldOut)row[2]=['held-out-capacity',row[2]];
observations['held-out-meaning-preserving']=run('held-out-meaning-preserving',canonical,{caseRows:heldOut});
save(`${dir}/observations.json`,observations);
save(`${dir}/freeze.json`,{schema:'miter-g32-r1-execution-freeze-v1',
  files:pins(['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md','ACCEPTANCE.md',
    'WORK_PROTOCOL.md','docs/gates/G31/P9/R1/closure.json','docs/gates/G32/R1/plan.json',
    'docs/gates/G32/R1/expected-arm-matrix.json','tests/fixtures/g32/integrated_fixture.metta',
    'scripts/g32/run.mjs'].map(file=>`${root}/${file}`)),
  participant_sources:records,cases,network_requests:0,credential_lookups:0,
  model_calls:0,external_effects:0,persistent_runtime_mutations:0});
console.log(JSON.stringify({status:'OBSERVED',arms:Object.keys(observations).length}));
