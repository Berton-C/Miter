; AMA-1.1 continuously recurring native assistant reactor.
; The reactor processes typed contact and consequence; it does not invent work,
; select by scenario, or grant effects. Mechanical callbacks may carry bytes,
; wait, checkpoint, and report control, but they cannot choose movement.

(= (ARActiveRows $scope)
   (collapse (match &assistant_state
     (active-organization $scope $cut $movement)
     (active-organization $scope $cut $movement))))

(= (ARHistoryHas $kind $id)
   (let $rows (collapse (match &assistant_history
     (assistant-history $kind $id $scope $payload) $id))
     (> (size-atom $rows) 0)))

(= (ARMovementValid $movement)
   (or (CPShape $movement movement-formed 7)
     (or (CPShape $movement movement-plural-live 4)
       (or (CPShape $movement movement-unresolved 3)
           (CPShape $movement no-current-movement 2)))))

; Byte integrity belongs to the membrane. For a v2 movement, native restore
; additionally re-forms the movement from its retained constitutive basis and
; requires exact agreement with the active cut. V1 snapshots keep their prior
; bounded validation because they carry no v2 continuation basis.
(= (ARMovementConstitutivelyConsistent $cut $movement)
   (let $basis (CPMovementBasisV2 $movement)
     (if (CPShape $basis continuation-basis-v2 5)
       (let* (($base-cut (CPBaseCutWithoutParticipantRelations $cut))
              ($encounter (CPConstitutiveEncounterV2 $base-cut
                (index-atom $basis 1) (index-atom $basis 2)
                (index-atom $basis 3) (index-atom (index-atom $basis 4) 1))))
         (and (CPShape $encounter constitutive-encounter 7)
              (== (index-atom $encounter 5) $movement)))
       true)))

(= (ARActiveValid $active)
   (and (CPShape $active active-organization 4)
     (and (CPShape (index-atom $active 1) scope 4)
       (and (CPCutValid (index-atom $active 2))
        (and (ARMovementValid (index-atom $active 3))
             (ARMovementConstitutivelyConsistent
               (index-atom $active 2) (index-atom $active 3)))))))

(= (ARHistoryValid $row)
   (and (CPShape $row assistant-history 5)
     (and (CPHas (index-atom $row 1)
            (encounter consequence restoration effect scope-binding continuity semantic) 0)
          (CPShape (index-atom $row 3) scope 4))))

(= (ARAllValid $rows $validator $i)
   (if (< $i (size-atom $rows))
     (and ($validator (index-atom $rows $i))
          (ARAllValid $rows $validator (+ $i 1))) true))

(= (ARAddAll $space $rows $i)
   (if (< $i (size-atom $rows))
     (let* (($row (index-atom $rows $i))
            ($added (add-atom $space $row)))
       (ARAddAll $space $rows (+ $i 1))) restored))

(= (ARStateScopesUnique $rows $i $seen)
   (if (< $i (size-atom $rows))
     (let $scope (index-atom (index-atom $rows $i) 1)
       (if (CPHas $scope $seen 0) false
         (ARStateScopesUnique $rows (+ $i 1) (cons-atom $scope $seen)))) true))

(= (ARHistoryKeysUnique $rows $i $seen)
   (if (< $i (size-atom $rows))
     (let* (($row (index-atom $rows $i))
            ($key (history-key (index-atom $row 1) (index-atom $row 2))))
       (if (CPHas $key $seen 0) false
         (ARHistoryKeysUnique $rows (+ $i 1) (cons-atom $key $seen)))) true))

(= (ARSpacesEmpty)
   (and (== (size-atom (collapse (match &assistant_state $atom $atom))) 0)
        (== (size-atom (collapse (match &assistant_history $atom $atom))) 0)))

(= (AssistantSnapshot)
   (assistant-snapshot
     (state (collapse (match &assistant_state $atom $atom)))
     (history (collapse (match &assistant_history $atom $atom)))))

