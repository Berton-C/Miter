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

; The exact native question is itself retained as one unresolved participant.
; This gives later native formation a single source for the Soul-selected
; Fact9/flourishing surface without copying the complete question into every
; provider candidate. It is not support for alignment and does not create a
; second authority lineage.
(= (C3SemanticQuestionParticipant $question)
   (if (CPShape $question c3-semantic-question-v1 11)
     ((participant-contribution
        (c3-native-semantic-question-participation
          (index-atom (index-atom $question 1) 1))
        native-authority (index-atom $question 2)
        (lineage provisional-26.6-26.9 semantic-question-construction)
        (participant-relation-claim c3-semantic-question-grounding
          unresolved
          (c3-native-semantic-question-basis-v1 $question
            soul-selected-fact9-and-flourishing-surface
            no-provider-relevance-authority))
        candidate no-contact-no-movement-authority))
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

(= (C3SemanticQuestionClaimsFromRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
             (and (== (index-atom $relation 1)
                    c3-semantic-question-grounding)
                  (== (index-atom $relation 2) unresolved)))
         (index-atom $relation 3)
         (C3SemanticQuestionClaimsFromRelationsAt $relations (+ $i 1))))
     ()))

(= (C3SemanticQuestionClaims $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (C3SemanticQuestionClaimsFromRelationsAt
       (index-atom $participant-relations 1) 0)
     ()))

(= (C3SemanticQuestionsFromClaimsAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($question (if
              (CPShape $evidence c3-native-semantic-question-basis-v1 4)
              (index-atom $evidence 1) ())))
       (if (and (== (index-atom $claim 2) native-authority)
                (CPShape $question c3-semantic-question-v1 11))
         (cons-atom $question
           (C3SemanticQuestionsFromClaimsAt $claims (+ $i 1)))
         (C3SemanticQuestionsFromClaimsAt $claims (+ $i 1))))
     ()))

(= (C3SemanticQuestions $participant-relations)
   (C3SemanticQuestionsFromClaimsAt
     (C3SemanticQuestionClaims $participant-relations) 0))

(= (C3ModelClaimsBoundToQuestionAt $claims $question $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($candidate (if (CPShape $evidence c3-model-reading-v1 4)
              (index-atom $evidence 2) ())))
       (and (== (index-atom $claim 2) model)
         (and (CPShape $evidence c3-model-reading-v1 4)
          (and (== (index-atom $evidence 1) (index-atom $question 1))
           (and (C3ModelCandidateValid $candidate $question)
                (C3ModelClaimsBoundToQuestionAt $claims $question
                  (+ $i 1)))))))
     true))

(= (C3ModelInquiryEntriesAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($evidence (index-atom (index-atom $claims $i) 6))
            ($candidate (index-atom $evidence 2)))
       (cons-atom
         (c3-semantic-discrimination-entry-v1
           (index-atom $candidate 1)
           (source-question (index-atom $evidence 1))
           (proposal-summary (index-atom $candidate 2))
           (index-atom $candidate 3)
           (index-atom $candidate 4)
           (counterfactual (index-atom $candidate 5))
           unresolved-provider-proposal
           requires-new-contact-and-native-consequence)
         (C3ModelInquiryEntriesAt $claims (+ $i 1))))
     ()))

