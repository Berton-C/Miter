// Builder-only deterministic compaction of generated G33 R2 evidence.
// Retains failure causes and raw provider/native products while removing only
// duplicated synthetic runtime inputs already retained in canonical sources.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import assert from 'node:assert/strict';
import {root} from '../fidelity/check.mjs';

const evidence=path.join(root,'evidence/G33/R2');
assert.equal(path.resolve(evidence),'/Users/claritymiter/miter/evidence/G33/R2');

const modelFiles=id=>[
  `model-${id}/continuity.metta`,`model-${id}/continuity.stdout`,
  `model-${id}/continuity.stderr`,`model-${id}/continuity-process.json`,
  `model-${id}/runtime/context.json`,
  `model-${id}/runtime/outputs/continuity-reading-template.json`,
  `model-${id}/runtime/outputs/continuity-reading-request.json`,
  `model-${id}/runtime/outputs/continuity-reading-raw.json`,
  `model-${id}/runtime/outputs/continuity-reading-timing.json`,
  `model-${id}/runtime/outputs/continuity-reading-typed.json`,
  `model-${id}/runtime/outputs/capsule.json`,
  `model-${id}/runtime/outputs/capsule-event-witness.json`,
  `model-${id}/runtime/outputs/answer.json`
];
const trajectoryFiles=[
  'ground-trajectory-severed/ground.metta','ground-trajectory-severed/ground.stdout',
  'ground-trajectory-severed/ground.stderr','ground-trajectory-severed/ground-process.json',
  'ground-trajectory-severed/runtime/context.json',
  'ground-trajectory-severed/runtime/outputs/continuity-reading-typed.json',
  'ground-trajectory-severed/runtime/outputs/capsule.json',
  'ground-trajectory-severed/runtime/outputs/answer.json'
];
const shared=['opening.json','runner-failure.json'];
const keep={
  'attempt-001':[...shared,
    'model-r1-transfer/continuity.metta','model-r1-transfer/continuity.stdout',
    'model-r1-transfer/continuity.stderr','model-r1-transfer/continuity-process.json',
    'model-r1-transfer/runtime/context.json',
    'model-r1-transfer/runtime/outputs/startup.json',
    'model-r1-transfer/runtime/outputs/restart-intent.json',
    'model-r1-transfer/runtime/outputs/request-intent.json'],
  'attempt-002':[...shared,...modelFiles('r1-transfer')],
  'attempt-003':[...shared,...modelFiles('r1-transfer'),...modelFiles('g11-exact-regression'),
    ...trajectoryFiles],
  'attempt-004':[...shared,...modelFiles('r1-transfer'),...modelFiles('g11-exact-regression'),
    ...trajectoryFiles,'provider-off/provider-off.metta','provider-off/provider-off.stdout',
    'provider-off/provider-off.stderr','provider-off/provider-off-process.json',
    'provider-off/runtime/context.json','provider-off/runtime/outputs/startup.json'],
  'attempt-005':['opening.json','observations.json','freeze.json','verdict.json',
    ...modelFiles('r1-transfer'),...modelFiles('g11-exact-regression')]
};

for(const [attempt,files] of Object.entries(keep)){
  const source=path.join(evidence,attempt);assert(fs.existsSync(source),source);
  const temporary=fs.mkdtempSync(path.join(os.tmpdir(),`miter-${attempt}-`));
  for(const rel of files){
    const from=path.join(source,rel);
    if(!fs.existsSync(from))continue;
    const to=path.join(temporary,rel);fs.mkdirSync(path.dirname(to),{recursive:true});
    fs.copyFileSync(from,to);
  }
  fs.rmSync(source,{recursive:true});
  fs.renameSync(temporary,source);
}

const final=path.join(evidence,'attempt-006');
assert(fs.existsSync(final),final);
for(const entry of fs.readdirSync(final,{withFileTypes:true})){
  if(!entry.isDirectory())continue;
  if(entry.name.startsWith('parse-')||entry.name.startsWith('native-')||
     entry.name==='ground-zero-project'||entry.name==='ground-ambiguous-project'){
    for(const leaf of ['store','capsules']){
      const target=path.join(final,entry.name,'runtime',leaf);
      if(fs.existsSync(target))fs.rmSync(target,{recursive:true});
    }
  }
}

console.log(JSON.stringify({status:'COMPACTED-GENERATED-EVIDENCE',attempts:Object.keys(keep),
  final_attempt:'attempt-006'}));
