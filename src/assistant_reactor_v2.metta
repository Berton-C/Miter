; AMA-1.2 R3 persistent assistant integration for the native authority joint.
; This replaces the contact step; it does not run beside the v1 cognition path.

(= (AR2MovementSummaryValid $summary)
   (or (CPShape $summary movement-standing 4)
     (or (CPShape $summary movement-standing 3)
         (CPShape $summary movement-standing 2))))

(= (AR2EncounterHistoryPayloadValid $payload)
   (let* (($payload-valid (CPShape $payload encounter-incorporated-v2 5))
          ($cut-valid (if $payload-valid
            (CPShape (index-atom $payload 1) cut-of 3) false))
          ($movement-valid (if $payload-valid
            (AR2MovementSummaryValid (index-atom $payload 2)) false))
          ($joint-valid (if $payload-valid
            (CP2AuthorityJointValid (index-atom $payload 4)) false)))
     (and $payload-valid
       (and $cut-valid (and $movement-valid $joint-valid)))))

(= (AR2HistoryValid $row)
   (let* (($row-valid (CPShape $row assistant-history 5))
          ($is-encounter (if $row-valid
            (== (index-atom $row 1) encounter) false)))
     (if $is-encounter
       (let* (($scope-valid (CPShape (index-atom $row 3) scope 4))
              ($payload-valid
                (AR2EncounterHistoryPayloadValid (index-atom $row 4))))
         (and $scope-valid $payload-valid))
       (ARHistoryValid $row))))

(= (AR2AllHistoryValid $rows $i)
   (if (< $i (size-atom $rows))
     (and (AR2HistoryValid (index-atom $rows $i))
          (AR2AllHistoryValid $rows (+ $i 1))) true))

(= (AR2RestoreValid $state-wrapper $history-wrapper $state $history)
   (and (ARSpacesEmpty)
     (and (CPShape $state-wrapper state 2)
      (and (CPShape $history-wrapper history 2)
       (and (is-expr $state)
        (and (is-expr $history)
         (and (CPUniq $state 0 ())
          (and (CPUniq $history 0 ())
           (and (ARAllValid $state ARActiveValid 0)
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
     (encounter-incorporated-v2 (index-atom $cut 1)
       (ARMovementSummary $movement) (index-atom $cut 12) $joint)))

(= (AR2GroundedEncounterValid $grounded)
   (let $shape-valid (CPShape $grounded authority-grounded-encounter 3)
     (if $shape-valid
       (CP2AuthorityJointValid (index-atom $grounded 1)) false)))

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
           (AssistantConsequence (index-atom $input 2) (index-atom $input 3))
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