(= (C3QuestionFlourishingValuesAt $surfaces $values $i $out)
   (if (< $i (size-atom $values))
     (let $value (index-atom $values $i)
       (if (C3QuestionFlourishingValuePresentAt $surfaces $value 0)
         (C3QuestionFlourishingValuesAt $surfaces $values (+ $i 1)
           (cons-atom $value $out))
         (C3QuestionFlourishingValuesAt $surfaces $values (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (C3QuestionFlourishingValuePresentInEntriesAt $entries $value $i)
   (if (< $i (size-atom $entries))
     (if (and (CPShape (index-atom $entries $i)
                flourishing-inquiry-entry 3)
              (== (index-atom (index-atom $entries $i) 1) $value))
       true
       (C3QuestionFlourishingValuePresentInEntriesAt $entries $value
         (+ $i 1)))
     false))

(= (C3QuestionFlourishingValuePresentAt $surfaces $value $i)
   (if (< $i (size-atom $surfaces))
     (let $surface (index-atom $surfaces $i)
       (if (and (CPShape $surface flourishing-inquiry-surface 3)
             (C3QuestionFlourishingValuePresentInEntriesAt
               (index-atom (index-atom $surface 2) 1) $value 0))
         true
         (C3QuestionFlourishingValuePresentAt $surfaces $value (+ $i 1))))
     false))

(= (C3QuestionFlourishingValues $question)
   (let $participation (index-atom $question 7)
     (if (CPShape $participation flourishing-participation 3)
       (C3QuestionFlourishingValuesAt (index-atom $participation 1)
         (CPFlourishingValues) 0 ())
       ())))

(= (C3QuestionFactIdsFromEntriesAt $entries $i $out)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (and (CPShape $entry fact9-inquiry-entry 4)
                (== (CPHas (index-atom $entry 1) $out 0) false))
         (C3QuestionFactIdsFromEntriesAt $entries (+ $i 1)
           (cons-atom (index-atom $entry 1) $out))
         (C3QuestionFactIdsFromEntriesAt $entries (+ $i 1) $out)))
     $out))

(= (C3QuestionFactIdsFromSurfacesAt $surfaces $i $out)
   (if (< $i (size-atom $surfaces))
     (let $surface (index-atom $surfaces $i)
       (if (CPShape $surface fact9-inquiry-surface 3)
         (C3QuestionFactIdsFromSurfacesAt $surfaces (+ $i 1)
           (C3QuestionFactIdsFromEntriesAt
             (index-atom (index-atom $surface 2) 1) 0 $out))
         (C3QuestionFactIdsFromSurfacesAt $surfaces (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (C3QuestionFactIds $question)
   (let $participation (index-atom $question 6)
     (if (CPShape $participation fact9-participation 3)
       (C3QuestionFactIdsFromSurfacesAt (index-atom $participation 1) 0 ())
       ())))

; Native MeTTa does not pick a fluent proposal. It joins all exact candidates
; into one bounded discriminating inquiry over their differences. The inquiry
; is a new Soul-owned movement possibility; every provider proposal remains
; unresolved until the inquiry returns contact and consequence.
(= (C3SemanticInquirySurface $participant-relations)
   (let* (($questions (C3SemanticQuestions $participant-relations))
          ($claims (C3ModelClaims $participant-relations)))
     (if (and (== (size-atom $questions) 1)
           (and (> (size-atom $claims) 1) (< (size-atom $claims) 4)))
       (let $question (index-atom $questions 0)
         (if (C3ModelClaimsBoundToQuestionAt $claims $question 0)
           (c3-semantic-inquiry-surface-v1
             (index-atom $question 1)
             (index-atom $question 4)
             (selected-fact9-expressions (C3QuestionFactIds $question))
             (selected-flourishings
               (C3QuestionFlourishingValues $question))
             (candidate-contrasts (C3ModelInquiryEntriesAt $claims 0))
             joined-without-provider-selection
             native-contact-and-counterfactual-discrimination-required)
           (c3-semantic-inquiry-surface-unavailable
             candidate-not-bound-to-native-question)))
       (c3-semantic-inquiry-surface-unavailable
         missing-or-ambiguous-question-or-candidates))))

(= (C3SemanticInquiryPossibilities $cut $participant-relations)
   (let $surface (C3SemanticInquirySurface $participant-relations)
     (if (CPShape $surface c3-semantic-inquiry-surface-v1 8)
       ((possible-movement c3-semantic-discrimination-inquiry inquiry
          (CPNativeRequirementRelations $cut)
          (CPNativeRequirementDistinctions $cut)
          (CPNativeRequirementInterfaces $cut)
          (index-atom (index-atom $surface 4) 1)
          (consequence-route
            (soul-formed-semantic-discrimination $surface)
            non-certifying)
          l2425-supported))
       ())))

(= (C3SemanticInquirySurfaceFromMovement $movement)
   (if (and (CPShape $movement movement-formed 7)
         (and (== (index-atom $movement 1) inquiry)
              (== (index-atom $movement 2)
                c3-semantic-discrimination-inquiry)))
     (let* (($answerability (index-atom $movement 5))
            ($o-star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($route (if (CPShape $o-star o-star 2)
              (index-atom $o-star 1) ()))
            ($inquiry (if (CPShape $route consequence-route 3)
              (index-atom $route 1) ()))
            ($surface (if
              (CPShape $inquiry soul-formed-semantic-discrimination 2)
              (index-atom $inquiry 1) ())))
       (if (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
                (== (index-atom $route 2) non-certifying))
         $surface
         (c3-semantic-inquiry-surface-unavailable
           malformed-or-certifying-movement-route)))
     (c3-semantic-inquiry-surface-unavailable
       movement-is-not-semantic-discrimination-inquiry)))

(= (C3SemanticCandidateIdsAt $entries $i)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (CPShape $entry c3-semantic-discrimination-entry-v1 9)
         (cons-atom (index-atom $entry 1)
           (C3SemanticCandidateIdsAt $entries (+ $i 1)))
         (C3SemanticCandidateIdsAt $entries (+ $i 1))))
     ()))

(= (C3SemanticCandidateIds $surface)
   (if (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
            (CPShape (index-atom $surface 5) candidate-contrasts 2))
     (C3SemanticCandidateIdsAt
       (index-atom (index-atom $surface 5) 1) 0)
     ()))

(= (C3SemanticEntryForIdAt $entries $id $i)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (and (CPShape $entry c3-semantic-discrimination-entry-v1 9)
                (== (index-atom $entry 1) $id))
         $entry (C3SemanticEntryForIdAt $entries $id (+ $i 1))))
     (c3-semantic-discrimination-entry-unavailable $id)))

(= (C3SemanticEntryForId $surface $id)
   (if (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
            (CPShape (index-atom $surface 5) candidate-contrasts 2))
     (C3SemanticEntryForIdAt (index-atom (index-atom $surface 5) 1) $id 0)
     (c3-semantic-discrimination-entry-unavailable $id)))

(= (C3SemanticReturnedCandidateRowsAt $relations $candidate-ids $i)
   (if (< $i (size-atom $relations))
     (let $row (index-atom $relations $i)
       (if (and (CPShape $row relation 5)
             (and (CPHas (index-atom $row 1) $candidate-ids 0)
              (and (== (index-atom $row 2) semantic-candidate-contact)
                   (CPHas (index-atom $row 3)
                     (support contradiction unresolved) 0))))
         (cons-atom $row
           (C3SemanticReturnedCandidateRowsAt $relations $candidate-ids
             (+ $i 1)))
         (C3SemanticReturnedCandidateRowsAt $relations $candidate-ids
           (+ $i 1))))
     ()))

(= (C3SemanticReturnedCandidateRows $surface $consequence)
   (if (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
            (CPConsequenceV2Valid $consequence))
     (C3SemanticReturnedCandidateRowsAt
       (index-atom (index-atom $consequence 5) 1)
       (C3SemanticCandidateIds $surface) 0)
     ()))

(= (C3SemanticConsequenceResolution $movement $consequence)
   (let* (($surface (C3SemanticInquirySurfaceFromMovement $movement))
          ($rows (C3SemanticReturnedCandidateRows $surface $consequence)))
     (if (== (size-atom $rows) 1)
       (let* (($row (index-atom $rows 0))
              ($entry (C3SemanticEntryForId $surface (index-atom $row 1))))
         (if (CPShape $entry c3-semantic-discrimination-entry-v1 9)
           (c3-semantic-consequence-resolution-v1
             (index-atom $surface 1) $entry $row
             (returned-consequence (index-atom $consequence 1))
             exact-candidate-contact
             provider-proposal-still-non-certifying)
           (c3-semantic-consequence-resolution-unavailable
             candidate-entry-not-found)))
       (c3-semantic-consequence-resolution-unavailable
         missing-or-ambiguous-candidate-contact))))

; A consequence-earned semantic discrimination becomes durable developmental
; material only as an exact, provisional episode.  It retains the complete
; Soul-selected inquiry surface, all alternatives and their counterfactuals,
; the exact returned row, and the one source/next movement lineage.  It is not
; a truth assertion, a reusable rule, or provider authority.
(= (C3DevelopmentMovementReference $cut $movement)
   (if (CPShape $movement movement-formed 7)
     (movement-reference
       (if (CPShape (index-atom $movement 3) source-cut 2)
         (index-atom (index-atom $movement 3) 1)
         (index-atom $cut 1))
       formed
       (index-atom $movement 1) (index-atom $movement 2))
     (if (CPShape $movement movement-plural-live 4)
       (movement-reference (index-atom $cut 1) plural-live
         (size-atom (index-atom (index-atom $movement 2) 1)) unresolved)
       (movement-reference (index-atom $cut 1) unresolved
         (index-atom $movement 1) unresolved))))

; Recover the exact native semantic question from the source movement's
; continuation basis.  The question is not reconstructed from provider text:
; it is the original Soul-formed participant retained by the one constitutive
; encounter that formed the semantic inquiry.
(= (C3SemanticQuestionFromMovement $cut $movement)
   (if (CPShape $movement movement-formed 7)
     (let $retained (index-atom $movement 6)
       (if (CPShape $retained retained-alternatives-v3 3)
         (let $basis (index-atom $retained 2)
           (if (CPShape $basis continuation-basis-v3 6)
             (let* (($participant-source (index-atom $basis 3))
                    ($participants (participant-reentry-organization
                      differentiated-by-source-scope-and-lineage
                      (CPParticipantAt $cut $participant-source 0)
                      repeated-same-lineage-is-not-independent-support))
                    ($relations
                      (CPParticipantRelationOrganization $participants))
                    ($questions (C3SemanticQuestions $relations)))
               (if (== (size-atom $questions) 1)
                 (index-atom $questions 0)
                 (c3-semantic-question-unavailable
                   missing-or-ambiguous-source-question)))
             (c3-semantic-question-unavailable
               source-movement-has-no-v3-basis)))
         (c3-semantic-question-unavailable
           source-movement-has-no-retained-v3-alternatives)))
     (c3-semantic-question-unavailable source-movement-not-formed)))

(= (C3SemanticResolutionMatchesSurface $resolution $surface)
   (if (and (CPShape $resolution c3-semantic-consequence-resolution-v1 7)
            (CPShape $surface c3-semantic-inquiry-surface-v1 8))
     (let* (($entry (index-atom $resolution 2))
            ($row (index-atom $resolution 3))
            ($candidate-id (if
              (CPShape $entry c3-semantic-discrimination-entry-v1 9)
              (index-atom $entry 1) no-candidate-id)))
       (==
         ((== (index-atom $resolution 1) (index-atom $surface 1))
          (== $entry (C3SemanticEntryForId $surface $candidate-id))
          (CPShape $row relation 5)
          (== (index-atom $row 1) $candidate-id)
          (== (index-atom $row 2) semantic-candidate-contact)
          (CPHas (index-atom $row 3) (support contradiction unresolved) 0)
          (CPShape (index-atom $resolution 4) returned-consequence 2)
          (== (index-atom $resolution 5) exact-candidate-contact)
          (== (index-atom $resolution 6)
            provider-proposal-still-non-certifying))
         (true true true true true true true true true)))
     false))

(= (C3SemanticDevelopmentRecord $scope $cut $movement $next-cut
      $next-movement $consequence)
   (let* (($surface (C3SemanticInquirySurfaceFromMovement $movement))
          ($question (C3SemanticQuestionFromMovement $cut $movement))
          ($resolution (C3SemanticConsequenceResolution $movement
            $consequence)))
     (if (and (CPShape $scope scope 4)
           (and (CPShape $question c3-semantic-question-v1 11)
            (and (== (index-atom $question 1) (index-atom $surface 1))
             (and (C3SemanticResolutionMatchesSurface $resolution $surface)
                  (== (index-atom (index-atom $resolution 4) 1)
                    (index-atom $consequence 1))))))
       (c3-semantic-development-v1
         (development-reference (index-atom $consequence 1))
         $scope
         (C3DevelopmentMovementReference $cut $movement)
         $surface
         $question
         $resolution
         (C3DevelopmentMovementReference $next-cut $next-movement)
         (epistemic-standing consequence-earned-discrimination provisional)
         (authority-boundary
           no-provider-choice no-repetition-authority no-genome-mutation
           later-use-requires-new-native-comparison-and-consequence))
       (c3-semantic-development-unavailable
         (index-atom $consequence 1) no-exact-semantic-discrimination))))

(= (C3SemanticDevelopmentRecordValid $record)
   (if (CPShape $record c3-semantic-development-v1 10)
     (let* (($reference (index-atom $record 1))
            ($scope (index-atom $record 2))
            ($source (index-atom $record 3))
            ($surface (index-atom $record 4))
            ($question (index-atom $record 5))
            ($resolution (index-atom $record 6))
            ($next (index-atom $record 7)))
       (==
         ((CPShape $reference development-reference 2)
          (CPShape $scope scope 4)
          (CPShape $source movement-reference 5)
          (CPShape $next movement-reference 5)
          (CPShape $question c3-semantic-question-v1 11)
          (== (index-atom $question 1) (index-atom $surface 1))
          (== (index-atom $question 4) (index-atom $surface 2))
          (CPSetEqual (C3QuestionFactIds $question)
            (index-atom (index-atom $surface 3) 1))
          (CPSetEqual (C3QuestionFlourishingValues $question)
            (index-atom (index-atom $surface 4) 1))
          (C3SemanticResolutionMatchesSurface $resolution $surface)
          (== (index-atom $reference 1)
            (index-atom (index-atom $resolution 4) 1))
          (== (index-atom $source 1)
            (next-cut
              (index-atom (index-atom $question 4) 1)
              (index-atom (index-atom $question 1) 1)))
          (== (index-atom $source 2) formed)
          (== (index-atom $source 3) inquiry)
          (== (index-atom $source 4) c3-semantic-discrimination-inquiry)
          (== (index-atom $record 8)
            (epistemic-standing consequence-earned-discrimination provisional))
          (== (index-atom $record 9)
            (authority-boundary
              no-provider-choice no-repetition-authority no-genome-mutation
              later-use-requires-new-native-comparison-and-consequence)))
         (true true true true true true true true true true true true true true
           true true true)))
     false))

(= (C3SemanticDevelopmentParticipant $scope $record)
   (if (and (C3SemanticDevelopmentRecordValid $record)
            (== (index-atom $record 2) $scope))
     (participant-contribution
       (c3-semantic-development-memory-participation
         (index-atom (index-atom $record 1) 1))
       developmental-memory $scope
       (lineage consequence-earned-semantic-development
         (index-atom (index-atom $record 1) 1))
       (participant-relation-claim c3-semantic-development-memory
         unresolved
         (c3-semantic-development-memory-evidence-v1 $record
           candidate-for-new-contact-comparison-not-support))
       candidate no-contact-no-movement-authority)
     (participant-unresolved semantic-development-memory
       malformed-or-scope-mismatched)))

(= (C3SemanticDevelopmentClaimsFromRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
             (and (== (index-atom $relation 1)
                    c3-semantic-development-memory)
                  (== (index-atom $relation 2) unresolved)))
         (index-atom $relation 3)
         (C3SemanticDevelopmentClaimsFromRelationsAt $relations (+ $i 1))))
     ()))

