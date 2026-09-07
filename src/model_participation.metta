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
(= (C3ParticipantsAfterSemanticConsequence $participants $movement
      $consequence)
   (let* (($surface (C3SemanticInquirySurfaceFromMovement $movement))
          ($resolution (C3SemanticConsequenceResolution $movement
            $consequence)))
     (if (and (CPShape $surface c3-semantic-inquiry-surface-v1 8)
              (CPShape $resolution c3-semantic-consequence-resolution-v1 7))
       (C3ParticipantsWithoutSemanticSurfaceAt $participants $surface 0)
       $participants)))

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
