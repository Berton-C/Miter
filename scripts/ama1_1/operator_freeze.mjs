// Builder-side AMA-1.1 operator-freeze proof. Never imported by Miter.
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync, spawnSync} from 'node:child_process';
import {checkOpen} from '../fidelity/check.mjs';

const root = '/Users/claritymiter/miter';
const swi = '/opt/homebrew/bin/swipl';
const petta = '/private/tmp/miter-g06-petta-ae66fa8';
const pettaCommit = 'ae66fa8e41dcd5539d614706bd4e5cfb34f9608d';
const plan = 'docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/AMA-1.1/R1/plan.json';
const evidence = path.join(root, 'evidence/AMA-1.1/R1/operator-freeze-002');
const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'miter-ama11-operator-'));
const entry = path.join(temporaryRoot, 'operator-proof.metta');

const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const writeJson = (file, value) => fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);

assert.equal(fs.existsSync(evidence), false, 'operator-freeze evidence is immutable once recorded');
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(), pettaCommit);
assert.equal(execFileSync('/usr/bin/git', ['-C', petta, 'status', '--porcelain'], {encoding: 'utf8'}).trim(), '');
const opening = checkOpen(plan);
assert.equal(opening.status, 'OPEN-PACKAGE-VALID');

const contact = (id, occurrence, possibilities) => `(contact ${id} human-contact principal-a audience-a project-a ${occurrence} K0
  (encounter-configuration
    (D ((relation rel-choice contact support direct))
       ((distinction dist-owner available direct)))
    (Omega ((material-relation omega-agency (Gravity Love) support witness-a)))
    (I ((interface talk available direct)))
    (W ((thread undertaking-1 open direct)))
    (C ((soul-relation AgencyBalance material direct)))
    (present-context now direct)
    ((fact-view f1 (Gravity Love) (omega-agency) recognized direct))
    ((flourishing-view AgencyBalance rel-choice flourishing direct)
     (flourishing-view ConnectionDepth omega-agency beneficial-direction direct))
    (${possibilities})
    ((participant-contribution p1 model (scope principal-a audience-a project-a)
      (lineage model-1) (claim idea) candidate no-contact-no-movement-authority)))
  ())`;

const inquiry = `(possible-movement m1 inquiry (rel-choice omega-agency) (dist-owner) (talk)
  (AgencyBalance ConnectionDepth) (consequence-route response non-certifying) l2425-supported)`;
const defer = `(possible-movement m2 defer (rel-choice omega-agency) (dist-owner) (talk)
  (AgencyBalance ConnectionDepth) (consequence-route deferral non-certifying) l2425-supported)`;

const program = `!(import! &self "${root}/src/bootstrap_assistant_v1.metta")
!(bind! &canonical (new-space))
!(bind! &plural (new-space))
!(add-atom &canonical ${contact('evt-one', 'occurrence-one', inquiry)})
!(add-atom &plural ${contact('evt-two', 'occurrence-two', `${inquiry} ${defer}`)})
!(match &canonical $contact (result canonical (CPEncounter $contact ())))
!(match &plural $contact (result plural (CPEncounter $contact ())))
!(match &canonical $contact
  (result consequence
    (CPNextCut (CPMakeCut $contact ())
      (consequence consequence-1 m1 effect-none observed
        (D-delta ((relation rel-return consequence support direct))
                 ((distinction dist-return available direct)))
        (I-delta ((interface talk revisable consequence)))
        (W-delta ((thread undertaking-1 continued consequence)))
        (present-context after direct) direct))))
`;

fs.writeFileSync(entry, program);
const started = new Date().toISOString();
const run = spawnSync(swi,
  ['--stack_limit=2g', '-q', '-s', `${petta}/src/main.pl`, '--', entry, 'silent'],
  {cwd: root, encoding: 'utf8', timeout: 30000, maxBuffer: 32 * 1024 * 1024});

assert.equal(run.status, 0, run.error?.message ?? run.stderr);
assert.equal(run.signal, null);
assert.equal(run.stderr, '');
assert.match(run.stdout, /\(result canonical \(constitutive-encounter /);
assert.match(run.stdout, /\(movement-formed inquiry m1 /);
assert.match(run.stdout, /\(result plural \(constitutive-encounter /);
assert.match(run.stdout, /\(movement-plural-live /);
assert.match(run.stdout, /generated-standing m1 generated/);
assert.match(run.stdout, /generated-standing m2 generated/);
assert.match(run.stdout, /\(result consequence \(constitutive-cut /);
assert.match(run.stdout, /consequence-incorporated\)\)/);
assert.doesNotMatch(run.stdout, /\(partial |ERROR:/);

fs.mkdirSync(evidence, {recursive: true});
fs.copyFileSync(entry, path.join(evidence, 'operator-proof.metta'));
fs.writeFileSync(path.join(evidence, 'stdout.txt'), run.stdout);
fs.writeFileSync(path.join(evidence, 'stderr.txt'), run.stderr);
const sources = [
  'constitution/fact9_projection_v1.metta',
  'constitution/soul.metta',
  'constitution/soul_compass_v02.metta',
  'src/bootstrap_assistant_v1.metta',
  'src/constitutive_participation_v1.metta'
].map(relative => ({path: relative, sha256: sha256(path.join(root, relative))}));
writeJson(path.join(evidence, 'runtime.json'), {
  schema: 'miter-ama11-operator-runtime-v1',
  started_at_utc: started,
  completed_at_utc: new Date().toISOString(),
  swipl: execFileSync(swi, ['--version'], {encoding: 'utf8'}).trim(),
  petta_commit: pettaCommit,
  temporary_runtime_root: temporaryRoot,
  external_network_calls: 0,
  model_calls: 0,
  private_memory_reads: 0,
  sources
});
writeJson(path.join(evidence, 'verdict.json'), {
  schema: 'miter-ama11-operator-freeze-verdict-v1',
  status: 'PASS-BOUNDED',
  opening_status: opening.status,
  facts: {
    native_import_and_reduction: true,
    finite_constitutive_encounter: true,
    support_specific_fact9_expression: true,
    nine_flourishing_organization_non_scalar: true,
    one_generated_relation_constructs_movement: true,
    plural_generated_relations_remain_live: true,
    typed_consequence_constructs_next_cut: true
  },
  standing: 'Operator syntax and finite positive behavior only. No service, semantic adequacy, external effect, held-out falsifier, restart, or full AMA-1.1 claim is certified.',
  next_boundary: 'Freeze these operators before disclosing post-operator adversarial and carrier-neutral cases.'
});

console.log(JSON.stringify({status: 'PASS-BOUNDED', evidence}));
