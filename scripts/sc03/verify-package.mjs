// Offline builder verification. Never loaded by Miter's runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync,spawnSync} from 'node:child_process';
import {root,hash,validatePlan} from '../fidelity/check.mjs';
process.chdir(root);
const plan=validatePlan(JSON.parse(fs.readFileSync('docs/gates/SC03/plan.json')));
const baseline='70f59bafd397578984f3cf4afa35d126ec0afa27';
const unchanged=['src/participation.metta','src/participation_support.metta','constitution/soul_compass_v02.metta'].map(path=>{
  const sha256=hash(fs.readFileSync(path));assert.equal(sha256,hash(execFileSync('git',['show',baseline+':'+path])));return {path,sha256};
});
const runtime=['scripts/sc03/main.pl','effect_membranes/miter_undertaking.pl','effect_membranes/miter_store.pl','src/undertaking.metta','src/bootstrap_undertaking.metta'];
for(const f of runtime)assert(!/\.mjs\b|\.cjs\b|node(?:js)?[ '\"]|java[ '\"]|python[ '\"]|py-call|janus/i.test(fs.readFileSync(f,'utf8')),f+' non-native runtime seam');
const commands=[['scripts/fidelity/check.mjs','plan','docs/gates/SC04/plan.json'],['scripts/sc01/validate-docs.cjs'],['--test','scripts/fidelity/check.test.mjs']];
const results=commands.map(args=>{const r=spawnSync(process.execPath,args,{encoding:'utf8'});assert.equal(r.status,0);return {args,status:r.status,stdout:r.stdout,stderr:r.stderr}});
assert.equal(execFileSync('git',['branch','--show-current'],{encoding:'utf8'}).trim(),'main');
const report={status:'PASS-PACKAGE',controls:plan.controls,preserved_g22:plan.preserved.length,unchanged,runtime_entry:'scripts/sc03/main.pl',runtime_boundary:'PeTTa/MeTTa cognition; Prolog mechanics; no JavaScript or Python/Java invocation in inspected entry/membranes',runtime_sources:runtime.map(path=>({path,sha256:hash(fs.readFileSync(path))})),commands:results,semantic_fidelity_certified:false};
const out='evidence/SC03/closure-checks.json';assert(!fs.existsSync(out));fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({status:report.status,preserved_g22:report.preserved_g22,unchanged:unchanged.length,runtime_sources:runtime.length}));
