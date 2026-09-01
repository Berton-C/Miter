# VAD Affect Perception: Consolidated State and Programme

**Status:** Consolidation of the VAD workstream from `shared_files/` and `shared_files/repos/omega_archive/`, read end to end 2026-07-17. v1.1 adds Section 7, the reconciliation with the v08.7.2 engine era, since every library in this consolidation predates the engine's durability protocol. This document is the single entry point for the VAD programme; the source files remain where they are until a curation pass promotes them.
**Provenance:** The archive library layer is authored by Clarity (April 2026, ClarityClaw era); the human-experience formalization is grounded in Berton's teaching and dated 2026-04-21; the operational Python layer and migration design are April 2026 working products.
**Reading order for this sprint:** this document first, then `lib_human_experience.metta` (the theory), then `lib_vad_sentence.metta` (the measurement model), then the migration design.

---

## 0. What VAD is in ClarityOmega, in one paragraph

VAD here is not sentiment analysis and not emotion labeling. It is the computational person-read: a three-axis measurement (valence, arousal, dominance) interpreted through a formal model of human experience in which the axes reveal what a person is doing (escaping disquiet, collapsing under weight, settling into clarity, pivoting into insight) rather than what they are (angry, sad, happy). The measurement is sentence-level trajectory, not word-level lookup, because a sentence is a journey and the movement carries more information than the position. The output routes to presence modes bounded by coded consent constraints, and couples to the soul by modulating value weights. The programme's end state is this perception running natively in the substrate beside the LLM's person-read, each calibrating the other, in the same pattern the soul already uses for verdict pre-computation.

---

## 1. The architecture, layer by layer, as it exists

### 1.1 Theory layer: `lib_human_experience.metta` (242 lines, 2026-04-21, archive)

The formal model of human experience of mind: eight axioms as executable definitions. The load-bearing ones for VAD:

- Axiom 4: SNS reactivity is escape behavior (disquieting sensation attributed externally produces SNS-Active).
- Axiom 5: insight requires PNS assertion; self-reorganization happens only when PNS asserts.
- Axiom 7: directing a person in SNS always increases confusion; a hard constraint, not a tendency.
- Axiom 8: non-directive presence is what allows PNS to assert.

