; AMA-1.2 R3 persistent assistant integration for the native authority joint.
; This replaces the contact step; it does not run beside the v1 cognition path.

(= (AR2MovementSummaryValid $summary)
   (or (CPShape $summary movement-standing 4)
     (or (CPShape $summary movement-standing 3)
         (CPShape $summary movement-standing 2))))

(= (AR2ProbeBasisMatchesReference $basis $reference)
   (if (and (CPShape $reference movement-reference 5)
         (and (== (index-atom $reference 2) formed)
              (== (index-atom $reference 3) inquiry)))
     (and (M24ProbeBasisValid $basis)
       (and (== (index-atom $basis 2) (index-atom $reference 4))
            (== (index-atom $basis 3)
              (source-cut (index-atom $reference 1)))))
     (CPShape $basis probe-basis-unresolved 2)))

(= (AR2EncounterHistoryPayloadValid $payload)
   (let* (($payload-valid (or (CPShape $payload encounter-incorporated-v2 5)
                              (CPShape $payload encounter-incorporated-v3 6)))
          ($cut-valid (if $payload-valid
            (CPShape (index-atom $payload 1) cut-of 3) false))
          ($movement-valid (if $payload-valid
            (AR2MovementSummaryValid (index-atom $payload 2)) false))
          ($joint-valid (if $payload-valid
            (CP2AuthorityJointValid (index-atom $payload 4)) false)))
     (and $payload-valid
       (and $cut-valid
        (and $movement-valid
         (and $joint-valid
          (and (if (CPShape $payload encounter-incorporated-v3 6)
                 (AR2ProbeBasisMatchesReference (index-atom $payload 5)
                   (CP2JointMovementReference (index-atom $payload 4))) true)
          (if (CPShape (index-atom $payload 4)
                authority-participation-joint-v2 11)
            (let* (($summary (index-atom $payload 2))
                   ($reference (CP2JointMovementReference
                     (index-atom $payload 4))))
              (if (CPShape $summary movement-standing 4)
                (and (== (index-atom $reference 2) formed)
                 (and (== (index-atom $reference 3) (index-atom $summary 3))
                      (== (index-atom $reference 4) (index-atom $summary 2))))
                true)) true))))))))

(= (AR2ConsequenceHistoryPayloadValid $payload)
   (if (CPShape $payload consequence-incorporation-v3 4)
     (let* (($next (index-atom $payload 1))
            ($next-valid (CPShape $next next-constitutive-organization-v3 3)))
       (if $next-valid
         (let* (($encounter (index-atom $next 1))
                ($transition (index-atom $next 2))
                ($transition-valid (M24DevelopmentalTransitionValid $transition))
                ($consequence (if $transition-valid
                  (index-atom $transition 4) ()))
                ($scope (if $transition-valid
                  (index-atom $transition 5) ()))
                ($expected-participants (if $transition-valid
                  (AR2ConsequenceParticipants $scope
                    (index-atom $transition 2) $consequence) ()))
                ($expected-readings (if $transition-valid
                  (CPParticipantAt (index-atom $encounter 1)
                    $expected-participants 0) ()))
                ($retained-readings (if
                  (CPShape $encounter constitutive-encounter 7)
                  (index-atom (index-atom $encounter 6) 2) ())))
           (and (CPShape $encounter constitutive-encounter 7)
            (and $transition-valid
             (and (CPDRelationKnown (index-atom $encounter 1)
                    m24-consequence-developmental-grounding)
              (and (== (index-atom (index-atom $encounter 1) 1)
                     (index-atom (index-atom $transition 6) 1))
               (and (== (index-atom $payload 2)
                      (prior-movement (index-atom $consequence 2)))
                (and (== (index-atom $payload 3)
                       (returned-evidence (index-atom $consequence 12)))
                     (CPSubset $expected-readings $retained-readings 0))))))))
         false))
     false))

