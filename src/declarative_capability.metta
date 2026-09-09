; First mutable cognitive surface: bounded declarative MeTTa capabilities.
;
; A module is inert, provenance-bearing data until the same constitutive
; encounter that carries it forms its exact activation movement. The fixed
; interpreter can relate declared input relations to a possible movement; it
; cannot choose that movement, grant an effect, or evaluate arbitrary source.

(= (WHModuleContractValid $contract)
   (if (CPShape $contract capability-contract-v1 4)
     (let* (($requires (index-atom $contract 1))
            ($projects (index-atom $contract 2))
            ($route (index-atom $contract 3)))
       (and (CPShape $requires requires-relations 2)
        (and (is-expr (index-atom $requires 1))
         (and (> (size-atom (index-atom $requires 1)) 0)
          (and (CPUniq (index-atom $requires 1) 0 ())
           (and (CPShape $projects projects-movement 3)
            (and (CPHas (index-atom $projects 2) (inquiry undertaking) 0)
             (and (CPShape $route consequence-route 3)
                  (== (index-atom $route 2) non-certifying)))))))))
     false))

(= (WHModuleAuthorityValid $authority)
   (if (CPShape $authority capability-authority-v1 5)
     (==
       ((index-atom $authority 1) (index-atom $authority 2)
        (index-atom $authority 3) (index-atom $authority 4))
       ((permissions ()) (network-surfaces ())
        (credential-capabilities ()) (effect-classes (no-direct-effects))))
     false))

(= (WHModuleTrialsValid $trials $contract)
   (if (CPShape $trials independent-trials 3)
     (let* (($positive (index-atom $trials 1))
            ($negative (index-atom $trials 2))
            ($required (index-atom (index-atom $contract 1) 1))
            ($projected (index-atom (index-atom $contract 2) 1)))
       (==
         ((CPShape $positive declarative-trial 4)
          (index-atom $positive 2) (index-atom $positive 3)
          (CPShape $negative declarative-trial 4)
          (index-atom $negative 2) (index-atom $negative 3))
         (true (relations $required) (expect $projected)
          true (relations ()) (expect no-output))))
     false))

; declarative-capability-module-v1:
; id version interface state purpose pressure contract authority reversibility
; tests memory provenance human-approval standing
(= (WHModuleValid $module)
   (if (CPShape $module declarative-capability-module-v1 15)
     (let* (($contract (index-atom $module 7))
            ($authority (index-atom $module 8))
            ($tests (index-atom $module 10)))
       (==
         ((CPShape (index-atom $module 3) interface-version 2)
          (index-atom $module 4)
          (WHModuleContractValid $contract)
          (WHModuleAuthorityValid $authority)
          (index-atom $module 9)
          (WHModuleTrialsValid $tests $contract)
          (CPShape (index-atom $module 11) memory-scopes 2)
          (CPShape (index-atom $module 12) module-provenance 3)
          (index-atom $module 13) (index-atom $module 14))
         (true stateless-v1 true true hot-rollback-previous-version true
          true true no-new-external-reach candidate-not-self-certifying)))
     false))

(= (WHInterpretRelations $module $relations)
   (if (WHModuleValid $module)
     (let* (($contract (index-atom $module 7))
            ($required (index-atom (index-atom $contract 1) 1))
            ($projected (index-atom (index-atom $contract 2) 1)))
       (if (CPSubset $required $relations 0) $projected no-output))
     no-output))

