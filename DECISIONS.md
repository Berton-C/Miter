# BGI Miter PoC — Decision Ledger

**Version:** 0.1 Draft  
**Date:** 2026-09-01  
**Status:** Append-only human decision ledger  
**Rule:** Existing entries are not silently rewritten. Corrections create a new entry referencing the superseded entry.

---

## Decision-entry template

```text
## D-xxx — Title

Status: ACCEPTED | PROVISIONAL | OPEN | REJECTED | SUPERSEDED
Date:
Decision owner:

Question:
Decision:
Why:
Alternatives considered:
Consequences:
Revisit trigger:
Supersedes / superseded by:
```

---

## D-001 — Project and program name

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** What is the correct project/program name?

**Decision:** The project is **BGI Miter** and the program is **Miter**. Any accidental future use of “Mitter” is interpreted as Miter without treating it as a different project.

**Why:** “Mitter” was an accidental spelling influenced by PeTTa/MeTTa.

**Consequences:** All repository, service, namespace, and documentation names use Miter.

---

## D-002 — Twofold PoC

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** What must the minimal PoC prove?

**Decision:** The PoC has two inseparable proofs:

1. the seed Soul-constituted organism works;
2. that organism can build a materially omitted capability through its own governed extension process.

The first omitted-part proving target is Mattermost.

**Why:** A static human-built seed does not prove Miter can build beyond its instantiation.

**Consequences:** Final acceptance requires both Proof A and Proof B.

---

## D-003 — Continuity of Mind is core, not later scope

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Can long-term memory be omitted from the seed to move faster?

**Decision:** No. Continuity of Mind is a constitutive PoC requirement. Miter must recall exact project state after long absence, including a book project untouched for three months.

**Why:** A highly capable but amnesic Miter would be frustrating and unusable; the context-window goldfish failure is unacceptable.

**Alternatives considered:** Defer Chroma/LTM until after voice/self-modification proof.

**Consequences:** Trajectory, structured continuity capsules, Chroma semantic memory, restart rehydration, and the ninety-day book test enter the critical path.

---

## D-004 — ChromaDB is retained and strengthened

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton with architectural qualification

**Question:** Does ChromaDB belong in Miter?

**Decision:** Yes. ChromaDB is a staple semantic-memory service and remains part of the PoC.

It is not the only historical or exact-continuity authority. The canonical stack is:

```text
append-only trajectory
+ structured continuity capsules
+ durable admitted memory documents
+ Chroma semantic index
```

**Why:** Chroma gives useful semantic retrieval; exact project continuity requires additional structured authority.

**Consequences:** Chroma collection loss must be recoverable from durable records.

---

## D-005 — Existing Chroma data is protected

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** May bootstrap reuse or alter the existing ClarityOmega/VAD Chroma collections directly?

**Decision:** Existing collections are inventoried and backed up before use. The seed creates `miter-ltm-v1`. Legacy memory can be read/migrated only through an explicit, reversible process.

**Why:** The user's existing memory is valuable and must not become test collateral.

---

## D-006 — No four-NACE sheaf in the PoC

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Does the SN/FPN/DMN/global four-loop sheaf belong in the first Miter build?

**Decision:** No. It may be reconsidered after the PoC is alive.

**Why:** It is not necessary to prove the core organism and would enlarge the build surface prematurely.

**Consequences:** NACE enters only as a minimal contextual capability-efficacy/plasticity loop.

---

## D-007 — Meaning-bearing core is PeTTa/MeTTa

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** What belongs in the cognitive core?

**Decision:** Soul, state transitions, RNA lifecycle, scheduling, memory policy, recall selection, movement construction, NACE revision, voice intention/audit, and extension adjudication live in PeTTa/MeTTa.

**Why:** Miter is a PeTTa/MeTTa-first project and should have one inspectable cognitive genome.

---

## D-008 — No in-process MeTTa/Python seam in the core

**Status:** ACCEPTED WITH FEASIBILITY GATE  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Must the core avoid Python?

**Decision:** The default architecture uses no `py-call` or Janus/Python runtime path for Miter cognition. Direct imported Prolog predicates provide mechanical services.

