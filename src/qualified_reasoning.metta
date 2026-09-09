; Qualified consequence-sensitive reasoning for the one Miter runtime.
;
; This module extracts only the minimal NARS/NAL truth-revision closure needed
; by Miter.  It does not import lib_nars.metta or lib_pln.metta because the
; pinned libraries register overlapping global operator names.  Every product
; below carries its doctrine, pin, exact source hash, premises, evidence-family
; identities, truth semantics, and non-authority standing.
;
; The qualified NAL closure is derived from PeTTa lib/lib_nars.metta at commit
; ae66fa8e41dcd5539d614706bd4e5cfb34f9608d, file SHA-256
; f2a1ab3be59c59128894367a2f52a12c0fafdf1fb26b4affedd48270b47d4b43.
; The qualified PLN closure below is derived from PeTTa lib/lib_pln.metta at
; the same commit, file SHA-256
; 6b980321bbe9b49e5b12e2fcee0479ab1d5c7550c2104a67b0722a5b473da4ee.
;
; MIT License
; Copyright (c) 2025 Patrick Hammer
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

(= (MiterNALTruthC2W $c)
   (/ $c (- 1 $c)))

(= (MiterNALTruthW2C $w)
   (/ $w (+ $w 1)))

(= (MiterNALTruthRevision (stv $f1 $c1) (stv $f2 $c2))
   (let* (($w1 (MiterNALTruthC2W $c1))
          ($w2 (MiterNALTruthC2W $c2))
          ($w (+ $w1 $w2))
          ($f (/ (+ (* $w1 $f1) (* $w2 $f2)) $w))
          ($c (MiterNALTruthW2C $w)))
     (stv (min 1.00 $f) (min 0.99 (max (max $c $c1) $c2)))))

(= (MiterTruthValueValid $truth)
   (if (CPShape $truth stv 3)
     (let* (($frequency (index-atom $truth 1))
            ($confidence (index-atom $truth 2)))
       (and (>= $frequency 0.0)
         (and (<= $frequency 1.0)
          (and (>= $confidence 0.0) (< $confidence 1.0)))))
     false))

; This is the one PLN operator presently earned by a calibrated Miter
; consumer. It is namespaced rather than importing lib_pln.metta alongside
; lib_nars.metta: both pinned libraries publish Truth_Revision and |- in the
; global namespace. The 0.02 term is inherited PLN semantics, not a movement
; score or policy threshold.
(= (MiterPLNTruthModusPonens (stv $f1 $c1) (stv $f2 $c2))
   (stv (+ (* $f1 $f2) (* 0.02 (- 1 $f1))) (* $c1 $c2)))

; One returned developmental-transfer observation becomes one explicitly
; named evidential premise. Unresolved standing remains non-numerical.
(= (MiterPLNTransferStandingTruth $standing)
   (if (== $standing support) (stv 1.0 0.5)
     (if (== $standing contradiction) (stv 0.0 0.5)
       (pln-truth-unavailable unresolved-transfer-standing))))

(= (MiterPLNCutContainsConsequence $cut-id $consequence-id)
   (if (== $cut-id $consequence-id) true
     (if (CPShape $cut-id next-cut 3)
       (if (== (index-atom $cut-id 2) $consequence-id) true
         (MiterPLNCutContainsConsequence
           (index-atom $cut-id 1) $consequence-id))
       false)))

