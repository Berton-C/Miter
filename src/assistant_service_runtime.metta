; Sole continuously cycling V3 service assembly.
;
; This file is imported last, after contact/dialogue participation and Soul
; regeneration have been defined.  PeTTa resolves called functions while a
; definition is compiled, so the active, regenerative, endogenous and waiting
; movements are one self-recurring reduction here rather than mutually
; recursive definitions spread across modules.

; Final service link.  Contact/dialogue participation is imported after the
; authority module because it consumes the completed AR4 preparation seam.
; These dispatch and effect functions must therefore compile here, after both
; sides exist, rather than capture unresolved function names in an earlier
; module.  They add no cognition: they connect the one already-defined path.
(= (AS4AnyEffectDescriptor $contact-result)
   (if (or (CPShape $contact-result assistant-contact-incorporated-v5 6)
           (CPShape $contact-result assistant-contact-incorporated-v4 5))
     (C4MattermostEffectDescriptor $contact-result)
     (ARLocalEffectDescriptor $contact-result)))

(= (AS4AnyEffectDescriptorValid $descriptor)
   (or (ARLocalEffectDescriptorValid $descriptor)
       (C4MattermostEffectDescriptorValid $descriptor)))

(= (AS4AnyEffectProof $descriptor)
   (if (CPShape $descriptor mattermost-effect-descriptor-v1 9)
     (index-atom (index-atom $descriptor 6) 1)
     (index-atom (index-atom $descriptor 5) 1)))

(= (AS4AnyEffectCertificateWrapper $descriptor)
   (if (CPShape $descriptor mattermost-effect-descriptor-v1 9)
     (index-atom $descriptor 5)
     (index-atom $descriptor 4)))

(= (AS4EffectOne $root $contact-result $effect-writer)
   (let $descriptor (AS4AnyEffectDescriptor $contact-result)
     (if (AS4AnyEffectDescriptorValid $descriptor)
       (let* (($effect-id (index-atom $descriptor 1))
              ($scope (index-atom $descriptor 3))
              ($proof (AS4AnyEffectProof $descriptor))
              ($result ($effect-writer $root $descriptor)))
         (if (ARAnyEffectResultValid $result)
           (let* (($proof-history (ARRecordVoiceProofReference $effect-id
                    $scope $proof $result))
                  ($history (if (CPHas $proof-history
                     (assistant-history-recorded assistant-history-duplicate) 0)
                    (ARRecord effect $effect-id $scope
                      (effect-witness-v2 $result
                        (AS4AnyEffectCertificateWrapper $descriptor)
                        (ARNativeProofReference $proof)))
                    assistant-history-conflict)))
             (if (and (CPHas $proof-history
                        (assistant-history-recorded assistant-history-duplicate) 0)
                      (CPHas $history
                        (assistant-history-recorded assistant-history-duplicate) 0))
               (local-effect-result $result $proof-history $history)
               (local-effect-held $effect-id
                 (history $proof-history $history))))
           (local-effect-held $effect-id $result)))
       $descriptor)))

; The direct V5 dialogue result reaches this function only after the complete
; same-cut result/outcome joint has validated.  Its descriptor, certificate,
; proof and proof reference are exact fields of that joint.  Re-running the
; restored-artifact validators here would add no cognition and was the dominant
; whole-turn cost.  The membrane still receives the complete proof-bearing
; descriptor and remains exactly-once.
(= (AS4EffectOneFromValidatedDialogue $root $contact-result $effect-writer)
   (let* (($descriptor (index-atom $contact-result 5))
          ($effect-id (index-atom $descriptor 1))
          ($scope (index-atom $descriptor 3))
          ($certificate (index-atom (index-atom $descriptor 5) 1))
          ($proof-reference (index-atom $certificate 7))
          ($result ($effect-writer $root $descriptor)))
     (if (and (ARAnyEffectResultValid $result)
              (CPShape $proof-reference native-proof-reference 5))
       (let* (($proof-record (native-movement-proof-record-v2
                $proof-reference
                (certificate-sha256 (index-atom $result 2))
                (proof-sha256 (index-atom $result 3))
                persisted-by-effect-membrane-before-observation))
              ($proof-history (ARRecordVoiceProof $effect-id $scope
                $proof-record))
              ($history (if (CPHas $proof-history
                    (assistant-history-recorded assistant-history-duplicate) 0)
                (ARRecord effect $effect-id $scope
                  (effect-witness-v2 $result
                    (index-atom $descriptor 5) $proof-reference))
                assistant-history-conflict)))
         (if (and (CPHas $proof-history
                    (assistant-history-recorded assistant-history-duplicate) 0)
                  (CPHas $history
                    (assistant-history-recorded assistant-history-duplicate) 0))
           (local-effect-result $result $proof-history $history)
           (local-effect-held $effect-id (history $proof-history $history))))
       (local-effect-held $effect-id $result))))

