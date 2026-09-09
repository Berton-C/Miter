; Provisional Inquiry-26.6/26.9 laboratory dynamics.
;
; This module does not amend the five ratified authorities. It makes one
; bounded, provenance-bearing experimental choice: partial alignment in one
; simultaneous R/A/P read is treated as a generative opening. What is aligned
; is preserved; what remains unresolved is carried into renewed contact.
; Returned consequence may then reorganize later possibility formation. There
; is no scalar objective, R/A/P reconstruction, scenario table, model chooser,
; or second cognitive engine here.

(= (C3RAPRelatednessRow $reading)
   (let* (($rap (index-atom $reading 2))
          ($perspectives (index-atom $rap 2))
          ($perspective (index-atom $perspectives 1))
          ($profile (index-atom $perspective 3)))
     (c3-rap-perspective Relatedness
       (if (and (CPShape $profile relatedness-profile 4)
                (== (index-atom $profile 3) true)) aligned unresolved)
       $perspective)))

(= (C3RAPAppropriatenessRow $reading)
   (let* (($rap (index-atom $reading 2))
          ($perspectives (index-atom $rap 2))
          ($perspective (index-atom $perspectives 2))
          ($read-app (index-atom $perspective 3)))
     (c3-rap-perspective Appropriateness
       (if (CPShape $read-app read-app-v2 10) aligned unresolved)
       $perspective)))

(= (C3RAPPrecisionRow $reading)
   (let* (($rap (index-atom $reading 2))
          ($perspectives (index-atom $rap 2))
          ($perspective (index-atom $perspectives 3))
          ($profile (index-atom $perspective 3)))
     (c3-rap-perspective Precision
       (if (and (CPShape $profile precision-profile 4)
                (== (index-atom $profile 3) true)) aligned unresolved)
       $perspective)))

(= (C3RAPRows $reading)
   ((C3RAPRelatednessRow $reading)
    (C3RAPAppropriatenessRow $reading)
    (C3RAPPrecisionRow $reading)))

(= (C3RAPRowsWithStandingAt $rows $standing $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (CPShape $row c3-rap-perspective 4)
                (== (index-atom $row 2) $standing))
         (cons-atom $row
           (C3RAPRowsWithStandingAt $rows $standing (+ $i 1)))
         (C3RAPRowsWithStandingAt $rows $standing (+ $i 1))))
     ()))

(= (C3RAPConfiguration $reading $cut $developmental)
   (let* (($primary (index-atom $reading 1))
          ($rap (index-atom $reading 2))
          ($rows (C3RAPRows $reading))
          ($aligned (C3RAPRowsWithStandingAt $rows aligned 0))
          ($unresolved (C3RAPRowsWithStandingAt $rows unresolved 0)))
     (if (and (CPShape $reading m25-movement-reading-v3 9)
           (and (CPShape $primary m25-primary-movement-v2 11)
                (CPShape $rap rap-read-v2 6)))
       (c3-rap-configuration-v1
         (index-atom $rap 1)
         (movement-reference (index-atom $primary 1)
           (index-atom $primary 2))
         (simultaneous-perspectives $rows)
         (preserved-alignment $aligned)
         (generative-unresolved $unresolved)
         same-contact-one-movement
         heterogeneous-non-compensatory
         non-scalar-non-reconstructive)
       (c3-rap-configuration-unresolved invalid-m25-reading))))

(= (C3RAPConfigurationValid $configuration $reading $cut $developmental)
   (and (CPShape $configuration c3-rap-configuration-v1 9)
        (== $configuration (C3RAPConfiguration $reading $cut $developmental))))

(= (C3PartialRAP $configuration)
   (if (CPShape $configuration c3-rap-configuration-v1 9)
     (let* (($aligned (index-atom (index-atom $configuration 4) 1))
            ($unresolved (index-atom (index-atom $configuration 5) 1)))
       (and (> (size-atom $aligned) 0) (> (size-atom $unresolved) 0)))
     false))

(= (C3PerspectiveNamesAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (CPShape $row c3-rap-perspective 4)
         (cons-atom (index-atom $row 1)
           (C3PerspectiveNamesAt $rows (+ $i 1)))
         (C3PerspectiveNamesAt $rows (+ $i 1))))
     ()))