(= (C3SemanticDevelopmentClaims $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (C3SemanticDevelopmentClaimsFromRelationsAt
       (index-atom $participant-relations 1) 0)
     ()))

(= (C3SemanticDevelopmentRecordFromClaim $claim)
   (if (CPShape $claim participant-relation-evidence 7)
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence c3-semantic-development-memory-evidence-v1 3)
         (index-atom $evidence 1)
         (c3-semantic-development-unavailable claim-has-no-record)))
     (c3-semantic-development-unavailable malformed-claim)))

(= (C3FactRolesPresentAt $facts $roles $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (and (CPShape $fact fact9-expression 10)
             (and (CPSetEqual (index-atom $fact 2) $roles)
                  (== (index-atom (index-atom $fact 6) 2)
                    recognized-compose)))
         true (C3FactRolesPresentAt $facts $roles (+ $i 1))))
     false))

(= (C3QuestionFactEntriesApplicableAt $entries $facts $i)
   (if (< $i (size-atom $entries))
     (let* (($entry (index-atom $entries $i))
            ($roles (if (and (CPShape $entry fact9-inquiry-entry 4)
                             (CPShape (index-atom $entry 2) roles 2))
              (index-atom (index-atom $entry 2) 1) ())))
       (and (> (size-atom $roles) 0)
            (and (C3FactRolesPresentAt $facts $roles 0)
                 (C3QuestionFactEntriesApplicableAt $entries $facts
                   (+ $i 1)))))
     true))

