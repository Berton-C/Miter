; Bounded semantic participation.
;
; Verified semantic observations enter the same constitutive contact as scoped,
; provenance-bearing participant contributions.  They remain derived readings:
; no retrieved item is contact, authority, a movement, or an instruction.  Rank
; is deliberately absent from native construction.  Unavailable, degraded, and
; incompatible sources remain explicit participants rather than causing amnesia
; or silently disappearing.

(= (ASSemanticParticipantValid $scope $participant)
   (and (CPShape $participant participant-contribution 8)
     (and (== (index-atom $participant 2) memory)
      (and (== (index-atom $participant 3) $scope)
       (let $lineage (index-atom $participant 4)
         (and (is-expr $lineage)
          (and (> (size-atom $lineage) 1)
           (and (== (index-atom $lineage 0) lineage)
            (and (CPShape (index-atom $participant 5) participant-relation-claim 4)
             (and (CPHas (index-atom $participant 6)
                    (candidate supported contradicted unresolved) 0)
                  (== (index-atom $participant 7)
                    no-contact-no-movement-authority)))))))))))

(= (ASSemanticParticipantsValidAt $scope $participants $i)
   (if (< $i (size-atom $participants))
     (and (ASSemanticParticipantValid $scope (index-atom $participants $i))
          (ASSemanticParticipantsValidAt $scope $participants (+ $i 1))) true))

(= (ASSemanticProjectionValid $projection)
   (if (CPShape $projection semantic-projection-v1 5)
     (let* (($scope (index-atom $projection 1))
            ($observation (index-atom $projection 2))
            ($participants-wrapper (index-atom $projection 3))
            ($lineage (index-atom $projection 4))
            ($standing (index-atom $observation 4))
            ($participants (index-atom $participants-wrapper 1)))
       (and (CPShape $scope scope 4)
        (and (CPShape $observation semantic-index-observation 9)
         (and (CPShape $participants-wrapper semantic-participants 2)
          (and (CPShape $lineage semantic-source-lineage 5)
           (and (CPHas $standing (available unavailable degraded incompatible) 0)
            (and (== (index-atom $observation 8) rank-not-authority)
             (and (is-expr $participants)
              (and (if (== $standing available) true
                     (== (size-atom $participants) 0))
                   (ASSemanticParticipantsValidAt $scope $participants 0))))))))))
     false))

(= (ASSemanticRows $scope)
   (collapse (match &assistant_semantic
     (semantic-projection-v1 $scope $observation $participants $lineage)
     (semantic-projection-v1 $scope $observation $participants $lineage))))

(= (ASSemanticSpaceEmpty)
   (== (size-atom (collapse (match &assistant_semantic $atom $atom))) 0))

(= (ASSemanticAllValid $rows $i)
   (if (< $i (size-atom $rows))
     (and (ASSemanticProjectionValid (index-atom $rows $i))
          (ASSemanticAllValid $rows (+ $i 1))) true))

(= (ASSemanticSourceIdsUniqueAt $rows $i $seen)
   (if (< $i (size-atom $rows))
     (let $id (index-atom (index-atom (index-atom $rows $i) 2) 1)
       (if (CPHas $id $seen 0) false
         (ASSemanticSourceIdsUniqueAt $rows (+ $i 1) (cons-atom $id $seen)))) true))

(= (ASSemanticAddAll $rows $i)
   (if (< $i (size-atom $rows))
     (let* (($row (index-atom $rows $i))
            ($added (add-atom &assistant_semantic $row)))
       (ASSemanticAddAll $rows (+ $i 1))) assistant-semantic-restored))

(= (AssistantSemanticRestore $source-set)
   (if (CPShape $source-set semantic-source-set-v1 2)
     (let $rows (index-atom $source-set 1)
       (if (and (is-expr $rows)
             (and (ASSemanticSpaceEmpty)
              (and (ASSemanticAllValid $rows 0)
                   (ASSemanticSourceIdsUniqueAt $rows 0 ()))))
         (if (== (size-atom $rows) 0) assistant-semantic-new
           (ASSemanticAddAll $rows 0))
         assistant-semantic-restore-rejected))
     (if (CPShape $source-set semantic-source-set-held 2)
       (assistant-semantic-restore-held (index-atom $source-set 1))
       assistant-semantic-restore-rejected)))

