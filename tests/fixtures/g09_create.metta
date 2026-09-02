!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_chroma_service.pl" (miter_chroma_service_request))
!(miter_chroma_service_request "config/chroma-service.json" "config/embedding-profile.json" "tests/fixtures/g09_create.json" "runtime/g09/create.json")
