// Offline causal fixtures only; no model calls or runtime decision-making.
import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,hash,native,save,read,sexp} from '../g22_v2/common.mjs';
const tag=process.argv[2];assert.match(tag??'',/^[0-9]{3}$/);const dir=root+'/evidence/G28-R2/quality-'+tag;assert(!fs.existsSync(dir));fs.mkdirSync(dir,{recursive:true});
process.on('uncaughtException',e=>{save(dir+'/failure.json',{message:e.message,stack:e.stack});console.error(e.stack);process.exitCode=1});
const files=['src/executable_partial_revision_v1.metta','src/executable_development_v3.metta','src/bootstrap_executable_development_v3.metta','effect_membranes/miter_executable_development_v3.pl','scripts/g28_r2/quality.mjs'];
save(dir+'/freeze.json',{files:files.map(p=>({path:root+'/'+p,sha256:hash(fs.readFileSync(root+'/'+p))}))});
fs.mkdirSync(dir+'/code');for(const p of files)fs.copyFileSync(root+'/'+p,dir+'/code/'+p.replaceAll('/','__'));
const boot=`!(import! &self "${root}/src/bootstrap_executable_development_v3.metta")\n`;
const a=['candidate-file','alpha','source-a','hash-a'],b=['candidate-file','beta','source-b','hash-b'];
const obligation=(path,id,expected,actual)=>['file-obligation',path,id,['expected-exit',expected],['process-observation',id,actual,'','',false,'receipt']];
const rows=[obligation('alpha','observation-a',0,0),obligation('beta','observation-b',0,1)];
const reversed=[obligation('alpha','observation-a',0,1),obligation('beta','observation-b',0,0)];
const unknown=structuredClone(rows);unknown[1][4]=['process-incomplete','observation-b','unknown'];
const neutral=[...rows].reverse().concat([obligation('unrelated','neutral',0,0)]);
const renamed=rows.map((r,i)=>{r=structuredClone(r);r[2]='different-'+i;r[4][1]=r[2];return r});
const definitions={canonical:rows,reversed,unknown,neutral,renamed};
const expr=Object.entries(definitions).map(([name,rs])=>`!(result ${name} (PRConstruct ${sexp([a,b])} ${sexp(rs)}))`).join('\n');
const result=native(dir,'partial-selection',expr,boot),map=Object.fromEntries(result.map(r=>[r[1],r[2]]));
assert.equal(result.length,5);assert.deepEqual(map.canonical[1],[b]);assert.deepEqual(map.canonical[2],[a]);assert.deepEqual(map.reversed[1],[a]);assert.deepEqual(map.reversed[2],[b]);assert.deepEqual(map.unknown[1],[]);assert.deepEqual(map.unknown[3],[b]);
for(const key of ['neutral','renamed'])assert.deepEqual(map[key].slice(1,4),map.canonical.slice(1,4));
const source=fs.readFileSync(root+'/src/executable_partial_revision_v1.metta','utf8'),start=source.indexOf('(= (PRState '),end=source.indexOf('(= (PRFileState ',start);assert(start>=0&&end>start);
save(dir+'/severed.metta',source.slice(0,start)+'(= (PRState $row) satisfied)\n'+source.slice(end));
const bare=`!(import! &self "${root}/src/bootstrap_grounded_language.metta")\n!(import! &self "${dir}/severed.metta")\n`;
const severed=native(dir,'severed',expr,bare);assert.deepEqual(severed[0][2][1],[]);assert.notDeepEqual(severed[0][2].slice(1,4),map.canonical.slice(1,4));
assert.deepEqual(native(dir,'restored',expr,boot),result);
const extra=native(dir,'guards',`
!(result unknown-not-ready (PRReady ${sexp(map.unknown)}))
!(result ready (PRReady ${sexp(map.canonical)}))
!(result assembled (PRMerge ${sexp(map.canonical)} ((candidate-file beta new hash-new))))
!(result escaped (PRMerge ${sexp(map.canonical)} ((candidate-file gamma new hash-new))))
!(result duplicated (PRMerge ${sexp(map.canonical)} ((candidate-file beta new h1) (candidate-file beta new h2))))
!(result missing (PRMerge ${sexp(map.canonical)} ()))
!(result sensitive (ZSensitivityPassed (test-sensitivity (process-observation smoke-no-output 1 "" "" false receipt) (process-observation smoke-no-lf 1 "" "" false receipt))))
!(result insensitive (ZSensitivityPassed (test-sensitivity (process-observation smoke-no-output 1 "" "" false receipt) (process-observation smoke-no-lf 0 "" "" false receipt))))
!(result truncation (ZReady (model-observation x eof 200 10 true length artifact-shaped 12 "" ()) ))
`,boot);
const g=Object.fromEntries(extra.map(x=>[x[1],x[2]]));assert.equal(g['unknown-not-ready'],'false');assert.equal(g.ready,'true');assert.deepEqual(g.assembled,[a,['candidate-file','beta','new','hash-new']]);for(const k of ['escaped','duplicated','missing'])assert.deepEqual(g[k],['partial-assembly-held']);assert.equal(g.sensitive,'true');assert.equal(g.insensitive,'false');assert.equal(g.truncation,'false');
save(dir+'/verdict.json',{status:'PASS-BOUNDED',new_model_calls:0,material_reversal:true,unknown_not_failure:true,neutral_and_renamed:true,severed_and_restored:true,partial_assembly_guarded:true,test_sensitivity_required:true,rows:result,guards:extra,limits:'Generic finite file/obligation projection, not natural-language diagnosis or all Soul semantics'});console.log(JSON.stringify(read(dir+'/verdict.json')));
