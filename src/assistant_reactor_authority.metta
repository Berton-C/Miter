; Persistent assistant integration for the native authority joint.
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
          (if (or (CPShape (index-atom $payload 4)
                    authority-participation-joint-v2 11)
              (or (CPShape (index-atom $payload 4)
                     authority-participation-joint-v3 11)
                (or (CPShape (index-atom $payload 4)
                      authority-participation-joint-v4 12)
                 (or (CPShape (index-atom $payload 4)
                       authority-participation-joint-v5 13)
                  (or (CPShape (index-atom $payload 4)
                        authority-participation-joint-v6 14)
                   (or (CPShape (index-atom $payload 4)
                         authority-participation-joint-v7 15)
                       (CPShape (index-atom $payload 4)
                         authority-participation-joint-v8 16)))))))
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

; The active v3 movement already carries its exact M24 developmental
; organization in the continuation basis.  Consequence history therefore
; retains a compact, integrity-protected reference instead of duplicating the
; entire next encounter and transition.  The checkpoint membrane hashes the
; complete snapshot; active restore separately re-forms the movement from its
; constitutive basis.
(= (AR2DevelopmentalReference $developmental)
   (if (M24DevelopmentalOrganizationValid $developmental)
     (m24-developmental-reference
       (index-atom (index-atom $developmental 1) 1)
       (index-atom $developmental 3)
       (index-atom $developmental 13))
     (m24-developmental-reference-unresolved)))

(= (AR2ConsequenceHistoryV4 $scope $next-cut $next-movement $transition
      $consequence)
   (consequence-incorporation-v4
     (next-organization-reference $scope (index-atom $next-cut 1)
       (CP2MovementReference $next-cut $next-movement))
     (AR2DevelopmentalReference (index-atom $transition 2))
     (prior-movement (index-atom $consequence 2))
     (returned-evidence (index-atom $consequence 12))
     active-basis-carries-exact-developmental-organization))

; V5 adds the exact C3 developmental episode when this consequence resolves a
; Soul-formed semantic discrimination. Other consequences carry an explicit
; unavailable marker. The record is history and future inquiry material; it
; is not silently inserted as support or as a behavioral rule.
(= (AR3ConsequenceHistoryV5 $scope $cut $movement $next-cut $next-movement
      $transition $consequence)
   (consequence-incorporation-v5
     (next-organization-reference $scope (index-atom $next-cut 1)
       (CP2MovementReference $next-cut $next-movement))
     (AR2DevelopmentalReference (index-atom $transition 2))
     (prior-movement (index-atom $consequence 2))
     (returned-evidence (index-atom $consequence 12))
     (C3SemanticDevelopmentRecord $scope $cut $movement $next-cut
       $next-movement $consequence)
     active-basis-carries-exact-developmental-organization))

(= (AR2ConsequenceHistoryPayloadV4Valid $payload)
   (if (CPShape $payload consequence-incorporation-v4 6)
     (let* (($next (index-atom $payload 1))
            ($developmental (index-atom $payload 2))
            ($prior (index-atom $payload 3))
            ($returned (index-atom $payload 4)))
       (and (CPShape $next next-organization-reference 4)
        (and (CPShape (index-atom $next 1) scope 4)
         (and (CPShape (index-atom $next 3) movement-reference 5)
          (and (== (index-atom $next 2)
                 (index-atom (index-atom $next 3) 1))
           (and (CPShape $developmental m24-developmental-reference 4)
            (and (CPShape $prior prior-movement 2)
             (and (CPShape $returned returned-evidence 2)
                  (== (index-atom $payload 5)
                    active-basis-carries-exact-developmental-organization)))))))))
     false))

(= (AR3SemanticDevelopmentHistoryStandingValid $standing)
   (or (C3SemanticDevelopmentRecordValid $standing)
     (and (CPShape $standing c3-semantic-development-unavailable 3)
          (== (index-atom $standing 2)
            no-exact-semantic-discrimination))))

(= (AR3SemanticDevelopmentReferenceId $standing)
   (if (C3SemanticDevelopmentRecordValid $standing)
     (index-atom (index-atom $standing 1) 1)
     (if (CPShape $standing c3-semantic-development-unavailable 3)
       (index-atom $standing 1) invalid-semantic-development-reference)))

(= (AR3ConsequenceHistoryPayloadV5Valid $payload)
   (if (CPShape $payload consequence-incorporation-v5 7)
     (let* (($next (index-atom $payload 1))
            ($developmental (index-atom $payload 2))
            ($prior (index-atom $payload 3))
            ($returned (index-atom $payload 4))
            ($semantic-development (index-atom $payload 5)))
       (==
         ((CPShape $next next-organization-reference 4)
          (CPShape (index-atom $next 1) scope 4)
          (CPShape (index-atom $next 3) movement-reference 5)
          (== (index-atom $next 2)
            (index-atom (index-atom $next 3) 1))
          (CPShape $developmental m24-developmental-reference 4)
          (CPShape $prior prior-movement 2)
          (CPShape $returned returned-evidence 2)
          (AR3SemanticDevelopmentHistoryStandingValid $semantic-development)
          (if (C3SemanticDevelopmentRecordValid $semantic-development)
            (== (index-atom $semantic-development 2)
              (index-atom $next 1)) true)
          (if (C3SemanticDevelopmentRecordValid $semantic-development)
            (== (index-atom $semantic-development 7)
              (index-atom $next 3)) true)
          (if (C3SemanticDevelopmentRecordValid $semantic-development)
            (== (index-atom (index-atom $semantic-development 3) 4)
              (index-atom $prior 1)) true)
          (== (index-atom $payload 6)
            active-basis-carries-exact-developmental-organization))
         (true true true true true true true true true true true true)))
     false))

(= (AR3SemanticDevelopmentRecordsForScope $scope)
   (let $rows (collapse (match &assistant_history
          (assistant-history consequence $id $scope
            (consequence-incorporation-v5 $next $m24 $prior $returned
              $semantic-development $standing))
          $semantic-development))
     (if (> (size-atom $rows) 0)
       (collapse (let $record (superpose $rows)
         (if (C3SemanticDevelopmentRecordValid $record) $record (empty))))
       ())))

(= (AR3SemanticDevelopmentParticipantsAt $scope $records $i)
   (if (< $i (size-atom $records))
     (let $record (index-atom $records $i)
       (if (C3SemanticDevelopmentRecordValid $record)
         (cons-atom (C3SemanticDevelopmentParticipant $scope $record)
           (AR3SemanticDevelopmentParticipantsAt $scope $records (+ $i 1)))
         (AR3SemanticDevelopmentParticipantsAt $scope $records (+ $i 1))))
     ()))

(= (AR3SemanticDevelopmentParticipantsForScope $scope)
   (AR3SemanticDevelopmentParticipantsAt $scope
     (AR3SemanticDevelopmentRecordsForScope $scope) 0))

(= (AR2PayloadHead $payload $head)
   (and (is-expr $payload)
     (and (> (size-atom $payload) 0)
          (== (index-atom $payload 0) $head))))

(= (AR3ModelHistoryPayloadValid $payload)
   (if (CPShape $payload model-reading-incorporated-v2 7)
     (let* (($question (index-atom $payload 1))
            ($observation (index-atom $payload 2))
            ($count (index-atom $payload 5)))
       (and (CPShape $question c3-semantic-question-v1 11)
        (and (C3ModelObservationValid $observation $question)
         (and (== (index-atom $payload 3) (index-atom $question 4))
          (and (CPShape (index-atom $payload 4) movement-reference 5)
           (and (CPShape $count model-participant-count 2)
            (and (== (index-atom $count 1)
                   (size-atom (index-atom (index-atom $observation 9) 1)))
                 (== (index-atom $payload 6)
                   provider-proposals-participated-before-next-formation))))))))
     (if (CPShape $payload model-reading-unavailable-v1 3)
       (let $question (index-atom $payload 1)
         (and (CPShape $question c3-semantic-question-v1 11)
              (C3ModelObservationUnavailableValid
                (index-atom $payload 2) $question)))
       false)))

(= (AR2HistoryValid $row)
   (let* (($row-valid (CPShape $row assistant-history 5))
          ($is-encounter (if $row-valid
            (== (index-atom $row 1) encounter) false)))
     (if $is-encounter
       (let* (($scope-valid (CPShape (index-atom $row 3) scope 4))
              ($payload-valid
                (AR2EncounterHistoryPayloadValid (index-atom $row 4))))
         (and $scope-valid $payload-valid))
       (if (and $row-valid (== (index-atom $row 1) voice-proof))
         (and (CPShape (index-atom $row 3) scope 4)
              (AR2NativeMovementProofValid (index-atom $row 4)))
         (if (and $row-valid (== (index-atom $row 1) model-reading))
           (and (CPShape (index-atom $row 3) scope 4)
                (AR3ModelHistoryPayloadValid (index-atom $row 4)))
         (if (and $row-valid (== (index-atom $row 1) consequence))
           (let $payload (index-atom $row 4)
             (if (AR2PayloadHead $payload consequence-incorporation-v3)
               (and (AR2ConsequenceHistoryPayloadValid $payload)
                 (== (index-atom (index-atom (index-atom $payload 1) 2) 5)
                   (index-atom $row 3)))
               (if (AR2PayloadHead $payload consequence-incorporation-v4)
                 (and (AR2ConsequenceHistoryPayloadV4Valid $payload)
                      (== (index-atom (index-atom $payload 1) 1)
                        (index-atom $row 3)))
                 (if (AR2PayloadHead $payload consequence-incorporation-v5)
                   (and (AR3ConsequenceHistoryPayloadV5Valid $payload)
                     (and (== (index-atom (index-atom $payload 1) 1)
                            (index-atom $row 3))
                          (== (AR3SemanticDevelopmentReferenceId
                                (index-atom $payload 5))
                            (index-atom $row 2))))
                   (ARHistoryValid $row)))))
           (ARHistoryValid $row)))))))

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

; Voice proof restored into the authority-grounded runtime must re-form through
; the v3 constitutive basis, not merely satisfy the earlier carrier shape.
(= (AR2NativeMovementProofValid $proof)
   (if (CPShape $proof native-movement-proof-v1 5)
     (let* (($cut (index-atom $proof 1))
            ($scope (index-atom $proof 2))
            ($movement (index-atom $proof 3))
            ($participants (index-atom $proof 4)))
       (and (CPCutValid $cut)
        (and (== (index-atom $cut 3) $scope)
         (and (ARMovementValid $movement)
          (and (AR2MovementConstitutivelyConsistent $cut $movement)
               (CPShape $participants participant-reentry-organization 4))))))
     false))

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

; Once consequence has formed the next cut, its history payload—not the
; original encounter payload—is the exact developmental lineage for that new
; active movement. Collecting by structural cut/movement identity avoids a
; latest-row convention and lets the same organism receive further contact.
(= (AR2ConsequencePayloadsForScope $scope)
   (collapse (match &assistant_history
     (assistant-history consequence $id $scope $payload) $payload)))

(= (AR2ConsequencePayloadMatchesMovement $payload $cut $movement)
   (if (AR2ConsequenceHistoryPayloadValid $payload)
     (let* (($next (index-atom $payload 1))
            ($encounter (index-atom $next 1)))
       (and (== (index-atom $encounter 1) $cut)
            (== (AREncounterMovement $encounter) $movement)))
     (if (AR2ConsequenceHistoryPayloadV4Valid $payload)
       (let $next (index-atom $payload 1)
         (and (== (index-atom $next 2) (index-atom $cut 1))
              (== (index-atom $next 3)
                (CP2MovementReference $cut $movement))))
       (if (AR3ConsequenceHistoryPayloadV5Valid $payload)
         (let $next (index-atom $payload 1)
           (and (== (index-atom $next 2) (index-atom $cut 1))
                (== (index-atom $next 3)
                  (CP2MovementReference $cut $movement))))
         false))))

(= (AR2ConsequenceDevelopmentalMatchesAt $payloads $cut $movement $i $out)
   (if (< $i (size-atom $payloads))
     (let $payload (index-atom $payloads $i)
       (if (and (AR2ConsequenceHistoryPayloadValid $payload)
                (AR2ConsequencePayloadMatchesMovement $payload $cut $movement))
         (let* (($next (index-atom $payload 1))
                ($transition (index-atom $next 2))
                ($developmental (index-atom $transition 2)))
           (AR2ConsequenceDevelopmentalMatchesAt $payloads $cut $movement
             (+ $i 1) (cons-atom $developmental $out)))
         (AR2ConsequenceDevelopmentalMatchesAt $payloads $cut $movement
           (+ $i 1) $out)))
     $out))

(= (AR2DevelopmentalForMovement $scope $cut $movement)
   (let* (($basis (AR2MovementBasis $movement))
          ($basis-developmental (if
            (CPShape $basis continuation-basis-v3 6)
              (index-atom $basis 5)
              (m24-developmental-organization-unresolved
                no-v3-continuation-basis))))
     (if (and (M24DevelopmentalOrganizationValid $basis-developmental)
              (== (index-atom $cut 3) $scope))
       $basis-developmental
       (let* (($encounter-payloads (AR2EncounterPayloadsForScope $scope))
              ($consequence-payloads (AR2ConsequencePayloadsForScope $scope))
              ($encounter-matches (AR2DevelopmentalMatchesAt
                $encounter-payloads $cut $movement 0 ()))
              ($consequence-matches (AR2ConsequenceDevelopmentalMatchesAt
                $consequence-payloads $cut $movement 0 ()))
              ($matches (CPListAppend $encounter-matches
                $consequence-matches)))
         (if (== (size-atom $matches) 1)
           (index-atom $matches 0)
           (m24-developmental-organization-unresolved
             missing-or-ambiguous-active-movement-lineage))))))

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

(= (AR2M255ReorganizationParticipants $scope $cut $movement $next-cut
      $consequence)
   (let* (($witness (M255ConsequenceReorganization $cut $movement $next-cut
            $consequence))
          ($target (M255ConsequenceParticipationTarget $witness))
          ($consequence-id (index-atom $consequence 1)))
     (if (M255ConsequenceReorganizationValid $witness $cut $movement
           $next-cut $consequence)
       ((participant-contribution
          (m255-native-reorganization-participation $consequence-id)
          native-authority $scope
          (lineage Inquiry-25.5-one-engine-participation
            (index-atom $movement 2))
          (participant-relation-claim $target support
            (m255-developmental-evidence
              (M255NativeOneEngineBasis $witness)))
          supported no-contact-no-movement-authority)
        (participant-contribution
          (m255-returned-contact-participation $consequence-id)
          returned-contact $scope
          (lineage returned-consequence $consequence-id)
          (participant-relation-claim $target support
            (returned-contact-evidence
              (index-atom $consequence 12)
              (M255ReturnedReorganizationBasis $witness)))
          supported no-contact-no-movement-authority))
       ())))

; M25.5 change categories are not post-hoc labels. Two differentiated
; lineages make each valid same-law cross-cut witness available as a material
; relation before the next cut's single R/A/P read: native law supplies the
; category meaning, while returned contact supplies the actual transition.
; Neither participant may choose a movement or claim contact authority.
(= (AR2M255ChangeParticipantPair $scope $movement $consequence $witness)
   (let* (($category (M255CrossCutChangeCategory $witness))
          ($target (M255CrossCutChangeTarget $witness))
          ($consequence-id (index-atom $consequence 1)))
     ((participant-contribution
        (m255-change-native-participation $category $consequence-id)
        native-authority $scope
        (lineage Inquiry-25.5-generative-change $category)
        (participant-relation-claim $target support
          (m255-same-law-category-evidence $category
            (movement-reference (index-atom $movement 2))))
        supported no-contact-no-movement-authority)
      (participant-contribution
        (m255-change-returned-participation $category $consequence-id)
        returned-contact $scope
        (lineage returned-consequence $consequence-id)
        (participant-relation-claim $target support
          (m255-cross-cut-change-evidence
            (returned-consequence-reference $consequence-id
              (index-atom $consequence 2) (index-atom $consequence 4)
              (index-atom $consequence 12))
            $witness))
        supported no-contact-no-movement-authority))))

(= (AR2M255ChangeParticipantsAt $scope $cut $movement $next-cut
      $consequence $changes $i)
   (if (< $i (size-atom $changes))
     (let $witness (index-atom $changes $i)
       (if (M255CrossCutChangeValid $witness $cut $movement $next-cut
             $consequence)
         (CPListAppend
           (AR2M255ChangeParticipantPair $scope $movement $consequence
             $witness)
           (AR2M255ChangeParticipantsAt $scope $cut $movement $next-cut
             $consequence $changes (+ $i 1)))
         (AR2M255ChangeParticipantsAt $scope $cut $movement $next-cut
           $consequence $changes (+ $i 1))))
     ()))

; Reflexive constraint is admitted only as a conjunction of two independently
; attributable premises: native M25.5 supplies the typed dependence law and
; returned contact supplies the actual severing that changed Access.  The
; witness is constructed against the participant-free next projection, so it
; cannot use its own participant relation as a premise.
(= (AR2M255ReflexiveParticipants $scope $cut $movement $next-cut
      $consequence)
   (let* (($witness (M255ReflexiveConstraintTransition $cut $movement
            $next-cut $consequence))
          ($consequence-id (index-atom $consequence 1)))
     (if (M255ReflexiveConstraintTransitionValid $witness $cut $movement
           $next-cut $consequence)
       ((participant-contribution
          (m255-reflexive-native-participation $consequence-id)
          native-authority $scope
          (lineage Inquiry-25.5-reflexive-constraint
            (index-atom $movement 2))
          (participant-relation-claim m255-reflexive-constraint-participation
            support
            (m255-self-representation-dependence-evidence
              (index-atom $witness 4)))
          supported no-contact-no-movement-authority)
        (participant-contribution
          (m255-reflexive-returned-participation $consequence-id)
          returned-contact $scope
          (lineage returned-consequence $consequence-id)
          (participant-relation-claim m255-reflexive-constraint-participation
            support
            (m255-severing-bite-evidence
              (returned-consequence-reference $consequence-id
                (index-atom $consequence 2) (index-atom $consequence 4)
                (index-atom $consequence 12))
              (index-atom $witness 5)))
          supported no-contact-no-movement-authority))
       ())))

(= (AR2M255ConsequenceParticipants $scope $cut $movement $next-cut
      $consequence)
   (let $changes (M255CrossCutChanges $cut $movement $next-cut $consequence)
     (CPListAppend
       (AR2M255ReorganizationParticipants $scope $cut $movement $next-cut
         $consequence)
       (CPListAppend
         (AR2M255ChangeParticipantsAt $scope $cut $movement $next-cut
           $consequence $changes 0)
         (AR2M255ReflexiveParticipants $scope $cut $movement $next-cut
           $consequence)))))

(= (AR2ReconstituteAfterConsequence $scope $cut $movement $consequence)
   (let* (($basis (AR2MovementBasis $movement))
          ($prior (AR2DevelopmentalForMovement $scope $cut $movement))
          ($probe-basis (M24ConsequenceBasisForMovement $movement))
          ($next-cut (CPNextCutV2 $cut $consequence))
          ($base-next-cut (CPBaseCutWithoutParticipantRelations $next-cut))
          ($transition (M24DevelopmentalTransition $prior $probe-basis
            $consequence $scope $base-next-cut))
          ($m255-participants (AR2M255ConsequenceParticipants $scope $cut
            $movement $base-next-cut $consequence))
          ($c3-participants (C3ConsequenceParticipants $scope $cut $movement
            $prior $consequence)))
     (if (and (or (CPShape $basis continuation-basis-v2 5)
                  (CPShape $basis continuation-basis-v3 6))
           (and (M24DevelopmentalTransitionValid $transition)
                (CPCutValid $base-next-cut)))
       (let* (($evolved (index-atom $transition 2))
              ($flourishing-views (CPListAppend (index-atom $basis 2)
                (index-atom (index-atom $consequence 10) 1)))
              ($participant-source (CPListAppend (index-atom $basis 3)
                (CPListAppend
                  (AR2ConsequenceParticipants $scope $evolved $consequence)
                  (CPListAppend $m255-participants $c3-participants))))
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
                  (AR3ConsequenceHistoryV5 $scope $cut $movement $next-cut
                    $next-movement (index-atom $next-organization 2)
                    $consequence))
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
                    ($developmental-participants
                      (AR3SemanticDevelopmentParticipantsForScope $scope))
                    ($participating-contact (if
                      (> (size-atom $developmental-participants) 0)
                      (CP2ContactWithAuthorityParticipants $contact
                        $developmental-participants)
                      $contact))
                    ($grounded (CP2Encounter $participating-contact
                      $predecessor)))
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

; A provider may participate only after returned consequence has opened an
; exact partial-alignment inquiry and before the next movement is formed.  The
; question carries the source Fact9/flourishing material selected by native
; construction plus returned-contact material.  Provider candidates remain
; unresolved participants: they cannot define relevance, alignment, contact,
; authority, or choice.
(= (AR3PreformationModelReading $root $question $consequence-id $model-writer)
   (if (ARHistoryHas model-reading $consequence-id)
       (preformation-model-reading-held
         prior-model-reading-without-consequence-history)
       (let $observation ($model-writer $root $question)
         (if (C3ModelObservationValid $observation $question)
           (preformation-model-reading-v1 $question $observation
             (C3ModelParticipants $observation $question)
             model-reading-incorporated)
           (if (C3ModelObservationUnavailableValid $observation $question)
             (preformation-model-reading-v1 $question $observation ()
               model-reading-unavailable)
             (preformation-model-reading-held
               malformed-model-observation))))))

(= (AR3PreformationModelReadingUsable $reading)
   (if (CPShape $reading preformation-model-reading-v1 5)
     (or (== (index-atom $reading 4) model-reading-incorporated)
         (== (index-atom $reading 4) model-reading-unavailable))
     (CPShape $reading preformation-model-reading-not-requested 2)))

(= (AR3PreformationModelParticipants $reading)
   (if (CPShape $reading preformation-model-reading-v1 5)
     (if (== (index-atom $reading 4) model-reading-incorporated)
       (index-atom $reading 3) ())
     ()))

(= (AR3PreformationQuestionParticipants $reading)
   (if (CPShape $reading preformation-model-reading-v1 5)
     (if (== (index-atom $reading 4) model-reading-incorporated)
       (C3SemanticQuestionParticipant (index-atom $reading 1)) ())
     ()))

; The returned consequence, M25.5/M26.6 laboratory participation, and any
; bounded semantic proposals all enter one participant source.  M25 then forms
; the next constitutive encounter once, preserving one runtime and one clock.
(= (AR3ReconstituteAfterConsequence $root $scope $cut $movement $consequence
      $model-writer)
   (let* (($basis (AR2MovementBasis $movement))
          ($prior (AR2DevelopmentalForMovement $scope $cut $movement))
          ($probe-basis (M24ConsequenceBasisForMovement $movement))
          ($next-cut (CPNextCutV2 $cut $consequence))
          ($base-next-cut (CPBaseCutWithoutParticipantRelations $next-cut))
          ($transition (M24DevelopmentalTransition $prior $probe-basis
            $consequence $scope $base-next-cut))
          ($m255-participants (AR2M255ConsequenceParticipants $scope $cut
            $movement $base-next-cut $consequence))
          ($c3-participants (C3ConsequenceParticipants $scope $cut $movement
            $prior $consequence)))
     (if (and (or (CPShape $basis continuation-basis-v2 5)
                  (CPShape $basis continuation-basis-v3 6))
           (and (M24DevelopmentalTransitionValid $transition)
                (CPCutValid $base-next-cut)))
       (let* (($evolved (index-atom $transition 2))
              ($source-facts (CPFactExpressionsAt $cut
                (index-atom $basis 1) 0))
              ($source-flourishing (CPFlourishingOrganizationV2 $cut
                (index-atom $basis 2)))
              ; A semantic provider's returned candidate is new contact for
              ; native consequence interpretation.  It may not recursively
              ; trigger another provider call before Miter has incorporated
              ; and compared that contact through the full authority joint.
              ; Any later consultation must be newly formed by that changed
              ; native organization.
              ($semantic-return (CPShape
                (C3SemanticInquirySurfaceFromMovement $movement)
                c3-semantic-inquiry-surface-v1 8))
              ($model-reading (if $semantic-return
                (preformation-model-reading-not-requested
                  semantic-inquiry-return-requires-native-incorporation)
                (let $question (C3SemanticQuestionFromConsequence $scope $cut
                      $movement $prior $consequence $source-facts
                      $source-flourishing)
                  (if (CPShape $question c3-semantic-question-v1 11)
                    (AR3PreformationModelReading $root $question
                      (index-atom $consequence 1) $model-writer)
                    (preformation-model-reading-not-requested
                      no-consequence-earned-partial-alignment-question))))))
         (if (AR3PreformationModelReadingUsable $model-reading)
           (let* (($semantic-participants
                    (C3SemanticConsequenceParticipants $scope $movement
                      $consequence))
                  ($prior-participants
                    (C3ParticipantsAfterSemanticConsequence
                      (index-atom $basis 3) $movement $consequence))
                  ($flourishing-views (CPListAppend (index-atom $basis 2)
                    (index-atom (index-atom $consequence 10) 1)))
                  ($participant-source (CPListAppend $prior-participants
                    (CPListAppend
                      (AR2ConsequenceParticipants $scope $evolved $consequence)
                      (CPListAppend $m255-participants
                        (CPListAppend $c3-participants
                         (CPListAppend $semantic-participants
                          (CPListAppend
                            (AR3PreformationQuestionParticipants
                              $model-reading)
                            (AR3PreformationModelParticipants
                              $model-reading))))))))
                  ($next (M25ConstitutiveEncounter $base-next-cut
                    (index-atom $basis 1) $flourishing-views
                    $participant-source (index-atom (index-atom $basis 4) 1)
                    $evolved)))
             (if (and (CPShape $next constitutive-encounter 7)
                      (CPDRelationKnown (index-atom $next 1)
                        m24-consequence-developmental-grounding))
               (ar3-next-constitutive-result-v1
                 (next-constitutive-organization-v3 $next $transition)
                 $model-reading)
               (ar3-next-constitutive-result-unresolved
                 developmental-participation-not-causal $model-reading)))
           (ar3-next-constitutive-result-unresolved
             model-reading-malformed-or-incoherent $model-reading)))
       (ar3-next-constitutive-result-unresolved
         missing-basis-developmental-lineage-or-valid-transition
         (preformation-model-reading-not-requested invalid-transition)))))

(= (AR3RecordModelReading $id $scope $next-cut $next-movement $reading)
   (if (CPShape $reading preformation-model-reading-v1 5)
     (let* (($question (index-atom $reading 1))
            ($observation (index-atom $reading 2))
            ($standing (index-atom $reading 4)))
       (if (== $standing model-reading-incorporated)
         (let* (($count (size-atom (index-atom $reading 3)))
                ($history (ARRecord model-reading $id $scope
                  (model-reading-incorporated-v2 $question $observation
                    (index-atom $question 4)
                    (CP2MovementReference $next-cut $next-movement)
                    (model-participant-count $count)
                    provider-proposals-participated-before-next-formation))))
           (if (== $history assistant-history-recorded)
             (assistant-model-reading-incorporated $id
               (model-participant-count $count)
               (ARMovementSummary $next-movement))
             (assistant-model-reading-held $id $history)))
         (if (== $standing model-reading-unavailable)
           (let $history (ARRecord model-reading $id $scope
                  (model-reading-unavailable-v1 $question $observation))
             (assistant-model-reading-unavailable $id
               (index-atom $observation 4) $history))
           (assistant-model-reading-held $id unknown-model-reading-standing))))
     (if (CPShape $reading preformation-model-reading-not-requested 2)
       model-participation-not-requested
       (assistant-model-reading-held $id malformed-preformation-reading))))

(= (AR3IncorporateConsequenceV4 $root $id $scope $cut $movement $consequence
      $model-writer)
   (let $result (AR3ReconstituteAfterConsequence $root $scope $cut $movement
          $consequence $model-writer)
     (if (CPShape $result ar3-next-constitutive-result-v1 3)
       (let* (($next-organization (index-atom $result 1))
              ($model-reading (index-atom $result 2))
              ($encounter (index-atom $next-organization 1))
              ($next-cut (index-atom $encounter 1))
              ($next-movement (AREncounterMovement $encounter))
              ($state (ARReplaceActive $scope $next-cut $next-movement))
              ($history (if (== $state assistant-active-replaced)
                (ARRecord consequence $id $scope
                  (AR3ConsequenceHistoryV5 $scope $cut $movement $next-cut
                    $next-movement (index-atom $next-organization 2)
                    $consequence))
                state-not-recorded)))
         (if (== $history assistant-history-recorded)
           (let $model-outcome (AR3RecordModelReading $id $scope $next-cut
                  $next-movement $model-reading)
             (assistant-processed-v3
               (assistant-consequence-incorporated $id $next-organization)
               $model-outcome))
           (assistant-processed-v3
             (assistant-consequence-held $id $history)
             model-participation-not-requested)))
       (assistant-processed-v3
         (assistant-consequence-held $id $result)
         model-participation-not-requested))))

(= (AssistantConsequenceV3 $root $scope $consequence $model-writer)
   (if (and (CPShape $scope scope 4) (CPConsequenceValid $consequence))
     (let* (($id (index-atom $consequence 1))
            ($active (ARActiveRows $scope)))
       (if (ARHistoryHas consequence $id)
         (assistant-processed-v3 (assistant-consequence-duplicate $id)
           model-participation-not-requested)
         (if (!= (size-atom $active) 1)
           (assistant-processed-v3
             (assistant-consequence-held $id active-cut-unavailable)
             model-participation-not-requested)
           (let* (($organization (index-atom $active 0))
                  ($cut (index-atom $organization 2))
                  ($movement (index-atom $organization 3)))
             (if (ARConsequenceMovementMatches $movement $consequence)
               (if (CPConsequenceV2Valid $consequence)
                 (AR3IncorporateConsequenceV4 $root $id $scope $cut $movement
                   $consequence $model-writer)
                 (assistant-processed-v3
                   (ARIncorporateConsequenceV1 $id $scope $cut $movement
                     $consequence)
                   model-participation-not-requested))
               (assistant-processed-v3
                 (assistant-consequence-held $id movement-link-mismatch)
                 model-participation-not-requested))))))
     (assistant-processed-v3
       (assistant-consequence-rejected malformed-scope-or-consequence)
       model-participation-not-requested)))

(= (AssistantInputWithModelV3 $root $input $model-writer)
   (if (and (CPShape $input assistant-input 4)
            (== (index-atom $input 1) consequence))
     (AssistantConsequenceV3 $root (index-atom $input 2)
       (index-atom $input 3) $model-writer)
     (assistant-processed-v3 (AssistantInputV2 $input)
       model-participation-not-requested)))

; Inputs remain sequential inside the one supported reactor cycle. A returned
; consequence and its optional thought-partner participation therefore complete
; before another contact can replace the active constitutive organization.
(= (AssistantProcessWithModelAt $root $inputs $model-writer $i)
   (if (< $i (size-atom $inputs))
     (cons-atom
       (AssistantInputWithModelV3 $root (index-atom $inputs $i) $model-writer)
       (AssistantProcessWithModelAt $root $inputs $model-writer (+ $i 1)))
     ()))

(= (AR3InputResultsAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom (index-atom (index-atom $rows $i) 1)
       (AR3InputResultsAt $rows (+ $i 1))) ()))

(= (AR3ModelOutcomesAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom (index-atom (index-atom $rows $i) 2)
       (AR3ModelOutcomesAt $rows (+ $i 1))) ()))

(= (AR3ModelOutcomeValid $outcome)
   (or (== $outcome model-participation-not-requested)
     (or (CPShape $outcome assistant-model-reading-incorporated 4)
      (or (CPShape $outcome assistant-model-reading-unavailable 4)
       (or (CPShape $outcome assistant-model-reading-duplicate 2)
           (CPShape $outcome assistant-model-reading-held 3))))))

(= (AR3ModelOutcomesValidAt $outcomes $i)
   (if (< $i (size-atom $outcomes))
     (and (AR3ModelOutcomeValid (index-atom $outcomes $i))
          (AR3ModelOutcomesValidAt $outcomes (+ $i 1))) true))

(= (AssistantCycleStepV3 $root $inputs $model-writer)
   (if (is-expr $inputs)
     (let $rows (AssistantProcessWithModelAt $root $inputs $model-writer 0)
       (assistant-cycle-step-v3 (AR3InputResultsAt $rows 0)
         (AR3ModelOutcomesAt $rows 0) (AssistantSnapshot)))
     (assistant-cycle-step-v3 ((assistant-input-rejected malformed-batch))
       (model-participation-not-requested) (AssistantSnapshot))))

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
               (let* (($step (AssistantCycleStepV3 $root $inputs $model-writer))
                      ($results (index-atom $step 1))
                      ($model-outcomes (index-atom $step 2))
                      ($effects (AREffectsAt $root $results $effect-writer 0))
                      ($valid (and (AR3ModelOutcomesValidAt $model-outcomes 0)
                                   (AREffectsValidAt $effects 0))))
                 (if $valid
                   (let* (($snapshot (AssistantSnapshot))
                          ($checkpoint ($checkpoint-writer $root $snapshot))
                          ($record ($recorder $root assistant-cycle-v3
                            (cycle-standing contact-consequence-and-model
                              $idle $checkpoint))))
                     (if (== $checkpoint checkpointed)
                       (AssistantCycleWithV3 $root false $next $base $cap
                         $control-reader $input-reader $checkpoint-writer
                         $waiter $recorder $effect-writer $model-writer)
                       (assistant-service-held (checkpoint $checkpoint))))
                   (let $record ($recorder $root assistant-cycle-held-v3
                          (held-outcomes $model-outcomes $effects))
                     (assistant-service-held
                       (model-or-effect-outcomes $model-outcomes $effects)))))
               (let $wait ($waiter $root $interval)
                 (AssistantCycleWithV3 $root true $next $base $cap
                   $control-reader $input-reader $checkpoint-writer $waiter
                   $recorder $effect-writer $model-writer))))))
       (assistant-cycle-held malformed-control))))

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

(= (AssistantServiceStartV3 $root)
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
             (let $start-record (as_record $root assistant-started-v3
                    (startup-restoration $restoration $continuity-restoration
                      $semantic-restoration))
               (AssistantCycleWithV3 $root false $base $base $cap
                 as_control as_input as_checkpoint as_wait as_record as_effect
                 as_model))))))))