(= (C3QuestionFactSurfacesApplicableAt $surfaces $facts $i)
   (if (< $i (size-atom $surfaces))
     (let* (($surface (index-atom $surfaces $i))
            ($entries (if (and (CPShape $surface fact9-inquiry-surface 3)
                               (CPShape (index-atom $surface 2)
                                 fact9-material 2))
              (index-atom (index-atom $surface 2) 1) ())))
       (and (> (size-atom $entries) 0)
            (and (C3QuestionFactEntriesApplicableAt $entries $facts 0)
                 (C3QuestionFactSurfacesApplicableAt $surfaces $facts
                   (+ $i 1)))))
     true))

(= (C3QuestionFactParticipationApplicable $question $facts)
   (let $participation (index-atom $question 6)
     (if (CPShape $participation fact9-participation 3)
       (let $surfaces (index-atom $participation 1)
         (and (> (size-atom $surfaces) 0)
              (C3QuestionFactSurfacesApplicableAt $surfaces $facts 0)))
       false)))

(= (C3FlourishingRowsMaterialAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (CPShape $row flourishing-standing 4)
             (and (!= (index-atom $row 1) no-material-relation)
                  (!= (index-atom $row 2) unknown)))
         true (C3FlourishingRowsMaterialAt $rows (+ $i 1))))
     false))

(= (C3FlourishingMaterialPresent $organization $value)
   (let $expressions (CPFlourishingExpressionFor $organization $value)
     (if (== (size-atom $expressions) 1)
       (let $expression (index-atom $expressions 0)
         (and (CPShape $expression flourishing-expression 4)
              (C3FlourishingRowsMaterialAt (index-atom $expression 3) 0)))
       false)))

(= (C3AllFlourishingMaterialPresentAt $organization $values $i)
   (if (< $i (size-atom $values))
     (and (C3FlourishingMaterialPresent $organization
            (index-atom $values $i))
          (C3AllFlourishingMaterialPresentAt $organization $values
            (+ $i 1)))
     true))

; Applicability is structural and conservative: a different contact cut must
; expose recognized Fact9 expressions over every exact role-set and material
; participation by every flourishing selected by the source Soul inquiry.
; Fact/view and relation identifiers may differ, allowing a previously unseen
; composition to become comparable without a new behavioral branch. No words,
; model confidence, repetition count, or preferred answer are consulted.
; Passing this test only permits a new inquiry.
(= (C3SemanticDevelopmentApplicable $record $cut $facts $flourishing)
   (if (C3SemanticDevelopmentRecordValid $record)
     (let* (($surface (index-atom $record 4))
            ($question (index-atom $record 5))
            ($source-cut (index-atom (index-atom $surface 2) 1))
            ($values (C3QuestionFlourishingValues $question)))
       (and (!= (index-atom $cut 1) $source-cut)
        (and (> (size-atom $values) 0)
          (and (C3QuestionFactParticipationApplicable $question $facts)
               (C3AllFlourishingMaterialPresentAt $flourishing $values 0)))))
     false))

(= (C3SemanticDevelopmentTransferRoute $record $cut)
   (let* (($surface (index-atom $record 4))
          ($question (index-atom $record 5))
          ($resolution (index-atom $record 6))
          ($entry (index-atom $resolution 2)))
     (discriminating-developmental-transfer-v2
       (index-atom $record 1)
       (source-cut (index-atom (index-atom $surface 2) 1))
       (target-cut (index-atom $cut 1))
       (source-candidate $entry)
       (source-rap-opening (index-atom $entry 4) (index-atom $entry 5))
       (source-partial-openings (C3QuestionOpenings $question))
       (source-fact9-participation (index-atom $question 6))
       (source-flourishing-participation (index-atom $question 7))
       (index-atom $surface 3)
       (index-atom $surface 4)
       (counterfactual-retained (index-atom $entry 6))
       provisional-transfer-requires-returned-contact)))

(= (C3SemanticDevelopmentTransferPossibilitiesAt $claims $cut $facts
      $flourishing $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($record (C3SemanticDevelopmentRecordFromClaim $claim)))
       (if (and (== (index-atom $claim 2) developmental-memory)
                (C3SemanticDevelopmentApplicable $record $cut $facts
                  $flourishing))
         (cons-atom
           (possible-movement
             (index-atom (index-atom $record 1) 1)
             inquiry
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (index-atom (index-atom (index-atom $record 4) 4) 1)
             (consequence-route
               (C3SemanticDevelopmentTransferRoute $record $cut)
               non-certifying)
             l2425-supported)
           (C3SemanticDevelopmentTransferPossibilitiesAt $claims $cut $facts
             $flourishing (+ $i 1)))
         (C3SemanticDevelopmentTransferPossibilitiesAt $claims $cut $facts
           $flourishing (+ $i 1))))
     ()))

(= (C3SemanticDevelopmentTransferPossibilities $cut $facts $flourishing
      $participant-relations)
   (C3SemanticDevelopmentTransferPossibilitiesAt
     (C3SemanticDevelopmentClaims $participant-relations)
     $cut $facts $flourishing 0))

