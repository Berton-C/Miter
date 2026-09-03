// Independent finite-language oracle. No result is supplied to the runtime.
import assert from 'node:assert/strict';import {verify as languageVerify,walk} from '../sc04/verify.mjs';
const key=JSON.stringify;export const set=x=>new Set(x.map(key));
const role={choose:'choice',inspect:'inspection',restore:'recovery',recover:'recovery'};
export function meanings(c,raw){
 const t=raw.trim().replace(/\.$/u,'').toLowerCase();let m,kind,person,artifact,verbs;
 if((m=/^(?:you requested revision of|the requested change is to revise) (?:the )?([\p{L}\p{N}_-]+)$/u.exec(t))){kind='reported-request';artifact=m[1]}
 else if((m=/^the revision of (?:the )?([\p{L}\p{N}_-]+) is complete$/u.exec(t))){kind='completion';artifact=m[1]}
 else if((m=/^i will revise (?:the )?([\p{L}\p{N}_-]+)$/u.exec(t))){kind='system-promise';artifact=m[1]}
 else if((m=/^please revise (?:the )?([\p{L}\p{N}_-]+)$/u.exec(t))){kind='unreported-instruction';artifact=m[1]}
 else {
   const forms=[[/^([\p{L}\p{N}_-]+) must remain able to (.+)$/u,'retain'],[/^the change must keep ([\p{L}\p{N}_-]+) able to (.+)$/u,'retain'],[/^([\p{L}\p{N}_-]+) may (.+)$/u,'permission'],[/^([\p{L}\p{N}_-]+) no longer needs to (.+)$/u,'release']];
   for(const [re,k]of forms)if((m=re.exec(t))){kind=k;person=m[1];const tail=/^(.+) (?:the )?([\p{L}\p{N}_-]+)$/u.exec(m[2]);if(!tail)return null;artifact=tail[2];verbs=tail[1].replace(/ the$/,'').split(' and ');break;}
 }
 if(!kind)return null;
 const names=c.nodes.filter(n=>n[2]==='human-confirmation'&&n[6][0]==='named').map(n=>n[6]);
 const lookup=(alias,k)=>{const ids=[...new Set(names.filter(x=>x[1]===alias&&x[2]===k).map(x=>x[3]))];return ids.length===1?ids[0]:null};
 const a=lookup(artifact,'artifact');if(!a||a!==c.target)return null;
 if(!person)return [[kind,['path',a,'revised']]];
 const p=lookup(person,'person');if(!p||!verbs.every(v=>role[v]))return null;
 const claims=[];for(const v of verbs){const r=role[v],ends=[...new Set(c.nodes.filter(n=>n[2]==='human-confirmation'&&n[6][0]==='interface'&&n[6][1]===a&&n[6][2]===r).map(n=>n[6][3]))];if(ends.length!==1)return null;claims.push(kind==='release'?['release',['language-obligation',a,p,r]]:[kind,a,p,r,ends[0]])}return claims;
}
export function verify(row,result){
 assert.equal(result[0],'voice-test-result');const [,g,i,a,d,request]=result;languageVerify(row.c,g);
 if(row.intended===null){assert.equal(i[0],'voice-inquiry');assert.equal(a[0],'voice-fault');assert.equal(d[0],'expression-revalidation');return {id:row.id,status:'inquiry'}}
 assert.equal(i[0],'voice-intention');assert.equal(i.length,7);assert.deepEqual(i[2],row.c.scope);assert.deepEqual(set(i[4].map(e=>e[1])),set(row.intended));
 assert.deepEqual(i[5][1],g[4][2]);assert.equal(i[6],row.c.expected==='complete'?'completed':row.c.expected==='no-plan'?'incomplete':'candidate-available');
 assert.equal(request[0],'render-request');assert.deepEqual(request[7],i[4].map(e=>e[1]).filter((x,j,xs)=>xs.findIndex(y=>key(y)===key(x))===j));
 assert(!key(request).includes('journal'));assert(!key(request).includes('external-contact')); // minimal names/relations, not raw proof cone
 if(key(row.current)!==key(row.c.scope)||key(row.candidateScope)!==key(row.current)){assert.equal(a[0],'voice-revalidation-required');assert.equal(d[0],'expression-revalidation');return {id:row.id,status:'revalidation'}}
 assert.equal(a[0],'voice-audit');assert.equal(a.length,7);assert.deepEqual(a[4][1],i);
 const actual=[],unresolved=[];row.clauses.forEach((text,j)=>{const ms=meanings(row.c,text),read=a[5][1][j];assert.equal(read[0],'expression-reading');assert.equal(read[1],String(j));assert.equal(read[5],'rendering-not-authority');
   const chars=Array.from(text),start=chars.findIndex(x=>!/\s/u.test(x));let end=chars.length;while(end&&/\s/u.test(chars[end-1]))end--;assert.deepEqual(read[2],['span',String(Math.max(start,0)),String(end)]);
   if(ms){assert.equal(read[4][0],'expression-meanings');assert.deepEqual(set(read[4][1].map(x=>x[1])),set(ms));actual.push(...ms)}else unresolved.push(j);
 });
 assert.equal(a[5][1].length,row.clauses.length);const have=set(actual),want=set(row.intended),missing=row.intended.filter(x=>!have.has(key(x))),added=actual.filter(x=>!want.has(key(x)));
 const status=unresolved.length?'interpretation-incomplete':missing.length||added.length?'meaning-altered':'faithful';assert.equal(a[3],status);
 const defects=a[6][1],missingKind=unresolved.length?'unverified-meaning':'omitted-meaning';assert.deepEqual(set(defects.filter(x=>x[0]===missingKind).map(x=>x[1])),set(missing));assert.deepEqual(set(defects.filter(x=>x[0]==='unsupported-alteration').map(x=>x[1])),set(added));
 if(unresolved.length)assert(!defects.some(x=>x[0]==='omitted-meaning'));
 for(const x of defects.filter(x=>x[0]==='unsupported-alteration')){const j=Number(x[2][1]);assert(meanings(row.c,row.clauses[j]).some(y=>key(y)===key(x[1])));assert.deepEqual(x[2][2],a[5][1][j][2])}
 walk(a,p=>{if(p[0]==='root'){const n=row.c.nodes.find(n=>n[1]===p[1]);assert(n);assert.equal(n[2],p[3]);assert.equal(n[5],p[2])}});
 assert.equal(d[0],status==='faithful'?'expression-ready':'repair-request');if(status==='faithful')assert.equal(d[2],'no-emission-authority');
 return {id:row.id,status,missing:missing.length,added:added.length,unresolved:unresolved.length};
}
