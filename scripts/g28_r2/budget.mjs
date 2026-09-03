// An explicitly synthetic attempted call after all four retained slots are
// spent. Success means NO fifth request reached the model, not model success.
import fs from 'node:fs';import assert from 'node:assert/strict';
import {root,read,save,native} from '../g22_v2/common.mjs';
const d=root+'/evidence/G28-R2/attempt-004',E=root+'/evidence/G28-R2';
const claims=fs.readdirSync(E).filter(f=>/^call-[1-4]\.claim$/.test(f));assert.equal(claims.length,4);assert(!fs.existsSync(d+'/budget-probe-generation.json'));
const boot=`!(import! &self "${root}/src/bootstrap_executable_development_v3.metta")\n!(import_prolog_functions_from_file "${root}/scripts/g28_r2/boundaries.pl" (xb_exhausted_question))\n`;
const rows=native(d,'spent-grant',`
!(result exhausted (let* (($q (xb_exhausted_question "${d}")) ($s (add-atom &derived (executable-generation-pending "${d}" $q))) ($r (wz_model "${d}" $q)) ($c (remove-atom &derived (executable-generation-pending "${d}" $q)))) (wz_save "${d}" spent-grant-observation $r)))
`,boot);assert.equal(rows[0][2],'stored');const result=read(d+'/spent-grant-observation.json').native;assert.equal(result[0],'model-unavailable');assert(result[1].includes('model_grant_exhausted'));assert(!fs.existsSync(d+'/budget-probe-request.json'));assert(!fs.existsSync(d+'/budget-probe-wire.json'));assert.deepEqual(fs.readdirSync(E).filter(f=>/^call-[1-4]\.claim$/.test(f)),claims);
save(d+'/budget-verdict.json',{status:'PASS-BOUNDED',all_four_claims_retained:true,no_fifth_request:true,new_model_calls:0,synthetic_probe:true,observed:result});console.log(JSON.stringify(read(d+'/budget-verdict.json')));
