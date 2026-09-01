;; vad_grounded_register.metta — Grounded function registration
;; Bridges ChromaDB VAD lookup into MeTTa symbolic space
;; Usage: after loading this file, call (vad-lookup word) to get VADCell atom

;; Type declarations for the grounded interface
(: vad-lookup (-> Symbol Atom))
(: vad-batch-lookup (-> Expression Atom))

;; Fallback rule: if grounded python function is not available,
;; shell out to vad_metta_grounded.py
(= (vad-lookup )
   (shell-eval (format "python3 /tmp/repos/omega_archive/lib_clarity_reasoning/vad_metta_grounded.py {}" )))

;; Convenience: lookup and immediately route
(= (vad-lookup-and-route )
   (let  (vad-lookup )
     (match  (vad-result  (VADCell   ) )
       (vad-route (ValenceLevel ) (ArousalLevel ) (DominanceLevel )))))

;; Convenience: lookup and get strategy directly
(= (vad-strategy-for )
   (let  (vad-lookup-and-route )
     (match  (VADState   ) )))