(= (ARRestoreValid $state-wrapper $history-wrapper $state $history)
   (and (ARSpacesEmpty)
     (and (CPShape $state-wrapper state 2)
      (and (CPShape $history-wrapper history 2)
       (and (is-expr $state)
        (and (is-expr $history)
         (and (CPUniq $state 0 ())
          (and (CPUniq $history 0 ())
           (and (ARAllValid $state ARActiveValid 0)
            (and (ARAllValid $history ARHistoryValid 0)
             (and (ARStateScopesUnique $state 0 ())
                  (ARHistoryKeysUnique $history 0 ()))))))))))))

(= (AssistantRestore $snapshot)
   (if (CPShape $snapshot assistant-snapshot 3)
     (let* (($state-wrapper (index-atom $snapshot 1))
            ($history-wrapper (index-atom $snapshot 2))
            ($state (index-atom $state-wrapper 1))
            ($history (index-atom $history-wrapper 1)))
       (if (ARRestoreValid $state-wrapper $history-wrapper $state $history)
         (let* (($s (ARAddAll &assistant_state $state 0))
                ($h (ARAddAll &assistant_history $history 0)))
           assistant-state-restored)
         assistant-restore-rejected))
     assistant-restore-rejected))

(= (ARReplaceActive $scope $cut $movement)
   (let $prior (ARActiveRows $scope)
     (if (> (size-atom $prior) 1) assistant-state-conflict
       (if (== (size-atom $prior) 1)
         (let* (($old (index-atom $prior 0))
                ($removed (remove-atom &assistant_state $old))
                ($added (add-atom &assistant_state
                  (active-organization $scope $cut $movement))))
           assistant-active-replaced)
         (let $added (add-atom &assistant_state
           (active-organization $scope $cut $movement)) assistant-active-replaced)))))

(= (ARRecord $kind $id $scope $payload)
   (if (ARHistoryHas $kind $id) assistant-history-duplicate
     (let $added (add-atom &assistant_history
       (assistant-history $kind $id $scope $payload)) assistant-history-recorded)))

(= (AREncounterMovement $encounter)
   (index-atom $encounter 5))

(= (ARMovementSummary $movement)
   (if (CPShape $movement movement-formed 7)
     (movement-standing formed (index-atom $movement 2) (index-atom $movement 1))
     (if (CPShape $movement movement-plural-live 4)
       (movement-standing plural-live
         (size-atom (index-atom (index-atom $movement 2) 1)))
       (if (CPShape $movement movement-unresolved 3)
         (movement-standing unresolved (index-atom $movement 1))
         (movement-standing none)))))

(= (AREncounterSummary $encounter)
   (let* (($cut (index-atom $encounter 1))
          ($movement (AREncounterMovement $encounter)))
     (encounter-incorporated (index-atom $cut 1) (ARMovementSummary $movement)
       (index-atom $cut 12))))

(= (AssistantEncounter $contact)
   (if (CPContactValid $contact)
     (let* (($id (index-atom $contact 1))
            ($scope (CPContactScope $contact))
            ($prior (ARActiveRows $scope)))
       (if (ARHistoryHas encounter $id) (assistant-contact-duplicate $id)
         (if (> (size-atom $prior) 1) (assistant-contact-held $id state-conflict)
           (let* (($predecessor (if (== (size-atom $prior) 1)
                    (index-atom (index-atom $prior 0) 2) ()))
                  ($encounter (CPEncounter $contact $predecessor)))
             (if (CPShape $encounter constitutive-encounter 7)
               (let* (($cut (index-atom $encounter 1))
                      ($movement (AREncounterMovement $encounter))
                      ($state (ARReplaceActive $scope $cut $movement))
                      ($history (if (== $state assistant-active-replaced)
                        (ARRecord encounter $id $scope (AREncounterSummary $encounter))
                        state-not-recorded)))
                 (if (== $history assistant-history-recorded)
                   (assistant-contact-incorporated $id $encounter)
                   (assistant-contact-held $id $history)))
               (assistant-contact-held $id $encounter))))))
     (assistant-contact-rejected malformed-or-unauthorized-contact)))

