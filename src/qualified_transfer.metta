; Consequence-earned PLN relational transfer for the one Miter runtime.
;
; This late adapter can see the completed C3 developmental record ontology.
; The qualified PLN operator itself is defined in qualified_reasoning.metta
; before provisional dynamics compile, so the consumer and producer share one
; pinned meaning without importing the colliding PLN/NARS global namespaces.

(= (MiterPLNTransferRecordsForScope $scope)
   (let* (($v6 (collapse (match &assistant_history
            (assistant-history consequence $id $scope
              (consequence-incorporation-v6 $next $m24 $prior $returned
                $semantic $transfer $standing))
            $transfer)))
          ($v7 (collapse (match &assistant_history
            (assistant-history consequence $id $scope
              (consequence-incorporation-v7 $next $m24 $prior $returned
                $semantic $transfer $alignment $standing))
            $transfer)))
          ($v8 (collapse (match &assistant_history
            (assistant-history consequence $id $scope
              (consequence-incorporation-v8 $next $m24 $prior $returned
                $semantic $transfer $alignment $memory $standing))
            $transfer)))
          ($rows (CPListAppend $v6 (CPListAppend $v7 $v8))))
     (if (> (size-atom $rows) 0)
       (collapse (let $record (superpose $rows)
         (if (C3DevelopmentalTransferRecordValid $record) $record (empty))))
       ())))

(= (MiterPLNNACEProductFromDevelopment $development)
   (if (MiterNACEDevelopmentPayloadValid $development)
     (let $update (index-atom $development 3)
       (if (CPShape $update nace-revision-product-v1 11) $update
         (pln-source-unavailable no-revisable-nace-product)))
     (pln-source-unavailable invalid-nace-development)))

(= (MiterPLNRelationalTransferProduct $scope $nace $transfer)
   (if (and (MiterNACEUpdateValid $nace)
            (C3DevelopmentalTransferRecordValid $transfer))
     (let* (($target (index-atom $nace 2))
            ($nace-scope (index-atom $target 1))
            ($possibility-wrapper (index-atom $target 3))
            ($source-efficacy-wrapper (index-atom $nace 6))
            ($dependency (index-atom $nace 8))
            ($nace-returned-wrapper (index-atom $dependency 2))
            ($source-reference (index-atom $transfer 3))
            ($transfer-reference (index-atom $transfer 1))
            ($transfer-resolution (index-atom $transfer 4))
            ($possibility-id (if (CPShape $possibility-wrapper possibility 2)
              (index-atom $possibility-wrapper 1) unavailable))
            ($source-efficacy (if
              (CPShape $source-efficacy-wrapper contextual-efficacy 2)
              (index-atom $source-efficacy-wrapper 1) unavailable))
            ($nace-returned (if
              (CPShape $nace-returned-wrapper returned-consequence 2)
              (index-atom $nace-returned-wrapper 1) unavailable))
            ($source-cut (if (CPShape $source-reference movement-reference 5)
              (index-atom $source-reference 1) unavailable))
            ($source-movement (if
              (CPShape $source-reference movement-reference 5)
              (index-atom $source-reference 4) unavailable))
            ($transfer-returned (if
              (CPShape $transfer-reference transfer-development-reference 2)
              (index-atom $transfer-reference 1) unavailable))
            ($transfer-standing
              (C3DevelopmentalTransferStanding $transfer-resolution))
            ($relation-truth
              (MiterPLNTransferStandingTruth $transfer-standing)))
       (if (and (== $scope $nace-scope)
             (and (== $scope (index-atom $transfer 2))
              (and (== $possibility-id $source-movement)
               (and (!= $nace-returned $transfer-returned)
                (and (MiterPLNCutContainsConsequence
                       $source-cut $nace-returned)
                 (and (MiterTruthValueValid $source-efficacy)
                      (MiterTruthValueValid $relation-truth)))))))
         (pln-relational-transfer-product-v1
           (qualified-inference-v1 PLN
             ae66fa8e41dcd5539d614706bd4e5cfb34f9608d
             6b980321bbe9b49e5b12e2fcee0479ab1d5c7550c2104a67b0722a5b473da4ee
             MiterPLNTruthModusPonens)
           $scope
           (source-nace-revision $nace)
           (developmental-transfer-premise $transfer)
           (source-contextual-efficacy $source-efficacy)
           (relational-transfer-premise $relation-truth)
           (independent-evidence-families
             (nace-returned-consequence $nace-returned)
             (transfer-returned-consequence $transfer-returned))
           (truth-semantics PLN-simple-truth-value
             miter-pln-transfer-standing-adapter-v1
             exact-independent-returned-consequences)
           (contextual-transfer-hypothesis
             (MiterPLNTruthModusPonens $source-efficacy $relation-truth))
           (dependency (source-possibility $possibility-id)
             (source-cut $source-cut)
             (transfer-returned-consequence $transfer-returned))
           unresolved-native-participant
           no-permission-no-authority-no-numeric-movement-choice)
         (pln-relational-transfer-unavailable
           non-independent-or-materially-unmatched-premises)))
     (pln-relational-transfer-unavailable invalid-source-products)))

