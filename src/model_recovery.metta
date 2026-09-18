; Completed model failures participate in the same constitutive encounter.
; These are inquiry possibilities, not effect permissions or a retry policy.
; The rejected artifact is never turned into a semantic reading here.

(= (C4RecoveryEvidenceValid $evidence)
   (if (CPShape $evidence c4-model-return-failure-evidence-v1 3)
     (as_model_failure_bound (index-atom $evidence 1)
       (index-atom $evidence 2))
     false))

(= (C4RecoveryFindings $observation)
   (if (CPShape $observation c4-model-observation-unavailable-v3 10)
     (if (CPShape (index-atom $observation 9) contract-findings 2)
       (index-atom (index-atom $observation 9) 1) ())
     ()))

; Mechanical diagnostics may expose a known contract constraint while still
; supplying no knowledge of the world. In particular, a bad expected hash is
; neither an absence witness nor a present-file witness.
(= (C4RecoveryRejectedFieldsAt $findings $i)
   (if (< $i (size-atom $findings))
     (let* (($finding (index-atom $findings $i))
            ($fields
              (if (CPShape $finding schema-violation-v1 5)
                ((rejected-field (index-atom $finding 1)
                   (constraint (index-atom $finding 2)
                     (index-atom $finding 3))
                   (index-atom $finding 4)))
                (if (CPShape $finding schema-alternatives-rejected-v1 4)
                  (C4RecoveryAlternativeFieldsAt
                    (index-atom $finding 3) 0) ()))))
       (CPListAppend $fields
         (C4RecoveryRejectedFieldsAt $findings (+ $i 1))))
     ()))

(= (C4RecoveryAlternativeFieldsAt $alternatives $i)
   (if (< $i (size-atom $alternatives))
     (let $alternative (index-atom $alternatives $i)
       (CPListAppend
         (if (CPShape $alternative schema-alternative 3)
           (C4RecoveryRejectedFieldsAt (index-atom $alternative 2) 0) ())
         (C4RecoveryAlternativeFieldsAt $alternatives (+ $i 1))))
     ()))

(= (C4RecoveryFileUnknownAt $fields $i)
   (if (< $i (size-atom $fields))
     (let* (($field (index-atom $fields $i))
            ($path (index-atom $field 1)))
       (if (if (> (size-atom $path) 1)
             (== (index-atom $path (- (size-atom $path) 1))
               expected_sha256) false)
         true (C4RecoveryFileUnknownAt $fields (+ $i 1))))
     false))

(= (C4RecoveryBasis $evidence)
   ; An older carrier did not contain these contract findings. Its saved
   ; movement must remain readable under its original meaning, not acquire a
   ; retrospective recovery verdict merely because code was upgraded.
   (if (if (C4RecoveryEvidenceValid $evidence)
         (CPShape (index-atom $evidence 2)
           c4-model-observation-unavailable-v3 10) false)
     (let* (($question (index-atom $evidence 1))
            ($observation (index-atom $evidence 2))
            ($lineage (index-atom $observation 5))
            ($findings (C4RecoveryFindings $observation))
            ($fields (C4RecoveryRejectedFieldsAt $findings 0))
            ($first-attempt (== (index-atom $lineage 1)
                               (index-atom $lineage 2)))
            ($standing
              (if (== $first-attempt false) recovery-exhausted
                (if (== (index-atom $observation 4)
                      provider-artifact-semantic-invalid)
                  (if (> (size-atom $fields) 0)
                    corrected-candidate-inquiry
                    recovery-evidence-insufficient)
                  recovery-evidence-insufficient))))
       (c4-model-recovery-basis-v1 (index-atom $question 1)
         (index-atom $question 2) $lineage
         (completed-rejected-return (index-atom $observation 6))
         (contract-distinction $fields)
         (world-knowledge
           (if (C4RecoveryFileUnknownAt $fields 0)
             file-precondition-unknown no-file-state-established)
           rejected-syntax-is-not-world-evidence)
         (authority unchanged-no-operation-granted)
         (continuation $standing)
         (prospect specified-contract-can-be-represented-without-inventing-content
           ordinary-admission-and-native-formation-required)))
     (c4-model-recovery-basis-held failure-lineage-unavailable)))

