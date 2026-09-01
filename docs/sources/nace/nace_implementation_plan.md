# NACE Implementation Plan (Cognition via Truth_Revision)

**Status:** Build guide. What is done, what is left, in dependency order.
**Scope:** The NACE capability-efficacy learning system: beliefs as atoms,
revision via lib_nal's Truth_Revision, the loop as the bridge to lib_nal.
**Companion docs:** `nace_inloop_hook_spec.md` (the hook design, approved),
`sprint_0_coda_phase_a_v1.md` (the registry wiring NACE depends on).

---

## 1. What NACE is, in one paragraph

When a capability runs, its outcome (worked or failed) revises a belief about
that capability's efficacy. The belief is a NAL truth value `(stv freq conf)`.
Revision is `Truth_Revision` (lib_nal). A dispatch gate `should-dispatch` reads
the belief to decide whether to run a capability. Beliefs persist in files
across cycles and restarts. The loop is the only thing that can run the revision,
because lib_nal is only loaded inside the running loop process.

---

## 2. The two hard-won facts this build rests on

Both proven this session, both permanent constraints:

1. **The atomspace is stateless across invocations; persistence is file-based.**
   `set-atom!` does not persist. Beliefs live in files, loaded into the
   atomspace at startup via initSoulSeeds. (Proven three ways.)

2. **lib_nal is only reachable inside the running loop.** The revision operator
   is `Truth_Revision` (and `|-nal`, which calls it), defined in lib_nal.metta.
   It reduces only in the live loop process where lib_nal is loaded via the
   lib_omegaclaw chain. It does NOT reduce in a fresh `run.sh` or any external
   process. Therefore revision must run inside the loop. No external courier.

These two facts killed the external-courier model and fixed the architecture:
cognition in the substrate (Truth_Revision), state in files, the loop as bridge.

**One-cycle belief lag (S1).** The hook processes pending revisions in Phase 4.0,
but that cycle's dispatch decisions are made later in the same cycle reading the
belief as it was at cycle start. A revision applied this cycle affects NEXT
cycle's dispatch, not the current one. This is architecturally fine (a belief
update is evidence for future decisions, not a retroactive change to the current
one), but it is stated here so no one expects same-cycle availability.

---

## 3. Constraint catalog additions (record these)

