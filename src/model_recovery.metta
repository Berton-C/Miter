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

; Inquiry is not a claim that its flourishing requirements are satisfied.
; This surface preserves the complete current compass, including identities
; with no established material relation, beside the exact simultaneous native
; readings. It supplies neither missing world evidence nor movement authority.
; Callers derive it from an independently validated, exact native proof.
(= (C4ReturnedInquiryEvidenceAt $participants $scope $contact-id $i)
   (if (< $i (size-atom $participants))
     (let* (($participant (index-atom $participants $i))
            ($rest (C4ReturnedInquiryEvidenceAt $participants $scope $contact-id (+ $i 1))))
       (if (if (CPShape $participant derived-participant-reading 9)
             (and (== (index-atom $participant 2) tool)
               (and (== (index-atom $participant 3) $scope)
                 (and (== (index-atom $participant 7) no-contact)
                   (and (== (index-atom $participant 8) no-movement-authority)
                        (CPShape (index-atom $participant 5) participant-relation-claim 4))))) false)
         (let* (($claim (index-atom $participant 5))
                ($evidence (index-atom $claim 3)))
           (if (if (== (index-atom $claim 2) unresolved)
                 (if (== (index-atom $claim 1) model-return-failure)
                   (if (C4RecoveryEvidenceValid $evidence)
                     (let $question (index-atom $evidence 1)
                       (and (== (index-atom $question 2) $scope)
                            (== (index-atom (index-atom $question 1) 1) $contact-id))) false)
                   (if (== (index-atom $claim 1) open-growth-request-returned)
                     (if (C4CapabilityReturnedEvidenceValid $evidence)
                       (let $descriptor (index-atom (index-atom $evidence 1) 1)
                         (and (== (index-atom $descriptor 3) $scope)
                              (== (index-atom $descriptor 4) (source-contact $contact-id)))) false)
                     false)) false)
             (cons-atom $evidence $rest) $rest))
         $rest)) ()))


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

; Returned alternatives can refine their one source inquiry into a comparison,
; not a selected operation. Only a prospective native admission marker enables
; this composition; historical proofs keep their original possibility family.
(= (C4ReturnedProposalEvidence $source $question $reading)
   (let $proposal (index-atom $reading 8)
     (c4-capability-proposal-evidence-v3 $source
       (index-atom $question 1) (index-atom $reading 1)
       (index-atom $reading 4) (index-atom $reading 5)
       (index-atom $proposal 2) (index-atom $proposal 3))))

(= (C4ComparisonExpectedAt $readings $source $question $i)
   (if (< $i (size-atom $readings))
     (let* (($reading (index-atom $readings $i))
            ($rest (C4ComparisonExpectedAt $readings $source $question (+ $i 1))))
       (if (== (index-atom (index-atom $reading 8) 1) proposed)
         (cons-atom (C4ReturnedProposalEvidence $source $question $reading) $rest)
         $rest)) ()))

(= (C4ComparisonSourceClaimsAt $claims $source $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (index-atom $claim 6))
            ($rest (C4ComparisonSourceClaimsAt $claims $source (+ $i 1))))
       (if (if (CPShape $evidence c4-capability-proposal-evidence-v3 8)
             (== (index-atom $evidence 1) $source) false)
         (cons-atom $claim $rest) $rest)) ()))

(= (C4ComparisonClaimEvidenceAt $claims $i)
   (if (< $i (size-atom $claims))
     (cons-atom (index-atom (index-atom $claims $i) 6)
       (C4ComparisonClaimEvidenceAt $claims (+ $i 1))) ()))

(= (C4ComparisonRelationClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (CPListAppend
         (if (or (CPShape $relation participant-proposed-relation 4)
               (or (CPShape $relation participant-supported-relation 4)
                   (CPShape $relation participant-relation-conflict 4)))
           (index-atom $relation 3)
           (if (CPShape $relation participant-proposed-relation 5)
             (index-atom $relation 4) ()))
         (C4ComparisonRelationClaimsAt $relations (+ $i 1)))) ()))

(= (C4ComparisonReturnedRoute $focus)
   (if (C4RecoveryEvidenceValid $focus)
     (c4-model-recovery-route-v1 (C4RecoveryBasis $focus) $focus)
     (if (C4CapabilityReturnedEvidenceValid $focus)
       (C4CapabilityReturnedRoute
         (index-atom (index-atom (index-atom $focus 1) 1) 1) $focus)
       no-returned-evidence-route)))

(= (C4ComparisonObservedAt $claims $question $focus $observation $i)
   (if (< $i (size-atom $claims))
     (let $claim (index-atom $claims $i)
       (if (if (C4RecoverySupportedReturnClaim $claim)
             (or
               (== (index-atom $claim 6)
                 (c4-returned-inquiry-result-v1 $question
                   (returned-inquiry-focus $focus) $observation))
               (== (index-atom $claim 6)
                 (c4-model-correction-result-v1 $focus $observation
                   candidate-return-not-world-evidence))) false)
         true (C4ComparisonObservedAt $claims $question $focus $observation (+ $i 1)))) false))

(= (C4ComparisonFocusPresentAt $claims $focus $i)
   (if (< $i (size-atom $claims))
     (let $claim (index-atom $claims $i)
       (if (== ((index-atom $claim 2) (index-atom $claim 4) (index-atom $claim 6))
               (tool unresolved $focus))
         true (C4ComparisonFocusPresentAt $claims $focus (+ $i 1)))) false))

