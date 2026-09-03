!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v1.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28/boundaries.pl" (xb_saved))

!(result input (let $x (wx_input "/Users/claritymiter/miter/evidence/G28/attempt-005") (index-atom $x 0)))
!(result unstaged (let* (($q (xb_saved "/Users/claritymiter/miter/evidence/G28/attempt-005" executable-1-generation.json)) ($r (wx_model "/Users/claritymiter/miter/evidence/G28/attempt-005" $q))) (index-atom $r 0)))
!(result replay (let* (($q (xb_saved "/Users/claritymiter/miter/evidence/G28/attempt-005" executable-1-generation.json)) ($s (add-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28/attempt-005" $q))) ($r (wx_model "/Users/claritymiter/miter/evidence/G28/attempt-005" $q)) ($c (remove-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28/attempt-005" $q)))) (wx_save "/Users/claritymiter/miter/evidence/G28/attempt-005" replay $r)))
!(result held (let $x (wx_input "/outside-of-workshop") (index-atom $x 0)))
!(result forged (let $r (wx_observe "/Users/claritymiter/miter/evidence/G28/attempt-005" ordinary (workshop-result fabricated test-completed fake-event fake-hash)) (index-atom $r 0)))
!(result lineage (wx_candidate_bound "/Users/claritymiter/miter/evidence/G28/attempt-005" executable-1 (executable-candidate forged () ())))

