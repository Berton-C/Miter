// Preserve the exploratory probe before generic implementation repairs.
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
const dir='evidence/SC01/probe-001';
fs.mkdirSync(dir,{recursive:true});
for(const f of ['raw.stdout','raw.stderr']) if(fs.existsSync(dir+'/'+f)) throw Error('refusing to overwrite evidence');
fs.copyFileSync('src/participation.metta',dir+'/participation.metta');
const r=spawnSync('/opt/homebrew/bin/swipl',['--stack_limit=1g','-q','-s','/private/tmp/miter-g06-petta-ae66fa8/src/main.pl','--',process.cwd()+'/tests/fixtures/sc01/probe.metta'],{encoding:'utf8',timeout:30000,maxBuffer:10*1024*1024});
fs.writeFileSync(dir+'/raw.stdout',r.stdout||'');fs.writeFileSync(dir+'/raw.stderr',r.stderr||'');
fs.writeFileSync(dir+'/status.json',JSON.stringify({exit:r.status,error:r.error?.message??null,claim:'exploratory observation, not acceptance',finding:'Final-only goals allow an intermediate loss followed by restoration; retain this output before correcting transition checks.'},null,2)+'\n');
console.log({exit:r.status,evidence:dir});