(= (ARConsequenceMovementMatches $movement $consequence)
   (and (CPShape $movement movement-formed 7)
        (== (index-atom $movement 2) (index-atom $consequence 2))))

(= (ARIncorporateConsequenceV1 $id $scope $cut $movement $consequence)
   (let* (($next (CPNextCut $cut $consequence))
          ($state (ARReplaceActive $scope $next
            (no-current-movement consequence-incorporated)))
          ($history (if (== $state assistant-active-replaced)
            (ARRecord consequence $id $scope
              (consequence-incorporation (index-atom $next 1)
                (index-atom $consequence 2) (index-atom $consequence 9)))
            state-not-recorded)))
     (if (== $history assistant-history-recorded)
       (assistant-consequence-incorporated $id $next)
       (assistant-consequence-held $id $history))))

(= (ARIncorporateConsequenceV2 $id $scope $cut $movement $consequence)
   (let $next-organization
     (CPReconstituteAfterConsequenceV2 $cut $movement $consequence)
     (if (CPShape $next-organization next-constitutive-organization 2)
       (let* (($encounter (index-atom $next-organization 1))
              ($next-cut (index-atom $encounter 1))
              ($next-movement (AREncounterMovement $encounter))
              ($state (ARReplaceActive $scope $next-cut $next-movement))
              ($history (if (== $state assistant-active-replaced)
                (ARRecord consequence $id $scope
                  (consequence-incorporation-v2 $next-organization
                    (prior-movement (index-atom $consequence 2))
                    (returned-evidence (index-atom $consequence 12))))
                state-not-recorded)))
         (if (== $history assistant-history-recorded)
           (assistant-consequence-incorporated $id $next-organization)
           (assistant-consequence-held $id $history)))
       (assistant-consequence-held $id $next-organization))))

(= (AssistantConsequence $scope $consequence)
   (if (and (CPShape $scope scope 4) (CPConsequenceValid $consequence))
     (let* (($id (index-atom $consequence 1))
            ($active (ARActiveRows $scope)))
       (if (ARHistoryHas consequence $id) (assistant-consequence-duplicate $id)
         (if (!= (size-atom $active) 1) (assistant-consequence-held $id active-cut-unavailable)
           (let* (($organization (index-atom $active 0))
                  ($cut (index-atom $organization 2))
                  ($movement (index-atom $organization 3)))
             (if (ARConsequenceMovementMatches $movement $consequence)
               (if (CPConsequenceV2Valid $consequence)
                 (ARIncorporateConsequenceV2 $id $scope $cut $movement $consequence)
                 (ARIncorporateConsequenceV1 $id $scope $cut $movement $consequence))
               (assistant-consequence-held $id movement-link-mismatch))))))
     (assistant-consequence-rejected malformed-scope-or-consequence)))

