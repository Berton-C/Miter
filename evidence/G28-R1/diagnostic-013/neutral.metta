!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v2.metta")
!(import_prolog_functions_from_file "/Users/claritymiter/miter/scripts/g28_r1/observations.pl" (dg_observation dg_incomplete))
!(result reordered (let $r (YContinuationCompare ((edge grant usable) (edge discrepancy specific))) (index-atom $r 1)))
!(result renamed (let $r (DCCompare ((edge x available)) ((path x done)) ((operation another-name ((edge x available)) ((edge x done)) ())) 3) (index-atom $r 1)))