; Structural validation is deliberately available before provisional
; dynamics compile. The later history adapter additionally validates the full
; C3 transfer record and constructs this product from exact stored premises.
(= (MiterPLNRelationalTransferProductStructurallyValid $product)
   (if (CPShape $product pln-relational-transfer-product-v1 13)
     (let* (($inference (index-atom $product 1))
            ($scope (index-atom $product 2))
            ($nace-wrapper (index-atom $product 3))
            ($transfer-wrapper (index-atom $product 4))
            ($source-wrapper (index-atom $product 5))
            ($relation-wrapper (index-atom $product 6))
            ($families (index-atom $product 7))
            ($hypothesis-wrapper (index-atom $product 9))
            ($source-truth (if
              (CPShape $source-wrapper source-contextual-efficacy 2)
              (index-atom $source-wrapper 1) unavailable))
            ($relation-truth (if
              (CPShape $relation-wrapper relational-transfer-premise 2)
              (index-atom $relation-wrapper 1) unavailable))
            ($hypothesis (if
              (CPShape $hypothesis-wrapper contextual-transfer-hypothesis 2)
              (index-atom $hypothesis-wrapper 1) unavailable)))
       (==
         ((== $inference
            (qualified-inference-v1 PLN
              ae66fa8e41dcd5539d614706bd4e5cfb34f9608d
              6b980321bbe9b49e5b12e2fcee0479ab1d5c7550c2104a67b0722a5b473da4ee
              MiterPLNTruthModusPonens))
          (CPShape $scope scope 4)
          (CPShape $nace-wrapper source-nace-revision 2)
          (CPShape (index-atom $nace-wrapper 1)
            nace-revision-product-v1 11)
          (CPShape $transfer-wrapper developmental-transfer-premise 2)
          (CPShape (index-atom $transfer-wrapper 1)
            c3-developmental-transfer-development-v1 8)
          (MiterTruthValueValid $source-truth)
          (MiterTruthValueValid $relation-truth)
          (CPShape $families independent-evidence-families 3)
          (!= (index-atom $families 1) (index-atom $families 2))
          (== (index-atom $product 8)
            (truth-semantics PLN-simple-truth-value
              miter-pln-transfer-standing-adapter-v1
              exact-independent-returned-consequences))
          (MiterTruthValueValid $hypothesis)
          (== $hypothesis
            (MiterPLNTruthModusPonens $source-truth $relation-truth))
          (CPShape (index-atom $product 10) dependency 4)
          (== (index-atom $product 11) unresolved-native-participant)
          (== (index-atom $product 12)
            no-permission-no-authority-no-numeric-movement-choice))
         (true true true true true true true true true true true true true true
           true true)))
     false))

(= (MiterNACEOutcomeTyped $outcome)
   (CPHas $outcome
     (confirmed disconfirmed ambiguous inapplicable delayed mixed malformed
       criterion-failed) 0))

; This laboratory adapter is explicit and reversible. Confirmed and
; disconfirmed are one positive or negative observation respectively. The
; NARS evidence-weight relation c = w/(w+1) therefore gives one observation
; confidence 0.5. No other standing is coerced into numerical evidence.
(= (MiterNACEOutcomeCounts $outcome)
   (if (== $outcome confirmed) (nace-evidence-counts 1 0)
     (if (== $outcome disconfirmed) (nace-evidence-counts 0 1)
       (nace-evidence-pending $outcome))))

(= (MiterNACECountsValid $counts)
   (if (CPShape $counts nace-evidence-counts 3)
     (let* (($positive (index-atom $counts 1))
            ($negative (index-atom $counts 2)))
       (and (>= $positive 0)
         (and (>= $negative 0) (> (+ $positive $negative) 0))))
     false))

(= (MiterNACECountsTruth $counts)
   (if (MiterNACECountsValid $counts)
     (let* (($positive (index-atom $counts 1))
            ($negative (index-atom $counts 2))
            ($weight (+ $positive $negative)))
       (stv (/ $positive $weight) (MiterNALTruthW2C $weight)))
     (nace-truth-unavailable invalid-or-pending-counts)))

(= (MiterNACEPrimaryFromMovement $movement)
   (if (CPShape $movement movement-formed 7)
     (let $derivation (index-atom $movement 4)
       (if (and (CPShape $derivation material-derivation 7)
                (CPShape (index-atom $derivation 1) primary-movement 2))
         (index-atom (index-atom $derivation 1) 1)
         (nace-primary-unavailable no-authority-primary)))
     (nace-primary-unavailable no-single-formed-movement)))

