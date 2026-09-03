; G31 P3 native construction and interpretation for one source-grounded repair.
; The LLM renders candidate bytes only. It does not grant source standing,
; effect authority, test sufficiency, promotion, or live contact.

(= (G31P3RepairPrompt)
 "Return exactly BEGIN_SOURCE on its own line, then the full revised SWI-Prolog source, then END_SOURCE on its own line. Preserve every byte of the supplied prior source except replace the exact text body:_{channel_id:CID, message:M} with body:_{channel_id:CID, message:M, pending_post_id:IK}. This maps the already-validated stable idempotency key into Mattermost 11.7.7's actual request field while retaining the descriptor-level idempotency_key. Make no other code, comment, whitespace, export, behavior, credential, network, Soul, memory, or test change. Do not use a code fence or explanation.")

(= (G31P3RevisionQuestion $source $observedVersion $candidate $oldFile)
 (let $assessment
  (RReconciliationAssessment $source $observedVersion $candidate)
  (if (and (== (index-atom (index-atom $assessment 1) 1)
               supported-qualified)
       (and (== (index-atom (index-atom $assessment 2) 1)
                revision-required)
        (and (PHas pending-post-id-in-request-body
                   (index-atom (index-atom $assessment 2) 3) 0)
             (PHas effect-key-mapped-to-pending-post-id
                   (index-atom (index-atom $assessment 2) 3) 0))))
   (openrouter-source openrouter-g31-p3-revision-1
    mattermost-v11-7-7-pending-post-reconciliation
    mattermost-g31-p3 bridge (G31P3RepairPrompt) $oldFile
    ((source-consequence
      v11-7-7 2045acd92c40353abfc5ffff8ae1e0dd9d2e6737
      pending-post-id cache-window-seconds-30)
     (candidate-consequence
      (index-atom $candidate 1)
      missing-request-body-map hold-before-live)
     (non-claim universal-exactly-once))
    8192 300)
   (g31-p3-revision-question-held $assessment))))

(= (G31P3Run $root $source $observedVersion $candidate $oldFile)
 (let $question
  (G31P3RevisionQuestion $source $observedVersion $candidate $oldFile)
  (if (PShape $question openrouter-source 10)
   (let* (($stage (add-atom &derived
                    (openrouter-source-pending $root $question)))
          ($observation (or_source $root $question))
          ($clear (remove-atom &derived
                    (openrouter-source-pending $root $question))))
    (g31-p3-model-candidate $question $observation))
   $question)))

(= (G31P3MockValid $mock $candidateHash)
 (if (PShape $mock g31-p3-mock-observation 12)
  (and (== (index-atom $mock 1) $candidateHash)
   (and (== (index-atom $mock 2) true)
    (and (== (index-atom $mock 3) true)
     (and (== (index-atom $mock 4) 1)
      (and (== (index-atom $mock 5) true)
       (and (== (index-atom $mock 6) true)
        (and (== (index-atom $mock 7) true)
         (and (== (index-atom $mock 8) true)
          (and (== (index-atom $mock 9) true)
           (and (== (index-atom $mock 10) true)
                (== (index-atom $mock 11) true))))))))))) false))

(= (G31P3TrialStanding $source $observedVersion $candidate $mock)
 (let $assessment
  (RReconciliationAssessment $source $observedVersion $candidate)
  (if (and (== (index-atom (index-atom $assessment 1) 1)
               supported-qualified)
       (and (== (index-atom (index-atom $assessment 2) 1)
                qualified-bounded-retry)
            (G31P3MockValid $mock (index-atom $candidate 1))))
   (g31-p3-candidate-qualified
    (candidate (index-atom $candidate 1))
    (destination mattermost v11-7-7)
    (retry-envelope same-principal same-key within-30-seconds)
    (limits expiry eviction restart cache-loss)
    (exactly-once-standing unproven)
    (next-standing eligible-for-transport-integration-not-live))
   (g31-p3-candidate-held $assessment $mock))))
