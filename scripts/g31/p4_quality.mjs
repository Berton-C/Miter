// Native changed-evidence controls for transport qualification.
import assert from 'node:assert/strict';
import {root,read,save,native,sexp} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'101';
const dir=`${root}/evidence/G31/p4-${tag}`;
assert.equal(read(`${dir}/run-verdict.json`).status,'PASS-BOUNDED');
const canonical=read(`${dir}/canonical-result.json`).observation;
const candidate=canonical[1],transport=canonical[2];
const cases={canonical,wrong_candidate:structuredClone(canonical),
  wrong_transport:structuredClone(canonical),unauthorized_leak:structuredClone(canonical),
  identity_changed:structuredClone(canonical),no_journal:structuredClone(canonical),
  no_restart:structuredClone(canonical),panic_failed:structuredClone(canonical),
  rollback_failed:structuredClone(canonical),external_target:structuredClone(canonical)};
cases.wrong_candidate[1]='0'.repeat(64);cases.wrong_transport[2]='f'.repeat(64);
cases.unauthorized_leak[4]='1';cases.identity_changed[7]='false';
cases.no_journal[11]='false';cases.no_restart[12]='false';
cases.panic_failed[13]='false';cases.rollback_failed[14]='false';
cases.external_target[15]='false';
const boot=`!(import! &self "${root}/src/bootstrap_surface_transport_qualification_v1.metta")\n`;
const rows=native(dir,'native-quality-controls',Object.entries(cases).map(([name,obs])=>
  `!(result ${name.replaceAll('_','-')} (P4TransportStanding ${sexp(obs)} ${sexp(candidate)} ${sexp(transport)}))`).join('\n'),boot);
const map=Object.fromEntries(rows.map(row=>[row[1],row[2]]));
assert.equal(map.canonical[0],'g31-p4-transport-qualified');
for(const name of ['wrong-candidate','wrong-transport','unauthorized-leak','identity-changed',
  'no-journal','no-restart','panic-failed','rollback-failed','external-target'])
  assert.equal(map[name][0],'g31-p4-transport-held',name);
save(`${dir}/quality-verdict.json`,{status:'PASS-BOUNDED',canonical_qualified:true,
  wrong_candidate_held:true,wrong_transport_held:true,unauthorized_leak_held:true,
  identity_change_held:true,missing_journal_held:true,missing_restart_held:true,
  failed_panic_held:true,failed_rollback_held:true,external_target_held:true,
  first_match_policy_not_used:true,model_calls:0,credential_lookups:0,
  local_mattermost_requests:0});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
