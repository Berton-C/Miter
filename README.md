# Miter

Miter is a continuously cycling PeTTa/MeTTa cognitive architecture whose
read-only constitutional genome, nine interconnected flourishings, nine
Immutable Facts, ratified M24–M26.3 mathematics, and accumulated consequence
participate in forming movement. Native Prolog provides the non-cognitive
effect membrane that carries, persists, hashes, waits, supervises, and commits
bytes. A minimal C grounding exposes only the POSIX `fsync()` primitive needed
for durable storage. Neither decides what contact means or which movement
Miter takes.

This branch is the lean clean-room recovery baseline. It contains the one
supported runtime and its controlling authorities. It deliberately excludes
the former repository's gate evidence, test archives, logs, campaign papers,
duplicate checkpoints, generated reports, and `initial_canon/` provenance.
Those materials remain outside this repository.

## Current standing

The recovered runtime presently provides one recurring PeTTa/MeTTa cycle,
constitutional integrity admission, typed contact/consequence carriers, the
complete causal M24–M26.3 projection, provisional partial-alignment inquiry,
explicitly granted GLM 5.3 thought-partner participation, append-only
trajectory storage, stable scope boundaries, writable per-scope Continuity of
Mind capsules, exact checkpoint/capsule restoration, local effect preparation,
and start/status/stop/panic operations.

It is **not yet the usable Miter alpha**. General conversational response,
live Chroma retrieval, general LLM/VoiceRNA composition, Mattermost delivery,
earned self-extension, hot upgrade, and rollback remain to be integrated into
this same runtime. [MITER_BUILD_ATLAS.md](MITER_BUILD_ATLAS.md) is the single
operations map for that additive work.

The current C4 cut can resolve the configured local Mattermost group and its
authorized principals, admit new versioned contacts into the one reactor, and
restore them after restart. It deliberately cannot emit a Mattermost response
yet; outbound remains disabled until general VoiceRNA and delivery
reconciliation are causally joined.

Every native checkpoint now writes immutable, content-addressed continuity
capsules for each exact principal/audience/project scope. A capsule carries the
active relationship, undertaking, attention, next-movement, developmental,
and raw-source-reference organization already formed by MeTTa. One atomic
checkpoint pointer binds the complete snapshot to its capsule manifest;
restart rejects altered or mismatched continuity. Capsules have no age expiry
and remain until explicit authorized erasure, repair, or migration. Chroma is
only a rebuildable semantic index and can never substitute for these records.

## Runtime boundary

There is one cognitive runtime and one clock:

```text
contact / consequence
        |
non-cognitive Prolog carrier and persistence membranes
        |
one recurring PeTTa/MeTTa reactor
        |
Fact9 + flourishings + M24–M26.3 + memory + consequence
        |
native movement / VoiceRNA certificate
        |
capability-limited Prolog effect membrane
```

Prolog supervision does not create a second cognitive cycle. Python,
JavaScript, and Java are not part of the core or core-service seam.
The pinned PeTTa/SWI runtime extension may schedule independent
MeTTa-defined possibility reductions concurrently. It preserves their order
and has no authority to inspect, filter, rank, join, or select their results.

## Requirements

- macOS on Apple Silicon for the current native store extension
- SWI-Prolog with `swipl` and `swipl-ld` on `PATH`
- PeTTa commit `ae66fa8e41dcd5539d614706bd4e5cfb34f9608d`

Point Miter at that pinned PeTTa checkout without copying it into this repo:

```sh
export MITER_PETTA_MAIN=/absolute/path/to/PeTTa/src/main.pl
```

## Operate the recovered baseline

Use an explicit runtime directory outside this repository. Do not use
`~/.miter`.

```sh
bin/miter bootstrap --runtime-root /absolute/private/runtime/path
bin/miter start     --runtime-root /absolute/private/runtime/path
bin/miter status    --runtime-root /absolute/private/runtime/path
bin/miter stop      --runtime-root /absolute/private/runtime/path
bin/miter panic     --runtime-root /absolute/private/runtime/path
```

`config/miter.json` is the human-readable mechanical runtime configuration.
`config/models.json` is the human-editable model registry; it contains only
resource and Keychain references. Every remote call additionally requires an
exact, time-bounded runtime-local grant derived from `config/model-grants.json`,
which is inactive by default. `config/continuity.json` contains only legacy
read-only import bindings and is intentionally unbound; native writable
continuity is intrinsic to every checkpoint. These files store references and
scope bindings, never secrets. Runtime bytes, memories, credentials, model
files, Chroma data, logs, and evidence stay outside Git.

## Source map

- `CONSTITUTION.md` and `MITER_SOUL_CONSTITUTIVE_SPEC.md`: controlling identity
  and Soul specification.
- `authority/`: the five ratified mathematical authorities.
- `constitution/`: immutable native projections and their integrity manifest.
- `src/`: PeTTa/MeTTa cognition and the single recurring runtime.
- `effect_membranes/`: non-cognitive Prolog/C mechanics.
- `config/`: public-safe human-editable configuration.
- `bin/miter`: the only supported operator entry.

## License

See [LICENSE](LICENSE).
