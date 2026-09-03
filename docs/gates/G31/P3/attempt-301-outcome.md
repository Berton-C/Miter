# G31 P3 attempt 301 — native question valid, builder serialization failed

The native layer constructed the intended source-grounded OpenRouter question and exited successfully with empty stderr. The builder then split stdout at physical newlines before parsing. Because the question legitimately carried the complete prior Prolog source as a multiline string, the parser treated fragments of that one term as separate values and failed with `Unterminated string in JSON`.

This is a builder evidence-transport defect, not a candidate, model, Mattermost, or Soul judgment. No model request, call claim, candidate, credential lookup, local Mattermost request, message effect, activation, or promotion occurred. The single authorized model-call slot remains unspent.

R1 will keep the full request and response in durable JSON artifacts, while native stdout exposes only compact, parse-safe readiness and observation summaries. That changes no source meaning, prompt, model envelope, candidate acceptance condition, or live authority.
