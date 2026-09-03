// Offline native-substrate probe, not part of Miter's running cognition.
import fs from 'node:fs';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
import {root,checkOpen} from '../fidelity/check.mjs';import {base,sexp} from './fixtures.mjs';
process.chdir(root);const out=process.argv[2];assert.match(out??'',/^evidence\/SC04\/probe-\d{3}$/);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const save=(p,x)=>fs.writeFileSync(out+'/'+p,typeof x==='string'?x:JSON.stringify(x)+'\n');
save('opening.json',checkOpen('docs/gates/SC04/plan.json'));const c=base();save('case.json',c);
for(const p of ['src/grounded_language.metta','src/participation_support.metta','effect_membranes/miter_language.pl'])save(p.split('/').at(-1),fs.readFileSync(p,'utf8'));
const args=[c.scope,c.nodes,c.registry,c.current,c.operations,c.target,c.budget,c.proposals];
const inner=`(let* (($proofs (SReadAll ${[c.scope,c.nodes,c.registry,c.current,0].map(sexp).join(' ')})) ($rows (LSourceRows ${[c.scope,c.nodes,c.registry].map(sexp).join(' ')})) ($readings (LReadRows ${[c.scope,c.nodes,c.registry,c.current].map(sexp).join(' ')} $proofs $rows 0))) $readings)`;
const mode=process.argv[3]??'full';const expression=mode==='scan'?'(let* (($t (miter_language_tokens "Please revise ledger.")) ($w (LUnpunctuate (LWords $t 0)))) (scanned $t $w (LParse $w)))':mode==='read'?inner:mode==='products'?`(let $r ${inner} (products (LAllProducts $r 0 ()) (LQuestions $r artifact)))`:`(GroundLanguage ${args.map(sexp).join(' ')})`;
save('entry.metta',`!(import! &self "${root}/src/bootstrap_grounded_language.metta")\n!(let $r ${expression} (case-result probe $r))\n`);
const r=spawnSync('/opt/homebrew/bin/swipl',['--stack_limit=1g','-q','-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',root+'/'+out+'/entry.metta'],{encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});save('stdout',r.stdout??'');save('stderr',r.stderr??'');save('process.json',{status:r.status,signal:r.signal,error:r.error?.message??null});console.log(JSON.stringify({status:r.status,stdout:(r.stdout??'').slice(0,1500),stderr:r.stderr,evidence:out}));