(= (C3PartialAlignmentOpening $reading $cut $developmental)
   (let* (($primary (index-atom $reading 1))
          ($configuration (C3RAPConfiguration $reading $cut $developmental))
          ($balance (index-atom $primary 5))
          ($possibility (index-atom $primary 9)))
     (if (and (CPShape $configuration c3-rap-configuration-v1 9)
           (and (C3PartialRAP $configuration)
                (CPShape $possibility possible-movement 9)))
       (c3-partial-alignment-opening-v2
         (index-atom $configuration 2)
         (rap-read-reference (index-atom $primary 1)
           one-contact-simultaneous-three-perspective-read)
         (source-cut (index-atom $cut 1))
         (preserve
           (C3PerspectiveNamesAt
             (index-atom (index-atom $configuration 4) 1) 0))
         (explore
           (C3PerspectiveNamesAt
             (index-atom (index-atom $configuration 5) 1) 0))
         (constitutive-participation-reference
           (index-atom $balance 1) (index-atom $balance 3)
           (source-constitutive-material-v1
             (required-relations (index-atom $possibility 3))
             (required-flourishings (index-atom $possibility 6))))
         (provenance-reference (index-atom $cut 1)
           (index-atom $developmental 13))
         unresolved-is-generative-opening-not-deficit)
       (c3-partial-alignment-opening-unavailable
         no-simultaneous-partial-alignment))))

(= (C3PartialAlignmentOpeningValid $opening $reading $cut $developmental)
   (and (CPShape $opening c3-partial-alignment-opening-v2 9)
        (== $opening
          (C3PartialAlignmentOpening $reading $cut $developmental))))

(= (C3OpeningsAt $readings $cut $developmental $i)
   (if (< $i (size-atom $readings))
     (let* (($reading (index-atom $readings $i))
            ($opening (C3PartialAlignmentOpening $reading $cut
              $developmental)))
       (if (CPShape $opening c3-partial-alignment-opening-v2 9)
         (cons-atom $opening
           (C3OpeningsAt $readings $cut $developmental (+ $i 1)))
         (C3OpeningsAt $readings $cut $developmental (+ $i 1))))
     ()))

(= (C3MovementReadings $movement)
   (if (CPShape $movement movement-formed 7)
     (let $retained (index-atom $movement 6)
       (if (CPShape $retained retained-alternatives-v3 3)
         (index-atom $retained 1) ()))
     (if (CPShape $movement movement-plural-live 4)
       (let $retained (index-atom $movement 3)
         (if (CPShape $retained retained-alternatives-v3 3)
           (index-atom $retained 1) ()))
       (if (CPShape $movement movement-unresolved 3)
         (let $retained (index-atom $movement 2)
           (if (CPShape $retained retained-alternatives-v3 3)
             (index-atom $retained 1) ()))
         ()))))

(= (C3MovementBasisFromReadings $movement)
   (let $readings (C3MovementReadings $movement)
     (if (> (size-atom $readings) 0)
       (let* (($reading (index-atom $readings 0))
              ($primary (index-atom $reading 1)))
         (if (CPShape $primary m25-primary-movement-v2 11)
           (index-atom $primary 8) no-continuation-basis))
       no-continuation-basis)))

(= (C3OpeningsFromMovement $movement $cut $developmental)
   (C3OpeningsAt (C3MovementReadings $movement) $cut $developmental 0))

(= (C3ConsequenceMaterial $consequence)
   (c3-returned-material-v1
     (index-atom $consequence 5) (index-atom $consequence 6)
     (index-atom $consequence 7) (index-atom $consequence 8)
     (index-atom $consequence 9) (index-atom $consequence 10)
     (index-atom $consequence 11) (index-atom $consequence 12)))

; A returned Omega relation already carries an exact, bounded first-eight role
; support and provenance.  Re-form it as a finite contact-relative Fact9 view
; for the next cut so previously unseen lawful compositions can participate
; without a new behavioral branch.  This is recognition of the supplied
; relation, not reconstruction of actuality or invention of a missing role.
(= (C3ConsequenceFactViewsAt $relations $consequence-id $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation material-relation 5)
                (CPSupportValid (index-atom $relation 2)))
         (cons-atom
           (fact-view (index-atom $relation 1)
             (index-atom $relation 2)
             ((index-atom $relation 1)) recognized
             (returned-consequence-explicit-role-recognition
               $consequence-id (index-atom $relation 4)))
           (C3ConsequenceFactViewsAt $relations $consequence-id (+ $i 1)))
         (C3ConsequenceFactViewsAt $relations $consequence-id (+ $i 1))))
     ()))