(= (C4ComparisonBasisValid $basis $cut $claims)
   (if (CPShape $basis c4-returned-comparison-basis-v1 6)
     (let* (($source (index-atom $basis 1)) ($question (index-atom $basis 2))
            ($focus (index-atom $basis 3)) ($observed (index-atom $basis 4)))
       (if (and (C4ReturnedProposalSourceValid $source)
                (as_model_semantic_bound $question $observed))
         (==
           ((index-atom $question 2)
            (index-atom (index-atom $question 1) 1)
            (index-atom $source 3) (index-atom $source 4)
            (!= (C4ComparisonReturnedRoute $focus) no-returned-evidence-route)
            (C4ComparisonFocusPresentAt $claims $focus 0)
            (C4ComparisonObservedAt $claims $question $focus $observed 0)
            (index-atom $basis 5))
           ((index-atom $cut 3) (index-atom (index-atom $cut 1) 1)
            (index-atom $question 1) (index-atom $observed 8)
            true true true native-joined-inquiry-no-execution-authority)) false)) false))

(= (C4ComparisonMembersAt $possibilities $expected $source-route $i)
   (if (< $i (size-atom $possibilities))
     (let* (($p (index-atom $possibilities $i))
            ($rest (C4ComparisonMembersAt $possibilities $expected $source-route (+ $i 1))))
       (if (or (CPHas $p $expected 0)
               (== (index-atom $p 7) (consequence-route $source-route non-certifying)))
         (cons-atom $p $rest) $rest)) ()))

(= (C4ComparisonRequirementsAt $members $field $i $out)
   (if (< $i (size-atom $members))
     (C4ComparisonRequirementsAt $members $field (+ $i 1)
       (C4ContinuationJoinAt $out (index-atom (index-atom $members $i) $field) 0)) $out))

(= (C4ComparisonRetainOthersAt $possibilities $members $i)
   (if (< $i (size-atom $possibilities))
     (let* (($p (index-atom $possibilities $i))
            ($rest (C4ComparisonRetainOthersAt $possibilities $members (+ $i 1))))
       (if (CPHas $p $members 0) $rest (cons-atom $p $rest))) ()))

(= (C4ComparisonJoinBasis $possibilities $basis $cut $flourishing $relations $claims)
   (if (C4ComparisonBasisValid $basis $cut $claims)
     (let* (($source (index-atom $basis 1)) ($question (index-atom $basis 2))
            ($observed (index-atom $basis 4))
            ($expected-evidence (C4ComparisonExpectedAt
              (index-atom (index-atom $observed 9) 1) $source $question 0))
            ($source-claims (C4ComparisonSourceClaimsAt
              (C4CapabilityProposalClaims $relations) $source 0))
            ($actual-evidence (C4ComparisonClaimEvidenceAt $source-claims 0))
            ($expected (C4CapabilityProposalPossibilitiesAt $source-claims $cut $flourishing 0)))
       (if (and (> (size-atom $expected) 1)
             (and (== (size-atom $expected-evidence) (size-atom $actual-evidence))
               (and (CPSubset $expected-evidence $actual-evidence 0)
                    (CPSubset $expected $possibilities 0))))
         (let* (($members (C4ComparisonMembersAt $possibilities $expected
                   (C4ComparisonReturnedRoute (index-atom $basis 3)) 0))
                ($family (c4-returned-comparison-family-v1 $basis
                  (exact-member-possibilities $members)
                  all-members-retained-without-selection
                  no-new-contact-or-operation-authority))
                ($comparison (possible-movement (as_native_id c4-returned-comparison $family)
                  inquiry
                  (C4ComparisonRequirementsAt $members 3 0 ())
                  (C4ComparisonRequirementsAt $members 4 0 ())
                  (C4ComparisonRequirementsAt $members 5 0 ())
                  (C4ComparisonRequirementsAt $members 6 0 ())
                  (consequence-route (soul-formed-returned-proposal-comparison $family)
                    non-certifying) l2425-supported)))
           (cons-atom $comparison (C4ComparisonRetainOthersAt $possibilities $members 0)))
         $possibilities)) $possibilities))

(= (C4ReturnedComparisonJoinAt $possibilities $markers $cut $flourishing $relations $claims $i)
   (if (< $i (size-atom $markers))
     (let* (($claim (index-atom $markers $i))
            ($basis (index-atom $claim 6)))
       (C4ReturnedComparisonJoinAt
         (if (and (== (index-atom $claim 2) native-authority)
                  (== (index-atom $claim 4) unresolved))
           (C4ComparisonJoinBasis $possibilities $basis $cut $flourishing $relations $claims)
           $possibilities)
         $markers $cut $flourishing $relations $claims (+ $i 1))) $possibilities))

(= (C4ComparisonMarkersAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (if (CPShape $relation participant-proposed-relation 4)
             (== (index-atom $relation 1) returned-proposal-comparison) false)
         (index-atom $relation 3) (C4ComparisonMarkersAt $relations (+ $i 1)))) ()))

(= (C4ReturnedComparisonJoin $possibilities $cut $flourishing $relations)
   (let $markers (C4ComparisonMarkersAt (index-atom $relations 1) 0)
     (if (== (size-atom $markers) 0) $possibilities
       (C4ReturnedComparisonJoinAt $possibilities $markers $cut $flourishing $relations
         (C4ComparisonRelationClaimsAt (index-atom $relations 1) 0) 0))))