; Stable carrier identity and configured scope are mechanical observations.
; Native cognition admits the contact and preserves that exact binding in its
; developmental history; the binding never chooses or renders movement.
(= (ACBoundEncounter $binding $contact)
   (if (ACScopeBindingValid $binding $contact)
     (let* (($scope (CPContactScope $contact))
            ($continuity (ACContinuityForScope $scope))
            ($semantic (ASSemanticForScope $scope)))
       (if (== $continuity (continuity-standing conflicting-sources-for-scope))
         (assistant-contact-rejected conflicting-continuity-sources)
         (let* (($continuity-contact (if (ACContinuityValid $continuity)
                  (ACContactWithContinuity $contact $continuity) $contact))
                ($effective-contact
                  (ASContactWithSemantic $continuity-contact $semantic))
                ($result (AssistantEncounter $effective-contact)))
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

; assistant-input contact Contact | assistant-input consequence Scope Consequence
(= (AssistantInput $input)
   (if (CPShape $input assistant-input 3)
     (if (== (index-atom $input 1) contact)
       (AssistantEncounter (index-atom $input 2))
       (assistant-input-rejected unknown-input-kind))
     (if (CPShape $input assistant-input 4)
       (if (== (index-atom $input 1) contact)
         (ACBoundEncounter (index-atom $input 2) (index-atom $input 3))
         (if (== (index-atom $input 1) consequence)
           (AssistantConsequence (index-atom $input 2) (index-atom $input 3))
           (assistant-input-rejected unknown-input-kind)))
       (assistant-input-rejected malformed-input))))

(= (AssistantProcessAt $inputs $i)
   (if (< $i (size-atom $inputs))
     (cons-atom (AssistantInput (index-atom $inputs $i))
       (AssistantProcessAt $inputs (+ $i 1))) ()))

(= (AssistantCycleStep $inputs)
   (if (is-expr $inputs)
     (assistant-cycle-step (AssistantProcessAt $inputs 0) (AssistantSnapshot))
     (assistant-cycle-step ((assistant-input-rejected malformed-batch)) (AssistantSnapshot))))

(= (ARVoiceCertificate $encounter)
   (if (CPShape $encounter constitutive-encounter 7)
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($participants (index-atom $encounter 6)))
       (if (ARMovementValid $movement)
         (assistant-voice-certificate-v1
           (VoiceRNA bounded-native-expression)
           (source-cut (index-atom $cut 1))
           (index-atom $cut 3)
           (movement-source $movement)
           (intended-expression
             (local-response (ARMovementSummary $movement)))
           (participant-boundaries $participants)
           (voice-audit source-bound uncertainty-retained no-added-authority)
           no-emission-authority)
         (assistant-voice-held invalid-movement)))
     (assistant-voice-held invalid-encounter)))

(= (ARVoiceCertificateValid $certificate)
   (and (CPShape $certificate assistant-voice-certificate-v1 9)
     (and (CPShape (index-atom $certificate 1) VoiceRNA 2)
      (and (CPShape (index-atom $certificate 2) source-cut 2)
       (and (CPShape (index-atom $certificate 3) scope 4)
        (and (CPShape (index-atom $certificate 4) movement-source 2)
         (and (CPShape (index-atom $certificate 5) intended-expression 2)
          (and (CPShape (index-atom $certificate 6) participant-boundaries 2)
           (and (CPShape (index-atom $certificate 7) voice-audit 4)
                (== (index-atom $certificate 8) no-emission-authority))))))))))

(= (ARLocalEffectDescriptor $contact-result)
   (if (CPShape $contact-result assistant-contact-incorporated 3)
     (let* (($contact-id (index-atom $contact-result 1))
            ($encounter (index-atom $contact-result 2))
            ($certificate (ARVoiceCertificate $encounter)))
       (if (ARVoiceCertificateValid $certificate)
         (local-effect-descriptor-v1 $contact-id $contact-id
           (index-atom $certificate 3)
           (payload $certificate)
           (capability local-isolated-outbox no-network no-external-authority)
           prepared)
         (local-effect-held $contact-id $certificate)))
     no-local-effect))

(= (ARLocalEffectResultValid $result)
   (and (is-expr $result)
     (and (== (size-atom $result) 3)
       (CPHas (index-atom $result 0)
         (local-effect-committed local-effect-duplicate) 0))))

(= (AREffectOne $root $contact-result $effect-writer)
   (let $descriptor (ARLocalEffectDescriptor $contact-result)
     (if (CPShape $descriptor local-effect-descriptor-v1 7)
       (let $result ($effect-writer $root $descriptor)
         (if (ARLocalEffectResultValid $result)
           (let* (($scope (index-atom $descriptor 3))
                  ($history (ARRecord effect (index-atom $descriptor 1) $scope
                    (effect-witness $result (index-atom $descriptor 4)))))
             (local-effect-result $result $history))
           (local-effect-held (index-atom $descriptor 1) $result)))
       $descriptor)))

(= (AREffectsAt $root $results $effect-writer $i)
   (if (< $i (size-atom $results))
     (cons-atom (AREffectOne $root (index-atom $results $i) $effect-writer)
       (AREffectsAt $root $results $effect-writer (+ $i 1))) ()))

(= (AREffectOutcomeValid $outcome)
   (if (== $outcome no-local-effect) true
     (if (CPShape $outcome local-effect-result 3)
       (and (ARLocalEffectResultValid (index-atom $outcome 1))
            (CPHas (index-atom $outcome 2)
              (assistant-history-recorded assistant-history-duplicate) 0))
       false)))

(= (AREffectsValidAt $effects $i)
   (if (< $i (size-atom $effects))
     (and (AREffectOutcomeValid (index-atom $effects $i))
          (AREffectsValidAt $effects (+ $i 1))) true))

(= (ARControlValid $control)
   (and (CPShape $control assistant-control 3)
        (CPHas (index-atom $control 1) (continue stop panic) 0)))

(= (ARNextInterval $interval $cap)
   (let $next (* $interval 2) (if (> $next $cap) $cap $next)))

; All callbacks are non-cognitive capabilities supplied by the service bootstrap:
; control(root), input(root), checkpoint(root,snapshot), wait(root,seconds),
; record(root,kind,payload), and effect(root,descriptor). Native recursion owns
; continuation, VoiceRNA and descriptor formation.
(= (AssistantCycleWith $root $idle $interval $base $cap
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
               (let* (($step (AssistantCycleStep $inputs))
                      ($effects (AREffectsAt $root (index-atom $step 1) $effect-writer 0))
                      ($effects-valid (AREffectsValidAt $effects 0)))
                 (if $effects-valid
                   (let* (($snapshot (AssistantSnapshot))
                          ($checkpoint ($checkpoint-writer $root $snapshot))
                          ($record ($recorder $root assistant-cycle
                            (cycle-standing contact-or-consequence $idle $checkpoint))))
                     (if (== $checkpoint checkpointed)
                       (AssistantCycleWith $root false $next $base $cap
                         $control-reader $input-reader $checkpoint-writer $waiter $recorder $effect-writer)
                       (assistant-service-held (checkpoint $checkpoint))))
                   (let $record ($recorder $root assistant-effect-held $effects)
                     (assistant-service-held $effects))))
               (let $wait ($waiter $root $interval)
                 (AssistantCycleWith $root true $next $base $cap
                   $control-reader $input-reader $checkpoint-writer $waiter $recorder $effect-writer))))))
       (assistant-cycle-held malformed-control))))

