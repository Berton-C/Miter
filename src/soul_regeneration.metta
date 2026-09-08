; Autonomous repair of causally expressed Soul organization.
; The immutable constitutional spaces are germline.  This module never writes
; them.  It constructs and compares repair candidates in a bounded quarantine
; AtomSpace,
; promotes only one independently warranted reconstruction into the existing
; active cut, and records the complete diagnosis and adjudication in history.

(= (SRExpressionRowsAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (CPShape $row soul-relation 4)
                (== (index-atom $row 1)
                  constitutive-soul-participation))
         (cons-atom $row (SRExpressionRowsAt $rows (+ $i 1)))
         (SRExpressionRowsAt $rows (+ $i 1))))
     ()))

(= (SRExpressionRows $cut)
   (if (CPShape $cut constitutive-cut 14)
     (let $carrier (index-atom $cut 10)
       (if (CPShape $carrier C 2)
         (SRExpressionRowsAt (index-atom $carrier 1) 0)
         ()))
     ()))

(= (SRExpressedSoulValid $cut)
   (let $rows (SRExpressionRows $cut)
     (if (== (size-atom $rows) 1)
       (let $row (index-atom $rows 0)
         (and (CPShape $row soul-relation 4)
              (== (index-atom $row 2) support)))
       false)))

(= (SRSoulInjury $cut)
   (let $rows (if (CPShape $cut constitutive-cut 14)
     (let $carrier (index-atom $cut 10)
       (if (CPShape $carrier C 2) (index-atom $carrier 1) ())) ())
     (if (== (size-atom $rows) 0) severed-expression
       (if (!= (size-atom (SRExpressionRows $cut)) 1)
         corrupted-or-ambiguous-expression
         (if (SRExpressedSoulValid $cut) no-injury
           causally-absent-expression)))))

(= (SRGermlineWitness)
   (soul-germline-witness-v1
     (soul-values (collapse (match &soul (soul-value $value $meaning) $value)))
     (soul-relations (collapse
       (match &soul (soul-relation $relation $a $b $failure) $relation)))
     (flourishings (CPFlourishingValues))
     (fact9-roles (collapse
       (match &fact9 (fact9-role $role $kind $meaning) $role)))
     (rationality (SoulRationalityAudit))
     immutable-read-only-authority))

(= (SRGermlineWitnessValid $witness)
   (if (CPShape $witness soul-germline-witness-v1 7)
     (let* (($values (index-atom (index-atom $witness 1) 1))
            ($relations (index-atom (index-atom $witness 2) 1))
            ($flourishings (index-atom (index-atom $witness 3) 1))
            ($facts (index-atom (index-atom $witness 4) 1))
            ($checks
              ((CPShape (index-atom $witness 1) soul-values 2)
               (CPShape (index-atom $witness 2) soul-relations 2)
               (CPShape (index-atom $witness 3) flourishings 2)
               (CPShape (index-atom $witness 4) fact9-roles 2)
               (> (size-atom $values) 0)
               (> (size-atom $relations) 0)
               (== (size-atom $flourishings) 9)
               (== (size-atom $facts) 9)
               (CPUniq $values 0 ())
               (CPUniq $relations 0 ())
               (CPUniq $flourishings 0 ())
               (CPUniq $facts 0 ())
               (== (index-atom $witness 5) (rationality true))
               (== (index-atom $witness 6)
                 immutable-read-only-authority))))
       (== $checks
         (true true true true true true true true true true true true true true)))
     false))

(= (SRPayloadHead $payload)
   (if (and (is-expr $payload) (> (size-atom $payload) 0))
     (index-atom $payload 0) atomic-or-empty-payload))

(= (SRHistoryReferencesForScope $scope)
   (collapse (match &assistant_history
     (assistant-history $kind $id $scope $payload)
     (history-reference $kind $id (SRPayloadHead $payload)))))

(= (SRConsequenceReferencesForScope $scope)
   (collapse (match &assistant_history
     (assistant-history consequence $id $scope $payload)
     (consequence-reference $id (SRPayloadHead $payload)))))

