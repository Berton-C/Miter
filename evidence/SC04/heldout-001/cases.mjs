// Builder-owned training cases and expected observations, never runtime inputs.
import {base,clone,replaceText,append} from './fixtures.mjs';
export function training(){
 const cs=[];const add=(id,change=()=>{},expected='preserved')=>{const c=base();c.id=id;c.expected=expected;change(c);cs.push(c);return c};
 add('canonical');add('paraphrase',c=>{replaceText(c,'request-source','ledger needs revision.');replaceText(c,'commitment-source','mara must still be able to choose and inspect and restore ledger.')});
 add('neutral-order',c=>{c.nodes.reverse();c.registry.reverse();c.current.reverse();c.operations.reverse()});
 add('permission-not-duty',c=>replaceText(c,'commitment-source','mara may choose and inspect and restore ledger.'),'direct-available');
 add('permission-not-release',c=>append(c,'permission-source','mara may choose and inspect and restore ledger.'));
 add('human-release',c=>append(c,'release-source','mara no longer needs to choose and inspect and restore ledger.'),'direct-available');
 add('generated-release',c=>append(c,'release-source','mara no longer needs to choose and inspect and restore ledger.','artifact','generation'));
 add('contradiction',c=>append(c,'prohibition-source','Do not revise ledger.'),'inquiry');
 add('unknown-material',c=>append(c,'unclear-source','Perhaps shuffle ledger imaginatively.'),'inquiry');
 add('unknown-other',c=>append(c,'unclear-source','Perhaps shuffle journal imaginatively.','other-artifact'));
 add('malformed-coordination',c=>replaceText(c,'commitment-source','Keep mara able to choose and ledger.'),'inquiry');
 add('unknown-ability',c=>replaceText(c,'commitment-source','Keep mara able to choose and conceal ledger.'),'inquiry');
 add('target-mismatch',c=>replaceText(c,'commitment-source','Keep mara able to choose journal.'),'inquiry');
 add('missing-raw',c=>{c.nodes=c.nodes.filter(x=>x[1]!=='commitment-source')},'inquiry');
 add('registry-mismatch',c=>{c.nodes.find(x=>x[1]==='commitment-source')[6][2]='mara may choose ledger.'},'inquiry');
 add('stale-version',c=>{c.current.find(x=>x[1]==='commitment-source')[2]='v2'},'inquiry');
 add('foreign-principal',c=>{c.nodes.find(x=>x[1]==='commitment-source')[3]=['other-principal']},'inquiry');
 add('foreign-project',c=>{c.nodes.find(x=>x[1]==='commitment-source')[4]='other-project'},'inquiry');
 add('generated-substitution',c=>{c.nodes.find(x=>x[1]==='commitment-source')[2]='generation'},'inquiry');
 add('ambiguous-name',c=>{const n=clone(c.nodes.find(x=>x[1]==='name-person'));n[1]='competing-name';n[6][3]='other-person';c.nodes.push(n);c.registry.push(['observation',...n.slice(1,7)]);c.current.push(['at',n[1],n[5]])},'inquiry');
 add('duplicated-derivation',c=>{const n=clone(c.nodes.find(x=>x[1]==='name-person'));n[1]='name-citation';n[2]='inference';n[7]=['name-person'];c.nodes.push(n);c.current.push(['at',n[1],n[5]])});
 add('missing-binding',c=>{c.nodes=c.nodes.filter(x=>x[1]!=='interface-recovery')},'inquiry');
 add('missing-observed-path',c=>{c.nodes=c.nodes.filter(x=>x[1]!=='edge-2');c.operations=c.operations.slice(0,1)},'no-plan');
 add('no-operator',c=>{c.operations=[]},'no-plan');
 add('already-complete',c=>{const n=['node','completed-observation','external-contact',[c.scope[2]],c.scope[3],'v1',['edge','artifact','revised'],[]];c.nodes.push(n);c.registry.push(['observation',...n.slice(1,7)]);c.current.push(['at',n[1],n[5]])},'complete');
 const purpose=['purpose',['language-purpose','artifact'],['path','artifact','revised']];
 add('supported-proposal',c=>{c.proposals=[['reading-proposal','model-fixture','oracle-request','request-source',0,21,[purpose]]]});
 add('invented-proposal',c=>{c.proposals=[['reading-proposal','model-fixture','oracle-request','request-source',0,21,[['permission','all-effects']]]]});
 add('forged-span',c=>{c.proposals=[['reading-proposal','model-fixture','oracle-request','request-source',1,21,[purpose]]]});
 add('malformed-proposal',c=>{c.proposals=[['reading-proposal','model-fixture']]});
 add('no-request',c=>{c.nodes=c.nodes.filter(x=>x[1]!=='request-source');c.registry=c.registry.filter(x=>x[1]!=='request-source')},'inquiry');
 add('nontext-input',c=>replaceText(c,'commitment-source',[]),'inquiry');
 add('oversized-input',c=>replaceText(c,'commitment-source','x'.repeat(8193)),'inquiry');
 return cs;
}
