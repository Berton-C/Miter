!(import! &self "/Users/claritymiter/miter/src/bootstrap_nace_v2.metta")
!(result check (let* (($inv (index-atom (index-atom (nn_input "/Users/claritymiter/miter/evidence/G24/attempt-006/boundaries/native-guards") 1) 1)) ($old (NSeed $inv)) ($obs (NObserve $inv))) (nn_commit "/Users/claritymiter/miter/evidence/G24/attempt-006/boundaries/native-guards" (NApply $old $obs))))
