!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v3.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r2/boundaries.pl" (xb_candidate xb_generation xb_opportunity xb_forged_candidate xb_neutral_candidate xb_receipt xb_forged_manifest))

!(result manifest-bound (let $c (xb_forged_manifest "/Users/claritymiter/miter/evidence/G28-R2/attempt-004") (wz_candidate_bound "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" fresh-1 $c)))
!(result manifest-valid (let* (($o (xb_opportunity "/Users/claritymiter/miter/evidence/G28-R2/attempt-004")) ($c (xb_forged_manifest "/Users/claritymiter/miter/evidence/G28-R2/attempt-004"))) (ZCandidateValid $o fresh-1 $c)))
!(result disk (let $c (xb_candidate "/Users/claritymiter/miter/evidence/G28-R2/attempt-004") (wz_disk_bound "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" fresh-1 $c)))
!(result replay (let* (($q (xb_generation "/Users/claritymiter/miter/evidence/G28-R2/attempt-004")) ($s (add-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q))) ($r (wz_model "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q)) ($c (remove-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q)))) (index-atom $r 7)))

