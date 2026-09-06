; Inquiry-25.5 generative signatures and proof-relevant carrier translation.
; Pure MeTTa. These finite witnesses neither select a movement nor claim
; actuality, carrier identity, SameBecoming, or total carrier isomorphism.

(= (M255AllIn $xs $ys $i)
   (if (< $i (size-atom $xs))
     (and (CPHas (index-atom $xs $i) $ys 0)
          (M255AllIn $xs $ys (+ $i 1))) true))

(= (M255Fact9RecognitionIndices)
   (Gravity Balance Connection Precision Effortlessness Transformation Love
     Sacred Present))

(= (M255FirstEightRecognitionIndicesValidAt $indices $i)
   (if (< $i 8)
     (and (CPFirstEight (index-atom $indices $i))
          (M255FirstEightRecognitionIndicesValidAt $indices (+ $i 1)))
     true))

(= (M255Fact9RecognitionIndicesValid $indices)
   (if (== $indices (M255Fact9RecognitionIndices))
     (and (CPUniq $indices 0 ())
      (and (M255FirstEightRecognitionIndicesValidAt $indices 0)
           (CPPresent (index-atom $indices 8))))
     false))

; RecIdx is the constitutional nine-role vocabulary, not the IDs of whichever
; finite fact views happen to be present in one contact. PartialRec below
; supplies the cut-relative recognition values separately.
(= (M255RecognitionIdsAt $facts $i)
   (let $indices (M255Fact9RecognitionIndices)
     (if (< $i (size-atom $indices))
       (cons-atom (index-atom $indices $i)
         (M255RecognitionIdsAt $facts (+ $i 1))) ())))

(= (M255RecognizedFactBasesAt $facts $index $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (CPShape $fact fact9-expression 10)
         (if (and (CPHas $index (index-atom $fact 2) 0)
                  (== (index-atom $fact 6)
                    (composition can-compose recognized-compose)))
           (cons-atom
             (recognized-fact-basis (index-atom $fact 1)
               (index-atom $fact 2) (index-atom $fact 5)
               (index-atom $fact 9))
             (M255RecognizedFactBasesAt $facts $index (+ $i 1)))
           (M255RecognizedFactBasesAt $facts $index (+ $i 1)))
         (M255RecognizedFactBasesAt $facts $index (+ $i 1))))
     ()))

(= (M255PartialRecognitionValue $cut $facts $index)
   (if (== $index Present)
     (if (and (CPCutValid $cut) (CPPresent Present))
       (some (present-context-basis (index-atom $cut 11)
         (same-becoming (index-atom $cut 5) (index-atom $cut 1))))
       (none no-current-present-context))
     (if (CPFirstEight $index)
       (let $bases (M255RecognizedFactBasesAt $facts $index 0)
         (if (> (size-atom $bases) 0)
           (some (recognized-fact-bases $bases))
           (none no-current-recognition)))
       (none unknown-fact9-index))))

(= (M255PartialRecognition $cut $facts $index)
   (m255-partial-recognition-v1 $index (index-atom $cut 5)
     (M255PartialRecognitionValue $cut $facts $index)
     (source-cut (index-atom $cut 1))
     (provenance Inquiry-25.5-from-Inquiry-26.3 finite-contact-reading)
     no-generated-completeness-amalgamation-or-movement-authority))

(= (M255PartialRecognitionsAt $cut $facts $indices $i)
   (if (< $i (size-atom $indices))
     (cons-atom (M255PartialRecognition $cut $facts
                  (index-atom $indices $i))
       (M255PartialRecognitionsAt $cut $facts $indices (+ $i 1)))
     ()))

(= (M255RecognitionFamily $cut $facts)
   (let* (($indices (M255Fact9RecognitionIndices))
          ($rows (M255PartialRecognitionsAt $cut $facts $indices 0)))
     (m255-recognition-family-v1 (index-atom $cut 5)
       (recognition-indices $indices) (partial-recognitions $rows)
       nine-index-recognition overlapping-recognition-permitted
       finite-partial-not-completeness-proof
       no-inverse-to-generated-or-movement)))

(= (M255PartialRecognitionRowsValidAt $rows $indices $occurrence
      $source-cut $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (CPShape $row m255-partial-recognition-v1 7)
         (let* (($index-valid
                  (== (index-atom $row 1) (index-atom $indices $i)))
                ($occurrence-valid
                  (== (index-atom $row 2) $occurrence))
                ($value-valid
                  (or (CPShape (index-atom $row 3) some 2)
                      (CPShape (index-atom $row 3) none 2)))
                ($cut-valid
                  (== (index-atom $row 4) (source-cut $source-cut)))
                ($provenance-valid
                  (== (index-atom $row 5)
                    (provenance Inquiry-25.5-from-Inquiry-26.3
                      finite-contact-reading)))
                ($authority-valid
                  (== (index-atom $row 6)
                    no-generated-completeness-amalgamation-or-movement-authority))
                ($remaining-valid
                  (M255PartialRecognitionRowsValidAt $rows $indices
                    $occurrence $source-cut (+ $i 1))))
           (and $index-valid
            (and $occurrence-valid
             (and $value-valid
              (and $cut-valid
               (and $provenance-valid
                (and $authority-valid $remaining-valid)))))))
         false))
     true))

(= (M255RecognitionFamilyMarkersValid $family)
   (and (== (index-atom $family 4) nine-index-recognition)
    (and (== (index-atom $family 5) overlapping-recognition-permitted)
     (and (== (index-atom $family 6)
            finite-partial-not-completeness-proof)
          (== (index-atom $family 7)
            no-inverse-to-generated-or-movement)))))

(= (M255RecognitionFamilyRowsValid $family $indices $rows)
   (if (M255Fact9RecognitionIndicesValid $indices)
     (if (== (size-atom $rows) 9)
       (let $first (index-atom $rows 0)
         (if (CPShape $first m255-partial-recognition-v1 7)
           (let $source-wrapper (index-atom $first 4)
             (if (CPShape $source-wrapper source-cut 2)
               (and (M255PartialRecognitionRowsValidAt $rows $indices
                      (index-atom $family 1)
                      (index-atom $source-wrapper 1) 0)
                    (M255RecognitionFamilyMarkersValid $family))
               false))
           false))
       false)
     false))

