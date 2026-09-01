!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_store.pl" (miter_store_verify_ledger miter_store_readback miter_store_append_event))

!(miter_store_verify_ledger "./runtime/g07/store" "./runtime/g07/report-before-fork.json")
!(miter_store_readback "./runtime/g07/store" "./runtime/g07/readback-before-fork.json")
!(miter_store_append_event "./runtime/g07/store" "./runtime/g07/libmiter_store_posix.dylib" "./tests/fixtures/g07_fork.json")