(= (AS4EffectsAt $root $results $effect-writer $i)
   (if (< $i (size-atom $results))
     (cons-atom (AS4EffectOne $root (index-atom $results $i) $effect-writer)
       (AS4EffectsAt $root $results $effect-writer (+ $i 1))) ()))

(= (AS4EffectsFromValidatedRowsAt $root $rows $effect-writer $i)
   (if (< $i (size-atom $rows))
     (let* (($row (index-atom $rows $i))
            ($result (index-atom $row 1))
            ($effect (if (CPShape $result
                  assistant-contact-incorporated-v5 6)
              (AS4EffectOneFromValidatedDialogue $root $result $effect-writer)
              (AS4EffectOne $root $result $effect-writer))))
       (cons-atom $effect
         (AS4EffectsFromValidatedRowsAt $root $rows $effect-writer (+ $i 1))))
     ()))

(= (AS4EffectOutcomeValid $outcome)
   (if (== $outcome no-local-effect) true
     (if (CPShape $outcome local-effect-result 4)
       (and (ARAnyEffectResultValid (index-atom $outcome 1))
        (and (CPHas (index-atom $outcome 2)
               (assistant-history-recorded assistant-history-duplicate) 0)
             (CPHas (index-atom $outcome 3)
               (assistant-history-recorded assistant-history-duplicate) 0)))
       false)))

(= (AS4EffectsValidAt $effects $i)
   (if (< $i (size-atom $effects))
     (and (AS4EffectOutcomeValid (index-atom $effects $i))
          (AS4EffectsValidAt $effects (+ $i 1))) true))

(= (AS4ControlledFixtureContact $input)
   (if (and (CPShape $input assistant-input 4)
            (== (index-atom $input 1) contact))
     (let* (($binding (index-atom $input 2))
            ($route (if (CPShape $binding scope-binding-v1 6)
              (index-atom $binding 1) ())))
       (and (CPShape $route surface-route 6)
            (== (index-atom $route 1) controlled-fixture)))
     false))

; A controlled fixture bypasses conversational VAD/model rendering, but it
; must still encounter the same live capability environment as every other
; contact.  The observation contributes availability only; the exact
; operation remains inert until the complete native encounter forms it.
(= (AS4ControlledFixtureInput $root $input)
   (let* (($binding (index-atom $input 2))
          ($contact (index-atom $input 3))
          ($initial-context (AR4BoundContactContextV1 $binding $contact)))
     (if (AR4BoundContactContextValid $initial-context)
       (let* (($bound-contact (index-atom $initial-context 5))
              ($environment (as_capability_environment $root))
              ($participants
                (C4CapabilityEnvironmentParticipants
                  $bound-contact $environment))
              ($effective-contact
                (C4ContactWithCapabilityEnvironment
                  $bound-contact $participants))
              ($context (bound-contact-context-v1
                (index-atom $initial-context 1)
                (index-atom $initial-context 2)
                (index-atom $initial-context 3)
                (index-atom $initial-context 4)
                $effective-contact))
              ($prepared (AR4PrepareEncounterV1 $effective-contact)))
         (if (AR4PreparedEncounterValid $prepared)
           (let* (($encounter (index-atom (index-atom $prepared 4) 2))
                  ($proof (ARNativeMovementProof $encounter))
                  ($proof-record (as_capability_proof $root
                    (C4CapabilityProofId $encounter) $proof))
                  ($descriptor (C4CapabilityRequestDescriptor
                    $effective-contact $encounter $proof-record))
                  ($observation (if
                    (C4CapabilityRequestDescriptorValid $descriptor
                      $effective-contact $encounter)
                    (as_capability_request $root $descriptor)
                    (capability-observation-held-v1
                      (index-atom $contact 1)
                      no-proof-bound-exact-operation)))
                  ($participant (C4CapabilityObservationParticipant
                    $descriptor $observation))
                  ($final-prepared (if (CPShape $participant
                        participant-contribution 8)
                    (C4ReformPreparedWithParticipants $prepared
                      ($participant))
                    $prepared))
                  ($result
                    (AR4IncorporatePreparedEncounter $final-prepared)))
             (AR4RecordBoundContextV1 $context $result))
           (AR4IncorporatePreparedEncounter $prepared)))
       (assistant-contact-held (index-atom $contact 1)
         stable-identity-scope-mismatch))))

