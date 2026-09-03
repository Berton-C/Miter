!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v3.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r3/fixtures.pl" (ef_pair))
!(import! &self "/Users/claritymiter/miter/evidence/G28-R3/attempt-002/trial-severed-code.metta")
!(result broken (let* (($p (ef_pair "/Users/claritymiter/miter/evidence/G28-R3/attempt-002" broken-trial)) ($a (EPAdmission (index-atom $p 0) (index-atom $p 1)))) (index-atom $a 0)))
