!(import! &self "/Users/claritymiter/miter/src/bootstrap_voice_trials_v2.metta")
!(add-atom &soul (protected-canary Soul))
!(add-atom &history (protected-canary adverse-history))
!(result diagnosis (let* (($i (tv_input "/Users/claritymiter/miter/evidence/G22/attempt-001/canonical" input)) ($m (tv_module "/Users/claritymiter/miter/evidence/G22/attempt-001/canonical" parent)) ($r (tv_input "/Users/claritymiter/miter/evidence/G22/attempt-001/canonical" parent-report)) ($case (index-atom (index-atom $i 1) 0)) ($obs (index-atom (index-atom $r 3) 0))) ((PShape $r trial-report 4) (size-atom (index-atom $r 3)) (== (index-atom $obs 1) $case) (PShape $obs trial-observation 4) (TVFind $case (index-atom $r 3)) (== $obs (TVObserve $case $m)))))
