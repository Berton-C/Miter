!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_integrity.pl" (miter_integrity_snapshot miter_integrity_verify))
!(miter_integrity_snapshot 42)
!(miter_integrity_verify "runtime/g13/nonexistent-pin.json" "runtime/g13/missing-pin-report.json")