(= (SRRecoveryBasis $active $basis $germline)
   (let* (($scope (index-atom $active 1))
          ($cut (index-atom $active 2)))
     (soul-recovery-basis-v1 $scope
       (source-cut (index-atom $cut 1))
       (surviving-D (index-atom $cut 6))
       (surviving-Omega (index-atom $cut 7))
       (surviving-interfaces (index-atom $cut 8))
       (surviving-weave (index-atom $cut 9))
       (surviving-present (index-atom $cut 11))
       (surviving-provenance (index-atom $cut 12))
       (surviving-memory (SRHistoryReferencesForScope $scope))
       (surviving-consequence (SRConsequenceReferencesForScope $scope))
       (continuation-basis $basis)
       $germline)))

(= (SRRepairedExpression $cut $recovery $germline)
   (C ((soul-relation constitutive-soul-participation support
     (living-soul-expression-v1
       (source-cut (index-atom $cut 1))
       (germline $germline)
       (surviving-organization $recovery)
       (authority-boundary immutable-germline-derived-expression))))))

(= (SRCutWithExpression $cut $expression)
   (constitutive-cut
     (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
     (index-atom $cut 4) (index-atom $cut 5) (index-atom $cut 6)
     (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
     $expression (index-atom $cut 11) (index-atom $cut 12)
     (index-atom $cut 13)))

(= (SRNativeCandidate $active $repair-id $basis $recovery $germline)
   (let* (($scope (index-atom $active 1))
          ($cut (index-atom $active 2))
          ($candidate-cut (SRCutWithExpression $cut
            (SRRepairedExpression $cut $recovery $germline))))
     (soul-repair-candidate-v1 $repair-id $scope
       (source-cut (index-atom $cut 1)) $candidate-cut $basis $germline
       native-germline-and-surviving-organization)))

(= (SRExternalCandidateOne $active $basis $germline $participant)
   (let* (($scope (index-atom $active 1))
          ($cut (index-atom $active 2))
          ($id (index-atom $participant 1))
          ($claim (index-atom $participant 5))
          ($proposed (if (CPShape $claim participant-relation-claim 4)
            (index-atom $claim 2) unresolved))
          ($expression (C ((soul-relation constitutive-soul-participation
            $proposed (external-candidate $id (index-atom $participant 4))))))
          ($candidate-cut (SRCutWithExpression $cut $expression)))
     (soul-repair-candidate-v1 (external-repair-candidate $id) $scope
       (source-cut (index-atom $cut 1)) $candidate-cut $basis $germline
       (external-participant (index-atom $participant 2)
         (index-atom $participant 6) (index-atom $participant 7)))))

(= (SRExternalCandidatesAt $active $basis $germline $participants $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (and (CPShape $participant participant-contribution 8)
             (and (CPShape (index-atom $participant 5)
                    participant-relation-claim 4)
              (== (index-atom (index-atom $participant 5) 1)
                constitutive-soul-participation)))
         (cons-atom (SRExternalCandidateOne $active $basis $germline
             $participant)
           (SRExternalCandidatesAt $active $basis $germline $participants
             (+ $i 1)))
         (SRExternalCandidatesAt $active $basis $germline $participants
           (+ $i 1))))
     ()))

(= (SRMovementFromCutAndBasis $cut $basis)
   (if (CPShape $basis continuation-basis-v3 6)
     (let* (($base-cut (CPBaseCutWithoutParticipantRelations $cut))
            ($encounter (M25ConstitutiveEncounter $base-cut
              (index-atom $basis 1) (index-atom $basis 2)
              (index-atom $basis 3) (index-atom (index-atom $basis 4) 1)
              (index-atom $basis 5))))
       (if (CPShape $encounter constitutive-encounter 7)
         (index-atom $encounter 5) soul-repair-movement-unresolved))
     soul-repair-movement-unresolved))

(= (SRMovementCapacityAvailable $movement)
   (or (CPShape $movement movement-formed 7)
       (CPShape $movement movement-plural-live 4)))

