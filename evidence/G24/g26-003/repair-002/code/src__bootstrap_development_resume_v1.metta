; Load shared cognitive definitions exactly once per fresh worker.
!(import! &self "/Users/claritymiter/miter/src/bootstrap_nace_selection_v1.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_voice_trials_v2.pl" (tv_restore))
!(import! &self "/Users/claritymiter/miter/src/voice_trials_v2.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_development_resume_v1.pl" (dr_input dr_record dr_snapshot))
!(import! &self "/Users/claritymiter/miter/src/development_resume_v1.metta")