(= (MiterNACEPending $scope $cut $movement)
   (let $primary (MiterNACEPrimaryFromMovement $movement)
     (if (CPShape $primary m25-primary-movement-v2 11)
       (let* (($possibility (index-atom $primary 9))
              ($route (if (CPShape $possibility possible-movement 9)
                (index-atom $possibility 7) ())))
         (if (CPShape $route consequence-route 3)
           (nace-pending-expectation-v1
             (nace-target-v1 $scope
               (movement-form (index-atom $possibility 2))
               (possibility (index-atom $possibility 1))
               (criterion (index-atom $route 1)))
             (CP2MovementReference $cut $movement)
             (source-cut (index-atom $cut 1))
             (consequence-standing (index-atom $route 2))
             formed-before-returned-consequence
             no-outcome-assumed)
           (nace-pending-unavailable malformed-consequence-route)))
       (nace-pending-unavailable no-single-authority-primary))))

(= (MiterNACEPendingValid $pending $scope $cut $movement)
   (and (CPShape $pending nace-pending-expectation-v1 7)
        (== $pending (MiterNACEPending $scope $cut $movement))))

(= (MiterNACEPendingMatchesReturnedMovement $pending $movement-form)
   (and (CPShape $pending nace-pending-expectation-v1 7)
     (let $reference (index-atom $pending 2)
       (and (CPShape $reference movement-reference 5)
            (== (index-atom $reference 4) $movement-form)))))

(= (MiterNACEPendingRowsForMovement $scope $movement-form)
   (collapse (match &assistant_history
     (assistant-history nace-pending $id $scope $payload)
     (if (MiterNACEPendingMatchesReturnedMovement $payload $movement-form)
       $payload (empty)))))

(= (MiterNACEEvidenceFamily $consequence)
   (nace-evidence-family-v1
     (returned-provenance (index-atom $consequence 12))))

(= (MiterNACEObservation $pending $consequence)
   (let $outcome (index-atom $consequence 4)
     (if (and (CPShape $pending nace-pending-expectation-v1 7)
              (CPConsequenceV2Valid $consequence))
       (if (MiterNACEOutcomeTyped $outcome)
         (nace-observation-v1
           (index-atom $pending 1)
           $outcome
           (MiterNACEOutcomeCounts $outcome)
           (MiterNACEEvidenceFamily $consequence)
           (returned-consequence-reference
             (index-atom $consequence 1) (index-atom $consequence 2)
             $outcome (index-atom $consequence 12))
           (criterion-version miter-nace-outcome-adapter-v1)
           immutable-source-observation)
         (nace-observation-pending-v1
           (index-atom $pending 1) unrecognized-outcome
           (returned-consequence-reference
             (index-atom $consequence 1) (index-atom $consequence 2)
             $outcome (index-atom $consequence 12))))
       (nace-observation-unavailable malformed-pending-or-consequence))))

(= (MiterNACEObservationValid $observation)
   (if (CPShape $observation nace-observation-v1 8)
     (let* (($outcome (index-atom $observation 2))
            ($counts (index-atom $observation 3)))
       (and (CPShape (index-atom $observation 1) nace-target-v1 5)
        (and (MiterNACEOutcomeTyped $outcome)
         (and (== $counts (MiterNACEOutcomeCounts $outcome))
          (and (CPShape (index-atom $observation 4)
                 nace-evidence-family-v1 2)
           (and (CPShape (index-atom $observation 5)
                  returned-consequence-reference 5)
            (and (== (index-atom $observation 6)
                   (criterion-version miter-nace-outcome-adapter-v1))
                 (== (index-atom $observation 7)
                   immutable-source-observation))))))))
     false))

(= (MiterNACEStoredDevelopmentReadable $payload)
   (if (CPShape $payload nace-development-record-v1 4)
     (and (CPShape (index-atom $payload 1)
            nace-pending-expectation-v1 7)
          (MiterNACEObservationValid (index-atom $payload 2)))
     false))

(= (MiterNACEObservationsForTarget $scope $target)
   (collapse (match &assistant_history
     (assistant-history nace-development $id $scope $payload)
     (if (and (MiterNACEStoredDevelopmentReadable $payload)
              (== (index-atom (index-atom $payload 2) 1) $target))
       (index-atom $payload 2) (empty)))))

(= (MiterNACEEvidenceFamilyInAt $family $observations $i)
   (if (< $i (size-atom $observations))
     (if (== (index-atom (index-atom $observations $i) 4) $family)
       true
       (MiterNACEEvidenceFamilyInAt $family $observations (+ $i 1)))
     false))