(= (AS4InputWithModel $root $input)
   (if (and (CPShape $input assistant-input 4)
            (== (index-atom $input 1) consequence))
     (AssistantConsequenceV3 $root (index-atom $input 2)
       (index-atom $input 3) as_model)
     (if (and (CPShape $input assistant-input 4)
              (== (index-atom $input 1) contact))
       ; Carrier-kind routing is mechanical. A controlled native fixture has
       ; no conversational payload and therefore enters the same complete
       ; constitutive path without invoking dialogue/VAD/model renderers.
       (if (AS4ControlledFixtureContact $input)
         (assistant-processed-v3 (AS4ControlledFixtureInput $root $input)
           model-participation-not-requested)
         (C4BoundContactWithModelV1 $root (index-atom $input 2)
           (index-atom $input 3)))
       (assistant-processed-v3 (AssistantInputV2 $input)
         model-participation-not-requested))))

(= (AS4ProcessInputsAt $root $inputs $i)
   (if (< $i (size-atom $inputs))
     (cons-atom (AS4InputWithModel $root (index-atom $inputs $i))
       (AS4ProcessInputsAt $root $inputs (+ $i 1))) ()))

(= (AS4InputResultsAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom (index-atom (index-atom $rows $i) 1)
       (AS4InputResultsAt $rows (+ $i 1))) ()))

(= (AS4ModelOutcomesAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom (index-atom (index-atom $rows $i) 2)
       (AS4ModelOutcomesAt $rows (+ $i 1))) ()))

(= (AS4ModelOutcomeValid $outcome)
   (or (== $outcome model-participation-not-requested)
     (or (CPShape $outcome assistant-model-reading-incorporated 4)
      (or (CPShape $outcome assistant-model-reading-unavailable 4)
       (or (CPShape $outcome assistant-model-reading-duplicate 2)
        (or (CPShape $outcome assistant-model-reading-held 3)
            (C4DialogueModelOutcomeValid $outcome)))))))

(= (AS4ModelOutcomesValidAt $outcomes $i)
   (if (< $i (size-atom $outcomes))
     (and (AS4ModelOutcomeValid (index-atom $outcomes $i))
          (AS4ModelOutcomesValidAt $outcomes (+ $i 1))) true))

(= (AS4ProcessedRowValid $row)
   (if (CPShape $row assistant-processed-v3 3)
     (let* (($result (index-atom $row 1))
            ($outcome (index-atom $row 2)))
       (if (CPShape $result assistant-contact-incorporated-v5 6)
         (C4FreshDialogueResultOutcomeValid $result $outcome)
         (AS4ModelOutcomeValid $outcome)))
     false))

(= (AS4ProcessedRowsValidAt $rows $i)
   (if (< $i (size-atom $rows))
     (and (AS4ProcessedRowValid (index-atom $rows $i))
          (AS4ProcessedRowsValidAt $rows (+ $i 1))) true))

(= (AS4ModelStageStandingsAt $outcomes $i)
   (if (< $i (size-atom $outcomes))
     (cons-atom
       (C4DialogueStageStandingFromValidated (index-atom $outcomes $i))
       (AS4ModelStageStandingsAt $outcomes (+ $i 1))) ()))

(= (AS4ModelStageStandingsFromRowsAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom
       (C4DialogueStageStandingFromValidated
         (index-atom (index-atom $rows $i) 2))
       (AS4ModelStageStandingsFromRowsAt $rows (+ $i 1))) ()))

(= (AS4CycleStep $root $inputs)
   (if (is-expr $inputs)
     (let $rows (AS4ProcessInputsAt $root $inputs 0)
       (assistant-cycle-step-v4 $rows
         (if (AS4ProcessedRowsValidAt $rows 0)
           same-cut-rows-valid same-cut-rows-invalid)
         snapshot-deferred-to-commit-boundary))
     (assistant-cycle-step-v4 ()
       same-cut-rows-invalid
       snapshot-deferred-to-commit-boundary)))

