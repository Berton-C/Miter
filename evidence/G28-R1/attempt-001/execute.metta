!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v2.metta")
!(add-atom &soul (protected-canary Soul))
!(result outcome (let $result (YRun "/Users/claritymiter/miter/evidence/G28-R1/attempt-001") (wy_save "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" final $result)))
!(result state (wy_save "/Users/claritymiter/miter/evidence/G28-R1/attempt-001" atomspace ((collapse (match &trial $a $a)) (collapse (match &derived $a $a)) (collapse (match &soul $a $a)))))
