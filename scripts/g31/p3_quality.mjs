// Re-evaluate candidate standing under causally changed relations.
import assert from 'node:assert/strict';
import {root, read, save, native, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '301';
const dir = `${root}/evidence/G31/p3-${tag}`;
assert.equal(read(`${dir}/run-verdict.json`).status, 'PASS-BOUNDED');
const input = read(`${dir}/input.json`).native;
const source = input[1];
const version = input[2];
const view = read(`${dir}/candidate-view.json`).native;
const mock = read(`${dir}/canonical-result.json`).mock;
const noMap = structuredClone(view); noMap[5] = ['field-maps'];
const tooLate = structuredClone(view); tooLate[7] = 31;
const noJournal = structuredClone(view); noJournal[8] = false;
const alteredMock = structuredClone(mock); alteredMock[5] = false;
const hiddenLimit = structuredClone(mock); hiddenLimit[7] = false;
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_candidate_revision_v1.metta")\n`;
const cases = {
  canonical:[source,version,view,mock],
  wrong_version:[source,'v11-7-6',view,mock],
  no_map:[source,version,noMap,mock],
  late_retry:[source,version,tooLate,mock],
  no_journal:[source,version,noJournal,mock],
  changed_receipt:[source,version,view,alteredMock],
  hidden_expiry_limit:[source,version,view,hiddenLimit]
};
const rows = native(dir, 'native-quality-controls',
  Object.entries(cases).map(([name, values]) =>
   `!(result ${name.replaceAll('_','-')} (G31P3TrialStanding ${sexp(values[0])} ${values[1]} ${sexp(values[2])} ${sexp(values[3])}))`).join('\n'), boot);
const map = Object.fromEntries(rows.map(row => [row[1],row[2]]));
assert.equal(map.canonical[0], 'g31-p3-candidate-qualified');
for (const name of ['wrong-version','no-map','late-retry','no-journal',
  'changed-receipt','hidden-expiry-limit'])
  assert.equal(map[name][0], 'g31-p3-candidate-held', name);
save(`${dir}/quality-verdict.json`, {
  status:'PASS-BOUNDED', canonical_qualified:true,
  wrong_version_held:true, missing_mapping_held:true,
  retry_after_window_held:true, missing_journal_held:true,
  changed_receipt_held:true, hidden_expiry_limit_held:true,
  order_or_first_match_policy_not_used:true,
  model_calls:0, local_mattermost_requests:0,
  mattermost_credentials:0,
  limits:'Native acceptance comparison over source, candidate, and causal mock relations'
});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