(= (AssistantCycleWithV3 $root $idle $interval $base $cap
      $control-reader $input-reader $checkpoint-writer $waiter $recorder
      $effect-writer $model-writer)
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
               (let* (($step (AS4CycleStep $root $inputs))
                          ($rows (index-atom $step 1))
                          ($same-cut-standing (index-atom $step 2))
                          ($effects (if (== $same-cut-standing
                                same-cut-rows-valid)
                            (AS4EffectsFromValidatedRowsAt $root $rows
                              $effect-writer 0)
                            ()))
                          ($valid (and
                            (== $same-cut-standing same-cut-rows-valid)
                            (AS4EffectsValidAt $effects 0))))
                     (if $valid
                       (let* (($snapshot (AssistantSnapshot))
                              ($checkpoint
                                ($checkpoint-writer $root $snapshot))
                              ($record ($recorder $root assistant-cycle-v3
                                (cycle-standing contact-consequence-and-model
                                  $idle $checkpoint
                                  (model-stage-standings
                                    (AS4ModelStageStandingsFromRowsAt
                                      $rows 0))))))
                         (if (== $checkpoint checkpointed)
                           (AssistantCycleWithV3 $root false $next $base $cap
                             $control-reader $input-reader $checkpoint-writer
                             $waiter $recorder $effect-writer $model-writer)
                           (assistant-service-held (checkpoint $checkpoint))))
                       (let $record ($recorder $root assistant-cycle-held-v3
                              (held-rows $rows $effects))
                         (assistant-service-held
                           (model-or-effect-outcomes $rows $effects)))))
               (let* (($active-organizations
                        (AR3ActiveOrganizations))
                      ($regenerative-results
                        (AssistantRegenerativeResultsFromActivesV1
                          $active-organizations)))
                 (if (> (size-atom $regenerative-results) 0)
                   (if (SRRepairResultsCompletedAt
                         $regenerative-results 0)
                     (let* (($snapshot (AssistantSnapshot))
                            ($checkpoint
                              ($checkpoint-writer $root $snapshot))
                            ($record ($recorder $root
                              assistant-soul-regeneration-v1
                              (cycle-standing
                                autonomous-expressed-soul-restoration
                                $idle $checkpoint))))
                       (if (== $checkpoint checkpointed)
                         (AssistantCycleWithV3 $root false
                           $base $base $cap $control-reader $input-reader
                           $checkpoint-writer $waiter $recorder
                           $effect-writer $model-writer)
                         (assistant-service-held
                           (checkpoint $checkpoint))))
                     (let $record ($recorder $root
                            assistant-soul-regeneration-held-v1
                            $regenerative-results)
                       (assistant-service-held
                         (soul-regeneration $regenerative-results))))
                   (let $endogenous-results
                          (AssistantEndogenousResultsFromActivesV3
                            $active-organizations)
                     (if (> (size-atom $endogenous-results) 0)
                       ; The final service-owned effect family is compiled
                       ; after both local and Mattermost descriptor species.
                       ; Reuse it for endogenous results as well: the earlier
                       ; higher-order legacy family can lose its callback
                       ; specialization under the pinned PeTTa compiler.
                       (let* (($effects (AS4EffectsAt $root
                                  $endogenous-results $effect-writer 0))
                              ($valid (AS4EffectsValidAt $effects 0)))
                         (if $valid
                           (let* (($snapshot (AssistantSnapshot))
                                  ($checkpoint
                                    ($checkpoint-writer $root $snapshot))
                                  ($record ($recorder $root
                                    assistant-endogenous-cycle-v1
                                    (cycle-standing soul-formed-opportunity
                                      $idle $checkpoint))))
                             (if (== $checkpoint checkpointed)
                               (AssistantCycleWithV3 $root false
                                 $base $base $cap $control-reader
                                 $input-reader $checkpoint-writer
                                 $waiter $recorder $effect-writer
                                 $model-writer)
                               (assistant-service-held
                                 (checkpoint $checkpoint))))
                           (let $record ($recorder $root
                                  assistant-endogenous-cycle-held-v1
                                  $effects)
                             (assistant-service-held
                               (endogenous-effects $effects)))))
                       (let $wait ($waiter $root $interval)
                         (AssistantCycleWithV3 $root true $next
                           $base $cap $control-reader $input-reader
                           $checkpoint-writer $waiter $recorder
                           $effect-writer $model-writer))))))))))
       (assistant-cycle-held malformed-control))))

(= (AssistantServiceStartV3 $root)
   (let* (($integrity (as_integrity $root))
          ($boot (SoulStartup $integrity)))
     (if (!= $boot soul-ready)
       (assistant-service-held $boot)
       (let* (($restoration (AR2ServiceRestore $root))
              ($continuity-source
                (miter_assistant_continuity_restore $root))
              ($continuity-restoration
                (AssistantContinuityRestore $continuity-source))
              ($semantic-source (miter_assistant_semantic_restore $root))
              ($semantic-restoration
                (AssistantSemanticRestore $semantic-source))
              ($base (as_config $root idle_base_seconds))
              ($cap (as_config $root idle_cap_seconds)))
         (if (or (== $restoration assistant-restore-rejected-v2)
              (or (== $continuity-restoration
                     assistant-continuity-restore-rejected)
               (or (CPShape $continuity-restoration
                     assistant-continuity-restore-held 2)
                (or (== $semantic-restoration
                       assistant-semantic-restore-rejected)
                 (or (CPShape $semantic-restoration
                       assistant-semantic-restore-held 2)
                  (or (== $base ()) (== $cap ())))))))
           (assistant-service-held
             (startup-restoration $restoration $continuity-restoration
               $semantic-restoration))
           (if (> $base $cap)
             (assistant-service-held invalid-idle-envelope)
             (let $start-record (as_record $root assistant-started-v3
                    (startup-restoration $restoration
                      $continuity-restoration $semantic-restoration))
               (AssistantCycleWithV3 $root false $base $base $cap
                 as_control as_input as_checkpoint as_wait as_record as_effect
                 as_model))))))))
