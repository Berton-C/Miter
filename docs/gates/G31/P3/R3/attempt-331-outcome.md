# G31 P3 R3 attempt 331 — the qualified wrapper was not registered

R3 added the qualified Prolog wrapper and an effect-free readiness predicate, but the fresh preflight exposed an earlier bootstrap omission: `bootstrap_mattermost_candidate_revision_v1.metta` invoked `import_prolog_functions_from_file` without first importing PeTTa's `(library lib_import)`. PeTTa therefore retained `(g31_p3_renderer_ready)` as an unevaluated expression instead of calling the predicate.

The source-grounded native revision question still reached its expected standing, which isolates the failure to the Prolog-grounding registration boundary. Inspection of the pinned PeTTa source confirms that `import_prolog_functions_from_file` is defined in `lib/lib_import.metta`; working Miter bootstraps, including G30, import that library explicitly before using it.

The builder rejected the unevaluated expression. No call claim, provider request, credential lookup, candidate, Mattermost contact, message effect, activation, or promotion occurred. The single model-call slot remains unspent.

R4 will add the missing explicit library import before the existing qualified grounding import, prove the readiness predicate reduces to `true` without effects, and then run the unchanged original one-call P3 experiment.