(= (ASSemanticForScope $scope)
   (let $rows (ASSemanticRows $scope)
     (if (== (size-atom $rows) 0) (semantic-standing no-source-for-scope)
       (semantic-scope-set $scope $rows))))

(= (ASSemanticStateParticipant $projection)
   (let* (($scope (index-atom $projection 1))
          ($observation (index-atom $projection 2))
          ($source-id (index-atom $observation 1))
          ($standing (index-atom $observation 4))
          ($reason (index-atom $observation 5))
          ($query-id (index-atom $observation 6)))
     (participant-contribution $source-id memory $scope
       (lineage $source-id $query-id)
       (participant-relation-claim relation-semantic-memory-availability
         unresolved $reason)
       unresolved no-contact-no-movement-authority)))

(= (ASSemanticProjectionParticipants $projection)
   (let* (($observation (index-atom $projection 2))
          ($standing (index-atom $observation 4))
          ($participants (index-atom (index-atom $projection 3) 1)))
     (if (== $standing available) $participants
       (cons-atom (ASSemanticStateParticipant $projection) ()))))

(= (ASSemanticParticipantsAt $projections $i)
   (if (< $i (size-atom $projections))
     (CPListAppend
       (ASSemanticProjectionParticipants (index-atom $projections $i))
       (ASSemanticParticipantsAt $projections (+ $i 1))) ()))

(= (ASSemanticParticipantIdsUniqueAt $participants $i $seen)
   (if (< $i (size-atom $participants))
     (let $id (index-atom (index-atom $participants $i) 1)
       (if (CPHas $id $seen 0) false
         (ASSemanticParticipantIdsUniqueAt $participants (+ $i 1)
           (cons-atom $id $seen)))) true))

(= (ASContactWithSemantic $contact $semantic)
   (if (CPShape $semantic semantic-standing 2) $contact
     (if (and (CPShape $contact contact-v2 11)
              (CPShape $semantic semantic-scope-set 3))
       (let* (($scope (index-atom $semantic 1))
              ($projections (index-atom $semantic 2))
              ($configuration (CPContactConfiguration $contact))
              ($prior (index-atom $configuration 10))
              ($added (ASSemanticParticipantsAt $projections 0))
              ($participants (CPListAppend $prior $added)))
         (if (and (== $scope (CPContactScope $contact))
                  (ASSemanticParticipantIdsUniqueAt $participants 0 ()))
           (let $new-configuration (encounter-configuration
                (index-atom $configuration 1) (index-atom $configuration 2)
                (index-atom $configuration 3) (index-atom $configuration 4)
                (index-atom $configuration 5) (index-atom $configuration 6)
                (index-atom $configuration 7) (index-atom $configuration 8)
                (index-atom $configuration 9) $participants)
             (contact-v2 (index-atom $contact 1) (index-atom $contact 2)
               (index-atom $contact 3) (index-atom $contact 4)
               (index-atom $contact 5) (index-atom $contact 6)
               (index-atom $contact 7) (index-atom $contact 8)
               $new-configuration (CPContactParents $contact)))
           (semantic-contact-held scope-or-participant-id-conflict)))
       (semantic-contact-held malformed-contact-or-semantic-scope-set))))

(= (ASSemanticStandingSummaryAt $projections $i)
   (if (< $i (size-atom $projections))
     (let $observation (index-atom (index-atom $projections $i) 2)
       (cons-atom (semantic-source-standing
          (index-atom $observation 1) (index-atom $observation 2)
          (index-atom $observation 3) (index-atom $observation 4)
          (index-atom $observation 5) (index-atom $observation 6)
          rank-not-authority)
         (ASSemanticStandingSummaryAt $projections (+ $i 1)))) ()))

(= (ASSemanticStandingSummary $semantic)
   (if (CPShape $semantic semantic-scope-set 3)
     (semantic-standing-summary (index-atom $semantic 1)
       (ASSemanticStandingSummaryAt (index-atom $semantic 2) 0))
     $semantic))
