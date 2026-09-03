import {base,clone,sexp} from '../sc04/fixtures.mjs';
import {cases as voiceCases} from '../sc05/cases.mjs';
// Inert module JSON strings become native atoms at the mechanical boundary.
// The general language-fixture serializer instead quotes punctuation such as *.
export const policySexp=x=>Array.isArray(x)?'('+x.map(policySexp).join(' ')+')':x==='*'?'*':sexp(x);
export function compilerCases(){const rows=voiceCases().filter(r=>['faithful','observed-completion','source-releases-inspection','unavailable-operators'].includes(r.id));const renamed=clone(rows[0]);renamed.id='unicode-names';renamed.c=map(renamed.c,x=>typeof x==='string'?x.replaceAll('mara','léa').replaceAll('Mara','Léa').replaceAll('ledger','cahier'):x);return [...rows,renamed]}
export const map=(x,f)=>Array.isArray(x)?x.map(v=>map(v,f)):x&&typeof x==='object'?Object.fromEntries(Object.entries(x).map(([k,v])=>[k,map(v,f)])):f(x);
export function second(a){const b=map(clone(a),x=>x==='artifact'?'artifact-two':x==='person'?'person-two':x);for(const rs of [b.nodes,b.registry])for(const n of rs)if(n[6][0]==='named')n[6][2]=n[6][2].replace('-two','');return b}
export const frame=c=>['voice-frame',c.scope,c.nodes,c.registry,c.current,c.operations,c.target,c.budget,c.proposals];
export const clauses=['You requested revision of ledger.','Mara must remain able to choose and restore ledger.'];
export const full=['You requested revision of ledger.','Mara must remain able to choose and inspect and restore ledger.'];
export const surfaces=[['surface-capability','VoicePolicy','retention-omission','miter-voice-policy-v1',['trial-guidance'],[]]];
export const grant=scope=>['development-grant',scope,1,1024,120];
export function scenarios(){
 const a=base(),b=second(a),rows=[];const add=(id,records,expected='development-held',extras={})=>rows.push({id,a:clone(a),b:clone(b),ca:clauses,cb:clauses,records,expected,surfaces,grant:grant(a.scope),...extras});
 add('canonical','($a $b)','development-opportunity');add('one-family','($a)');
 add('replay-renamed-id',`($a (audit-observation replay ${sexp(a.scope)} independent-native-audit ${sexp(frame(a))} ${sexp(clauses)} (index-atom $a 6)))`); // differing request id invalidates old audit too
 add('same-family-new-audit',`($a (DObserve new-event independent-native-audit ${sexp(frame(a))} ${sexp(clauses)}))`);
 const changed=clone(a);for(const rs of [changed.nodes,changed.registry])for(const n of rs)n[5]='v2';for(const n of changed.current)n[2]='v2';
 add('timestamp-version-replay',`($a (DObserve later-version independent-native-audit ${sexp(frame(changed))} ${sexp(clauses)}))`);
 add('neutral-order','($b $a)','development-opportunity');
 add('faithful','($a $b)','development-held',{ca:full,cb:full});
 add('unknown','($a $b)','development-held',{ca:['The ledger remains empowering.'],cb:['The ledger remains empowering.']});
 add('self-claims',`((audit-observation receipt-a ${sexp(a.scope)} self-trace (index-atom $a 4) (index-atom $a 5) (index-atom $a 6)) (audit-observation receipt-b ${sexp(a.scope)} self-trace (index-atom $b 4) (index-atom $b 5) (index-atom $b 6)))`);
 add('tampered-candidate',`((audit-observation receipt-a ${sexp(a.scope)} independent-native-audit (index-atom $a 4) ${sexp(full)} (index-atom $a 6)) $b)`);
 const stale=clone(a);stale.current.find(x=>x[1]==='request-source')[2]='v-missing';
 add('stale-frame',`((audit-observation receipt-a ${sexp(a.scope)} independent-native-audit ${sexp(frame(stale))} (index-atom $a 5) (index-atom $a 6)) $b)`);
 const scope=clone(a.scope);scope[2]='other-person';add('wrong-scope',`((audit-observation receipt-a ${sexp(scope)} independent-native-audit (index-atom $a 4) (index-atom $a 5) (index-atom $a 6)) $b)`);
 add('malformed-record','((not-an-audit) $b)');add('missing-surface','($a $b)','development-inquiry',{surfaces:[]});add('exhausted-resource','($a $b)','development-incomplete',{grant:['development-grant',a.scope,0,1024,120]});
 const na=map(a,x=>typeof x==='string'?x.replaceAll('mara','léa').replaceAll('Mara','Léa').replaceAll('ledger','cahier'):x),nb=second(na);
 add('neutral-lexical-names','($a $b)','development-opportunity',{a:na,b:nb,ca:map(clauses,x=>x.replaceAll('Mara','Léa').replaceAll('ledger','cahier')),cb:map(clauses,x=>x.replaceAll('Mara','Léa').replaceAll('ledger','cahier'))});
 return rows;
}
export function modules(){const good=['voice-policy','miter-voice-policy-v1','fixture-module','Finite fixture', [['rule','defect','semantic-drift','approved-clause-plan',1],['rule','always','*','preserve-candidate',0]],['trial-guidance'],[]];const rows=[];const add=(id,expected,edit=()=>{})=>{const m=clone(good);edit(m);rows.push({id,m,expected})};
 add('valid','module-valid');add('soul-write','forbidden-write',m=>m[5]=['&soul']);add('history-write','forbidden-write',m=>m[5]=['&history']);add('active-write','forbidden-write',m=>m[5]=['active-registry']);add('external-effect','forbidden-effect',m=>m[6]=['http-post']);add('unknown-action','forbidden-vocabulary',m=>m[4][0][3]='execute-code');add('unknown-condition','forbidden-vocabulary',m=>m[4][0][1]='run');add('unknown-defect','forbidden-vocabulary',m=>m[4][0][2]='all-authority');add('variant-range','forbidden-vocabulary',m=>m[4][0][4]=2);add('missing-default','missing-default',m=>m[4].pop());add('empty','malformed-rules',m=>m[4]=[]);add('bad-schema','wrong-schema-or-id',m=>m[1]='execute-metta');add('bad-id','wrong-schema-or-id',m=>m[2]='not-requested');return rows;}
