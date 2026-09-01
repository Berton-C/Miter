!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_continuity.pl" (miter_continuity_write_capsule miter_continuity_set_current))

!(miter_continuity_write_capsule "./runtime/g08/continuity" "./runtime/g07/libmiter_store_posix.dylib" "./tests/fixtures/g08_capsule_current.json")
!(miter_continuity_set_current "./runtime/g08/continuity" "./runtime/g07/libmiter_store_posix.dylib" "project-g08-glass-archive" "capsule-g08-002")
