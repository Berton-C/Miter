; G31 P0 imports read-only Docker metadata discovery only.
!(import! &self (library lib_import))
!(import! &self "/Users/claritymiter/miter/src/participation.metta")
!(import! &self "/Users/claritymiter/miter/src/participation_support.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_mattermost_live_preflight_v1.pl" (g31_docker_inventory))
!(import! &self "/Users/claritymiter/miter/src/mattermost_live_grant_v1.metta")
