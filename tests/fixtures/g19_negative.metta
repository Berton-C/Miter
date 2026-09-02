!(import! &self "/Users/claritymiter/miter/src/bootstrap_reactor.metta")
; Test-only severed selector never yields to contact while internal work exists.
(= (G19Internals)
   (collapse (match &rna (ready $id ResearchRNA $locus $n)
                        (ready $id ResearchRNA $locus $n))))
(= (G19NonInterruptible $root)
   (if (> (size-atom (G19Internals)) 0) (G19Internals) (ReactorReady)))
!(SoulBoot "runtime/g19/negative/integrity.json")
!(ReactorCycleWith "runtime/g19/negative" false 0.05 G19NonInterruptible)
