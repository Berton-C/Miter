!(import! &self "/Users/claritymiter/miter/src/bootstrap_reactor.metta")
!(import_prolog_functions_from_file "./effect_membranes/miter_interests.pl"
 (miter_interest_proposals miter_interest_field miter_interest_observations miter_interest_cut
  miter_interest_id miter_interest_seen miter_interest_note miter_interest_write
  miter_interest_opportunity_field miter_interest_request miter_interest_rna))
!(import! &self "/Users/claritymiter/miter/src/interests.metta")
!(add-atom &rna_hooks (idle-promoter InterestIdle))
!(add-atom &rna_hooks (rna-advancer DevelopRNA DevelopBoundary))
