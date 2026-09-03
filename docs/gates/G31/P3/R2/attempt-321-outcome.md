# G31 P3 R2 attempt 321 — preflight passed; transitive grounding was not callable

R2 passed its zero-effect preflight: the native request was source-grounded, compact, and carried the exact normalized 8192-token/300-second envelope. During execution, however, `or_source/3` remained an unevaluated MeTTa expression. The bootstrap named the P3 membrane as the import source, while `or_source/3` is defined only in the OpenRouter file loaded transitively by that membrane; PeTTa did not expose the transitive predicate as a grounding.

The native process still exited cleanly and the builder correctly refused to treat the unevaluated expression as a model observation. No call claim, provider request, credential lookup, candidate, Mattermost contact, message effect, activation, or promotion occurred. The original model-call slot remains unspent.

R3 will define and import one explicit P3-qualified wrapper directly in the approved membrane. Its offline standing must prove the underlying predicate, exact request grant, and one unspent slot are present without invoking transport.