Part 5 states what VAD reveals: an inner-landscape reading composed of `escape-pattern` (valence and arousal: active-escape-from-disquiet, collapsed-under-weight, not-escaping, uncertain-ground), `agency-story` (dominance: the person's relationship to their own experience), and trajectory direction. Part 4 models the awareness progression (immersed, noticing, witnessing) with progression possible only under PNS. The file closes with the role statement: create conditions for seeing, not telling.

This file is the code grounding for the SNS-to-PNS inversion thesis. It is currently archived and unloaded; the live genesis engine cites its Axiom 8 by name, which means the live code references an unloaded file. That citation-to-unloaded-source is a standing cleanup item.

### 1.2 Measurement layer: `lib_vad_sentence.metta` (302 lines, 2026-04-21, archive)

Sentence-level composite VAD with trajectory. The mechanics: clause segmentation; recency weighting (weight rises as position to the power 1.5 plus 0.3, because the last thing said carries the most weight); weighted composite across clauses; trajectory direction from inter-clause deltas (Improving, Deteriorating, Oscillating, Stable-Negative, Stable-Positive, Pivot); trajectory velocity (delta magnitude) and coherence (whether the three axes move together); movement stories mapping trajectory to meaning (breakthrough-moment, rapidly-losing-ground, searching-for-ground, held-in-weight, resting-in-okayness, confusion-shift); and routing from the full inner-landscape reading to a presence mode and response quality with confidence.

The two worked examples in Part 8 are the programme's justification and should survive into any external presentation:

- "I am struggling but I think I see something." Word-level composite reads negative, routes to comfort: wrong. Trajectory reads a high-coherence pivot: breakthrough-moment, route Spacious-Presence, witness-and-name: right.
- "Everything is fine, I just feel a little off." Word-level reads slightly positive, routes normal: wrong. Recency-weighted deterioration detects minimized distress: route Grounded-Witnessing, gentle-inquiry: right.

This is failure-that-looks-like-success detection at the affect level, structurally parallel to the co-occurrence gap signatures at the value level.

### 1.3 Routing layer: `lib_vad.metta` (122 lines, archive) and `vad_routing_substrate.metta` (18 lines, archive)

Typed routing from discretized VAD cells to strategies (empathic-attunement, gentle-activation, collaborative-exploration, witnessing-celebration, grounding-presence), strategies to actions, cells to tones, and tones to PNS word-register fields (the vocabulary the response should draw from per tone). The substrate variant carries the same routes with NAL stv values, per the migration design's step of making routing judgments native NAL.

Section 4 of `lib_vad.metta` codes the consent constraints and is the single most important passage for governance conversations:

- `(vad-constraint act-on-inner-experience-uninvited) forbidden`
- `(vad-constraint default-mode) informs-presence-not-action`
- `(vad-constraint before-exploring) ask-permission`

Affect perception informs presence; it never licenses uninvited action on someone's inner experience. This is enacted consent architecture at the perception layer, coded in April, and it belongs in any reply to the OmegaV2 governance exchange.

### 1.4 Soul coupling layer: `emotion_integration.metta` (22 lines, archive)

Ten emotion landmarks as VAD points, and value-weight modulation rules: detected fear or sadness raises the compassion weight 1.5x; detected anger raises honesty and humility 1.3x. This is the direct primitive by which the person-read modulates the value structure's live weighting, and it is the seam where the VAD programme meets the soul rather than merely standing beside it.

### 1.5 Operational Python layer (working products, `shared_files/` root)

- `sentence_vad_compositor_v2.py` (150 lines): the working mirror of the measurement layer; clause split, recency weights, composite, pivot detection with per-clause deltas, trajectory classification, word-level fallback for sparse clauses.
- `e2e_test.py` (42 lines): the full pipeline demonstrated: text to VAD to a 27-tone map (valence sign by arousal band by dominance band) to NAL statements with confidence to strategy. The TONE_MAP's 27 named tones are the native counterpart to Channel A's SOUL-TONE field.
- `revision_loop_v2.py` (65 lines): SNS-to-PNS lexical substitution (must to might, should to could, urgent to present, problem to pattern) with a valence self-audit pass: the inversion thesis applied to Clarity's own output register.
- `vad_chromadb_bridge.py` (60 lines, archive): the live lookup against the `nrc_vad_full` ChromaDB collection, discretizing to cells and emitting MeTTa atoms. The public `soul/vad_integration.py` imports this bridge.
- `live_integration_spec.md` (30 lines): the injection pattern: guidance string computed from VAD, prepended internal-only, stripped from user-visible output; V6 routing modes confirmed 15 of 15.

### 1.6 Assets

- `NRC_VAD_Lexicon_v2.1/`: the full NRC lexicon (unigrams and per-axis files) plus the v2 paper and the practical-ethics paper. The ChromaDB collection is built from this (44,728 word triplets per the continuity spec).
- `vad_lexicon_top100.metta` (104 lines): the top 100 emotionally significant words as `PB-Vec` atoms, p-bit encoded. This is the direct compatibility layer with the quantale engine's p-bit algebra: the lexicon already speaks the engine's native type.

### 1.7 Migration design: `clarity_vad_migration_design.md` (43 lines, 2026-04-16)

The five-step Python-to-MeTTa blueprint: lexicon entries as atoms, emotional comparison as NAL similarity, felt-sense fields as VSA bundles, the presence pipeline as NAL temporal revision with natural confidence decay, and composite emotional state as key-bound bundles unbindable by axis. Its dependency list records what was proven at design time: the VSA foundation, quantale algebra, and the STV-PB bridge all confirmed working, with the three VAD axes already modeled as NAL inheritance chains carrying measured stv values. Scope estimate: 28 Python components across 5 independently testable steps.

---

## 2. Integration targets

**Channel A (the person-read).** The native pipeline (lexicon lookup, sentence trajectory, tone) runs beside the LLM's Channel A evaluation, producing a native tone and inner-landscape reading per message. The two are calibrated against each other in the established soul-pre-compute pattern: native expectation recorded, LLM assertion recorded, agreement tagged, disagreement history conditioning future context. The honest claim shape: this nativizes a measurable layer of the person-read, not the whole of it; lexical trajectory cannot read irony, context, or history, which is what the calibration against the LLM layer is for.

**Channel B and C (evaluation).** Two seams. The value-weight modulation of 1.4 feeds detected affect into the evaluation's live weighting. And the escape-pattern reading cross-checks the tension vectors: urgency-narrows-thought has a measurable affect signature (negative valence, high arousal, collapsed time horizon), giving the judge-capture taxonomy a native sensor.

**The epistemic engine.** The PB-Vec lexicon encoding and the engine's existing affective probe surfaces (the v08.5 lineage carries affective-PNS-orientation and affective-tension-vector-audit probes) are the connection points: affect readings as p-bit evidence the engine's earned-confidence algebra can govern like any other evidence.

**Channel D and the output register.** The PNS word-register fields and the SNS-to-PNS substitution audit apply to Clarity's own voice: the inversion practiced on her output, not only perceived in input.

---

## 3. Ladder status, per component

- Theory and measurement libraries (`lib_human_experience`, `lib_vad_sentence`, `lib_vad`, routing substrate, emotion integration): isolated implementation, authored April 2026, archived in the repo-generation migration, not in the loaded manifest.
- Operational Python (compositor v2, e2e pipeline, revision loop, bridge): isolated implementation with focused verification (e2e tests run; V6 routing 15 of 15 per the integration spec).
- ChromaDB lexicon collection: live asset (the public bridge queries it).
- Public surface (`soul/vad_integration.py`): live but minimal; keyword-list extraction only, no trajectory, no channel wiring.
- Channel A wiring, calibration loop, engine coupling: specified by this document; not begun.
- Migration steps 1 through 5: step 1 partially done (top-100 PB-Vec atoms generated); steps 2 through 5 designed, not built.

## 4. Known defects and reconciliation items

1. `vad_grounded_register.metta` is corrupted: its variables are stripped throughout (empty argument positions where `$word` and bindings should be), consistent with a round-trip through unbound-variable rendering. Rebuild from intent before any load; do not load as-is.
2. `vad_validation_queries.metta` tests a `vad-route` return shape (VADState with Tone, Strategy, and Label) richer than any library version in the keep-set produces. Either a richer routing version exists elsewhere or the tests anticipate one; reconcile before treating the tests as the contract.
3. `vad_case_router.metta` is a single line without a trailing newline (wc reports 0 lines); verify paren balance before load.
4. The live genesis engine cites `lib_human_experience` Axiom 8 while the file is archived and unloaded: promote the file or annotate the citation.
5. Two near-duplicate copy sets exist in the archive (`lib_clarity_reasoning/` and `lib_candidates/` variants); the curation pass should pick one lineage and mark the other superseded.

## 5. Falsifiers

The programme is judged by these, in the project's standard form:

- **F1, native tone calibration.** Run the native pipeline beside Channel A on real cycles; record agreement between native tone and LLM SOUL-TONE. Falsified if native tone carries no signal (agreement at chance) or adds nothing the LLM layer does not already assert (perfect agreement with zero disagreement information).
- **F2, trajectory value.** The minimized-distress and buried-breakthrough sentence classes: falsified if sentence-trajectory routing does not outperform word-level composite routing on exactly the cases Part 8 of the measurement library claims (pivots and minimizations).
- **F3, weight modulation bite.** With value-weight modulation enabled versus disabled on identical inputs (freeze-replay form once available): falsified if modulated weights never change an evaluation outcome, meaning the coupling is decorative.

## 6. Relationship to the wider programme

This workstream is one of the three integration surfaces the v08.7.2 engine handoff names (Channels, Registry plus NACE, SSI). Its distinctive contribution to the project's external conversations: the consent constraints of 1.3 and the inversion practice of the revision loop are enacted fragments of the governance layer the OmegaV2 exchange identified as the field's co-equal deliverable, and the trajectory examples of 1.2 are the clearest demonstration available that the person-read is a perception problem, not a labeling problem.

## 7. Reconciliation with v08.7.2 (the era gap, stated so it cannot be forgotten)

Every library in this consolidation is April 2026 work. The v08.7.2 engine, its durability protocol, and the soul-owned evolutionary topology arrived in July. The April designs are unaware of them, and three reconciliations follow before any of this work goes live.

**7.1 The injection pattern is superseded.** The April `live_integration_spec.md` pattern (compute guidance, prepend it directly to context) predates the engine's law that observations are not durable growth and that adapters persist while the engine computes. Under the current architecture, a VAD reading is a runtime observation: it enters through the evolutionary topology (`soul/evolutionary/runtime.metta`), may become a pending candidate, earns validation evidence, and becomes durable only through soul approval and the Channel C write boundary. The per-cycle presence guidance can still condition the send (that is composition, not persistence), but nothing VAD-derived writes durable state outside the protocol chain. The April spec is kept as design history, not as the integration pattern.

**7.2 The type layer is already aligned; the rest of the lexicon is not.** `vad_lexicon_top100.metta` encodes entries as `PB-Vec` atoms, the engine's native p-bit type, so the top-100 slice already speaks v08.7.2. The remaining lexicon access runs through the ChromaDB bridge in raw floats. Migration step 1 should be restated as: lexicon entries as PB-Vec atoms governed by the engine's algebra, with the bridge as the generation tool rather than the runtime path.

**7.3 Confidence must be earned, not asserted.** The April routing tables carry asserted stv values (`(empathic-attunement (stv 0.9 0.9))`). Under the engine's organizing law, strength may be imagined but confidence must be earned. The route confidences become calibration-derived: initialized agnostic, revised by recorded agreement between native routing and observed outcomes, in the same pattern the NACE capability beliefs use. Asserted constants survive only as priors, flagged as priors.

The falsifiers in Section 5 are unchanged by this reconciliation; F3 in particular should be run in freeze-replay form under the engine's evidence discipline once that methodology lands.

## Document end