This is motivated by leverage and seam reduction, not purity. If G02–G04 disprove the path, stop and adjudicate rather than forcing awkward shell workarounds.

**Consequences:** External Chroma or tentacle services may still be implemented in Python; they are outside the in-process cognitive seam.

---

## D-009 — Prolog is the native mechanical membrane

**Status:** PROVISIONAL UNTIL G02–G04  
**Date:** 2026-09-01

**Question:** How does the MeTTa core reach HTTP, JSON, files, process control, and exact lookup?

**Decision:** Use small SWI-Prolog libraries imported through PeTTa.

**Why:** PeTTa already runs in SWI-Prolog; this removes a cross-runtime object seam while preserving MeTTa ownership of meaning.

**Revisit trigger:** Native extension or marshalling proves unreliable on the pinned Mac runtime.

---

## D-010 — External tentacles use the fitting modality

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Must every extension be PeTTa/MeTTa?

**Decision:** No. Anything core to Miter is PeTTa/MeTTa. External tentacles such as Mattermost, HTML, voice, or video may use the most effective implementation modality.

**Constraint:** They obey typed event/effect boundaries and cannot acquire cognitive or constitutional authority.

---

## D-011 — Native macOS core first

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** Docker or native Mac for the core?

**Decision:** Run the Miter core natively on the Apple-silicon MacBook Pro unless Task 00 proves a blocker.

**Why:** Lower friction, direct use of local services, and maximum host capability.

**Consequences:** Docker remains available for generated extension isolation and later reproducibility/CI.

---

## D-012 — No RAM disk in the initial architecture

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** Should Miter or model files run from a RAM disk?

**Decision:** No initial RAM disk.

**Why:** Unified memory is shared by model weights, KV cache, Metal, SWI-Prolog, services, and macOS; the OS already caches files. A RAM disk is not a sandbox or durability surface.

**Revisit trigger:** Profiling proves disk I/O—not inference or memory pressure—is a material bottleneck for disposable scratch work.

---

## D-013 — LM Studio is the initial local inference service

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Which local serving layer should the PoC use?

**Decision:** Use the user's existing LM Studio service through its localhost compatible API.

**Why:** The required models are already installed and running; replacing the service adds no immediate leverage.

---

## D-014 — Initial chat-model profiles

**Status:** ACCEPTED AS AVAILABLE PROFILES; ROLE OPEN UNTIL G05  
**Date:** 2026-09-01

**Decision:** Register discovered IDs for:

- Qwen3.8-27B 08-0MTP GGUF;
- Nemotron 3.5 30B A3B Antislop FTPO I1.

Use aliases `qwen-local` and `nemotron-local`. Assign roles after a controlled bakeoff.

**Why:** Model suitability is contextual and should be measured.

---

## D-015 — Separate embedding profile

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** Can chat-model identity be treated as embedding identity?

**Decision:** No. A separate local embedding profile with model ID, vector dimension, chunking, normalization, and schema version is required.

**Consequences:** Different embedding profiles are not silently mixed in one collection.

---

## D-016 — VAD belongs as bounded perception and voice audit

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton with authority bounds

**Question:** Does VAD earn a place in the seed?

**Decision:** Yes, as a lexical/trajectory cue for presence and VoiceRNA fidelity.

It is not direct or sovereign knowledge of a human's inner state, diagnosis, or task-permission authority.

**Consequences:** Coverage, uncertainty, trajectory fixtures, consent constraints, and no-redistribution rules are acceptance requirements.

---

## D-017 — Preserve the local NRC VAD asset; do not redistribute

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** Use the user's private local asset/collection. Do not commit the lexicon, include it in evidence, or expose it to third parties. Record checksum and attribution only.

**Why:** Source terms prohibit redistribution and distinguish research from commercial use.

---

## D-018 — Quantale corpus is selective source material

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** Does the full quantale engine enter the seed?

**Decision:** No full monolith. Extract only concepts or small modules that earn their place through a consumer and severed-arm test.

**Admitted direction:** regulatory signals for contact, provenance, contradiction, inquiry, living questions, attention, and developmental pressure.

**Restriction:** No p-bit or provisional “quantale” score becomes Soul authority.

---

