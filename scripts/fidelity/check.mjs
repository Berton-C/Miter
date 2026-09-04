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
const seedControls = ['CONSTITUTION.md','MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md'];
const campaignControls = [...seedControls,'AUTHORITY_MAP.md','POC_SPEC.md','ACCEPTANCE.md','BUILD_FIDELITY_PROTOCOL.md','WORK_PROTOCOL.md','docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.md','docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.json'];
export const constitutiveStages = ['typed-contact','constitutive-cut','fact9-expression','flourishing-organization','generated-continuations','native-movement','bounded-participant-reentry','voice-and-effect','consequence-next-cut','restart-continuity'];
export const firstSliceBoundary = 'The first always-on slice may be bounded in external reach, deployment scale, and initially earned effect capabilities, but it must be complete in constitutive organization and open to general unfamiliar conversation, undertakings, endogenous participation, consequence, and continuity.';
const historicalPlan = plan => plan.schema === 'miter-build-plan-v1' && /^(?:SC\d{2}|G(?:[0-2]\d|3[0-3]))$/.test(plan.gate);
const campaignPlan = plan => plan.schema === 'miter-campaign-phase-plan-v1' && /^AMA-1\.[1-7]$/.test(plan.phase);
const targetOf = plan => campaignPlan(plan) ? plan.phase : plan.gate;
export function validatePlan(plan, readFile=read) {
  need(historicalPlan(plan) || campaignPlan(plan), 'plan schema/gate or phase');
  need(text(plan.claim) && text(plan.non_claims) && text(plan.rationale), 'bounded claim and rationale required');
  const campaign = campaignPlan(plan), expected = campaign ? campaignControls : seedControls;
  need(JSON.stringify(Object.keys(plan.controls).sort()) === JSON.stringify([...expected].sort()), campaign ? 'complete campaign controls required' : 'exactly two controls required');
  const ids = new Set();
  for (const name of expected) {
    const bytes = readFile(name);
    need(hash(bytes) === plan.controls[name], 'control changed: '+name);
    for (const m of bytes.toString().matchAll(/\b((?:C|S|FC|T|CA)-\d{2,4})\b/g)) ids.add(m[1]);
  }
  need(Array.isArray(plan.requirements) && plan.requirements.some(x=>x.startsWith('C-')) && plan.requirements.some(x=>x.startsWith('S-')), 'both controls must participate');
  if (campaign) need(plan.requirements.some(x=>x.startsWith('T-')) && plan.requirements.some(x=>x.startsWith('CA-')), 'campaign phase requires T and CA acceptance families');
  for (const id of plan.requirements) need(ids.has(id), 'unknown requirement: '+id);
  for (const key of ['reading','representation','consumer','falsifiers','scope_review','rollback','predecessor']) need(text(plan[key]), 'missing '+key);
  need(Array.isArray(plan.allowed_paths) && plan.allowed_paths.length, 'change scope required');
  for (const p of plan.allowed_paths) local(p);
  need(Array.isArray(plan.claim_ids) && plan.claim_ids.length && new Set(plan.claim_ids).size === plan.claim_ids.length, 'unique claim IDs required');
  need(Array.isArray(plan.preserved), 'preserved baseline required');
  for (const e of plan.preserved) need(hash(readFile(e.path))===e.sha256,'preserved work changed: '+e.path);
  need(readFile('MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md').equals(readFile('docs/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md')), 'Soul copies differ');
  if (campaign) {
    const frozenCampaign=JSON.parse(readFile('docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.json').toString());
    need(frozenCampaign.version==='1.1' && frozenCampaign.phases?.some(p=>p.id===plan.phase), 'phase absent from active campaign');
    need(plan.fidelity_checker?.path==='scripts/fidelity/check.mjs' && plan.fidelity_checker?.test_path==='scripts/fidelity/check.test.mjs', 'campaign fidelity checker identity required');
    need(hash(readFile(plan.fidelity_checker.path))===plan.fidelity_checker.sha256, 'campaign fidelity checker changed');
    need(hash(readFile(plan.fidelity_checker.test_path))===plan.fidelity_checker.test_sha256, 'campaign fidelity checker tests changed');
    need(Array.isArray(plan.constitutive_trace) && plan.constitutive_trace.length===constitutiveStages.length, 'complete F-09 constitutive trace required');
    need(JSON.stringify(plan.constitutive_trace.map(x=>x.stage))===JSON.stringify(constitutiveStages), 'F-09 stages/order changed');
    for (const row of plan.constitutive_trace) {
      need(Array.isArray(row.requirements) && row.requirements.length, 'trace requirements missing: '+row.stage);
      for (const id of row.requirements) need(ids.has(id), 'unknown trace requirement: '+id);
      for (const key of ['representation','consumer','expected_positive','material_severance','neutral','restoration','standing','successor_dependency']) need(text(row[key]), 'trace '+row.stage+' missing '+key);
    }
    if (plan.phase==='AMA-1.1') {
      need(plan.first_slice_boundary===firstSliceBoundary, 'AMA-1.1 first-slice boundary changed');
      for (const id of ['C-016','C-017','C-018',...Array.from({length:12},(_,i)=>'S-'+(1401+i)),...Array.from({length:12},(_,i)=>'T-'+(47+i)),...Array.from({length:9},(_,i)=>'CA-'+String(i+1).padStart(2,'0'))]) need(plan.requirements.includes(id), 'AMA-1.1 missing constitutive requirement: '+id);
    }
  }
  return plan;
}
export function checkOpen(planPath) {
  const plan = validatePlan(json(planPath));
  const committed = execFileSync('git',['show','HEAD:'+planPath],{cwd:root});
  need(hash(committed)===hash(read(planPath)), 'plan not frozen in HEAD');
  return {status:'OPEN-PACKAGE-VALID',target:targetOf(plan),...(campaignPlan(plan)?{phase:plan.phase}:{gate:plan.gate}),plan:planPath,plan_sha256:hash(committed),plan_commit:git(['rev-parse','HEAD']),controls:plan.controls,semantic_fidelity_certified:false};
}
export function checkClose(closurePath) {
  const closure = json(closurePath), plan = validatePlan(json(closure.plan));
  const campaign=campaignPlan(plan), target=targetOf(plan);
  need(closure.schema===(campaign?'miter-campaign-phase-closure-v1':'miter-build-closure-v1') && (campaign?closure.phase:closure.gate)===target, 'closure schema/target');
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
  const reviewKeys=['source_meaning','causal_evidence','substitution_audit','capability_and_constraint_audit','remaining_gaps'];
  if (campaign) reviewKeys.push('constitutive_participation','next_cut_and_restart');
  for (const key of reviewKeys) need(text(closure.fidelity_review?.[key]), 'incomplete fidelity review: '+key);
  if (campaign) {
    need(Array.isArray(closure.constitutive_trace_results) && closure.constitutive_trace_results.length===constitutiveStages.length, 'closure F-09 trace results incomplete');
    need(JSON.stringify(closure.constitutive_trace_results.map(x=>x.stage))===JSON.stringify(constitutiveStages), 'closure F-09 stages/order changed');
    for (const row of closure.constitutive_trace_results) need(['PROVEN-RUNTIME','FAIL','UNRESOLVED','PARTIAL'].includes(row.status) && text(row.evidence) && text(row.limit), 'invalid closure trace result: '+row.stage);
    need(closure.constitutive_trace_results.every(x=>x.status==='PROVEN-RUNTIME'), 'campaign phase cannot pass with unproved constitutive trace');
  }
  need(text(closure.reviewer) && text(closure.review_limits), 'review attribution/limits required');
  if (closure.next_plan) {
    const next = validatePlan(json(closure.next_plan));
    need(targetOf(next)!==target, 'next plan repeats target');
    need(next.predecessor===closurePath, 'next plan not linked to closure');
    need(JSON.stringify(next.controls)===JSON.stringify(plan.controls),'next plan controls differ');
  } else need(text(closure.terminal_reason),'next plan or terminal reason required');
  const changes=new Set([...git(['diff',closure.plan_commit,'--name-only']).split('\n'),...git(['ls-files','--others','--exclude-standard']).split('\n')].filter(Boolean));
  const preserved=new Set(plan.preserved.map(e=>e.path));
  for (const p of changes) if (!preserved.has(p)) need(plan.allowed_paths.some(a=>a.endsWith('/')?p.startsWith(a):p===a),'out-of-scope change: '+p);
  return {status:'CLOSURE-PACKAGE-VALID',target,...(campaign?{phase:plan.phase}:{gate:plan.gate}),claims:closure.claim_results,next_plan:closure.next_plan??null,semantic_fidelity_certified:false};
}
if (process.argv[1]===fileURLToPath(import.meta.url)) {
  try {
    const [mode,p]=process.argv.slice(2);
    need(['open','close','plan'].includes(mode),'usage: check.mjs open|close|plan PATH');
    const result=mode==='open'?checkOpen(p):mode==='close'?checkClose(p):(()=>{const plan=validatePlan(json(p));return {status:'PLAN-VALID',target:targetOf(plan),...(campaignPlan(plan)?{phase:plan.phase}:{gate:plan.gate}),semantic_fidelity_certified:false}})();
    process.stdout.write(JSON.stringify(result,null,2)+'\n');
  } catch(error) { process.stderr.write(JSON.stringify({status:'FAIL',reason:error.message})+'\n'); process.exitCode=1; }
}