(= (C3TransferEntryMatchesOpeningAt $entry $openings $i)
   (if (< $i (size-atom $openings))
     (let $opening (index-atom $openings $i)
       (if (and (CPShape $opening c3-partial-alignment-opening-v2 9)
             (and (CPSetEqual (index-atom (index-atom $entry 4) 1)
                    (index-atom (index-atom $opening 4) 1))
                  (CPSetEqual (index-atom (index-atom $entry 5) 1)
                    (index-atom (index-atom $opening 5) 1))))
         true (C3TransferEntryMatchesOpeningAt $entry $openings (+ $i 1))))
     false))

(= (C3FlourishingIdsFromEntriesAt $entries $i $out)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (and (CPShape $entry flourishing-inquiry-entry 3)
                (== (CPHas (index-atom $entry 1) $out 0) false))
         (C3FlourishingIdsFromEntriesAt $entries (+ $i 1)
           (cons-atom (index-atom $entry 1) $out))
         (C3FlourishingIdsFromEntriesAt $entries (+ $i 1) $out)))
     $out))

(= (C3FlourishingIdsFromSurfacesAt $surfaces $i $out)
   (if (< $i (size-atom $surfaces))
     (let $surface (index-atom $surfaces $i)
       (if (CPShape $surface flourishing-inquiry-surface 3)
         (C3FlourishingIdsFromSurfacesAt $surfaces (+ $i 1)
           (C3FlourishingIdsFromEntriesAt
             (index-atom (index-atom $surface 2) 1) 0 $out))
         (C3FlourishingIdsFromSurfacesAt $surfaces (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (C3DevelopmentalTransferRouteValid $route)
   (if (CPShape $route discriminating-developmental-transfer-v2 13)
     (let* (($entry (index-atom (index-atom $route 4) 1))
            ($openings (index-atom (index-atom $route 6) 1))
            ($fact-participation (index-atom (index-atom $route 7) 1))
            ($flourishing-participation
              (index-atom (index-atom $route 8) 1))
            ($fact-surfaces (if
              (CPShape $fact-participation fact9-participation 3)
              (index-atom $fact-participation 1) ()))
            ($flourishing-surfaces (if
              (CPShape $flourishing-participation flourishing-participation 3)
              (index-atom $flourishing-participation 1) ()))
            ($fact-ids (C3QuestionFactIdsFromSurfacesAt $fact-surfaces 0 ()))
            ($flourishing-values (C3FlourishingIdsFromSurfacesAt
              $flourishing-surfaces 0 ())))
       (==
         ((CPShape (index-atom $route 1) development-reference 2)
          (CPShape (index-atom $route 2) source-cut 2)
          (CPShape (index-atom $route 3) target-cut 2)
          (CPShape (index-atom $route 4) source-candidate 2)
          (CPShape $entry c3-semantic-discrimination-entry-v1 9)
          (CPShape (index-atom $route 5) source-rap-opening 3)
          (== (index-atom $route 5)
            (source-rap-opening (index-atom $entry 4)
              (index-atom $entry 5)))
          (CPShape (index-atom $route 6) source-partial-openings 2)
          (> (size-atom $openings) 0)
          (C3TransferEntryMatchesOpeningAt $entry $openings 0)
          (CPShape (index-atom $route 7) source-fact9-participation 2)
          (CPShape $fact-participation fact9-participation 3)
          (> (size-atom $fact-surfaces) 0)
          (CPShape (index-atom $route 8)
            source-flourishing-participation 2)
          (CPShape $flourishing-participation flourishing-participation 3)
          (> (size-atom $flourishing-surfaces) 0)
          (CPShape (index-atom $route 9) selected-fact9-expressions 2)
          (CPSetEqual (index-atom (index-atom $route 9) 1) $fact-ids)
          (CPShape (index-atom $route 10) selected-flourishings 2)
          (CPSetEqual (index-atom (index-atom $route 10) 1)
            $flourishing-values)
          (CPShape (index-atom $route 11) counterfactual-retained 2)
          (== (index-atom $route 11)
            (counterfactual-retained (index-atom $entry 6)))
         (== (index-atom $route 12)
            provisional-transfer-requires-returned-contact))
         (true true true true true true true true true true true true true true
           true true true true true true true true true)))
     false))

(= (C3DevelopmentalTransferRouteFromMovement $movement)
   (if (and (CPShape $movement movement-formed 7)
            (== (index-atom $movement 1) inquiry))
     (let* (($answerability (index-atom $movement 5))
            ($o-star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($route-wrapper (if (CPShape $o-star o-star 2)
              (index-atom $o-star 1) ()))
            ($route (if (CPShape $route-wrapper consequence-route 3)
              (index-atom $route-wrapper 1) ())))
       (if (and (C3DevelopmentalTransferRouteValid $route)
             (and (== (index-atom $route-wrapper 2) non-certifying)
                  (== (index-atom $movement 2)
                    (index-atom (index-atom $route 1) 1))))
         $route
         (c3-developmental-transfer-route-unavailable
           malformed-or-movement-id-mismatched)))
     (c3-developmental-transfer-route-unavailable
       movement-is-not-formed-inquiry)))

(= (C3DevelopmentalTransferRowsAt $relations $development-id $i)
   (if (< $i (size-atom $relations))
     (let $row (index-atom $relations $i)
       (if (and (CPShape $row relation 5)
             (and (== (index-atom $row 1) $development-id)
              (and (== (index-atom $row 2) developmental-transfer-contact)
                   (CPHas (index-atom $row 3)
                     (support contradiction unresolved) 0))))
         (cons-atom $row
           (C3DevelopmentalTransferRowsAt $relations $development-id
             (+ $i 1)))
         (C3DevelopmentalTransferRowsAt $relations $development-id
           (+ $i 1))))
     ()))

(= (C3DevelopmentalTransferResolution $movement $consequence)
   (let* (($route (C3DevelopmentalTransferRouteFromMovement $movement))
          ($development-id (if (C3DevelopmentalTransferRouteValid $route)
            (index-atom (index-atom $route 1) 1) no-development-id))
          ($rows (if (CPConsequenceV2Valid $consequence)
            (C3DevelopmentalTransferRowsAt
              (index-atom (index-atom $consequence 5) 1)
              $development-id 0) ())))
     (if (and (C3DevelopmentalTransferRouteValid $route)
           (and (CPConsequenceV2Valid $consequence)
            (and (== (index-atom $movement 2) (index-atom $consequence 2))
                 (== (size-atom $rows) 1))))
       (c3-developmental-transfer-resolution-v1
         $route (index-atom $rows 0)
         (returned-consequence (index-atom $consequence 1))
         exact-transfer-contact
         source-provider-remains-non-certifying)
       (c3-developmental-transfer-resolution-unavailable
         missing-ambiguous-or-movement-mismatched-contact))))

(= (C3DevelopmentalTransferResolutionValid $resolution)
   (if (CPShape $resolution c3-developmental-transfer-resolution-v1 6)
     (let* (($route (index-atom $resolution 1))
            ($row (index-atom $resolution 2))
            ($development-id (if
              (C3DevelopmentalTransferRouteValid $route)
              (index-atom (index-atom $route 1) 1) no-development-id)))
       (==
         ((C3DevelopmentalTransferRouteValid $route)
          (CPShape $row relation 5)
          (== (index-atom $row 1) $development-id)
          (== (index-atom $row 2) developmental-transfer-contact)
          (CPHas (index-atom $row 3)
            (support contradiction unresolved) 0)
          (CPShape (index-atom $resolution 3) returned-consequence 2)
          (== (index-atom $resolution 4) exact-transfer-contact)
          (== (index-atom $resolution 5)
            source-provider-remains-non-certifying))
         (true true true true true true true true)))
     false))

(= (C3DevelopmentalTransferStanding $resolution)
   (let $standing (index-atom (index-atom $resolution 2) 3)
     (if (== $standing support) support
       (if (== $standing contradiction) contradiction unresolved))))

(= (C3DevelopmentalTransferParticipantStanding $resolution)
   (let $standing (C3DevelopmentalTransferStanding $resolution)
     (if (== $standing support) supported
       (if (== $standing contradiction) contradicted candidate))))

(= (C3DevelopmentalTransferRelationId $resolution)
   (c3-developmental-transfer-result
     (index-atom (index-atom $resolution 3) 1)))

; Native interpretation and returned contact remain independently attributable.
; Their joined relation is support only when the returned row supports this
; exact transfer inquiry. Contradiction and unresolved standing remain live
; but cannot be promoted by provider fluency or repetition.
(= (C3DevelopmentalTransferConsequenceParticipants $scope $movement
      $consequence)
   (let $resolution (C3DevelopmentalTransferResolution $movement $consequence)
     (if (C3DevelopmentalTransferResolutionValid $resolution)
       (let* (($id (index-atom $consequence 1))
              ($target (C3DevelopmentalTransferRelationId $resolution))
              ($standing (C3DevelopmentalTransferStanding $resolution))
              ($participant-standing
                (C3DevelopmentalTransferParticipantStanding $resolution)))
         ((participant-contribution
            (c3-native-developmental-transfer-participation $id)
            native-authority $scope
            (lineage provisional-26.6-26.9 developmental-transfer)
            (participant-relation-claim $target $standing
              (c3-native-developmental-transfer-basis-v1 $resolution
                one-contact-one-movement-three-perspectives
                no-provider-self-certification))
            $participant-standing no-contact-no-movement-authority)
          (participant-contribution
            (c3-returned-developmental-transfer-participation $id)
            returned-contact $scope
            (lineage returned-consequence $id)
            (participant-relation-claim $target $standing
              (c3-returned-developmental-transfer-evidence-v1 $resolution
                (index-atom $consequence 12)))
            $participant-standing no-contact-no-movement-authority)))
       ())))

(= (C3SemanticResolutionClaimStanding $resolution)
   (let $standing (index-atom (index-atom $resolution 3) 3)
     (if (== $standing support) support
       (if (== $standing contradiction) contradiction unresolved))))

(= (C3SemanticResolutionParticipantStanding $resolution)
   (let $standing (C3SemanticResolutionClaimStanding $resolution)
     (if (== $standing support) supported
       (if (== $standing contradiction) contradicted candidate))))

; Returned contact and native interpretation are distinct lineages. Together
; they can establish a consequence-bearing semantic discrimination, but only
; for the exact candidate named by the movement's retained inquiry surface.
(= (C3SemanticConsequenceParticipants $scope $movement $consequence)
   (let $resolution (C3SemanticConsequenceResolution $movement $consequence)
     (if (CPShape $resolution c3-semantic-consequence-resolution-v1 7)
       ((participant-contribution
          (c3-native-semantic-consequence-participation
            (index-atom $consequence 1))
          native-authority $scope
          (lineage provisional-26.6-26.9 semantic-consequence-interpretation)
          (participant-relation-claim c3-semantic-discrimination-result
            (C3SemanticResolutionClaimStanding $resolution)
            (c3-native-semantic-consequence-basis-v1 $resolution
              candidate-difference-preserved
              no-provider-self-certification))
          (C3SemanticResolutionParticipantStanding $resolution)
          no-contact-no-movement-authority)
        (participant-contribution
          (c3-returned-semantic-consequence-participation
            (index-atom $consequence 1))
          returned-contact $scope
          (lineage returned-consequence (index-atom $consequence 1))
          (participant-relation-claim c3-semantic-discrimination-result
            (C3SemanticResolutionClaimStanding $resolution)
            (c3-returned-semantic-consequence-evidence-v1 $resolution
              (index-atom $consequence 12)))
          (C3SemanticResolutionParticipantStanding $resolution)
          no-contact-no-movement-authority))
       ())))

(= (C3SemanticParticipantForSurface $participant $surface)
   (let* (($candidate-ids (C3SemanticCandidateIds $surface))
          ($question-ref (index-atom $surface 1))
          ($question-id (if (CPShape $question-ref question-reference 3)
            (index-atom $question-ref 1) no-question-id))
          ($id (if (CPShape $participant participant-contribution 8)
            (index-atom $participant 1) malformed-participant))
          ($source (if (CPShape $participant participant-contribution 8)
            (index-atom $participant 2) malformed-source)))
     (or (and (== $source model) (CPHas $id $candidate-ids 0))
       (== $id (c3-native-semantic-question-participation $question-id)))))

(= (C3ParticipantsWithoutSemanticSurfaceAt $participants $surface $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (C3SemanticParticipantForSurface $participant $surface)
         (C3ParticipantsWithoutSemanticSurfaceAt $participants $surface
           (+ $i 1))
         (cons-atom $participant
           (C3ParticipantsWithoutSemanticSurfaceAt $participants $surface
             (+ $i 1)))))
     ()))

; A successfully contacted semantic inquiry retires only its exact unresolved
; proposal set from the active cut. The participants remain in append-only
; model history; their consequence-bearing resolution replaces them in the
; next live organization. Missing or ambiguous contact retires nothing.
(= (C3DevelopmentalMemoryParticipantForResolution $participant $resolution)
   (let* (($route (index-atom $resolution 1))
          ($development-id (index-atom (index-atom $route 1) 1))
          ($id (if (CPShape $participant participant-contribution 8)
            (index-atom $participant 1) malformed-participant)))
     (== $id
       (c3-semantic-development-memory-participation $development-id))))

(= (C3ParticipantsWithoutDevelopmentalTransferAt $participants $resolution
      $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (C3DevelopmentalMemoryParticipantForResolution $participant
             $resolution)
         (C3ParticipantsWithoutDevelopmentalTransferAt $participants
           $resolution (+ $i 1))
         (cons-atom $participant
           (C3ParticipantsWithoutDevelopmentalTransferAt $participants
             $resolution (+ $i 1)))))
     ()))

; Resolved model candidates and the exact developmental memory being tested
; leave the active participant set only after matching returned contact. Their
; append-only history remains intact and may participate in a later new contact.
(= (C3ParticipantsAfterSemanticConsequence $participants $movement
      $consequence)
   (let* (($surface (C3SemanticInquirySurfaceFromMovement $movement))
          ($semantic-resolution (C3SemanticConsequenceResolution $movement
            $consequence))
          ($without-semantic (if
            (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
                 (CPShape $semantic-resolution
                   c3-semantic-consequence-resolution-v1 7))
            (C3ParticipantsWithoutSemanticSurfaceAt $participants $surface 0)
            $participants))
          ($transfer-resolution
            (C3DevelopmentalTransferResolution $movement $consequence)))
     (if (C3DevelopmentalTransferResolutionValid $transfer-resolution)
       (C3ParticipantsWithoutDevelopmentalTransferAt $without-semantic
         $transfer-resolution 0)
       $without-semantic)))

(= (C3DevelopmentalTransferResolutionFromClaim $claim)
   (if (CPShape $claim participant-relation-evidence 7)
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence c3-native-developmental-transfer-basis-v1 4)
         (index-atom $evidence 1)
         (if (CPShape $evidence
               c3-returned-developmental-transfer-evidence-v1 3)
           (index-atom $evidence 1)
           (c3-developmental-transfer-resolution-unavailable
             claim-has-no-transfer-resolution))))
     (c3-developmental-transfer-resolution-unavailable malformed-claim)))