## D-019 — NACE is plasticity, not constitution

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** NACE revises contextual efficacy/causal beliefs from consequence. It cannot rewrite Soul, success law, provenance law, or promotion authority.

**Consequences:** At least two competing capabilities and a later selection difference are required.

---

## D-020 — VoiceRNA owns every human-facing surface

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Question:** Is one-shot Soul prompting sufficient?

**Decision:** No. Soul constructs communicative intention; the LLM renders; AuditRNA may reject and return work for repair; only a certified expression reaches the human.

**Consequences:** Mattermost replies also pass VoiceRNA.

---

## D-021 — Persistent readiness includes Miter's own interests

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Decision:** Miter may pursue Soul-grounded curiosity, creative endeavors, self-improvement, and bounded self-authored development when capacity permits.

**Paired law:** Miter also has a right to quiescence and may not manufacture perpetual inference.

---

## D-022 — First self-modifying surface is declarative

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** Should the first proof allow arbitrary generated MeTTa code to run live?

**Decision:** No. The first self-modification is a schema-constrained declarative module interpreted by fixed machinery.

**Why:** It proves changed future cognition and hot loading while preserving a small authority surface.

**Revisit trigger:** Declarative proof is complete and a bounded executable-MeTTa lifecycle is specified and tested.

---

## D-023 — Executable extension work uses fork–test–merge

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** Generated executable extensions live in isolated git branches/worktrees and run in a constrained sandbox. Main is not modified during trial.

**Source inspiration:** Headlong, translated through Inquiry-24 lifecycle and Miter governance.

---

## D-024 — ChatGPT Work builds the workshop, not Mattermost

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Question:** What may the human construction agent prebuild?

**Decision:** ChatGPT Work builds the generic surface contract, mock fixture, workshop broker, tests, and promotion machinery. It does not implement the Mattermost tentacle in the seed.

**Why:** Proof B requires Miter-authored omitted capability.

---

## D-025 — Mattermost is the first omitted-part proving target

**Status:** ACCEPTED  
**Date:** 2026-09-01  
**Decision owner:** Berton

**Decision:** After Proof A, Miter builds a Mattermost tentacle through the extension workshop.

**Why:** Mattermost is valuable, already familiar in the ClarityOmega environment, and demonstrates a real external surface.

---

## D-026 — Mattermost bridge is a pure adapter

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** The bridge maps authenticated Mattermost events/effects to the generic Miter surface contract. It does not reason about Soul or directly query LTM.

**Consequences:** Allowlist, stable IDs, cursor, idempotency, credential isolation, and memory-scope mapping are mandatory.

---

## D-027 — Headlong trajectory/context patterns are adopted

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** Adopt:

- append-only JSONL DAG;
- context as projection;
- tiered resolution with raw retrieval;
- fork–test–merge;
- small tools;
- bridge as pure client;
- status/watchdog/panic;
- adaptive idle backoff.

**Restriction:** Translate into Miter's typed, scoped, Soul-governed architecture.

---

## D-028 — Headlong Bash cognition is rejected

**Status:** REJECTED  
**Date:** 2026-09-01

**Decision:** Bash and immediate model-generated shell execution do not enter the Miter cognitive core.

**Why:** It collapses generation and effect authority and conflicts with MeTTa-first cognition.

**Allowed:** A bounded sandboxed extension may use Bash when justified.

---

## D-029 — The exact project checkpoint outranks semantic similarity

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** For “where did I leave off?” questions, resolve a structured authoritative capsule. Chroma may locate candidates or enrich the answer, but cannot silently choose current state by nearest-vector score.

---

## D-030 — No global master prompt or master world representation

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** Multiple RNA species use local context projections and meet through typed bridge objects. The seed does not build one universal prompt containing all cognition and memory.

---

## D-031 — Native core plus external services is not impurity

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** LM Studio, ChromaDB, Mattermost, and sandbox runners are services/tentacles. Their implementation language is not part of Miter's cognitive authority.

**Why:** The meaningful boundary is what decides, not whether every process uses one language.

---

## D-032 — No scalar Soul vote

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** No VAD average, p-bit, STV, utility, confidence, or weighted pattern score may directly produce the constitutional verdict.