(= (M255RecognitionFamilyStructuralValid $family)
   (if (CPShape $family m255-recognition-family-v1 8)
     (let* (($indices-wrapper (index-atom $family 2))
            ($rows-wrapper (index-atom $family 3)))
       (if (CPShape $indices-wrapper recognition-indices 2)
         (if (CPShape $rows-wrapper partial-recognitions 2)
           (let* (($indices (index-atom $indices-wrapper 1))
                  ($rows (index-atom $rows-wrapper 1)))
             (M255RecognitionFamilyRowsValid $family $indices $rows))
           false)
         false))
     false))

(= (M255RecognitionFamilyValid $family $cut $facts)
   (if (M255RecognitionFamilyStructuralValid $family)
     (== $family (M255RecognitionFamily $cut $facts))
     false))

(= (M255PartialRecognitionPresent $row)
   (if (CPShape $row m255-partial-recognition-v1 7)
     (CPShape (index-atom $row 3) some 2) false))

(= (M255RecognitionOverlapsAtJ $rows $i $j)
   (if (< $j (size-atom $rows))
     (let* (($left (index-atom $rows $i))
            ($right (index-atom $rows $j)))
       (if (and (M255PartialRecognitionPresent $left)
             (and (M255PartialRecognitionPresent $right)
              (and (!= (index-atom $left 1) (index-atom $right 1))
                   (== (index-atom $left 2) (index-atom $right 2)))))
         (cons-atom
           (m255-recognition-overlap-v1 (index-atom $left 1)
             (index-atom $right 1) (index-atom $left 2)
             (left-recognition (index-atom $left 3))
             (right-recognition (index-atom $right 3))
             common-occurrence-without-amalgamation-or-sovereignty)
           (M255RecognitionOverlapsAtJ $rows $i (+ $j 1)))
         (M255RecognitionOverlapsAtJ $rows $i (+ $j 1))))
     ()))

(= (M255RecognitionOverlapsAtI $rows $i)
   (if (< (+ $i 1) (size-atom $rows))
     (CPListAppend (M255RecognitionOverlapsAtJ $rows $i (+ $i 1))
       (M255RecognitionOverlapsAtI $rows (+ $i 1)))
     ()))

(= (M255RecognitionProfileAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (cons-atom (recognition-value (index-atom $row 1)
                    (index-atom $row 3))
         (M255RecognitionProfileAt $rows (+ $i 1))))
     ()))

(= (M255RecognitionProfile $family)
   (if (CPShape $family m255-recognition-family-v1 8)
     (let $rows-wrapper (index-atom $family 3)
       (if (CPShape $rows-wrapper partial-recognitions 2)
         (recognition-profile
           (M255RecognitionProfileAt (index-atom $rows-wrapper 1) 0))
         (recognition-profile-unresolved malformed-recognition-family)))
     (recognition-profile-unresolved malformed-recognition-family)))

(= (M255RecognitionOrganization $cut $facts)
   (let* (($family (M255RecognitionFamily $cut $facts))
          ($rows (index-atom (index-atom $family 3) 1))
          ($overlaps (M255RecognitionOverlapsAtI $rows 0)))
     (m255-recognition-organization-v1 $family
       (recognition-overlaps $overlaps)
       (recognition-profile (M255RecognitionProfile $family))
       overlap-does-not-imply-exhaustion-or-global-view
       recognition-does-not-construct-generated-or-movement)))

(= (M255RecognitionOrganizationStructuralValid $organization)
   (if (CPShape $organization m255-recognition-organization-v1 6)
     (let $family (index-atom $organization 1)
       (if (M255RecognitionFamilyStructuralValid $family)
         (let* (($rows-wrapper (index-atom $family 3))
                ($rows (index-atom $rows-wrapper 1)))
           (and (== (index-atom $organization 2)
                  (recognition-overlaps
                    (M255RecognitionOverlapsAtI $rows 0)))
            (and (== (index-atom $organization 3)
                   (recognition-profile (M255RecognitionProfile $family)))
             (and (== (index-atom $organization 4)
                    overlap-does-not-imply-exhaustion-or-global-view)
                  (== (index-atom $organization 5)
                    recognition-does-not-construct-generated-or-movement)))))
         false))
     false))

(= (M255RecognitionOrganizationValid $organization $cut $facts)
   (if (M255RecognitionOrganizationStructuralValid $organization)
     (== $organization (M255RecognitionOrganization $cut $facts))
     false))

; This finite countermodel form is used only with independently constructed
; valid/invalid Generated witnesses. Equal recognition profiles can therefore
; witness non-invertibility; the relation itself cannot create either status.
(= (M255RecognitionNonReconstructionCountermodel $family-a $generated-a
      $family-b $generated-b)
   (if (M255RecognitionFamilyStructuralValid $family-a)
     (if (M255RecognitionFamilyStructuralValid $family-b)
       (if (and (== (M255RecognitionProfile $family-a)
                     (M255RecognitionProfile $family-b))
             (and (CPShape $generated-a generated-v1 7)
                  (CPShape $generated-b m255-generated-unresolved 2)))
         (m255-recognition-nonreconstruction-countermodel-v1
           (M255RecognitionProfile $family-a)
           (generated-standing generated) (generated-standing unresolved)
           same-recognition-profile-different-generated-standing
           no-inverse-no-completeness-no-movement-authority)
         (m255-recognition-nonreconstruction-unresolved
           missing-equal-profile-or-differentiated-generated-standing))
       (m255-recognition-nonreconstruction-unresolved
         malformed-second-recognition-family))
     (m255-recognition-nonreconstruction-unresolved
       malformed-first-recognition-family)))

(= (M255GenSig $carrier $move-type $cut $facts $possibility)
   (gen-sig-v1
     (carrier-signature $carrier constitutive-cut $move-type)
     (cut-vocabulary (index-atom $cut 1) (index-atom $cut 2)
       (proto-time inherited-strict-partial-order))
     (move-vocabulary (index-atom $possibility 1)
       (index-atom $possibility 2))
     (relation-vocabulary (index-atom $possibility 3))
     (distinction-vocabulary (index-atom $possibility 4))
     (interface-vocabulary (index-atom $possibility 5))
     (precursor-vocabulary
       (r-star (index-atom $possibility 3))
       (a-star (index-atom $possibility 5))
       (p-star (index-atom $possibility 4))
       (o-star (index-atom $possibility 7)))
     (inherited-legality (index-atom $possibility 8))
     (force-obligation-vocabulary
       (obligation-domain holding-apart imposed-velocity compensatory bypass)
       (holds-obligation-relation witness-required)
       (disqualifying-obligation-relation witness-required)
       witness-bearing-non-optimizing)
     (disposition-reachability-vocabulary
       (disposition-domain open constrained unresolved)
       (reachable-relation derived-read-only))
     (reflexive-constraint-vocabulary
       (self-representation-dependence witness-required)
       (severing-changes-access witness-required)
       conjunctive-causal-bite)
     (recognition-vocabulary (M255RecognitionIdsAt $facts 0)
       partial-non-reconstructive)))

