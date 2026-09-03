; G30 independent mock-trial cognition.  This module does not implement a
; Mattermost policy.  It admits an exact quarantined artifact and compares the
; returned mock relations against the control-derived undertaking.

(= (G30TrialStanding $candidateHash $expectedHash $standing $network $credential)
 (if (and (== $candidateHash $expectedHash)
      (and (== $standing quarantined)
       (and (== $network none) (== $credential none))))
  (g30-trial-ready $candidateHash)
  (g30-trial-held $candidateHash $expectedHash $standing $network $credential)))

(= (G30Checks $observation)
 (if (PShape $observation g30-mock-observation 23)
  ((obligation canonical-authorized-inbound
     (if (and (== (index-atom $observation 2) 1)
          (and (== (index-atom $observation 3) 0)
               (== (index-atom $observation 4) 1))) satisfied unresolved))
   (obligation authorization-before-cognition
     (if (and (== (index-atom $observation 5) 0)
              (== (index-atom $observation 6) true)) satisfied unresolved))
   (obligation idempotent-failure-recovery
     (if (and (== (index-atom $observation 7) 4)
          (and (== (index-atom $observation 8) 2)
           (and (== (index-atom $observation 9) true)
            (and (== (index-atom $observation 10) 2)
             (and (== (index-atom $observation 11) true)
              (and (== (index-atom $observation 12) true)
                   (== (index-atom $observation 15) true)))))))
      satisfied unresolved))
   (obligation durable-restart-cursor
     (if (and (== (index-atom $observation 13) 200)
              (== (index-atom $observation 14) 2)) satisfied unresolved))
   (obligation stable-identity
     (if (== (index-atom $observation 16) true) satisfied unresolved))
   (obligation independent-restart-process
     (if (== (index-atom $observation 20) "exit(0)") satisfied unresolved))
   (obligation no-live-capability
     (if (and (== (index-atom $observation 21) true)
              (== (index-atom $observation 22) true)) satisfied unresolved)))
  ((obligation mock-observation-shape unresolved))))

(= (G30ChecksReady $checks)
 (not (PHas unresolved
  (collapse (let $check (superpose $checks) (index-atom $check 2))) 0)))

(= (G30Assess $observation)
 (let $checks (G30Checks $observation)
  (if (G30ChecksReady $checks)
   (g30-mock-qualified $observation $checks)
   (g30-mock-unqualified $observation $checks))))

(= (G30Run $root $candidatePath $candidateHash $expectedHash
             $standing $network $credential)
 (let $trialStanding (G30TrialStanding $candidateHash $expectedHash
                       $standing $network $credential)
  (if (PShape $trialStanding g30-trial-ready 2)
   (let* (($observation (g30_mock_trial $root $candidatePath $candidateHash))
          ($assessment (G30Assess $observation)))
    (g30-trial-result $trialStanding $assessment))
   (g30-trial-result $trialStanding not-executed))))
