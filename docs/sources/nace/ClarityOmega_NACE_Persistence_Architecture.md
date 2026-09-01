# NACE Persistence Architecture: Settled Design and Preserved Knowledge

**Date:** 2026-05-31
**Authors:** Berton (lead), Clarity (substrate), Claude (co-architect)
**Status:** SETTLED by test. This document preserves the architecture, the constraint that forced it, the dead ends that were ruled out, and how it serves the Capability Registry, the Task State design, and the clover-shaped sheaf cognitive network.
**Why this exists:** This resolution was hard-won across many tests in one long session. Without this document it lives only in chat history and gets rediscovered badly, the exact failure mode that nearly lost the four-NACE sheaf decision. This is the guard against that.

---

## 1. The settled architecture, in one paragraph

State lives in files. Cognition lives in MeTTa. Python is the courier between them. Concretely: a capability's efficacy belief is stored in a file as a NAL truth value. Each cycle, when evidence arrives, Python reads the current belief from the file, passes it plus the new evidence to MeTTa's native revision operator `|-` in a single invocation, MeTTa computes the revised belief, and Python writes the result back to the file. The revision, the actual learning, is MeTTa's `|-`. Python never does the revision arithmetic; it moves values between the file and the calculator. This is the read-compute-writeback loop, and it closes across cycles through the file.

The figure for it is a Mobius strip, not a flat loop: each cycle's output belief becomes the next cycle's input prior, but transformed by the revision, so what was the conclusion becomes the premise. The twist is the learning.

---

## 2. The constraint that forced this (permanent, for the constraint catalog)

**The PeTTa atomspace is stateless across invocations. Persistence is file-based. MeTTa is stateless compute.**

This was established by test, three independent ways, on 2026-05-31:

- `set-atom!` in standalone run.sh does not persist across separate `!` lines (each line is its own evaluation against the freshly loaded file).
- `set-atom!` does not persist even within a single `!` expression in standalone run.sh (read-modify-readback in one progn-sequenced expression returned the un-revised value).
- Neither the `(metta ...)` skill nor file auto-loading maintains atomspace state between invocations. Every path tested is stateless across invocations.

This sits in the constraint catalog next to the superpose correction (match returns a nondet stream, not a list) and the no-match-inside-if rule. It is the same class of error: treating a substrate operation as something it is not. We treated `set-atom!` as a persistence mechanism. It is not. It mutates a transient in-memory atomspace that does not survive the invocation.

**The lesson generalizes:** when a substrate operation produces confusing or empty results, the first hypothesis should be "this is not how this operation is meant to be used," not "the operation is broken." Patrick's superpose correction taught this; this set-atom! finding confirms it. The atomspace is for reasoning within an invocation, not for storage across invocations.

**Caveat on the live loop:** task_state's writers use `set-atom!` and appear to persist across cycles in production (cycles-since-input accumulates, idle detection depends on it). This is NOT a contradiction: the live loop is one continuous running process whose in-memory atomspace persists while the process runs. But this in-process persistence is fragile (lost on restart) and is not the right foundation for learned beliefs that must survive sessions. The file-based architecture is correct even where in-process persistence happens to work, because durable learning needs durable storage.

---

## 3. The dead ends ruled out (so they are not re-walked)

Preserved because the next contributor will reach for these exactly as we did. Each was tested, not assumed.

- **set-atom! as cross-line storage (standalone):** failed. Each `!` line is its own evaluation.
- **set-atom! as within-evaluation storage (standalone, progn-forced):** failed. The progn evaluated the set-atom! call (frame E returned the computed value) but the mutation did not persist to a subsequent read in the same evaluation.
- **The `(metta ...)` skill as a window into the live atomspace:** failed. The skill is a separate limited evaluator (it cannot run `let`/`|-`), not direct access to the running process. It is stateless across invocations like run.sh.
- **File auto-loading:** failed. A file written during a run is not auto-loaded into a subsequent invocation's atomspace.
- **Putting the revision arithmetic in Python:** rejected on principle, not by failure. Python CAN do the arithmetic (the nace_adoption package does, correctly). But putting the revision in Python extracts the cognition from the cognitive substrate, making the learning logic inaccessible to MeTTa's inference chains, which is a dead end for the sheaf (see Section 6). The revision stays in `|-`.