From this session, for the constraint catalog so they are not rediscovered.
NOTE (Clarity's meta-observation): these are PROJECT-LEVEL, not NACE-specific.
The `|-nal`-not-`|-` lesson and the live-context-load lesson apply to ANY future
lib_nal consumer. They should also live in the shared project constraint catalog
(wherever the C12 / superpose / no-match-in-if rules live), not only in this
NACE doc, so the next lib_nal consumer does not rediscover them from here.

- **The NAL revision operator is `|-nal`, not `|-`.** `|-` is undefined and
  echoes unreduced. Verify operator names against lib_nal.metta before testing.
- **Substrate operators need the live-context library load.** lib_nal loads via
  lib_omegaclaw's chain inside the running loop. A standalone `run.sh` with an
  isolated import does not activate the definitions.
- **A function result placed inside a data-constructor atom does not
  auto-evaluate.** `(cap-efficacy $cap (revise-efficacy ...))` leaves the inner
  call unreduced. Force it: bind via `let` to the evaluated result first, OR
  call the reducing function so its result is the bound value. (We resolved this
  by computing the revision before constructing the atom.)
- **No `replace-line` file primitive exists.** The loop has `read-file`,
  `write-file` (overwrite whole), `append-file`. Replacing one line means
  read-whole, string-edit, write-whole.

## 3.5 THE UNRESOLVED BLOCKER (read before N1, this is load-bearing)

**The read-modify-write of an atom did not compose in standalone run.sh.**

The caller_operations_probe (PROBE E and F) found this and it was never resolved:
`set-atom!` (and by extension the remove-old + add-new pattern) inside a let-chain
returned the UNREDUCED `set-atom!` expression rather than executing the mutation,
and the subsequent read in the same evaluation showed the OLD value (4/3, not the
revised 5/4). The mutation did not take. add-atom and remove-atom alone worked
(PROBE F wrote the audit atom and removed the pending atom), but the read-then-
write-back pattern did not.

Why this matters for N1: the dual-write step (atomspace remove-old + add-new so
current-efficacy sees the revision this run) IS a read-modify-write of the belief
atom. PROBE E is exactly that operation, and it did not compose in standalone
run.sh. So N1's atomspace-update half is NOT proven to work. It may work in the
LIVE LOOP (task_state's writers use set-atom! read-modify-write and apparently
persist in production, which is the in-process atomspace persisting while the
process runs), but it did NOT work in standalone run.sh evaluation.

THE OPEN QUESTION, answerable before building N1: does the atomspace
remove-old + add-new (or set-atom!) compose within a single live-loop cycle, so
that current-efficacy sees the revised value the same cycle? Test it in the LIVE
LOOP, not run.sh (the same context lesson as |-nal). Two outcomes:
- It composes in the live loop -> N1's dual-write works, build as specced.
- It does NOT compose even in the live loop -> the atomspace-update half is
  impossible same-cycle, and the architecture must change: drop the atomspace
  update, write only the file, and accept that current-efficacy reads the
  revised value only AFTER a restart reloads the file (or find another read
  path). This would be a real architecture change, not a tweak.

This is the FIRST thing to resolve. Do not build N1's dual-write until the live-
loop read-modify-write behavior is known. It is the same shape of unknown that
|-nal was: untested in the right context, with a confident-looking plan built
on top of it. Test before building.

---

## 4. What is DONE (verified)

- **`soul/nace_substrate.metta`** (definitions, verified live by Clarity):
  - `evidence-stv` (confirmed -> (stv 1.0 0.1), disconfirmed -> (stv 0.0 0.1))
  - `current-efficacy` (reads a belief, defaults to (stv 0.5 0.0) for unknown cap)
  - `revise-efficacy` (calls Truth_Revision; verified to reduce live)
  - `efficacy-expectation` (Truth_Expectation; verified live)
  - `should-dispatch` (gate at expectation >= 0.3)
  - `updated-belief-atom` (builds the persistable atom, with the eval fix)
  Truth_Revision and Truth_Expectation confirmed reducing in the live process,
  results verified to the digit against the NAL formula.

- **`soul/nace_beliefs.metta`** (the store): three seed capabilities at agnostic
  (stv 0.5 0.0). NOTE: header still says "Courier writes this file only" which
  is stale (courier is dead). FIX the header to "the loop's revision hook writes
  this file" as part of the build.

- **`soul/nace_pending.metta`** (the queue): empty for v1, with header guardrails
  naming valid outcomes and the known-cap constraint.

- **`nace_inloop_hook_spec.md`** (the hook design): approved by Clarity, all
  review notes folded in, v1 boundaries named.

---

## 5. What is DEAD (do not deploy)

- `nace_courier.py` (external courier): killed by fact 2. Nothing external
  reaches lib_nal.
- All `run.sh`-based verify scripts (`verify_nace.py`, `verify_nace_substrate.py`,
  `probe_*.py`): they test in a context where lib_nal is not loaded, so their
  results on any lib_nal function are meaningless. Verification happens in the
  live loop instead.
- `nal_revision.py`: keep as REFERENCE only (the Python formula that the
  substrate's Truth_Revision is checked against; they agree to the digit). Never
  on the production path. Not deployed as runtime.

---

## 6. What is LEFT, in dependency order

### DEPENDENCY: Sprint 0-Coda must land first

NACE gates and learns from capability dispatch. The Capability Registry
dispatcher is not yet wired to the runtime; Sprint 0-Coda wires it (registers
skill-discovery, inserts dispatch into getContext). Until capabilities dispatch
through a live registry, NACE has nothing to gate and no outcomes to record.

**Therefore: Sprint 0-Coda is a hard dependency, not a preference.** Hooking
NACE in before Coda would wire a governance-and-learning layer onto a dispatcher
that does not fire. NACE work below begins after Coda lands.

NACE's `should-dispatch` is naturally part of the producer-side work-package
that Coda's own design schedules between Coda close and Sprint 1: soul/registry
state written as queryable atoms. NACE is downstream of Coda, in that package.

### The NACE work itself (Berton + Claude; hooks are ours, not Clarity's)

Division of labor: the loop.metta hook, the writer file, the wiring, and the
integration are Berton + Claude work. Clarity authors substrate atoms and MeTTa
logic where the writer needs new substrate functions, but the loop integration
is ours.

**STEP N0: Fix the load path (CRITICAL, found by Clarity's S5 + ghost-state Q).**
Verified against lib_clarity_reasoning.metta: NONE of the nace files are
currently in the import chain. This must be corrected with a specific asymmetry:

- **`nace_substrate.metta` MUST be auto-loaded** (add an import line in
  lib_clarity_reasoning.metta). Without it, the definitions (current-efficacy,
  revise-efficacy, etc.) are not in the atomspace and nothing reduces.
- **`nace_beliefs.metta` MUST be auto-loaded.** Without it, the belief atoms are
  not in the atomspace at startup, so current-efficacy always hits its default
  and the persistence story is broken (the file gets written but never read
  back). This is the gap Clarity's S5 caught.
- **`nace_pending.metta` MUST NOT be auto-loaded.** The writer reads pending
  entries from the FILE, not the atomspace. If pending were auto-loaded, startup
  entries would become atomspace ghost-state the file-reading writer never
  processes (Clarity's ghost-state question). Keeping pending out of the chain
  is deliberate, not an oversight. Do not "helpfully" add it later.

EXACT IMPORT LINES (A1): the syntax is `!(import! &self (library omegaclaw
./soul/<name>))`. The last existing soul/ import is at line 79
(recent_action_retriever). Add after it, plus the writers file from N1:
```
!(import! &self (library omegaclaw ./soul/nace_substrate))
!(import! &self (library omegaclaw ./soul/nace_beliefs))
!(import! &self (library omegaclaw ./soul/nace_writers))
```
Do NOT add nace_pending. nace_writers is built in N1; its import lands when N1
does (or add it now and N1 fills the file).

This asymmetry (substrate + beliefs loaded, pending NOT loaded) is the correct
load configuration. N0 lands before N1.

**STEP N0.5: Resolve the read-modify-write blocker in the live loop (BEFORE N1).**
Per Section 3.5. The atomspace half of N1's dual-write is unproven; PROBE E
showed it not composing in standalone run.sh. Before building N1:
- In the LIVE LOOP (not run.sh), test whether reading a belief atom, then
  remove-old + add-new (or set-atom!), then reading again in the same cycle,
  shows the revised value. task_state's writers suggest it works in-process, but
  this exact same-cycle read-after-write for the belief atom must be confirmed.

  EXACT TEST EXPRESSION (A2, live loop only):
  ```
  (let $old (current-efficacy web-search)
       (let $_ (set-atom! &self (cap-efficacy web-search $old)
                                (cap-efficacy web-search (stv 0.9 0.2)))
            (current-efficacy web-search)))
  ```
  Expect `(stv 0.9 0.2)` if same-cycle read-after-write composes. If it returns
  the old `(stv 0.5 0.0)` or an unreduced set-atom! expression, it did NOT
  compose (the PROBE E result), and the fork below applies. Run via Clarity's
  metta skill in the live process, the context where set-atom! has its
  in-process atomspace.
- If it composes live: N1's dual-write is sound, proceed.
- If it does NOT compose live: change the architecture before N1. Drop the
  atomspace update; write only the file. Accept the one-cycle-plus-reload lag,
  or find a read path that re-reads the file. This is a design fork, resolve it
  here, not mid-build.

**N0.5 HARDENING (2026-06-13 persistence findings -- apply these to the test).**
A live investigation this date independently re-confirmed the persistence physics
this gate depends on, and produced three corrections to how N0.5 must be run so its
result is trustworthy:

1. **MATCH-VERIFY the stored atom; do not trust the test expression's return value.**
   The A2 test above reads `current-efficacy` and returns it. That return can lie: a
   returned value can show one thing while the atomspace holds another (a derivation's
   computed value is not its stored value), and a mutation can appear to happen while
   nothing committed. So after the `set-atom!`, in a SEPARATE command, `match` for the
   belief atom directly and read the actual stored value. A pass is "match finds the
   revised value," never "the let-chain returned the revised value." Without this,
   N0.5 can return a false "it composes" and send N1 down the dual-write path on an
   unverified pass.

2. **Do NOT lean on "task_state writers apparently persist in production" as evidence
   the gate will pass.** "Apparently persists" is the same unverified-persistence
   assumption that, this date, turned out false elsewhere (a built atom network was
   ~half phantom because "I added N" was never checked against "match finds N").
   Before this plan cites task_state as precedent, match-verify that task_state's
   `set-atom!` writes are actually in the atomspace, not inferred from absence of
   errors. "Apparently persists" is not "match-confirmed persists."

3. **The file-only fallback is physics-aligned, not a degradation.** If N0.5 fails,
   writing only the file and reading via reload is not a sad downgrade -- it aligns
   NACE with the proven persistence model (files are what survive; in-process
   atomspace mutation is the unreliable seam). Treat the file-only path as an
   expected, sound outcome, with the one-cycle-plus-reload lag as its normal cost.

These three are instances of one durable rule: VERIFY THE LOAD-BEARING SUBSTRATE
CLAIM WITH A CLEAN MATCH-CHECK BEFORE BUILDING ON IT. "It threw" is not "broken";
"it computed" is not "persisted"; "I added N" is not "match finds N"; "it returned X"
is not "the atomspace holds X."

**N0.5 GATE -- RESOLVED 2026-06-13 (proven live, full atom-operation ladder ran clean).**
The gate and every atom-operation it depends on are now PROVEN. See the companion
`Atom_Operations_Map.md` for the full cell-by-cell evidence. Summary of what was
proven, and what it means for this writer:

- **Read-modify-write COMPOSES same-cycle and COMMITS across the cycle boundary.**
  N0.5 passes. The atomspace half of the dual-write is sound. (set-atom! then a
  same-cycle scalar read returned the new value; the separate-command persist-check
  confirmed it committed.)
- **set-atom! UPSERTS on non-match:** if the source pattern does not exactly match,
  set-atom! does NOT no-op -- it CREATES a new atom (proven: absent source ->
  duplicate created). So the writer must NOT use set-atom!-with-old-value, because in
  a revision loop the old value drifts and a non-match would silently spawn a
  duplicate belief.
- **add-atom is NOT idempotent:** adding an identical atom creates a true duplicate.
  So add-alone is also a duplicate source.
- **remove-atom removes ALL matching in one call**, and with a VARIABLE in the value
  position `(cap-efficacy X $v)` it clears ALL atoms for capability X regardless of
  value or count (proven: three web-search atoms across two values -> one variable
  remove -> zero). This makes remove-then-add a SELF-HEALING clean-swap.
- **Persistence path:** CWD is `/PeTTa`; file ops MUST use the ABSOLUTE path
  `/PeTTa/repos/omegaclaw/soul/nace_beliefs.metta` (relative paths resolve to a
  nonexistent `/PeTTa/soul/` and silently fail). The write -> restart -> load
  round-trip is PROVEN: writing that file lands in what the boot import loads.
- **Reads:** scalar reads `(cap-efficacy X (stv $s $c)) $s` return clean; tuple
  returns throw-with-leak. The writer reads belief fields individually as scalars.

**THE PROVEN WRITER PATTERN (replaces the under-specified dual-write in step N1.3):**
```
per capability X with a matured outcome:
  1. read current belief via scalar reads (clean): current freq, current conf of X
  2. compute revised stv via |-nal / Truth_Revision (live-loop only)
  3. (remove-atom &self (cap-efficacy X $v))        ; VARIABLE value: clears ALL
                                                     ; copies of X, any value/count
  4. (add-atom &self (cap-efficacy X revised-stv))  ; places exactly ONE
  5. rewrite nace_beliefs.metta at the ABSOLUTE path (persists across restart)
```
This lands at exactly one correct belief from ANY prior state (clean, stale-valued,
or duplicated). The duplicate-corruption risk is structurally eliminated by remove-
all semantics. The only residual caution is mid-write-crash atomicity (file+atomspace
divergence) -- a v1-acceptable boundary; restart reverts to the last-good file.

**STEP N1: Build `soul/nace_writers.metta` (the writer).**
- Define `do-process-pending-revisions!`. Per the hook spec Section 3, BUILT ON THE
  PROVEN WRITER PATTERN above (remove-by-variable then add, absolute-path file write):
  1. `read-file` (ABSOLUTE path) `nace_pending.metta`, parse `(pending-revision $cap
     $outcome)` entries from the string (NOT match &self; pending entries are in the
     file, not the atomspace).
  2. For each entry: evaluate `(updated-belief-atom $cap $outcome)` (lib_nal
     loaded in-loop, so Truth_Revision reduces).
  3. DUAL-WRITE the revised belief via the PROVEN pattern: (a) atomspace
     `(remove-atom &self (cap-efficacy $cap $v))` then `(add-atom &self (cap-efficacy
     $cap revised))` so current-efficacy sees exactly one this run, (b) rewrite
     nace_beliefs.metta at the ABSOLUTE path so it survives restart. (NOT set-atom! --
     it upserts on non-match and would spawn duplicates.)
  4. Remove the processed entry from nace_pending.metta (full-file rewrite, ABSOLUTE
     path; no replace-line primitive).
- Pure-vs-writer split: definitions stay in nace_substrate.metta, the
  side-effecting do-*! writer goes here. Header states the role.
- Register in `lib_clarity_reasoning/lib_clarity_reasoning.metta`.
- **Also in N1 (S2): fix the stale nace_beliefs.metta header.** It currently
  says "Courier writes this file only" (courier is dead). Change to "the loop's
  revision hook (do-process-pending-revisions!) writes this file." Fold into N1
  so it does not get orphaned as a lost separate task.
- **N1 DONE criterion (A3):** do-process-pending-revisions! reduces without
  error against a test pending file; nace_beliefs.metta shows the revised belief;
  the processed pending entry is removed from nace_pending.metta. (Checkpoint to
  know N1 is complete, not full system verification, that is N4.)

**STEP N2: Insert the loop.metta hook.**
- One line, Phase 4.0 (iteration entry), after the message-reception block,
  before prompt assembly: `($_ (do-process-pending-revisions!))`.
- Single function call, no inline logic (Discipline 1).
- Run the Section 6 checklist from the hook spec before committing.
- **N2 DONE criterion (A3):** loop.metta contains the single hook line at Phase
  4.0; the loop starts and runs a cycle without error. (Checkpoint, not full
  verification.)

**STEP N3: Update `artifact_1_loop_metta_wiring_diagram.md` (same commit as N2).**
- Phase 4.0 entry: the hook reads nace_pending, dual-writes nace_beliefs +
  atomspace, calls do-process-pending-revisions!, serves the capability registry.
- Maintenance contract per artifact_0 Discipline 4.

**STEP N4: Verify in the live loop (NOT run.sh).**
- Drop a test entry into nace_pending.metta. Use an ACTUAL SEED CAPABILITY (S3):
  `(pending-revision web-search confirmed)` only works by the unknown-cap default
  path; instead use one of the three seed caps so the dual-write exercises the
  REPLACE-existing-belief-line path, which is the real production path. Use a
  seed cap that exists in nace_beliefs.metta.
- Let the loop run one cycle. Confirm: the belief in nace_beliefs.metta changed
  to the revised value, the in-atomspace atom changed (query it live), and the
  pending entry was removed.
- Verify the revised value against the NAL reference (the Python formula in
  nal_revision.py, reference-only).
- This is the verification that replaces the dead run.sh scripts: it runs in the
  live loop where lib_nal is loaded.

**STEP N5: Wire should-dispatch as the registry gate (producer-side package).**
- After Coda wires the registry, the registry consults `should-dispatch $cap`
  before dispatching a capability. This is the gate NACE was built to provide.
- The registry reads the efficacy belief (now a live atom, dual-written by the
  hook) to decide dispatch.

**STEP N6: Wire the real recorder (producer-side package).**
- Replace the v1 manual/test pending-writer with the real recorder: after a
  capability dispatches and its outcome is known, write
  `(pending-revision $cap confirmed|disconfirmed)` to nace_pending.metta.
- This closes the loop: dispatch -> outcome -> pending entry -> hook revises ->
  belief updates -> next dispatch gate sees the new belief. The Mobius cycle.
- **OPEN QUESTION for N6 (S4, genuinely hard, flag now): outcome determination.**
  A capability can return a value, time out, throw an exception, return empty, or
  return something malformed. Which of these map to `confirmed` vs
  `disconfirmed`? A clean return is confirmed; a thrown exception is likely
  disconfirmed; but a timeout, an empty result, or a malformed result are
  genuinely ambiguous. This mapping is unaddressed and non-trivial. It likely
  needs a third outcome (ambiguous -> no revision, the evidence-stv None path) or
  per-capability outcome interpreters. Resolve this in N6 design; do not let it
  surface as a runtime surprise. It may justify extending evidence-stv beyond the
  two v1 tokens.

---

## 7. Known v1 boundaries (from the hook spec, carried forward)

- Dual-write is not atomic (atomspace + file can diverge on mid-write crash;
  restart reverts to last-good file). Acceptable v1; revisit for durability.
- Race on the pending file (recorder append during hook rewrite loses the
  entry). Fine for v1 manual writer; the real recorder (N6) needs a lock or
  append-only handoff.
- Unknown-cap on the WRITE side: current-efficacy defaults safely on read, but
  the dual-write has no belief line to replace for an unknown cap. The real
  recorder (N6) needs a defined behavior: append-new or reject.
- Full-file rewrite is a scalability ceiling (fine for 3-10 beliefs, not 50+).
  Future: append-only log with compaction, or an indexed store.

---

## 8. The architecture, named (for whoever builds the real recorder)

The pending file is a narrow asynchronous interface (Clarity's framing). The
recorder deposits an intention (capability X had outcome Y); the loop processes
it next cycle. The recorder does not know about Truth_Revision; the revision
system does not know about skill dispatch. This decoupling is what makes NACE
sound and extensible: the real recorder (N6) writes to the same surface the v1
test writer used, and the hook does not change.

This pattern (pending file -> in-loop hook -> substrate revision -> dual-write)
is reusable. NACE is the first instance of a generic capability-learning loop,
not the only possible one.

---

## 9. Sequence summary

```
Sprint 0-Coda (registry wired, skill-discovery registered)   [DEPENDENCY]
        |
        v
Producer-side work-package (soul/registry state as queryable atoms)
        |
        +-- N0   fix load path (substrate+beliefs loaded, pending NOT)
        +-- N0.5 RESOLVE read-modify-write blocker in live loop (GATE before N1)
        +-- N1   build nace_writers.metta (+ fix stale beliefs header)
        +-- N2   loop.metta hook (Phase 4.0)
        +-- N3   artifact_1 wiring update (same commit)
        +-- N4   verify in the live loop (with a seed cap)
        +-- N5   should-dispatch as the registry gate
        +-- N6   the real recorder (closes the cycle; outcome-mapping open Q)
        |
        v
NACE live: dispatch gated by learned efficacy, outcomes revise beliefs,
beliefs persist across cycles and restarts, cognition in the substrate.
```

The done work (Section 4) stands. The dead work (Section 5) is discarded. The
left work (Section 6) begins after Coda, because NACE has nothing to act on
until capabilities dispatch through a wired registry.
