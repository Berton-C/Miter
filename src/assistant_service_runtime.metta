; Sole continuously cycling V3 service assembly.
;
; This file is imported last, after contact/dialogue participation and Soul
; regeneration have been defined.  PeTTa resolves called functions while a
; definition is compiled, so the active, regenerative, endogenous and waiting
; movements are one self-recurring reduction here rather than mutually
; recursive definitions spread across modules.

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
               (let $tables (miter_petta_clear_exact_validation_tables)
                 (if (== $tables exact-native-validation-tables-cleared)
                   (let* (($step (AssistantCycleStepV3 $root $inputs))
                          ($results (index-atom $step 1))
                          ($model-outcomes (index-atom $step 2))
                          ($effects (C4EffectsAt $root $results
                            $effect-writer 0))
                          ($valid (and
                            (AR3ModelOutcomesValidAt $model-outcomes 0)
                            (C4EffectsValidAt $effects 0))))
                     (if $valid
                       (let* (($snapshot (AssistantSnapshot))
                              ($checkpoint
                                ($checkpoint-writer $root $snapshot))
                              ($record ($recorder $root assistant-cycle-v3
                                (cycle-standing contact-consequence-and-model
                                  $idle $checkpoint
                                  (model-stage-standings
                                    (AR3ModelStageStandingsAt
                                      $model-outcomes 0))))))
                         (if (== $checkpoint checkpointed)
                           (AssistantCycleWithV3 $root false $next $base $cap
                             $control-reader $input-reader $checkpoint-writer
                             $waiter $recorder $effect-writer $model-writer)
                           (assistant-service-held (checkpoint $checkpoint))))
                       (let $record ($recorder $root assistant-cycle-held-v3
                              (held-outcomes $model-outcomes $effects))
                         (assistant-service-held
                           (model-or-effect-outcomes
                             $model-outcomes $effects)))))
                   (assistant-service-held
                     exact-native-validation-table-reset-failed)))
               (let* (($regenerative-step
                        (AssistantRegenerativeCycleStepV1))
                      ($regenerative-results
                        (index-atom $regenerative-step 1)))
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
                         (let $tables
                           (miter_petta_clear_exact_validation_tables)
                           (if (== $tables
                                 exact-native-validation-tables-cleared)
                             (reduce (AssistantCycleWithV3 $root false
                               $base $base $cap $control-reader $input-reader
                               $checkpoint-writer $waiter $recorder
                               $effect-writer $model-writer))
                             (assistant-service-held
                               exact-native-validation-table-reset-failed)))
                         (assistant-service-held
                           (checkpoint $checkpoint))))
                     (let $record ($recorder $root
                            assistant-soul-regeneration-held-v1
                            $regenerative-results)
                       (assistant-service-held
                         (soul-regeneration $regenerative-results))))
                   (let* (($endogenous-step
                            (AssistantEndogenousCycleStepV3))
                          ($endogenous-results
                            (index-atom $endogenous-step 1)))
                     (if (> (size-atom $endogenous-results) 0)
                       (let* (($effects (AREffectsAt $root
                                  $endogenous-results $effect-writer 0))
                              ($valid (AREffectsValidAt $effects 0)))
                         (if $valid
                           (let* (($snapshot (AssistantSnapshot))
                                  ($checkpoint
                                    ($checkpoint-writer $root $snapshot))
                                  ($record ($recorder $root
                                    assistant-endogenous-cycle-v1
                                    (cycle-standing soul-formed-opportunity
                                      $idle $checkpoint))))
                             (if (== $checkpoint checkpointed)
                               (let $tables
                                 (miter_petta_clear_exact_validation_tables)
                                 (if (== $tables
                                       exact-native-validation-tables-cleared)
                                   (reduce (AssistantCycleWithV3 $root false
                                     $base $base $cap $control-reader
                                     $input-reader $checkpoint-writer
                                     $waiter $recorder $effect-writer
                                     $model-writer))
                                   (assistant-service-held
                                     exact-native-validation-table-reset-failed)))
                               (assistant-service-held
                                 (checkpoint $checkpoint))))
                           (let $record ($recorder $root
                                  assistant-endogenous-cycle-held-v1
                                  $effects)
                             (assistant-service-held
                               (endogenous-effects $effects)))))
                       (let $wait ($waiter $root $interval)
                         (reduce (AssistantCycleWithV3 $root true $next
                           $base $cap $control-reader $input-reader
                           $checkpoint-writer $waiter $recorder
                           $effect-writer $model-writer)))))))))))
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
