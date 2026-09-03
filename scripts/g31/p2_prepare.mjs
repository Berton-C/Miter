// Freeze exact Mattermost v11.7.7 sources and derive candidate applicability.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root, hash, checkOpen} from '../fidelity/check.mjs';
import {native, save, read, pins, sexp} from '../g22_v2/common.mjs';

process.chdir(root);
const tag = process.argv[2] ?? '001';
const checkout = path.resolve(process.argv[3] ?? '');
assert.match(tag, /^\d{3}$/);
assert(checkout !== root && fs.statSync(checkout).isDirectory());
const dir = `${root}/evidence/G31/p2-${tag}`;
assert(!fs.existsSync(dir));
fs.mkdirSync(`${dir}/references`, {recursive:true});
process.on('uncaughtException', error => {
  save(`${dir}/failure.json`, {message:error.message, stack:error.stack});
  console.error(error.stack);
  process.exitCode = 1;
});

const opening = checkOpen('docs/gates/G31/P2/plan.json');
assert.equal(opening.plan_commit,
  '560aa07ca88248712c27617f2f04e6ac7801946d');
save(`${dir}/opening.json`, opening);

const git = args => execFileSync('git', ['-C', checkout, ...args],
  {encoding:'utf8'}).trim();
const sourceCommit = git(['rev-parse', 'HEAD']);
assert.equal(sourceCommit, '2045acd92c40353abfc5ffff8ae1e0dd9d2e6737');
assert.equal(git(['describe', '--exact-match', '--tags', 'HEAD']), 'v11.7.7');
assert.equal(git(['status', '--porcelain']), '');
assert.equal(git(['remote', 'get-url', 'origin']),
  'https://github.com/mattermost/mattermost.git');

const referenceFiles = [
  'api/v4/source/definitions.yaml',
  'api/v4/source/posts.yaml',
  'server/channels/api4/post.go',
  'server/channels/app/platform/service.go',
  'server/channels/app/post.go',
  'server/channels/app/post_test.go',
  'server/platform/services/cache/lru.go',
  'server/platform/services/cache/provider.go',
  'server/public/model/config.go',
  'server/public/model/post.go',
  'webapp/channels/src/packages/mattermost-redux/src/actions/posts.ts'
];
for (const source of referenceFiles)
  assert(fs.statSync(`${checkout}/${source}`).isFile(), source);

function span(file, startPattern, endPattern=startPattern) {
  const lines = fs.readFileSync(`${checkout}/${file}`, 'utf8').split('\n');
  const start = lines.findIndex(line => line.includes(startPattern));
  assert(start >= 0, `${file}: ${startPattern}`);
  const relativeEnd = lines.slice(start).findIndex(line => line.includes(endPattern));
  assert(relativeEnd >= 0, `${file}: ${endPattern}`);
  return {path:file, start_line:start + 1, end_line:start + relativeEnd + 1,
    sha256:hash(fs.readFileSync(`${checkout}/${file}`))};
}
const observations = [
  span('server/public/model/post.go', 'PendingPostId string'),
  span('server/channels/app/post.go', 'pendingPostIDsCacheTTL =',
    'PendingPostIDsCacheSize ='),
  span('server/channels/app/post.go',
    'deduplicateCreatePost attempts', 'return actualPost, nil'),
  span('server/channels/app/post.go',
    'If we get this far, we\'ve recorded', 'SetWithExpiry(post.PendingPostId, savedPost.Id'),
  span('server/channels/app/post_test.go',
    'duplicate create post is idempotent', 'should have returned previously created post id'),
  span('server/channels/app/post_test.go',
    'duplicate create post after cache expires is not idempotent',
    'should have created new post id'),
  span('server/platform/services/cache/provider.go',
    'NewProvider creates a new CacheProvider', 'return NewLRU(opts), nil'),
  span('server/platform/services/cache/lru.go',
    'type LRU struct', 'items                  map[string]*list.Element'),
  span('server/public/model/config.go',
    'func (s *CacheSettings) SetDefaults()', 'CacheTypeLRU'),
  span('webapp/channels/src/packages/mattermost-redux/src/actions/posts.ts',
    'const pendingPostId =', 'pending_post_id: pendingPostId'),
  span('api/v4/source/posts.yaml', 'operationId: CreatePost',
    'required: true'),
  span('api/v4/source/definitions.yaml', 'pending_post_id:')
];
for (const [index, observation] of observations.entries()) {
  const lines = fs.readFileSync(`${checkout}/${observation.path}`, 'utf8').split('\n');
  const excerpt = lines.slice(observation.start_line - 1,
    observation.end_line).join('\n') + '\n';
  const evidencePath = `references/${String(index + 1).padStart(2, '0')}__${observation.path.replaceAll('/', '__')}.excerpt`;
  fs.writeFileSync(`${dir}/${evidencePath}`, excerpt);
  observation.evidence_path = evidencePath;
  observation.excerpt_sha256 = hash(Buffer.from(excerpt));
}
const sourceIndex = {
  schema:'miter-g31-mattermost-source-index-v1',
  repository:'https://github.com/mattermost/mattermost.git',
  tag:'v11.7.7', commit:sourceCommit,
  observations,
  interpretation:'Source establishes bounded cache-backed duplicate handling, not durable or universal exactly-once.'
};
save(`${dir}/source-index.json`, sourceIndex);

