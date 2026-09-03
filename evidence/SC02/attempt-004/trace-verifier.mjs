// Verify native products against input records. Does not generate candidate plans.
import assert from 'node:assert/strict';
const set=xs=>new Set(xs.map(JSON.stringify));
const one=(rows,id)=>{const xs=rows.filter(x=>x[1]===id);assert.equal(xs.length,1);return xs[0]};
const reach=(edges,a,b)=>{const seen=new Set(),todo=[a];while(todo.length){const x=todo.pop();if(x===b)return true;if(seen.has(x))continue;seen.add(x);for(const e of edges)if(e[1]===x)todo.push(e[2]);}return false};
export function verifyTraces(c,g){
  if(!Array.isArray(g)||g[0]!=='grounded-participation')return;
  assert.deepEqual(g[1],c.scope);
  function proof(p,seen=[]){
    assert.equal(p[0],'supported');const d=p[2],id=d[1];assert(!seen.includes(id));
    const n=one(c.nodes,id);assert.equal(n.length,8);assert(n[3].includes(c.scope[2]));assert.equal(n[4],c.scope[3]);
    assert.deepEqual(one(c.current,id),['at',id,n[5]]);assert.deepEqual(p[1],n[6]);assert.equal(d[2],n[2]);
    let roots;
    if(d[0]==='origin'){
      assert(['external-contact','human-confirmation','testimony','action-result'].includes(n[2]));assert.deepEqual(n[7],[]);
      assert.deepEqual(one(c.registry,id),['observation',...n.slice(1,7)]);assert.equal(d[3],n[5]);roots=[['root',id,n[5],n[2]]];
    }else{
      assert.equal(d[0],'derived');assert(['inference','memory-recall'].includes(n[2]));assert(n[7].length>0);
      assert.deepEqual(d[3].map(x=>x[2][1]),n[7]);roots=[];
      for(const parent of d[3]){assert.deepEqual(parent[1],p[1]);roots.push(...proof(parent,[...seen,id]));}
    }
    assert.deepEqual(set(p[3]),set(roots));assert.equal(p[3].length,set(roots).size);return p[3];
  }
  for(const p of g[2][1])if(p[0]==='supported')proof(p);
  const fields={choice:'AgencyBalance',inspection:'SharedUnderstanding',recovery:'TimeCoherence'};
  for(const row of g[3][1])if(row[0]==='material-interface'){
    assert.equal(row[1],fields[row[2]]);assert.equal(row[5][0],'support-basis');assert(row[5][1].length>0);
    for(const p of row[5][1]){proof(p);const k=p[1];assert.equal(k[0],'commitment');assert.equal(k[2],c.request[1]);assert.equal(k[3],row[3]);assert.equal(k[4],row[2]);assert.equal(k[5],row[4]);}
  }
  const search=g[4];if(!Array.isArray(search)||search[0]!=='scoped-search')return;
  const focus=g[3][1].filter(x=>x[0]==='material-interface');assert.deepEqual(search[2][1],focus);
  const state0=g[2][1].filter(x=>x[0]==='supported'&&x[1][0]==='edge').map(x=>x[1]);
  for(const candidate of search[4].filter(x=>x[0]==='candidate-participation')){
    let state=state0;
    for(const t of [...candidate[1]].reverse()){
      assert.equal(t[0],'transition');assert.deepEqual(set(t[2]),set(state));const op=one(c.operations,t[1]);const before=set(state);for(const e of op[2])assert(before.has(JSON.stringify(e)));
      const after=new Set(before);for(const e of op[4])after.delete(JSON.stringify(e));for(const e of op[3])after.add(JSON.stringify(e));assert.deepEqual(set(t[3]),after);state=t[3];
      for(const f of focus)assert(reach(state,f[3],f[4]));
    }
    assert.deepEqual(set(candidate[2]),set(state));assert(reach(state,c.request[1],c.request[2]));for(const f of focus)assert(reach(state,f[3],f[4]));
  }
}
