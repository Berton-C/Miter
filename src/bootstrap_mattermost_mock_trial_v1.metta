; Fixed G30 bootstrap.  Only the deterministic mock grounding is imported.
!(import! &self (library lib_import))
!(import! &self "/Users/claritymiter/miter/src/participation.metta")
!(import! &self "/Users/claritymiter/miter/src/participation_support.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_mattermost_mock_v1.pl" (g30_mock_trial))
!(import! &self "/Users/claritymiter/miter/src/mattermost_mock_trial_v1.metta")
