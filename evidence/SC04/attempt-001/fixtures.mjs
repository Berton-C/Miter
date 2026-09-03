// Offline test data, not a runtime interpreter. Expected products are separate.
import fs from 'node:fs';
import {root} from '../fidelity/check.mjs';
export const clone=x=>structuredClone(x);
export function base(){
 const b=JSON.parse(fs.readFileSync(root+'/tests/fixtures/sc01/cases.json'));
 const scope=b.scope,rows=[];
 function row(id,kind,payload){rows.push(['node',id,kind,[scope[2]],scope[3],'v1',payload,[]])}
 b.state.forEach((e,i)=>row('edge-'+i,'external-contact',e));
 row('name-person','human-confirmation',['named','mara','person','person']);
 row('name-artifact','human-confirmation',['named','ledger','artifact','artifact']);
 row('name-other','human-confirmation',['named','journal','artifact','other-artifact']);
 for(const [role,end] of [['choice','choose'],['inspection','inspect'],['recovery','recover']])row('interface-'+role,'human-confirmation',['interface','artifact',role,end]);
 row('request-source','human-confirmation',['utterance','artifact','Please revise ledger.']);
 row('commitment-source','human-confirmation',['utterance','artifact','Keep mara able to choose and inspect and restore ledger.']);
 return {scope,nodes:rows,registry:rows.map(n=>['observation',...n.slice(1,7)]),current:rows.map(n=>['at',n[1],n[5]]),operations:b.operations,target:'artifact',budget:2,proposals:[]};
}
export function replaceText(c,id,text){for(const rs of [c.nodes,c.registry])rs.find(x=>x[1]===id)[6][2]=text;return c;}
export function append(c,id,text,target='artifact',kind='human-confirmation'){
 const n=['node',id,kind,[c.scope[2]],c.scope[3],'v1',['utterance',target,text],[]];c.nodes.push(n);c.registry.push(['observation',...n.slice(1,7)]);c.current.push(['at',id,'v1']);return c;
}
export const sexp=x=>Array.isArray(x)?'('+x.map(sexp).join(' ')+')':typeof x==='string'&&(!/^[A-Za-z0-9_-]+$/.test(x))?JSON.stringify(x):String(x);
export function parse(line){const t=line.match(/"(?:\\.|[^"\\])*"|\(|\)|[^\s()]+/gu)??[];let i=0;function one(){const x=t[i++];if(x==='('){const a=[];while(t[i]!==')'){if(i>=t.length)throw Error('unterminated native result');a.push(one())}i++;return a}return x?.startsWith('"')?JSON.parse(x):x}const x=one();if(i!==t.length)throw Error('trailing native result');return x;}