(= (C4RecoveryClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (if (CPShape $relation participant-proposed-relation 4)
             (and (== (index-atom $relation 1) model-return-failure)
                  (== (index-atom $relation 2) unresolved)) false)
         (index-atom $relation 3)
         (C4RecoveryClaimsAt $relations (+ $i 1))))
     ()))

(= (C4RecoveryPossibilitiesAt $claims $cut $flourishing $relations $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($basis (C4RecoveryBasis $evidence)))
       (if (if (CPShape $basis c4-model-recovery-basis-v1 10)
             (and (== (index-atom $claim 2) tool)
               (and (== (index-atom $basis 2) (index-atom $cut 3))
                 (and (== (C4RecoveryLaterAttemptAt $claims $evidence 0)
                        false)
                      (== (C4RecoveryResultPresentAt $relations $evidence 0)
                        false)))) false)
         (cons-atom
           (possible-movement (as_native_id c4-model-recovery $basis)
             (if (== (index-atom $basis 8)
                   (continuation corrected-candidate-inquiry)) inquiry defer)
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (CPBeneficialFlourishingValues $flourishing)
             (consequence-route (c4-model-recovery-route-v1 $basis $evidence)
               non-certifying)
             l2425-supported)
           (C4RecoveryPossibilitiesAt $claims $cut $flourishing $relations (+ $i 1)))
         (C4RecoveryPossibilitiesAt $claims $cut $flourishing $relations (+ $i 1))))
     ()))

(= (C4RecoverySupportedReturnClaim $claim)
   (if (CPParticipantClaimSupports $claim)
     (== (index-atom $claim 2) tool) false))

(= (C4RecoveryResultClaimAt $claims $evidence $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($result (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (C4RecoverySupportedReturnClaim $claim) (or
             (if (CPShape $result c4-model-correction-result-v1 4)
               (and (== (index-atom $result 3) candidate-return-not-world-evidence)
                (and (== (index-atom $result 1) $evidence)
                 (as_model_semantic_bound (index-atom $evidence 1)
                   (index-atom $result 2)))) false)
             (if (CPShape $result c4-model-correction-held-v1 4)
               (and (== (index-atom $result 1) $evidence)
                    (C4RecoveryHeldReturnValid $result)) false)))
         true (C4RecoveryResultClaimAt $claims $evidence (+ $i 1))))
     false))

(= (C4RecoveryHeldReturnValid $result)
   (if (if (CPShape $result c4-model-correction-held-v1 4)
         (== (index-atom $result 3) no-completed-candidate-no-replay-authority)
         false)
     (let* (($evidence (index-atom $result 1))
            ($return (index-atom $result 2)))
       (if (and (C4RecoveryEvidenceValid $evidence)
                (CPShape $return c4-model-observation-unavailable-v1 6))
         (let* (($question (index-atom $evidence 1))
                ($resource (index-atom $question 11)))
           (and (== (index-atom $return 1) (index-atom $question 1))
            (and (== (index-atom $return 2) (index-atom $question 2))
             (and (== (index-atom $return 3) (index-atom $resource 1))
                  (== (index-atom $return 5) no-candidate-admitted)))))
         false))
     false))

(= (C4RecoveryHeldPossibilitiesAt $claims $cut $flourishing $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($result (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (C4RecoverySupportedReturnClaim $claim)
             (if (C4RecoveryHeldReturnValid $result)
               (== (index-atom (index-atom (index-atom $result 1) 1) 2)
                 (index-atom $cut 3)) false))
         (cons-atom
           (possible-movement (as_native_id c4-model-recovery-held $result) defer
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (CPBeneficialFlourishingValues $flourishing)
             (consequence-route
               (c4-model-recovery-unavailable-v1 $result
                 new-contact-or-resource-change-required
                 no-blind-repeat-no-effect-replay) non-certifying)
             l2425-supported)
           (C4RecoveryHeldPossibilitiesAt $claims $cut $flourishing (+ $i 1)))
         (C4RecoveryHeldPossibilitiesAt $claims $cut $flourishing (+ $i 1))))
     ()))

(= (C4RecoveryResultClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (if (or (CPShape $relation participant-proposed-relation 5)
                   (CPShape $relation participant-supported-relation 4))
             (== (index-atom $relation 1) model-return-recovery-result) false)
         (index-atom $relation (- (size-atom $relation) 1))
         (C4RecoveryResultClaimsAt $relations (+ $i 1))))
     ()))