(= (M255GenSigVocabularyValid $signature)
   (let* (($relations (index-atom $signature 4))
          ($distinctions (index-atom $signature 5))
          ($interfaces (index-atom $signature 6)))
     (and (CPShape $relations relation-vocabulary 2)
      (and (CPShape $distinctions distinction-vocabulary 2)
       (and (CPShape $interfaces interface-vocabulary 2)
        (and (is-expr (index-atom $relations 1))
         (and (is-expr (index-atom $distinctions 1))
          (and (is-expr (index-atom $interfaces 1))
           (and (CPUniq (index-atom $relations 1) 0 ())
            (and (CPUniq (index-atom $distinctions 1) 0 ())
                 (CPUniq (index-atom $interfaces 1) 0 ())))))))))))

(= (M255GenSigPrecursorsValid $signature)
   (let* (($precursors (index-atom $signature 7))
          ($relations (index-atom (index-atom $signature 4) 1))
          ($distinctions (index-atom (index-atom $signature 5) 1))
          ($interfaces (index-atom (index-atom $signature 6) 1)))
     (and (CPShape $precursors precursor-vocabulary 5)
      (and (== (index-atom $precursors 1) (r-star $relations))
       (and (== (index-atom $precursors 2) (a-star $interfaces))
        (and (== (index-atom $precursors 3) (p-star $distinctions))
             (CPShape (index-atom $precursors 4) o-star 2)))))))

(= (M255GenSigContractsValid $signature)
   (let* (($obligations (index-atom $signature 9))
          ($recognition (index-atom $signature 12)))
     (and (== (index-atom $signature 8)
            (inherited-legality l2425-supported))
      (and (== $obligations
             (force-obligation-vocabulary
               (obligation-domain holding-apart imposed-velocity
                 compensatory bypass)
               (holds-obligation-relation witness-required)
               (disqualifying-obligation-relation witness-required)
               witness-bearing-non-optimizing))
       (and (== (index-atom $signature 10)
              (disposition-reachability-vocabulary
                (disposition-domain open constrained unresolved)
                (reachable-relation derived-read-only)))
        (and (== (index-atom $signature 11)
               (reflexive-constraint-vocabulary
                 (self-representation-dependence witness-required)
                 (severing-changes-access witness-required)
                 conjunctive-causal-bite))
         (and (CPShape $recognition recognition-vocabulary 3)
          (and (is-expr (index-atom $recognition 1))
               (== (index-atom $recognition 2)
                 partial-non-reconstructive)))))))))

(= (M255GenSigStructuralValid $signature)
   (if (CPShape $signature gen-sig-v1 13)
     (and (CPShape (index-atom $signature 1) carrier-signature 4)
      (and (CPShape (index-atom $signature 2) cut-vocabulary 4)
       (and (== (index-atom (index-atom $signature 2) 3)
              (proto-time inherited-strict-partial-order))
        (and (CPShape (index-atom $signature 3) move-vocabulary 3)
         (and (M255GenSigVocabularyValid $signature)
          (and (M255GenSigPrecursorsValid $signature)
               (M255GenSigContractsValid $signature))))))) false))

(= (M255GenSigRelations $signature)
   (index-atom (index-atom $signature 4) 1))
(= (M255GenSigDistinctions $signature)
   (index-atom (index-atom $signature 5) 1))
(= (M255GenSigInterfaces $signature)
   (index-atom (index-atom $signature 6) 1))
(= (M255GenSigCarrier $signature)
   (index-atom (index-atom $signature 1) 1))

(= (M255CarrierRoleIdsAt $carrier $kind $ids $i)
   (if (< $i (size-atom $ids))
     (cons-atom (carrier-role $carrier $kind (index-atom $ids $i))
       (M255CarrierRoleIdsAt $carrier $kind $ids (+ $i 1))) ()))

(= (M255CarrierGenSig $carrier $move-type $cut $facts $possibility)
   (let* (($relations (M255CarrierRoleIdsAt $carrier relation
                       (index-atom $possibility 3) 0))
          ($distinctions (M255CarrierRoleIdsAt $carrier distinction
                          (index-atom $possibility 4) 0))
          ($interfaces (M255CarrierRoleIdsAt $carrier interface
                        (index-atom $possibility 5) 0))
          ($recognitions (M255CarrierRoleIdsAt $carrier recognition
                          (M255RecognitionIdsAt $facts 0) 0)))
     (gen-sig-v1
       (carrier-signature $carrier constitutive-cut $move-type)
       (cut-vocabulary (index-atom $cut 1) (index-atom $cut 2)
         (proto-time inherited-strict-partial-order))
       (move-vocabulary (index-atom $possibility 1)
         (index-atom $possibility 2))
       (relation-vocabulary $relations)
       (distinction-vocabulary $distinctions)
       (interface-vocabulary $interfaces)
       (precursor-vocabulary (r-star $relations) (a-star $interfaces)
         (p-star $distinctions) (o-star (index-atom $possibility 7)))
       (inherited-legality (index-atom $possibility 8))
       (force-obligation-vocabulary
         (obligation-domain holding-apart imposed-velocity compensatory bypass)
         (holds-obligation-relation witness-required)
         (disqualifying-obligation-relation witness-required)
         witness-bearing-non-optimizing)
       (disposition-reachability-vocabulary
         (disposition-domain open constrained unresolved)
         (reachable-relation derived-read-only))
       (reflexive-constraint-vocabulary
         (self-representation-dependence witness-required)
         (severing-changes-access witness-required)
         conjunctive-causal-bite)
       (recognition-vocabulary $recognitions partial-non-reconstructive))))

(= (M255GenSigValid $signature $carrier $move-type $cut $facts $possibility)
   (and (CPCutValid $cut)
     (and (CPShape $possibility possible-movement 9)
      (and (M255GenSigStructuralValid $signature)
           (== $signature
             (M255GenSig $carrier $move-type $cut $facts $possibility))))))

; A GenSig names the carrier vocabulary. Generated/𝒢 remains a separate,
; witness-bearing relation. In particular, the mere presence of the force,
; disposition, reflexive, and recognition fields above does not claim that
; any such witness is inhabited for this movement.
(= (M255AStarWitness $signature)
   (a-star-witness (M255GenSigInterfaces $signature)
     fits-identified-interface no-unwitnessed-constraint))

