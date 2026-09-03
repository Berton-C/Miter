// Offline negative controls for the two closed evidence-storage profiles.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {root, save} from '../g22_v2/common.mjs';

const tag = process.argv[2] ?? '351';
assert.match(tag, /^3\d{2}$/);
const dir = `${root}/evidence/G31/p3-${tag}`;
assert(fs.existsSync(`${dir}/manifest.json`));
const membrane = `${root}/effect_membranes/miter_surface_design_v1.pl`;
const succeeds = goal => {
  const run = spawnSync('/opt/homebrew/bin/swipl',
    ['-q','-f','none','-s',membrane,'-g',`${goal},halt`],
    {encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
  if (run.status === 0) assert.equal(run.stderr, '');
  return run.status === 0;
};

const temporary = fs.mkdtempSync(path.join(os.tmpdir(),'miter-g31-profile-'));
const target = path.join(temporary,'target');
const link = path.join(temporary,'link');
try {
  fs.mkdirSync(target);
  fs.symlinkSync(target,link,'dir');
  const results = {
    current_g31_manifest_verified:succeeds(`sd_verify('${dir}')`),
    g31_profile_exact:succeeds("sd_root_profile('/Users/claritymiter/miter/evidence/G31/p3-351',g31_p3)"),
    g29_profile_preserved:succeeds("sd_root_profile('/Users/claritymiter/miter/evidence/G29/attempt-901',g29)"),
    arbitrary_g31_root_rejected:!succeeds("sd_root_profile('/Users/claritymiter/miter/evidence/G31/arbitrary',_)"),
    wrong_g31_schema_rejected:!succeeds("sd_profile_manifest(g31_p3,_{schema:\"miter-g29-freeze-v1\",files:[]},_)"),
    missing_required_set_rejected:!succeeds("sd_profile_manifest(g31_p3,_{schema:\"miter-g31-p3-freeze-v1\",files:[]},R),sd_manifest_required_present(_{files:[]},R)"),
    changed_or_missing_pin_rejected:!succeeds("sd_manifest_pins_valid(_{files:[_{path:\"/private/tmp/miter-no-such-pin\",sha256:\"00\"}]})"),
    symlink_rejected:!succeeds(`sd_no_links('${link}','${temporary}')`),
    g29_required_contract_preserved:succeeds("sd_profile_manifest(g29,_{schema:\"miter-g29-freeze-v1\",files:[]},R),memberchk('config/surface-event-v1.json',R),memberchk('effect_membranes/miter_surface_design_v1.pl',R),\\+memberchk('src/mattermost_candidate_revision_v1.metta',R)")
  };
  for (const [name, value] of Object.entries(results)) assert.equal(value,true,name);
  save(`${dir}/storage-profile-quality.json`, {
    status:'PASS-BOUNDED', ...results,
    historical_g29_attempt_901_full_replay:false,
    historical_replay_limit:'Its immutable manifest pins the preceding source hash; the exact G29 root, schema, and required-set relations are tested directly.',
    credential_lookups:0, network_requests:0, persistent_fixture_writes:0
  });
  console.log(JSON.stringify(results));
} finally {
  fs.rmSync(temporary,{recursive:true,force:true});
}
