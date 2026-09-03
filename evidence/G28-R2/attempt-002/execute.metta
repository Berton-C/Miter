!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v3.metta")
!(add-atom &soul (protected-canary Soul))
!(result outcome (let $r (ZRun "/Users/claritymiter/miter/evidence/G28-R2/attempt-002") (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-002" final $r)))
!(result state (wz_save "/Users/claritymiter/miter/evidence/G28-R2/attempt-002" atomspace ((collapse (match &trial $a $a)) (collapse (match &derived $a $a)) (collapse (match &soul $a $a)))))
