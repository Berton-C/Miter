# LM Studio structured-output contract used by G04

G04 uses LM Studio's documented OpenAI-compatible `POST /v1/chat/completions` path with `response_format.type = json_schema`, a supplied JSON schema, bounded `max_tokens`, and `stream = false`.

Official documentation consulted on 2026-09-01:

- https://lmstudio.ai/docs/developer/openai-compat/structured-output
- https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict

The provider returns the constrained JSON object as a string in `choices[0].message.content`. Miter therefore retains the complete provider envelope as raw evidence and independently parses and validates that content through SWI-Prolog before MeTTa may admit a semantic-result atom.

The final fixture uses two loopback ports because the exact Nemotron GGUF
requires operation offload to be disabled on this Apple host, a switch the LM
Studio model manager does not currently expose. Qwen uses LM Studio's normal
port 1234. Nemotron uses LM Studio's own 2.32.0 runtime on port 1235 with CPU
execution flags. Both receive byte-equivalent request bodies except for the
required model ID; their schema and semantic request are identical.