(= (ARServiceRestore $root)
   (let $snapshot (as_restore $root)
     (if (== $snapshot no-checkpoint) assistant-state-new
       (if (== $snapshot checkpoint-invalid) assistant-restore-rejected
         (AssistantRestore $snapshot)))))

; Supported persistent entry. Integrity and restoration are measured by
; non-cognitive membranes but admitted here. Only this native path decides
; whether the continuously recurring cognition may begin.
(= (AssistantServiceStart $root)
   (let* (($integrity (as_integrity $root))
          ($boot (SoulStartup $integrity)))
     (if (!= $boot soul-ready)
       (assistant-service-held $boot)
       (let* (($restoration (ARServiceRestore $root))
              ($continuity-source (miter_assistant_continuity_restore $root))
              ($continuity-restoration
                (AssistantContinuityRestore $continuity-source))
              ($semantic-source (miter_assistant_semantic_restore $root))
              ($semantic-restoration
                (AssistantSemanticRestore $semantic-source))
              ($base (as_config $root idle_base_seconds))
              ($cap (as_config $root idle_cap_seconds)))
         (if (or (== $restoration assistant-restore-rejected)
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
             (let $start-record (as_record $root assistant-started
                    (startup-restoration $restoration $continuity-restoration
                      $semantic-restoration))
               (AssistantCycleWith $root false $base $base $cap
                 as_control as_input as_checkpoint as_wait as_record as_effect))))))))
