!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v2.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r1/observations.pl" (dg_observation dg_incomplete))
!(result complete (let $r (YContinuationCompare (PAdd (YFailureFacts (dg_observation "/Users/claritymiter/miter/evidence/G28-R1/diagnostic-011/malformed/observation.json")) ((edge grant usable)) 0)) (index-atom $r 1)))
!(result incomplete (let $r (YContinuationCompare (PAdd (YFailureFacts (dg_incomplete "/Users/claritymiter/miter/evidence/G28-R1/diagnostic-011/malformed/observation.json")) ((edge grant usable)) 0)) (index-atom $r 1)))
