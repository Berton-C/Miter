!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v3.metta")

!(result source (let $o (ZOpportunity (wz_input "/Users/claritymiter/miter/evidence/G28-R2/attempt-003")) (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-003" opportunity $o)))
!(result prior (let $p (wz_prior "/Users/claritymiter/miter/evidence/G28-R2/attempt-003") (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-003" prior-readback $p)))
!(result revision (let* (($p (wz_prior "/Users/claritymiter/miter/evidence/G28-R2/attempt-003")) ($rows (ZObligations (index-atom $p 2))) ($r (PRConstruct (index-atom (index-atom $p 1) 2) $rows))) (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-003" prior-revision $r)))

