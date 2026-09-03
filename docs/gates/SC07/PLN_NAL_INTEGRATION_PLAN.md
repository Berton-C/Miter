# PLN/NAL participation — source-bound integration plan

2026-09-03. Documentary response to Berton's request during SC06. Status: **PROPOSED implementation specializations; no PLN/NAL integration or runtime result claimed.**

## Authority and sequencing

The Constitution and ratified Soul specification remain the controls. PLN and NAL are native reasoning resources with which the Soul can form, compare and revise grounded possibilities. They are not additional constitutional authorities, a replacement Soul, or a scoring layer laid over the five mathematical foundations. Their useful participation is constructive, not limited to rejection or efficacy bookkeeping.

This plan implements S-102, S-501–504 and S-1001–1003; C-009/012/020–025/080–085; W-032/033; and the F-01–07 builder methodology. The specific library operator, evidence interpretation and consumer must be earned together. The five authorities constrain the meaning of that participation; an inference library does not implement their mathematics merely by returning a truth value.

This file and the accompanying [prior-work audit](PRIOR_WORK_INFERENCE_AUDIT.md) are prospective planning inputs in SC06's already permitted next-planning directory. **They are not a frozen SC07 implementation plan, do not reserve SC07 for PLN/NAL, and do not add a new prerequisite before the agreed G22 pause.** The frozen SC06 plan remains unchanged. Complete its bounded opportunity/quarantine claim, assess the actual rejoin prerequisites, and pause before G22 or repeating affected historical mechanical evidence if they are established. Any missing constitutive prerequisite instead determines the next frozen SC plan.

G24 already requires explicit native NAL revision and independent durable readback. G25 requires consequence-dependent later selection with a severed-learning comparison. These are required later obligations, not optional items that a benefit audit can discard. Broader PLN/NAL participation is selected from the concrete gaps below; it is neither indiscriminate import nor an indefinite untracked “future enhancement.” Revisit the opportunity register when composing the next affected gate and at the G22/G24 planning boundary, without executing those gates now.

## What participation can add to the five foundations

These are proposed finite realizations, not claims of completed mathematical implementation.

| Foundation and inherited meaning | Useful inference participation | Product and native consumer | Distinction that must survive |
|---|---|---|---|
| M24: partial frames, contact-answerability, interpretation use and inquiry | Construct competing explanations and identify which further contact would discriminate them; distinguish failed carriage from failed use of an available distinction | Provenanced hypotheses, support/opposition and a bounded inquiry consumed by the continuing undertaking | Repeated derivations are not fresh support; a hypothesis is not observed actuality, discharged obligation or permission |
| M25: Soul-grounded movement of one situated relational organization | Derive consequences, dependencies and alternative ways of participating from scoped premises; revise a fallible consequence expectation | Derived relations and candidate movements participating in the same D/Ω/I/W/C organization | R/A/P are not independent scores; confidence cannot compensate a failed material relation/distinction or supply admissibility |
| M255: generative organization and lawful transport | Propose new compositions or candidate carrier correspondences; expose which necessary mapping is still missing | Proposed relations/maps consumed by native composition and explicit translation checking | Similarity or probable equivalence is not GenTranslation/GenEquivV2; discovery of a possible mapping is not its proof |
| M260: partial participation of one occurrence and SameBecoming | Revise a situated belief while retaining the occurrence, premise lineage and the transformations that warranted revision | Versioned derived beliefs and dependency links consumed by continuity and re-expression | A revised belief does not rewrite its source contact; copied state or similar output is not developmental lineage |
| M263: n-ary, support-specific co-expression and Present context | Reason over explicitly represented joint dependencies and role-sensitive compositions; expose missing joint support | Scoped n-ary candidate relations consumed by the existing exact composition/witness checks | Pairwise confidence does not prove whole coupling; Fact9 roles are not renamed flourishings; CanCompose is not RecognizedCompose |

Both inspected libraries expose deductive, inductive and abductive operations. An initial bounded implementation may choose NAL for consequence revision and a particular PLN operation for relational inference, but those are implementation choices, not an assertion that NAL only learns one number or that only PLN can form hypotheses. Select the exact operation by its documented semantics and demonstrated benefit.

## Integration hazard: AtomSpace separation is not enough by assertion

Inspected PeTTa pin: `ae66fa8e41dcd5539d614706bd4e5cfb34f9608d`.

The pinned `lib/lib_nars.metta` and `lib/lib_pln.metta` define overlapping names. A scan of function-definition heads found:

`BestCandidate`, `ConfidenceRank`, `LimitSize`, `PriorityRank`, `PriorityRankNeg`, `StampConcat`, `StampDisjoint`, `Truth_Abduction`, `Truth_Deduction`, `Truth_Induction`, `Truth_Negation`, `Truth_Revision`, `Truth_c2w`, `Truth_w2c`, and `|-`.

This is a name inventory, not a complete arity, transitive-import or runtime-collision proof. Some shared names have different signatures or semantics. Inventory those distinctions before selecting an operator.

Source inspection also sharpens the proposed “separate spaces or qualified adapters” remedy. In `src/filereader.pl`, `process_form` stores a function's source expression in the supplied Space, then calls `translate_clause(Term, Clause)` without that Space and asserts the compiled clause. In `src/translator.pl`, the generated predicate and arity registration are keyed by the function name. Consequently, putting source atoms in `&pln` and `&nal` does **not establish isolation of compiled execution**. A wrapper that still calls ambiguous global `Truth_Revision` does not repair this.

Preferred first experiment: a minimal, explicitly qualified native operator closure, including every shared helper it actually calls, with source pin/hash and equivalence tests. An existing runtime namespace mechanism is acceptable only after execution tests demonstrate its isolation. Separate native worker processes are a fallback if needed, with their communication, restart and resource costs explicit. No Prolog implementation of the inference formula and no Python reasoning seam are permitted.

Before co-loading, prove in native PeTTa:

1. Each selected operator's arity, truth semantics, edge cases and expected result cardinality against an independent reference.
2. The same qualified result when alone, with the other library present, in both load orders, and after supported reload/restart.
3. No cross-family clauses, duplicate answers, helper contamination or accidental use of `|-`'s broad nondeterministic search.
4. Namespace checks catch a deliberately unqualified/cross-wired call and restoration recovers the expected result.
5. The tested interface cannot convert source provenance, model confidence or an STV into permission or a constitutional verdict.

These checks are future integration evidence, not reported as completed by this source audit. W-032 requires the intended NAL operation directly, not a broad proof-search wrapper from which a convenient answer is selected.

## Native inference contract

The first integration plan must freeze a typed product with at least:

- Inference identity; engine/library pin; qualified operator and interface version.
- Premise identities, source roots, scope/current cut, occurrence reference where applicable, and derivation dependencies.
- Explicit truth-value semantics and input meaning. NAL STV, PLN truth values, p-bits and heuristic priorities are not interchangeable because they share numeric shape. Any justified conversion declares purpose, version, assumptions and information lost under W-033.
- Evidence-family identities and overlap/common-ancestry accounting. Revision cannot count a repeated conclusion, retransmitted observation or multiple derivations from one source as independent evidence.
- Conclusion, standing, competing readings, unresolved uncertainty, assumptions and possible defeaters.
- The actual native consumer and the question/undertaking it serves. Inferential support is distinct from action authority and from a required mathematical witness.

Store immutable observations in their source standing and inference products in scoped derived organization, with dependency links sufficient to revalidate later use. Library stamps may help but are not automatically equivalent to Miter's evidence identity, n-user scopes or source lineage. Test those meanings explicitly. Missing, delayed, ambiguous, stale and inapplicable observations do not become negative evidence for numerical convenience.

Historical `nace_substrate.metta` and the original Soul architecture contain useful designs, but their example confidence values, thresholds, broad truth-value equivalence claims, raw-note interpretation and Python persistence are not automatically admitted. The quantale corpus's §29.5 supplies a bounded PLN closure-oracle contract with support/opposition and status; it is not a loaded constitutional verdict engine or proof that every library operation is mathematically adequate.

## Capability-led opportunity register

