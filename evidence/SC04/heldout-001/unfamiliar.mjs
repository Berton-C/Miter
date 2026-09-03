// Builder-known generator; concrete instances are drawn only after Git freeze.
import {base,clone,replaceText,append} from './fixtures.mjs';
export function generate(seed,count=64){
 let n=parseInt(seed.slice(0,8),16)>>>0;const draw=()=>{n^=n<<13;n^=n>>>17;n^=n<<5;return n>>>0};
 const cases=[];for(let i=0;i<count;i++){
   const c=base(),suffix=draw().toString(16),a='folio'+suffix,p=(i%2?'mára':'collaborator')+draw().toString(16);
   const map={artifact:'document-'+suffix,person:'participant-'+suffix,choose:'choice-end-'+suffix,inspect:'inspection-end-'+suffix,recover:'recovery-end-'+suffix,delegate:'relay-'+suffix,original:'initial-'+suffix};
   const edge=e=>[e[0],map[e[1]]??e[1],map[e[2]]??e[2]];
   for(const r of c.nodes){const v=r[6];if(v[0]==='edge')r[6]=edge(v);else if(v[0]==='named'){if(r[1]==='name-person'){v[1]=p;v[3]=map.person}else if(r[1]==='name-artifact'){v[1]=a;v[3]=map.artifact}}else if(v[0]==='interface'){v[1]=map.artifact;v[3]=map[v[3]]}else if(v[0]==='utterance')v[1]=map[v[1]]??v[1]}
   c.operations=c.operations.map(o=>[o[0],o[1],o[2].map(edge),o[3].map(edge),o[4].map(edge)]);c.target=map.artifact;c.registry=clone(c.nodes.map(r=>['observation',...r.slice(1,7)]));
   const all=['choose','inspect','restore'];for(let j=all.length-1;j>0;j--){const k=draw()%(j+1);[all[j],all[k]]=[all[k],all[j]]}
   const verbs=all.slice(0,1+draw()%3).join(' and '),kind=i%8;
   replaceText(c,'request-source',draw()%2?`Please revise ${a}.`:`${a} needs revision.`);
   const forms=[`Keep ${p} able to ${verbs} ${a}.`,`${p} must be able to ${verbs} ${a}.`,`${p} must still be able to ${verbs} ${a}.`];
   replaceText(c,'commitment-source',forms[draw()%forms.length]);c.expected='preserved';
   if(kind===1){replaceText(c,'commitment-source',`${p} may ${verbs} ${a}.`);c.expected='direct-available'}
   if(kind===2){append(c,'release-source',`${p} no longer needs to ${verbs} ${a}.`,c.target);c.expected='direct-available'}
   if(kind===3){append(c,'prohibition-source',`Do not revise ${a}.`,c.target);c.expected='inquiry'}
   if(kind===4)append(c,'other-source',`Explore a different question ${suffix}.`,'other-artifact');
   if(kind===5){c.operations=[];c.expected='no-plan'}
   if(kind===6){const r=['node','completed-source','external-contact',[c.scope[2]],c.scope[3],'v1',['edge',c.target,'revised'],[]];c.nodes.push(r);c.registry.push(clone(['observation',...r.slice(1,7)]));c.current.push(['at',r[1],'v1']);c.expected='complete'}
   if(kind===7){c.current.find(r=>r[1]==='commitment-source')[2]='v2';c.expected='inquiry'}
   if(draw()%2){c.nodes.reverse();c.registry.reverse();c.current.reverse();c.operations.reverse()}
   c.id='unfamiliar-'+String(i).padStart(3,'0');cases.push(c);
 }return cases;
}
