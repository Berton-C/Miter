# BGI Miter PoC — ChatGPT Work Construction Protocol

**Version:** 0.1 Draft  
**Date:** 2026-09-01  
**Status:** Normative construction discipline  
**Applies to:** ChatGPT Work, Codex, human collaborators, and any model-assisted implementation process operating in the Miter repository

---

## 0. Mission

Build the smallest system that satisfies `ACCEPTANCE.md` without weakening `CONSTITUTION.md`, importing unearned authority, or hiding uncertainty behind plausible code.

The construction agent is not the architect of last resort. It is an implementation and evidence agent operating under fixed authority.

The governing maxim is:

> **Implement one bounded claim. Prove it in the actual runtime. Preserve the raw evidence. Then move.**

---

# I. Authority and write permissions

## W-001 — Required reading order

Before Task 00, read in this order:

1. `CONSTITUTION.md`
2. `AUTHORITY_MAP.md`
3. `POC_SPEC.md`
4. `ACCEPTANCE.md`
5. `WORK_PROTOCOL.md`
6. `FAST_PATH.md`
7. `SOURCE_MATERIALS_CHECKLIST.md`
8. `DECISIONS.md`
9. `HEADLONG_INHERITANCE.md`
10. `README.md`

Before each gate, reread:

- the gate in `ACCEPTANCE.md`;
- every `C-` law referenced by that gate;
- the relevant `P-` specification sections;
- the relevant proven substrate constraints in this document.

## W-002 — Human-controlled files

The implementation agent may not edit:

```text
CONSTITUTION.md
ACCEPTANCE.md
AUTHORITY_MAP.md
```

It may not silently edit `POC_SPEC.md` to fit an implementation. If the specification proves wrong or underspecified, stop and create a proposed decision entry under `proposals/` or present the issue to the human.

## W-003 — Decision changes

A design change requires:

1. exact conflict or missing fact;
2. raw evidence;
3. affected law/spec/gate IDs;
4. at least two alternatives;
5. expected consequences;
6. human decision recorded in `DECISIONS.md`;
7. only then, a new implementation attempt.

## W-004 — One gate per task

A Work task implements one gate or one explicitly named prerequisite nugget. It must not opportunistically build later subsystems.

## W-005 — No acceptance by narration

Phrases such as these have no evidential standing:

```text
should work
looks correct
appears wired
is architecturally sound
passes by inspection
likely persists
the model says it succeeded
```

Convert each claim into an observable test or mark it unproven.

---

# II. Per-gate operating sequence

## W-010 — Gate opening declaration

Before modifying code, print and save:

```text
GATE:
REQUIREMENT IDS:
CONSTITUTIONAL LAWS:
FILES EXPECTED TO CHANGE:
FILES FORBIDDEN TO CHANGE:
POSITIVE FIXTURE:
NEGATIVE CONTROL:
EXPECTED OBSERVABLE DIFFERENCE:
CURRENT UNPROVEN ASSUMPTIONS:
ROLLBACK METHOD:
```

## W-011 — Repository preflight

Before every gate:

1. `git status --short`;
2. current branch and commit;
3. source/service versions;
4. active processes relevant to the gate;
5. hashes of protected files;
6. backup/snapshot of mutable external state when applicable.

If the tree contains unexplained changes, stop.

## W-012 — Hypothesis before experiment

State the mechanism being tested and both polar outcomes before running the probe.

Example:

```text
Hypothesis: remove-by-variable clears all cap-efficacy atoms for one capability.
Positive expectation: three values become zero matches after one remove.
Negative expectation: removing a different capability leaves all three unchanged.
```

## W-013 — Smallest reversible probe

When an unproven substrate behavior blocks a gate, do not build around it. Create a minimal isolated probe against known-clean state.

A probe:

- changes one variable;
- has a control;
- has exact expected output;
- runs in the same runtime context as production;
- preserves raw output;
- restores state afterward.

## W-014 — Separate mutation and verification

Never trust a mutation expression's returned value. Verify the stored result in a separate command or process step using a proven read instrument.