**Why:** Ratified alignment and movement obligations are structured and non-compensatory.

---

## D-033 — The PoC uses a bounded seed Soul projection

**Status:** ACCEPTED WITH EXPLICIT LIMITATION  
**Date:** 2026-09-01

**Decision:** Build the smallest Soul projection required to govern the PoC from inherited authority and original Soul implementation evidence.

**Limitation:** It is not presented as final 26.9 Soul/flourishing mathematics.

---

## D-034 — Human live approval remains required

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** Miter may autonomously generate and test internal/declarative candidates and mock external extensions. Human approval gates live credentials, live Mattermost reach, and any extension with meaningful external effects.

**Revisit trigger:** Later ratified governance explicitly changes this authority topology.

---

## D-035 — Evidence package is part of the PoC product

**Status:** ACCEPTED  
**Date:** 2026-09-01

**Decision:** The PoC is not complete without raw, reproducible evidence and severed-arm results. A live demo without retained evidence is insufficient.

---

## D-036 — Miter effect membranes are in-process SWI-Prolog groundings

**Status:** ACCEPTED
**Date:** 2026-09-01

**Decision:** Miter-owned cognition is implemented in PeTTa/MeTTa. Mechanical groundings live under `effect_membranes/` and are loaded through PeTTa's Prolog-extension path. The Miter runtime path contains no Python client, helper, object, callback, `py-call`, or Janus seam. Prolog performs only bounded mechanics; MeTTa owns meaning and policy.

**Consequences:** External localhost services may use their own implementation languages, but they remain replaceable and non-authoritative behind typed HTTP boundaries.

---

## D-037 — Effect predicates are narrow, deterministic, and total

**Status:** ACCEPTED
**Date:** 2026-09-01

**Decision:** Each imported effect predicate accepts scalars or opaque references and returns exactly one typed success or typed error. It leaves no open choice points, never converts failure into silence, holds no meaning-bearing state, writes no cognitive AtomSpace state, and performs only the exact authorized mechanical operation.

**Consequences:** Higher-order interpretation, admission, routing, and authorization remain explicit MeTTa decisions.

---

## D-038 — Miter has an isolated Chroma deployment

**Status:** ACCEPTED
**Date:** 2026-09-01

**Decision:** The existing ClarityOmega Chroma container and persistence remain untouched. Miter receives a newly pinned Chroma container or process, a separate persistent volume or approved dedicated bind mount, and a new collection named `miter-ltm-v1`. Existing legacy or NRC data may be accessed read-only, or migrated only from a verified copy. Miter and ClarityOmega never share writable Chroma persistence.

**Consequences:** Chroma remains a non-authoritative, rebuildable semantic index. Task 00 must identify the exact image/version, localhost endpoint, and new Miter persistence location before implementation.

---

# Open decisions for Task 00 / early gates

## D-O01 — Exact PeTTa source and pin

**Status:** OPEN

Task 00 must identify the source/version most suitable for native macOS and direct Prolog imports.

---

## D-O02 — Exact local embedding model

**Status:** OPEN

Choose after enumerating LM Studio/local embedding options and measuring deterministic dimension/schema behavior.

---

## D-O03 — Chroma service deployment mode

**Status:** SUPERSEDED BY D-038

Deployment mode is resolved. Task 00 must still determine the exact pinned image/version, localhost endpoint, and new Miter volume or bind path; it must not attach Miter writable state to existing ClarityOmega persistence.

---

## D-O04 — Initial Qwen/Nemotron role assignment

**Status:** OPEN UNTIL G05

The bakeoff decides renderer, auditor/reviewer, candidate-generation, and extension-code roles.

---

## D-O05 — Extension sandbox technology

**Status:** OPEN

Default candidate is Docker because it is already available and provides an understandable boundary. Task 00 may identify Apple Containers or another equivalent, but the acceptance contract remains unchanged.

---

## D-O06 — Mattermost extension implementation language

**Status:** INTENTIONALLY OPEN TO MITER

Miter chooses based on the bridge contract, available libraries, sandbox support, and measured build/test consequences.

---

# Final ledger rule

A later implementation surprise does not retroactively change these decisions. It creates a new decision entry with evidence and an explicit supersession relation.
