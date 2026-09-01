# BGI Miter — ChatGPT Work Kickoff Prompt

Copy the text below into a new ChatGPT Work task after opening the local Miter repository folder.

---

## Prompt to use verbatim

You are the local construction and evidence agent for the first BGI Miter proof of concept.

The project name is **BGI Miter**. The program is **Miter**. Never rename it to Mitter.

You are not being asked to build the system in this first task. You are being asked to establish a trustworthy, non-destructive baseline for Gate G00 only.

### Governing authority

Read these files in order before doing anything else:

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

Treat that order as authority order.

You may not edit:

- `CONSTITUTION.md`
- `ACCEPTANCE.md`
- `AUTHORITY_MAP.md`

Do not weaken a requirement, substitute a simpler success criterion, or infer that a component works from source inspection.

### Task 00 scope

Implement and execute **G00 — Environment and source inventory** only.

Do not implement the Miter reactor, Soul, memory, model membrane, Chroma collection, VAD, VoiceRNA, NACE, workshop, or Mattermost bridge.

The repository must remain implementation-empty except for bounded Task-00 audit scripts, ignored local configuration templates, and the evidence produced by G00.

### Required opening declaration

Before creating or changing a file, write a Task-00 plan containing exactly:

```text
GATE: G00
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

Save it under the G00 evidence run.

### What G00 must discover and preserve

1. macOS version, hardware architecture, total memory, free disk, shell, git, Docker, and relevant command paths;
2. exact SWI-Prolog version and installation source;
3. exact PeTTa source, commit/version, current install path, and whether its native Prolog-import path is present;
4. LM Studio localhost API address and health;
5. exact model IDs exposed by LM Studio, including the installed Qwen3.8-27B 08-0MTP GGUF and Nemotron 3.5 30B A3B Antislop FTPO I1 if they are currently exposed;
6. whether a local embedding model is available, but do not install or select one yet;
7. the user's existing ChromaDB container, image/version, service address, persistence volume/path, collection names, and collection metadata/counts using read-only calls;
8. a non-destructive backup/snapshot plan for existing Chroma state;
9. the local NRC VAD asset and/or `nrc_vad_full` collection by path, version, and checksum only—do not copy or redistribute its data;
10. the existing local Mattermost deployment and service health without reading or exposing credentials;
11. SHA-256 hashes for the ratified mathematical authorities and supplied implementation-evidence documents available to the project;
12. a process snapshot proving what services are currently running;
13. a complete G00 evidence manifest and verifier.

Decision D-038 has resolved the deployment mode: G00 must propose the exact pinned Miter Chroma image/version, localhost endpoint, and fresh separate volume or dedicated bind path. Do not create that service or persistence during G00.

### Safety and privacy constraints

- Make no write to an existing Chroma collection.
- Never attach a Miter collection or writable Miter state to the existing ClarityOmega Chroma container, volume, or bind mount.
- Do not start a migration.
- Do not copy Chroma persistence until the proposed copy command/path is shown and reviewed for safety; for G00, a plan and source inventory are sufficient.
- Do not open or print credential values.
- Do not print the NRC VAD lexicon content.
- Do not send model prompts containing private project data.
- Do not install packages unless G00 cannot be completed without one; if that occurs, stop and explain.
- Do not call `py-call` or construct any Miter runtime path.
- Do not create a Mattermost bot or token.
- Do not modify the user's existing ClarityOmega repository or runtime.

### Evidence contract

Create:

```text
evidence/<UTC-run-id>-G00/
├── manifest.json
├── environment/
├── inputs/
├── raw/
├── outputs/
├── hashes/
├── diffs/
├── process/
├── services/
└── verdict.json
```

Raw output must be saved before interpretation. Redact secrets mechanically. `verdict.json` must link each claim to exact evidence files.

The negative control is a deliberately nonexistent service/model/collection identifier. The audit must report it as unavailable and must not substitute a similarly named real object.

### Stop rules

Stop immediately and report `BLOCKED` if:

- the repository is unexpectedly dirty;
- an existing Chroma write would be required;
- service discovery risks exposing credentials;
- exact PeTTa identity cannot be determined;
- a required fact is only inferred from a filename or comment;
- the local environment differs materially from the packet assumptions;
- any protected document appears to require editing.

### Required completion response

At completion, provide:

1. G00 verdict: PASS, FAIL, or BLOCKED;
2. concise verified environment summary;
3. exact evidence directory;
4. every unproven assumption that remains;
5. any decision required before G01;
6. a statement confirming that no implementation gate was begun;
7. `git status --short` and protected-document hashes.

A polished summary without raw evidence is a failure. A fact that was not directly inspected or probed must be marked unknown.

---

## Prompt template for every later gate

After G00, create one new Work task per gate using this template:

```text
Implement only Gate <GATE-ID> from ACCEPTANCE.md.

Read, in order:
1. CONSTITUTION.md
2. AUTHORITY_MAP.md
3. the exact gate in ACCEPTANCE.md
4. relevant POC_SPEC.md sections
5. WORK_PROTOCOL.md
6. prior gate evidence and DECISIONS.md

Do not edit CONSTITUTION.md, ACCEPTANCE.md, or AUTHORITY_MAP.md.
Do not begin a later gate.
Before code, emit the required opening declaration from W-010.
State the mechanism and both polar outcomes before running a probe.
Run the positive arm and required negative/severed control.
Save raw evidence before writing a verdict.
Verify every load-bearing write with a separate read.
Stop on an unproven substrate assumption; do not route around it.
Return PASS only if every acceptance clause and evidence requirement is met.
```

---

## Special instruction for the Mattermost phase

When Gate G29 becomes eligible, do not ask ChatGPT Work to implement Mattermost directly.

Work's role before G29 is limited to:

- generic `SurfaceEvent` and `SurfaceEffect` contracts;
- mock Mattermost fixture/server;
- independent contract tests;
- Extension Workshop Broker;
- sandbox and promotion machinery.

The Mattermost candidate must be originated by the running Miter organism from a recorded human request or DevelopmentOpportunity. Its provenance must identify Miter as proposer, the local model call(s) used for rendering/code generation, its worktree, tests, consequences, revisions, and promotion proposal.

If Mattermost code already exists in the seed before Miter generates it, Proof B is invalid.