## W-015 — Positive and severed arms

Every constitutive claim requires:

- canonical arm;
- otherwise-identical severed arm;
- predeclared expected difference.

A component whose removal never changes a discriminating result is not yet proven constitutive.

## W-016 — Evidence first, interpretation second

Save raw output before writing a summary. The summary must cite file paths and exact values.

## W-017 — Commit discipline

One gate may use multiple commits, but each commit must be coherent and reversible. The final gate commit includes:

- implementation;
- fixtures;
- verifier;
- evidence manifest reference;
- documentation of newly proven substrate behavior, if any.

Do not squash away failed experiments whose history is required by the PoC's developmental evidence. Failed candidate worktrees may be preserved outside main while their result events remain canonical.

---

# III. Status vocabulary

Every implementation claim receives exactly one status:

- `SOURCE` — directly present in an authority/source artifact.
- `PROVEN-RUNTIME` — reproduced in the actual Miter runtime with raw evidence.
- `PROVEN-HARNESS` — reproduced in an isolated harness, not yet wired live.
- `SPECIFIED` — design contract exists; implementation not proven.
- `EXPERIMENTAL` — bounded implementation under test.
- `ASSUMED` — believed but not tested; never load-bearing.
- `UNKNOWN` — no reliable evidence.
- `REJECTED` — disproven or constitutionally forbidden.

Do not use “done” without the gate ID and evidence run ID.

---

# IV. PeTTa/MeTTa substrate rules

These rules are inherited from the supplied Atom Operations Map and must govern code until the pinned PeTTa version proves otherwise.

## W-020 — Scalar-safe reads

Safe read pattern:

```metta
(match &self (cap-efficacy $name (stv $s $c)) $s)
(match &self (cap-efficacy $name (stv $s $c)) $c)
(match &self (cap-efficacy $name (stv $s $c)) $name)
```

Do not return nested compounds or an entire `(stv ...)` as a load-bearing read unless a new probe proves that exact shape safe in the pinned runtime.

Read compound fields individually.

## W-021 — `match` cardinality

`match` returns:

- zero matches → clean empty result;
- one match → one result;
- many matches → every binding.

Repeated scalar results can reveal duplicate atoms. Count by list length only where the return shape is proven scalar/symbol.

## W-022 — `add-atom` duplicates

`add-atom` is not idempotent. Adding an identical atom creates a duplicate.

Forbidden writer shape:

```metta
(add-atom &self (cap-efficacy $cap $new))
```

when an old value may exist.

## W-023 — Canonical mutable-atom writer

For a single-valued atom family, the approved pattern is:

```metta
(remove-atom &self (cap-efficacy $cap $any-old-value))
(add-atom &self (cap-efficacy $cap $new-value))
```

The variable-value remove clears every stale or duplicate value before adding exactly one replacement.

Afterward, verify through a separate scalar read and count.

## W-024 — `set-atom!` is unsafe for stale-source replacement

`set-atom!` creates a new atom when its source does not match. It must not be used where the old value may have drifted or duplicated.

Any use requires an explicit gate-local justification and proof of source cardinality.

## W-025 — Writes are in-process unless made durable

AtomSpace mutation survives only for the life/context proven by the actual loop. Durable state must be written to the canonical durable surface and reloaded on restart.

Do not confuse:

```text
computed
stored in AtomSpace
persisted to disk
rehydrated after restart
```

Each is a separate claim and test.

## W-026 — Absolute paths for durable file writes

Do not assume process working directory. Resolve and record absolute runtime paths under the configured Miter state root.

## W-027 — `superpose` containment

A bare `superpose` in a `let*` binding exposes open choice points. Downstream failure can replay intervening effects.

Unless multiplication is explicitly intended and tested, use the certified shape:

1. guard the empty case;
2. wrap iteration in `collapse`;
3. isolate effects outside nondeterministic branches.

## W-028 — Partial clause tables fail silently

A call to a function with no matching clause can silently kill the enclosing `let*` chain.

