; C3 bounded semantic thought-partner participation.
;
; The Soul forms the question from a consequence-earned partial R/A/P opening.
; A model may return possible readings. Those readings remain typed proposals:
; they are not contact, evidence of alignment, movement authority, or a verdict.

(= (C3OpeningsFromReorganizationsAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (CPShape $row c3-possible-reorganization-v1 8)
         (let $source (index-atom $row 1)
           (if (CPShape $source source-opening 2)
             (cons-atom (index-atom $source 1)
               (C3OpeningsFromReorganizationsAt $rows (+ $i 1)))
             (C3OpeningsFromReorganizationsAt $rows (+ $i 1))))
         (C3OpeningsFromReorganizationsAt $rows (+ $i 1))))
     ()))

(= (C3OpeningsFromReturnedEvidence $evidence)
   (if (== (size-atom $evidence) 1)
     (let* (($row (index-atom $evidence 0))
            ($family (index-atom $row 1))
            ($lawful (if (CPShape $family c3-reorganization-family-v1 8)
              (index-atom $family 4) ())))
       (if (CPShape $lawful lawful-possibilities 2)
         (C3OpeningsFromReorganizationsAt (index-atom $lawful 1) 0) ()))
     ()))

(= (C3SemanticQuestionInstructions)
  "Return only one JSON object with this exact shape: {\"uncertainty\":\"...\",\"candidates\":[{\"summary\":\"...\",\"preserve\":[\"Relatedness\"],\"explore\":[\"Appropriateness\"],\"counterfactual\":\"...\"}]}. Return 2 or 3 materially different relational possibilities. Use only Relatedness, Appropriateness, and Precision in preserve/explore. Preserve every perspective identified as aligned, explore only perspectives identified as unresolved, and use the supplied Fact9 and interconnected flourishing inquiry surfaces to explain what new contact or distinction could disclose fuller alignment. Do not choose a candidate, claim alignment, issue a verdict, address the human, add a value or Fact9 role which Miter did not supply, or use a Markdown fence.")

(= (C3OpeningSourceMaterial $opening)
   (if (CPShape $opening c3-partial-alignment-opening-v2 9)
     (let $reference (index-atom $opening 6)
       (if (CPShape $reference constitutive-participation-reference 4)
         (index-atom $reference 3)
         (source-constitutive-material-unavailable)))
     (source-constitutive-material-unavailable)))

(= (C3OpeningRequiredRelations $opening)
   (let $material (C3OpeningSourceMaterial $opening)
     (if (and (CPShape $material source-constitutive-material-v1 3)
              (CPShape (index-atom $material 1) required-relations 2))
       (index-atom (index-atom $material 1) 1) ())))

(= (C3OpeningRequiredFlourishings $opening)
   (let $material (C3OpeningSourceMaterial $opening)
     (if (and (CPShape $material source-constitutive-material-v1 3)
              (CPShape (index-atom $material 2) required-flourishings 2))
       (index-atom (index-atom $material 2) 1) ())))

(= (C3FactRelevantToRequirementsAt $fact $requirements $i)
   (if (< $i (size-atom $requirements))
     (if (CPFactCoversRelation $fact (index-atom $requirements $i)) true
       (C3FactRelevantToRequirementsAt $fact $requirements (+ $i 1))) false))

(= (C3FactInquiryEntriesAt $facts $requirements $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (and (CPShape $fact fact9-expression 10)
                (C3FactRelevantToRequirementsAt $fact $requirements 0))
         (cons-atom
           (fact9-inquiry-entry (index-atom $fact 1)
             (roles (index-atom $fact 2))
             (material-relations
               (CPRowIds (index-atom (index-atom $fact 4) 2))))
           (C3FactInquiryEntriesAt $facts $requirements (+ $i 1)))
         (C3FactInquiryEntriesAt $facts $requirements (+ $i 1))))
     ()))

(= (C3FlourishingInquiryEntriesAt $organization $values $i)
   (if (< $i (size-atom $values))
     (let* (($value (index-atom $values $i))
            ($rows (CPFlourishingExpressionFor $organization $value)))
       (if (== (size-atom $rows) 1)
         (let $expression (index-atom $rows 0)
           (cons-atom
             (flourishing-inquiry-entry $value
               (current-relational-standings (index-atom $expression 3)))
             (C3FlourishingInquiryEntriesAt $organization $values (+ $i 1))))
         (C3FlourishingInquiryEntriesAt $organization $values (+ $i 1))))
     ()))

