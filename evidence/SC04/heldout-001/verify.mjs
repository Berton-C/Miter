// Independent finite-evidence checker. It never supplies a native premise.
import assert from 'node:assert/strict';
export const walk=(x,f)=>{if(Array.isArray(x)){f(x);x.forEach(v=>walk(v,f))}};
const key=x=>JSON.stringify(x);const equalSet=(a,b)=>assert.deepEqual(new Set(a.map(key)),new Set(b.map(key)));
export const plans=r=>r[4]?.[0]==='participation'&&r[4][2]?.[4]?.[0]==='scoped-search'?r[4][2][4][4].filter(x=>x[0]==='candidate-participation'):[];
export const signatures=r=>[...new Set(plans(r).map(p=>key(p[1].map(t=>t[1]).reverse())))].sort();
const reach=(edges,a,b)=>{const seen=new Set(),todo=[a];while(todo.length){const x=todo.pop();if(x===b)return true;if(seen.has(x))continue;seen.add(x);for(const e of edges)if(e[1]===x)todo.push(e[2])}return false};
function observed(c,id){const n=c.nodes.filter(x=>x[1]===id);assert.equal(n.length,1);const r=n[0];assert(r[3].includes(c.scope[2]));assert.equal(r[4],c.scope[3]);assert.deepEqual(c.current.filter(x=>x[1]===id),[['at',id,r[5]]]);if(['external-contact','human-confirmation','testimony','action-result'].includes(r[2]))assert.deepEqual(c.registry.filter(x=>x[1]===id),[['observation',...r.slice(1,7)]]);return r;}
function expectedSyntax(text){
 const t=text.trim().replace(/\.$/u,'').toLowerCase();let m;
 if((m=/^please revise ([\p{L}\p{N}_-]+)$/u.exec(t)))return ['syntax','request',m[1],'revised'];
 if((m=/^([\p{L}\p{N}_-]+) needs revision$/u.exec(t)))return ['syntax','request',m[1],'revised'];
 if((m=/^do not revise ([\p{L}\p{N}_-]+)$/u.exec(t)))return ['syntax','prohibition',m[1],'revised'];
 const patterns=[[/^keep ([\p{L}\p{N}_-]+) able to (.+) ([\p{L}\p{N}_-]+)$/u,'obligation'],[/^([\p{L}\p{N}_-]+) must (?:still )?be able to (.+) ([\p{L}\p{N}_-]+)$/u,'obligation'],[/^([\p{L}\p{N}_-]+) may (.+) ([\p{L}\p{N}_-]+)$/u,'permission'],[/^([\p{L}\p{N}_-]+) no longer needs to (.+) ([\p{L}\p{N}_-]+)$/u,'release']];
 for(const [re,mode] of patterns)if((m=re.exec(t))){const roles=m[2].split(' and ').map(v=>({choose:'choice',inspect:'inspection',restore:'recovery'})[v]);if(roles.every(Boolean))return ['syntax','ability',mode,m[1],m[3],roles];}
 return null;
}
export function verify(c,r){
 assert.equal(r[0],'language-grounding');assert.equal(r.length,5);assert.deepEqual(r[1],c.scope);assert(['participation','inquiry'].includes(r[4][0]));
 for(const read of r[2][1]){
   assert.equal(read[0],'language-reading');assert.equal(read.length,7);
   if(read[6]?.[0]!=='supported')continue;
   const raw=observed(c,read[1]);assert.equal(raw[2],'human-confirmation');const text=raw[6][2];
   if(typeof text!=='string'||Array.from(text).length>8192){assert.equal(read[3],'no-span');assert.deepEqual(read[5],['unresolved','lexical-input']);continue;}
   const chars=Array.from(text);
   const first=chars.findIndex(x=>!/^\s$/u.test(x));let end=chars.length;while(end>0&&/^\s$/u.test(chars[end-1]))end--;
   assert.deepEqual(read[3],['span',String(Math.max(0,first)),String(end)]);
   const syntax=expectedSyntax(text);if(syntax)assert.deepEqual(read[4],syntax);else assert.equal(read[4][0],'unparsed');
   if(read[5]?.[0]==='interpreted'){
     assert(syntax);const bindings=read[5][2];for(const b of bindings)assert.equal(b[0],'supported');
     const named=(alias,kind)=>{const rows=bindings.filter(p=>p[1][0]==='named'&&p[1][1]===alias&&p[1][2]===kind);assert(rows.length);const ids=[...new Set(rows.map(p=>p[1][3]))];assert.equal(ids.length,1);return ids[0]};
     const artifact=named(syntax[1]==='ability'?syntax[4]:syntax[2],'artifact');assert.equal(artifact,raw[6][1]);
     for(const bound of read[5][1])if(bound[0]==='bound-claim'){
       const claim=bound[1];if(syntax[1]==='request')assert.deepEqual(claim,['purpose',['language-purpose',artifact],['path',artifact,'revised']]);
       else if(syntax[1]==='prohibition')assert.deepEqual(claim,['prohibition',['path',artifact,'revised']]);
       else {const actor=named(syntax[3],'person');const iface=bound[2].map(x=>x[1]).find(x=>x[0]==='interface');assert(iface);assert.equal(iface[1],artifact);assert(syntax[5].includes(iface[2]));const id=['language-obligation',artifact,actor,iface[2]];assert.deepEqual(claim,syntax[2]==='obligation'?['commitment',id,artifact,actor,iface[2],iface[3]]:syntax[2]==='release'?['release',id]:['permission',artifact,actor,iface[2],iface[3]]);}
     }
   }
 }
 walk(r,p=>{
   if(p[0]==='origin'){const n=observed(c,p[1]);assert.equal(n[2],p[2]);assert.equal(n[5],p[3])}
   if(p[0]==='root'){const n=observed(c,p[1]);assert.equal(n[5],p[2]);assert.equal(n[2],p[3])}
   if(p[0]==='supported'&&p[2]?.[0]==='language-derived'){
     const roots=[];for(const b of p[2][4])roots.push(...b[3]);equalSet(p[3],roots);
     assert.equal(new Set(p[3].map(key)).size,p[3].length);
   }
 });
 for(const p of plans(r)){
   let state=c.nodes.filter(n=>n[6]?.[0]==='edge'&&c.registry.some(o=>key(o)===key(['observation',...n.slice(1,7)]))).map(n=>n[6]);
   const goals=p[3];for(const step of [...p[1]].reverse()){
     equalSet(step[2],state);const op=c.operations.find(x=>x[1]===step[1]);assert(op);assert(op[2].every(e=>state.some(x=>key(x)===key(e))));
     state=state.filter(e=>!op[4].some(x=>key(x)===key(e))).concat(op[3]);state=[...new Map(state.map(e=>[key(e),e])).values()];equalSet(state,step[3]);
     for(const goal of goals.slice(1))assert(reach(state,goal[1],goal[2]));
   }
   equalSet(state,p[2]);for(const goal of goals)assert(reach(state,goal[1],goal[2]));
 }
 const sig=signatures(r);
 if(c.expected==='preserved')assert.deepEqual(sig,['["preserve-participation","direct-change"]']);
 else if(c.expected==='direct-available')assert(sig.includes('["direct-change"]'));
 else if(c.expected==='complete')assert.deepEqual(sig,['[]']);
 else if(c.expected==='inquiry'){assert.equal(r[4][0],'inquiry');assert.equal(sig.length,0)}
 else if(c.expected==='no-plan'){assert.equal(r[4][0],'participation');assert.equal(sig.length,0)}
 else throw Error('undeclared independent expectation');
}
