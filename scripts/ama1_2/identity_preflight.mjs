// AMA-1.2 R2 read-only identity and exact-group preflight.

import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp, swi} from '../g22_v2/common.mjs';

process.chdir(root);
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.2/R2/plan.json';
const attempt = process.argv.find(value => /^\d{3}$/.test(value)) ?? '001';
const dir = `${root}/evidence/AMA-1.2/R2/identity-${attempt}`;
const privatePath = `${root}/config/local/ama1_2/multi-principal-binding-v1.json`;
assert.equal(checkOpen(plan).status, 'OPEN-PACKAGE-VALID');
assert(!fs.existsSync(dir), 'recorded evidence is immutable');
assert(!fs.existsSync(privatePath), 'private binding already exists');
fs.mkdirSync(dir, {recursive:true});

const config = read(`${root}/config/miter-assistant-mattermost-v1.example.json`);
const candidateHash = config.authority_lineage.candidate_sha256;
const transportHash = config.authority_lineage.transport_sha256;
const probe = `${root}/effect_membranes/miter_mattermost_multi_identity_probe_v1.pl`;
const q = value => `'${String(value).replaceAll("'", "''")}'`;
const visibilityGoal = `miter_mattermost_multi_identity_probe_v1:ama12_group_visibility(${q(config.surface.origin)},${q(config.surface.team_slug)},${q(config.principals.mattermost_credential_reference.service)},R),json_write_dict(current_output,R,[width(0)]),nl,halt`;
const visibilityProcess = spawnSync(swi,
  ['-q','-f','none','-s',probe,'-g',visibilityGoal],
  {cwd:root, encoding:'utf8', timeout:120000, maxBuffer:4*1024*1024});
assert.equal(visibilityProcess.status, 0,
  visibilityProcess.error?.message??visibilityProcess.stderr);
assert.equal(visibilityProcess.stderr, '');
const visibility = JSON.parse(visibilityProcess.stdout);
save(`${dir}/group-visibility.json`, visibility);
if (visibility.exact_berton_haley_miter_group_count !== 1) {
  save(`${dir}/verdict.json`, {
    schema:'miter-ama12-r2-identity-preflight-verdict-v1',
    status:'BLOCKED-EXACT-GROUP-NOT-UNIQUELY-VISIBLE',
    visible_channel_count:visibility.visible_channel_count,
    visible_group_count:visibility.visible_group_count,
    exact_group_count:visibility.exact_berton_haley_miter_group_count,
    stable_ids_public:false, credential_values_returned:false,
    post_content_reads:0, message_reads:0, message_writes:0, api_mutations:0,
    payload_cognition:'held', memory_admission:'held', model_use:'held', egress:'held',
    activated:false,
    next_boundary:'Make exactly one Mattermost group conversation containing berton_c, haley, and miter visible to the miter bot, then rerun the read-only preflight.'
  });
  console.log(JSON.stringify(read(`${dir}/verdict.json`)));
  process.exit(0);
}
const goal = `miter_mattermost_multi_identity_probe_v1:ama12_identity_probe(${q(dir)},${q(candidateHash)},${q(transportHash)},${q(config.surface.origin)},${q(config.surface.team_slug)},${q(config.surface.denied_control_channel_slug)},${q(config.principals.mattermost_credential_reference.service)},R),writeln(R),halt`;
const started = Date.now();
const processResult = spawnSync(swi, ['-q','-f','none','-s',probe,'-g',goal],
  {cwd:root, encoding:'utf8', timeout:120000, maxBuffer:4*1024*1024});
save(`${dir}/probe-process.json`, {
  status:processResult.status, signal:processResult.signal,
  error:processResult.error?.message??null, elapsed_ms:Date.now()-started,
  stdout:processResult.stdout?.trim()??'', stderr:processResult.stderr?.trim()??''
});
assert.equal(processResult.status, 0, processResult.error?.message??processResult.stderr);
assert.equal(processResult.stderr, '');

const publicResult = read(`${dir}/identity-redacted.json`);
const observationDocument = read(`${dir}/identity-observation.json`);
assert(fs.existsSync(privatePath));
assert.equal(fs.statSync(privatePath).mode & 0o777, 0o600);
const privateResult = read(privatePath);
assert.equal(privateResult.credential_value, null);
assert.equal(hash(fs.readFileSync(privatePath)), publicResult.private_record_sha256);
assert.deepEqual(publicResult.expected_principals, ['berton_c','haley','miter']);
assert.equal(publicResult.resolved.unique_group_count, 1);
assert.equal(publicResult.resolved.exact_three_members, true);
assert.equal(publicResult.post_content_reads, 0);
assert.equal(publicResult.message_writes, 0);
assert.equal(publicResult.api_mutations, 0);
assert.equal(publicResult.consent.haley, 'unresolved');
const publicText = JSON.stringify(publicResult)+JSON.stringify(observationDocument)+
  processResult.stdout+processResult.stderr;
const privateValues = [privateResult.server.id, privateResult.team.id,
  privateResult.carrier.id, privateResult.denied_control.id,
  privateResult.principals.berton.id, privateResult.principals.haley.id,
  privateResult.principals.bot.id];
for (const value of privateValues)
  assert(!publicText.includes(value), 'private stable identity leaked into public evidence');

const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v2.metta")\n`;
const rows = native(dir, 'native-identity-standing',
  `!(result standing (AMA12IdentityStanding ${sexp(observationDocument.native)} ${sexp(candidateHash)} ${sexp(transportHash)}))`, boot);
assert.equal(rows.length, 1);
const standing = rows[0][2];
assert.equal(standing[0], 'ama12-private-identity-bound');
save(`${dir}/native-standing.json`, {native:standing});

const sources = [plan, 'docs/operations/AMA-1.2-LIVE-GRANT.md',
  'config/miter-assistant-mattermost-v1.example.json',
  'src/mattermost_live_grant_v2.metta',
  'src/bootstrap_mattermost_live_grant_v2.metta',
  'effect_membranes/miter_mattermost_multi_identity_probe_v1.pl',
  'scripts/ama1_2/identity_preflight.mjs'];
save(`${dir}/manifest.json`, {
  schema:'miter-ama12-r2-identity-preflight-manifest-v1',
  files:pins([...sources.map(file=>`${root}/${file}`),
    `${dir}/identity-redacted.json`, `${dir}/identity-observation.json`,
    `${dir}/probe-process.json`, `${dir}/native-standing.json`]),
  private_record:{tracked:false, location:'config/local/ignored',
    mode:'0600', sha256:publicResult.private_record_sha256},
  credential_values_returned:false
});
save(`${dir}/verdict.json`, {
  schema:'miter-ama12-r2-identity-preflight-verdict-v1',
  status:'PASS-IDENTITY-BOUND-AWAITING-HALEY-DISCLOSURE',
  exact_group_membership:true, unique_group_count:1,
  stable_ids_public:false, private_record_mode:'0600',
  consent:{berton:'affirmed',haley:'unresolved'},
  payload_cognition:'held', memory_admission:'held', model_use:'held', egress:'held',
  request_count:publicResult.request_count, credential_lookups:1,
  credential_values_returned:false, post_content_reads:0, message_reads:0,
  message_writes:0, api_mutations:0, activated:false,
  native_standing:standing[0],
  next_boundary:'Haley must affirm the exact disclosure before ordinary payload cognition, memory admission, model use, egress, or the activation clock can begin.'
});
console.log(JSON.stringify(read(`${dir}/verdict.json`)));
