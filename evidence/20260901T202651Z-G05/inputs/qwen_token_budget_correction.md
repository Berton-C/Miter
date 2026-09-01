# Qwen token-budget correction

The first valid-endpoint G05 request used `max_tokens: 512`. Qwen returned the
correct bounded answer text, but the provider reported 474 reasoning tokens and
terminated at exactly 512 completion tokens with `finish_reason: length` before
the strict JSON object was complete.

The incomplete run was stopped and preserved under
`raw/probes/qwen_512_token/`. The fixed content corpus, response schema,
sampling temperature, seed, scoring rules, and expected results were not
changed. The generation ceiling alone was increased to 1,024, matching the
already-proven G04 budget. Truncation remains a parse failure; the parser was
not relaxed.
