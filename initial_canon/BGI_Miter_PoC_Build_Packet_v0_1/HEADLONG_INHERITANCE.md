# BGI Miter PoC — Headlong Inheritance Assessment

**Version:** 0.1 Draft  
**Date:** 2026-09-01  
**Status:** External engineering-inspiration assessment; not constitutional authority  
**Source basis:** `laude-institute/headlong` repository README, philosophy, launch description, and Telegram/Slack bridge documentation as inspected on 2026-09-01

---

## 0. Ruling

Headlong contains several highly leveraged mechanisms that earn a place in Miter's PoC **after translation into Miter's constitutional architecture**.

The central ruling is:

> Headlong is strongest where it treats trajectory, context, memory resolution, channel ingress, and self-improvement as explicit inspectable engineering surfaces. It is least aligned with Miter where Bash and immediate model-generated shell execution become the mind and hands.

Miter should inherit the former and reject the latter.

---

# I. What Headlong actually contributes

Headlong's public design presents a persistent-agent microharness built from small shell executables. Its core claims include:

- an append-only JSONL trajectory organized as a DAG with fork and merge;
- context as a projection of trajectory rather than the trajectory itself;
- tiered context compaction in which recent entries remain verbatim and older history is progressively summarized but still retrievable in raw form;
- subagents inheriting access to ancestor trajectories;
- persistent agency in which messages become events in an ongoing stream rather than resetting the agent into a new isolated conversation;
- self-improvement by forking the codebase, testing changes, merging successes, and discarding failures;
- Docker by default for generated-code execution;
- small composable tools rather than one large hidden framework;
- external channel bridges that remain clients of an existing event/trajectory API;
- allowlists, isolated credentials, and cursor/reconnect behavior for bridges;
- status, watchdog, stop, and operational recovery surfaces;
- local/OpenAI-compatible model-server support in current development.

These are real and relevant to Miter.

---

# II. Patterns that earn a place in the Miter PoC

## H-001 — Append-only trajectory DAG

### Headlong contribution

Every thought, message, action, and result enters an append-only JSONL trajectory. Fork and merge create a DAG rather than rewriting one linear history.

### Miter translation

Miter adopts an append-only canonical event ledger with:

- stable event IDs;
- parent/fork references;
- source cut and target cut;
- provenance;
- content hash;
- scope;
- event type;
- result/standing;
- merge references where applicable.

### Why it earns a place

This directly supports:

- Inquiry-24 immutable history;
- additive interpretation;
- developmental lineage;
- candidate trial branches;
- restart continuity;
- exact evidence packages;
- recovery without pretending history did not occur.

### Miter strengthening

Headlong's trajectory is engineering history. Miter additionally separates:

- contact;
- internal movement;
- semantic reading;
- memory admission;
- candidate generation;
- certified effect;
- witnessed consequence;
- accepted development.

One JSONL envelope can hold them, but their types and authority remain distinct.

---

## H-002 — Context is a projection, not memory itself

### Headlong contribution

The context tool renders a trajectory into an LLM message array. History is not compacted away in place.

### Miter translation

`ContextRNA` builds a purpose-specific context from:

- Soul excerpts material to the current movement;
- current project/relationship capsule;
- recent verbatim events;
- progressively summarized older history;
- semantically retrieved memory documents;
- raw-source links;
- uncertainty and scope.

### Why it earns a place

This is the correct response to the “LLM context window as goldfish mind” failure. Miter's mind and history remain outside the call; the call receives a temporary reading frame.

### Miter strengthening

Context is RNA-specific. Person-reading, VoiceRNA, DevelopRNA, and ExtensionRNA do not all receive the same global prompt.

---

## H-003 — Tiered context resolution

### Headlong contribution

The whole trajectory remains available at exponentially decaying resolution: recent material is verbatim, older material is summarized, and summaries act as indexes back to raw entries.

### Miter translation

The PoC uses four context tiers:

1. current exact obligations/capsule;
2. recent verbatim events;
3. older admitted summaries and episodes;
4. raw artifacts retrievable by ID.

### Why it earns a place

It combines useful bounded context with recoverability and prevents “compaction” from becoming historical erasure.

### Miter strengthening

Tier selection is governed by question, scope, provenance, and materiality—not only age. A three-month-old project checkpoint can outrank yesterday's irrelevant conversation.

---

## H-004 — Messages enter one ongoing stream

### Headlong contribution

External messages land as observations in the agent's existing trajectory. The agent remains one ongoing process rather than spawning a new disconnected chat mind.

### Miter translation

All surfaces emit canonical `SurfaceEvent` atoms into the same reactor and append-only trajectory.

