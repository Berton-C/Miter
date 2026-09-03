// Builder fixtures only. Expectations are never inputs to native construction.
import fs from 'node:fs';import {root} from '../fidelity/check.mjs';import {base,clone} from '../sc04/fixtures.mjs';import {cases as voiceCases,wanted} from '../sc05/cases.mjs';import {map,frame} from '../sc06/cases.mjs';
export {frame};
export const seed=()=>JSON.parse(fs.readFileSync(root+'/derived/voice-realization-seed-v2.json'));
export function compound(){const m=seed();m.candidate_id='fixture-expressive-capability';m.purpose='Builder-authored compound grammar test input; not a model candidate';m.constructions[1].tokens=m.constructions[1].tokens.map(t=>t==='@verb'?'@verbs':t);return m}
export function joint(c,claims=clone(wanted.filter(x=>x[0]==='retain')),kind='human-confirmation'){
 const n=['node','joint-contact',kind,[c.scope[2]],c.scope[3],'v1',['coexpress',c.target,claims],[]];c.nodes.push(n);c.registry.push(['observation',...clone(n.slice(1,7))]);c.current.push(['at',n[1],'v1']);return c;
}
export function cases(){const rows=[];const add=(id,edit=()=>{},extra={})=>{const r={id,c:base(),m:compound(),fuel:256,intended:clone(wanted),expected:'supported-expression-alternatives',jointClaims:[],...extra};edit(r);rows.push(r)};
 add('compound-alternatives');add('seed-individual',r=>r.m=seed());
 add('joint-supported',r=>{joint(r.c);r.jointClaims=clone(wanted.filter(x=>x[0]==='retain'))});
 add('joint-unavailable-in-seed',r=>{joint(r.c);r.jointClaims=clone(wanted.filter(x=>x[0]==='retain'));r.m=seed();r.expected='expression-inquiry'});
 add('partial-joint',r=>{r.jointClaims=clone(wanted.filter(x=>x[0]==='retain'&&x[3]!=='recovery'));joint(r.c,r.jointClaims)});
 add('generated-joint',r=>joint(r.c,undefined,'generation'));
 add('foreign-joint',r=>{joint(r.c);for(const rs of [r.c.nodes,r.c.registry])rs.find(x=>x[1]==='joint-contact')[3]=['other-principal']});
 add('stale-joint',r=>{joint(r.c);r.c.current.find(x=>x[1]==='joint-contact')[2]='v2';r.expected='expression-context-incomplete'});
 add('irrelevant-joint',r=>{joint(r.c);for(const rs of [r.c.nodes,r.c.registry])rs.find(x=>x[1]==='joint-contact')[6][1]='other-artifact'});
 add('unknown-wording',r=>{r.m.constructions[1].tokens=['@person','is','delightfully','empowering'];r.expected='expression-inquiry'});
 add('unsupported-completion',r=>{r.m.constructions[0].tokens=['the','revision','of','@artifact','is','complete'];r.expected='expression-inquiry'});
 add('permission-shift',r=>{r.m.constructions[1].tokens=['@person','may','@verbs','@artifact'];r.expected='expression-inquiry'});
 add('wrong-person',r=>{r.m.constructions[1].tokens=['alex','must','remain','able','to','@verbs','@artifact'];r.expected='expression-inquiry'});
 add('reordered-constructors',r=>{r.m.constructions.reverse();for(const c of r.m.constructions)c.id='renamed-'+c.id});
 add('unicode-names',r=>{r.c=map(r.c,x=>typeof x==='string'?x.replaceAll('ledger','cahier').replaceAll('mara','léa').replaceAll('Mara','Léa'):x)});
 for(const id of ['observed-completion','source-releases-inspection','unavailable-operators']){const v=voiceCases().find(x=>x.id===id);add(id,r=>{r.c=v.c;r.intended=v.intended})}
 add('no-source-authority',r=>{for(const rs of [r.c.nodes,r.c.registry])rs.find(x=>x[1]==='request-source')[2]='generation';r.intended=null;r.expected='construction-inquiry'});
 add('zero-search-grant',r=>{r.fuel=0;r.expected='expression-search-incomplete'});
 add('missing-report-capability',r=>{r.m.constructions=r.m.constructions.filter(x=>x.meaning!=='reported-request');r.expected='expression-inquiry'});
 add('duplicate-constructor-id',r=>{r.m.constructions[1].id=r.m.constructions[0].id;r.expected='construction-rejected'});
 add('unknown-slot',r=>{r.m.constructions[0].tokens=['@execute'];r.expected='construction-rejected'});
 return rows;
}
