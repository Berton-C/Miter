# G03 completion report

## Verdict

**PASS.** Pinned native PeTTa called Miter's SWI-Prolog HTTP/JSON membrane, discovered LM Studio's current catalog, wrote machine-local profile mappings only to ignored configuration, and resolved both required chat aliases to exact live IDs.

## Proven discovery

- `qwen-local` resolved to `qwen/qwen3.8-27b`.
- `nemotron-local` resolved to `nemotron-3.5-30b-a3b-antislop-ftpo-i1`.
- The optional `embedding-local` profile also resolved to `text-embedding-nomic-embed-text-v1.5`.
- The checked-in membrane contains no exact model ID or LM Studio display name. It accepts generic alias and selector scalars and fails if live discovery yields zero or multiple IDs.
- The alias mapping is in ignored `config/local/g03-model-profiles.json`, mode `0600`, SHA-256 `aa9832b6eaa4130955297576645bbd36086fd6abb380c539f03a9702bb330c6e`. The file is not part of the commit.

## Controls and boundary

- `missing-local` returned exactly `unknown-model-profile` in PeTTa and in a separate deterministic Prolog read.
- A supplemental unavailable-endpoint probe returned exactly `lm-studio-unavailable` and created no configuration.
- The monitored Miter process tree was shell to native `swipl`; no Python, Janus, or `py-call` seam was present.
- The committed service response is mechanically reduced to `id`, `type`, and `state`. The full private response was not copied into Git; its SHA-256 is retained separately.
- Repeating the fixture produced byte-identical PeTTa output and the same local configuration hash.

## Scope

This gate proves service discovery and exact local addressing only. It does not prove schema-constrained inference, assign model roles, or validate embeddings. G04 was not begun.