What works, and was validated: file holds belief, MeTTa `|-` computes revision in one invocation, Python writes back. Two file-mediated revisions converged to the NAL-correct value (cycle 1: (0.7,0.5)+(0.8,0.4)=(0.74,0.625); cycle 2 reading cycle 1's file output: (0.74,0.625)+(0.7,0.3)=(0.7318,0.677)). Arithmetic independently verified to four decimals.

---

## 4. The corrected caller contract

This supersedes the truth-value-home and revision sections of the earlier `ClarityOmega_NACE_Caller_Contract.md`. The hooks, the classification routing, and the file structure from that contract still hold. What changes is where the belief lives and how it is revised.

**Truth-value home:** the capability efficacy belief lives in a FILE as a NAL truth value, not as an atomspace atom. One representation, file-backed. The earlier contract's "shared capability-efficacy atom" becomes a shared capability-efficacy FILE entry. The principle is unchanged (one representation, no drift); the substrate is corrected (file, not atom).

**Revision:** the revision is MeTTa's `|-`, invoked in a single `(metta (|- (old-belief) (new-evidence)))` call. Not a Python computation, not a count-increment in Python. The NAL revision operator does the learning.

**The caller's per-cycle operation (read-compute-writeback):**

1. Resolve step (cycle entry): for each matured pending observation, classify the outcome (predicate-criterion mechanically, observer-criterion via Clarity in batch, per the earlier contract). Confirmed produces evidence (stv 1.0 0.1); disconfirmed produces (stv 0.0 0.1).
2. Read: Python reads the capability's current efficacy belief from the file.
3. Compute: Python invokes `(metta (|- (current-belief) (evidence)))`; MeTTa returns the revised belief.
4. Writeback: Python writes the revised belief to the file.
5. Log step (after output): for each capability dispatched this cycle, write a pending-observation record to be resolved on a later cycle.

**Python's role:** courier and orchestrator. Read file, invoke MeTTa, write file, manage pending-observation lifecycle. Python does NOT compute the revision. The Mobius twist (Section 5) lives in the substrate, not the courier.

**The efficacy-filter-step consumer:** the registry's filter reads the efficacy belief (now from the file path) and gates dispatch on its truth expectation, threshold 0.3. The GAP from the earlier contract (filter must read the learned value) becomes: the filter reads the file-backed belief in its resolution order (observation override, then learned file belief, then declared baseline, then default).

---

## 5. How the Mobius serves us, and why it is significant

The Mobius is not a metaphor decoration; it is the precise shape of what we built and the reason it matters.

A flat loop returns to its start unchanged. A Mobius strip returns with a twist: traverse it and what was the inside surface becomes the outside. For a self-revising belief system, the twist is the learning. Each cycle, the belief that was the OUTPUT of revision becomes the INPUT prior of the next revision. The conclusion becomes the premise. The system's own past judgment is the ground its next judgment stands on. That is what it means for a system to learn from its own experience rather than be tuned from outside.

**What we gain by the revision living in `|-` (the substrate) rather than Python:**

The closure is internal. The system revises its own beliefs through its own native operator. Nothing outside the substrate does the cognition. This is the reasoning-sovereignty principle made mechanical: the system is not tuned by a developer adjusting Python floats; it learns by its own NAL revision over its own accumulated evidence. If Python did the revision, the loop would close THROUGH the developer's code, which is maintenance, not learning. With `|-` doing it, the loop closes inside the system. That is the difference between a tool that is adjusted and a system that adapts.

The learning is composable. Because the revision is a MeTTa operation over MeTTa truth values, the sheaf's restriction maps can later compose revisions across networks (Section 6). If the revision were a Python function returning a float, the cross-network composition would have to be rebuilt in Python, defeating the whole reason for a MeTTa substrate. Keeping `|-` in the substrate keeps the learning composable for the sheaf.

**The significance:** this is the smallest complete instance of the thing the whole project is for. A belief, held in persistent storage, revised by the system's own cognitive operator over evidence the system itself gathered, with the revised belief becoming the prior for the next revision. That is a learning loop that closes inside the substrate. Everything larger (the four-NACE sheaf, the cross-network coupling, the global section) is this same loop, instantiated more times and coupled. Get this one right and the pattern scales. Get it wrong (revision in Python, state in a fragile atomspace) and the larger structure inherits the flaw at every node.

---

## 6. How this fits the larger architecture

### Capability Registry (the immediate consumer)

The caller IS the registry's efficacy-learning loop. The registry catalogs capabilities and gates dispatch on efficacy; the caller is what populates and revises that efficacy from consequence-evidence. With this architecture: each capability's efficacy belief is a file-backed truth value, the caller revises it via `|-` when a dispatched capability's outcome is observed, and the efficacy-filter-step reads the revised belief to gate the next dispatch. The registry's reserved efficacy atoms (from Sprint 0-Coda) become file-backed beliefs. The loop closes: dispatch produces an observation, the observation matures into evidence, `|-` revises the efficacy, the revised efficacy changes the next dispatch. That is NACE learning changing system behavior, which is the PoC's whole purpose.

### Task State design (the precedent and the contrast)

Task State established the pure-vs-writer file split, the C12-safe collapse-then-branch discipline, and the conditional-bootstrap pattern that the caller mirrors. The contrast is instructive: Task State's writers use `set-atom!` and rely on the live loop's in-process persistence (which works for cycle-scoped scalars like cycles-since-input that do not need to survive restart). The caller needs DURABLE persistence (learned beliefs must survive sessions), so it uses the file-backed model instead. Both follow the same disciplines; they differ in persistence substrate because they differ in durability need. This contrast is worth preserving: not everything needs file-backing, but learned beliefs do. The choice of persistence substrate follows from the durability requirement.

### The clover-shaped sheaf cognitive network (the destination)

The four-NACE sheaf is four learning loops (SN, FPN, DMN local stalks plus the global section) coupled over the switch-hub topology. This architecture is the shape of EACH stalk's learning loop: file-backed belief, `|-` revision, Mobius closure. The capability-registry caller is the first instance, the prototype stalk. When the SN stalk becomes the second NACE instance (per the SN reconciliation parking document), it uses this same pattern: SN truth values in file-backed storage, revised by `|-` from SN consequence-evidence, closing the same Mobius loop.

The restriction maps (Sprint 5+) compose revisions ACROSS stalks, and this is exactly why the revision had to stay in `|-` rather than Python: a restriction map reading one stalk's belief and revising another's is a MeTTa operation over MeTTa truth values. If the revision were Python, the restriction maps would have no substrate-native belief to compose. By keeping `|-` as the revision everywhere, every stalk's learning is composable by the restriction maps, and the global section can emerge from the coupled local revisions. The file-backed-belief, `|-`-revision pattern is the unit the entire sheaf is built from. Proving it on the capability-registry caller proves the unit; the sheaf is the unit instantiated four times and coupled.

---

## 7. The method, preserved as a reusable asset

The verification methodology that produced this resolution is itself worth keeping, because it caught two false-confidence errors that would otherwise have shaped the build wrongly.

**The probe-plus-wrapper pattern:** write a small MeTTa probe that exercises one specific behavior; wrap it in a Python diagnostic that runs the probe in-container via run.sh, extracts the raw output, and prints the RAW BLOCK before its verdict. The raw-block-before-verdict design is load-bearing: twice this session a verdict was wrong (a wrapper printed BUILD IN METTA on a failing test; a standalone result was misread as success), and both times the raw block printed alongside let the error be caught by reading the actual values against the claimed verdict. A diagnostic that hides its raw output and shows only a verdict can lie undetectably. One that shows its work can be checked.

**Verify, do not trust, including self-reports:** the system's claims (and a collaborator's claims) are data to verify, not facts to accept. Twice this session a claim was confidently wrong and was caught by checking the raw output or the arithmetic independently. This is not distrust of the collaborator; it is the discipline that lets the collaboration move fast without accumulating false foundations. Arithmetic gets verified to decimals. Verdicts get checked against raw output. "It works" is the start of verification, not the end.

