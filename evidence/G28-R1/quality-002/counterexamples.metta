!(import! &self "/Users/claritymiter/miter/src/bootstrap_executable_development_v2.metta")

!(result absent (YTrialFacts (executable-trial-unqualified ((io-case sample payload (1))) ((io-incomplete sample unknown))) (process-incomplete candidate-smoke unknown)))
!(result mismatch (YTrialFacts (executable-trial-unqualified ((io-case sample payload (1))) ((io-observation sample 0 (2)))) (process-incomplete candidate-smoke unknown)))
!(result failed-process (YTrialFacts (executable-trial-qualified () ()) (process-observation candidate-smoke 1 "" "" false receipt)))
!(result passed-process (YTrialFacts (executable-trial-qualified () ()) (process-observation candidate-smoke 0 "" "" false receipt)))
!(result output-truncated (YSmokePassed (process-observation candidate-smoke 0 "" "" true receipt)))
!(result direct-counterexample (YCaseCounterexample (io-case sample payload (1)) ((io-observation sample 0 (2)))))
!(result counterexamples (collapse (let $c (superpose ((io-case sample payload (1)))) (YCaseCounterexample $c ((io-observation sample 0 (2))))))))