(= (M255InterfacesFitMovement $cut $possibility)
   (let $interfaces (index-atom $possibility 5)
     (and (is-expr $interfaces)
       (and (> (size-atom $interfaces) 0)
            (CPAllInterfacesKnown $cut $interfaces 0)))))

(= (M255GeneratedFromSignature $signature $possibility)
   (generated-v1 $signature
     (r-star-witness (M255GenSigRelations $signature)
       used-and-counterfactually-discriminating)
     (M255AStarWitness $signature)
     (p-star-witness (M255GenSigDistinctions $signature)
       used-and-counterfactually-discriminating)
     (o-star-witness (index-atom $possibility 7) consequence-open)
     (l2425-witness (index-atom $possibility 8))))

(= (M255GeneratedWitness $signature $possibility)
   (M255GeneratedFromSignature $signature $possibility))

(= (M255GeneratedWitnessStructuralValid $witness $signature)
   (if (CPShape $witness generated-v1 7)
     (and (== (index-atom $witness 1) $signature)
      (and (== (index-atom $witness 2)
             (r-star-witness (M255GenSigRelations $signature)
               used-and-counterfactually-discriminating))
       (and (== (index-atom $witness 3) (M255AStarWitness $signature))
        (and (== (index-atom $witness 4)
               (p-star-witness (M255GenSigDistinctions $signature)
                 used-and-counterfactually-discriminating))
         (and (CPShape (index-atom $witness 5) o-star-witness 3)
              (CPShape (index-atom $witness 6) l2425-witness 2)))))) false))

(= (M255GeneratedWitnessValid $witness $signature $carrier $move-type
      $cut $facts $flourishing $possibility)
   (and (M255GenSigValid $signature $carrier $move-type $cut $facts
          $possibility)
    (and (== $witness (M255GeneratedWitness $signature $possibility))
     (and (M255GeneratedWitnessStructuralValid $witness $signature)
      (and (CPRelationsReady $cut $facts (index-atom $possibility 3))
       (and (CPDistinctionsReady $cut (index-atom $possibility 4))
        (and (M255InterfacesFitMovement $cut $possibility)
         (and (CPConsequenceReady (index-atom $possibility 7))
          (and (== (index-atom $possibility 8) l2425-supported)
           (and (CPShape $flourishing flourishing-organization 3)
                (== (size-atom (index-atom $flourishing 2)) 9)))))))))))

; B8 negative direction: R*/A*/P*/O* do not compensate for a missing L2425
; premise. This constructor is evidence of a failed Generated relation, not a
; way to manufacture either contact or a negative movement verdict.
(= (M255GenSigNonL2425ContractsValid $signature $carrier $move-type $cut
      $facts $possibility)
   (let* (($obligations (index-atom $signature 9))
          ($recognition (index-atom $signature 12)))
     (and (CPShape $signature gen-sig-v1 13)
      (and (== $signature
             (M255GenSig $carrier $move-type $cut $facts $possibility))
       (and (!= (index-atom $possibility 8) l2425-supported)
        (and (== (index-atom $signature 8)
               (inherited-legality (index-atom $possibility 8)))
         (and (== $obligations
                (force-obligation-vocabulary
                  (obligation-domain holding-apart imposed-velocity
                    compensatory bypass)
                  (holds-obligation-relation witness-required)
                  (disqualifying-obligation-relation witness-required)
                  witness-bearing-non-optimizing))
          (and (== (index-atom $signature 10)
                 (disposition-reachability-vocabulary
                   (disposition-domain open constrained unresolved)
                   (reachable-relation derived-read-only)))
           (and (== (index-atom $signature 11)
                  (reflexive-constraint-vocabulary
                    (self-representation-dependence witness-required)
                    (severing-changes-access witness-required)
                    conjunctive-causal-bite))
            (and (CPShape $recognition recognition-vocabulary 3)
                 (== (index-atom $recognition 2)
                   partial-non-reconstructive)))))))))))

(= (M255GenSigValidExceptL2425 $signature $carrier $move-type $cut $facts
      $possibility)
   (and (CPCutValid $cut)
      (and (CPShape $possibility possible-movement 9)
       (and (== $signature
              (M255GenSig $carrier $move-type $cut $facts $possibility))
        (and (CPShape $signature gen-sig-v1 13)
         (and (CPShape (index-atom $signature 1) carrier-signature 4)
          (and (CPShape (index-atom $signature 2) cut-vocabulary 4)
           (and (CPShape (index-atom $signature 3) move-vocabulary 3)
            (and (M255GenSigVocabularyValid $signature)
             (and (M255GenSigPrecursorsValid $signature)
                  (M255GenSigNonL2425ContractsValid $signature $carrier
                    $move-type $cut $facts $possibility)))))))))))

(= (M255L2425FailureWitness $signature $carrier $move-type $cut $facts
      $flourishing $possibility)
   (if (CPShape $possibility possible-movement 9)
     (let $candidate (M255GeneratedWitness $signature $possibility)
       (if (M255GenSigValidExceptL2425 $signature $carrier $move-type $cut
             $facts $possibility)
         (if (CPRelationsReady $cut $facts (index-atom $possibility 3))
           (if (CPDistinctionsReady $cut (index-atom $possibility 4))
             (if (M255InterfacesFitMovement $cut $possibility)
               (if (CPConsequenceReady (index-atom $possibility 7))
                 (if (!= (index-atom $possibility 8) l2425-supported)
                   (if (and (CPShape $flourishing flourishing-organization 3)
                            (== (size-atom (index-atom $flourishing 2)) 9))
                     (if (== (M255GeneratedWitnessValid $candidate $signature
                               $carrier $move-type $cut $facts $flourishing
                               $possibility) false)
                       (m255-l2425-failure-witness-v1
                         (r-star-retained (index-atom $candidate 2))
                         (a-star-retained (index-atom $candidate 3))
                         (p-star-retained (index-atom $candidate 4))
                         (o-star-retained (index-atom $candidate 5))
                         (l2425-standing (index-atom $candidate 6))
                         generated-standing-not-generated
                         no-contact-or-movement-authority)
                       (m255-l2425-failure-unresolved
                         candidate-unexpectedly-generated))
                     (m255-l2425-failure-unresolved
                       incomplete-flourishing-organization))
                   (m255-l2425-failure-unresolved l2425-is-supported))
                 (m255-l2425-failure-unresolved missing-o-star))
               (m255-l2425-failure-unresolved missing-a-star-interface-fit))
             (m255-l2425-failure-unresolved missing-p-star-distinction))
           (m255-l2425-failure-unresolved missing-r-star-relation))
         (m255-l2425-failure-unresolved invalid-generative-signature)))
     (m255-l2425-failure-unresolved malformed-possibility)))

