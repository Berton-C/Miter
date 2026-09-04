# BGI Miter — PoC Build Packet

**Version:** 0.2 — constitutive always-on control alignment
**Date:** 2026-09-01  
**Project:** BGI Miter  
**Program name:** Miter  
**Primary construction agent:** ChatGPT Work, operating locally against the repository  
**Target host:** Apple-silicon MacBook Pro, 45 GB unified memory  

---

## 1. What this packet is

**Current build control (2026-09-04):** Berton has ratified the [Soul constitutive specification v0.4](MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md) alongside the [Constitution](CONSTITUTION.md). Version 0.4 makes the Fact9–Flourishing Constitutive Participation Bridge the cognitive joint through which contact, generation, participation, consequence, and Continuity of Mind become one process at every developmental cut. It prohibits building a generic assistant first and attaching the Soul afterward. Every new phase follows the [build-fidelity protocol v1.2](BUILD_FIDELITY_PROTOCOL.md). The first post-PoC program is the [Always-On Miter Assistant campaign v1.1](docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.md). The G33 seed-PoC result remains bounded historical evidence, not a declaration that the constitutive always-on assistant already exists, and the campaign plan does not itself authorize ongoing Mattermost reach.

It is deliberately smaller than the eventual Miter architecture, but it is not a toy agent. The PoC is required to prove two things:

1. **Miter is alive as the intended kind of cognitive system.** Miter must be a Soul-constituted PeTTa/MeTTa organism whose cognition is not trapped inside an LLM conversation, whose local LLM renders bounded semantic products, whose long-term memory preserves Continuity of Mind, whose voice is audited against Soul-determined intention, and whose ongoing activity includes both receptive readiness and endogenous development.

2. **Miter can build what was intentionally omitted from the seed organism.** After the core PoC is alive, Miter must use its own governed extension process to design, implement, test, and propose promotion of a new external surface. The first proving target is a Mattermost tentacle. The Mattermost implementation language is not predetermined; Miter may select the most effective modality, provided the extension obeys the typed boundary and governance contract.

The second proof is essential. A PoC that can only run what humans prebuilt proves a static architecture. Miter must demonstrate that the seed organism can expand its own available participation topology without rewriting its immutable Soul or allowing a candidate to certify itself.

---

## 2. The governing PoC claim

The Miter PoC succeeds only when one recorded, reproducible evidence package demonstrates all of the following:

> A native, continuously cycling PeTTa/MeTTa process, using narrow non-cognitive service membranes, can receive human or endogenous contact; construct a provenance-bearing D/Ω/I/W/C developmental cut in which support-specific Fact9 and the complete interconnected flourishing compass materially organize plural lawful continuations; natively construct, compare, join, inquire, undertake, defer, or decline movement; use Continuity of Mind, LLM, PLN/NAL, memory, and tools only as bounded participants; render and certify expression; receive consequence into the next cut; preserve the unfinished organization across restart and long temporal absence; develop and regenerate expressed capacity without mutating its germline; and extend governed external participation while credentials, effects, and memory access remain outside candidate sovereignty.

The first always-on slice may be bounded in external reach, deployment scale, and initially earned effect capabilities, but it must be complete in constitutive organization and open to general unfamiliar conversation, undertakings, endogenous participation, consequence, and continuity.

This is a mechanism proof. It does not claim a final Soul, complete open-ended-intelligence mathematics, final 26.9 kernel authority, universal autopoiesis, or unrestricted safe self-programming.

---

## 3. Continuity of Mind is a core requirement

Long-term memory is not optional in this PoC.

A system that can reason, self-modify, and speak from Soul but cannot remember a book project after three months is not usable as Miter. The LLM context window is not Miter's mind. ChromaDB semantic retrieval is therefore strengthened.

The PoC uses three coordinated memory surfaces:

1. **Immutable trajectory ledger:** append-only events recording contact, thought-process state, actions, consequences, memories, revisions, forks, merges, and promotions.
2. **Structured continuity projections:** exact project checkpoints, commitments, open questions, current artifacts, next moves, relationship scope, and active developmental state.
3. **ChromaDB semantic index:** persistent semantic retrieval over memory documents, episodes, project materials, summaries, and artifact excerpts.

