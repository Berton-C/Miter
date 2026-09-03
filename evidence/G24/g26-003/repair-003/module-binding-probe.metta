!(import! &self "/Users/claritymiter/miter/src/bootstrap_development_resume_v1.metta")
!(add-atom &soul (protected-canary Soul))
!(add-atom &history (protected-canary adverse-history))
!(result binding (let* (($input (dr_input "/Users/claritymiter/miter/evidence/G24/g26-003/repair-003")) ($accepted (index-atom $input 1)) ($invs (index-atom $input 3)) ($loaded (TVHydrate $accepted (tv_restore $accepted)))) ((DRActiveFits $accepted $invs (index-atom $input 8)) (DRActiveFits $accepted $invs ()) (DRActiveFits $accepted $invs (index-atom $input 8)))))