(= (AR2PayloadHead $payload $head)
   (and (is-expr $payload)
     (and (> (size-atom $payload) 0)
          (== (index-atom $payload 0) $head))))

(= (AR2HistoryValid $row)
   (let* (($row-valid (CPShape $row assistant-history 5))
          ($is-encounter (if $row-valid
            (== (index-atom $row 1) encounter) false)))
     (if $is-encounter
       (let* (($scope-valid (CPShape (index-atom $row 3) scope 4))
              ($payload-valid
                (AR2EncounterHistoryPayloadValid (index-atom $row 4))))
         (and $scope-valid $payload-valid))
       (if (and $row-valid (== (index-atom $row 1) consequence))
         (let $payload (index-atom $row 4)
           (if (AR2PayloadHead $payload consequence-incorporation-v3)
             (and (AR2ConsequenceHistoryPayloadValid $payload)
               (== (index-atom (index-atom (index-atom $payload 1) 2) 5)
                 (index-atom $row 3)))
             (ARHistoryValid $row)))
         (ARHistoryValid $row)))))

(= (AR2AllHistoryValid $rows $i)
   (if (< $i (size-atom $rows))
     (and (AR2HistoryValid (index-atom $rows $i))
          (AR2AllHistoryValid $rows (+ $i 1))) true))

(= (AR2MovementBasis $movement)
   (if (CPShape $movement movement-formed 7)
     (let $retained (index-atom $movement 6)
       (if (CPShape $retained retained-alternatives-v3 3)
         (index-atom $retained 2)
         (CPMovementBasisV2 $movement)))
     no-continuation-basis))

(= (AR2MovementConstitutivelyConsistent $cut $movement)
   (let $basis (AR2MovementBasis $movement)
     (if (CPShape $basis continuation-basis-v3 6)
       (let* (($base-cut (CPBaseCutWithoutParticipantRelations $cut))
              ($encounter (M25ConstitutiveEncounter $base-cut
                (index-atom $basis 1) (index-atom $basis 2)
                (index-atom $basis 3) (index-atom (index-atom $basis 4) 1)
                (index-atom $basis 5))))
         (and (CPShape $encounter constitutive-encounter 7)
              (== (index-atom $encounter 5) $movement)))
       (ARMovementConstitutivelyConsistent $cut $movement))))

(= (AR2ActiveValid $active)
   (and (CPShape $active active-organization 4)
     (and (CPShape (index-atom $active 1) scope 4)
      (and (CPCutValid (index-atom $active 2))
       (and (ARMovementValid (index-atom $active 3))
            (AR2MovementConstitutivelyConsistent
              (index-atom $active 2) (index-atom $active 3)))))))

(= (AR2RestoreValid $state-wrapper $history-wrapper $state $history)
   (and (ARSpacesEmpty)
     (and (CPShape $state-wrapper state 2)
      (and (CPShape $history-wrapper history 2)
       (and (is-expr $state)
        (and (is-expr $history)
         (and (CPUniq $state 0 ())
          (and (CPUniq $history 0 ())
           (and (ARAllValid $state AR2ActiveValid 0)
            (and (AR2AllHistoryValid $history 0)
             (and (ARStateScopesUnique $state 0 ())
                  (ARHistoryKeysUnique $history 0 ()))))))))))))

(= (AssistantRestoreV2 $snapshot)
   (if (CPShape $snapshot assistant-snapshot 3)
     (let* (($state-wrapper (index-atom $snapshot 1))
            ($history-wrapper (index-atom $snapshot 2))
            ($state (index-atom $state-wrapper 1))
            ($history (index-atom $history-wrapper 1)))
       (if (AR2RestoreValid $state-wrapper $history-wrapper $state $history)
         (let* (($s (ARAddAll &assistant_state $state 0))
                ($h (ARAddAll &assistant_history $history 0)))
           assistant-state-restored-v2)
         assistant-restore-rejected-v2))
     assistant-restore-rejected-v2))

