!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_store.pl" (miter_store_verify_ledger))

!(miter_store_verify_ledger "./runtime/g07/store-negative" "./runtime/g07/report-negative.json")
