// R8 failure isolation only. No variant is used as a runtime substitute.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root,checkOpen} from '../fidelity/check.mjs';
import {save,swi,petta} from '../g22_v2/common.mjs';
import {sexp,parse} from '../sc04/fixtures.mjs';

process.chdir(root);
const source=JSON.parse(fs.readFileSync(`${root}/evidence/G33/R8/attempt-001/source-contacts.json`));
const out=`${root}/evidence/G33/R8/attempt-001/isolation`;
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
save(`${out}/opening.json`,checkOpen('docs/gates/G33/R8/plan.json'));
const [a,b]=['g33-r8-isolate-a','g33-r8-isolate-b'].map((id,index)=>
  `(DObserve ${id} independent-native-audit ${sexp(index?source.second_frame:source.first_frame)} ${sexp(source.clauses)})`);
const opportunity=records=>`(DOpportunity g33-r8-isolate ${sexp(source.first_frame[1])} ${records} ${sexp(source.surfaces)} ${sexp(source.grant)})`;
const body=`!(let* (($a ${a}) ($b ${b})) (case-result canonical ${opportunity('($a $b)')}))\n`;
const variants={
  'current-development-bootstrap':
    `!(import! &self "${root}/src/bootstrap_development_cycle.metta")\n`,
  'current-voice-construction-bootstrap':
    `!(import! &self "${root}/src/bootstrap_voice_construction.metta")\n`,
  'current-relational-voice-bootstrap':
    `!(import! &self "${root}/src/bootstrap_relational_voice.metta")\n`,
  'minimal-current-semantic-imports':
    `!(import! &self "${root}/src/bootstrap_grounded_language.metta")\n`+
    `!(import! &self "${root}/src/relational_voice.metta")\n`+
    `!(import! &self "${root}/src/development_evidence.metta")\n`
};
const summary={schema:'miter-g33-r8-isolation-v1',variants:{}};
for(const [name,boot] of Object.entries(variants)){
  const metta=`${out}/${name}.metta`;save(metta,boot+body);
  const run=spawnSync(swi,['--stack_limit=2g','-q','-s',`${petta}/src/main.pl`,'--',metta,'silent'],
    {cwd:root,encoding:'utf8',timeout:90000,maxBuffer:128*1024*1024});
  save(`${out}/${name}.stdout`,run.stdout??'');save(`${out}/${name}.stderr`,run.stderr??'');
  const line=(run.stdout??'').replace(/\x1b\[[0-9;]*m/g,'').split('\n').find(x=>x.startsWith('(case-result '));
  const product=line?parse(line)[2]:null;
  summary.variants[name]={status:run.status,signal:run.signal,stderr_nonempty:!!run.stderr,
    product,product_head:Array.isArray(product)?product[0]:null};
}
save(`${out}/summary.json`,summary);
console.log(JSON.stringify(summary));