### Why it earns a place

It preserves continuity across Mattermost, later voice, terminal, or other channels.

### Miter strengthening

“One stream” does not mean “one undifferentiated privacy pool.” Miter enforces:

- authenticated identity;
- relationship scope;
- project scope;
- channel/team scope;
- memory disclosure law;
- surface-specific rendering.

---

## H-005 — Fork–test–merge self-improvement

### Headlong contribution

An agent forks code and optionally trajectory, changes something, runs it, and merges successes or discards failures. Main remains untouched during trial.

### Miter translation

The Extension Workshop Broker owns:

- branch/worktree creation;
- candidate write access;
- sandbox test execution;
- diffs;
- artifacts;
- review requests;
- discard;
- promotion proposal;
- human-approved merge for live reach.

### Why it earns a place

This is the cleanest engineering counterpart to:

```text
candidate ≠ trial ≠ consequence ≠ accepted development ≠ durable organization
```

### Miter strengthening

A passing test is not sufficient. Promotion additionally requires:

- Soul admissibility;
- no hard-floor regressions;
- provenance;
- candidate cannot own the acceptance test;
- independent consequence/review;
- rollback projection;
- immutable history.

---

## H-006 — Small composable tools

### Headlong contribution

Headlong uses small tools such as trajectory, context, memory, skill, view, put, and sub operations rather than burying everything in one framework.

### Miter translation

Miter's fixed membranes and broker operations remain narrow:

```text
llm-submit / result access
chroma-add / query / get
trajectory-append / verify
capsule-write / resolve
hash / atomic-write
worktree-create / test / diff / discard / propose
surface-ingress / effect-commit
```

### Why it earns a place

Small seams are easier to reason about, test, replace, and deny authority to.

### Miter strengthening

Each tool has a typed contract and authority manifest. Composition occurs through MeTTa-owned movements, not free shell pipelines.

---

## H-007 — Generated-code sandbox by default

### Headlong contribution

Headlong uses Docker where available to contain generated code.

### Miter translation

Miter's cognitive core runs natively, but arbitrary generated extension code runs through an isolated workshop sandbox.

### Why it earns a place

This localizes isolation at the genuinely dangerous surface without paying Docker complexity for the entire cognitive organism.

### Miter strengthening

The candidate does not receive:

- host home;
- secrets;
- main-branch write;
- Docker socket;
- undeclared network;
- Chroma;
- Soul;
- event-history writer.

---

## H-008 — Bridge as pure client

### Headlong contribution

The Telegram bridge acts as a pure client of the existing web API and trajectory format. It maps authenticated chat identity into an event and tails trajectory output for replies. It uses an allowlist and isolates the bot token.

The Slack bridge similarly maps workspace/channel/thread identity into the common event flow.

### Miter translation

The first Mattermost tentacle must:

- be a pure transport/identity adapter;
- produce `SurfaceEvent`;
- consume `SurfaceEffect`;
- use stable IDs and cursor state;
- enforce allowlist before cognition;
- isolate credentials;
- use idempotency keys;
- never query Chroma or Soul itself.

### Why it earns a place

This provides an excellent precedent for proving that a new channel can be added without changing the cognitive core.

### Miter strengthening

Miter's bridge contract additionally carries memory scope and relationship identity, and every human-facing reply must pass VoiceRNA certification.

---

## H-009 — Status, watchdog, stop, and panic

### Headlong contribution

Persistent agents require explicit operational surfaces to see whether they are alive, stop them, and collect failure evidence.

### Miter translation

The PoC includes:

- `status-miter.sh`;
- `stop-miter.sh`;
- `panic-miter.sh`;
- service health;
- current RNA and cut;
- last event ID;
- last certified effect;
- active worktree/sandbox;
- quiescence/wake state;
- evidence bundle generation.

### Why it earns a place

Always-on without legibility and immediate stop authority is irresponsible and nearly impossible to debug.

---

## H-010 — Adaptive idle backoff

### Headlong contribution

Current Headlong engineering includes a persistent loop that does not need a busy-spin rate and can adapt its waiting behavior.

### Miter translation

When Miter is quiescent:

- idle wait increases up to a cap;
- new contact, due obligations, or developmental opportunity reset it;
- waiting never creates a synthetic autonomy event by itself;
- status remains observable.

### Why it earns a place

It makes persistent readiness resource-conscious while preserving endogenous work.

---

## H-011 — Subagent ancestry visibility

### Headlong contribution

Subagents can see ancestor trajectory and understand why they were created and what has already been tried.

### Miter PoC ruling

