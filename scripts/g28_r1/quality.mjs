// No inference. Counterexample semantics must not collapse missing observations.
import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,hash} from '../fidelity/check.mjs';import {native,read,save} from '../g22_v2/common.mjs';
const tag=process.argv[2]??'001';assert.match(tag,/^[0-9]{3}$/);const d=root+'/evidence/G28-R1/quality-'+tag;assert(!fs.existsSync(d));fs.mkdirSync(d);
save(d+'/freeze.json',{files:['src/executable_development_v2.metta','scripts/g28_r1/quality.mjs'].map(p=>({path:root+'/'+p,sha256:hash(fs.readFileSync(root+'/'+p))}))});
const boot=`!(import! &self "${root}/src/bootstrap_executable_development_v2.metta")\n`;
const good='(executable-trial-qualified () ())',unknown='(executable-trial-unqualified ((io-case sample payload (1))) ((io-incomplete sample unknown)))',wrong='(executable-trial-unqualified ((io-case sample payload (1))) ((io-observation sample 0 (2))))';
const rows=native(d,'counterexamples',`
!(result absent (YTrialFacts ${unknown} (process-incomplete candidate-smoke unknown)))
!(result mismatch (YTrialFacts ${wrong} (process-incomplete candidate-smoke unknown)))
!(result failed-process (YTrialFacts ${good} (process-observation candidate-smoke 1 "" "" false receipt)))
!(result passed-process (YTrialFacts ${good} (process-observation candidate-smoke 0 "" "" false receipt)))
!(result output-truncated (YSmokePassed (process-observation candidate-smoke 0 "" "" true receipt)))
!(result direct-counterexample (YCaseCounterexample (io-case sample payload (1)) ((io-observation sample 0 (2)))))
`,boot);
const v=Object.fromEntries(rows.map(x=>[x[1],x[2]]));assert.deepEqual(v.absent,[]);assert.deepEqual(v['passed-process'],[]);assert.deepEqual(v.mismatch,[['edge','discrepancy','specific']]);assert.deepEqual(v['failed-process'],v.mismatch);assert.equal(v['output-truncated'],'false');
save(d+'/verdict.json',{status:'PASS-BOUNDED',rows,new_model_calls:0,limits:'Finite observed-counterexample projection, not a general semantic diagnosis'});console.log(JSON.stringify(read(d+'/verdict.json')));