Guard partial tables with a total wrapper or collapse-and-branch pattern. Every public function must define behavior for unknown/malformed input.

## W-029 — Failing binding stops the chain

A non-throwing failed binding aborts later bindings silently. Use sentinel bisection to localize a dead corridor.

## W-030 — Nested ordinary calls in `let` bindings

Do not assume `(f (g x))` reduces inside an ordinary binding. Sequence nested ordinary calls:

```metta
(let $gx (g $x)
  (let $result (f $gx)
    ...))
```

Core forms may compose differently; rely only on proven patterns.

## W-031 — Typed-function silent guards

A typed call with undeclared-symbol arguments may silently fail because call-site type guards become control flow.

For runtime-minted symbols or open vocabularies:

- avoid inappropriate typed corridors;
- declare symbols where finite and stable;
- or use a proven untyped adapter with explicit validation.

Do not interpret silence as a legitimate branch result.

## W-032 — Explicit NAL operations

At load-bearing learning seams, call the intended operator directly, such as `Truth_Revision`, rather than relying on a broad wrapper whose nondeterministic rule family may return multiple derivations.

Read and persist the revised STV through proven scalar-safe and remove/add writer patterns.

## W-033 — STV is not p-bit by shape

No generic adapter may treat an NAL STV and a graded regulatory p-bit as semantically identical merely because both have two coordinates.

Every conversion names:

- source semantics;
- target semantics;
- purpose;
- mapping version;
- provenance;
- information lost.

## W-034 — Pure engine / governed writer split

Computation libraries do not write state. Writers do not invent semantic judgments. Keep:

```text
pure read/classification
→ candidate result
→ governed writer
→ separate verification
```

---

# V. Native membrane rules

## W-040 — No `py-call` in the Miter core

The core acceptance path may not import or call Python through PeTTa/Janus.

This does not ban:

- an external ChromaDB server implemented in Python;
- an extension/tentacle implemented in Python when chosen through the workshop;
- Python used offline by a human as a reference or migration utility, outside the Miter runtime path.

The claim tested is architectural: no meaning-bearing cognitive transition crosses an in-process MeTTa/Python seam.

## W-041 — Prolog membrane scope

Prolog may perform only deterministic mechanics such as:

- HTTP/JSON transport;
- service discovery and health;
- atomic file append/write/rename/fsync;
- hashing;
- process status/control;
- exact lexicon lookup;
- sandbox broker invocation;
- stable ID/time generation.

Prolog may not decide:

- which model question matters;
- what a response means;
- whether Soul alignment holds;
- whether a memory should be admitted;
- whether a candidate deserves promotion;
- whether an external action is lawful.

## W-042 — Typed membrane results

Every boundary defines:

```text
request type
response type
error type
version
request ID
idempotency key where effectful
timeout/cancellation behavior
```

Avoid passing large provider-specific nested structures directly through the MeTTa/Prolog return boundary. Prefer opaque request IDs plus scalar accessors where required by the runtime's marshalling behavior.

## W-043 — No shell workaround for core services

Do not replace a proper HTTP/store predicate with arbitrary `shell("curl ...")` or command-string parsing merely to avoid writing the membrane.

## W-044 — Secrets

Secrets remain in service-specific environment or keychain configuration. MeTTa may refer to a credential profile name; it may not read or render the secret.

Secret scanning is mandatory after every extension candidate and before evidence packaging.

---

# VI. Long-term memory and Continuity of Mind rules

## W-050 — Canonical order of memory authority

For exact continuity:

```text
append-only trajectory
→ structured continuity capsule
→ admitted memory document
→ Chroma semantic index
→ temporary context projection
```

A lower surface may help locate a higher one. It may not replace its authority.

## W-051 — Chroma is not the only copy

Every Chroma document references a durable source memory/event/capsule whose content hash can be verified.

Deleting a test Chroma collection must not destroy canonical memory.

## W-052 — Existing collections are read-only until migrated