(= (M255L2425FailureWitnessValid $witness $signature $carrier $move-type
      $cut $facts $flourishing $possibility)
   (if (CPShape $witness m255-l2425-failure-witness-v1 8)
     (== $witness (M255L2425FailureWitness $signature $carrier $move-type
       $cut $facts $flourishing $possibility))
     false))

(= (M255IdentityMapAt $kind $ids $i)
   (if (< $i (size-atom $ids))
     (let $id (index-atom $ids $i)
       (cons-atom (gen-map $kind $id $id
          (load-bearing-correspondence preserved))
         (M255IdentityMapAt $kind $ids (+ $i 1)))) ()))

(= (M255MapIdsAt $maps $field $i)
   (if (< $i (size-atom $maps))
     (cons-atom (index-atom (index-atom $maps $i) $field)
       (M255MapIdsAt $maps $field (+ $i 1))) ()))

(= (M255MapRowsValidAt $maps $kind $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (and (CPShape $row gen-map 5)
        (and (== (index-atom $row 1) $kind)
         (and (== (index-atom $row 4)
                (load-bearing-correspondence preserved))
              (M255MapRowsValidAt $maps $kind (+ $i 1)))))) true))

(= (M255MapCoverageValid $map-set $kind $source-ids $target-ids)
   (if (CPShape $map-set gen-map-set 3)
     (let* (($maps (index-atom $map-set 2))
            ($sources (M255MapIdsAt $maps 2 0))
            ($targets (M255MapIdsAt $maps 3 0)))
       (and (== (index-atom $map-set 1) $kind)
        (and (is-expr $maps)
         (and (M255MapRowsValidAt $maps $kind 0)
          (and (CPUniq $sources 0 ())
           (and (CPUniq $targets 0 ())
            (and (M255AllIn $source-ids $sources 0)
             (and (M255AllIn $sources $source-ids 0)
              (and (M255AllIn $target-ids $targets 0)
                   (M255AllIn $targets $target-ids 0)))))))))) false))

(= (M255GenTranslation $source $target $source-generated $target-generated)
   (gen-translation-v2 $source $target $source-generated $target-generated
     (gen-map-set relation
       (M255IdentityMapAt relation (M255GenSigRelations $source) 0))
     (gen-map-set distinction
       (M255IdentityMapAt distinction (M255GenSigDistinctions $source) 0))
     (gen-map-set interface
       (M255IdentityMapAt interface (M255GenSigInterfaces $source) 0))
     (coverage bidirectional load-bearing no-unwitnessed-mapping)
     (constraint-transport bidirectional no-unwitnessed-constraint)
     (o-star-transport bidirectional (index-atom $source-generated 5)
       (index-atom $target-generated 5))
     (proto-time-compatible (index-atom $source 2) (index-atom $target 2))
     structural-equivalence-does-not-imply-same-becoming))

(= (M255GenTranslationMapsValid $translation $source $target)
   (and (M255MapCoverageValid (index-atom $translation 5) relation
          (M255GenSigRelations $source) (M255GenSigRelations $target))
    (and (M255MapCoverageValid (index-atom $translation 6) distinction
           (M255GenSigDistinctions $source) (M255GenSigDistinctions $target))
         (M255MapCoverageValid (index-atom $translation 7) interface
           (M255GenSigInterfaces $source) (M255GenSigInterfaces $target)))))

(= (M255GenTranslationContractsValid $translation $source $target
      $source-generated $target-generated)
   (and (== (index-atom $translation 8)
          (coverage bidirectional load-bearing no-unwitnessed-mapping))
    (and (== (index-atom $translation 9)
           (constraint-transport bidirectional no-unwitnessed-constraint))
     (and (== (index-atom $translation 10)
            (o-star-transport bidirectional
              (index-atom $source-generated 5)
              (index-atom $target-generated 5)))
      (and (== (index-atom $translation 11)
             (proto-time-compatible (index-atom $source 2)
               (index-atom $target 2)))
           (== (index-atom $translation 12)
             structural-equivalence-does-not-imply-same-becoming))))))

(= (M255GenTranslationValid $translation)
   (if (CPShape $translation gen-translation-v2 13)
     (let* (($source (index-atom $translation 1))
            ($target (index-atom $translation 2))
            ($source-generated (index-atom $translation 3))
            ($target-generated (index-atom $translation 4)))
       (and (M255GenSigStructuralValid $source)
       (and (M255GenSigStructuralValid $target)
         (and (M255GeneratedWitnessStructuralValid $source-generated $source)
          (and (M255GeneratedWitnessStructuralValid $target-generated $target)
           (and (M255GenTranslationMapsValid $translation $source $target)
                (M255GenTranslationContractsValid $translation $source $target
                  $source-generated $target-generated)))))))
     false))

(= (M255CrossCarrierTranslationValid $translation)
   (and (M255GenTranslationValid $translation)
        (!= (M255GenSigCarrier (index-atom $translation 1))
            (M255GenSigCarrier (index-atom $translation 2)))))

(= (M255GenEquivV2 $source $target $source-generated $target-generated)
   (let $translation (M255GenTranslation $source $target
                        $source-generated $target-generated)
     (if (M255GenTranslationValid $translation)
       (gen-equiv-v2 $source $target $translation
         structural-equivalence-not-carrier-identity)
       (gen-equiv-v2-unresolved missing-proof-relevant-translation))))

(= (M255GenEquivV2Valid $equivalence)
   (if (CPShape $equivalence gen-equiv-v2 5)
     (and (M255GenTranslationValid (index-atom $equivalence 3))
      (and (== (index-atom $equivalence 1)
             (index-atom (index-atom $equivalence 3) 1))
       (and (== (index-atom $equivalence 2)
              (index-atom (index-atom $equivalence 3) 2))
            (== (index-atom $equivalence 4)
              structural-equivalence-not-carrier-identity)))) false))

(= (M255CrossCarrierEquivV2Valid $equivalence)
   (and (M255GenEquivV2Valid $equivalence)
        (M255CrossCarrierTranslationValid (index-atom $equivalence 3))))