(= (C3ConsequenceFactViews $consequence)
   (if (CPConsequenceV2Valid $consequence)
     (C3ConsequenceFactViewsAt
       (index-atom (index-atom $consequence 6) 1)
       (index-atom $consequence 1) 0)
     ()))

(= (C3ConsequenceHasMaterial $consequence)
   (if (CPConsequenceV2Valid $consequence)
     (or (> (size-atom (index-atom (index-atom $consequence 5) 1)) 0)
      (or (> (size-atom (index-atom (index-atom $consequence 5) 2)) 0)
       (or (> (size-atom (index-atom (index-atom $consequence 6) 1)) 0)
        (or (> (size-atom (index-atom (index-atom $consequence 7) 1)) 0)
         (or (> (size-atom (index-atom (index-atom $consequence 8) 1)) 0)
          (or (> (size-atom (index-atom (index-atom $consequence 9) 1)) 0)
              (> (size-atom (index-atom (index-atom $consequence 10) 1)) 0)))))))
     false))

(= (C3ReorganizationForOpening $opening $consequence)
   (c3-possible-reorganization-v1
     (source-opening $opening)
     (preserved-alignment (index-atom $opening 4))
     (unresolved-relation (index-atom $opening 5))
     (returned-contact (C3ConsequenceMaterial $consequence))
     (counterfactual-discrimination
       without-returned-contact-opening-remains-unresolved
       with-returned-contact-next-possibility-must-be-reformed)
     same-generative-law
     no-preselected-outcome))

(= (C3ReorganizationsAt $openings $consequence $i)
   (if (< $i (size-atom $openings))
     (cons-atom
       (C3ReorganizationForOpening (index-atom $openings $i) $consequence)
       (C3ReorganizationsAt $openings $consequence (+ $i 1)))
     ()))

(= (C3ReorganizationFamily $movement $cut $developmental $consequence)
   (let* (($openings (C3OpeningsFromMovement $movement $cut $developmental))
          ($reorganizations (C3ReorganizationsAt $openings $consequence 0)))
     (if (and (> (size-atom $openings) 0)
           (and (C3ConsequenceHasMaterial $consequence)
                (== (index-atom $movement 2) (index-atom $consequence 2))))
       (c3-reorganization-family-v1
         (movement-reference (index-atom $movement 2)
           (index-atom $movement 1))
         (source-cut (index-atom $cut 1))
         (returned-consequence (index-atom $consequence 1))
         (lawful-possibilities $reorganizations)
         (comparison preserve-aligned-material
           expose-unresolved-difference consequence-answerable)
         (joined-standing all-noncompensatory-openings-retained)
         no-argmax-no-scalar-no-rules-table)
       (c3-reorganization-family-unresolved
         no-partial-opening-or-material-consequence))))

(= (C3ReorganizationFamilyValid $family $movement $cut $developmental
      $consequence)
   (and (CPShape $family c3-reorganization-family-v1 8)
        (== $family
          (C3ReorganizationFamily $movement $cut $developmental $consequence))))

; Two independent lineages are required before the laboratory result becomes
; a material relation: native MeTTa supplies the provisional generative
; interpretation; returned contact supplies the actual reorganization. The
; relation is evidence for later cognition, never its own authority. The
; caller supplies the already validated active movement from &assistant_state;
; this layer does not repeatedly reconstruct the complete C2 certificate for
; every retained reading.
(= (C3ConsequenceParticipants $scope $cut $movement $developmental
      $consequence)
   (let* (($family (C3ReorganizationFamily $movement $cut $developmental
            $consequence))
          ($consequence-id (index-atom $consequence 1)))
     (if (CPShape $family c3-reorganization-family-v1 8)
       ((participant-contribution
          (c3-native-partial-alignment-participation $consequence-id)
          native-authority $scope
          (lineage provisional-26.6-26.9 partial-rap-generativity)
          (participant-relation-claim c3-partial-rap-reorganization
            support
            (c3-native-generative-basis-v2
              (C3OpeningsFromMovement $movement $cut $developmental)
              preserve-aligned-explore-unresolved
              one-contact-one-movement-three-perspectives))
          supported no-contact-no-movement-authority)
        (participant-contribution
          (c3-returned-partial-alignment-participation $consequence-id)
          returned-contact $scope
          (lineage returned-consequence $consequence-id)
          (participant-relation-claim c3-partial-rap-reorganization
            support
            (c3-returned-reorganization-evidence-v2 $family
              (index-atom $consequence 12)))
          supported no-contact-no-movement-authority))
       ())))

(= (C3ReturnedEvidenceFromClaimsAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (CPShape $evidence c3-returned-reorganization-evidence-v2 3)
         (cons-atom $evidence
           (C3ReturnedEvidenceFromClaimsAt $claims (+ $i 1)))
         (C3ReturnedEvidenceFromClaimsAt $claims (+ $i 1))))
     ()))

(= (C3ReturnedEvidenceFromCut $cut)
   (C3ReturnedEvidenceFromClaimsAt
     (M255ParticipantClaimsForTargetAtCut $cut
       c3-partial-rap-reorganization) 0))

(= (C3EvidenceConsequenceIdsAt $evidence $i)
   (if (< $i (size-atom $evidence))
     (let* (($row (index-atom $evidence $i))
            ($family (index-atom $row 1))
            ($returned (index-atom $family 3)))
       (cons-atom (index-atom $returned 1)
         (C3EvidenceConsequenceIdsAt $evidence (+ $i 1))))
     ()))

; The thought-partner projection consumes the consequence-earned opening. It
; is loaded here so its possible readings participate at the same formation
; seam, not in a parallel model loop.
!(import! &self "./src/model_participation.metta")

(= (C3LearnedPossibilities $cut)
   (let $evidence (C3ReturnedEvidenceFromCut $cut)
     (if (> (size-atom $evidence) 0)
       ((possible-movement
          c3-developmental-inquiry
          inquiry
          (CPNativeRequirementRelations $cut)
          (CPNativeRequirementDistinctions $cut)
          (CPNativeRequirementInterfaces $cut)
          (CPFlourishingValues)
          (consequence-route
            (discriminating-developmental-contact
              (returned-consequences
                (C3EvidenceConsequenceIdsAt $evidence 0))
              (reorganization-evidence-count (size-atom $evidence))
              (material-relation c3-partial-rap-reorganization))
            non-certifying)
          l2425-supported))
       ())))

; Once a consequence-earned generative opening exists, the generic inquiry is
; replaced by its source-grounded refinement. Undertaking and deferral remain
; available as independently constructed alternatives. This is refinement by
; persisted relational evidence, not first-match behavioral selection.
(= (C3NACERevisionProductsAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       ; PeTTa's `and` evaluates both operands, so indexing a non-qualified
       ; claim here would erase the whole family. Guard the product read
       ; structurally before inspecting it.
       (if (CPShape $evidence qualified-reasoning-evidence 3)
         (if (CPShape (index-atom $evidence 2)
               nace-revision-product-v1 11)
           (cons-atom (index-atom $evidence 2)
             (C3NACERevisionProductsAt $claims (+ $i 1)))
           (C3NACERevisionProductsAt $claims (+ $i 1)))
         (C3NACERevisionProductsAt $claims (+ $i 1))))
     ()))

(= (C3NACEInquiryPossibilities $cut)
   (let $products (C3NACERevisionProductsAt
          (M255ParticipantClaimsForTargetAtCut $cut
            nace-contextual-development) 0)
     (if (> (size-atom $products) 0)
       ((possible-movement nace-consequence-discrimination inquiry
          (CPNativeRequirementRelations $cut)
          (CPNativeRequirementDistinctions $cut)
          (CPNativeRequirementInterfaces $cut)
          (CPFlourishingValues)
          (consequence-route
            (nace-discriminating-contact
              (qualified-revision-products $products))
            non-certifying)
          l2425-supported))
       ())))