ChromaDB is an index and document-retrieval service, not the sole source of historical truth. Raw records and exact continuity capsules remain independently inspectable and recoverable. Context presented to an LLM is a temporary projection of Miter's trajectory and memories, never the location of cognition itself.

The decisive memory test is not “a vector query returned something related.” It is:

> After process restart and a simulated ninety-day absence, a vague request such as “Where was I with the book?” reconstructs the correct project, latest authoritative checkpoint, exact artifact and section, unresolved question, intended next move, and source memory/event identifiers while preserving older superseded checkpoints as history.

---

## 4. Runtime topology

The default PoC runs the Miter core natively on macOS.

```text
Human / later Mattermost
          │
          ▼
Typed event ingress
          │
          ▼
PeTTa / MeTTa Miter reactor
  Soul + RNA + movement + memory policy
          │
          ├──────── Prolog LM membrane ───────► LM Studio on localhost
          │                                      Qwen / Nemotron / embedding model
          │
          ├──────── Prolog memory membrane ───► Chroma server on localhost
          │
          ├──────── Prolog store membrane ────► trajectory, capsules, snapshots
          │
          └──────── extension workshop broker ► isolated git worktree / sandbox
```

### Core language boundary

- Meaning-bearing cognition, scheduling, Soul judgment, memory admission, recall selection, movement construction, NACE revision, and extension adjudication belong in PeTTa/MeTTa.
- SWI-Prolog predicates may perform deterministic transport, JSON, HTTP, atomic file operations, hashing, process supervision, and service health checks.
- The Miter core must not use `py-call` or an in-process MeTTa/Python seam.
- External services and tentacles may use the modality best suited to their task. They communicate with Miter through typed event/effect contracts and cannot acquire cognitive or constitutional authority merely because they are capable.

### Local models already available

The initial model registry must include aliases for the two models already present in LM Studio:

- `qwen-local`: **Qwen3.8-27B 08-0MTP GGUF**
- `nemotron-local`: **Nemotron 3.5 30B A3B Antislop FTPO I1**

The exact LM Studio model identifiers are discovered at bootstrap and recorded in local configuration. Neither model is constitutionally preferred. A controlled bakeoff assigns initial roles from measured schema reliability, VoiceRNA repair rate, code-generation quality, latency, and resource use. NACE may later revise contextual efficacy from consequence evidence.

A separate local embedding model is required for ChromaDB indexing and querying. Its identifier, vector dimension, normalization, and chunking version must be recorded with every collection. Embeddings from different models must not be silently mixed in one collection.

---

## 5. PeTTa/MeTTa core, Prolog effect membranes, and sandboxed extensions

Docker is not required for the cognitive core. Miter-owned cognition remains in PeTTa/MeTTa. Narrow SWI-Prolog groundings under `effect_membranes/` perform HTTP/JSON transport, durable storage, hashing, process mechanics, and sandbox-broker calls. They return typed mechanical results to MeTTa; they do not own meaning, policy, memory admission, or cognitive state.

Python is not part of Miter's core, effect membranes, provider client, memory client, routing, state, or auditing path. LM Studio and ChromaDB remain replaceable localhost services reached through Prolog HTTP predicates. Their internal implementation languages do not give them cognitive authority.

```text
PeTTa/MeTTa decision
  -> effect_membranes/*.pl (SWI-Prolog mechanics)
  -> localhost service / durable store / sandbox broker
  -> typed result
  -> MeTTa interpretation
```

Miter uses a newly pinned Chroma service with its own persistence volume and collection `miter-ltm-v1`. The existing ClarityOmega Chroma container and persistence remain untouched. Any legacy access is read-only, or occurs through a separately verified copy and explicit migration procedure.

However, arbitrary generated extension code must not run unsandboxed as the logged-in user. The seed organism therefore includes a narrow **Extension Workshop Broker**. It owns candidate worktrees, test execution, build isolation, diffs, and promotion requests. Miter can ask it to create, write, test, inspect, and discard candidate extensions, but the broker—not the model—owns the actual host authority.

The default PoC policy is:

- native PeTTa/MeTTa for cognition, Prolog effect membranes for mechanics, and localhost LM Studio and isolated Miter Chroma services;
- git branch/worktree isolation for every candidate;
- Docker or an equivalently isolated runner for arbitrary executable extension tests;
- declarative MeTTa candidates may be trialed in a quarantine AtomSpace without Docker;
- live promotion of a networked or externally effectful tentacle requires explicit human approval.

