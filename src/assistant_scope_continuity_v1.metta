; AMA-1.2 stable-scope admission at the native boundary.
; The Prolog membrane can establish exact carrier identity and configured scope;
; only native cognition admits the resulting contact and preserves the binding
; in developmental history. No surface identity supplies semantic movement.

(= (ACScopeBindingValid $binding $contact)
   (and (CPShape $binding scope-binding-v1 6)
     (and (CPShape (index-atom $binding 1) surface-route 6)
      (and (CPShape (index-atom $binding 2) scope 4)
       (and (CPShape (index-atom $binding 3) surface-event 4)
        (and (== (index-atom $binding 4) authorized-before-payload-cognition)
         (and (CPShape (index-atom $binding 5) binding-record 3)
          (and (== (index-atom $binding 2) (CPContactScope $contact))
               (== (index-atom (index-atom $binding 3) 1)
                   (index-atom $contact 1))))))))))

(= (ACContinuityValid $projection)
   (if (CPShape $projection continuity-projection-v1 13)
     (and (CPShape (index-atom $projection 1) scope 4)
      (and (CPShape (index-atom $projection 2) trajectory-plane 6)
       (and (CPShape (index-atom $projection 3) capsule-plane 14)
        (and (CPShape (index-atom $projection 4) raw-artifact-plane 4)
         (and (CPShape (index-atom $projection 5) semantic-plane 5)
          (and (CPShape (index-atom $projection 6) relationship-organization 2)
           (and (CPShape (index-atom $projection 7) undertaking-organization 4)
            (and (CPShape (index-atom $projection 8) attention-organization 3)
             (and (CPShape (index-atom $projection 9) rna-organization 3)
              (and (CPShape (index-atom $projection 10)
                     pending-consequence-organization 2)
               (and (CPShape (index-atom $projection 11)
                      learned-relation-organization 2)
                    (CPShape (index-atom $projection 12) source-lineage 4))))))))))))
     false))

(= (ACContinuityRows $scope)
   (collapse (match &assistant_continuity
     (continuity-projection-v1 $scope $trajectory $capsule $raw $semantic
       $relationships $undertaking $attention $rna $pending $learned $lineage)
     (continuity-projection-v1 $scope $trajectory $capsule $raw $semantic
       $relationships $undertaking $attention $rna $pending $learned $lineage))))

(= (ACContinuitySpaceEmpty)
   (== (size-atom (collapse (match &assistant_continuity $atom $atom))) 0))

(= (ACContinuityAllValid $rows $i)
   (if (< $i (size-atom $rows))
     (and (ACContinuityValid (index-atom $rows $i))
          (ACContinuityAllValid $rows (+ $i 1))) true))

(= (ACContinuityScopesUnique $rows $i $seen)
   (if (< $i (size-atom $rows))
     (let $scope (index-atom (index-atom $rows $i) 1)
       (if (CPHas $scope $seen 0) false
         (ACContinuityScopesUnique $rows (+ $i 1) (cons-atom $scope $seen)))) true))

(= (ACContinuityAddAll $rows $i)
   (if (< $i (size-atom $rows))
     (let* (($row (index-atom $rows $i))
            ($added (add-atom &assistant_continuity $row)))
       (ACContinuityAddAll $rows (+ $i 1))) assistant-continuity-restored))

(= (AssistantContinuityRestore $source-set)
   (if (CPShape $source-set continuity-source-set-v1 2)
     (let $rows (index-atom $source-set 1)
       (if (and (is-expr $rows)
             (and (ACContinuitySpaceEmpty)
              (and (ACContinuityAllValid $rows 0)
                   (ACContinuityScopesUnique $rows 0 ()))))
         (if (== (size-atom $rows) 0) assistant-continuity-new
           (ACContinuityAddAll $rows 0))
         assistant-continuity-restore-rejected))
     assistant-continuity-restore-rejected))

(= (ACContinuityForScope $scope)
   (let $rows (ACContinuityRows $scope)
     (if (== (size-atom $rows) 0) (continuity-standing no-source-for-scope)
       (if (== (size-atom $rows) 1) (index-atom $rows 0)
         (continuity-standing conflicting-sources-for-scope)))))

(= (ACMergeRowsAt $rows $derived $i)
   (if (< $i (size-atom $derived))
     (let $row (index-atom $derived $i)
       (if (== (size-atom (CPFind $rows (index-atom $row 1))) 0)
         (ACMergeRowsAt (CPListAppend $rows ($row)) $derived (+ $i 1))
         (ACMergeRowsAt $rows $derived (+ $i 1)))) $rows))

(= (ACRelationsFromIdsAt $ids $kind $evidence $i)
   (if (< $i (size-atom $ids))
     (cons-atom (relation (index-atom $ids $i) $kind support $evidence)
       (ACRelationsFromIdsAt $ids $kind $evidence (+ $i 1))) ()))

