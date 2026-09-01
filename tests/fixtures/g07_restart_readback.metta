!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_store.pl" (miter_store_verify_ledger miter_store_readback))

!(miter_store_verify_ledger "./runtime/g07/store" "./runtime/g07/report-final.json")
!(miter_store_readback "./runtime/g07/store" "./runtime/g07/readback-final.json")
