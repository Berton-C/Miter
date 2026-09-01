!(import! &self (library lib_import))
!(import_prolog_functions_from_file "./effect_membranes/miter_continuity.pl" (miter_continuity_reconstruct miter_continuity_get_capsule))

!(miter_continuity_reconstruct "./runtime/g08/continuity" "project-g08-glass-archive" "./runtime/g08/reconstruction.json")
!(miter_continuity_get_capsule "./runtime/g08/continuity" "project-g08-glass-archive" "capsule-g08-001" "./runtime/g08/prior-access.json")