(= (ACThreadsFromIdsAt $ids $standing $evidence $i)
   (if (< $i (size-atom $ids))
     (cons-atom (thread (index-atom $ids $i) $standing $evidence)
       (ACThreadsFromIdsAt $ids $standing $evidence (+ $i 1))) ()))

(= (ACContinuityRelations $projection)
   (let* (($trajectory (index-atom $projection 2))
          ($capsule (index-atom $projection 3))
          ($relationships (index-atom $projection 6))
          ($undertaking (index-atom $projection 7))
          ($attention (index-atom $projection 8))
          ($rna (index-atom $projection 9))
          ($learned (index-atom $projection 11))
          ($lineage (index-atom $projection 12)))
     (CPListAppend
       ((relation continuity-trajectory-current continuity support
          (trajectory-evidence (index-atom $trajectory 2)
            (index-atom $trajectory 3) (index-atom $trajectory 4)))
        (relation continuity-capsule-current continuity support
          (capsule-evidence (index-atom $capsule 1)
            (index-atom $capsule 5) (index-atom $capsule 6)
            (index-atom $capsule 8) (index-atom $capsule 9)
            (index-atom $capsule 10) (index-atom $capsule 11)))
        (relation continuity-artifact-current continuity support
          (artifact-evidence (index-atom $capsule 3) (index-atom $capsule 4)))
        (relation continuity-undertaking-current continuity support
          (undertaking-evidence (index-atom $undertaking 1)
            (index-atom $undertaking 2) (index-atom $undertaking 3)))
        (relation continuity-attention-current continuity support
          (attention-evidence (index-atom $attention 1)
            (index-atom $attention 2)))
        (relation continuity-rna-current continuity support
          (rna-evidence (index-atom $rna 1) (index-atom $rna 2))))
       (CPListAppend
         (ACRelationsFromIdsAt (index-atom $relationships 1)
           continuity-relationship (index-atom $lineage 1) 0)
         (ACRelationsFromIdsAt (index-atom $learned 1)
           continuity-learned-relation (index-atom $lineage 1) 0)))))

(= (ACContactWithContinuity $contact $projection)
   (if (and (CPShape $contact contact-v2 11) (ACContinuityValid $projection))
     (let* (($configuration (CPContactConfiguration $contact))
            ($old-d (index-atom $configuration 1))
            ($old-i (index-atom $configuration 3))
            ($old-w (index-atom $configuration 4))
            ($old-c (index-atom $configuration 5))
            ($capsule (index-atom $projection 3))
            ($undertaking (index-atom $projection 7))
            ($attention (index-atom $projection 8))
            ($pending (index-atom $projection 10))
            ($lineage (index-atom $projection 12))
            ($relations (ACContinuityRelations $projection))
            ($new-d (D
              (CPMergeNewRelationsAt (index-atom $old-d 1) $relations 0)
              (ACMergeRowsAt (index-atom $old-d 2)
                ((distinction continuity-exact-vs-semantic available
                   (index-atom $capsule 1))) 0)))
            ($new-i (I (ACMergeRowsAt (index-atom $old-i 1)
              ((interface interface-exact-continuity open
                 (index-atom $capsule 4))) 0)))
            ($continuity-weave (CPListAppend
              ((thread (index-atom $undertaking 1) continued
                 (index-atom $capsule 1)))
              (CPListAppend
                (ACThreadsFromIdsAt (index-atom $undertaking 2) open
                  (index-atom $lineage 1) 0)
                (ACThreadsFromIdsAt (index-atom $pending 1) pending
                  (index-atom $lineage 1) 0))))
            ($new-w (W (ACMergeRowsAt (index-atom $old-w 1)
              $continuity-weave 0)))
            ($new-c (C (ACMergeRowsAt (index-atom $old-c 1)
              ((soul-relation relation-continuity-of-mind material
                 (index-atom $capsule 1))) 0)))
            ($new-flourishing (CPListAppend (index-atom $configuration 8)
              ((flourishing-view TimeCoherence continuity-capsule-current
                 beneficial-direction (index-atom $capsule 1))
               (flourishing-view AttentionStewardship continuity-attention-current
                 beneficial-direction (index-atom $attention 1)))))
            ($new-configuration (encounter-configuration $new-d
              (index-atom $configuration 2) $new-i $new-w $new-c
              (index-atom $configuration 6) (index-atom $configuration 7)
              $new-flourishing (index-atom $configuration 9)
              (index-atom $configuration 10))))
       (contact-v2 (index-atom $contact 1) (index-atom $contact 2)
         (index-atom $contact 3) (index-atom $contact 4) (index-atom $contact 5)
         (index-atom $contact 6) (index-atom $contact 7) (index-atom $contact 8)
         $new-configuration
         (CPListAppend (CPContactParents $contact)
           ((index-atom (index-atom $projection 12) 1)))))
     $contact))
