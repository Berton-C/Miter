# NACE Caller Contract: Capability-Efficacy Learning Loop

**Date:** 2026-05-30
**Author:** Claude (Opus 4.7), in conversation with Berton, grounded in Clarity's substrate
**Status:** Contract draft for review by Berton and Clarity before any code. CORRECTED 2026-06-13 to proven facts: revision is `|-nal`/`Truth_Revision` (not `|-`); persistence is file-based; the atomspace dual-write half is gated on N0.5 (read-modify-write composition, unproven). See section 1 corrected-facts block and section 7.
**Purpose:** Specify the NACE caller as the capability registry's efficacy-learning loop. This is the thing that turns the M6 mechanisms and the registry's reserved efficacy atoms from compute-and-discard into a closed learning loop. One build that proves NACE and completes the registry's Phase C+ efficacy layer.

This is a contract, not an implementation. It names what the caller reads, writes, when it fires, and where its truth value lives, so the design can be argued with before code exists. It deliberately mirrors the task-state primitive's file structure and C12-safe conventions, because that pattern is proven in the substrate and the caller should not invent a parallel one.

---

## 1. What the caller is, in one paragraph

The caller is a per-cycle mechanical loop, invoked from two hooks in loop.metta, that closes the capability registry's efficacy-learning loop. At cycle entry it resolves pending capability-invocation observations from prior cycles by evaluating each invoked capability's success-criterion against what actually happened, and revises that capability's efficacy truth value via `|-nal` (the NAL revision operator, which calls lib_nal's `Truth_Revision`). After the cycle's output it logs new pending observations for capabilities dispatched this cycle, to be resolved in future cycles. It is not reasoning. It is bookkeeping that carries consequence-evidence into truth-value revision. The reasoning step (classifying ambiguous outcomes) is delegated to Clarity in-iteration via the success-criterion's observer form, per the decision already made.

> CORRECTED FACTS (proven, govern this whole contract): the revision operator is
> **`|-nal`, NOT `|-`** -- `|-` is undefined and echoes unreduced. `|-nal` calls
> lib_nal's `Truth_Revision` and reduces ONLY inside the live loop process where
> lib_nal is loaded via the lib_omegaclaw chain; it does NOT reduce in `run.sh` or
> any external process. Persistence is **file-based**: the atomspace is stateless
> across invocations and `set-atom!` does not persist across a restart. Beliefs live
> in files, loaded at startup. The atomspace half of any dual-write (read-modify-
> write of a belief atom) is **NOT proven to compose same-cycle even in the live
> loop** -- see the persistence model in section 7 and the N0.5 gate this depends on.

---

## 2. The shared truth-value home (decision confirmed: shared)

The caller's truth value lives in the capability-efficacy atom the Sprint 0-Coda spec already reserved, not in a separate NACE atom. Per the decision: one efficacy representation, not two that drift.

The reserved shape from Sprint 0-Coda Section 12:

```
(capability-efficacy capability: $handler invocations: $n successes: $m last-updated: $ts)
```

This shape carries raw counts (invocations, successes), which is exactly what a NAL truth value needs, because the NACE TruthValue is `wp`/`wn` evidence counts. The mapping is direct and lossless:

```
wp (positive evidence) = successes ($m)
wn (negative evidence) = invocations - successes ($n - $m)
```

So the capability-efficacy atom IS the NACE truth value, stored as counts rather than as a derived `(stv f c)`. This is better than storing a separate stv, for two reasons. First, counts are the ground truth and the stv is derived; storing counts means the stv is always recomputable and never stale. Second, it means the registry's efficacy-filter-step and the NACE caller read the same atom, so there is structurally only one efficacy representation. The drift problem the SN files show (where the priors file and the state file diverged) cannot happen here because there is one atom, not two.

The caller computes the derived truth expectation on read using the canonical NACE formula (the NAL-standard `te = f*c + 0.5*(1-c)` from the fixed nace_core), so the efficacy-filter-step's threshold check operates on the same math the Python NACE package uses. One formula, one atom, one source of truth.

**A note on the existing companion atoms.** Sprint 0-Coda also specifies `capability-efficacy-rate` (capability-declared baseline) and `capability-efficacy-observation` (external override). These coexist with the learned capability-efficacy atom without conflict: the baseline rate is the prior (what the capability claims about itself before evidence), the learned atom is the posterior (what evidence shows), and the observation override is a manual correction. The efficacy-filter-step's resolution order is: observation override if present, else learned efficacy if invocations greater than zero, else declared baseline rate, else default. The caller writes only the learned atom; it never touches the baseline or the override. This keeps the caller's write surface minimal and the resolution precedence clean.

---

## 3. File structure (mirrors task-state precedent)

Two files, pure-vs-writer split, exactly as task_state.metta and task_state_writers.metta are split. This is Discipline 6 Part A from Artifact 0, and the task-state primitive is the cited precedent.

