import fs from 'node:fs';import {root,hash} from '../fidelity/check.mjs';import {base,clone,replaceText} from '../sc04/fixtures.mjs';import {frame} from '../sc07/cases.mjs';import {wanted} from '../sc05/cases.mjs';
export function cases(){
 const parent=JSON.parse(fs.readFileSync(root+'/derived/voice-realization-seed-v2.json')),candidate=JSON.parse(fs.readFileSync(root+'/evidence/SC08/live-001/cycle/request/candidate.json'));
 const rows=[];function add(id,m,roots,edit=()=>{},expected='confirmed'){
  const c=base(),context='retention-coexpression-v1',question='question-'+id;
  const node=['node',question,'human-confirmation',[c.scope[2]],c.scope[3],'v1',['capability-question',c.target,'coexpress-retentions',context],[]];c.nodes.push(node);c.registry.push(['observation',...clone(node.slice(1,7))]);c.current.push(['at',question,'v1']);
  const r={id,c,m:clone(m),roots,context,question,fuel:256,intended:clone(wanted),jointClaims:[],expression:'supported-expression-alternatives',expected};edit(r);rows.push(r);
 }
 const one=r=>{replaceText(r.c,'commitment-source','Keep mara able to choose ledger.');r.intended=r.intended.filter(x=>x[0]!=='retain'||x[3]==='choice')};
 add('parent-one',parent,['source-parent-one'],one);
 add('parent-three',parent,['source-parent-three'],()=>{},'disconfirmed');
 add('candidate-one',candidate,['source-candidate-one'],one);
 add('candidate-three',candidate,['source-candidate-three']);
 add('repeat-parent-one',parent,['source-parent-one'],one);
 add('overlap-candidate',candidate,['source-candidate-three','another-root']);
 add('unknown-source',candidate,['source-unknown'],r=>{for(const a of [r.c.nodes,r.c.registry])a.find(n=>n[1]==='request-source')[2]='generation';r.intended=null;r.expression='construction-inquiry'},'ambiguous');
 add('unfinished-search',candidate,['source-delayed'],r=>{r.fuel=0;r.expression='expression-search-incomplete'},'delayed');
 add('foreign-criterion',candidate,['source-foreign-question'],r=>{for(const a of [r.c.nodes,r.c.registry])a.find(n=>n[1]===r.question)[6][1]='another-artifact'},'inapplicable');
 add('missing-criterion',candidate,['source-missing-question'],r=>r.question='unknown-question','criterion-failed');
 add('stale-criterion',candidate,['source-stale-question'],r=>r.c.current.find(n=>n[1]===r.question)[2]='v2','criterion-failed');
 add('invalid-module',candidate,['source-invalid-module'],r=>{r.m.allowed_writes=['&soul'];r.expression='construction-rejected'},'malformed');
 return rows;
}
export function input(rows){const modules=new Map();const invocations=rows.map(r=>{const bytes=JSON.stringify(r.m)+'\n',pin=hash(bytes),file='module-'+pin+'.json';modules.set(file,bytes);return {id:r.id,scope:r.c.scope,roots:r.roots,frame:frame(r.c),question:r.question,context:r.context,module_pin:pin,module_file:file,module:r.m,fuel:r.fuel}});return {modules,invocations};}