The user's existing ClarityOmega memory and `nrc_vad_full` assets are not modified during bootstrap. Inventory, safe-copy, and migration tests precede any write.

The seed PoC creates its own collection.

## W-053 — Embedding identity

Every collection and memory record carries:

- embedding model ID;
- vector dimension;
- normalization;
- chunking version;
- distance metric;
- collection schema version.

Do not mix embeddings from different profiles in one collection.

## W-054 — Memory admission

Do not automatically remember every prompt, output, or model thought.

A memory candidate must include:

- why it matters later;
- type;
- scope;
- source event;
- provenance;
- durability standing;
- correction/supersession relation;
- raw-artifact link when appropriate.

## W-055 — Project continuity capsule

A project capsule must preserve exact operational state:

```text
project ID
project name
current artifact and hash
current anchor/section
current goal
last completed movement
open questions/tensions
intended next movement
dependencies
scope
previous capsule
source events
timestamp
```

Do not rely on a prose summary alone for “where did I leave off?”

## W-056 — Additive correction

Correction creates a new memory/capsule that supersedes an earlier one. Do not overwrite the historical record.

## W-057 — Scoped recall

Filter by authenticated person, relationship, project, and surface scope before semantic ranking. A closer vector match does not override access scope.

## W-058 — Context projection

Context is assembled for a declared question and RNA species. It should include:

- current constitutional excerpt needed by the process;
- exact active capsule/commitment;
- recent verbatim events;
- older admitted summaries;
- selected raw retrieval links;
- uncertainty and provenance.

Do not dump the entire memory collection into the LLM.

## W-059 — Tiered compaction is additive

Compaction creates summaries/projections but preserves raw history and source links. Summaries may be regenerated.

## W-060 — Chroma failure mode

If Chroma is unavailable:

- exact continuity from capsules/trajectory remains available;
- semantic enrichment is marked unavailable;
- no empty result is silently treated as “Miter remembers nothing.”

---

# VII. VAD and human-contact rules

## W-070 — Asset handling

The NRC VAD lexicon is a private local licensed research asset. Do not commit, copy into evidence, expose through an API to third parties, or include in generated extension packages.

Record only:

- local path;
- version;
- checksum;
- derived values for committed test phrases where licensing permits;
- attribution and acquisition instructions.

## W-071 — Lexical association, not person fact

Name outputs `AffectCue` or `AffectiveLanguageTrajectory`, not “true emotion” or “inner-state fact.”

## W-072 — Coverage and ambiguity

Every VAD result reports coverage and unknown terms. Low coverage yields uncertainty, not a confident neutral state.

## W-073 — MWE before unigram

Use deterministic longest-match handling for multi-word expressions before unigram fallback. Record which terms matched.

## W-074 — Trajectory and comparison

Do not use one sentence's average VAD as a sovereign reading. Preserve clause movement, pivot, contradiction, minimization, and comparative history where the fixture supports them.

## W-075 — Permission independence

No VAD output may change whether a requested task is permitted. It may influence presence, attention, clarification, and voice-audit requirements.

---

# VIII. Local model and VoiceRNA rules

## W-080 — Model aliases, not display assumptions

Discover exact LM Studio model IDs at runtime and map them to local aliases. Store aliases in ignored config.

## W-081 — Bounded role

Every model call identifies one bounded role:

```text
semantic reading
voice rendering
voice repair
candidate generation
extension implementation
independent review
```

A model call may not silently combine proposer, evaluator, writer, and constitutional authority.

## W-082 — Schema before prose parsing

Use structured output/schema where the service supports it. Reject malformed results mechanically.

## W-083 — Raw and interpreted separation

Store:

- raw provider response;
- parsed typed product;
- native interpretation/adjudication;

as different artifacts.

## W-084 — Voice intention is native

The LLM receives a `CommunicativeIntention` and rendering constraints. It does not determine the task verdict or Soul stance.

## W-085 — Structured defects

VoiceAudit returns named defects, evidence, severity, and repair requirement. Do not use an opaque “bad response” flag.

## W-086 — Attempt budget

