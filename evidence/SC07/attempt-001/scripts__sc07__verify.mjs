// Independent finite oracle; enumerates subsets of realized fragments, not the
// native missing-relation agenda. No oracle result enters runtime arguments.
import assert from 'node:assert/strict';import {meanings,set} from '../sc05/verify.mjs';
const key=JSON.stringify,subset=(a,b)=>a.every(x=>set(b).has(key(x))),equal=(a,b)=>subset(a,b)&&subset(b,a);
const role={choice:'choose',inspection:'inspect',recovery:'restore'};
export function options(row){
 const expected=row.intended;if(!expected)return [];
 const names=row.c.nodes.filter(n=>n[2]==='human-confirmation'&&n[6][0]==='named').map(n=>n[6]);const name=id=>names.find(n=>n[3]===id)?.[1]??'unresolved-name';
 const fragments=[];for(const c of row.m.constructions){let groups=[];const relevant=expected.filter(x=>x[0]===c.meaning);if(c.meaning==='retain'){for(let mask=1;mask<2**relevant.length;mask++){const claims=relevant.filter((_,i)=>mask&(1<<i));if(claims.every(x=>x[1]===claims[0][1]&&x[2]===claims[0][2]))groups.push(claims)}}else groups=relevant.map(x=>[x]);
 for(const claims of groups){const verbs=claims.map(x=>role[x[3]]).join(' and '),slots={'@artifact':name(row.c.target),'@person':claims[0][0]==='retain'?name(claims[0][2]):'unresolved-slot','@verbs':claims[0][0]==='retain'?verbs:'unresolved-slot','@verb':claims.length===1&&claims[0][0]==='retain'?verbs:'unresolved-group'},text=c.tokens.map(t=>slots[t]??t).join(' ')+'.',actual=meanings(row.c,text);if(actual&&equal(actual,claims))fragments.push({id:c.id,text,claims})}}
 const results=[];function enumerate(n,chosen,covered){if(equal(covered,expected)){if(!row.jointClaims.length||chosen.some(f=>subset(row.jointClaims,f.claims)))results.push(chosen);return}for(let j=n;j<fragments.length;j++){const f=fragments[j];if(f.claims.some(x=>set(covered).has(key(x))))continue;enumerate(j+1,[...chosen,f],[...covered,...f.claims])}}enumerate(0,[],[]);return results;
}
export const signature=fs=>key(fs.map(f=>({claims:[...set(f.claims)].sort(),text:f.text.toLowerCase()})).sort((a,b)=>key(a).localeCompare(key(b))));
export function verify(row,r){
 assert.equal(r[0],'result');const result=r[1],eligible=r[2];assert.equal(eligible[0],row.expected,row.id);
 if(['construction-rejected','construction-inquiry'].includes(row.expected))return {id:row.id,status:eligible[0]};
 assert.equal(result[0],'expression-construction');assert.deepEqual(set(result[1][4].map(e=>e[1])),set(row.intended));
 const fragments=result[2][1];for(const f of fragments){assert(['expression-fragment','unqualified-fragment'].includes(f[0]));const actual=meanings(row.c,f[3]);assert.equal(f[0]==='expression-fragment',!!actual&&equal(actual,f[2]),row.id+' fragment verification');}
 if(['expression-context-incomplete','expression-search-incomplete'].includes(row.expected)){if(row.expected==='expression-search-incomplete')assert(eligible[2].length>0);return {id:row.id,status:eligible[0]}}
 const actual=result[4][1].filter(x=>x[0]==='supported-expression');for(const x of actual){assert.equal(x[3][1][3],'faithful');assert.deepEqual(set(x[2].flatMap(f=>meanings(row.c,f[3])??[])),set(row.intended));if(row.jointClaims.length)assert(x[2].some(f=>subset(row.jointClaims,f[2])))}
 const expected=options(row),observed=actual.map(x=>signature(x[2].map(f=>({claims:f[2],text:f[3]}))));assert.deepEqual(new Set(observed),new Set(expected.map(signature)),row.id+' complete possibility set');
 if(row.expected==='supported-expression-alternatives'){assert.equal(eligible[2],'no-emission-authority');assert.deepEqual(eligible[1],actual);assert(actual.length>0)}else assert.equal(actual.length,0);
 return {id:row.id,status:eligible[0],options:actual.length};
}
