// Native severed controls for the version-matched reconciliation standing.
import assert from 'node:assert/strict';
import {root, read, save, native, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G31/p2-${tag}`;
assert.equal(read(`${dir}/preflight-verdict.json`).status,
  'PASS-BOUNDED-HOLD');
const input = read(`${dir}/native-input.json`);
const [source, current, projected] = [input.source, input.current, input.projected];
const sourceMissingReturn = structuredClone(source);
sourceMissingReturn[3] = sourceMissingReturn[3].filter(x =>
  x !== 'duplicate-returns-existing-post');
const tooLate = structuredClone(projected);
tooLate[7] = 31;
const wrongPrincipal = structuredClone(projected);
wrongPrincipal[6] = false;
const missingJournal = structuredClone(projected);
missingJournal[8] = false;
const noMap = structuredClone(projected);
noMap[5] = ['field-maps'];
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_reconciliation_v1.metta")\n`;
const cases = {
  exact_projected:[source, 'v11-7-7', projected],
  wrong_version:[source, 'v11-7-6', projected],
  source_missing_return:[sourceMissingReturn, 'v11-7-7', projected],
  current_unmapped:[source, 'v11-7-7', current],
  retry_after_window:[source, 'v11-7-7', tooLate],
  wrong_principal:[source, 'v11-7-7', wrongPrincipal],
  missing_journal:[source, 'v11-7-7', missingJournal],
  missing_map:[source, 'v11-7-7', noMap]
};
const rows = native(dir, 'native-quality-controls',
  Object.entries(cases).map(([name, values]) =>
    `!(result ${name.replaceAll('_','-')} (RReconciliationAssessment ${sexp(values[0])} ${values[1]} ${sexp(values[2])}))`).join('\n'), boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2]]));
assert.equal(map['exact-projected'][3][1], 'eligible-for-bounded-mock-trial');
assert.equal(map['wrong-version'][1][1], 'unresolved-version');
assert.equal(map['wrong-version'][3][1], 'hold-before-live');
assert.equal(map['source-missing-return'][1][1], 'unresolved-source-relations');
for (const name of ['current-unmapped','retry-after-window','wrong-principal',
  'missing-journal','missing-map']) {
  assert.equal(map[name][2][1], 'revision-required', name);
  assert.equal(map[name][3][1], 'hold-before-live', name);
}
save(`${dir}/quality-verdict.json`, {
  status:'PASS-BOUNDED',
  exact_version_and_projected_mapping_eligible_for_mock:true,
  mismatched_version_held:true, missing_source_result_relation_held:true,
  current_unmapped_candidate_held:true, retry_after_window_held:true,
  changed_principal_held:true, missing_journal_held:true,
  missing_mapping_held:true, universal_exactly_once_never_claimed:true,
  local_mattermost_requests:0, credential_lookups:0,
  message_reads:0, message_writes:0, model_calls:0,
  limits:'Relational source/candidate comparison; no live destination trial'
});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