(= (C3TransferClaimsSameResolutionAt $claims $resolution $i)
   (if (< $i (size-atom $claims))
     (and (== (C3DevelopmentalTransferResolutionFromClaim
                (index-atom $claims $i)) $resolution)
          (C3TransferClaimsSameResolutionAt $claims $resolution (+ $i 1)))
     true))

(= (C3TransferClaimsHaveSourceAt $claims $source $i)
   (if (< $i (size-atom $claims))
     (if (== (index-atom (index-atom $claims $i) 2) $source)
       true (C3TransferClaimsHaveSourceAt $claims $source (+ $i 1)))
     false))

(= (C3DevelopmentalTransferResultRelationValid $relation)
   (if (CPShape $relation participant-supported-relation 4)
     (let $target (index-atom $relation 1)
       ; Most supported relations in the shared organization are not C3
       ; transfer results. Discriminate the target before inspecting their
       ; differently typed evidence so unrelated authorities remain total.
       (if (CPShape $target c3-developmental-transfer-result 2)
         (let* (($claims (index-atom $relation 3))
                ($resolution (if (> (size-atom $claims) 0)
                  (C3DevelopmentalTransferResolutionFromClaim
                    (index-atom $claims 0))
                  (c3-developmental-transfer-resolution-unavailable
                    no-claims))))
           (and (== (size-atom $claims) 2)
            (and (C3DevelopmentalTransferResolutionValid $resolution)
             (and (== (index-atom $target 1)
                    (index-atom (index-atom $resolution 3) 1))
              (and (C3TransferClaimsSameResolutionAt $claims $resolution 0)
               (and (C3TransferClaimsHaveSourceAt $claims native-authority 0)
                    (C3TransferClaimsHaveSourceAt $claims returned-contact
                      0)))))))
         false))
     false))