**The Python NACE relationship:** the nace_adoption package (validated, 4/4 passing) is the reference implementation that proved the NAL math and established the canonical truth-expectation formula (te = f*c + 0.5*(1-c)). It is not a competitor to the MeTTa `|-` revision; it is the reference the MeTTa revision is checked against. When `|-` produces a revised value, it should match what the Python reference would compute for the same inputs. Two implementations, one canonical; the Python one validates, the MeTTa one runs in production. This relationship should be stated wherever both exist so neither is mistaken for the authoritative one alone.

---

## 8. What is now buildable, and what remains open

**Buildable now (every component proven by test):** the caller as a per-cycle read-`|-`-writeback loop. File holds the capability-efficacy belief, `|-` computes the revision, Python couriers, the filter reads the file-backed belief. Build against the verified registry interface (4/4 passing) plus the GAP edit (filter reads the learned belief).

**Open, deferred, and tracked elsewhere:**
- Cross-RESTART durability (does the file survive container restart, and is the file the single source of truth). This is the next persistence question after cross-cycle, and the file model is built for it, but it should be confirmed.
- The SN stalk as the second NACE instance (SN reconciliation parking document).
- The restriction maps composing revisions across stalks (Sprint 5+).
- The corvid/cephalopod enrichments (typed symbols, temporal indexing, motivational vectors) from the broader-framing document: parked as the roadmap beyond the next ridge, not the next step.

---

## 9. The one-line summary

State in files, cognition in MeTTa's `|-`, Python as courier; the belief revised by the system's own NAL operator becomes the prior for its next revision (the Mobius twist), closing a learning loop inside the substrate; this is the unit the capability-registry caller proves and the entire four-NACE sheaf is built from. Established by test, arithmetic verified, dead ends documented so they are not re-walked.
