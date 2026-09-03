// Causal quality controls for the live-grant representation; no live effects.
import assert from 'node:assert/strict';
import {root, read, save, native, sexp} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '001';
const dir = `${root}/evidence/G31/p0-${tag}`;
assert.equal(read(`${dir}/preflight-verdict.json`).status, 'PASS-BOUNDED-HOLD');
const incomplete = read(`${dir}/grant-input.json`).native;
const candidateHash = incomplete[1];
const complete = ['live-grant', candidateHash, 'bounded-canary',
  'http://127.0.0.1:8065', 'server-id', 'team-id', 'channel-id',
  'bot-user-id', ['keychain-ref', 'account', 'service'],
  ['posted', 'post-edited'], ['create-post'], 'exact-canary-payload',
  ['scope', 'server-id', 'team-id', 'channel-id', 'bot-user-id'],
  ['journal', 'cursor'], ['journal', 'effects'], 'one-shot', 'expires-at',
  ['panic', 'local-fixed'], ['rollback', 'stop-and-restore'],
  ['revocation', 'immediate'], 'berton-explicit'];
assert.equal(complete.length, 21);
const missingChannel = structuredClone(complete);
missingChannel[6] = 'unresolved';
const wrongCandidate = structuredClone(complete);
wrongCandidate[1] = '0'.repeat(64);
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_grant_v1.metta")\n`;
const inventory = ['g31-service-inventory', 'fixture', 1,
  ['clarityclaw_mattermost'], 'fixture-hash', false, 0, 0];
const rows = native(dir, 'native-quality-controls',
  `!(result incomplete (G31AssessGrant ${sexp(incomplete)} ${sexp(candidateHash)} ${sexp(inventory)}))\n` +
  `!(result complete (G31AssessGrant ${sexp(complete)} ${sexp(candidateHash)} ${sexp(inventory)}))\n` +
  `!(result missing-channel (G31AssessGrant ${sexp(missingChannel)} ${sexp(candidateHash)} ${sexp(inventory)}))\n` +
  `!(result wrong-candidate (G31AssessGrant ${sexp(wrongCandidate)} ${sexp(candidateHash)} ${sexp(inventory)}))`,
  boot);
const map = Object.fromEntries(rows.map(row => [row[1], row[2]]));
assert.equal(map.incomplete[0], 'g31-live-preflight-held');
assert.equal(map.complete[0], 'g31-live-preflight-ready');
assert.equal(map['missing-channel'][0], 'g31-live-preflight-held');
assert.equal(map['wrong-candidate'][0], 'g31-live-preflight-held');
save(`${dir}/quality-verdict.json`, {
  status:'PASS-BOUNDED', incomplete_grant_held:true,
  complete_synthetic_shape_ready:true, missing_channel_held:true,
  wrong_candidate_held:true, effect_capability_exposed:false,
  credential_capability_exposed:false, network_capability_exposed:false,
  limits:'Grant representation only; synthetic completeness is not Berton approval'
});
console.log(JSON.stringify(read(`${dir}/quality-verdict.json`)));
