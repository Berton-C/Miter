!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_store.pl" (miter_store_append_event))

!(miter_store_append_event "./runtime/g07/store" "./runtime/g07/libmiter_store_posix.dylib" "./tests/fixtures/g07_contact.json")
!(miter_store_append_event "./runtime/g07/store" "./runtime/g07/libmiter_store_posix.dylib" "./tests/fixtures/g07_internal_movement.json")
!(miter_store_append_event "./runtime/g07/store" "./runtime/g07/libmiter_store_posix.dylib" "./tests/fixtures/g07_witnessed_result.json")