This is not a retreat from native execution. It localizes containment at the exact surface where model-generated external code becomes dangerous.

---

## 6. Headlong inspiration in one paragraph

Headlong is an engineering inspiration, not architectural authority. Miter takes inspiration from its strongest patterns: append-only trajectory, context as a projection rather than mutable history, tiered compaction with raw retrieval, channel messages entering one ongoing stream, small composable tools, self-improvement through fork–test–merge, isolated credentials, watchdogs, status and panic controls, and exponential idle backoff that resets on contact. Miter rejects Bash as cognition, unrestricted shell authority, persona text as Soul, direct model execution, and Headlong's absence of privacy walls among participants. See `HEADLONG_INHERITANCE.md`.

---

## 7. Document authority order

ChatGPT Work must read these documents in this order:

1. `CONSTITUTION.md`
2. `MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md`
3. `AUTHORITY_MAP.md`
4. `POC_SPEC.md`
5. `ACCEPTANCE.md`
6. `BUILD_FIDELITY_PROTOCOL.md`
7. `docs/campaigns/ALWAYS_ON_MITER_ASSISTANT_V1/plan.md` and `plan.json`
8. `WORK_PROTOCOL.md`
9. `FAST_PATH.md`
10. `DECISIONS.md`
11. `SOURCE_MATERIALS_CHECKLIST.md`
12. `HEADLONG_INHERITANCE.md`

The order means:

- Ratified source authorities govern the bounded constitutional projection.
- `CONSTITUTION.md` governs the PoC implementation.
- The ratified Soul specification gives that constitution its complete constitutive implementation meaning and falsifiers.
- `POC_SPEC.md` defines what to build.
- `ACCEPTANCE.md` defines what counts as built.
- The build-fidelity protocol and active campaign govern additive construction without becoming Miter's cognition.
- `WORK_PROTOCOL.md` defines how Work may construct it.
- Conversation, comments, model output, implementation convenience, and passing a weaker substitute test cannot override those surfaces.

No implementation agent may edit a protected control or weaken acceptance during an active build gate or phase. Any required change stops the build and becomes an explicit human-reviewed decision in `DECISIONS.md`. D-043 authorizes this v0.4 synchronization only; it is not standing permission for later control drift. `GPT_WORK_KICKOFF_PROMPT.md` is a historical G00 prompt and is not current build control.

---

## 8. Historical seed layout

The following was the initial packet layout and remains useful orientation. It is not a current file-creation plan and does not authorize a runtime root. The active campaign must inventory actual promoted files and freeze its runtime-root decision before creating persistent state.

```text
miter/
├── README.md
├── CONSTITUTION.md
├── AUTHORITY_MAP.md
├── POC_SPEC.md
├── ACCEPTANCE.md
├── WORK_PROTOCOL.md
├── FAST_PATH.md
├── SOURCE_MATERIALS_CHECKLIST.md
├── DECISIONS.md
├── HEADLONG_INHERITANCE.md
├── GPT_WORK_KICKOFF_PROMPT.md
├── FINAL_POC_REPORT_TEMPLATE.md
├── PACKET_MANIFEST.json
│
├── constitution/
│   ├── soul.metta
│   ├── authority_manifest.metta
│   └── soul.sha256
│
├── src/
│   ├── main.metta
│   ├── reactor.metta
│   ├── events.metta
│   ├── movement.metta
│   ├── rna.metta
│   ├── context.metta
│   ├── continuity.metta
│   ├── memory.metta
│   ├── voice.metta
│   ├── vad.metta
│   ├── development.metta
│   ├── registry.metta
│   ├── nace.metta
│   └── extension.metta
│
├── effect_membranes/
│   ├── miter_llm.pl
│   ├── miter_chroma.pl
│   ├── miter_store.pl
│   ├── miter_integrity.pl
│   ├── miter_process.pl
│   └── miter_workshop.pl
│
├── config/
│   ├── models.example.metta
│   ├── services.example.metta
│   └── memory_schema.metta
│
├── modules/
│   ├── seed/
│   └── controls/
│
├── extensions/
│   ├── contracts/
│   ├── fixtures/
│   └── promoted/
│
├── tests/
│   ├── fixtures/
│   ├── unit/
│   ├── integration/
│   ├── severed_arms/
│   └── acceptance/
│
├── scripts/
│   ├── bootstrap-macos.sh
│   ├── run-miter.sh
│   ├── stop-miter.sh
│   ├── status-miter.sh
│   ├── panic-miter.sh
│   └── run-acceptance.sh
│
└── evidence/
    └── .gitkeep
```

