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

(= (ARActiveValid $active)
   (and (CPShape $active active-organization 4)
     (and (CPShape (index-atom $active 1) scope 4)
       (and (CPCutValid (index-atom $active 2))
            (ARMovementValid (index-atom $active 3))))))

(= (ARHistoryValid $row)
   (and (CPShape $row assistant-history 5)
     (and (CPHas (index-atom $row 1) (encounter consequence restoration) 0)
          (CPShape (index-atom $row 3) scope 4))))

(= (ARAllValid $rows $validator $i)
   (if (< $i (size-atom $rows))
     (and ($validator (index-atom $rows $i))
          (ARAllValid $rows $validator (+ $i 1))) true))

(= (ARAddAll $space $rows $i)
   (if (< $i (size-atom $rows))
     (let $added (add-atom $space (index-atom $rows $i))
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
                   (assistant-consequence-held $id $history)))
               (assistant-consequence-held $id movement-link-mismatch))))))
     (assistant-consequence-rejected malformed-scope-or-consequence)))

; assistant-input contact Contact | assistant-input consequence Scope Consequence
(= (AssistantInput $input)
   (if (CPShape $input assistant-input 3)
     (if (== (index-atom $input 1) contact)
       (AssistantEncounter (index-atom $input 2))
       (assistant-input-rejected unknown-input-kind))
     (if (CPShape $input assistant-input 4)
       (if (== (index-atom $input 1) consequence)
         (AssistantConsequence (index-atom $input 2) (index-atom $input 3))
         (assistant-input-rejected unknown-input-kind))
       (assistant-input-rejected malformed-input))))

(= (AssistantProcessAt $inputs $i)
   (if (< $i (size-atom $inputs))
     (cons-atom (AssistantInput (index-atom $inputs $i))
       (AssistantProcessAt $inputs (+ $i 1))) ()))

(= (AssistantCycleStep $inputs)
   (if (is-expr $inputs)
     (assistant-cycle-step (AssistantProcessAt $inputs 0) (AssistantSnapshot))
     (assistant-cycle-step ((assistant-input-rejected malformed-batch)) (AssistantSnapshot))))

(= (ARControlValid $control)
   (and (CPShape $control assistant-control 3)
        (CPHas (index-atom $control 1) (continue stop panic) 0)))

(= (ARNextInterval $interval $cap)
   (let $next (* $interval 2) (if (> $next $cap) $cap $next)))

; All callbacks are non-cognitive capabilities supplied by the service bootstrap:
; control(root), input(root), checkpoint(root,snapshot), wait(root,seconds),
; and record(root,kind,payload). Native recursion owns continuation.
(= (AssistantCycleWith $root $idle $interval $base $cap
      $control-reader $input-reader $checkpoint-writer $waiter $recorder)
   (let $control ($control-reader $root)
     (if (ARControlValid $control)
       (if (== (index-atom $control 1) panic)
         (let $record ($recorder $root assistant-panicked $control)
           (assistant-panicked (index-atom $control 2)))
         (if (== (index-atom $control 1) stop)
           (let $record ($recorder $root assistant-stopped $control)
             (assistant-stopped (index-atom $control 2)))
           (let* (($inputs ($input-reader $root))
                  ($step (AssistantCycleStep $inputs))
                  ($snapshot (index-atom $step 2))
                  ($checkpoint ($checkpoint-writer $root $snapshot))
                  ($active (> (size-atom $inputs) 0))
                  ($record ($recorder $root assistant-cycle
                    (cycle-standing $active $idle $checkpoint)))
                  ($wait (if $active no-wait ($waiter $root $interval)))
                  ($next (if $active $base (ARNextInterval $interval $cap))))
             (AssistantCycleWith $root (if $active false true) $next $base $cap
               $control-reader $input-reader $checkpoint-writer $waiter $recorder))))
       (assistant-cycle-held malformed-control))))