(= (SRCandidateTrial $active $expected $candidate)
   (let* (($id (index-atom $candidate 1))
          ($candidate-cut (index-atom $candidate 4))
          ($basis (index-atom $candidate 5))
          ($movement (SRMovementFromCutAndBasis $candidate-cut $basis))
          ($source-valid (== (index-atom $candidate 7)
            native-germline-and-surviving-organization))
          ($exact (== $candidate $expected))
          ($restored (and (SRExpressedSoulValid $candidate-cut)
            (and (ARMovementValid $movement)
             (and (AR2MovementConstitutivelyConsistent $candidate-cut $movement)
                  (SRMovementCapacityAvailable $movement)))))
          ($changed (!= (ARMovementSummary (index-atom $active 3))
                         (ARMovementSummary $movement))))
     (if (and $source-valid (and $exact (and $restored $changed)))
       (soul-repair-trial-v1 $id admitted
         (active-organization (index-atom $active 1) $candidate-cut $movement)
         (causal-restoration
           (ARMovementSummary (index-atom $active 3))
           (ARMovementSummary $movement)))
       (soul-repair-trial-v1 $id rejected
         unsupported-self-or-external-reconstruction
         (candidate-source (index-atom $candidate 7))))))

(= (SRCandidateTrialsAt $active $expected $candidates $i)
   (if (< $i (size-atom $candidates))
     (cons-atom (SRCandidateTrial $active $expected
         (index-atom $candidates $i))
       (SRCandidateTrialsAt $active $expected $candidates (+ $i 1)))
     ()))

(= (SRAdmittedTrialsAt $trials $i)
   (if (< $i (size-atom $trials))
     (let $trial (index-atom $trials $i)
       (if (and (CPShape $trial soul-repair-trial-v1 5)
                (== (index-atom $trial 2) admitted))
         (cons-atom $trial (SRAdmittedTrialsAt $trials (+ $i 1)))
         (SRAdmittedTrialsAt $trials (+ $i 1))))
     ()))

(= (SRRejectedTrialsAt $trials $i)
   (if (< $i (size-atom $trials))
     (let $trial (index-atom $trials $i)
       (if (and (CPShape $trial soul-repair-trial-v1 5)
                (== (index-atom $trial 2) rejected))
         (cons-atom $trial (SRRejectedTrialsAt $trials (+ $i 1)))
         (SRRejectedTrialsAt $trials (+ $i 1))))
     ()))

(= (SRQuarantineAddAt $repair-id $trials $i)
   (if (< $i (size-atom $trials))
     (let* (($trial (index-atom $trials $i))
            ($row (soul-repair-quarantine-v1 $repair-id
                    (index-atom $trial 1) (index-atom $trial 2)))
            ($added (add-atom &assistant_repair $row)))
       (SRQuarantineAddAt $repair-id $trials (+ $i 1)))
     quarantine-written))

(= (SRQuarantineRows $repair-id)
   (collapse (match &assistant_repair
     (soul-repair-quarantine-v1 $repair-id $candidate $standing)
     (soul-repair-quarantine-v1 $repair-id $candidate $standing))))

(= (SRQuarantineClear $repair-id)
   (remove-atom &assistant_repair
     (soul-repair-quarantine-v1 $repair-id $candidate $standing)))

(= (SRSoulRegenerationRecordValid $record)
   (if (CPShape $record soul-regeneration-record-v1 11)
     (let* (($class (index-atom $record 1))
            ($injury (index-atom $record 2))
            ($recovery (index-atom $record 3))
            ($candidates (index-atom (index-atom $record 4) 1))
            ($trials (index-atom (index-atom $record 5) 1))
            ($admitted (SRAdmittedTrialsAt $trials 0))
            ($restored (index-atom (index-atom $record 7) 1))
            ($before (index-atom (index-atom $record 8) 1))
            ($after (index-atom (index-atom $record 9) 1)))
       (and (== $class
              (repair-class expressed-soul-constitutive-participation-v1))
        (and (CPShape $injury soul-injury-v1 4)
         (and (CPShape $recovery soul-recovery-basis-v1 13)
          (and (CPShape (index-atom $record 4) candidates 2)
           (and (CPShape (index-atom $record 5) trials 2)
            (and (> (size-atom $candidates) 0)
             (and (== (size-atom $admitted) 1)
              (and (== (index-atom $record 6)
                     (adjudication exactly-one-independently-supported
                       unsupported-candidates-rejected))
               (and (CPShape (index-atom $record 7) restored-active 2)
                (and (AR2ActiveValid $restored)
                 (and (SRExpressedSoulValid (index-atom $restored 2))
                  (and (SRGermlineWitnessValid $before)
                   (and (== $before $after)
                    (and (== $after (SRGermlineWitness))
                         (CPShape (index-atom $record 10)
                           causal-restoration 3))))))))))))))))
     false))

