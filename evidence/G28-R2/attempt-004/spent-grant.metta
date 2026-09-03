!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v3.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r2/boundaries.pl" (xb_exhausted_question))

!(result exhausted (let* (($q (xb_exhausted_question "/Users/claritymiter/miter/evidence/G28-R2/attempt-004")) ($s (add-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q))) ($r (wz_model "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q)) ($c (remove-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" $q)))) (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-004" spent-grant-observation $r)))

