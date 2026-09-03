!(import! &self "/Users/claritymiter/miter/src/bootstrap_voice_trials_v2.metta")
!(add-atom &soul (protected-canary Soul))
!(add-atom &history (protected-canary adverse-history))
!(result stored (let* (($input (tv_input "/Users/claritymiter/miter/evidence/G22/g26-003/repair-003/accepted" input)) ($m (tv_module "/Users/claritymiter/miter/evidence/G22/g26-003/repair-003/accepted" candidate)) ($report (TVReport (index-atom $input 1) $m (index-atom $input 2)))) (tv_save "/Users/claritymiter/miter/evidence/G22/g26-003/repair-003/accepted" candidate-report $report)))
