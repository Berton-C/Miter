!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_promotion_v1.metta")
!(result snapshot (let $s (wp_snapshot "/Users/claritymiter/miter/evidence/G28-R3/attempt-001") (wp_save "/Users/claritymiter/miter/evidence/G28-R3/attempt-001" snapshot $s)))
!(result admission (let $a (EPAdmission (wp_input "/Users/claritymiter/miter/evidence/G28-R3/attempt-001") (wp_snapshot "/Users/claritymiter/miter/evidence/G28-R3/attempt-001")) (wp_save "/Users/claritymiter/miter/evidence/G28-R3/attempt-001" preflight-admission $a)))