| ID / source meaning | Missing useful result and candidate mechanism | First consumer / next planning trigger | Evidence and falsifier / current status |
|---|---|---|---|
| PN-01 — S-1002; C-081–085; G24/25 | Typed consequences revise contextual efficacy through explicit native NAL revision | NACE belief update and later eligible module selection; required G24/25 planning after prerequisites | Independent reference/readback, duplicate/correlated and unknown-outcome cases, severed/restored revision and later selection. **REQUIRED, unimplemented** |
| PN-02 — M24; S-501/502/504 | Derive competing explanations and the next discriminating question, rather than merely transport an existing proposition | SC02-style derived support and SC03-style continuing inquiry; next gate needing partial-evidence entailment | A new justified question/alternative from relational premises; provenance severing removes it, irrelevant labels do not. No asserted false actuality. **PROPOSED, audit-identified** |
| PN-03 — M25; M263; T-14/15/34 | Expose a joint consequence or dependency not already supplied as an exact edge | Native possibility construction before existing exact participation/admissibility checks | Held-out relational compositions with essential third-party/joint relation; sever that relation and result changes. Pairwise averaging or a fabricated capability fails. **PROPOSED** |
| PN-04 — M255; M260; T-30/32 | Suggest a cross-context relation/map while retaining why and where it is reusable | Translation proposals and versioned continuity; next actual cross-carrier reuse requirement | Explicit mapping verified separately; broken correspondence or lineage blocks the claimed transport, not all inquiry. Similarity alone fails. **PROPOSED** |
| PN-05 — S-901/902/1001/1002 | Learn which eligible voice repair strategy helps in which evidenced context | Later VoicePolicy trials and consequence-sensitive selection | Genuine source-grounded alteration/outcome, matched future context, unaffected Soul obligations; parser incompleteness never masquerades as a model defect. **PROPOSED beyond SC06; PN-01 may cover its first useful slice** |
| PN-06 — M24; M260; S-402/504/607 | Reconsider only inferences affected by changed evidence and ask for missing contact | Dependency-directed revalidation in durable undertakings | Changed root invalidates/reconsiders dependent products; independent work survives; immutable past remains visible. Measure avoided recomputation. **PROPOSED; use existing exact machinery where sufficient** |

Each implementing gate expands the chosen row into the normal frozen source → representation → consumer → evidence → falsifier → status record. No row licenses broad inference throughout every reactor tick or a new global optimizer.

## Leveraged experiment and efficiency discipline

Start from a missing distinction in a useful undertaking, not from a wish to exercise a library. Compare the existing exact baseline with a bounded inference-assisted arm using the same inputs and declared resource envelope. Preserve an inference-severed arm, irrelevant perturbations and restoration. Measure a justified additional alternative, a discriminating inquiry, a consequence-earned improvement, or reduced necessary work—not the number of produced atoms.

An especially useful first vertical slice is **reasoning toward the next discriminating contact**: two supported but incompatible explanations, an explicit distinction they disagree about, and a scoped question whose answer would reorganize the next movement. The Soul determines its relevance and authority. An LLM may propose explanations; its proposals keep generated standing and cannot validate themselves.

Keep the first inference products provisional until they earn use. Avoid unbounded closure expansion; the native undertaking determines the question and a renewable resource-bounded computation. Existing exact graph reachability, provenance binding, current-cut validation, persistence and effect checks should stay exact. Adding probabilistic machinery to a correct equality check would add cost without capability.

Integration passes only when both judgments hold: operator/packaging evidence is correct, and the builder's control-grounded fidelity review shows real constructive participation without weakening the inherited distinctions. A benchmark improvement cannot overrule the controls. A narrow passed slice cannot be called implementation of all five authorities or all nine flourishings.

## Inspected source identities

Baseline Miter commit: `c574bcdf65168c48ecdc5f0b94f4377959f61b13`. SC06 was uncommitted work in progress during the audit; this is not a closure assessment of it.

| Source | SHA-256 |
|---|---|
| Constitution | `b6378a5cc6a256e94813bc2c4b6598339ee7d7982355fc05c6a1aafcded8d47c` |
| Ratified Soul spec | `1c8b8b63aa8c05f9c75345add978d35e074cf4cb76bf510013c945ae6098f4e7` |
| Build fidelity protocol | `6ddbaf2167d0f717fffe71bfba919fbf6b860b7278f174fd7e0c2e5da119236b` |
| Pinned `lib/lib_nars.metta` | `f2a1ab3be59c59128894367a2f52a12c0fafdf1fb26b4affedd48270b47d4b43` |
| Pinned `lib/lib_pln.metta` | `6b980321bbe9b49e5b12e2fcee0479ab1d5c7550c2104a67b0722a5b473da4ee` |
| Pinned `src/filereader.pl` | `b8941ea91e7e85ff389630372607b04541773e3055816c51be4dd6eb265c0c5d` |
| Pinned `src/translator.pl` | `628b0de73489bc1518a255bb061929b2fe5183ff28318fa495802228bd290a63` |

Local pinned checkout inspected at `/private/tmp/miter-g06-petta-ae66fa8`. Durable identity is the upstream commit plus file hashes, not that temporary pathname. No upstream-currentness, new mathematical proof, namespace-isolation runtime result, source-archive change, control amendment or Python dependency is claimed.
