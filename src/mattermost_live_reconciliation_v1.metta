; G31 P2 source-grounded reconciliation comparison.
; This module derives bounded standing from admitted version/source relations.
; It does not perform transport, choose an effect, or claim universal exactly-once.

(= (RMissing $required $available $i)
 (if (< $i (size-atom $required))
  (let* (($need (index-atom $required $i))
         ($rest (RMissing $required $available (+ $i 1))))
   (if (PHas $need $available 0) (PList $rest)
       (cons-atom $need $rest))) ()))

(= (RSourceShape $source)
 (if (PShape $source mattermost-reconciliation-source 5)
  (and (is-expr (index-atom $source 3))
       (is-expr (index-atom $source 4))) false))

(= (RCandidateShape $candidate)
 (if (PShape $candidate effect-descriptor-view 9)
  (and (is-expr (index-atom $candidate 3))
   (and (is-expr (index-atom $candidate 4))
        (is-expr (index-atom $candidate 5)))) false))

(= (RSourceNeeds)
 (post-json-field-pending-post-id
  request-key-cached-before-create
  duplicate-returns-existing-post
  in-flight-duplicate-reports-pending
  failed-create-removes-key
  cache-window-30-seconds
  expired-key-may-create-new-post
  authorization-checked-before-existing-return))

(= (RCandidateNeeds)
 (pending-post-id-in-request-body
  effect-key-mapped-to-pending-post-id
  same-authorized-principal
  retry-within-cache-window
  durable-local-effect-journal))

(= (RCandidateEvidence $candidate)
 (collapse
  (superpose
   ((if (PHas pending-post-id (index-atom $candidate 3) 0)
      pending-post-id-in-request-body (empty))
    (if (PHas (map idempotency-key pending-post-id)
              (index-atom $candidate 5) 0)
      effect-key-mapped-to-pending-post-id (empty))
    (if (== (index-atom $candidate 6) true)
      same-authorized-principal (empty))
    (if (and (> (index-atom $candidate 7) 0)
             (<= (index-atom $candidate 7) 30))
      retry-within-cache-window (empty))
    (if (== (index-atom $candidate 8) true)
      durable-local-effect-journal (empty))))))

(= (RSourceStanding $source $observedVersion)
 (if (RSourceShape $source)
  (if (== (index-atom $source 1) $observedVersion)
   (let $missing (RMissing (RSourceNeeds) (index-atom $source 3) 0)
    (if (== (size-atom $missing) 0)
     (source-standing supported-qualified
      (version $observedVersion (index-atom $source 2))
      (constraints (index-atom $source 4)))
     (source-standing unresolved-source-relations $missing)))
   (source-standing unresolved-version
    (expected (index-atom $source 1)) (observed $observedVersion)))
  (source-standing malformed-source)))

(= (RCandidateStanding $candidate $source)
 (if (RCandidateShape $candidate)
  (if (== (index-atom $candidate 2) (index-atom $source 1))
   (let $missing (RMissing (RCandidateNeeds)
                           (RCandidateEvidence $candidate) 0)
    (if (== (size-atom $missing) 0)
     (candidate-standing qualified-bounded-retry
      (candidate (index-atom $candidate 1))
      (window-seconds (index-atom $candidate 7)))
     (candidate-standing revision-required
      (candidate (index-atom $candidate 1)) $missing)))
   (candidate-standing unresolved-version
    (candidate-version (index-atom $candidate 2))
    (source-version (index-atom $source 1))))
  (candidate-standing malformed-candidate)))

(= (RReconciliationAssessment $source $observedVersion $candidate)
 (let* (($sourceStanding (RSourceStanding $source $observedVersion))
        ($candidateStanding (RCandidateStanding $candidate $source)))
  (reconciliation-assessment
   $sourceStanding
   $candidateStanding
   (effect-standing
    (if (and (== (index-atom $sourceStanding 1) supported-qualified)
             (== (index-atom $candidateStanding 1)
                 qualified-bounded-retry))
      eligible-for-bounded-mock-trial hold-before-live))
   (exactly-once-standing unproven)
   (failure-boundary
    accepted-response-lost-after-window-remains-uncertain))))
