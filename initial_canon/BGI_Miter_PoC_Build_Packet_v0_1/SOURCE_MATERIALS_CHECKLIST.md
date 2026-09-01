# BGI Miter PoC — Source Materials Checklist

**Version:** 0.1 Draft  
**Date:** 2026-09-01  
**Purpose:** Tell the human and ChatGPT Work exactly which source materials must be locally available before Task 00, which are private runtime assets, and which are references only.

---

## 0. Source placement

Recommended repository-local source layout:

```text
docs/sources/
├── authority/
├── architecture/
├── substrate/
├── nace/
├── vad/
├── quantale/
└── external-notes/
```

The source files are evidence and reference. They are not imported automatically into the Miter runtime.

Do not rename authority files until Task 00 has recorded their original names and hashes.

---

# I. Required ratified authorities

Place these exact files under `docs/sources/authority/`:

- [ ] `0k_24_Ratified_Mathematical_Authority.md`
- [ ] `25f_Ratified_Balance_as_Intelligence_Mathematical_Object.md`
- [ ] `25.5m_Ratified_Mathematical_Authority.md`
- [ ] `26.0_Ratified_Mathematical_Authority.md`
- [ ] `26.3_Ratified_Mathematical_Authority.md`

Task 00 records SHA-256 hashes and confirms that `AUTHORITY_MAP.md` points to the correct local files.

Later Inquiry-26 source or Lean artifacts may be added, but they do not silently change this PoC's authority. A human decision must update the map.

---

# II. Required architecture ancestry

Place under `docs/sources/architecture/`:

- [ ] `ORIG_ClarityClaw_Soul_Architecture_Strategy_Map_current.md`

This is historical implementation ancestry. Its old project names remain in the source for provenance and must not leak into Miter identity.

Optional but useful if locally available:

- [ ] current ClarityOmega README and research programme;
- [ ] current loop/wiring diagrams relevant to tested behaviors;
- [ ] current Capability Registry contracts;
- [ ] current SSI/corner-gate evidence used by later Miter work.

These are implementation evidence, not mathematical authority.

---

# III. Required PeTTa/MeTTa substrate evidence

Place under `docs/sources/substrate/`:

- [ ] `Atom_Operations_Map.md`

Optional companions if locally available:

- [ ] NAL/marshal boundary reference;
- [ ] superpose containment audits;
- [ ] typed-call silent-failure probes;
- [ ] persistence and absolute-path probes;
- [ ] clean raw logs for the proven writer ladder.

Task 00 must determine whether the selected Miter PeTTa version matches the environment in which these facts were proven. Facts are re-probed when version/runtime context differs.

---

# IV. Required NACE source material

Place under `docs/sources/nace/`:

- [ ] `ClarityOmega_NACE_Build_State_Honest_Assessment copy.md`
- [ ] `ClarityOmega_NACE_Caller_Contract.md`
- [ ] `ClarityOmega_NACE_Persistence_Architecture.md`
- [ ] `nace_implementation_plan.md`
- [ ] `nace_substrate.metta`
- [ ] `nace_beliefs.metta`
- [ ] `nace_pending.metta`

Optional:

- [ ] any clean NACE live-loop evidence and reference arithmetic;
- [ ] capability-registry harness results;
- [ ] NAL source at the pinned version.

The four-NACE sheaf is reference-only and excluded from the seed PoC.

---

# V. Required VAD source material

Place documents/code under `docs/sources/vad/`:

- [ ] `README.txt` from NRC VAD Lexicon v2.1
- [ ] `Paper-VAD-v2-2025.pdf`
- [ ] `000_vad_affect_perception_consolidated.md`
- [ ] `lib_vad.metta`
- [ ] `vad_routing_substrate.metta`
- [ ] `vote_threshold.metta`
- [ ] `vad_grounded_register.metta` — source evidence only; known corrupted and must not be loaded
- [ ] `vad_metta_grounded.py` — migration/reference evidence only; not core runtime
- [ ] `web_vitality_v8.metta` if relevant to the original programme