(= (MiterNACERevisableObservationsAt $observations $i)
   (if (< $i (size-atom $observations))
     (let $observation (index-atom $observations $i)
       (if (MiterNACECountsValid (index-atom $observation 3))
         (cons-atom $observation
           (MiterNACERevisableObservationsAt $observations (+ $i 1)))
         (MiterNACERevisableObservationsAt $observations (+ $i 1))))
     ()))

(= (MiterNALFoldObservationsAt $observations $i $truth $applications)
   (if (< $i (size-atom $observations))
     (let* (($next (MiterNACECountsTruth
              (index-atom (index-atom $observations $i) 3)))
            ($revised (MiterNALTruthRevision $truth $next)))
       (MiterNALFoldObservationsAt $observations (+ $i 1) $revised
         (+ $applications 1)))
     (nal-fold-v1 $truth $applications)))

(= (MiterNALAggregateObservations $observations)
   (if (> (size-atom $observations) 0)
     (let $first-truth (MiterNACECountsTruth
           (index-atom (index-atom $observations 0) 3))
       (if (MiterTruthValueValid $first-truth)
         (MiterNALFoldObservationsAt $observations 1 $first-truth 0)
         (nal-fold-unavailable invalid-first-observation)))
     (nal-fold-unavailable no-revisable-observations)))

(= (MiterNACEEvidenceFamiliesAt $observations $i)
   (if (< $i (size-atom $observations))
     (cons-atom (index-atom (index-atom $observations $i) 4)
       (MiterNACEEvidenceFamiliesAt $observations (+ $i 1)))
     ()))

(= (MiterNACEUpdate $scope $pending $consequence)
   (let $observation (MiterNACEObservation $pending $consequence)
     (if (MiterNACEObservationValid $observation)
       (let* (($target (index-atom $observation 1))
              ($prior (MiterNACEObservationsForTarget $scope $target))
              ($family (index-atom $observation 4)))
         (if (MiterNACEEvidenceFamilyInAt $family $prior 0)
           (nace-update-held-v1 $target correlated-or-repeated-evidence
             $observation)
           (let $counts (index-atom $observation 3)
             (if (MiterNACECountsValid $counts)
               (let* (($all (CPListAppend $prior
                              (cons-atom $observation ())))
                      ($revisable (MiterNACERevisableObservationsAt $all 0))
                      ($fold (MiterNALAggregateObservations $revisable)))
                 (if (CPShape $fold nal-fold-v1 3)
                   (nace-revision-product-v1
                     (qualified-inference-v1 NARS-NAL
                       ae66fa8e41dcd5539d614706bd4e5cfb34f9608d
                       f2a1ab3be59c59128894367a2f52a12c0fafdf1fb26b4affedd48270b47d4b43
                       MiterNALTruthRevision)
                     $target
                     (premises $revisable)
                     (evidence-families
                       (MiterNACEEvidenceFamiliesAt $revisable 0))
                     (truth-semantics
                       NARS-simple-truth-value evidence-weight-c-equals-w-over-w-plus-one
                       independent-returned-observation-counts)
                     (contextual-efficacy (index-atom $fold 1))
                     (operator-applications (index-atom $fold 2))
                     (dependency
                       (index-atom $pending 2)
                       (returned-consequence (index-atom $consequence 1)))
                     unresolved-native-participant
                     no-permission-no-authority-no-numeric-movement-choice)
                   (nace-update-held-v1 $target invalid-native-fold
                     $observation)))
               (nace-update-pending-v1 $target
                 (outcome (index-atom $observation 2))
                 $observation)))))
       (nace-update-held-v1 unknown-target malformed-observation
         $observation))))