Runtime state does not belong in git. The seed packet proposed `~/.miter/` as the following external layout, but that proposal is not active authority: do not create, populate, migrate, or chown it until AMA-1.1 freezes and authorizes the actual runtime root.

```text
~/.miter/
├── trajectory/
├── continuity/
├── memories/
├── chroma/
├── snapshots/
├── worktrees/
├── service-logs/
├── extension-logs/
└── assets/
    └── nrc-vad/       # local licensed asset; never committed or redistributed
```

---

## 9. Current build sequence

The numbered list below is the completed historical G01–G33 sequence. Current work follows the additive AMA-1 dependency graph rather than rerunning or extending it by gate-number momentum.

1. **Environment freeze and source pinning**
2. **PeTTa-to-Prolog native call proof**
3. **LM Studio structured-inference membrane**
4. **Trajectory and atomic store**
5. **Local embedding and ChromaDB memory membrane**
6. **Continuity-of-Mind project checkpoint proof**
7. **Soul and movement shell**
8. **VoiceRNA, bounded VAD, and output audit**
9. **Event reactor, quiescence, and endogenous development**
10. **Hot-loaded declarative capability and constitutional attack control**
11. **NACE consequence revision with discriminating selection change**
12. **Restart, replay, and full organism proof**
13. **Extension Workshop fork–test–merge physiology**
14. **Miter-authored Mattermost tentacle**
15. **Live Mattermost exchange, rollback control, and final evidence package**

A gate does not pass because code exists. It passes only through the exact positive and negative controls in `ACCEPTANCE.md` with raw evidence saved under `evidence/`.

The current progression is:

1. **AMA-1.1 — Constitutive always-on vertical slice and operator plane.** Build the supported service and the complete finite Fact9–flourishing–movement–consequence–continuity kernel together.
2. **AMA-1.2 — General contact, Continuity of Mind, and constitutive breadth.** Broaden people, projects, language, memory, and held-out composition through that same kernel.
3. **AMA-1.3 — Constitutive hardening and unfamiliar navigation.** Strengthen the existing causal organization against severance, disguise, contradiction, model substitution, and restart loss.
4. **AMA-1.4–1.7.** Grow capabilities, prove autonomous expressed-Soul repair, package the SNET evaluation release, then build the Local Surface Protocol and composable workbench.

No phase is complete from an isolated harness; its promoted result must participate through the supported running organism and unlock its named successor.

---

## 10. Explicitly excluded from the seed PoC

These remain later work unless a gate proves they are strictly necessary:

- four-NACE SN/FPN/DMN/global sheaf;
- full import of the 6,000-line quantale engine;
- a universal p-bit/STV conversion;
- MORK;
- browser, voice, video, email, shell, or calendar tentacles;
- unrestricted code execution by the LLM;
- a global master world model or global master prompt;
- multi-user memory sharing without scoped access law;
- full formal 26.6/26.9 runtime projection;
- a dashboard;
- a RAM disk;
- cloud inference as a requirement.

Mattermost is not prebuilt in the seed because it is the first extension proof.

---

## 11. Kill criteria

Stop the PoC and adjudicate before proceeding if any of these occurs:

- no clean PeTTa/Prolog path to LM Studio without `py-call`;
- memory retrieval cannot recover exact authoritative project state after restart;
- ChromaDB becomes the only copy of historical or project truth;
- Soul can be modified by a trial candidate;
- model output can directly execute, promote, or emit without native certification;
- VoiceAudit never changes a candidate response;
- VAD changes task permission or is treated as direct knowledge of inner state;
- idle continuation becomes synthetic perpetual inference without progress or stop law;
- NACE revision never changes a later choice;
- generated extension code can reach host secrets, Docker socket, or unapproved paths;
- Mattermost extension requires editing the Miter cognitive core rather than using the surface contract;
- the final proof cannot survive process restart;
- a severed arm behaves identically on every discriminating case.