const candidatePath = `${root}/evidence/G29/attempt-901/candidate/extension/mattermost_bridge.pl`;
const candidateBytes = fs.readFileSync(candidatePath);
const candidateHash = hash(candidateBytes);
assert.equal(candidateHash,
  'dff6f402bab8089cf42799c5e0b731e03c73f42d7be2b676cea24039af53cb34');
const candidateText = candidateBytes.toString();
assert.match(candidateText, /body:_\{channel_id:CID, message:M\}/);
assert.match(candidateText, /idempotency_key:IK/);
assert.doesNotMatch(candidateText,
  /body:_\{[^}]*pending_post_id/s);
save(`${dir}/candidate-observation.json`, {
  schema:'miter-g31-candidate-effect-observation-v1',
  candidate_sha256:candidateHash,
  request_body_fields:['channel-id','message'],
  descriptor_envelope_fields:['idempotency-key'],
  request_field_maps:[],
  pending_post_id_in_request_body:false,
  observed_only_no_candidate_edit:true
});

const source = ['mattermost-reconciliation-source', 'v11-7-7', sourceCommit,
  ['post-json-field-pending-post-id', 'request-key-cached-before-create',
   'duplicate-returns-existing-post', 'in-flight-duplicate-reports-pending',
   'failed-create-removes-key', 'cache-window-30-seconds',
   'expired-key-may-create-new-post',
   'authorization-checked-before-existing-return'],
  ['cache-not-durable', 'cache-may-evict', 'server-restart-loses-lru',
   'same-authorized-principal-required', 'retry-after-window-may-duplicate']];
const current = ['effect-descriptor-view', candidateHash, 'v11-7-7',
  ['body-fields','channel-id','message'],
  ['envelope-fields','idempotency-key'], ['field-maps'], true, 30, true];
const projected = ['effect-descriptor-view', 'projected-revision-not-code',
  'v11-7-7', ['body-fields','channel-id','message','pending-post-id'],
  ['envelope-fields','idempotency-key'],
  ['field-maps',['map','idempotency-key','pending-post-id']], true, 30, true];
save(`${dir}/native-input.json`, {
  schema:'miter-g31-reconciliation-input-v1',
  source, observed_version:'v11-7-7', current, projected,
  standing:'admitted official source relations plus observed candidate shape'
});
const boot = `!(import! &self "${root}/src/bootstrap_mattermost_live_reconciliation_v1.metta")\n`;
const rows = native(dir, 'native-assessment',
  `!(result current (RReconciliationAssessment ${sexp(source)} v11-7-7 ${sexp(current)}))\n` +
  `!(result projected (RReconciliationAssessment ${sexp(source)} v11-7-7 ${sexp(projected)}))`, boot);
assert.equal(rows.length, 2);
save(`${dir}/native-result.json`, {native:rows});
const byName = Object.fromEntries(rows.map(row => [row[1], row[2]]));
assert.equal(byName.current[1][1], 'supported-qualified');
assert.equal(byName.current[2][1], 'revision-required');
assert(byName.current[2][3].includes('pending-post-id-in-request-body'));
assert(byName.current[2][3].includes('effect-key-mapped-to-pending-post-id'));
assert.equal(byName.current[3][1], 'hold-before-live');
assert.equal(byName.projected[2][1], 'qualified-bounded-retry');
assert.equal(byName.projected[3][1], 'eligible-for-bounded-mock-trial');

const referencePaths = observations.map(row => `${dir}/${row.evidence_path}`);
save(`${dir}/manifest.json`, {
  schema:'miter-g31-p2-freeze-v1', plan:'docs/gates/G31/P2/plan.json',
  plan_commit:opening.plan_commit,
  mattermost:{repository:'https://github.com/mattermost/mattermost.git',
    tag:'v11.7.7', commit:sourceCommit},
  files:pins([
    `${root}/CONSTITUTION.md`, `${root}/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md`,
    `${root}/BUILD_FIDELITY_PROTOCOL.md`, `${root}/docs/gates/G31/P2/plan.json`,
    `${root}/src/mattermost_live_reconciliation_v1.metta`,
    `${root}/src/bootstrap_mattermost_live_reconciliation_v1.metta`,
    `${root}/src/participation.metta`, `${root}/scripts/g31/p2_prepare.mjs`,
    `${root}/scripts/g31/p2_quality.mjs`, `${root}/scripts/g31/p2_verify.mjs`,
    candidatePath, `${dir}/source-index.json`,
    `${dir}/candidate-observation.json`, `${dir}/native-input.json`,
    `${dir}/native-result.json`, ...referencePaths]),
  official_source_fetches:1, local_mattermost_requests:0,
  docker_calls:0, credential_lookups:0, message_reads:0,
  message_writes:0, model_calls:0, candidate_edits:0
});
save(`${dir}/preflight-verdict.json`, {
  status:'PASS-BOUNDED-HOLD',
  version_matched_official_source:true,
  destination_mechanism:'pending_post_id-cache-deduplication',
  mechanism_standing:'supported-qualified', cache_window_seconds:30,
  current_candidate_standing:'revision-required',
  missing_candidate_relations:[
    'pending-post-id-in-request-body',
    'effect-key-mapped-to-pending-post-id'
  ],
  projected_shape_standing:'eligible-for-bounded-mock-trial',
  exactly_once_standing:'unproven', live_contact:false,
  local_mattermost_requests:0, credential_lookups:0,
  message_reads:0, message_writes:0, candidate_edits:0
});
console.log(JSON.stringify(read(`${dir}/preflight-verdict.json`)));
