; G33 R13 versioned compact-proof integration. V1 semantic operators remain
; available, but only the v2 boundary is registered with the recurring driver.
!(import! &self "/Users/claritymiter/miter/src/bootstrap_development_reactor_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/nal_revision_v1.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_development_helix_v1.pl"
 (dh_input dh_outcome dh_save dh_trial_material dh_efficacy_fixture dh_existing_candidate dh_module_hash dh_n_restore nn_number))
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_development_proof_v1.pl"
 (dh2_hash_native dh2_root_probe dh2_input dh2_development_commit dh2_restore dh2_n_commit))
!(import! &self "/Users/claritymiter/miter/src/voice_trials_v2.metta")
!(import! &self "/Users/claritymiter/miter/src/nace_v2.metta")
!(import! &self "/Users/claritymiter/miter/src/nace_selection_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/development_helix_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/development_helix_v2.metta")
!(add-atom &rna_hooks (idle-promoter DevelopmentHelixIdleV2))
!(add-atom &rna_hooks (rna-advancer DevelopmentHelixRNA DevelopmentHelixBoundaryV2))