(= (C3DevelopmentalTransferResultPossibilitiesAt $relations $cut $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (C3DevelopmentalTransferResultRelationValid $relation)
         (let* (($target (index-atom $relation 1))
                ($claims (index-atom $relation 3))
                ($resolution (C3DevelopmentalTransferResolutionFromClaim
                  (index-atom $claims 0)))
                ($route (index-atom $resolution 1))
                ($base-relations (CPNativeRequirementRelations $cut))
                ($required-relations (if
                  (CPHas $target $base-relations 0) $base-relations
                  (cons-atom $target $base-relations))))
           (cons-atom
             (possible-movement (index-atom $target 1) undertaking
               $required-relations
               (CPNativeRequirementDistinctions $cut)
               (CPNativeRequirementInterfaces $cut)
               (index-atom (index-atom $route 10) 1)
               (consequence-route
                 (consequence-earned-developmental-transfer $resolution)
                 non-certifying)
               l2425-supported)
             (C3DevelopmentalTransferResultPossibilitiesAt $relations $cut
               (+ $i 1))))
         (C3DevelopmentalTransferResultPossibilitiesAt $relations $cut
           (+ $i 1))))
     ()))

(= (C3DevelopmentalTransferResultPossibilities $cut $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (C3DevelopmentalTransferResultPossibilitiesAt
       (index-atom $participant-relations 1) $cut 0)
     ()))

; A returned developmental-transfer consequence is a new episode in its own
; right. It is not another semantic-provider reading and must not be squeezed
; into that older record type. The exact Soul-selected Fact9/flourishing/RAP
; surface remains embedded in the resolution route, while returned contact
; determines the standing carried forward.
(= (C3DevelopmentalTransferRecord $scope $cut $movement $next-cut
      $next-movement $consequence)
   (let $resolution (C3DevelopmentalTransferResolution $movement $consequence)
     (if (C3DevelopmentalTransferResolutionValid $resolution)
       (let* (($standing (C3DevelopmentalTransferStanding $resolution))
              ($participant-standing
                (C3DevelopmentalTransferParticipantStanding $resolution)))
         (c3-developmental-transfer-development-v1
           (transfer-development-reference (index-atom $consequence 1))
           $scope
           (C3DevelopmentMovementReference $cut $movement)
           $resolution
           (C3DevelopmentMovementReference $next-cut $next-movement)
           (epistemic-standing consequence-earned-developmental-transfer
             $standing $participant-standing provisional)
           (authority-boundary
             soul-selected-fact9-flourishing-rap-surface
             returned-contact-determines-standing
             provider-remains-non-certifying
             no-repetition-authority no-genome-mutation)))
       (c3-developmental-transfer-development-unavailable
         (index-atom $consequence 1) no-exact-developmental-transfer))))

