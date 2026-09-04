; G33 R10 dedicated corrected bootstrap. The historical fixed-proposal idle
; path is intentionally not imported into this causal integration experiment.
!(import! &self "/Users/claritymiter/miter/src/bootstrap_reactor.metta")
!(import! &self "/Users/claritymiter/miter/src/bootstrap_development_cycle.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/effect_membranes/miter_development_reactor_v1.pl"
 (dr_contact_set dr_store_turn dr_state dr_rna_status dr_rna_checkpoint))
!(import! &self "/Users/claritymiter/miter/src/development_reactor_v1.metta")
!(add-atom &rna_hooks (idle-promoter SourceGroundedDevelopmentIdle))
!(add-atom &rna_hooks
 (rna-advancer SourceGroundedDevelopRNA SourceGroundedDevelopmentBoundary))
