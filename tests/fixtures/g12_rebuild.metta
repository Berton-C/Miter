!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_memory.pl" (miter_memory_record_count miter_memory_record_id miter_memory_supersession_count miter_memory_index))
!(import! &self "/Users/claritymiter/miter/src/memory.metta")
!(RebuildSemanticIndexRNA "runtime/g10/store")