## Private local asset — do not copy into git

The full NRC VAD lexicon and its Chroma collection remain outside the repository:

```text
~/.miter/assets/nrc-vad/     # recommended local path
existing collection: nrc_vad_full
```

Task 00 records:

- version;
- local path;
- checksum;
- collection name/count/dimension if available;
- license/attribution file location.

It must not copy or redistribute the lexical data.

---

# VI. Required quantale/source-engine material

Place under `docs/sources/quantale/`:

- [ ] `lib_quantale.metta`
- [ ] `lib_quantale_autopoietic_epistemic_dynamics_engine_v08_7_2_SOUL_EVOLUTIONARY_CANONICAL_TOPOLOGY.metta`

These are discovery and implementation source material. They are not automatically imported into the PoC.

Task-specific extraction must identify:

- exact function/atom family;
- consumer;
- status;
- mathematical standing;
- severed-arm test;
- whether the source operation must be renamed or rebuilt.

---

# VII. External repositories to pin by commit

Task 00 records the current commit and license for:

- [ ] `trueagi-io/PeTTa`
- [ ] `patham9/iter`
- [ ] `laude-institute/headlong`

Optional source references:

- [ ] LM Studio developer/API documentation version/date;
- [ ] ChromaDB server/client documentation version/date;
- [ ] Mattermost API documentation matching the local server version.

Do not vendor entire repositories into Miter merely for reference. Record commit IDs and relevant source excerpts/paths.

---

# VIII. Private local runtime inventory

Task 00 locates but does not expose or copy:

## Local models

- [ ] Qwen3.8-27B 08-0MTP GGUF
- [ ] Nemotron 3.5 30B A3B Antislop FTPO I1
- [ ] candidate local embedding model, if already installed

Record exact LM Studio model IDs, not only display names.

## ChromaDB

- [ ] current service address/version;
- [ ] persistence directory;
- [ ] collection list/counts;
- [ ] backup/copy destination with sufficient disk space;
- [ ] write processes that must be stopped before backup.

## Mattermost

- [ ] local server URL and version;
- [ ] service health;
- [ ] dedicated future test channel/account availability;
- [ ] credential location/profile name only—never the value.

## Miter runtime root

Create only after G00 review:

```text
~/.miter/
```

with mode-restricted subdirectories specified in `POC_SPEC.md`.

---

# IX. Source status labels

Each source added to the repository receives a row in `docs/sources/MANIFEST.json`:

```json
{
  "path": "docs/sources/...",
  "sha256": "...",
  "source_status": "RATIFIED_AUTHORITY|IMPLEMENTATION_EVIDENCE|DESIGN_PRESSURE|REFERENCE|PRIVATE_ASSET_POINTER",
  "origin": "...",
  "date_obtained": "...",
  "license_or_terms": "...",
  "runtime_import": false,
  "notes": "..."
}
```

A file is not imported into runtime because it appears in this manifest.

---

# X. Pre-Task-00 human checklist

Before opening ChatGPT Work:

- [ ] create an empty `miter` git repository;
- [ ] copy all build-packet `.md` files to the repository root;
- [ ] create the `docs/sources/` directories;
- [ ] copy the five ratified authority files;
- [ ] copy the required architecture/substrate/NACE/VAD/quantale source files available locally;
- [ ] do not copy the full NRC lexicon into git;
- [ ] ensure LM Studio is running or record that G00 should start it only after confirmation;
- [ ] ensure existing ChromaDB writers can be identified;
- [ ] do not expose Mattermost credentials;
- [ ] commit the initial documentation/source state;
- [ ] verify `git status --short` is empty;
- [ ] open the local repository folder in ChatGPT Work;
- [ ] paste `GPT_WORK_KICKOFF_PROMPT.md` verbatim.

If a required authority is missing, Task 00 must be `BLOCKED`, not silently continued from summaries.