(= (M255ReverseMapRowsAt $maps $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (cons-atom (gen-map (index-atom $row 1) (index-atom $row 3)
          (index-atom $row 2) (index-atom $row 4))
         (M255ReverseMapRowsAt $maps (+ $i 1)))) ()))

(= (M255ReverseMapSet $map-set)
   (gen-map-set (index-atom $map-set 1)
     (M255ReverseMapRowsAt (index-atom $map-set 2) 0)))

(= (M255GenTranslationSymm $translation)
   (if (M255GenTranslationValid $translation)
     (let* (($source (index-atom $translation 1))
            ($target (index-atom $translation 2))
            ($source-generated (index-atom $translation 3))
            ($target-generated (index-atom $translation 4)))
       (gen-translation-v2 $target $source $target-generated $source-generated
         (M255ReverseMapSet (index-atom $translation 5))
         (M255ReverseMapSet (index-atom $translation 6))
         (M255ReverseMapSet (index-atom $translation 7))
         (coverage bidirectional load-bearing no-unwitnessed-mapping)
         (constraint-transport bidirectional no-unwitnessed-constraint)
         (o-star-transport bidirectional (index-atom $target-generated 5)
           (index-atom $source-generated 5))
         (proto-time-compatible (index-atom $target 2)
           (index-atom $source 2))
         structural-equivalence-does-not-imply-same-becoming))
     (gen-translation-v2-unresolved invalid-source-translation)))

(= (M255MapTargetAt $maps $kind $source-id $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (if (and (== (index-atom $row 1) $kind)
                (== (index-atom $row 2) $source-id))
         (index-atom $row 3)
         (M255MapTargetAt $maps $kind $source-id (+ $i 1))))
     missing-load-bearing-map))

(= (M255ComposeMapRowsAt $left $right $kind $i)
   (if (< $i (size-atom $left))
     (let* (($row (index-atom $left $i))
            ($source-id (index-atom $row 2))
            ($middle-id (index-atom $row 3))
            ($target-id (M255MapTargetAt $right $kind $middle-id 0)))
       (cons-atom (gen-map $kind $source-id $target-id
          (load-bearing-correspondence preserved))
         (M255ComposeMapRowsAt $left $right $kind (+ $i 1)))) ()))

(= (M255ComposeMapSet $left $right $kind)
   (gen-map-set $kind
     (M255ComposeMapRowsAt (index-atom $left 2)
       (index-atom $right 2) $kind 0)))

(= (M255GenTranslationsComposable $left $right)
   (and (M255GenTranslationValid $left)
    (and (M255GenTranslationValid $right)
     (and (== (index-atom $left 2) (index-atom $right 1))
          (== (index-atom $left 4) (index-atom $right 3))))))

(= (M255GenTranslationTrans $left $right)
   (if (M255GenTranslationsComposable $left $right)
     (let* (($source (index-atom $left 1))
            ($target (index-atom $right 2))
            ($source-generated (index-atom $left 3))
            ($target-generated (index-atom $right 4)))
       (gen-translation-v2 $source $target $source-generated $target-generated
         (M255ComposeMapSet (index-atom $left 5)
           (index-atom $right 5) relation)
         (M255ComposeMapSet (index-atom $left 6)
           (index-atom $right 6) distinction)
         (M255ComposeMapSet (index-atom $left 7)
           (index-atom $right 7) interface)
         (coverage bidirectional load-bearing no-unwitnessed-mapping)
         (constraint-transport bidirectional no-unwitnessed-constraint)
         (o-star-transport bidirectional (index-atom $source-generated 5)
           (index-atom $target-generated 5))
         (proto-time-compatible (index-atom $source 2)
           (index-atom $target 2))
         structural-equivalence-does-not-imply-same-becoming))
     (gen-translation-v2-unresolved non-composable-domain)))

(= (M255GenEquivV2FromTranslation $translation)
   (if (M255GenTranslationValid $translation)
     (gen-equiv-v2 (index-atom $translation 1) (index-atom $translation 2)
       $translation structural-equivalence-not-carrier-identity)
     (gen-equiv-v2-unresolved missing-proof-relevant-translation)))

(= (M255TranslationLawWitness $translation)
   (let* (($symmetric (M255GenTranslationSymm $translation))
          ($source-refl (M255GenTranslation (index-atom $translation 1)
            (index-atom $translation 1) (index-atom $translation 3)
            (index-atom $translation 3)))
          ($target-refl (M255GenTranslation (index-atom $translation 2)
            (index-atom $translation 2) (index-atom $translation 4)
            (index-atom $translation 4)))
          ($source-roundtrip (M255GenTranslationTrans $translation $symmetric))
          ($target-roundtrip (M255GenTranslationTrans $symmetric $translation)))
     (gen-equiv-v2-laws-v1
       (bounded-domain (M255GenSigCarrier (index-atom $translation 1))
         (M255GenSigCarrier (index-atom $translation 2)))
       (reflexive-source (M255GenTranslationValid $source-refl))
       (reflexive-target (M255GenTranslationValid $target-refl))
       (symmetric (M255GenTranslationValid $symmetric))
       (transitive-source-roundtrip
         (M255GenTranslationValid $source-roundtrip))
       (transitive-target-roundtrip
         (M255GenTranslationValid $target-roundtrip))
       finite-domain-law-witness-not-universal-proof)))

(= (M255TranslationLawWitnessValid $translation $witness)
   (and (M255GenTranslationValid $translation)
    (and (== $witness (M255TranslationLawWitness $translation))
     (and (CPShape $witness gen-equiv-v2-laws-v1 8)
      (and (== (index-atom (index-atom $witness 2) 1) true)
       (and (== (index-atom (index-atom $witness 3) 1) true)
        (and (== (index-atom (index-atom $witness 4) 1) true)
         (and (== (index-atom (index-atom $witness 5) 1) true)
              (== (index-atom (index-atom $witness 6) 1) true)))))))))

(= (M255CarrierBundle $tag $carrier $move-type $cut $facts $possibility)
   (let* (($signature (M255CarrierGenSig $carrier $move-type $cut $facts
                        $possibility))
          ($generated (M255GeneratedFromSignature $signature $possibility)))
     (manifestation-carrier-v1 $tag $carrier $move-type $signature $generated)))

