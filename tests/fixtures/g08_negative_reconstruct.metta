!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_continuity.pl" (miter_continuity_reconstruct))

!(miter_continuity_reconstruct "./runtime/g08/continuity-negative" "project-g08-glass-archive" "./runtime/g08/reconstruction-negative.json")