(= (SRRepairOne $active)
   (let* (($scope (index-atom $active 1))
          ($cut (index-atom $active 2))
          ($injury (SRSoulInjury $cut)))
     (if (== $injury no-injury) no-soul-repair-required
       (let* (($basis (C3MovementBasisFromReadings (index-atom $active 3)))
              ($germline (SRGermlineWitness))
              ($repair-id (as_native_id soul-regeneration
                (expressed-soul-injury $scope (index-atom $cut 1)
                  $injury $germline)))
              ($recovery (SRRecoveryBasis $active $basis $germline))
              ($native (SRNativeCandidate $active $repair-id $basis
                $recovery $germline))
              ($participants (if (CPShape $basis continuation-basis-v3 6)
                (index-atom $basis 3) ()))
              ($external (SRExternalCandidatesAt $active $basis $germline
                $participants 0))
              ($candidates (cons-atom $native $external))
              ($trials (SRCandidateTrialsAt $active $native $candidates 0))
              ($written (SRQuarantineAddAt $repair-id $trials 0))
              ($readback (SRQuarantineRows $repair-id))
              ($cleared (SRQuarantineClear $repair-id))
              ($quarantine-empty (== (size-atom (SRQuarantineRows $repair-id)) 0))
              ($admitted (SRAdmittedTrialsAt $trials 0))
              ($rejected (SRRejectedTrialsAt $trials 0))
              ($quarantine-exact (and (== (size-atom $readback)
                (size-atom $trials)) $quarantine-empty)))
         (if (and $quarantine-exact (== (size-atom $admitted) 1))
           (let* (($trial (index-atom $admitted 0))
                  ($restored (index-atom $trial 3))
                  ($record (soul-regeneration-record-v1
                    (repair-class expressed-soul-constitutive-participation-v1)
                    (soul-injury-v1 (index-atom $cut 1) $injury
                      (index-atom $cut 10))
                    $recovery (candidates $candidates) (trials $trials)
                    (adjudication exactly-one-independently-supported
                      unsupported-candidates-rejected)
                    (restored-active $restored)
                    (germline-before $germline) (germline-after (SRGermlineWitness))
                    (index-atom $trial 4)))
                  ($record-valid (SRSoulRegenerationRecordValid $record)))
             (if $record-valid
               (let* (($replace (ARReplaceActive $scope
                          (index-atom $restored 2) (index-atom $restored 3)))
                      ($history (ARRecord soul-regeneration $repair-id $scope
                        $record)))
                 (if (and (== $replace assistant-active-replaced)
                      (and (CPHas $history
                         (assistant-history-recorded assistant-history-duplicate) 0)
                           (== (size-atom $readback) (size-atom $trials))))
                   (soul-regeneration-completed-v1 $repair-id $scope
                     (ARMovementSummary (index-atom $restored 3))
                     (rejected-candidates (size-atom $rejected)))
                   (soul-regeneration-held-v1 persistence-or-clear-failed)))
               (soul-regeneration-held-v1 invalid-regeneration-record)))
           (soul-regeneration-held-v1 no-unique-supported-reconstruction))))))

(= (SRRepairActivesAt $actives $i)
   (if (< $i (size-atom $actives))
     (let $result (SRRepairOne (index-atom $actives $i))
       (if (!= $result no-soul-repair-required)
         (cons-atom $result (SRRepairActivesAt $actives (+ $i 1)))
         (SRRepairActivesAt $actives (+ $i 1))))
     ()))