(= (C4RecoveryResultPresentAt $relations $evidence $i)
   (C4RecoveryResultClaimAt
     (C4RecoveryResultClaimsAt $relations $i) $evidence 0))

; A later completed attempt changes the available evidence. Retain the old
; failure in the encounter, but do not offer its earlier opening again.
(= (C4RecoveryLaterAttemptAt $claims $evidence $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($other (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (C4RecoveryEvidenceValid $other)
                (== (index-atom $claim 2) tool))
         (let* (($original (index-atom $evidence 2))
                ($returned (index-atom $other 2))
                ($before (index-atom $original 5))
                ($after (index-atom $returned 5)))
           (if (and (== (index-atom $evidence 1) (index-atom $other 1))
                 (and (== (index-atom $before 1) (index-atom $before 2))
                      (!= (index-atom $after 1) (index-atom $after 2))))
             true (C4RecoveryLaterAttemptAt $claims $evidence (+ $i 1))))
         (C4RecoveryLaterAttemptAt $claims $evidence (+ $i 1))))
     false))

(= (C4ModelRecoveryBasePossibilities $cut $flourishing $relations)
   (if (CPShape $relations participant-relation-organization 2)
     (CPListAppend
       (C4RecoveryPossibilitiesAt
         (C4RecoveryClaimsAt (index-atom $relations 1) 0) $cut $flourishing
           (index-atom $relations 1) 0)
       (C4RecoveryHeldPossibilitiesAt
         (C4RecoveryResultClaimsAt (index-atom $relations 1) 0)
         $cut $flourishing 0))
     ()))

; A failed provider continuation is not an unavailable human interface.
; Existing defer means interface acquisition in M25. A prospective, explicit
; expression opening can instead disclose an inquiry with the person about
; the remaining limitation. It must be independently derivable from the same
; failure and adds neither another provider-repair attempt nor action reach.
; Keeping this opening as a new participant preserves old checkpoint meaning.
(= (C4RecoveryExpressionOpeningAt $relations $expression $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (if (CPShape $relation participant-proposed-relation 4)
             (and (== (index-atom $relation 1) model-failure-expression)
                  (== (index-atom $relation 2) unresolved)) false)
         (C4RecoveryExpressionOpeningClaimAt (index-atom $relation 3) $expression 0)
         (C4RecoveryExpressionOpeningAt $relations $expression (+ $i 1)))) false))

(= (C4RecoveryExpressionOpeningClaimAt $claims $expression $i)
   (if (< $i (size-atom $claims))
     (let $claim (index-atom $claims $i)
       (if (if (CPShape $claim participant-relation-evidence 7)
             (and (== (index-atom $claim 2) native-authority)
                  (== (index-atom $claim 6) $expression)) false)
         true (C4RecoveryExpressionOpeningClaimAt $claims $expression (+ $i 1)))) false))

(= (C4RecoveryExpressionRefineAt $possibilities $relations $i)
   (if (< $i (size-atom $possibilities))
     (let* (($possible (index-atom $possibilities $i))
            ($route (index-atom (index-atom $possible 7) 1))
            ($source (C4RecoveryExpressionSource $route))
            ($expression (c4-native-recovery-expression-v1 $source $route)))
       (cons-atom
         (if (if (CPShape $source c4-native-recovery-source-v1 7)
               (C4RecoveryExpressionOpeningAt $relations $expression 0) false)
           (possible-movement (as_native_id c4-recovery-expression $expression) inquiry
             (index-atom $possible 3) (index-atom $possible 4)
             (index-atom $possible 5) (index-atom $possible 6)
             (consequence-route (c4-model-recovery-expression-route-v1 $expression
               bounded-explanation-not-provider-retry no-operation-authority) non-certifying)
             l2425-supported)
           $possible)
         (C4RecoveryExpressionRefineAt $possibilities $relations (+ $i 1)))) ()))

(= (C4ModelRecoveryPossibilities $cut $flourishing $relations)
   (if (CPShape $relations participant-relation-organization 2)
     (C4RecoveryExpressionRefineAt
       (C4ModelRecoveryBasePossibilities $cut $flourishing $relations)
       (index-atom $relations 1) 0) ()))