(= (AR2EncounterSummary $encounter $joint)
   (let* (($cut (index-atom $encounter 1))
          ($movement (AREncounterMovement $encounter)))
     (encounter-incorporated-v3 (index-atom $cut 1)
       (ARMovementSummary $movement) (index-atom $cut 12) $joint
       (M24ProbeBasisForMovement $movement))))

(= (AR2GroundedEncounterValid $grounded)
   (let $shape-valid (CPShape $grounded authority-grounded-encounter 3)
     (if $shape-valid
       (CP2AuthorityJointMatchesEncounter (index-atom $grounded 1)
         (index-atom $grounded 2)) false)))

; The developmental carrier used by a returned consequence must be the one
; retained for the exact active cut and movement. No latest-row convention and
; no merely similar contact may substitute for that lineage.
(= (AR2EncounterPayloadsForScope $scope)
   (collapse (match &assistant_history
     (assistant-history encounter $id $scope $payload) $payload)))

(= (AR2EncounterPayloadMatchesMovement $payload $cut $movement)
   (if (AR2EncounterHistoryPayloadValid $payload)
     (let $joint (index-atom $payload 4)
       (and (== (CP2JointMovementReference $joint)
              (CP2MovementReference $cut $movement))
            (== (index-atom $payload 2) (ARMovementSummary $movement))))
     false))

(= (AR2DevelopmentalMatchesAt $payloads $cut $movement $i $out)
   (if (< $i (size-atom $payloads))
     (let $payload (index-atom $payloads $i)
       (if (AR2EncounterPayloadMatchesMovement $payload $cut $movement)
         (let* (($joint (index-atom $payload 4))
                ($m24-organization (index-atom $joint 3))
                ($developmental
                  (CP2M24DevelopmentalOrganization $m24-organization)))
           (AR2DevelopmentalMatchesAt $payloads $cut $movement (+ $i 1)
             (cons-atom $developmental $out)))
         (AR2DevelopmentalMatchesAt $payloads $cut $movement (+ $i 1) $out)))
     $out))

(= (AR2DevelopmentalForMovement $scope $cut $movement)
   (let* (($payloads (AR2EncounterPayloadsForScope $scope))
          ($matches (AR2DevelopmentalMatchesAt $payloads $cut $movement 0 ())))
     (if (== (size-atom $matches) 1)
       (index-atom $matches 0)
       (m24-developmental-organization-unresolved
         missing-or-ambiguous-active-movement-lineage))))

(= (AR2ConsequenceParticipants $scope $evolved $consequence)
   (let* (($carrier (index-atom $evolved 1))
          ($contact-id (index-atom $carrier 1))
          ($consequence-id (index-atom $consequence 1))
          ($developmental-reference
            (m24-developmental-reference $contact-id
              (index-atom $evolved 3) (index-atom $evolved 13)))
          ($consequence-reference
            (returned-consequence-reference $consequence-id
              (index-atom $consequence 2) (index-atom $consequence 4)
              (index-atom $consequence 12))))
     ((participant-contribution
         (m24-consequence-developmental-participation $consequence-id)
         native-authority $scope
         (lineage Inquiry-24-developmental-consequence $contact-id)
         (participant-relation-claim m24-consequence-developmental-grounding
           support (m24-developmental-evidence $developmental-reference))
         supported no-contact-no-movement-authority)
      (participant-contribution
         (returned-consequence-participation $consequence-id)
         returned-contact $scope
         (lineage returned-consequence $consequence-id)
         (participant-relation-claim m24-consequence-developmental-grounding
           support (returned-contact-evidence $consequence-reference))
         supported no-contact-no-movement-authority))))

