import fs from 'node:fs';
import {root} from '../fidelity/check.mjs';

export const clone=value=>structuredClone(value);
export const sourceFrame=()=>JSON.parse(fs.readFileSync(
  `${root}/evidence/SC07/live-001/frame.json`)).native;

export function withoutJoint(){
  const f=sourceFrame();
  f[2]=f[2].filter(row=>row[1]!=='joint-contact');
  f[3]=f[3].filter(row=>row[1]!=='joint-contact');
  f[4]=f[4].filter(row=>row[1]!=='joint-contact');
  return f;
}

export function withoutMaterialRelation(){
  const f=sourceFrame();
  const direct=f[5].find(row=>row[1]==='direct-change');
  direct[4]=direct[4].filter(edge=>edge[2]!=='recover');
  return f;
}

export function reorderedFrame(){
  const f=sourceFrame();
  f[2].reverse();f[3].reverse();f[4].reverse();
  return f;
}

export function changedScope(){
  const f=sourceFrame();f[1][1]='changed-cut';return f;
}

export function projectCapability(){
  const d=JSON.parse(fs.readFileSync(
    `${root}/evidence/G22/g26-001/accepted/candidate.json`));
  const token=s=>s.startsWith('@')?['slot',s.slice(1)]:['literal',s];
  return ['voice-realization',d.schema,d.candidate_id,d.purpose,
    d.constructions.map(c=>['construction',c.id,c.meaning,c.tokens.map(token)]),
    d.allowed_writes,d.allowed_effects];
}

export function reorderedCapability(){
  const m=projectCapability();m[4].reverse();return m;
}
