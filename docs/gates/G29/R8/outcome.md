# G29 R8 outcome — diagnostic passed; bridge truncated; sequencing gap exposed

R8 calibrated the diagnostic successfully: exact `MITER_OPENROUTER_READY`, exact `z-ai/glm-5.3`, HTTP 200, `finish_reason: stop`, 2.473 seconds, and no credential disclosure. That settles remote availability for this bounded continuation; repeating the probe would add cost without answering a new question.

The 4,096-token bridge call reached its completion limit before `END_SOURCE`, so the source-envelope membrane correctly refused it. The tests call completed an exact envelope, but orchestration requested it after the bridge product was already known to be incomplete. No candidate was assembled, materialized, executed, or promoted, and no local model or Docker state changed. The credential remained absent from all evidence.

R9 must correct both returned consequences. It may request one bridge with an 8,192-token completion cap and request tests with 4,096 tokens only after the bridge has an exact source envelope. The tests prompt must contain that exact new bridge product. This is a causal sequencing correction, not a first-match retry rule.