(= (C3NativePossibilities $cut $facts $flourishing $participant-relations)
   (let* (($learned (C3LearnedPossibilities $cut))
          ($alignment (C3AlignmentInquiryPossibilities $cut $facts
            $flourishing))
          ($transfer (C3SemanticDevelopmentTransferPossibilities $cut $facts
            $flourishing $participant-relations))
          ($overlap-comparison
            (C3DevelopmentalOverlapComparisonPossibilities $cut $facts
              $flourishing $participant-relations))
          ($overlap-result
            (C3DevelopmentalOverlapResultPossibilities $cut
              $participant-relations))
          ($transfer-result
            (C3DevelopmentalTransferResultPossibilities $cut
              $participant-relations))
          ($memory-result
            (C3DevelopmentalMemoryResultPossibilities $cut
              $participant-relations))
          ($current-undertakings
            (CPNativeUndertakingsV2 $cut $facts $flourishing
              $participant-relations))
          ($transfer-current-joins
            (C3UniqueTransferCurrentUndertakingJoins $transfer-result
              $current-undertakings $cut))
          ($unjoined-transfer-result
            (if (> (size-atom $transfer-current-joins) 0)
              () $transfer-result))
          ($memory-current-joins
            (C3UniqueMemoryCurrentUndertakingJoins $memory-result
              $current-undertakings $cut))
          ($unjoined-memory-result
            (if (> (size-atom $memory-current-joins) 0)
              () $memory-result))
          ($alignment-result
            (C3AlignmentResultPossibilities $cut $participant-relations))
          ($transfer-memory
            (C3TransferDevelopmentMemoryPossibilities $cut $facts
              $flourishing $participant-relations))
          ($memory-continuation
            (C3MemoryApplicationContinuationPossibilities $cut $facts
              $flourishing $participant-relations))
          ($semantic-inquiry
            (C3SemanticInquiryPossibilities $cut $participant-relations))
          ($capability-inquiry
            (C4CapabilityProposalPossibilities $cut $flourishing
              $participant-relations))
          ($capability-result
            (C4CapabilityResultPossibilities $cut $participant-relations))
          ($nace-inquiry (C3NACEInquiryPossibilities $cut))
          ($workshop-transition
            (WHCapabilityTransitionPossibilities $cut $flourishing
              $participant-relations))
          ($active-capabilities
            (WHActiveCapabilityPossibilities $cut $flourishing
              $participant-relations))
          ; The semantic inquiry is the same source inquiry enriched by its
          ; returned candidate family, so retaining both would duplicate one
          ; cognitive possibility. A transfer inquiry has a different source
          ; contact and remains independently live when present.
          ($base-source-inquiry (if (> (size-atom $workshop-transition) 0)
            $workshop-transition
            (if (> (size-atom $capability-result) 0)
              $capability-result
              (if (> (size-atom $capability-inquiry) 0)
                $capability-inquiry
                (if (> (size-atom $semantic-inquiry) 0)
                  $semantic-inquiry
                  (if (> (size-atom $alignment) 0) $alignment $learned))))))
          ; A later memory-standing inquiry is the exact source-grounded
          ; refinement of the generic alignment inquiry on this contact.  Keep
          ; one rather than duplicating the same cognitive opening.
          ($source-inquiry (if (> (size-atom $memory-continuation) 0)
            () $base-source-inquiry))
          ($specialized (CPListAppend $nace-inquiry
            (CPListAppend $memory-continuation
            (CPListAppend $source-inquiry
              (CPListAppend $overlap-result
                (CPListAppend $overlap-comparison
                  (CPListAppend $transfer
                    (CPListAppend $unjoined-transfer-result
                      (CPListAppend $transfer-memory
                        $unjoined-memory-result))))))))))
     (CPListAppend $active-capabilities
     (CPListAppend
       ; Exact returned alignment contact refines the generic undertaking
       ; surface. It does not add a second scheduler or first-match branch:
       ; M25 still determines availability from the same participant
       ; organization and one simultaneous R/A/P read.
       (if (> (size-atom $memory-current-joins) 0)
         (CPListAppend $alignment-result $memory-current-joins)
         (if (> (size-atom $transfer-current-joins) 0)
           (CPListAppend $alignment-result $transfer-current-joins)
           (if (> (size-atom $alignment-result) 0) $alignment-result
             $current-undertakings)))
       (CPListAppend
         (if (> (size-atom $specialized) 0) $specialized
           (CPNativeInquiriesV2 $cut $facts $flourishing
             $participant-relations))
         (CPListAppend
           (C3ModelPossibilities $cut $participant-relations)
           (CPNativeDeferralsV2 $cut $flourishing)))))))

(= (C3LaboratoryBoundary)
   (c3-provisional-boundary-v1
     authority Inquiry-26.6-and-Inquiry-26.9-not-yet-ratified
     experiment partial-rap-generativity-through-returned-consequence
     reversible native-reprojection-from-persisted-relational-evidence
     preserves M24-M25.5-M26.0-M26.3-without-amendment
     falsifiers scalar-optimization rap-reconstruction scenario-rule-table
       self-confirmation consequence-free-growth second-cognitive-engine
     output formalization-observations-counterexamples-and-earned-relations))
