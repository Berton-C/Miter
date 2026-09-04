; G33 R12 versioned integration. Existing meanings are imported unchanged;
; only G33/R12 transport and persistence use the new membrane.
!(import! &self "/Users/claritymiter/miter/src/bootstrap_development_reactor_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/nal_revision_v1.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_development_helix_v1.pl"
 (dh_input dh_outcome dh_save dh_generation_audit dh_generate dh_candidate dh_trial_material dh_development_commit dh_restore
  dh_efficacy_fixture dh_existing_candidate dh_module_hash dh_n_restore dh_n_commit nn_number))
!(import! &self "/Users/claritymiter/miter/src/voice_trials_v2.metta")
!(import! &self "/Users/claritymiter/miter/src/nace_v2.metta")
!(import! &self "/Users/claritymiter/miter/src/nace_selection_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/development_helix_v1.metta")
!(add-atom &rna_hooks (idle-promoter DevelopmentHelixIdle))
!(add-atom &rna_hooks (rna-advancer DevelopmentHelixRNA DevelopmentHelixBoundary))
