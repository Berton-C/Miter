// Builder-owned cases: no claimed blindness. No expected decision enters Miter.
import {cases as prior,joint,frame} from '../sc07/cases.mjs';
import {map} from '../sc06/cases.mjs';
export {frame};
export function cases(){
 const old=prior(),get=id=>structuredClone(old.find(r=>r.id===id));
 const rows=['joint-supported','partial-joint','seed-individual','observed-completion','source-releases-inspection','unicode-names','generated-joint','foreign-joint','stale-joint','no-source-authority','zero-search-grant'].map(get);
 for(const [id,word,person]of [['joint-renamed','manuscript','berton'],['joint-transfer','canvas','yuri']]){
  const r=get('joint-supported');r.id=id;r.c=map(r.c,x=>typeof x==='string'?x.replaceAll('ledger',word).replaceAll('mara',person):x);rows.push(r);
 }
 return rows.map(({id,c,fuel,intended,expected,jointClaims})=>({id,c,fuel,intended,expected,jointClaims}));
}