(= (MiterPLNRelationalTransferProductValid $product)
   (if (MiterPLNRelationalTransferProductStructurallyValid $product)
     (let* (($scope (index-atom $product 2))
            ($nace (index-atom (index-atom $product 3) 1))
            ($transfer (index-atom (index-atom $product 4) 1)))
       (and (C3DevelopmentalTransferRecordValid $transfer)
            (== $product
              (MiterPLNRelationalTransferProduct $scope $nace $transfer))))
     false))

(= (MiterPLNProductsForNACEAt $scope $nace $transfers $i)
   (if (< $i (size-atom $transfers))
     (let $product (MiterPLNRelationalTransferProduct $scope $nace
                      (index-atom $transfers $i))
       ; This product was just constructed from a validated NACE update and
       ; full developmental-transfer record. Re-running the complete
       ; constructor equality proof here is exact but redundant; retain the
       ; independent structural proof before admitting it to the local list.
       (if (MiterPLNRelationalTransferProductStructurallyValid $product)
         (cons-atom $product
           (MiterPLNProductsForNACEAt $scope $nace $transfers (+ $i 1)))
         (MiterPLNProductsForNACEAt $scope $nace $transfers (+ $i 1))))
     ()))

(= (MiterPLNProductsAt $scope $developments $transfers $i)
   (if (< $i (size-atom $developments))
     (let $nace (MiterPLNNACEProductFromDevelopment
                  (index-atom $developments $i))
       (CPListAppend
         (if (CPShape $nace nace-revision-product-v1 11)
           (MiterPLNProductsForNACEAt $scope $nace $transfers 0) ())
         (MiterPLNProductsAt $scope $developments $transfers (+ $i 1))))
     ()))

(= (MiterPLNDerivableProductsForScope $scope)
   (MiterPLNProductsAt $scope
     (MiterNACEDevelopmentsForScope $scope)
     (MiterPLNTransferRecordsForScope $scope) 0))

(= (MiterPLNProductHistoryId $product)
   (let* (($families (index-atom $product 7))
          ($nace (index-atom (index-atom $families 1) 1))
          ($transfer (index-atom (index-atom $families 2) 1)))
     (pln-relational-transfer-product $nace $transfer)))

(= (MiterPLNDevelopmentHistoryValid $row)
   (if (and (CPShape $row assistant-history 5)
            (== (index-atom $row 1) pln-development))
     (let* (($id (index-atom $row 2))
            ($scope (index-atom $row 3))
            ($product (index-atom $row 4)))
       (and (MiterPLNRelationalTransferProductValid $product)
         (and (== $scope (index-atom $product 2))
              (== $id (MiterPLNProductHistoryId $product)))))
     false))

(= (MiterPLNRecordProductsAt $scope $products $i)
   (if (< $i (size-atom $products))
     (let* (($product (index-atom $products $i))
            ($id (MiterPLNProductHistoryId $product))
            ($recorded (ARRecord pln-development $id $scope $product)))
       (cons-atom $recorded
         (MiterPLNRecordProductsAt $scope $products (+ $i 1))))
     ()))

