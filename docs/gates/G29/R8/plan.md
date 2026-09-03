# G29 R8 — calibrated OpenRouter completion envelope

## Bounded claim

G29 R8 tests whether the exact OpenRouter GLM 5.3 renderer can return the diagnostic and two small source products when the completion envelope reflects its always-on reasoning behavior. It retains R7's central model registry, credential isolation, native resource comparison, exact sentinel, quarantine, and independent qualification.

## Frozen experiment

1. Reopen from the R7 `finish_reason: length` consequence, including its exact partial content, usage, latency, provider, privacy, credential-absence, and artifact-guard evidence.
2. Use fresh R8 claims and request IDs. R7 claims remain immutable and cannot be replayed.
3. Keep exact endpoint `https://openrouter.ai/api/v1/chat/completions`, model `z-ai/glm-5.3`, high reasoning, `zdr:true`, `data_collection:"deny"`, and `require_parameters:true` from the human-editable central registry. Another model must never answer.
4. Increase only the diagnostic completion cap from 64 to 256 tokens. Require exact decoded content `MITER_OPENROUTER_READY`; any embellishment, truncation, transport error, malformed response, or model mismatch stops both artifact branches.
5. After exact diagnostic success only, permit two source calls capped at 4,096 completion tokens, 300 seconds, and 2 MiB. The increased bound accommodates reasoning plus under-180-line source; it does not expand artifact scope.
6. Admit only exact `BEGIN_SOURCE`/`END_SOURCE` envelopes, assemble `mattermost-r8` in quarantine, and apply the unchanged syntax, PLUnit, forbidden-core, credential, provenance, authorization-first, identity, idempotency, cursor, panic, and causal controls.
7. Verify no local model load, no Docker service change, no credential material, no Mattermost network, exactly three R8 claims on success, and no promotion.
8. Close G29 and freeze G30 only if runtime, native causal, privacy, and independent process evidence all agree. Otherwise preserve the differentiated consequence and stop.
