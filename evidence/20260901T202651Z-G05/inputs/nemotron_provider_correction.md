# Nemotron provider correction

The initial G05 Nemotron arm used LM Studio's normal JIT GPU load. The exact
model loaded with all GPU layers, but every prompt terminated during evaluation
because the current Metal runtime could not find
`kernel_mul_mm_id_map0_ne20_18_ne02=128`. The provider returned HTTP 400 with
`{"error":"terminated"}`. The complete arm and bounded server-log excerpt are
preserved as a failed provider probe.

G04 already proved that the unchanged GGUF and the same LM Studio-supplied
2.32.0 `llama-server` complete successfully when GPU layers, operation offload,
and KV offload are disabled. The final Nemotron bakeoff arm therefore uses that
CPU-safe localhost service. Corpus content, schema, decoding parameters,
repetitions, scoring, and model ID remain unchanged.

Because Qwen and Nemotron use different provider modes in the final run,
latency and memory observations are reported but may not break a tied quality
score. Quality remains directly comparable; resource measurements are marked
non-comparable rather than silently treated as model merit.