(= (MiterNACEUpdateValid $update)
   (if (CPShape $update nace-revision-product-v1 11)
     (and (CPShape (index-atom $update 1) qualified-inference-v1 5)
       (and (CPShape (index-atom $update 2) nace-target-v1 5)
        (and (CPShape (index-atom $update 3) premises 2)
         (and (CPShape (index-atom $update 4) evidence-families 2)
          (and (MiterTruthValueValid
                 (index-atom (index-atom $update 6) 1))
           (and (CPShape (index-atom $update 7) operator-applications 2)
            (and (CPShape (index-atom $update 8) dependency 3)
             (and (== (index-atom $update 9)
                    unresolved-native-participant)
                  (== (index-atom $update 10)
                    no-permission-no-authority-no-numeric-movement-choice)))))))))
     (if (CPShape $update nace-update-pending-v1 4)
       (and (CPShape (index-atom $update 1) nace-target-v1 5)
            (MiterNACEObservationValid (index-atom $update 3)))
       (CPShape $update nace-update-held-v1 4))))

(= (MiterNACEDevelopmentPayloadValid $payload)
   (if (CPShape $payload nace-development-record-v1 4)
     (and (CPShape (index-atom $payload 1)
            nace-pending-expectation-v1 7)
       (and (MiterNACEObservationValid (index-atom $payload 2))
            (MiterNACEUpdateValid (index-atom $payload 3))))
     false))

(= (MiterNACEDevelopment $scope $movement $consequence)
   (let* (($reference (index-atom $consequence 2))
          ($pending-rows (MiterNACEPendingRowsForMovement $scope $reference)))
     (if (== (size-atom $pending-rows) 1)
       (let* (($pending (index-atom $pending-rows 0))
              ($observation (MiterNACEObservation $pending $consequence))
              ($update (MiterNACEUpdate $scope $pending $consequence)))
         (if (and (MiterNACEObservationValid $observation)
                  (MiterNACEUpdateValid $update))
           (nace-development-record-v1 $pending $observation $update)
           (nace-development-held-v1 observation-or-update-invalid
             $pending $observation $update)))
       (nace-development-held-v1
         missing-or-ambiguous-prior-pending-expectation))))

(= (MiterNACEParticipantsFromDevelopment $scope $development)
   (if (MiterNACEDevelopmentPayloadValid $development)
     (let* (($observation (index-atom $development 2))
            ($update (index-atom $development 3))
            ($target (index-atom $observation 1))
            ($consequence-reference (index-atom $observation 5)))
       ((participant-contribution
          (nace-native-reasoning-participation
            (index-atom $consequence-reference 1))
          native-authority $scope
          (lineage qualified-NARS-NAL
            ae66fa8e41dcd5539d614706bd4e5cfb34f9608d)
          (participant-relation-claim nace-contextual-development support
            (qualified-reasoning-evidence $target $update))
          supported no-contact-no-movement-authority)
        (participant-contribution
          (nace-returned-observation-participation
            (index-atom $consequence-reference 1))
          returned-contact $scope
          (lineage returned-consequence
            (index-atom $consequence-reference 1))
          (participant-relation-claim nace-contextual-development support
            (returned-nace-evidence $observation))
          supported no-contact-no-movement-authority)))
     ()))

(= (MiterNACEParticipantsForConsequence $scope $movement $consequence)
   (MiterNACEParticipantsFromDevelopment $scope
     (MiterNACEDevelopment $scope $movement $consequence)))

(= (MiterNACEDevelopmentsForScope $scope)
   (collapse (match &assistant_history
     (assistant-history nace-development $id $scope $payload)
     (if (MiterNACEDevelopmentPayloadValid $payload) $payload (empty)))))

(= (MiterNACEHistoricalParticipantsAt $scope $developments $i)
   (if (< $i (size-atom $developments))
     (CPListAppend
       (MiterNACEParticipantsFromDevelopment $scope
         (index-atom $developments $i))
       (MiterNACEHistoricalParticipantsAt $scope $developments (+ $i 1)))
     ()))

(= (MiterNACEHistoricalParticipantsForScope $scope)
   (MiterNACEHistoricalParticipantsAt $scope
     (MiterNACEDevelopmentsForScope $scope) 0))

(= (MiterQualifiedReasoningBoundary)
   (qualified-reasoning-boundary-v1
     NAL consequence-earned-contextual-revision
     PLN consequence-earned-relational-transfer-hypothesis
     namespace broad-unqualified-library-import-prohibited
     outputs attributable-supported-non-authoritative-native-participants
     prohibitions permission authority scalar-choice contact-fabrication
       self-confirmation))
