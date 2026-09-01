# G06 completion report

Status: **PASS**

## Pinned embedding identity

- Profile: `embedding-local`
- Exact model ID: `text-embedding-nomic-embed-text-v1.5`
- Provider metadata: Nomic AI, `nomic-bert`, GGUF `Q4_K_M`, maximum context 2048
- Vector dimension: 768
- Normalization: provider L2-unit, validated within tolerance `0.00001`
- Observed L2 norm: `1.000000024807349`
- Chunking: `miter-chunk-v1` (`utf8-codepoint-sliding-window`)
- Distance metric: cosine
- Collection schema identity: `miter-ltm-v1`

## Determinism proof

The fixed text `Miter continuity embedding fixture v1.` was sent twice through
the loopback-only typed Prolog membrane. Both raw provider responses were
byte-identical and both validated vectors produced SHA-256
`1913b90fbd51aa4e3a93751b185aabded00850002c6990eeb955d38e39a60e13`.

## Negative control

The first valid response was checked against a negative-only profile declaring
dimension 767. Validation returned `embedding-dimension-mismatch`. The gate
made zero Chroma requests, and the implementation contains no collection
mutation predicate, so rejection necessarily occurred before insertion.

## Boundary and integrity

MeTTa selects the embedding operation; `effect_membranes/miter_chroma.pl`
performs only loopback HTTP, strict profile/vector validation, checksumming, and
atomic evidence writes. No Python process or provider-output evaluation surface
is present. Protected documents and the ignored machine-local profile remained
byte-identical. No production memory collection was created.

G07 may proceed to the append-only canonical trajectory ledger.