(= (C3InquirySurfaceFromOrganizations $facts $flourishing $opening)
   (let* (($requirements (C3OpeningRequiredRelations $opening))
          ($flourishings (C3OpeningRequiredFlourishings $opening)))
     (if (and (> (size-atom $requirements) 0)
              (> (size-atom $flourishings) 0))
       (alignment-inquiry-surface-v1 (index-atom $opening 1)
         (fact9-material
           (C3FactInquiryEntriesAt $facts $requirements 0))
         (flourishing-material
           (C3FlourishingInquiryEntriesAt $flourishing $flourishings 0))
         (rap-partial (index-atom $opening 4) (index-atom $opening 5))
         one-contact-one-movement)
       (alignment-inquiry-surface-unavailable))))

(= (C3InquirySurfaceForOpening $encounter $opening)
   (C3InquirySurfaceFromOrganizations (index-atom $encounter 2)
     (index-atom $encounter 3) $opening))

(= (C3InquirySurfacesForOrganizationsAt $facts $flourishing $openings $i)
   (if (< $i (size-atom $openings))
     (let $surface (C3InquirySurfaceFromOrganizations $facts $flourishing
            (index-atom $openings $i))
       (if (CPShape $surface alignment-inquiry-surface-v1 6)
         (cons-atom $surface
           (C3InquirySurfacesForOrganizationsAt $facts $flourishing $openings
             (+ $i 1)))
         (C3InquirySurfacesForOrganizationsAt $facts $flourishing $openings
           (+ $i 1))))
     ()))

(= (C3InquirySurfacesAt $encounter $openings $i)
   (C3InquirySurfacesForOrganizationsAt (index-atom $encounter 2)
     (index-atom $encounter 3) $openings $i))

(= (C3Fact9InquirySurfacesAt $surfaces $i)
   (if (< $i (size-atom $surfaces))
     (let $surface (index-atom $surfaces $i)
       (cons-atom
         (fact9-inquiry-surface (index-atom $surface 1)
           (index-atom $surface 2))
         (C3Fact9InquirySurfacesAt $surfaces (+ $i 1))))
     ()))

(= (C3FlourishingInquirySurfacesAt $surfaces $i)
   (if (< $i (size-atom $surfaces))
     (let $surface (index-atom $surfaces $i)
       (cons-atom
         (flourishing-inquiry-surface (index-atom $surface 1)
           (index-atom $surface 3))
         (C3FlourishingInquirySurfacesAt $surfaces (+ $i 1))))
     ()))

(= (C3SemanticQuestionFromSurfaces $consequence-id $scope $movement
      $cut $openings $surfaces $returned-material)
   (if (and (CPShape $movement movement-formed 7)
         (and (> (size-atom $openings) 0)
              (== (size-atom $surfaces) (size-atom $openings))))
     (c3-semantic-question-v1
       (question-reference $consequence-id partial-rap-alignment)
       $scope
       (movement-reference (index-atom $movement 2)
         (index-atom $movement 1))
       (source-cut (index-atom $cut 1))
       (partial-openings $openings)
       (fact9-participation
         (C3Fact9InquirySurfacesAt $surfaces 0)
         finite-partial-non-reconstructive)
       (flourishing-participation
         (C3FlourishingInquirySurfacesAt $surfaces 0)
         interconnected-non-compensatory)
       (uncertainty
         relations-that-could-disclose-fuller-alignment-without-overwriting-what-is-aligned
         (returned-contact-material $returned-material))
       (request-contract (C3SemanticQuestionInstructions)
         public-safe-only candidate-possibilities-not-verdict
         no-contact-no-authority-no-choice)
       (resource-request openrouter-glm53
         human-preferred-default-not-cognitive-authority
         semantic-reading 2048 120))
     (c3-semantic-question-unavailable
       no-consequence-earned-partial-opening-or-material-surface)))