(= (WHModuleTrial $module)
   (if (WHModuleValid $module)
     (let* (($tests (index-atom $module 10))
            ($positive (index-atom $tests 1))
            ($negative (index-atom $tests 2))
            ($positive-result (WHInterpretRelations $module
              (index-atom (index-atom $positive 2) 1)))
            ($negative-result (WHInterpretRelations $module
              (index-atom (index-atom $negative 2) 1)))
            ($positive-expected (index-atom (index-atom $positive 3) 1))
            ($negative-expected (index-atom (index-atom $negative 3) 1)))
       (declarative-capability-trial-v1 (index-atom $module 1)
         (index-atom $module 2)
         (positive-case (index-atom $positive 1) $positive-result
           $positive-expected (== $positive-result $positive-expected))
         (negative-case (index-atom $negative 1) $negative-result
           $negative-expected (== $negative-result $negative-expected))
         independent-native-interpreter-no-provider))
     (declarative-capability-trial-held malformed-module)))

(= (WHModuleTrialValid $trial $module)
   (if (and (WHModuleValid $module)
            (CPShape $trial declarative-capability-trial-v1 6))
     (==
       ((index-atom $trial 1) (index-atom $trial 2)
        (index-atom (index-atom $trial 3) 4)
        (index-atom (index-atom $trial 4) 4) (index-atom $trial 5))
       ((index-atom $module 1) (index-atom $module 2) true true
        independent-native-interpreter-no-provider))
     false))

(= (WHCandidateEvidenceModulesAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (WHModuleValid $evidence)
         (cons-atom $evidence
           (WHCandidateEvidenceModulesAt $claims (+ $i 1)))
         (WHCandidateEvidenceModulesAt $claims (+ $i 1))))
     ()))

(= (WHCandidateModulesAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
                (== (index-atom $relation 1)
                  declarative-capability-candidate))
         (CPListAppend
           (WHCandidateEvidenceModulesAt (index-atom $relation 3) 0)
           (WHCandidateModulesAt $relations (+ $i 1)))
         (WHCandidateModulesAt $relations (+ $i 1))))
     ()))

(= (WHCandidateModules $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (WHCandidateModulesAt (index-atom $participant-relations 1) 0) ()))

(= (WHModuleActivationPossibilitiesAt $modules $cut $flourishing $i)
   (if (< $i (size-atom $modules))
     (let* (($module (index-atom $modules $i))
            ($trial (WHModuleTrial $module)))
       (if (WHModuleTrialValid $trial $module)
         (cons-atom
           (possible-movement
             (workshop-activate (index-atom $module 1)
               (index-atom $module 2)) inquiry
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (CPBeneficialFlourishingValues $flourishing)
             (consequence-route
               (declarative-hot-activation (index-atom $module 1)
                 (index-atom $module 2) $trial) non-certifying)
             l2425-supported)
           (WHModuleActivationPossibilitiesAt $modules $cut $flourishing
             (+ $i 1)))
         (WHModuleActivationPossibilitiesAt $modules $cut $flourishing
           (+ $i 1))))
     ()))

(= (WHRollbackEvidenceAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (CPShape $evidence declarative-capability-rollback-v1 6)
         (cons-atom $evidence (WHRollbackEvidenceAt $claims (+ $i 1)))
         (WHRollbackEvidenceAt $claims (+ $i 1))))
     ()))

(= (WHRollbackRequestsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
                (== (index-atom $relation 1)
                  declarative-capability-rollback-request))
         (CPListAppend (WHRollbackEvidenceAt (index-atom $relation 3) 0)
           (WHRollbackRequestsAt $relations (+ $i 1)))
         (WHRollbackRequestsAt $relations (+ $i 1))))
     ()))

(= (WHRollbackRequests $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (WHRollbackRequestsAt (index-atom $participant-relations 1) 0) ()))

(= (WHRollbackPossibilitiesAt $requests $cut $flourishing $i)
   (if (< $i (size-atom $requests))
     (let $request (index-atom $requests $i)
       (cons-atom
         (possible-movement
           (workshop-rollback (index-atom $request 1)
             (index-atom $request 2)) inquiry
           (CPNativeRequirementRelations $cut)
           (CPNativeRequirementDistinctions $cut)
           (CPNativeRequirementInterfaces $cut)
           (CPBeneficialFlourishingValues $flourishing)
           (consequence-route (declarative-hot-rollback $request)
             non-certifying) l2425-supported)
         (WHRollbackPossibilitiesAt $requests $cut $flourishing (+ $i 1))))
     ()))

