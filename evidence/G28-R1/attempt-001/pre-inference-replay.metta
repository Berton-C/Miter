!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v2.metta")
!(add-atom &soul (protected-canary Soul))
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r1/preflight.pl" (pf_question))

!(result opportunity (let $o (YOpportunity (wy_input "/Users/claritymiter/miter/evidence/G28-R1/attempt-001")) (wy_save "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" opportunity $o)))
!(result unstaged (let $r (wy_model "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" (pf_question "/Users/claritymiter/miter/evidence/G28-R1/attempt-001")) (index-atom $r 0)))
!(result unknown (let $r (wy_input "/unknown") (index-atom $r 0)))
!(result forged (let $r (wy_observe "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" ordinary (workshop-result fake test-completed fake hash)) (index-atom $r 0)))
!(result replay (let* (($q (pf_question "/Users/claritymiter/miter/evidence/G28-R1/attempt-001")) ($s (add-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" $q))) ($r (wy_model "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" $q)) ($c (remove-atom &derived (executable-generation-pending "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" $q)))) (index-atom $r 2)))