(= (AR2ReconstituteAfterConsequence $scope $cut $movement $consequence)
   (let* (($basis (AR2MovementBasis $movement))
          ($prior (AR2DevelopmentalForMovement $scope $cut $movement))
          ($probe-basis (M24ProbeBasisForMovement $movement))
          ($next-cut (CPNextCutV2 $cut $consequence))
          ($base-next-cut (CPBaseCutWithoutParticipantRelations $next-cut))
          ($transition (M24DevelopmentalTransition $prior $probe-basis
            $consequence $scope $base-next-cut)))
     (if (and (or (CPShape $basis continuation-basis-v2 5)
                  (CPShape $basis continuation-basis-v3 6))
           (and (M24DevelopmentalTransitionValid $transition)
                (CPCutValid $base-next-cut)))
       (let* (($evolved (index-atom $transition 2))
              ($flourishing-views (CPListAppend (index-atom $basis 2)
                (index-atom (index-atom $consequence 10) 1)))
              ($participant-source (CPListAppend (index-atom $basis 3)
                (AR2ConsequenceParticipants $scope $evolved $consequence)))
              ($next (M25ConstitutiveEncounter $base-next-cut
                (index-atom $basis 1) $flourishing-views $participant-source
                (index-atom (index-atom $basis 4) 1) $evolved)))
         (if (and (CPShape $next constitutive-encounter 7)
                  (CPDRelationKnown (index-atom $next 1)
                    m24-consequence-developmental-grounding))
           (next-constitutive-organization-v3 $next $transition)
           (next-constitutive-organization-unresolved
             developmental-participation-not-causal)))
       (next-constitutive-organization-unresolved
         missing-basis-developmental-lineage-or-valid-transition))))

(= (AR2IncorporateConsequenceV3 $id $scope $cut $movement $consequence)
   (let $next-organization
     (AR2ReconstituteAfterConsequence $scope $cut $movement $consequence)
     (if (CPShape $next-organization next-constitutive-organization-v3 3)
       (let* (($encounter (index-atom $next-organization 1))
              ($next-cut (index-atom $encounter 1))
              ($next-movement (AREncounterMovement $encounter))
              ($state (ARReplaceActive $scope $next-cut $next-movement))
              ($history (if (== $state assistant-active-replaced)
                (ARRecord consequence $id $scope
                  (consequence-incorporation-v3 $next-organization
                    (prior-movement (index-atom $consequence 2))
                    (returned-evidence (index-atom $consequence 12))))
                state-not-recorded)))
         (if (== $history assistant-history-recorded)
           (assistant-consequence-incorporated $id $next-organization)
           (assistant-consequence-held $id $history)))
       (assistant-consequence-held $id $next-organization))))

(= (AssistantConsequenceV2 $scope $consequence)
   (if (and (CPShape $scope scope 4) (CPConsequenceValid $consequence))
     (let* (($id (index-atom $consequence 1))
            ($active (ARActiveRows $scope)))
       (if (ARHistoryHas consequence $id) (assistant-consequence-duplicate $id)
         (if (!= (size-atom $active) 1)
           (assistant-consequence-held $id active-cut-unavailable)
           (let* (($organization (index-atom $active 0))
                  ($cut (index-atom $organization 2))
                  ($movement (index-atom $organization 3)))
             (if (ARConsequenceMovementMatches $movement $consequence)
               (if (CPConsequenceV2Valid $consequence)
                 (AR2IncorporateConsequenceV3 $id $scope $cut $movement
                   $consequence)
                 (ARIncorporateConsequenceV1 $id $scope $cut $movement
                   $consequence))
               (assistant-consequence-held $id movement-link-mismatch))))))
     (assistant-consequence-rejected malformed-scope-or-consequence)))

(= (AR2IncorporateGrounded $id $scope $grounded)
   (let $grounded-valid (AR2GroundedEncounterValid $grounded)
     (if $grounded-valid
       (let* (($joint (index-atom $grounded 1))
              ($encounter (index-atom $grounded 2))
              ($cut (index-atom $encounter 1))
              ($movement (AREncounterMovement $encounter))
              ($state (ARReplaceActive $scope $cut $movement))
              ($summary (AR2EncounterSummary $encounter $joint))
              ($history (if (== $state assistant-active-replaced)
                (ARRecord encounter $id $scope $summary)
                state-not-recorded)))
         (if (== $history assistant-history-recorded)
           (assistant-contact-incorporated $id $encounter)
           (assistant-contact-held $id $history)))
       (assistant-contact-held $id $grounded))))