(= (WHCapabilityTransitionPossibilities $cut $flourishing
      $participant-relations)
   (CPListAppend
     (WHModuleActivationPossibilitiesAt
       (WHCandidateModules $participant-relations) $cut $flourishing 0)
     (WHRollbackPossibilitiesAt
       (WHRollbackRequests $participant-relations) $cut $flourishing 0)))

; Active state carries the immediately previous verified version, so rollback
; never depends on source files or an unordered "latest" query.
(= (WHActiveCapabilityValid $active)
   (if (CPShape $active active-capability-module 6)
     (and (CPShape (index-atom $active 1) scope 4)
      (and (WHModuleValid (index-atom $active 2))
       (and (CPShape (index-atom $active 3) activation-reference 2)
        (and (or (== (index-atom $active 4) no-prior-active-version)
                 (WHModuleValid (index-atom $active 4)))
             (== (index-atom $active 5)
               live-declarative-data-no-source-eval-no-effect-authority)))))
     false))

(= (WHActiveRows $scope $module-id)
   (collapse (match &assistant_state
     (active-capability-module $scope $module $activation $prior $standing)
     (if (== (index-atom $module 1) $module-id)
       (active-capability-module $scope $module $activation $prior $standing)
       (empty)))))

(= (WHActivateModule $scope $module $activation-id)
   (let* (($rows (WHActiveRows $scope (index-atom $module 1)))
          ($prior (if (== (size-atom $rows) 1)
            (index-atom (index-atom $rows 0) 2) no-prior-active-version)))
     (if (> (size-atom $rows) 1)
       (hot-activation-held duplicate-active-module-state)
       (if (== (size-atom $rows) 1)
         ; Keep replacement in the same reduction that names the exact old
         ; row. The pinned runtime does not preserve remove-atom's mutation
         ; when it is hidden behind the earlier recursive helper.
         (let* (($old (index-atom $rows 0))
                ($removed (remove-atom &assistant_state $old))
                ($active (active-capability-module $scope $module
                  (activation-reference $activation-id) $prior
                  live-declarative-data-no-source-eval-no-effect-authority))
                ($added (add-atom &assistant_state $active)))
           (hot-capability-activated $module $prior $active))
         (let* (($active (active-capability-module $scope $module
                  (activation-reference $activation-id) no-prior-active-version
                  live-declarative-data-no-source-eval-no-effect-authority))
                ($added (add-atom &assistant_state $active)))
           (hot-capability-activated $module no-prior-active-version $active))))))

(= (WHRollbackModule $scope $request $activation-id)
   (let* (($module-id (index-atom $request 1))
          ($expected-version (index-atom $request 2))
          ($rows (WHActiveRows $scope $module-id)))
     (if (!= (size-atom $rows) 1)
       (hot-rollback-held active-version-unavailable)
       (let* (($active (index-atom $rows 0))
              ($current (index-atom $active 2))
              ($prior (index-atom $active 4)))
         (if (!= (index-atom $current 2) $expected-version)
           (hot-rollback-held expected-version-mismatch)
           (let* (($removed (remove-atom &assistant_state $active))
                  ($restored (if (WHModuleValid $prior)
                    (active-capability-module $scope $prior
                      (activation-reference $activation-id)
                      no-prior-active-version
                      live-declarative-data-no-source-eval-no-effect-authority)
                    no-active-version-after-rollback))
                  ($added (if (WHModuleValid $prior)
                    (add-atom &assistant_state $restored) rollback-deactivated)))
             (hot-capability-rolled-back $current $prior $restored)))))))

(= (WHMovementId $movement)
   (if (CPShape $movement movement-formed 7) (index-atom $movement 2)
     no-formed-movement))