All model repair/generation loops have explicit attempt, token, time, and resource budgets plus deterministic fallback or clean withholding.

## W-087 — No direct effect from model output

Model output cannot be:

- `eval`uated as MeTTa;
- executed as shell;
- sent to a user;
- written into active modules;
- promoted;

without the relevant parser, validator, certificate, and writer.

---

# IX. Reactor and endogenous-life rules

## W-090 — Events, not synthetic autonomy prompts

Endogenous work begins from typed obligations/opportunities grounded in history, contact, or a declared living question—not a generic “continue working” message.

## W-091 — RNA lifecycle visibility

Every active RNA has:

```text
ID
species
source event/cut
current locus
scope
budget
provenance
dependencies
authority
status
termination condition
```

The LLM context must not be the only copy of lifecycle state.

## W-092 — Quiescence

An empty lawful ready set produces `quiescent-ready`, not failure and not an LLM call.

## W-093 — Interruptibility

Endogenous work must suspend at a defined safe boundary when higher-priority contact arrives. Suspension state is durable enough to resume.

## W-094 — Progress witness

Autonomous continuation must produce or seek a typed progress witness. Repeated wakeups or token generation do not count as development.

## W-095 — Adaptive idle backoff

Use bounded increasing idle intervals that reset on contact or due work. Preserve status and panic control.

---

# X. Self-modification and Extension Workshop rules

## W-100 — First mutable surface is declarative

The first hot-loaded self-modification is a schema-constrained declarative MeTTa module interpreted by human-built fixed machinery.

No arbitrary generated MeTTa is directly evaluated in the active core.

## W-101 — Lifecycle separation

Keep distinct:

```text
pressure
candidate
validated candidate
quarantined trial
trial consequence
adjudication
accepted development
active projection
historical lineage
```

## W-102 — Candidate cannot own tests

The candidate may propose tests. The canonical acceptance and adversarial tests are controlled outside the candidate and cannot be edited by it.

## W-103 — Work must not prebuild the Mattermost solution

ChatGPT Work builds:

- generic extension contracts;
- workshop broker;
- mock server/fixtures;
- independent tests;
- sandbox and promotion machinery.

It must not add a Mattermost implementation to the seed. The candidate implementation must be generated under Miter's own DevelopmentOpportunity and recorded with Miter provenance.

## W-104 — Fork–test–merge

Executable extension candidates live on isolated git branches/worktrees. They cannot write directly to main.

## W-105 — Sandbox default

Generated executable code runs in a constrained environment with:

- no host home access;
- no repository write outside candidate worktree;
- no host secret access;
- no Docker socket unless the fixed broker specifically mediates a nested runner without exposing authority;
- no undeclared network;
- CPU, memory, time, and output limits.

## W-106 — Extension modality is open, contract is fixed

Miter may choose MeTTa, Prolog, Go, Rust, Python, JavaScript, Bash, or another modality for a tentacle when justified by the surface.

The chosen language does not acquire cognitive authority. The typed `SurfaceEvent`/`SurfaceEffect` contract, capability scope, tests, and promotion law remain fixed.

## W-107 — Independent review

The model that generated a candidate is not the sole reviewer. Use another profile, deterministic tests, or both.

## W-108 — Promotion is human-approved for live reach

A candidate may pass mock tests automatically. Live external credentials and network reach require explicit human approval.

## W-109 — Rollback and history

Rollback changes the active projection; it does not erase the candidate, trial, consequences, or intervening history.

---

# XI. Mattermost bridge rules

## W-120 — Pure bridge orientation

The bridge performs transport and identity mapping. It does not reason about Soul, query Chroma directly, or construct responses.

## W-121 — Stable identity

Inbound events include stable:

```text
server ID
team ID
channel ID
user ID
post ID
thread/root ID
event timestamp
bridge cursor
```

Display names are not identity authority.

## W-122 — Allowlist before cognition

Server/team/channel/user authorization is checked before an event enters Miter's cognitive reactor.

## W-123 — Idempotent effects

