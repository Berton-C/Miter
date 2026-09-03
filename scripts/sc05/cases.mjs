// Builder-owned finite experiments. Expected claims never enter Miter.
import {base,clone,append,replaceText} from '../sc04/fixtures.mjs';
export const report='You requested revision of ledger.';
export const retain='Mara must remain able to choose and inspect and restore ledger.';
export const wanted=[['reported-request',['path','artifact','revised']],...['choice','inspection','recovery'].map((r,i)=>['retain','artifact','person',r,['choose','inspect','recover'][i]])];
export function cases(){
 const rows=[];function add(id,clauses,edit=()=>{},extra={}){const c=base();c.expected='preserved';edit(c);rows.push({id,c,clauses,intended:clone(wanted),current:clone(c.scope),candidateScope:clone(c.scope),...extra});}
 add('faithful',[report,retain]);
 add('order-and-duplicate',[retain,report,report]);
 add('article-and-synonym',['The requested change is to revise the ledger.','The change must keep Mara able to recover and choose and inspect the ledger.']);
 add('permission',[report,'Mara may choose and inspect and restore ledger.']);
 add('release-instead-of-retain',[report,'Mara no longer needs to choose and inspect and restore ledger.']);
 add('instruction',['Please revise ledger.',retain]);
 add('promise',['I will revise ledger.',retain]);
 add('false-completion',[report,retain,'The revision of ledger is complete.']);
 add('missing-recovery',[report,'Mara must remain able to choose and inspect ledger.']);
 add('missing-request',[retain]);
 add('unknown-wording',[report,'The ledger remains delightfully empowering.']);
 add('unknown-extra-clause',[report,retain,'Miter has universal approval.']);
 add('empty',[]);
 add('refusal-wording',['I cannot help with that.']);
 add('wrong-actor',[report,'Alex must remain able to choose and inspect and restore ledger.']);
 add('wrong-artifact',['You requested revision of journal.',retain]);
 add('unavailable-operators',[report,retain],c=>{c.operations=[];c.expected='no-plan'});
 add('observed-completion',[report,retain,'The revision of the ledger is complete.'],c=>{
   for(const rs of [c.nodes,c.registry])rs.find(n=>n[6][0]==='edge'&&n[6][1]==='artifact')[6][2]='revised';c.expected='complete';
 },{intended:[['completion',['path','artifact','revised']],...clone(wanted)]});
 add('missing-observed-completion',[report,retain],c=>{
   for(const rs of [c.nodes,c.registry])rs.find(n=>n[6][0]==='edge'&&n[6][1]==='artifact')[6][2]='revised';c.expected='complete';
 },{intended:[['completion',['path','artifact','revised']],...clone(wanted)]});
 add('source-releases-inspection',[report,'Mara must remain able to choose and restore ledger.'],c=>append(c,'release-contact','Mara no longer needs to inspect ledger.'),{intended:clone(wanted.filter(x=>x[3]!=='inspection'))});
 add('same-expression-new-source',[report,retain],c=>append(c,'release-contact','Mara no longer needs to inspect ledger.'),{intended:clone(wanted.filter(x=>x[3]!=='inspection'))});
 add('other-context',[report,retain],c=>append(c,'other-contact','An unrelated open question about journal.', 'other-artifact'));
 add('equivalent-request',[report,retain],c=>replaceText(c,'request-source','Ledger needs revision.'));
 add('no-source-authority',[report,retain],c=>{for(const rs of [c.nodes,c.registry])rs.find(n=>n[1]==='request-source')[2]='generation';c.expected='inquiry'}, {intended:null});
 add('stale-source',[report,retain],c=>{c.current.find(n=>n[1]==='request-source')[2]='v2';c.expected='inquiry'}, {intended:null});
 add('scope-changed',[report,retain]);rows.at(-1).candidateScope[2]='other-principal';
 add('cut-changed',[report,retain]);rows.at(-1).current[1]='cut-later';
 const renamed=clone(rows[0]);renamed.id='unicode-neutral';const rename=x=>Array.isArray(x)?x.map(rename):typeof x==='string'?x.replaceAll('ledger','cahier').replaceAll('mara','léa').replaceAll('Mara','Léa'):x;
 renamed.c=rename(renamed.c);renamed.clauses=rename(renamed.clauses);rows.push(renamed);
 return rows;
}