(= (C3DevelopmentalTransferRecordValid $record)
   (if (CPShape $record c3-developmental-transfer-development-v1 8)
     (let* (($reference (index-atom $record 1))
            ($scope (index-atom $record 2))
            ($source (index-atom $record 3))
            ($resolution (index-atom $record 4))
            ($next (index-atom $record 5))
            ($route (if
              (C3DevelopmentalTransferResolutionValid $resolution)
              (index-atom $resolution 1)
              (c3-developmental-transfer-route-unavailable
                invalid-resolution)))
            ($standing (if
              (C3DevelopmentalTransferResolutionValid $resolution)
              (C3DevelopmentalTransferStanding $resolution) unresolved))
            ($participant-standing (if
              (C3DevelopmentalTransferResolutionValid $resolution)
              (C3DevelopmentalTransferParticipantStanding $resolution)
              candidate)))
       (==
         ((CPShape $reference transfer-development-reference 2)
          (CPShape $scope scope 4)
          (CPShape $source movement-reference 5)
          (CPShape $next movement-reference 5)
          (C3DevelopmentalTransferResolutionValid $resolution)
          (== (index-atom $reference 1)
            (index-atom (index-atom $resolution 3) 1))
          (== (index-atom $source 1)
            (index-atom (index-atom $route 3) 1))
          (== (index-atom $source 2) formed)
          (== (index-atom $source 3) inquiry)
          (== (index-atom $source 4)
            (index-atom (index-atom $route 1) 1))
          (== (index-atom $record 6)
            (epistemic-standing consequence-earned-developmental-transfer
              $standing $participant-standing provisional))
          (== (index-atom $record 7)
            (authority-boundary
              soul-selected-fact9-flourishing-rap-surface
              returned-contact-determines-standing
              provider-remains-non-certifying
              no-repetition-authority no-genome-mutation)))
         (true true true true true true true true true true true true)))
     false))

(= (C3DevelopmentalTransferMemoryParticipant $scope $record)
   (if (and (C3DevelopmentalTransferRecordValid $record)
            (== (index-atom $record 2) $scope))
     (let* (($reference (index-atom $record 1))
            ($resolution (index-atom $record 4))
            ($standing (C3DevelopmentalTransferStanding $resolution))
            ($participant-standing
              (C3DevelopmentalTransferParticipantStanding $resolution)))
       (participant-contribution
         (c3-developmental-transfer-memory-participation
           (index-atom $reference 1))
         developmental-memory $scope
         (lineage consequence-earned-developmental-transfer
           (index-atom $reference 1))
         (participant-relation-claim
           (c3-developmental-transfer-memory (index-atom $reference 1))
           $standing
           (c3-developmental-transfer-memory-evidence-v1 $record))
         $participant-standing no-contact-no-movement-authority))
     (c3-developmental-transfer-memory-participation-unavailable)))

(= (C3TransferDevelopmentClaimsFromRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (or (CPShape $relation participant-proposed-relation 4)
               (CPShape $relation participant-proposed-relation 5))
         (let $target (index-atom $relation 1)
           (if (CPShape $target c3-developmental-transfer-memory 2)
             (if (CPShape $relation participant-proposed-relation 5)
               (index-atom $relation 4) (index-atom $relation 3))
             (C3TransferDevelopmentClaimsFromRelationsAt $relations
               (+ $i 1))))
         (C3TransferDevelopmentClaimsFromRelationsAt $relations (+ $i 1))))
     ()))

(= (C3TransferDevelopmentClaims $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
     (C3TransferDevelopmentClaimsFromRelationsAt
       (index-atom $participant-relations 1) 0)
     ()))

(= (C3TransferDevelopmentRecordFromClaim $claim)
   (if (CPShape $claim participant-relation-evidence 7)
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence
             c3-developmental-transfer-memory-evidence-v1 2)
         (index-atom $evidence 1)
         (c3-developmental-transfer-development-unavailable
           no-reference claim-has-no-transfer-record)))
     (c3-developmental-transfer-development-unavailable
       no-reference malformed-claim)))

; A supported developmental transfer may participate in a later unfamiliar
; contact only when the current cut again supplies all material Fact9 role
; sets and all interconnected flourishings selected by the original Soul
; inquiry. The learned episode proposes an undertaking; it never executes one.
(= (C3TransferDevelopmentApplicable $record $cut $facts $flourishing)
   (if (C3DevelopmentalTransferRecordValid $record)
     (let* (($resolution (index-atom $record 4))
            ($route (index-atom $resolution 1))
            ($fact-participation
              (index-atom (index-atom $route 7) 1))
            ($fact-surfaces (if
              (CPShape $fact-participation fact9-participation 3)
              (index-atom $fact-participation 1) ()))
            ($values (index-atom (index-atom $route 10) 1))
            ($source-cut (index-atom (index-atom $record 3) 1)))
       (and (== (C3DevelopmentalTransferStanding $resolution) support)
        (and (!= (index-atom $cut 1) $source-cut)
         (and (> (size-atom $fact-surfaces) 0)
          (and (> (size-atom $values) 0)
           (and (C3QuestionFactSurfacesApplicableAt $fact-surfaces $facts 0)
                (C3AllFlourishingMaterialPresentAt $flourishing $values
                  0)))))))
     false))

(= (C3TransferDevelopmentMemoryPossibilitiesAt $claims $cut $facts
      $flourishing $i)
   (if (< $i (size-atom $claims))
     (let* (($record (C3TransferDevelopmentRecordFromClaim
              (index-atom $claims $i)))
            ($reference (if (C3DevelopmentalTransferRecordValid $record)
              (index-atom $record 1)
              (transfer-development-reference no-reference))))
       (if (C3TransferDevelopmentApplicable $record $cut $facts $flourishing)
         (cons-atom
           (possible-movement (index-atom $reference 1) undertaking
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (index-atom (index-atom
               (index-atom (index-atom $record 4) 1) 10) 1)
             (consequence-route
               (consequence-earned-developmental-memory $record)
               non-certifying)
             l2425-supported)
           (C3TransferDevelopmentMemoryPossibilitiesAt $claims $cut $facts
             $flourishing (+ $i 1)))
         (C3TransferDevelopmentMemoryPossibilitiesAt $claims $cut $facts
           $flourishing (+ $i 1))))
     ()))

(= (C3TransferDevelopmentMemoryPossibilities $cut $facts $flourishing
      $participant-relations)
   (C3TransferDevelopmentMemoryPossibilitiesAt
     (C3TransferDevelopmentClaims $participant-relations)
     $cut $facts $flourishing 0))

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