(= (WHFindModuleForMovementAt $modules $movement-id $i)
   (if (< $i (size-atom $modules))
     (let $module (index-atom $modules $i)
       (if (== $movement-id
             (workshop-activate (index-atom $module 1)
               (index-atom $module 2)))
         $module (WHFindModuleForMovementAt $modules $movement-id (+ $i 1))))
     no-matching-module))

(= (WHFindRollbackForMovementAt $requests $movement-id $i)
   (if (< $i (size-atom $requests))
     (let $request (index-atom $requests $i)
       (if (== $movement-id
             (workshop-rollback (index-atom $request 1)
               (index-atom $request 2)))
         $request
         (WHFindRollbackForMovementAt $requests $movement-id (+ $i 1))))
     no-matching-rollback))

(= (WHTransitionFromEncounter $encounter $contact-id)
   (if (CPShape $encounter constitutive-encounter 7)
     (let* (($scope (index-atom (index-atom $encounter 1) 3))
            ($participants (index-atom $encounter 6))
            ($relations (CPParticipantRelationOrganization $participants))
            ($movement-id (WHMovementId (index-atom $encounter 5)))
            ($module (WHFindModuleForMovementAt
              (WHCandidateModules $relations) $movement-id 0)))
       (if (WHModuleValid $module)
         (let* (($trial (WHModuleTrial $module))
                ($result (if (WHModuleTrialValid $trial $module)
                  (WHActivateModule $scope $module $contact-id)
                  (hot-activation-held native-trial-failed))))
           (workshop-transition-v1 activate $contact-id $scope $module
             $trial $result candidate-trial-admission-distinct))
         (let $request (WHFindRollbackForMovementAt
             (WHRollbackRequests $relations) $movement-id 0)
           (if (CPShape $request declarative-capability-rollback-v1 6)
             (let $result (WHRollbackModule $scope $request $contact-id)
               (workshop-transition-v1 rollback $contact-id $scope $request
                 no-candidate-trial $result
                 prior-version-restored-with-history-retained))
             no-workshop-transition))))
     (workshop-transition-held malformed-encounter)))

(= (WHRollbackRequestValid $request)
   (if (CPShape $request declarative-capability-rollback-v1 6)
     (and (CPShape (index-atom $request 4) module-provenance 3)
          (== (index-atom $request 5) no-new-external-reach))
     false))

(= (WHActivationResultValid $scope $subject $contact-id $result)
   (if (CPShape $result hot-capability-activated 4)
     (let* (($module (index-atom $result 1))
            ($prior (index-atom $result 2))
            ($active (index-atom $result 3)))
       (and (== $module $subject)
        (and (or (== $prior no-prior-active-version)
                 (WHModuleValid $prior))
         (and (WHActiveCapabilityValid $active)
          (==
            ((index-atom $active 1) (index-atom $active 2)
             (index-atom $active 3) (index-atom $active 4))
            ($scope $subject (activation-reference $contact-id) $prior))))))
     (== $result
       (hot-activation-held duplicate-active-module-state))))

(= (WHRollbackResultValid $scope $request $contact-id $result)
   (if (CPShape $result hot-capability-rolled-back 4)
     (let* (($current (index-atom $result 1))
            ($prior (index-atom $result 2))
            ($restored (index-atom $result 3)))
       (and (WHModuleValid $current)
        (and (== ((index-atom $current 1) (index-atom $current 2))
                 ((index-atom $request 1) (index-atom $request 2)))
         (if (WHModuleValid $prior)
           (and (WHActiveCapabilityValid $restored)
            (==
              ((index-atom $restored 1) (index-atom $restored 2)
               (index-atom $restored 3) (index-atom $restored 4))
              ($scope $prior (activation-reference $contact-id)
               no-prior-active-version)))
           (and (== $prior no-prior-active-version)
                (== $restored no-active-version-after-rollback))))))
     (or (== $result (hot-rollback-held active-version-unavailable))
         (== $result (hot-rollback-held expected-version-mismatch)))))