(= (AssistantEncounterV2 $contact)
   (let $contact-valid (CPContactValid $contact)
     (if $contact-valid
       (let* (($id (index-atom $contact 1))
              ($scope (CPContactScope $contact))
              ($prior (ARActiveRows $scope))
              ($duplicate (ARHistoryHas encounter $id)))
         (if $duplicate (assistant-contact-duplicate $id)
           (if (> (size-atom $prior) 1) (assistant-contact-held $id state-conflict)
             (let* (($predecessor (if (== (size-atom $prior) 1)
                      (index-atom (index-atom $prior 0) 2) ()))
                    ($grounded (CP2Encounter $contact $predecessor)))
               (AR2IncorporateGrounded $id $scope $grounded)))))
       (assistant-contact-rejected malformed-or-unauthorized-contact))))

(= (ACBoundEncounterV2 $binding $contact)
   (if (ACScopeBindingValid $binding $contact)
     (let* (($scope (CPContactScope $contact))
            ($continuity (ACContinuityForScope $scope))
            ($semantic (ASSemanticForScope $scope)))
       (if (== $continuity (continuity-standing conflicting-sources-for-scope))
         (assistant-contact-rejected conflicting-continuity-sources)
         (let* (($continuity-contact (if (ACContinuityValid $continuity)
                  (ACContactWithContinuity $contact $continuity) $contact))
                ($effective-contact (ASContactWithSemantic $continuity-contact $semantic))
                ($result (AssistantEncounterV2 $effective-contact)))
           (if (CPShape $effective-contact semantic-contact-held 2)
             (assistant-contact-held (index-atom $contact 1) $effective-contact)
             (if (CPShape $result assistant-contact-incorporated 3)
               (let* (($binding-history (ARRecord scope-binding
                         (index-atom $contact 1) $scope $binding))
                      ($continuity-history (ARRecord continuity
                         (index-atom $contact 1) $scope $continuity))
                      ($semantic-history (ARRecord semantic
                         (index-atom $contact 1) $scope
                         (ASSemanticStandingSummary $semantic))))
                 (if (and (CPHas $binding-history
                           (assistant-history-recorded assistant-history-duplicate) 0)
                      (and (CPHas $continuity-history
                             (assistant-history-recorded assistant-history-duplicate) 0)
                           (CPHas $semantic-history
                             (assistant-history-recorded assistant-history-duplicate) 0)))
                   $result
                   (assistant-contact-held (index-atom $contact 1)
                     scope-continuity-or-semantic-history-failed)))
               $result)))))
     (assistant-contact-rejected stable-identity-scope-mismatch)))

(= (AssistantInputV2 $input)
   (if (CPShape $input assistant-input 3)
     (if (== (index-atom $input 1) contact)
       (AssistantEncounterV2 (index-atom $input 2))
       (assistant-input-rejected unknown-input-kind))
     (if (CPShape $input assistant-input 4)
       (if (== (index-atom $input 1) contact)
         (ACBoundEncounterV2 (index-atom $input 2) (index-atom $input 3))
         (if (== (index-atom $input 1) consequence)
           (AssistantConsequenceV2 (index-atom $input 2) (index-atom $input 3))
           (assistant-input-rejected unknown-input-kind)))
       (assistant-input-rejected malformed-input))))

(= (AssistantProcessAtV2 $inputs $i)
   (if (< $i (size-atom $inputs))
     (cons-atom (AssistantInputV2 (index-atom $inputs $i))
       (AssistantProcessAtV2 $inputs (+ $i 1))) ()))

