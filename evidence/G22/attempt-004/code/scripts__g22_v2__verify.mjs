// Independent comparison: enumerate complete fragment sets and read real words.
// Never provides a verdict or expected outcome to native runtime.
import assert from 'node:assert/strict';import {verify as expression,options} from '../sc07/verify.mjs';
export function reports(rows,module,report){assert.equal(report[0],'trial-report');assert.equal(report[3].length,rows.length);
 return rows.map((r,i)=>{const o=report[3][i];assert.equal(o[0],'trial-observation');assert.equal(o[1][1],r.id);let expected=r.expected;
  if(['supported-expression-alternatives','expression-inquiry'].includes(expected))expected=options({...r,m:module}).length?'supported-expression-alternatives':'expression-inquiry';
  const result=expression({...r,m:module,expected},['result',o[2],o[3]]);return {...result,available:o[3][0]==='supported-expression-alternatives'};
 });
}
export function compare(parent,candidate){return parent.map((p,i)=>({id:p.id,parent:p.available,candidate:candidate[i].available,gain:!p.available&&candidate[i].available,loss:p.available&&!candidate[i].available}));}
