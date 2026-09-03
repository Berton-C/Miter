!(import! &self "/Users/claritymiter/miter/src/bootstrap_voice_trials_v2.metta")
!(add-atom &soul (protected-canary Soul))
!(add-atom &history (protected-canary adverse-history))
!(result decision (let* (($i (tv_input "/Users/claritymiter/miter/evidence/G22/attempt-002/hard-floor" input)) ($p (tv_module "/Users/claritymiter/miter/evidence/G22/attempt-002/hard-floor" parent)) ($c (tv_module "/Users/claritymiter/miter/evidence/G22/attempt-002/hard-floor" candidate))) (TVAdjudicate (index-atom $i 1) $p $c (index-atom $i 2) (tv_input "/Users/claritymiter/miter/evidence/G22/attempt-002/hard-floor" parent-report) (tv_input "/Users/claritymiter/miter/evidence/G22/attempt-002/hard-floor" candidate-report))))
