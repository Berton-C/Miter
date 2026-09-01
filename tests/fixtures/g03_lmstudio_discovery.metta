!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_llm.pl" (miter_lm_bind_profile miter_lm_resolve_profile))

!(miter_lm_bind_profile "http://127.0.0.1:1234/api/v0/models" "./config/local/g03-model-profiles.json" "qwen-local" "qwen" "27b")
!(miter_lm_bind_profile "http://127.0.0.1:1234/api/v0/models" "./config/local/g03-model-profiles.json" "nemotron-local" "nemotron" "30b")
!(miter_lm_bind_profile "http://127.0.0.1:1234/api/v0/models" "./config/local/g03-model-profiles.json" "embedding-local" "embedding" "nomic")

!(miter_lm_resolve_profile "./config/local/g03-model-profiles.json" "qwen-local")
!(miter_lm_resolve_profile "./config/local/g03-model-profiles.json" "nemotron-local")
!(miter_lm_resolve_profile "./config/local/g03-model-profiles.json" "embedding-local")
!(miter_lm_resolve_profile "./config/local/g03-model-profiles.json" "missing-local")