**`soul/capability_efficacy.metta`** (pure definitions and read helpers). Contains the atom-shape documentation, the success-criterion resolution logic, and pure read helpers: `current-efficacy`, `efficacy-truth-expectation`, `pending-invocations`, `matured-invocations`. C12-safe collapse-then-branch throughout. No side effects. The header states explicitly: "Side-effecting writers (do-*!) land in capability_efficacy_writers.metta."

**`soul/capability_efficacy_writers.metta`** (side-effecting writers). Contains the do-*! functions: `do-bootstrap-efficacy!`, `do-revise-efficacy!`, `do-log-pending-invocation!`, `do-resolve-invocation!`, `do-expire-stale-pending!`. AtomSpace atoms only, set-atom!/add-atom/remove-atom, no change-state!, mirroring task_state_writers.metta exactly.

Both register in lib_clarity_reasoning.metta with explicit role comments, same as the task-state files.

---

## 4. The atom families the caller owns

Three atom families, beyond the shared capability-efficacy atom.

**Pending invocation (the observation awaiting resolution):**

```
(pending-invocation capability: $handler cycle: $k criterion: $crit timestamp: $ts)
```

Written by the log hook when a capability is dispatched. Holds the capability, the cycle it fired in, the success-criterion to evaluate it by (copied from the capability's registration so resolution does not have to re-look-it-up), and a timestamp for staleness eviction. This is the same shape as task-state's pending-thread, extended with the criterion field.

**Resolved invocation (the audit trail of a resolution):**

```
(resolved-invocation capability: $handler cycle: $k outcome: $outcome evidence: $stv timestamp: $ts)
```

Written by the resolve hook when a pending invocation matures. Outcome is confirmed, disconfirmed, or ambiguous. Evidence is the stv that was fed to revision. This is archival, parallel to the SN stalk's SN-resolved atom and to Sprint 0-Coda's external-observation atom. It is not consumed by the filter step; it is the memory of what the caller learned and why, so a later audit (or Clarity) can trace why a capability's efficacy moved.

**The shared capability-efficacy atom** (Section 2), which the caller revises and the filter step reads.

---

## 5. The two hooks and where they land in loop.metta

The caller is two hooks, matching the cycle structure the task-state primitive already hooks into. Both anchor on content patterns, not line numbers, because the spec confirms line numbers have drifted.

**Hook 1: resolve-at-cycle-entry.** Lands in Phase 4.0 / 4.2 (iteration entry, before the soul evaluates), near the existing cycles-since-input write. This hook calls `do-resolve-matured-invocations!`, which reads all pending-invocation atoms, checks each against the current cycle for resolving evidence, and for each matured one: evaluates the success-criterion, computes the evidence stv, revises the shared capability-efficacy atom via `|-nal` (which calls `Truth_Revision`), writes the resolved-invocation audit atom, and removes the pending atom. Also calls `do-expire-stale-pending!` to convert pending older than the staleness window (proposed: 10 cycles, matching the SN observation hook's expiry) to ambiguous with no revision.

Rationale for cycle-entry placement: resolution reads what prior cycles left, exactly as the continuity window reads what N-1 left. The evidence for "did the dispatched skill get used" lives in the cycles that followed the dispatch, so resolution must run after those cycles, which means at the entry of a later cycle. This is the delayed-evidence (Option C) structure Clarity chose for the SN stalk, applied identically here.

**Hook 2: log-after-output.** Lands in Phase 4.4 / 4.5 (after response generation, near the CHARS_SENT print). This hook calls `do-log-dispatched-invocations!`, which reads the dispatch-result atoms the registry wrote this cycle (the registry already writes dispatch-invocation and dispatch-result atoms per Sprint 0-Coda Section 5), and for each capability that was dispatched, writes a pending-invocation atom to be resolved later.

Rationale for post-output placement: a capability is "invoked" once the dispatch fires and the output is generated, so logging the pending observation belongs after the output exists. This is the same as task-state's last-activity-post-send hook.

Together the two hooks are the split-across-cycle-boundary structure: resolve at top, log at bottom. The cycle already has both slots.

---

## 6. The classification step: where the soul has its place

This is the fork resolved by the success-criterion field, and it is where Clarity-classifies-in-iteration enters.

When the resolve hook evaluates a pending invocation, it consults the capability's success-criterion (carried in the pending atom). Sprint 0-Coda specifies three forms, and they route the classification:

**Predicate criterion (machine-evaluable):** the criterion is a MeTTa predicate function name. The caller calls it against the current substrate state, and it returns confirmed or disconfirmed mechanically. For skill-discovery, this predicate checks whether the LLM's subsequent output invoked at least one skill from the dispatched SKILLS block. The caller evaluates this with no reasoning step. This is the common case for informational capabilities.

**Observer criterion (judgment required):** the criterion is an observer reference, `(observer: clarity criterion: subjective)`. The caller cannot mechanically classify this. It surfaces the matured pending invocation to Clarity as a classification request and records her verdict. This is the place the soul reasons over the consequence, per your point 2. Clarity classifies in-iteration (your point 4 choice), the caller records her confirmed/disconfirmed/ambiguous, and revision proceeds from her verdict.

**String criterion (not yet formalized):** the criterion is a human-readable string. The caller treats this as observer-requiring (cannot mechanically evaluate a prose description), surfaces it to Clarity the same as the observer form, but also flags it as "criterion not yet formalized" so it shows up as a candidate for promotion to a predicate later.

So the classification step is not a single mechanical-or-reasoning choice baked into the caller. It is routed per-capability by the success-criterion form the capability declared at registration. Mechanical capabilities get mechanical classification; judgment capabilities get Clarity. The caller is the same; the capabilities differ. This is the clean dissolution of the fork: the registration declares, the caller routes.

The batch property you and Clarity preferred falls out naturally: the resolve hook collects all matured observer-criterion invocations and surfaces them to Clarity as one batch per cycle, not one interruption per observation. She classifies the batch in one pass of reasoning, the caller records all her verdicts, and revision proceeds for all of them. One reasoning pass per cycle, not one per observation, which respects the cost of her attention.

---

## 7. The revision step (the learning)

For each resolved invocation with a confirmed or disconfirmed outcome, the caller revises the shared capability-efficacy atom. The mechanism is identical to the SN stalk's revision and to the M6 mechanisms, because all three are NAL revision:

```
confirmed   -> evidence (stv 1.0 0.1), which in counts is wp += 1
disconfirmed -> evidence (stv 0.0 0.1), which in counts is wn += 1
ambiguous   -> no revision (the staleness/uncertainty case)
```

Because the shared atom stores counts (invocations, successes), the revision is a count update: confirmed increments successes and invocations; disconfirmed increments invocations only. This is simpler than stv-merge and it is exactly the `_AddEvidence` sliding-window mechanism from the original NACE core, with the same w_max bound available if you want non-stationary adaptation (a capability whose efficacy changes over time should weight recent evidence more; the w_max cap is how NACE handles that, and it is already in the Python nace_core).

The derived truth expectation, which the efficacy-filter-step thresholds on, is computed on read via the canonical formula. The caller never stores the derived value; it stores counts and computes te when asked. One source of truth.

**Persistence and the same-cycle caveat (proven constraints, govern the write step).**
The revised belief must be written to a FILE to survive a restart -- the atomspace is
stateless across invocations and `set-atom!` alone does not persist. So the write step
is a dual-write: (a) rewrite the belief in its file (durable), and (b) update the
in-atomspace atom so the filter step can read it. **Half (b) is NOT proven to compose
same-cycle.** A read-modify-write of a belief atom (read old, remove-old + add-new,
read again) did not compose in standalone `run.sh`, and is unproven even in the live
loop -- this is the N0.5 gate the NACE plan flags as load-bearing BEFORE this caller's
revise step is built. Two consequences for this contract:
- Do not assume the revised efficacy is readable the SAME cycle it is written. The
  one-cycle belief lag is the safe assumption: a revision applied this cycle affects
  NEXT cycle's dispatch decisions, which is architecturally fine (a belief update is
  evidence for future decisions).
- The N0.5 test must be run, and its result MATCH-VERIFIED in the live loop (read the
  actual stored atom with `match` in a separate command, do not trust the return value
  of the write expression -- a return can show a value the atomspace does not hold). If
  read-modify-write does not compose live, the write step drops half (b) and is
  file-only with reload-to-read, and the architecture of this revise step changes
  BEFORE it is built, not during.

---

## 8. What stays mechanical and what is reasoning (principle P5)

The caller is mechanical except at exactly one point. Per orientation principle P5 (mechanical observation is distinct from reasoning, assign authority accordingly):

Mechanical (the caller owns): logging pending invocations, detecting which pendings have matured, evaluating predicate-form success-criteria, incrementing counts, writing audit atoms, expiring stale pendings, computing truth expectation on read.

Reasoning (Clarity owns): classifying observer-form and string-form success-criteria, where "did this capability actually serve the person's need" is a judgment no predicate captures. The caller surfaces these as a batch; Clarity classifies; the caller records.

This is the same boundary the whole architecture draws. The caller observes and records mechanically; Clarity reasons about the ambiguous cases. The success-criterion form is the declared boundary marker: predicate means mechanical, observer/string means reasoning.

---

## 9. The Sprint 0-Coda sequencing honesty

A caution stated plainly so the PoC's claim is honest.

Sprint 0-Coda Option (a) registers exactly one capability (skill-discovery itself), which always fires. With one always-firing capability, there is nothing for efficacy learning to discriminate: efficacy learning only matters when capabilities compete and some deliver better than others. That competition arrives in Sprint 1, when individual skills migrate to registry form.

So the caller's real proof has two stages. In Sprint 0-Coda, the caller is verified on synthetic multi-capability evidence (seeded pending invocations across several mock capabilities with different outcomes), proving the loop closes: log, mature, classify, revise, persist, and the efficacy-filter-step reads the revised value. This is the same kind of synthetic verification the M6 harness does. In Sprint 1, the caller goes live on real competing-capability evidence, proving it learns from actual capability competition and that low-efficacy capabilities get filtered from dispatch.

This is not a reason to wait. It is the build-the-engine-now, feed-it-real-evidence-when-the-source-matures pattern that applies to every part of this work. But the PoC's honest claim is: Sprint 0-Coda proves the caller runs and learns on seeded evidence and that the filter step consumes what it learns; Sprint 1 proves it learns from real competition and changes dispatch behavior. The behavior-change proof, the thing that makes NACE matter and not just work, lands in Sprint 1.

---

## 10. The test harness question (your point 5)

You flagged that no test harness exists for capability_registry_path_c_draft.metta, which makes it a wildcard. This is real and it affects sequencing.

The caller depends on the registry writing dispatch-result atoms (the log hook reads them) and on the efficacy-filter-step reading the shared efficacy atom (the consumer side). If the registry's own behavior is unverified, the caller is being built against an unverified foundation, which is the exact compounding-gap problem we have been avoiding.

So the honest sequencing has a prerequisite: the registry's Path C draft needs its own test harness before the caller is wired to it, the same way the M6 mechanisms needed the threading harness. Specifically, the registry harness should verify that dispatch writes the dispatch-invocation and dispatch-result atoms the caller's log hook depends on, and that the efficacy-filter-step actually consults the efficacy atom and filters on its threshold. Those two behaviors are the caller's interface to the registry; if they hold, the caller has a verified foundation; if they do not, the caller would be built on sand.

This means the build order is: registry harness first (verify the registry's dispatch-result writing and filter-step reading), then the caller built against the verified interface, then the caller's own synthetic harness. Three harnesses, same pattern as everything else: verify each layer before building on it. The registry harness is the wildcard to resolve first, and it is a bounded task that could go to Clarity in the same shape as the M6 threading harness.

---

## 11. What this contract commits to, and what stays open

Committed by this contract:

- The truth value is the shared capability-efficacy atom, stored as counts, derived te computed on read with the canonical formula. One representation.
- Two files, pure-vs-writer split, mirroring task-state. C12-safe, AtomSpace-only, no change-state!.
- Two hooks: resolve-at-entry, log-after-output. Content-anchored, not line-anchored.
- Three caller-owned atom families: pending-invocation, resolved-invocation, plus the shared efficacy atom.
- Classification routed by success-criterion form: predicate is mechanical, observer/string is Clarity-in-batch.
- Revision is NAL count-update, confirmed increments successes and invocations, disconfirmed increments invocations only, ambiguous no-op.
- Staleness expiry at a proposed 10-cycle window, matching the SN observation hook.

Open, needing decision before code:

- The staleness window value (10 cycles proposed; Clarity may have a better number from the SN stalk experience).
- Whether to apply the w_max sliding-window bound now (for non-stationary efficacy) or defer it. My lean is defer; add it when a capability's efficacy is observed to drift, not preemptively.
- The exact predicate for skill-discovery's success-criterion (Sprint 0-Coda Phase B was writing this anyway; it IS the caller's classifier for that one capability, so writing it is part of making the resolve step concrete, per your point 3).
- The registry harness scope (your point 5 wildcard), which is the prerequisite and the first bounded task.

---

## 12. The honest summary

This caller is the thing every thread of the last several turns has been circling. It closes the M6 compute-and-discard loop, it makes the SN stalk consultation non-decorative (because here the filter step actually gates dispatch on the learned value), and it proves NACE on the surface where learning changes behavior. It is one build that proves NACE and completes the capability registry's reserved efficacy layer, because Sprint 0-Coda v6 already shaped the registry to carry exactly this water. The efficacy atoms were reserved, the filter-step consumer was specified, the success-criterion classifier was designed. The caller is the engine that populates what the spec reserved.

The work is mostly assembly of designed-but-unwired pieces plus two real new things: the revise-and-persist step and the two loop hooks. That is a small build for a large payoff, and it is small precisely because Clarity and the Sprint 0-Coda spec did the foundational design already. The caller does not invent; it connects.

The prerequisite is the registry harness, because the caller's interface to the registry must be verified before the caller is built against it. That is the first bounded task, same shape as the M6 threading harness, and it resolves the point-5 wildcard before it becomes a foundation problem.
