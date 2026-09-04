// Builder-side AMA-1.1 one-process reactor proof. Never imported by Miter.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const root = '/Users/claritymiter/miter';
const swi = '/opt/homebrew/bin/swipl';
const node = '/Users/bcb/.nvm/versions/node/v20.11.1/bin/node';
const petta = '/private/tmp/miter-g06-petta-ae66fa8';
const pettaCommit = 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d';
const operatorCommit = 'db0108013fb1a2630c8bc8061d316e43b8779175';
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const evidence = path.join(root, 'evidence/AMA-1.1/R1/reactor-freeze-002');
const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-reactor-'));
const entry = path.join(temporaryRoot, 'reactor-proof.metta');
const integrityReport = path.join(temporaryRoot, 'integrity-report.json');

const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const writeJson = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);

assert.equal(fs.existsSync(evidence), false, 'reactor-freeze evidence is immutable once recorded');
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(), pettaCommit);
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'status', '--porcelain'], {encoding: 'utf8'}).trim(), '');
assert.equal(execFileSync('/usr/bin/git', ['-C', root, 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(), operatorCommit);
const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');

const contact = `(contact evt-cycle human-contact principal-a audience-a project-a occurrence-cycle K0
  (encounter-configuration
    (D ((relation rel-choice contact support direct))
       ((distinction dist-owner available direct)))
    (Omega ((material-relation omega-agency (Gravity Love) support witness-cycle)))
    (I ((interface talk available direct)))
    (W ((thread undertaking-1 open direct)))
    (C ((soul-relation AgencyBalance material direct)))
    (present-context now direct)
    ((fact-view f-cycle (Gravity Love) (omega-agency) recognized direct))
    ((flourishing-view AgencyBalance rel-choice flourishing direct)
     (flourishing-view ConnectionDepth omega-agency beneficial-direction direct))
    ((possible-movement movement-cycle inquiry (rel-choice omega-agency)
      (dist-owner) (talk) (AgencyBalance ConnectionDepth)
      (consequence-route local-response non-certifying) l2425-supported))
    ((participant-contribution participant-cycle model
      (scope principal-a audience-a project-a) (lineage model-local)
      (claim semantic-reading) candidate no-contact-no-movement-authority)))
  ())`;

const program = `!(import! &self "${root}/src/bootstrap_assistant_v1.metta")
!(bind! &test-clock (new-space))
!(bind! &test-batch (new-space))
!(bind! &test-proof (new-space))
!(bind! &test-consequence (new-space))
!(add-atom &test-clock (test-counter 0))
!(add-atom &test-batch (test-batch ((assistant-input contact ${contact}))))
!(add-atom &test-consequence
  (test-batch ((assistant-input consequence (scope principal-a audience-a project-a)
    (consequence consequence-cycle movement-cycle effect-none observed
      (D-delta ((relation rel-return consequence support direct))
               ((distinction dist-return available direct)))
      (I-delta ((interface talk revisable consequence)))
      (W-delta ((thread undertaking-1 continued consequence)))
      (present-context after direct) direct)))))
(= (TestCount) (collapse (match &test-clock (test-counter $n) $n)))
(= (TestControl $root)
  (let* (($rows (TestCount)) ($n (index-atom $rows 0)) ($next (+ $n 1))
         ($removed (remove-atom &test-clock (test-counter $n)))
         ($added (add-atom &test-clock (test-counter $next))))
    (if (< $n 2) (assistant-control continue (cycle $n))
      (assistant-control stop (cycle $n)))))
(= (TestInput $root)
  (let $rows (TestCount)
    (if (== (index-atom $rows 0) 1)
      (index-atom (collapse (match &test-batch (test-batch $inputs) $inputs)) 0) ())))
(= (TestCheckpoint $root $snapshot)
  (let $added (add-atom &test-proof (checkpoint $snapshot)) checkpointed))
(= (TestWait $root $seconds)
  (let $added (add-atom &test-proof (waited $seconds)) waited))
(= (TestRecord $root $kind $payload)
  (let $added (add-atom &test-proof (record $kind $payload)) recorded))
(= (TestPanic $root) (assistant-control panic operator-panic))
!(result boot (SoulBoot "${integrityReport}"))
!(result loop (AssistantCycleWith test-root false 0.01 0.01 0.04
  TestControl TestInput TestCheckpoint TestWait TestRecord))
!(result restore-nonempty (AssistantRestore (AssistantSnapshot)))
!(match &test-consequence (test-batch $inputs)
  (result consequence (AssistantCycleStep $inputs)))
!(result active-count
  (size-atom (ARActiveRows (scope principal-a audience-a project-a))))
!(result panic (AssistantCycleWith test-root false 0.01 0.01 0.04
  TestPanic TestInput TestCheckpoint TestWait TestRecord))
!(result proof (collapse (match &test-proof $atom $atom)))
!(result snapshot (AssistantSnapshot))
`;

fs.writeFileSync(entry, program);
const started = new Date().toISOString();
const run = spawnSync(swi,
  ['--stack_limit=2g', '-q', '-s', `${petta}/src/main.pl`, '--', entry, 'silent'],
  {cwd: root, encoding: 'utf8', timeout: 30000, maxBuffer: 48 * 1024 * 1024});

assert.equal(run.status, 0, run.error?.message ?? run.stderr);
assert.equal(run.signal, null);
assert.equal(run.stderr, '');
assert.match(run.stdout, /\(result boot soul-ready\)/);
assert.match(run.stdout, /\(result loop \(assistant-stopped \(cycle 2\)\)\)/);
assert.match(run.stdout, /\(result restore-nonempty assistant-restore-rejected\)/);
assert.match(run.stdout, /\(waited 0\.01\)/);
assert.match(run.stdout, /\(record assistant-cycle \(cycle-standing true false checkpointed\)\)/);
assert.match(run.stdout, /\(record assistant-cycle \(cycle-standing false false checkpointed\)\)/);
assert.match(run.stdout, /assistant-consequence-incorporated consequence-cycle/);
assert.match(run.stdout, /consequence-incorporated/);
assert.match(run.stdout, /\(result active-count 1\)/);
assert.match(run.stdout, /\(result panic \(assistant-panicked operator-panic\)\)/);
assert.match(run.stdout, /\(assistant-history encounter evt-cycle .*\(encounter-incorporated /);
assert.match(run.stdout, /\(assistant-history consequence consequence-cycle /);
assert.doesNotMatch(run.stdout, /\(partial |ERROR:/);
assert.doesNotMatch(fs.readFileSync(path.join(root, 'src/assistant_reactor_v1.metta'), 'utf8'), /\$steps|supplied-step|step-count/);

const integrity = JSON.parse(fs.readFileSync(integrityReport, 'utf8'));
assert.equal(integrity.result, 'soul-integrity-verified');
fs.mkdirSync(evidence, {recursive: true});
fs.copyFileSync(entry, path.join(evidence, 'reactor-proof.metta'));
fs.copyFileSync(integrityReport, path.join(evidence, 'integrity-report.json'));
fs.writeFileSync(path.join(evidence, 'stdout.txt'), run.stdout);
fs.writeFileSync(path.join(evidence, 'stderr.txt'), run.stderr);
const sources = [
  'constitution/authority-manifest.json',
  'constitution/fact9_projection_v1.metta',
  'constitution/soul.metta',
  'constitution/soul_compass_v02.metta',
  'src/soul.metta',
  'src/bootstrap_assistant_v1.metta',
  'src/constitutive_participation_v1.metta',
  'src/assistant_reactor_v1.metta',
  'effect_membranes/miter_integrity.pl'
].map(relative => ({path: relative, sha256: sha256(path.join(root, relative))}));
writeJson(path.join(evidence, 'runtime.json'), {
  schema: 'miter-ama11-reactor-runtime-v1',
  started_at_utc: started,
  completed_at_utc: new Date().toISOString(),
  node: execFileSync(node, ['--version'], {encoding: 'utf8'}).trim(),
  swipl: execFileSync(swi, ['--version'], {encoding: 'utf8'}).trim(),
  petta_commit: pettaCommit,
  operator_commit: operatorCommit,
  temporary_runtime_root: temporaryRoot,
  external_network_calls: 0,
  model_calls: 0,
  private_memory_reads: 0,
  sources
});
writeJson(path.join(evidence, 'verdict.json'), {
  schema: 'miter-ama11-reactor-freeze-verdict-v1',
  status: 'PASS-BOUNDED',
  opening_status: opening.status,
  facts: {
    current_soul_integrity_identity_verified: true,
    one_petta_process_recurs_until_explicit_stop: true,
    typed_contact_uses_constitutive_encounter: true,
    empty_cycle_waits_without_inventing_work: true,
    no_supplied_step_count: true,
    compact_native_history_retained: true,
    linked_consequence_changes_active_cut: true,
    operator_panic_terminates_native_recurrence: true
  },
  standing: 'Native one-process recurrence and in-memory state only. No persistent service, external effect, process supervision, restart rehydration, model call, natural-language sufficiency, or full AMA-1.1 claim is certified.',
  next_boundary: 'Add the explicit-root Prolog service membrane and operator surface without moving any semantic choice out of MeTTa.'
});

console.log(JSON.stringify({status: 'PASS-BOUNDED', evidence}));
