// Builder-side evidence/identity checker. Never imported by Miter cognition.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export const hash = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const need = (condition, message) => { if (!condition) throw Error(message); };
const text = value => typeof value === 'string' && value.trim().length > 0;
export function local(p) {
  need(text(p) && !path.isAbsolute(p), 'relative repository path required');
  const full = path.resolve(root, p);
  need(full.startsWith(root + path.sep), 'path escapes repository');
  return full;
}
const read = p => fs.readFileSync(local(p));
const json = p => JSON.parse(read(p));
const git = args => execFileSync('git', args, {cwd:root,encoding:'utf8'}).trim();
export function validatePlan(plan, readFile=read) {
  need(plan.schema === 'miter-build-plan-v1' && /^SC\d{2}$/.test(plan.gate), 'plan schema/gate');
  need(text(plan.claim) && text(plan.non_claims) && text(plan.rationale), 'bounded claim and rationale required');
  const expected = ['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md'];
  need(JSON.stringify(Object.keys(plan.controls).sort()) === JSON.stringify(expected.sort()), 'exactly two controls required');
  const ids = new Set();
  for (const name of expected) {
    const bytes = readFile(name);
    need(hash(bytes) === plan.controls[name], 'control changed: '+name);
    for (const m of bytes.toString().matchAll(/\b((?:C|S|FC|T)-\d{2,4})\b/g)) ids.add(m[1]);
  }
  need(Array.isArray(plan.requirements) && plan.requirements.some(x=>x.startsWith('C-')) && plan.requirements.some(x=>x.startsWith('S-')), 'both controls must participate');
  for (const id of plan.requirements) need(ids.has(id), 'unknown requirement: '+id);
  for (const key of ['reading','representation','consumer','falsifiers','scope_review','rollback','predecessor']) need(text(plan[key]), 'missing '+key);
  need(Array.isArray(plan.allowed_paths) && plan.allowed_paths.length, 'change scope required');
  for (const p of plan.allowed_paths) local(p);
  need(Array.isArray(plan.claim_ids) && plan.claim_ids.length && new Set(plan.claim_ids).size === plan.claim_ids.length, 'unique claim IDs required');
  need(Array.isArray(plan.preserved), 'preserved baseline required');
  for (const e of plan.preserved) need(hash(readFile(e.path))===e.sha256,'preserved work changed: '+e.path);
  need(readFile('MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md').equals(readFile('docs/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md')), 'Soul copies differ');
  return plan;
}
export function checkOpen(planPath) {
  const plan = validatePlan(json(planPath));
  const committed = execFileSync('git',['show','HEAD:'+planPath],{cwd:root});
  need(hash(committed)===hash(read(planPath)), 'plan not frozen in HEAD');
  return {status:'OPEN-PACKAGE-VALID',gate:plan.gate,plan:planPath,plan_sha256:hash(committed),plan_commit:git(['rev-parse','HEAD']),controls:plan.controls,semantic_fidelity_certified:false};
}
export function checkClose(closurePath) {
  const closure = json(closurePath), plan = validatePlan(json(closure.plan));
  need(closure.schema==='miter-build-closure-v1' && closure.gate===plan.gate, 'closure schema/gate');
  need(/^[a-f0-9]{40}$/.test(closure.plan_commit), 'plan commit required');
  const frozen = execFileSync('git',['show',closure.plan_commit+':'+closure.plan],{cwd:root});
  need(hash(frozen)===hash(read(closure.plan)), 'frozen plan changed');
  need(closure.status==='PASS-BOUNDED', 'cannot progress from unsuccessful closure');
  need(Array.isArray(closure.evidence) && closure.evidence.length>0, 'evidence required');
  for (const e of closure.evidence) need(hash(read(e.path))===e.sha256,'evidence changed: '+e.path);
  need(closure.claim_results?.length===plan.claim_ids.length, 'claim results incomplete');
  for (const id of plan.claim_ids) {
    const matches=closure.claim_results.filter(x=>x.id===id);
    need(matches.length===1 && ['PROVEN-HARNESS','PROVEN-RUNTIME'].includes(matches[0].status) && text(matches[0].limit), 'unproved/unqualified claim '+id);
  }
  for (const key of ['source_meaning','causal_evidence','substitution_audit','capability_and_constraint_audit','remaining_gaps']) need(text(closure.fidelity_review?.[key]), 'incomplete fidelity review: '+key);
  need(text(closure.reviewer) && text(closure.review_limits), 'review attribution/limits required');
  if (closure.next_plan) {
    const next = validatePlan(json(closure.next_plan));
    need(next.gate!==plan.gate, 'next plan repeats gate');
    need(next.predecessor===closurePath, 'next plan not linked to closure');
    need(JSON.stringify(next.controls)===JSON.stringify(plan.controls),'next plan controls differ');
  } else need(text(closure.terminal_reason),'next plan or terminal reason required');
  const changes=new Set([...git(['diff',closure.plan_commit,'--name-only']).split('\n'),...git(['ls-files','--others','--exclude-standard']).split('\n')].filter(Boolean));
  const preserved=new Set(plan.preserved.map(e=>e.path));
  for (const p of changes) if (!preserved.has(p)) need(plan.allowed_paths.some(a=>a.endsWith('/')?p.startsWith(a):p===a),'out-of-scope change: '+p);
  return {status:'CLOSURE-PACKAGE-VALID',gate:plan.gate,claims:closure.claim_results,next_plan:closure.next_plan??null,semantic_fidelity_certified:false};
}
if (process.argv[1]===fileURLToPath(import.meta.url)) {
  try {
    const [mode,p]=process.argv.slice(2);
    need(['open','close','plan'].includes(mode),'usage: check.mjs open|close|plan PATH');
    const result=mode==='open'?checkOpen(p):mode==='close'?checkClose(p):{status:'PLAN-VALID',gate:validatePlan(json(p)).gate,semantic_fidelity_certified:false};
    process.stdout.write(JSON.stringify(result,null,2)+'\n');
  } catch(error) { process.stderr.write(JSON.stringify({status:'FAIL',reason:error.message})+'\n'); process.exitCode=1; }
}