Do **not** build a general subagent architecture in the seed PoC.

However, preserve the underlying principle in candidate worktrees and RNA forks:

- every fork receives its origin event;
- parent question;
- relevant prior attempts;
- scope;
- reason for branching;
- merge/termination condition.

This earns a place as lineage, not as a multi-agent feature.

---

# III. Headlong ideas that do not enter the Miter core

## R-H01 — Bash as cognition

Headlong deliberately makes Bash the model's only general tool. That is coherent for its project, but it does not fit Miter.

Miter rejects:

```text
LLM writes shell
→ shell executes immediately
→ next LLM call
```

because it collapses:

- semantic generation;
- execution authority;
- effect scope;
- success judgment;
- recovery;
- often, host security.

Bash may be selected for a bounded tentacle or script inside a sandbox. It is not Miter's cognitive substrate.

---

## R-H02 — Unrestricted shell as the universal tool system

Miter's core has no general shell capability. Fixed broker operations replace it.

The Extension Workshop may run declared build/test commands inside a constrained environment, but generated code cannot choose arbitrary host commands.

---

## R-H03 — Persona or prompt text as Soul

Headlong identities and thinker prompts are useful operating configuration. They do not meet Miter's requirement for an immutable, queryable, causally enacted Soul.

Miter's Soul must constrain:

- transcription;
- movement construction;
- memory admission;
- model role;
- expression;
- effect;
- self-modification;
- promotion;
- quiescence and endogenous work.

---

## R-H04 — The model owns continuation and completion

A model setting `FINAL` or simply continuing to emit Bash is not Miter's continuation law.

Miter continues only when the reactor can construct a lawful ready movement with a budget and stop condition.

---

## R-H05 — Compaction without project authority

Headlong's tiered summaries are excellent context indexes, but a vague semantic summary alone does not satisfy Miter's exact Continuity of Mind.

Miter adds structured project capsules with explicit current-authority and supersession relations.

---

## R-H06 — One identity stream without privacy walls

A common trajectory is valuable, but Miter must not expose one person's memory to another because it happens to be semantically relevant.

Scope filtering precedes retrieval.

---

# IV. Direct effects on the Miter build packet

Headlong materially changes this PoC in seven places:

1. **Canonical trajectory is a DAG, not one mutable history file.**
2. **Context is explicitly a projection of trajectory plus scoped memory.**
3. **Context uses tiered resolution with links back to raw source.**
4. **Extension self-improvement uses fork–test–merge rather than live self-edit.**
5. **The core includes status/watchdog/panic from the beginning.**
6. **Idle readiness uses adaptive backoff.**
7. **Mattermost is specified as a pure bridge to the common event/effect contract.**

These are not decorative acknowledgements. Each has an acceptance gate.

---

# V. Headlong-inspired acceptance matrix

| Pattern | Miter gate | Severed control |
|---|---|---|
| Append-only trajectory DAG | G07 | old-line mutation breaks integrity |
| Context as projection | G11/G12 | capsule severing exposes non-authoritative recall |
| Tiered compaction/raw retrieval | G10/G11 | summary-only arm loses exact source |
| Fork–test–merge | G28 | direct-main-write rejected |
| Sandbox generated code | G27 | path/secret/socket attack blocked |
| Pure channel bridge | G29–G31 | direct Soul/Chroma access rejected |
| Allowlist/identity | G30/G31 | unauthorized event never reaches cognition |
| Idempotent reply/cursor | G30/G31 | duplicate/reconnect does not duplicate effect |
| Status/panic | G07/G18/G31 | panic stops effect path |
| Idle backoff | G19 | non-backoff arm shows excess wakeups |
| Ancestor lineage | G21/G28 | candidate without origin lineage rejected |

---

# VI. Final assessment

Headlong does not provide Miter's Soul, proof-relevant movement, non-compensatory alignment, Continuity of Mind authority, VAD consent law, NACE plasticity boundary, or non-self-certifying self-development.

It does provide several missing pieces of excellent persistent-agent engineering.

The strongest synthesis is:

```text
Headlong's trajectory discipline
+ Miter's immutable developmental history

Headlong's context projection
+ Miter's scoped Continuity of Mind

Headlong's fork–test–merge
+ Miter's candidate/trial/consequence/adjudication law

Headlong's pure channel bridges
+ Miter's typed identity, memory-scope, VoiceRNA, and effect certificates

Headlong's persistent loop operations
+ Miter's event-driven readiness, endogenous interests, and right to quiescence
```

That combination earns a place in the PoC and is already reflected in `POC_SPEC.md` and `ACCEPTANCE.md`.