(= (M255CarrierBundleStructuralValid $bundle $tag $carrier $move-type
      $possibility)
   (if (CPShape $bundle manifestation-carrier-v1 6)
     (let* (($signature (index-atom $bundle 4))
            ($generated (index-atom $bundle 5)))
       (and (== (index-atom $bundle 1) $tag)
        (and (== (index-atom $bundle 2) $carrier)
         (and (== (index-atom $bundle 3) $move-type)
          (and (M255GenSigStructuralValid $signature)
           (and (== (M255GenSigCarrier $signature) $carrier)
            (and (== (index-atom (index-atom $signature 1) 3) $move-type)
             (and (== (index-atom $signature 3)
                    (move-vocabulary (index-atom $possibility 1)
                      (index-atom $possibility 2)))
                  (M255GeneratedWitnessStructuralValid $generated
                    $signature))))))))) false))

(= (M255CarrierMapRowsAt $kind $source-carrier $target-carrier $ids $i)
   (if (< $i (size-atom $ids))
     (let $id (index-atom $ids $i)
       (cons-atom
         (gen-map $kind (carrier-role $source-carrier $kind $id)
           (carrier-role $target-carrier $kind $id)
           (load-bearing-correspondence preserved))
         (M255CarrierMapRowsAt $kind $source-carrier $target-carrier
           $ids (+ $i 1)))) ()))

(= (M255CarrierMapSet $kind $source-carrier $target-carrier $ids)
   (gen-map-set $kind
     (M255CarrierMapRowsAt $kind $source-carrier $target-carrier $ids 0)))

(= (M255CarrierTranslation $source-bundle $target-bundle $possibility)
   (let* (($source-carrier (index-atom $source-bundle 2))
          ($target-carrier (index-atom $target-bundle 2))
          ($source (index-atom $source-bundle 4))
          ($target (index-atom $target-bundle 4))
          ($source-generated (index-atom $source-bundle 5))
          ($target-generated (index-atom $target-bundle 5)))
     (gen-translation-v2 $source $target $source-generated $target-generated
       (M255CarrierMapSet relation $source-carrier $target-carrier
         (index-atom $possibility 3))
       (M255CarrierMapSet distinction $source-carrier $target-carrier
         (index-atom $possibility 4))
       (M255CarrierMapSet interface $source-carrier $target-carrier
         (index-atom $possibility 5))
       (coverage bidirectional load-bearing no-unwitnessed-mapping)
       (constraint-transport bidirectional no-unwitnessed-constraint)
       (o-star-transport bidirectional (index-atom $source-generated 5)
         (index-atom $target-generated 5))
       (proto-time-compatible (index-atom $source 2) (index-atom $target 2))
       structural-equivalence-does-not-imply-same-becoming)))

(= (M255GenEquivV2Compact $translation)
   (gen-equiv-v2-compact-v1
     (source-carrier (M255GenSigCarrier (index-atom $translation 1)))
     (target-carrier (M255GenSigCarrier (index-atom $translation 2)))
     (index-atom $translation 5) (index-atom $translation 6)
     (index-atom $translation 7) (index-atom $translation 8)
     (index-atom $translation 9) (index-atom $translation 10)
     (index-atom $translation 11)
     structural-equivalence-not-carrier-identity-or-same-becoming))

(= (M255GenEquivV2CompactValid $certificate $translation)
   (and (M255CrossCarrierTranslationValid $translation)
        (== $certificate (M255GenEquivV2Compact $translation))))

(= (M255HubEquivalenceEvidence $source-bundle $hub-bundle $possibility)
   (let* (($translation (M255CarrierTranslation $source-bundle $hub-bundle
                          $possibility))
          ($equivalence (M255GenEquivV2Compact $translation))
          ($laws (M255TranslationLawWitness $translation)))
     (hub-equivalence-v1 (index-atom $source-bundle 1)
       (index-atom $hub-bundle 1) $equivalence $laws)))

(= (M255HubEquivalenceEvidenceValid $evidence $source-bundle $hub-bundle
      $possibility)
   (if (CPShape $evidence hub-equivalence-v1 5)
     (let* (($translation (M255CarrierTranslation $source-bundle $hub-bundle
                            $possibility))
            ($equivalence (index-atom $evidence 3))
            ($laws (index-atom $evidence 4)))
       (and (== (index-atom $evidence 1) (index-atom $source-bundle 1))
        (and (== (index-atom $evidence 2) (index-atom $hub-bundle 1))
         (and (== $equivalence (M255GenEquivV2Compact $translation))
          (and (M255GenEquivV2CompactValid $equivalence $translation)
               (M255TranslationLawWitnessValid $translation $laws)))))) false))

(= (M255FiveCarrierSuite $cut $facts $possibility)
   (let* (($ma (M255CarrierBundle MA m255-physical physical-movement
                 $cut $facts $possibility))
          ($mb (M255CarrierBundle MB m255-autopoietic autopoietic-movement
                 $cut $facts $possibility))
          ($mc (M255CarrierBundle MC m255-human-cognitive
                 human-cognitive-movement $cut $facts $possibility))
          ($md (M255CarrierBundle MD m255-miter-synthetic
                 synthetic-movement $cut $facts $possibility))
          ($me (M255CarrierBundle ME m255-multi-agent-inquiry
                 multi-agent-inquiry-movement $cut $facts $possibility)))
     (five-carrier-connected-suite-v1 $ma $mb $mc $md $me
       (human-cognitive-hub MC)
       (hub-equivalences
         (M255HubEquivalenceEvidence $ma $mc $possibility)
         (M255HubEquivalenceEvidence $mb $mc $possibility)
         (M255HubEquivalenceEvidence $md $mc $possibility)
         (M255HubEquivalenceEvidence $me $mc $possibility))
       one-generated-law-across-five-carriers
       finite-formal-projection-not-empirical-carrier-or-actuality-claim)))

(= (M255FiveCarrierSuiteStructuralValid $suite $possibility)
   (if (CPShape $suite five-carrier-connected-suite-v1 10)
     (let* (($ma (index-atom $suite 1))
            ($mb (index-atom $suite 2))
            ($mc (index-atom $suite 3))
            ($md (index-atom $suite 4))
            ($me (index-atom $suite 5))
            ($equivalences (index-atom $suite 7)))
       (and (M255CarrierBundleStructuralValid $ma MA m255-physical
              physical-movement $possibility)
        (and (M255CarrierBundleStructuralValid $mb MB m255-autopoietic
               autopoietic-movement $possibility)
         (and (M255CarrierBundleStructuralValid $mc MC m255-human-cognitive
                human-cognitive-movement $possibility)
          (and (M255CarrierBundleStructuralValid $md MD m255-miter-synthetic
                 synthetic-movement $possibility)
           (and (M255CarrierBundleStructuralValid $me ME
                  m255-multi-agent-inquiry multi-agent-inquiry-movement
                  $possibility)
            (and (== (index-atom $suite 6) (human-cognitive-hub MC))
             (and (CPShape $equivalences hub-equivalences 5)
              (and (M255HubEquivalenceEvidenceValid
                     (index-atom $equivalences 1) $ma $mc $possibility)
               (and (M255HubEquivalenceEvidenceValid
                      (index-atom $equivalences 2) $mb $mc $possibility)
                (and (M255HubEquivalenceEvidenceValid
                       (index-atom $equivalences 3) $md $mc $possibility)
                 (and (M255HubEquivalenceEvidenceValid
                        (index-atom $equivalences 4) $me $mc $possibility)
                  (and (== (index-atom $suite 8)
                         one-generated-law-across-five-carriers)
                       (== (index-atom $suite 9)
                         finite-formal-projection-not-empirical-carrier-or-actuality-claim))))))))))))))
     false))

