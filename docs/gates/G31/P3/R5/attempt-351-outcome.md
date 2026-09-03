# G31 P3 R5 attempt 351 — exact model repair captured; offline prior-contract assertion was wrong

R5 passed the complete storage-root preflight. It retained the closed G29 contract, admitted only the exact G31-P3 path/schema profile, verified every manifest pin and required dependency, and rejected the negative profile cases without reading credentials or using the network.

The one explicitly approved OpenRouter call then completed successfully in 23,484 ms. `z-ai/glm-5.3` returned the full bridge source with exactly the required `pending_post_id:IK` addition and no other byte change. The candidate hash is `cf771e7bdfa571f695a3949177cb33ed6fb04431999e88401163b21a328efca3`; it compiled cleanly and remains quarantined.

The subsequent offline canonical mock produced no result. Direct inspection found an error in the mock's representation of the unchanged ingest contract: it expected an exact repeated event to be suppressed as `duplicate`, while the candidate intentionally evaluates `TS =< Cursor` first and returns `stale_cursor`. This occurred after the successful model call but before candidate standing.

The model slot is now spent. There will be no retry. No Mattermost request, Mattermost credential lookup, message read/write, activation, or promotion occurred. R6 will resume only from the already captured observation and exact candidate bytes, correct the deterministic mock expectation, and complete causal tests.