(= (WHHistoryPayloadValid $payload)
   (if (CPShape $payload workshop-transition-v1 8)
     (let* (($operation (index-atom $payload 1))
            ($contact-id (index-atom $payload 2))
            ($scope (index-atom $payload 3))
            ($subject (index-atom $payload 4))
            ($trial (index-atom $payload 5))
            ($result (index-atom $payload 6)))
       (and (CPShape $scope scope 4)
        (if (== $operation activate)
          (and (WHModuleValid $subject)
            (and (WHModuleTrialValid $trial $subject)
              (WHActivationResultValid $scope $subject $contact-id $result)))
          (if (== $operation rollback)
            (and (WHRollbackRequestValid $subject)
             (and (== $trial no-candidate-trial)
                  (WHRollbackResultValid $scope $subject $contact-id $result)))
            false))))
     false))

(= (WHHistoryResultSupportsActive $payload $active)
   (if (and (CPShape $payload workshop-transition-v1 8)
            (CPShape (index-atom $payload 6) hot-capability-activated 4))
     (== (index-atom (index-atom $payload 6) 3) $active)
     (if (and (CPShape $payload workshop-transition-v1 8)
              (CPShape (index-atom $payload 6)
                hot-capability-rolled-back 4))
       (== (index-atom (index-atom $payload 6) 3) $active)
       false)))

(= (WHActiveSupportedByHistoryAt $active $history $i)
   (if (< $i (size-atom $history))
     (let $row (index-atom $history $i)
       (if (CPShape $row assistant-history 5)
         (if (== (index-atom $row 1) workshop)
           (if (== (index-atom $row 3) (index-atom $active 1))
             (if (WHHistoryResultSupportsActive
                    (index-atom $row 4) $active)
               true
               (WHActiveSupportedByHistoryAt $active $history (+ $i 1)))
             (WHActiveSupportedByHistoryAt $active $history (+ $i 1)))
           (WHActiveSupportedByHistoryAt $active $history (+ $i 1)))
         (WHActiveSupportedByHistoryAt $active $history (+ $i 1))))
     false))

(= (WHCapabilityStateHistorySupportedAt $capabilities $history $i)
   (if (< $i (size-atom $capabilities))
     (and (WHActiveSupportedByHistoryAt
            (index-atom $capabilities $i) $history 0)
          (WHCapabilityStateHistorySupportedAt
            $capabilities $history (+ $i 1)))
     true))

(= (WHActiveCapabilitiesForScope $scope)
   (collapse (match &assistant_state
     (active-capability-module $scope $module $activation $prior $standing)
     (active-capability-module $scope $module $activation $prior $standing))))

(= (WHActiveCapabilityPossibilitiesAt $rows $cut $flourishing $relations $i)
   (if (< $i (size-atom $rows))
     (let* (($active (index-atom $rows $i))
            ($module (index-atom $active 2))
            ($contract (index-atom $module 7))
            ($available (CPNativeRequirementRelations $cut))
            ($projected (WHInterpretRelations $module $available)))
       (if (!= $projected no-output)
         (cons-atom
           (possible-movement $projected
             (index-atom (index-atom $contract 2) 2)
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (CPBeneficialFlourishingValues $flourishing)
             (index-atom $contract 3) l2425-supported)
           (WHActiveCapabilityPossibilitiesAt $rows $cut $flourishing
             $relations (+ $i 1)))
         (WHActiveCapabilityPossibilitiesAt $rows $cut $flourishing
           $relations (+ $i 1))))
     ()))

(= (WHActiveCapabilityPossibilities $cut $flourishing $relations)
   (WHActiveCapabilityPossibilitiesAt
     (WHActiveCapabilitiesForScope (index-atom $cut 3))
     $cut $flourishing $relations 0))