; Product formation occurs once at the returned-consequence cut. It compares
; the new exact transfer premise only with prior qualified NACE developments,
; persists every independent result, and leaves later contacts to consume the
; stored qualified products rather than recomputing a growing cross-product.
(= (MiterPLNRecordProductsForTransfer $scope $transfer)
   (if (C3DevelopmentalTransferRecordValid $transfer)
     (let* (($products (MiterPLNProductsAt $scope
              (MiterNACEDevelopmentsForScope $scope) ($transfer) 0))
            ($records (MiterPLNRecordProductsAt $scope $products 0)))
       (if (> (size-atom $products) 0)
         (pln-development-records-v1
           (product-count (size-atom $products)) (records $records))
         pln-development-not-applicable))
     pln-development-not-applicable))

(= (MiterPLNRecordOutcomesValidAt $records $i)
   (if (< $i (size-atom $records))
     (and (CPHas (index-atom $records $i)
            (assistant-history-recorded assistant-history-duplicate) 0)
          (MiterPLNRecordOutcomesValidAt $records (+ $i 1))) true))

(= (MiterPLNRecordStandingValid $standing)
   (if (== $standing pln-development-not-applicable) true
     (if (CPShape $standing pln-development-records-v1 3)
       (let* (($count (index-atom (index-atom $standing 1) 1))
              ($records (index-atom (index-atom $standing 2) 1)))
         (and (== $count (size-atom $records))
           (and (> $count 0)
                (MiterPLNRecordOutcomesValidAt $records 0))))
       false)))

(= (MiterPLNStoredProductsForScope $scope)
   (collapse (match &assistant_history
     (assistant-history pln-development $id $scope $product)
     ; Restore performs the full exact reconstruction proof once. Live rows
     ; are admitted only by MiterPLNRecordProductsForTransfer. The read path
     ; therefore needs only the integrity-preserving structural and scope read.
     (if (and (MiterPLNRelationalTransferProductStructurallyValid $product)
              (== (index-atom $product 2) $scope))
       $product (empty)))))

(= (MiterPLNProductsForScope $scope)
   (MiterPLNStoredProductsForScope $scope))

(= (MiterPLNParticipantFromConstructedProduct $scope $product)
   (if (MiterPLNRelationalTransferProductStructurallyValid $product)
     (let* (($families (index-atom $product 7))
            ($nace-id (index-atom (index-atom $families 1) 1))
            ($transfer-id (index-atom (index-atom $families 2) 1))
            ($transfer (index-atom (index-atom $product 4) 1))
            ($standing (C3DevelopmentalTransferStanding
              (index-atom $transfer 4))))
       (participant-contribution
         (pln-relational-transfer-participation $nace-id $transfer-id)
         qualified-native-reasoning $scope
         (lineage qualified-PLN
           ae66fa8e41dcd5539d614706bd4e5cfb34f9608d
           $nace-id $transfer-id)
         (participant-relation-claim
           (pln-relational-transfer-hypothesis $nace-id $transfer-id)
           $standing
           (qualified-pln-relational-transfer-evidence $product))
         candidate no-contact-no-movement-authority))
     (participant-unresolved qualified-PLN invalid-relational-transfer-product)))

; The public constructor accepts an independently supplied product only after
; the full exact-reconstruction proof. Historical assembly calls the narrower
; helper above because each stored row was constructed at consequence time and
; passed the full restore invariant before this read.
(= (MiterPLNParticipantFromProduct $scope $product)
   (if (MiterPLNRelationalTransferProductValid $product)
     (MiterPLNParticipantFromConstructedProduct $scope $product)
     (participant-unresolved qualified-PLN invalid-relational-transfer-product)))

(= (MiterPLNParticipantsAt $scope $products $i)
   (if (< $i (size-atom $products))
     (cons-atom (MiterPLNParticipantFromConstructedProduct $scope
                  (index-atom $products $i))
       (MiterPLNParticipantsAt $scope $products (+ $i 1)))
     ()))

(= (MiterPLNHistoricalParticipantsForScope $scope)
   (MiterPLNParticipantsAt $scope (MiterPLNProductsForScope $scope) 0))
