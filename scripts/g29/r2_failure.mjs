// Preserve and independently classify the exhausted R2 candidate failure.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {root,hash,read,save} from '../g22_v2/common.mjs';

const tag=process.argv[2]??'210';
const dir=`${root}/evidence/G29/attempt-${tag}`;
const final=read(`${dir}/final-r2.json`).native;
assert.equal(final[0],'surface-extension-incomplete-r2');
const assessment=final[1];
assert.equal(assessment[0],'surface-candidate-unqualified-r2');
const candidate=assessment[1];
assert.equal(candidate[2],'mattermost-r2');
const syntax=assessment[2][4];
const trial=assessment[3];
assert.deepEqual(syntax,['surface-candidate-syntax',0,1,false]);
assert.equal(trial[0],'surface-candidate-trial');
assert.equal(trial[1],1);
assert(trial[2]>0&&trial[3]>0);

const base=`${root}/runtime/g29/candidates/mattermost-r2`;
for(const file of candidate[6]){
  const source=`${base}/${file[1]}`;
  assert.equal(hash(fs.readFileSync(source)),file[3]);
  const destination=`${dir}/candidate/${file[1]}`;
  fs.mkdirSync(destination.slice(0,destination.lastIndexOf('/')),{recursive:true});
  fs.copyFileSync(source,destination);
}
for(const part of ['bridge-1','tests-2']){
  const observation=read(`${dir}/repair-${part}-observation.json`).native;
  assert.equal(observation[3],'eof');
  assert.equal(observation[4],200);
  assert.equal(observation[8],'artifact-shaped');
  const decoded=JSON.parse(observation[10]);
  const target=observation[2]==='bridge'?candidate[6][0]:candidate[6][1];
  assert.equal(decoded.content,target[2]);
  assert.equal(hash(Buffer.from(decoded.content)),target[3]);
}
const joined=candidate[6].map(x=>x[2]).join('\n').toLowerCase();
for(const token of ['chroma','miter_soul','src/soul','&soul','direct_memory'])assert(!joined.includes(token));
assert(!/bearer\s+[a-z0-9_-]{12,}/i.test(joined));
const docker='/Applications/Docker.app/Contents/Resources/bin/docker';
save(`${dir}/services-after.txt`,execFileSync(docker,['ps','--format','{{.ID}} {{.Names}}'],{encoding:'utf8',timeout:20000}));
assert.equal(fs.readFileSync(`${dir}/services-before.txt`,'utf8'),fs.readFileSync(`${dir}/services-after.txt`,'utf8'));
save(`${dir}/r2-failure-verdict.json`,{
  status:'FAIL-EVIDENCE',
  actual_new_model_calls:2,
  native_targets:['bridge','tests'],
  exact_model_bytes_preserved:true,
  bridge_load_code:syntax[1],
  combined_load_code:syntax[2],
  test_exit_code:trial[1],
  stderr_error_count:trial[2],
  failure_marker_count:trial[3],
  repeated_invalid_dict_terms:trial[6].includes("Type error: `dict' expected"),
  test_path_syntax_error:trial[6].includes('mattermost_contract_tests.pl:48:25: Syntax error'),
  boundary_scan_passed:true,
  credentials_used:0,
  mattermost_network_calls:0,
  candidate_promoted:false,
  consequence:'R2 resource slice exhausted; use a separately frozen plan and different already-configured local semantic resource rather than repeat qwen unchanged.'
});
console.log(JSON.stringify(read(`${dir}/r2-failure-verdict.json`)));