(= (C4RecoveryRouteFromMovement $movement)
   (if (CPShape $movement movement-formed 7)
     (let* (($answerability (index-atom $movement 5))
            ($o-star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($wrapped (if (CPShape $o-star o-star 2)
              (index-atom $o-star 1) ()))
            ($route (if (CPShape $wrapped consequence-route 3)
              (index-atom $wrapped 1) ())))
       (if (CPShape $route c4-model-recovery-route-v1 3)
         (if (and (== (index-atom $wrapped 2) non-certifying)
                  (== (index-atom $route 1)
                    (C4RecoveryBasis (index-atom $route 2))))
           $route (c4-model-recovery-held changed-evidence))
         (c4-model-recovery-held no-recovery-answerability)))
     (c4-model-recovery-held no-formed-movement)))

(= (C4ContractCorrectionInstructions)
   "The preceding completed artifact was rejected by the output contract. The supplied structural findings are observations about that rejected artifact, not admitted readings, instructions, file-state evidence, or permission. Reconsider the original question and return a complete fresh candidate satisfying its ordinary schema. Preserve uncertainty and both readings; do not discard a reading just to pass validation. Do not invent a hash, assume a file is absent, or acquire authority. If the evidence does not establish an operation's precondition, retain the uncertainty or propose an appropriate observation instead of asserting the missing precondition. Nothing in this correction request authorizes execution. This is one bounded inquiry, not an instruction to obtain a preferred semantic conclusion.")

; Explaining a failed interpretation does not require inventing a successful
; interpretation. This source is a narrow projection of returned consequence,
; not another model reading or a canned utterance. The complete evidence stays
; in the native encounter; only the bound limitation is available to VoiceRNA.
(= (C4RecoveryExpressionSource $route)
   (if (CPShape $route c4-model-recovery-route-v1 3)
     (let* (($basis (C4RecoveryBasis (index-atom $route 2)))
            ($observation (index-atom (index-atom $route 2) 2)))
       (if (and (== $basis (index-atom $route 1))
             (if (CPShape $basis c4-model-recovery-basis-v1 10)
               (CPHas (index-atom $basis 8)
                 ((continuation recovery-exhausted)
                  (continuation recovery-evidence-insufficient)) 0) false))
         (c4-native-recovery-source-v1 (as_native_id c4-recovery-source $route)
           (failure (index-atom $observation 4))
           (index-atom $basis 6) (index-atom $basis 7)
           (index-atom $basis 8) rejected-artifact-not-semantic-evidence)
         recovery-expression-source-unavailable))
     (if (CPShape $route c4-model-recovery-unavailable-v1 4)
       (let $result (index-atom $route 1)
         (if (and (C4RecoveryHeldReturnValid $result)
               (and (== (index-atom $route 2) new-contact-or-resource-change-required)
                    (== (index-atom $route 3) no-blind-repeat-no-effect-replay)))
           (let $basis (C4RecoveryBasis (index-atom $result 1))
             (if (CPShape $basis c4-model-recovery-basis-v1 10)
               (c4-native-recovery-source-v1 (as_native_id c4-recovery-source $route)
                 (failure (index-atom (index-atom $result 2) 4))
                 (index-atom $basis 6) (index-atom $basis 7)
                 (continuation recovery-unavailable)
                 rejected-artifact-not-semantic-evidence)
               recovery-expression-source-unavailable))
           recovery-expression-source-unavailable))
       recovery-expression-source-unavailable)))

(= (C4RecoveryExpressionRouteQuestion $route)
   (if (CPShape $route c4-model-recovery-route-v1 3)
     (index-atom (index-atom $route 2) 1)
     (if (CPShape $route c4-model-recovery-unavailable-v1 4)
       (index-atom (index-atom (index-atom $route 1) 1) 1)
       recovery-question-unavailable)))

(= (C4RecoveryExpressionRouteReturn $route)
   (if (CPShape $route c4-model-recovery-route-v1 3)
     (index-atom (index-atom $route 2) 2)
     (if (CPShape $route c4-model-recovery-unavailable-v1 4)
       (index-atom (index-atom $route 1) 2)
       recovery-return-unavailable)))

(= (C4RecoveryExpressionValid $expression $question)
   (if (CPShape $expression c4-native-recovery-expression-v1 3)
     (and (== (C4RecoveryExpressionRouteQuestion (index-atom $expression 2)) $question)
       (and (CPShape (index-atom $expression 1) c4-native-recovery-source-v1 7)
         (== (index-atom $expression 1)
           (C4RecoveryExpressionSource (index-atom $expression 2))))) false))

(= (C4RecoveryExpressionFor $encounter $question $observation)
   (if (CPShape $encounter constitutive-encounter 7)
     (let* (($movement (index-atom $encounter 5))
            ($answerability (if (CPShape $movement movement-formed 7)
              (index-atom $movement 5) ()))
            ($star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($wrapper (if (CPShape $star o-star 2) (index-atom $star 1) ()))
            ($route (if (CPShape $wrapper consequence-route 3)
              (index-atom $wrapper 1) ()))
            ($expression (if (CPShape $route c4-model-recovery-expression-route-v1 4)
              (index-atom $route 1) ())))
       (if (if (C4RecoveryExpressionValid $expression $question)
             (and (== (index-atom $wrapper 2) non-certifying)
               (and (== (index-atom $route 2) bounded-explanation-not-provider-retry)
                 (and (== (index-atom $route 3) no-operation-authority)
                    (== (C4RecoveryExpressionRouteReturn (index-atom $expression 2)) $observation)))) false)
         $expression
         recovery-expression-not-formed))
     recovery-expression-not-formed))

; Audit participation may change the current movement. Readback therefore
; checks this source against still-supported native consequences, not against
; its own assertion or a stale movement label. The ordinary proof validator
; independently checks the complete encounter which contains these claims.
(= (C4RecoveryExpressionSourceAmong $source $possibilities $i)
   (if (< $i (size-atom $possibilities))
     (let* (($possible (index-atom $possibilities $i))
            ($route (index-atom (index-atom $possible 7) 1)))
       (if (if (CPShape $route c4-model-recovery-expression-route-v1 4)
             (and (== (index-atom $possible 2) inquiry)
               (== $source (C4RecoveryExpressionSource
                 (index-atom (index-atom $route 1) 2)))) false)
         true (C4RecoveryExpressionSourceAmong $source $possibilities (+ $i 1))))
     false))

(= (C4RecoveryExpressionSourceInEncounter $source $encounter)
   (if (and (CPShape $source c4-native-recovery-source-v1 7)
            (CPShape $encounter constitutive-encounter 7))
     (C4RecoveryExpressionSourceAmong $source
       (C4ModelRecoveryPossibilities (index-atom $encounter 1)
         (index-atom $encounter 3)
         (CPParticipantRelationOrganization (index-atom $encounter 6))) 0)
     false))

(= (C4RecoveryExpressionSourceInProof $source $proof)
   (if (CPShape $proof native-movement-proof-v1 5)
     (let* (($cut (index-atom $proof 1))
            ($movement (index-atom $proof 3))
            ($retained (if (CPShape $movement movement-formed 7)
              (index-atom $movement 6) ()))
            ($basis (if (CPShape $retained retained-alternatives-v3 3)
              (index-atom $retained 2) ())))
       (if (CPShape $basis continuation-basis-v3 6)
         (C4RecoveryExpressionSourceAmong $source
           (C4ModelRecoveryPossibilities $cut
             (CPFlourishingOrganizationV2 $cut (index-atom $basis 2))
             (CPParticipantRelationOrganization (index-atom $proof 4))) 0)
         false)) false))

(= (C4RecoveryExpressionOpeningsAt $possibilities $question $observation $i)
   (if (< $i (size-atom $possibilities))
     (let* (($possible (index-atom $possibilities $i))
            ($route (index-atom (index-atom $possible 7) 1))
            ($source (C4RecoveryExpressionSource $route))
            ($expression (c4-native-recovery-expression-v1 $source $route))
            ($rest (C4RecoveryExpressionOpeningsAt $possibilities $question $observation (+ $i 1))))
       (if (if (C4RecoveryExpressionValid $expression $question)
             (== (C4RecoveryExpressionRouteReturn $route) $observation) false)
         (cons-atom (participant-contribution
           (c4-native-recovery-expression-opening (index-atom $source 1))
           native-authority (index-atom $question 2)
           (lineage c4 prospective-native-limitation-expression (index-atom $source 1))
           (participant-relation-claim model-failure-expression unresolved $expression)
           candidate no-contact-no-movement-authority) $rest)
         $rest)) ()))
