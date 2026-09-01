; MeTTa owns the decision to embed; Prolog owns only typed transport,
; validation, hashing, and atomic artifact mechanics.
!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_chroma.pl" (miter_chroma_embed_text miter_chroma_validate_embedding_response))

!(miter_chroma_embed_text "./config/embedding-profile.json" "./config/local/g03-model-profiles.json" "Miter continuity embedding fixture v1." "./runtime/g06/vector.json" "./runtime/g06/vector-metadata.json")
!(miter_chroma_validate_embedding_response "./tests/fixtures/g06_wrong_dimension_profile.json" "./runtime/g06/vector.json")
