# G08 completion report

Status: **PASS**

## Exact book continuity

Project `project-g08-glass-archive` now has two immutable, content-hashed
capsules:

- `capsule-g08-001`, stored status `active`, content hash
  `ff5bb022c87ef3d7bfed253c425e56c9e0481c1d487a0c24b0e1f9471ea1e2d3`
- `capsule-g08-002`, stored status `current`, content hash
  `01cc5fd17e657d12b848e7f11141773b7cc50921c69ba2544923909359e0865d`

Capsule 002 explicitly names capsule 001 as both its previous checkpoint and
the checkpoint it supersedes. This expresses correction additively: capsule
001 remains byte-identical and directly retrievable, while reconstruction gives
it effective standing `superseded` from capsule 002's relation.

An explicit, atomically replaced `current.json` selects capsule 002. A fresh
PeTTa process reconstructed, without model inference or vector search:

- artifact: `tests/fixtures/g08_manuscript.md`
- artifact SHA-256: `5a8433e2d94034aa79c3098353acd1d5e55db6e54d8e9edab969261a4d4e34a3`
- exact location: `Chapter 3 / The Observatory / paragraph 4 decision beat`
- unresolved question: `Should Mara reveal the archive key to Jonas before the storm breaks?`
- next movement: `Draft Mara's decision beat, then test the reveal against chapter-one foreshadowing.`

## Negative control

A separate store copy retained byte-identical copies of both capsules but had
only its `current.json` removed. Reconstruction returned `ambiguous`, listed
`capsule-g08-001` and `capsule-g08-002`, selected neither, and recorded
`timestamp_fallback: false`. It did not silently choose the newer timestamp or
the capsule whose stored status says `current`.

## Integrity boundary

Capsules and the current index are owner-read/write, locked per project, fsynced
before atomic rename, and validated against their own content hashes. The
manuscript's byte-level hash is checked during admission and reconstruction.
Protected documents and the G07 trajectory stayed byte-identical. No Chroma
service was contacted, and no `~/.miter` path was created or modified.

G08 completes the requested sequence. G09 is the next bounded gate, but it has
not been started in this work order.