(= (C3SemanticQuestionFromConsequence $scope $cut $movement $developmental
      $consequence $facts $flourishing)
   (let* (($family (C3ReorganizationFamily $movement $cut $developmental
            $consequence))
          ($openings (C3OpeningsFromMovement $movement $cut $developmental))
          ($surfaces (C3InquirySurfacesForOrganizationsAt $facts $flourishing
            $openings 0)))
     (if (CPShape $family c3-reorganization-family-v1 8)
       (C3SemanticQuestionFromSurfaces (index-atom $consequence 1) $scope
         $movement $cut $openings $surfaces (C3ConsequenceMaterial $consequence))
       (c3-semantic-question-unavailable
         consequence-does-not-open-partial-alignment-inquiry))))

(= (C3ReturnedMaterialFromEvidence $evidence)
   (if (== (size-atom $evidence) 1)
     (let* (($family (index-atom (index-atom $evidence 0) 1))
            ($lawful (index-atom $family 4))
            ($rows (if (CPShape $lawful lawful-possibilities 2)
              (index-atom $lawful 1) ()))
            ($returned (if (> (size-atom $rows) 0)
              (index-atom (index-atom $rows 0) 4) ())))
       (if (CPShape $returned returned-contact 2)
         (index-atom $returned 1) returned-contact-material-unavailable))
     returned-contact-material-unavailable))

(= (C3SemanticQuestion $encounter)
   (if (CPShape $encounter constitutive-encounter 7)
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($evidence (C3ReturnedEvidenceFromCut $cut))
            ($consequence-ids (C3EvidenceConsequenceIdsAt $evidence 0))
            ($openings (C3OpeningsFromReturnedEvidence $evidence))
            ($surfaces (C3InquirySurfacesAt $encounter $openings 0)))
       (if (and (== (size-atom $consequence-ids) 1)
                (> (size-atom (C3LearnedPossibilities $cut)) 0))
         (C3SemanticQuestionFromSurfaces (index-atom $consequence-ids 0)
           (index-atom $cut 3) $movement $cut $openings $surfaces
           (C3ReturnedMaterialFromEvidence $evidence))
         (c3-semantic-question-unavailable
           no-single-consequence-earned-partial-opening)))
     (c3-semantic-question-unavailable malformed-encounter)))

(= (C3SemanticQuestionValid $question $encounter)
   (and (CPShape $question c3-semantic-question-v1 11)
        (== $question (C3SemanticQuestion $encounter))))

(= (C3SemanticQuestionFromConsequenceValid $question $scope $cut $movement
      $developmental $consequence $facts $flourishing)
   (and (CPShape $question c3-semantic-question-v1 11)
     (== $question (C3SemanticQuestionFromConsequence $scope $cut $movement
       $developmental $consequence $facts $flourishing))))

(= (C3QuestionOpenings $question)
   (if (and (CPShape $question c3-semantic-question-v1 11)
            (CPShape (index-atom $question 5) partial-openings 2))
     (index-atom (index-atom $question 5) 1) ()))

(= (C3CandidateMatchesOpeningAt $candidate $openings $i)
   (if (< $i (size-atom $openings))
     (let $opening (index-atom $openings $i)
       (if (and (CPShape $opening c3-partial-alignment-opening-v2 9)
             (and (CPSetEqual (index-atom (index-atom $candidate 3) 1)
                    (index-atom (index-atom $opening 4) 1))
                  (CPSetEqual (index-atom (index-atom $candidate 4) 1)
                    (index-atom (index-atom $opening 5) 1))))
         true (C3CandidateMatchesOpeningAt $candidate $openings (+ $i 1))))
     false))

(= (C3ModelCandidateValid $candidate $question)
   (and (CPShape $candidate c3-model-candidate-v1 7)
     (and (CPShape (index-atom $candidate 3) preserve 2)
      (and (CPShape (index-atom $candidate 4) explore 2)
       (and (== (index-atom $candidate 6) model-proposal-only)
            (C3CandidateMatchesOpeningAt $candidate
              (C3QuestionOpenings $question) 0))))))

(= (C3ModelCandidatesValidAt $candidates $question $i $ids)
   (if (< $i (size-atom $candidates))
     (let $candidate (index-atom $candidates $i)
       (and (C3ModelCandidateValid $candidate $question)
         (and (== (CPHas (index-atom $candidate 1) $ids 0) false)
              (C3ModelCandidatesValidAt $candidates $question (+ $i 1)
                (cons-atom (index-atom $candidate 1) $ids)))))
     true))

