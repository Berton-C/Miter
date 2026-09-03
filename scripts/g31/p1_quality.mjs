// Offline causal controls for corrected live-grant authority roles.
import assert from 'node:assert/strict';
import {root, read, save, native, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '101';
const dir = `${root}/evidence/G31/p1-${tag}`;
assert.equal(read(`${dir}/preflight-verdict.json`).status,
  'PASS-BOUNDED-HOLD');
const candidateHash = read(`${dir}/grant-input.json`).native[1];
const inventory = ['g31-service-inventory', 'retained-p0', 1,
  ['clarityclaw_mattermost'], 'retained-hash', false, 0, 0];
const complete = ['live-grant-v2', candidateHash, 'bounded-canary',
  'http://127.0.0.1:8065', 'server-id', 'team-id', 'channel-id',
  ['source-users', ['human-user-id']], 'bot-user-id',
  ['credential-ref', 'macos-keychain', 'bcb',
   'ai.bgi.miter.mattermost', 'bot-user-id'],
  ['posted', 'post-edited'], ['create-post'], 'exact-canary-payload',
  ['scope', 'server-id', 'team-id', 'channel-id', 'human-user-id'],
  ['voice-route', 'certified-movement', 'VoiceRNA', 'required'],
  ['transport-qualified', 'surface-transport-v1', 'transport-hash',
   'non-cognitive-prolog'],
  ['effect-reconciliation', 'destination-specific',
   'same-key-result-lookup-or-dedup', 'required'],
  ['journal', 'cursor'], ['journal', 'effects'], 'one-shot', 'expires-at',
  ['panic', 'local-fixed'], ['rollback', 'stop-and-restore'],
  ['revocation', 'immediate'], 'berton-explicit'];
assert.equal(complete.length, 25);
const variants = {
  complete,
  conflated:structuredClone(complete),
  wrong_binding:structuredClone(complete),
  no_voice:structuredClone(complete),
  no_transport:structuredClone(complete),
  no_reconciliation:structuredClone(complete),
  no_human_approval:structuredClone(complete),
  wrong_candidate:structuredClone(complete)
};
variants.conflated[7] = ['source-users', ['bot-user-id']];
variants.wrong_binding[9][4] = 'another-bot';
variants.no_voice[14] = 'unresolved';
variants.no_transport[15] = 'unresolved';
variants.no_reconciliation[16] = 'unresolved';
variants.no_human_approval[24] = 'unresolved';
variants.wrong_candidate[1] = '0'.repeat(64);
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const rows = native(dir, 'native-quality-controls',
  Object.entries(variants).map(([name, grant]) =>
    `!(result ${name.replaceAll('_','-')} (G31AssessGrant ${sexp(grant)} ${sexp(candidateHash)} ${sexp(inventory)}))`).join('\n'),
  boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2][0]]));
assert.equal(map.complete, 'g31-live-preflight-ready');
for (const name of ['conflated', 'wrong-binding', 'no-voice',
  'no-transport', 'no-reconciliation', 'no-human-approval',
  'wrong-candidate']) assert.equal(map[name], 'g31-live-preflight-held', name);
save(`${dir}/quality-verdict.json`, {
  status:'PASS-BOUNDED', complete_synthetic_shape_ready:true,
  conflated_source_and_bot_held:true, wrong_bot_credential_binding_held:true,
  missing_voice_held:true, missing_transport_held:true,
  missing_reconciliation_held:true, missing_human_approval_held:true,
  wrong_candidate_held:true, docker_calls:0, network_requests:0,
  credential_lookups:0,
  limits:'Correct authority representation only; synthetic fixture is not a live grant'
});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