Outbound responses use stable effect IDs/idempotency keys. Duplicate delivery or reconnect must not duplicate a human-visible message.

## W-124 — Cursor and reconnect

The bridge stores a durable cursor/checkpoint and resumes without replaying already processed posts as new contact.

## W-125 — Credential isolation

Bot credentials live only in bridge-specific environment/keychain configuration and are never returned to Miter.

## W-126 — Memory scope

The core derives memory scope from authenticated surface identity and relationship rules. The bridge does not decide which private memories to reveal.

## W-127 — Panic

A fixed local panic command stops the bridge and prevents new outbound effects without corrupting Miter's trajectory.

---

# XII. Coding and test standards

## W-130 — Small modules

Prefer small, explicit libraries with one authority role over a monolith. A file should state:

- purpose;
- authority;
- inputs;
- outputs;
- writes;
- consumers;
- failure behavior;
- status.

## W-131 — Total public interfaces

Every external/public function handles malformed, missing, unknown, and stale input explicitly.

## W-132 — No hidden defaults at authority seams

Defaults such as “unknown capability = approved,” “empty memory = false,” or “model parse failure = proceed” are forbidden.

## W-133 — Timeouts and cancellation

Every service call and sandbox job has a timeout, cancellation path, and typed timeout result.

## W-134 — Determinism where promised

Fix random seeds and decoding parameters for acceptance fixtures. If a model remains nondeterministic, define acceptable invariant properties and run repeated trials.

## W-135 — Resource measurements

Record latency, token counts, process RSS where available, model identity, and service health. Performance is not the primary acceptance criterion, but pathological cost or lockup must be visible.

## W-136 — Logging is not cognition

A detector or log does not count as architecture unless a consumer changes a later movement. Every new signal names its consumer and severed-arm test.

## W-137 — Error atoms, not silent permission

External failures normalize to typed errors. No exception, empty response, timeout, or malformed output can imply approval, success, health, or confirmation.

## W-138 — Evidence-safe logs

Logs must be useful for reconstruction but exclude secrets and avoid dumping private long-term memory content unnecessarily.

---

# XIII. Stop conditions

Work must stop immediately when:

1. a protected file would need editing;
2. a gate's negative control cannot be expressed;
3. the runtime behaves differently from a proven substrate rule;
4. a service/version fact is unknown and load-bearing;
5. a model output would need direct execution to make progress;
6. existing Chroma data could be mutated without a tested backup;
7. licensed VAD data would be copied or redistributed;
8. a generated candidate requests host-wide authority;
9. a test passes only after weakening expected behavior;
10. a write appears successful but separate verification disagrees;
11. repeated attempts are not generating new evidence;
12. a discrepancy between source and implementation would be silently reconciled.

At stop, produce:

```text
BLOCKED GATE
FACTS PROVEN
FACTS UNPROVEN
SURPRISE
MINIMAL REPRODUCTION
AFFECTED REQUIREMENTS
ALTERNATIVES
RECOMMENDED NEXT DECISION
```

---

# XIV. Gate completion report

At the end of a gate, Work writes:

```text
# Gate <ID> Completion Report

## Verdict
PASS | FAIL | BLOCKED

## Requirement mapping

## Files changed

## Mechanism implemented

## Positive result

## Negative/severed result

## Raw evidence paths

## Protected-file hashes

## Newly proven substrate facts

## Remaining uncertainty

## Rollback command

## Next eligible gate
```

The report is a rendering of evidence. It is not itself evidence.

---

# Final construction principle

Miter's PoC is designed to become capable of building beyond its seed. That does not justify giving the seed unrestricted hands.

The build must preserve this sequence:

```text
human-ratified constitution
→ fixed seed mechanisms
→ witnessed deficiency or requested extension
→ Miter-authored candidate
→ isolated trial
→ independent consequence
→ Soul-governed adjudication
→ human-approved external reach
→ durable lineage
```

A faster route that collapses these distinctions does not build Miter. It builds an LLM-driven automation system wearing Miter's vocabulary.