!(import! &self "./src/generative_participation.metta")

(= (M255FiveCarrierSuiteReady $suite $cut $facts $flourishing $possibility)
   (and (== $suite (M255FiveCarrierSuite $cut $facts $possibility))
    (and (M255FiveCarrierSuiteStructuralValid $suite $possibility)
     (and (CPRelationsReady $cut $facts (index-atom $possibility 3))
      (and (CPDistinctionsReady $cut (index-atom $possibility 4))
       (and (M255InterfacesFitMovement $cut $possibility)
        (and (CPConsequenceReady (index-atom $possibility 7))
         (and (== (index-atom $possibility 8) l2425-supported)
          (and (CPShape $flourishing flourishing-organization 3)
               (== (size-atom (index-atom $flourishing 2)) 9))))))))))

(= (M255PrimaryCarrierBridgeAfterGenerated $cut $facts $flourishing
      $possibility $source $target $source-generated $target-generated)
   (let* (($equivalence (M255GenEquivV2 $source $target
            $source-generated $target-generated))
          ($suite (M255FiveCarrierSuite $cut $facts $possibility))
          ($participation (M255FiveCarrierParticipationSuite $suite
            $possibility))
          ($recognition (M255RecognitionOrganization $cut $facts)))
     (if (M255FiveCarrierSuiteReady $suite $cut $facts $flourishing
           $possibility)
       (if (M255FiveCarrierParticipationSuiteValid $participation $suite
             $possibility)
         (if (M255RecognitionOrganizationValid $recognition $cut $facts)
           (primary-before-rap $equivalence $suite $participation
             $recognition)
           (primary-before-rap-unresolved invalid-recognition-organization))
         (primary-before-rap-unresolved invalid-participation-suite))
       (primary-before-rap-unresolved invalid-five-carrier-suite))))

(= (M255PrimaryCarrierBridgeReady $cut $facts $flourishing $possibility)
   (let* (($source (M255GenSig miter-native-possibility possible-movement
                    $cut $facts $possibility))
          ($target (M255GenSig miter-primary-movement
                    m25-primary-movement-v2 $cut $facts $possibility))
          ($source-generated (M255GeneratedWitness $source $possibility))
          ($target-generated (M255GeneratedWitness $target $possibility)))
     (if (M255GeneratedWitnessValid $source-generated $source
           miter-native-possibility possible-movement $cut $facts
           $flourishing $possibility)
       (if (M255GeneratedWitnessValid $target-generated $target
             miter-primary-movement m25-primary-movement-v2 $cut $facts
             $flourishing $possibility)
         (M255PrimaryCarrierBridgeAfterGenerated $cut $facts $flourishing
           $possibility $source $target $source-generated $target-generated)
         (primary-before-rap-unresolved invalid-target-generated))
       (primary-before-rap-unresolved invalid-source-generated))))

; The constructor is total across material failure. Failed contact floors are
; explicit unresolved standings and do not enter the heavier carrier suite or
; get repaired by recognition, equivalence, or open participation.
(= (M255PrimaryCarrierBridge $cut $facts $flourishing $possibility)
   (if (CPShape $possibility possible-movement 9)
     (if (CPRelationsReady $cut $facts (index-atom $possibility 3))
       (if (CPDistinctionsReady $cut (index-atom $possibility 4))
         (if (M255InterfacesFitMovement $cut $possibility)
           (if (CPConsequenceReady (index-atom $possibility 7))
             (if (== (index-atom $possibility 8) l2425-supported)
               (if (and (CPShape $flourishing flourishing-organization 3)
                        (== (size-atom (index-atom $flourishing 2)) 9))
                 (M255PrimaryCarrierBridgeReady $cut $facts $flourishing
                   $possibility)
                 (primary-before-rap-unresolved
                   incomplete-flourishing-organization))
               (primary-before-rap-unresolved missing-l2425))
             (primary-before-rap-unresolved missing-consequence-openness))
           (primary-before-rap-unresolved missing-fitting-interface))
         (primary-before-rap-unresolved missing-material-distinction))
       (primary-before-rap-unresolved missing-material-relation))
     (primary-before-rap-unresolved malformed-possibility)))

(= (M255PrimaryCarrierBridgeValid $bridge $possibility)
   (if (CPShape $bridge primary-before-rap 5)
     (let* (($equivalence (index-atom $bridge 1))
            ($suite (index-atom $bridge 2))
            ($participation (index-atom $bridge 3))
            ($recognition (index-atom $bridge 4))
            ($source (if (CPShape $equivalence gen-equiv-v2 5)
              (index-atom $equivalence 1) ()))
            ($target (if (CPShape $equivalence gen-equiv-v2 5)
              (index-atom $equivalence 2) ())))
       (and (M255CrossCarrierEquivV2Valid $equivalence)
        (and (== (M255GenSigCarrier $source) miter-native-possibility)
         (and (== (M255GenSigCarrier $target) miter-primary-movement)
          (and (== (index-atom (index-atom $source 1) 3)
                 possible-movement)
           (and (== (index-atom (index-atom $target 1) 3)
                  m25-primary-movement-v2)
            (and (== (index-atom $source 3)
                   (move-vocabulary (index-atom $possibility 1)
                     (index-atom $possibility 2)))
             (and (== (index-atom $target 3)
                    (move-vocabulary (index-atom $possibility 1)
                      (index-atom $possibility 2)))
              (and (M255FiveCarrierSuiteStructuralValid $suite $possibility)
               (and (M255FiveCarrierParticipationSuiteValid $participation
                      $suite $possibility)
                    (M255RecognitionOrganizationStructuralValid
                      $recognition))))))))))) false))
