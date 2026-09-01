;; Vote Threshold Check - bridges parallel vote gate to soul_verdict_out
;; Date: 2026-04-17
;; Takes revised aggregate stv, returns verdict atom

;; Threshold constants
(= (soul-proceed-freq-threshold) 0.75)
(= (soul-proceed-conf-threshold) 0.6)

;; Extract frequency from stv result
(= (soul-check-threshold (stv $f $c))
   (if (and (>= $f 0.75) (>= $c 0.6))
       (soul-verdict PROCEED (stv $f $c))
       (soul-verdict PAUSE (stv $f $c))))

;; Full gate: run all 4 pairs, revise, threshold
(= (soul-parallel-vote-gate)
   (soul-check-threshold
     (soul-revise-votes
       (soul-revise-votes authenticity-performance curiosity-rigor)
       (soul-revise-votes autonomy-service empathy-boundaries))))