(= (SRRepairResultsCompletedAt $results $i)
   (if (< $i (size-atom $results))
     (and (CPShape (index-atom $results $i)
            soul-regeneration-completed-v1 5)
          (SRRepairResultsCompletedAt $results (+ $i 1)))
     true))

(= (AssistantRegenerativeCycleStepV1)
   (let* (($actives (collapse (match &assistant_state $atom $atom)))
          ($results (SRRepairActivesAt $actives 0)))
     (assistant-regenerative-cycle-step-v1 $results (AssistantSnapshot))))

(= (AR3HistoryValid $row)
   (if (and (CPShape $row assistant-history 5)
         (== (index-atom $row 1) soul-regeneration))
     (and (CPShape (index-atom $row 3) scope 4)
          (SRSoulRegenerationRecordValid (index-atom $row 4)))
     (AR2HistoryValid $row)))

; Regeneration has priority over new endogenous opportunity because a damaged
; living Soul must not originate further movement. Both remain reductions of
; this same recurring reactor; neither is a second loop.
(= (AssistantCycleIdleWithV3 $root $idle $interval $next $base $cap
      $control-reader $input-reader $checkpoint-writer $waiter $recorder
      $effect-writer $model-writer)
   (let* (($regenerative-step (AssistantRegenerativeCycleStepV1))
          ($regenerative-results (index-atom $regenerative-step 1)))
     (if (> (size-atom $regenerative-results) 0)
       (if (SRRepairResultsCompletedAt $regenerative-results 0)
         (let* (($snapshot (AssistantSnapshot))
                ($checkpoint ($checkpoint-writer $root $snapshot))
                ($record ($recorder $root assistant-soul-regeneration-v1
                  (cycle-standing autonomous-expressed-soul-restoration
                    $idle $checkpoint))))
           (if (== $checkpoint checkpointed)
             (let $tables (miter_petta_clear_exact_validation_tables)
               (if (== $tables exact-native-validation-tables-cleared)
                 (reduce (AssistantCycleWithV3 $root false $base $base $cap
                   $control-reader $input-reader $checkpoint-writer $waiter
                   $recorder $effect-writer $model-writer))
                 (assistant-service-held
                   exact-native-validation-table-reset-failed)))
             (assistant-service-held (checkpoint $checkpoint))))
         (let $record ($recorder $root assistant-soul-regeneration-held-v1
                $regenerative-results)
           (assistant-service-held
             (soul-regeneration $regenerative-results))))
       (let* (($endogenous-step (AssistantEndogenousCycleStepV3))
              ($endogenous-results (index-atom $endogenous-step 1)))
         (if (> (size-atom $endogenous-results) 0)
           (let* (($effects (AREffectsAt $root $endogenous-results
                      $effect-writer 0))
                  ($valid (AREffectsValidAt $effects 0)))
             (if $valid
               (let* (($snapshot (AssistantSnapshot))
                      ($checkpoint ($checkpoint-writer $root $snapshot))
                      ($record ($recorder $root assistant-endogenous-cycle-v1
                        (cycle-standing soul-formed-opportunity
                          $idle $checkpoint))))
                 (if (== $checkpoint checkpointed)
                   (let $tables (miter_petta_clear_exact_validation_tables)
                     (if (== $tables exact-native-validation-tables-cleared)
                       (reduce (AssistantCycleWithV3 $root false $base $base
                         $cap $control-reader $input-reader
                         $checkpoint-writer $waiter $recorder $effect-writer
                         $model-writer))
                       (assistant-service-held
                         exact-native-validation-table-reset-failed)))
                   (assistant-service-held (checkpoint $checkpoint))))
               (let $record ($recorder $root
                      assistant-endogenous-cycle-held-v1 $effects)
                 (assistant-service-held (endogenous-effects $effects)))))
           (let $wait ($waiter $root $interval)
             (reduce (AssistantCycleWithV3 $root true $next $base $cap
               $control-reader $input-reader $checkpoint-writer $waiter
               $recorder $effect-writer $model-writer))))))))
