# Qwen bounded-completion budget correction

The first successfully retained Qwen provider envelope returned HTTP 200 but `finish_reason: length`, empty `message.content`, and 256 reasoning tokens—the entire original completion allowance. The independent parser returned `malformed-model-response`, and no typed product or semantic-result atom was created.

The shared request's `max_tokens` was increased from 256 to 1024. This does not relax the JSON schema, required fields, exact request ID, typed validator, or negative control. It gives both models the same still-bounded allowance to finish hidden reasoning and emit the constrained object.