(= (AssistantCycleStepV2 $inputs)
   (if (is-expr $inputs)
     (assistant-cycle-step (AssistantProcessAtV2 $inputs 0) (AssistantSnapshot))
     (assistant-cycle-step ((assistant-input-rejected malformed-batch))
       (AssistantSnapshot))))

(= (AssistantCycleWithV2 $root $idle $interval $base $cap
      $control-reader $input-reader $checkpoint-writer $waiter $recorder $effect-writer)
   (let $control ($control-reader $root)
     (if (ARControlValid $control)
       (if (== (index-atom $control 1) panic)
         (let $record ($recorder $root assistant-panicked $control)
           (assistant-panicked (index-atom $control 2)))
         (if (== (index-atom $control 1) stop)
           (let $record ($recorder $root assistant-stopped $control)
             (assistant-stopped (index-atom $control 2)))
           (let* (($inputs ($input-reader $root))
                  ($active (> (size-atom $inputs) 0))
                  ($next (if $active $base (ARNextInterval $interval $cap))))
             (if $active
               (let* (($step (AssistantCycleStepV2 $inputs))
                      ($effects (AREffectsAt $root (index-atom $step 1) $effect-writer 0))
                      ($effects-valid (AREffectsValidAt $effects 0)))
                 (if $effects-valid
                   (let* (($snapshot (AssistantSnapshot))
                          ($checkpoint ($checkpoint-writer $root $snapshot))
                          ($record ($recorder $root assistant-cycle-v2
                            (cycle-standing contact-or-consequence $idle $checkpoint))))
                     (if (== $checkpoint checkpointed)
                       (AssistantCycleWithV2 $root false $next $base $cap
                         $control-reader $input-reader $checkpoint-writer $waiter
                         $recorder $effect-writer)
                       (assistant-service-held (checkpoint $checkpoint))))
                   (let $record ($recorder $root assistant-effect-held $effects)
                     (assistant-service-held $effects))))
               (let $wait ($waiter $root $interval)
                 (AssistantCycleWithV2 $root true $next $base $cap
                   $control-reader $input-reader $checkpoint-writer $waiter
                   $recorder $effect-writer))))))
       (assistant-cycle-held malformed-control))))

(= (AR2ServiceRestore $root)
   (let $snapshot (as_restore $root)
     (if (== $snapshot no-checkpoint) assistant-state-new-v2
       (if (== $snapshot checkpoint-invalid) assistant-restore-rejected-v2
         (AssistantRestoreV2 $snapshot)))))

(= (AssistantServiceStartV2 $root)
   (let* (($integrity (as_integrity $root))
          ($boot (SoulStartup $integrity)))
     (if (!= $boot soul-ready)
       (assistant-service-held $boot)
       (let* (($restoration (AR2ServiceRestore $root))
              ($continuity-source (miter_assistant_continuity_restore $root))
              ($continuity-restoration (AssistantContinuityRestore $continuity-source))
              ($semantic-source (miter_assistant_semantic_restore $root))
              ($semantic-restoration (AssistantSemanticRestore $semantic-source))
              ($base (as_config $root idle_base_seconds))
              ($cap (as_config $root idle_cap_seconds)))
         (if (or (== $restoration assistant-restore-rejected-v2)
              (or (== $continuity-restoration assistant-continuity-restore-rejected)
               (or (CPShape $continuity-restoration assistant-continuity-restore-held 2)
                (or (== $semantic-restoration assistant-semantic-restore-rejected)
                 (or (CPShape $semantic-restoration assistant-semantic-restore-held 2)
                  (or (== $base ()) (== $cap ())))))))
           (assistant-service-held
             (startup-restoration $restoration $continuity-restoration
               $semantic-restoration))
           (if (> $base $cap)
             (assistant-service-held invalid-idle-envelope)
             (let $start-record (as_record $root assistant-started-v2
                    (startup-restoration $restoration $continuity-restoration
                      $semantic-restoration))
               (AssistantCycleWithV2 $root false $base $base $cap
                 as_control as_input as_checkpoint as_wait as_record as_effect))))))))
