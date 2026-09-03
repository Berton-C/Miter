; One fixed interpreter load per worker. Modules are inert data, not imports.
!(import! &self "/Users/claritymiter/miter/src/bootstrap_voice_construction.metta")
!(import! &self "/Users/claritymiter/miter/src/nal_revision_v1.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_nace_v2.pl"
 (nn_number nn_input nn_save nn_commit nn_restore nn_snapshot))
!(import! &self "/Users/claritymiter/miter/src/nace_v2.metta")