(= (C3ModelObservationValid $observation $question)
   (if (CPShape $observation c3-model-observation-v1 12)
     (let $candidates (index-atom (index-atom $observation 9) 1)
       (and (== (index-atom $observation 1) (index-atom $question 1))
        (and (== (index-atom $observation 2) (index-atom $question 2))
         (and (== (index-atom $observation 3) openrouter-glm53)
          (and (== (index-atom $observation 4) z-ai/glm-5.3)
           (and (== (index-atom $observation 5) (transport eof))
            (and (== (index-atom $observation 6) (http-status 200))
             (and (== (index-atom $observation 7) (finish-reason stop))
              (and (CPShape (index-atom $observation 8) raw-sha256 2)
               (and (CPShape (index-atom $observation 9) candidates 2)
                (and (CPShape (index-atom $observation 10) usage 5)
                 (and (> (size-atom $candidates) 1)
                  (and (< (size-atom $candidates) 4)
                   (and (C3ModelCandidatesValidAt $candidates $question 0 ())
                        (== (index-atom $observation 11)
                          provider-reading-no-contact-no-authority-no-choice)))))))))))))))
     false))

(= (C3ModelObservationUnavailableValid $observation $question)
   (and (CPShape $observation c3-model-observation-unavailable-v1 6)
     (and (== (index-atom $observation 1) (index-atom $question 1))
      (and (== (index-atom $observation 2) (index-atom $question 2))
       (and (== (index-atom $observation 3) openrouter-glm53)
            (== (index-atom $observation 5) no-candidate-admitted))))))

(= (C3ModelParticipantsAt $candidates $question $scope $i)
   (if (< $i (size-atom $candidates))
     (let $candidate (index-atom $candidates $i)
       (cons-atom
         (participant-contribution (index-atom $candidate 1) model $scope
           (lineage openrouter-glm53 z-ai/glm-5.3
             (index-atom $question 1) (index-atom $candidate 1))
           (participant-relation-claim c3-model-alignment-possibility
             unresolved
             (c3-model-reading-v1 (index-atom $question 1) $candidate
               proposal-requires-native-comparison-and-returned-consequence))
           candidate no-contact-no-movement-authority)
         (C3ModelParticipantsAt $candidates $question $scope (+ $i 1))))
     ()))

(= (C3ModelParticipants $observation $question)
   (if (C3ModelObservationValid $observation $question)
     (C3ModelParticipantsAt
       (index-atom (index-atom $observation 9) 1)
       $question (index-atom $question 2) 0)
     ()))

(= (C3ModelClaimsFromRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
             (and (== (index-atom $relation 1)
                    c3-model-alignment-possibility)
                  (== (index-atom $relation 2) unresolved)))
         (index-atom $relation 3)
         (C3ModelClaimsFromRelationsAt $relations (+ $i 1))))
     ()))

(= (C3ModelClaims $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (C3ModelClaimsFromRelationsAt (index-atom $participant-relations 1) 0)
     ()))

(= (C3ModelPossibilitiesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($candidate (if (CPShape $evidence c3-model-reading-v1 4)
              (index-atom $evidence 2) ())))
       (if (and (CPShape $candidate c3-model-candidate-v1 7)
                (== (index-atom $claim 2) model))
         (cons-atom
           ; The proposal receives a complete native R/A/P read but is not
           ; disguised as an available inquiry or undertaking. Its material
           ; relations remain those of the source cut; the unresolved model
           ; claim stays in the participant organization as provenance and
           ; cannot count as support for itself.
           (possible-movement (index-atom $candidate 1) semantic-proposal
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (CPFlourishingValues)
             (consequence-route
               (semantic-candidate-contact (index-atom $evidence 1)
                 (index-atom $candidate 1)) non-certifying)
             l2425-supported)
           (C3ModelPossibilitiesAt $claims $cut (+ $i 1)))
         (C3ModelPossibilitiesAt $claims $cut (+ $i 1))))
     ()))

(= (C3ModelPossibilities $cut $participant-relations)
   (C3ModelPossibilitiesAt (C3ModelClaims $participant-relations) $cut 0))
