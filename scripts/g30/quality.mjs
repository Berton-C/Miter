// Native causal audit plus direct severed-arm comparison.
import assert from 'node:assert/strict';
import {root, read, save, native, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G30/attempt-${tag}`;
assert.equal(read(`${dir}/run-verdict.json`).status, 'PASS-BOUNDED');
const result = read(`${dir}/native-result.json`).native;
const observation = result[2][1];
const variants = {
  canonical:structuredClone(observation),
  unauthorized:structuredClone(observation),
  duplicate_create:structuredClone(observation),
  lost_restart:structuredClone(observation),
  no_effect_dedupe:structuredClone(observation)
};
variants.unauthorized[6] = false;
variants.duplicate_create[8] = 3;
variants.lost_restart[13] = 0;
variants.no_effect_dedupe[15] = false;
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_mock_trial_v1.metta")\n`;
const rows = native(dir, 'native-quality-controls',
  Object.entries(variants).map(([name, value]) =>
    `!(result ${name} (G30Assess ${sexp(value)}))`).join('\n'), boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2][0]]));
assert.equal(map.canonical, 'g30-mock-qualified');
for (const name of ['unauthorized', 'duplicate_create', 'lost_restart',
  'no_effect_dedupe']) assert.equal(map[name], 'g30-mock-unqualified', name);
const identity = read(`${dir}/severed-identity/summary.json`);
const idempotency = read(`${dir}/severed-idempotency/summary.json`);
assert.equal(identity.authorization_preceded_payload, false);
assert.equal(idempotency.duplicate_effect_suppressed, false);
save(`${dir}/quality-verdict.json`, {
  status:'PASS-BOUNDED', canonical_qualified:true,
  unauthorized_consequence_changes_assessment:true,
  duplicate_create_changes_assessment:true,
  lost_restart_changes_assessment:true,
  removed_effect_dedupe_changes_assessment:true,
  identity_severance_observed:true,
  idempotency_severance_observed:true,
  behavior_table_used:false,
  limits:'Finite independent G30 mock behavior only; no live or promoted surface'
});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
