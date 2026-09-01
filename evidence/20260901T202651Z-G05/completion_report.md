# G05 completion report

## Verdict

**PASS.** The fixed six-case corpus ran three times per case against each local
chat profile: 36 total calls. Both profiles returned 18/18 mechanically valid
typed products with exact request-ID round trips. Qwen passed every mechanical
content criterion; Nemotron passed every schema arm and averaged 4.1667 of 5
content points.

The tracked initial role map selects `qwen-local` as the default. Qwen is the
primary profile for voice rendering, semantic reading, declarative MeTTa-module
generation, and extension implementation. Voice repair and independent review
showed no material quality difference. Nemotron remains the named alternate,
but NACE comparison remains blocked until two profiles pass every minimum
content criterion.

## Fixed corpus and bounded generation

The corpus covers:

1. VoiceRNA rendering from a declared communicative intention;
2. repair from named structured defects;
3. strict-schema semantic reading;
4. inert declarative MeTTa-module generation;
5. inert extension code plus test generation;
6. uncertainty honesty on insufficient evidence.

Every call used temperature 0, top-p 1, seed 505, maximum 1,024 completion
tokens, `reasoning_effort: none`, the same five-field strict JSON schema, and a
five-minute idle TTL. Raw provider envelopes, parsed typed products, timings,
and provider snapshots are separate artifacts. Candidate MeTTa and TypeScript
text was never evaluated or executed.

## Measured results

| Profile | Schema | Mean quality | Mean duration | Provider mode | Resource observation |
| --- | ---: | ---: | ---: | --- | --- |
| `qwen-local` | 18/18 | 5.0000 / 5 | 11,740 ms | LM Studio GPU JIT | 29,047,084,256-byte primary GGUF; unified GPU resident bytes unavailable |
| `nemotron-local` | 18/18 | 4.1667 / 5 | 5,494 ms | LM Studio runtime, CPU-safe | 27,040,755,744-byte GGUF; sampled RSS 32,587,874,304 bytes |

Resource and latency measurements are deliberately marked non-comparable
because the current LM Studio Metal path terminates this Nemotron GGUF at prompt
evaluation. They did not break any tied quality score. The faster observed
Nemotron durations therefore are not interpreted as a cross-provider model
advantage.

Nemotron's repeated deductions were mechanical rather than subjective: it did
not copy the exact required evidence span in four cases, and its MeTTa module
did not contain the exact compact module-header substring. It tied Qwen at full
quality for voice repair and uncertainty-honest independent review.

## Negative control

One quality score was reversed in a copied metrics file without updating the
canonical metrics digest. The role selector returned exit 2 and
`inconsistent_metrics`; it did not emit a plausible alternate role map from
tampered measurements.

## Provider probes retained

- The initial Qwen base-URL mistake was rejected before inference.
- A 512-token Qwen probe and the first 1,024-token auto-reasoning bakeoff are
  retained, including every truncation.
- LM Studio's JIT GPU Nemotron path reproduced the missing Metal expert-matrix
  kernel and returned `{"error":"terminated"}`.
- Nemotron's CPU-safe auto-reasoning probe consumed the artifact budget before
  emitting content.

These probes led to the explicit, identical `reasoning_effort: none` final
parameter. Content expectations, schema, seed, and scorer were not relaxed.

## Integrity and scope

- The protected canon and construction documents are byte-identical.
- The ignored local profile binding is byte-identical to the G04 baseline.
- No Python, Janus, or `py-call` appears in the sampled Miter request path.
- No model weights, credentials, Chroma data, or `~/.miter` state were created
  or added to Git.
- Qwen was unloaded and the temporary Nemotron service was stopped after the
  final arm.
- G06 was not started before this gate passed.

## Rollback

Revert the G05 commit. The local LM Studio model files and profile binding need
no rollback because they were not modified.

## Next eligible gate

G06 — embedding profile discovery.
