; C4 general dialogue participation and VoiceRNA.
;
; Exact human language first enters as contact, never as an instruction that
; bypasses the constitutive joint.  Miter forms a bounded semantic question
; from its preliminary D/Omega/I/W/C + Fact9 + flourishing organization.  A
; model returns plural derived readings.  Those readings re-enter the same
; contact as provenance-bearing participants before the final movement is
; formed.  A second bounded call may render that already-formed movement.
; Native VoiceRNA binds the rendering to the exact contact, readings, movement,
; scope and disclosure boundary before an effect descriptor can exist.

(= (C4TextParticipantsAt $participants $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (and (CPShape $participant participant-contribution 8)
             (and (== (index-atom $participant 2) human)
                  (CPShape (index-atom $participant 5)
                    participant-text-claim 5)))
         (cons-atom $participant
           (C4TextParticipantsAt $participants (+ $i 1)))
         (C4TextParticipantsAt $participants (+ $i 1))))
     ()))

(= (C4ExactTextParticipant $contact)
   (let $rows (C4TextParticipantsAt (CPParticipants $contact) 0)
     (if (== (size-atom $rows) 1)
       (index-atom $rows 0)
       (c4-text-participant-unavailable expected-exactly-one))))

; Mattermost chronology is admitted by the membrane as one proposed relation.
; It becomes material only when native history contains exactly one matching
; compact VoiceRNA proof/effect pair.  The two lineages remain separately
; attributable; a carrier file alone cannot manufacture continuation.
(= (C4ContactDRelations $contact)
   (index-atom (index-atom (CPContactConfiguration $contact) 1) 1))

(= (C4ReturnedRelationValid $contact $claim)
   (if (CPShape $claim participant-relation-claim 4)
     (let* (($effect-id (index-atom $claim 1))
            ($relations (CPFind (C4ContactDRelations $contact) $effect-id)))
       (and (== (index-atom $claim 2) support)
        (and (== (index-atom $claim 3)
               verified-delivered-response-in-same-thread)
         (and (== (size-atom $relations) 1)
          (== (index-atom $relations 0)
            (relation $effect-id returned-mattermost-effect support
              verified-delivered-response-in-same-thread))))))
     false))

(= (C4ReturnedCarrierParticipantValid $contact $participant)
   (if (CPShape $participant participant-contribution 8)
     (and (== (index-atom $participant 2) tool)
      (and (== (index-atom $participant 3) (CPContactScope $contact))
           (C4ReturnedRelationValid $contact (index-atom $participant 5))))
     false))

(= (C4ReturnedCarrierParticipantsAt $contact $participants $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (C4ReturnedCarrierParticipantValid $contact $participant)
         (cons-atom $participant
           (C4ReturnedCarrierParticipantsAt $contact $participants (+ $i 1)))
         (C4ReturnedCarrierParticipantsAt $contact $participants (+ $i 1))))
     ()))

(= (C4VoiceHistoryForEffect $effect-id)
   (collapse (match &assistant_history
     (assistant-history voice-proof $effect-id $scope $payload)
     (c4-voice-history $scope $payload))))

(= (C4EffectHistoryForEffect $effect-id)
   (collapse (match &assistant_history
     (assistant-history effect $effect-id $scope $payload)
     (c4-effect-history $scope $payload))))

(= (C4AudienceProjectSame $left $right)
   (and (== (index-atom $left 2) (index-atom $right 2))
        (== (index-atom $left 3) (index-atom $right 3))))

; Same-principal continuation must name the exact currently active source cut.
; A different authorized principal may join the shared audience/project only
; when that principal has no unrelated active organization to overwrite.
(= (C4ReturnedScopeCompatible $prior-scope $current-scope $proof-reference)
   (if (C4AudienceProjectSame $prior-scope $current-scope)
     (let $current-active (ARActiveRows $current-scope)
       (if (== (index-atom $prior-scope 1) (index-atom $current-scope 1))
         (and (== (size-atom $current-active) 1)
              (== (index-atom (index-atom
                    (index-atom $current-active 0) 2) 1)
                (index-atom $proof-reference 1)))
         (== (size-atom $current-active) 0)))
     false))

(= (C4ReturnedNativeParticipant $contact $carrier)
   (let* (($claim (index-atom $carrier 5))
          ($effect-id (index-atom $claim 1))
          ($voices (C4VoiceHistoryForEffect $effect-id))
          ($effects (C4EffectHistoryForEffect $effect-id))
          ($current-scope (CPContactScope $contact)))
     (if (and (== (size-atom $voices) 1) (== (size-atom $effects) 1))
       (let* (($voice-row (index-atom $voices 0))
              ($effect-row (index-atom $effects 0))
              ($prior-scope (index-atom $voice-row 1))
              ($voice (index-atom $voice-row 2))
              ($effect (index-atom $effect-row 2))
              ($proof-reference (if (ARVoiceProofReferenceRecordValid $voice)
                (index-atom $voice 1) ())))
         (if (and (== $prior-scope (index-atom $effect-row 1))
               (and (AR2CompactVoiceEffectPairValid $voice $effect $effect-id)
                (and (C4ReturnedScopeCompatible $prior-scope $current-scope
                       $proof-reference)
                 (and (CPShape (index-atom $proof-reference 1) cut-of 3)
                      (CPHas (index-atom (index-atom $proof-reference 1) 1)
                        (CPContactParents $contact) 0)))))
           (participant-contribution
             (c4-native-returned-effect-participation
               (index-atom $contact 1) $effect-id)
             native-authority $current-scope
             (lineage c4 persisted-voice-effect $effect-id $prior-scope)
             (participant-relation-claim $effect-id support
               (c4-returned-effect-proof-v1 $proof-reference $prior-scope
                 current-contact (index-atom $contact 1)))
             supported no-contact-no-movement-authority)
           no-native-returned-effect-participant))
       no-native-returned-effect-participant)))

(= (C4ContactWithReturnedEffect $contact)
   (let $carriers (C4ReturnedCarrierParticipantsAt $contact
          (CPParticipants $contact) 0)
     (if (== (size-atom $carriers) 1)
       (let $native (C4ReturnedNativeParticipant $contact
              (index-atom $carriers 0))
         (if (CPShape $native participant-contribution 8)
           (CP2ContactWithAuthorityParticipants $contact ($native)) $contact))
       $contact)))

; Associative recall is requested by the Soul as a scoped candidate surface.
; Exact continuity remains in the native capsule; neither Chroma distance nor
; result order has native standing.
(= (C4MemoryQuery $contact)
   (let* (($participant (C4ExactTextParticipant $contact))
          ($claim (if (CPShape $participant participant-contribution 8)
            (index-atom $participant 5) ())))
     (if (and (CPContactValid $contact)
              (CPShape $claim participant-text-claim 5))
       (c4-memory-query-v1
         (question-reference (index-atom $contact 1) continuity-recall)
         (CPContactScope $contact)
         (exact-contact-text (index-atom $claim 1) (index-atom $claim 2)
           (index-atom $claim 3))
         (query-contract scoped-continuity-candidates rank-not-authority
           no-contact-no-authority-no-choice)
         (resource-request chroma-local 4))
       (c4-memory-query-unavailable missing-exact-scoped-contact))))

(= (C4MemoryResultValid $result)
   (if (CPShape $result c4-memory-result-v1 8)
     (==
       ((CPShape (index-atom $result 3) source-capsule 6)
        (CPShape (index-atom $result 4) body 3)
        (CPShape (index-atom $result 5) snapshot-sha256 2)
        (CPShape (index-atom $result 6) distance 3)
        (== (index-atom (index-atom $result 6) 2)
          diagnostic-not-authority)
        (== (index-atom $result 7)
          scope-and-capsule-verified-locally))
       (true true true true true true))
     false))

(= (C4MemoryResultsValidAt $results $i $ids)
   (if (< $i (size-atom $results))
     (let $result (index-atom $results $i)
       (and (C4MemoryResultValid $result)
        (and (== (CPHas (index-atom $result 1) $ids 0) false)
             (C4MemoryResultsValidAt $results (+ $i 1)
               (cons-atom (index-atom $result 1) $ids)))))
     true))

(= (C4MemoryObservationValid $observation $question)
   (if (and (CPShape $observation c4-memory-observation-v1 10)
            (CPShape $question c4-memory-query-v1 6))
     (let* (($standing (index-atom $observation 5))
            ($memories (index-atom $observation 8))
            ($rows (if (CPShape $memories memories 2)
              (index-atom $memories 1) ())))
       (==
         ((== (index-atom $observation 1) (index-atom $question 1))
          (== (index-atom $observation 2) (index-atom $question 2))
          (== (index-atom $observation 3)
            miter-cleanroom-continuity-v1)
          (== (index-atom $observation 4)
            lm-studio-nomic-embed-v1.5)
          (CPShape $standing standing 2)
          (CPHas (index-atom $standing 1) (available unavailable) 0)
          (CPShape (index-atom $observation 6) reason 2)
          (CPShape (index-atom $observation 7) query-sha256 2)
          (CPShape $memories memories 2)
          (if (== (index-atom $standing 1) available)
            (> (size-atom $rows) 0) (== (size-atom $rows) 0))
          (C4MemoryResultsValidAt $rows 0 ())
          (== (index-atom $observation 9) rank-not-authority))
         (true true true true true true true true true true true true)))
     false))

(= (C4MemoryUnavailableValid $observation $question)
   (and (CPShape $observation c4-memory-observation-unavailable-v1 6)
     (and (== (index-atom $observation 1) (index-atom $question 1))
      (and (== (index-atom $observation 2) (index-atom $question 2))
       (and (== (index-atom $observation 3) chroma-local)
            (== (index-atom $observation 5) no-candidate-admitted))))))

(= (C4MemoryParticipant $result $scope $query-hash)
   (participant-contribution (index-atom $result 1) memory $scope
     (lineage chroma-local miter-cleanroom-continuity-v1 $query-hash
       (index-atom $result 1))
     (c4-scoped-memory-candidate-v1
       (c4-continuity-memory (index-atom $result 1))
       (c4-scoped-memory-evidence-v1
         (index-atom $result 2) (index-atom $result 3)
         (index-atom $result 4) (index-atom $result 5)
         (index-atom $result 6) scope-and-capsule-verified
         rank-not-authority))
     unresolved no-contact-no-movement-authority))

(= (C4MemoryParticipantsAt $results $scope $query-hash $i)
   (if (< $i (size-atom $results))
     (cons-atom
       (C4MemoryParticipant (index-atom $results $i) $scope $query-hash)
       (C4MemoryParticipantsAt $results $scope $query-hash (+ $i 1)))
     ()))

(= (C4MemoryStateParticipant $question $observation)
   (participant-contribution
     (c4-memory-availability (index-atom (index-atom $question 1) 1))
     memory (index-atom $question 2)
     (lineage chroma-local (index-atom $question 1))
     (c4-memory-availability-candidate-v1
       relation-semantic-memory-availability
       (c4-memory-availability-observation $observation))
     unresolved no-contact-no-movement-authority))

(= (C4MemoryParticipants $observation $question)
   (if (C4MemoryObservationValid $observation $question)
     (let $rows (index-atom (index-atom $observation 8) 1)
       (if (> (size-atom $rows) 0)
         (C4MemoryParticipantsAt $rows (index-atom $question 2)
           (index-atom (index-atom $observation 7) 1) 0)
         ((C4MemoryStateParticipant $question $observation))))
     (if (C4MemoryUnavailableValid $observation $question)
       ((C4MemoryStateParticipant $question $observation)) ())))

(= (C4MemorySurface $participant)
   (if (and (CPShape $participant participant-contribution 8)
         (and (== (index-atom $participant 2) memory)
              (CPShape (index-atom $participant 5)
                c4-scoped-memory-candidate-v1 3)))
     (let $evidence (index-atom (index-atom $participant 5) 2)
       (if (CPShape $evidence c4-scoped-memory-evidence-v1 8)
         (c4-memory-reference (index-atom $participant 1)
           (index-atom $evidence 1)
           (body-sha256 (index-atom (index-atom $evidence 3) 1))
           (snapshot-sha256
             (index-atom (index-atom $evidence 4) 1))
           scope-and-capsule-verified
           content-withheld-from-remote-provider rank-not-authority)
         no-memory-surface))
     no-memory-surface))

; Exact memory bodies remain inside the native contact organization.  They may
; be exposed only to the explicitly configured loopback continuity resource,
; and only after a derived continuity requirement participates in the same
; formed encounter.  Chroma order and distance remain non-authoritative.
(= (C4PrivateMemoryEntry $participant)
   (if (and (CPShape $participant participant-contribution 8)
         (and (== (index-atom $participant 2) memory)
              (CPShape (index-atom $participant 5)
                c4-scoped-memory-candidate-v1 3)))
     (let $evidence (index-atom (index-atom $participant 5) 2)
       (if (CPShape $evidence c4-scoped-memory-evidence-v1 8)
         (c4-private-memory-evidence-v1 (index-atom $participant 1)
           (index-atom $evidence 1) (index-atom $evidence 2)
           (index-atom $evidence 3) (index-atom $evidence 4)
           scope-and-capsule-verified rank-not-authority)
         no-private-memory-entry))
     no-private-memory-entry))

(= (C4PrivateMemoryEntriesAt $participants $i)
   (if (< $i (size-atom $participants))
     (let $entry (C4PrivateMemoryEntry (index-atom $participants $i))
       (if (== $entry no-private-memory-entry)
         (C4PrivateMemoryEntriesAt $participants (+ $i 1))
         (cons-atom $entry
           (C4PrivateMemoryEntriesAt $participants (+ $i 1)))))
     ()))

(= (C4PrivateContinuityContext $contact)
   (private-continuity-context
     (C4PrivateMemoryEntriesAt (CPParticipants $contact) 0)
     scope-verified-native-candidates-not-authority))

(= (C4PrivateContinuityContextEntries $context)
   (if (CPShape $context private-continuity-context 3)
     (index-atom $context 1) ()))

(= (C4PrivateContinuityContextPresent $context)
   (> (size-atom (C4PrivateContinuityContextEntries $context)) 0))

(= (C4MemorySurfacesAt $participants $i)
   (if (< $i (size-atom $participants))
     (let $surface (C4MemorySurface (index-atom $participants $i))
       (if (== $surface no-memory-surface)
         (C4MemorySurfacesAt $participants (+ $i 1))
         (cons-atom $surface
           (C4MemorySurfacesAt $participants (+ $i 1)))))
     ()))

(= (C4ContactWithMemory $contact $participants)
   (if (> (size-atom $participants) 0)
     (CP2ContactWithAuthorityParticipants $contact $participants) $contact))

(= (C4Fact9EntriesAt $facts $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (CPShape $fact fact9-expression 10)
         (cons-atom
           (c4-fact9-entry (index-atom $fact 1)
             (roles (index-atom $fact 2))
             (material-relations
               (CPRowIds (index-atom (index-atom $fact 4) 2)))
             (index-atom $fact 6))
           (C4Fact9EntriesAt $facts (+ $i 1)))
         (C4Fact9EntriesAt $facts (+ $i 1))))
     ()))

(= (C4FlourishingEntriesAt $expressions $i)
   (if (< $i (size-atom $expressions))
     (let $expression (index-atom $expressions $i)
       (if (CPShape $expression flourishing-expression 4)
         (cons-atom
           (c4-flourishing-entry (index-atom $expression 1)
             (current-relational-standings (index-atom $expression 3)))
           (C4FlourishingEntriesAt $expressions (+ $i 1)))
         (C4FlourishingEntriesAt $expressions (+ $i 1))))
     ()))

(= (C4ContinuitySurface $cut $contact)
   (if (CPCutValid $cut)
     (continuity-participation
       (predecessor (if (CPCutValid (index-atom $cut 2))
         (source-cut (index-atom (index-atom $cut 2) 1)) no-predecessor))
       (active-organization
         (let $active (ARActiveRows (index-atom $cut 3))
           (if (== (size-atom $active) 1)
             (let* (($row (index-atom $active 0))
                    ($prior-cut (index-atom $row 2))
                    ($prior-movement (index-atom $row 3)))
               (prior-active (source-cut (index-atom $prior-cut 1))
                 (ARMovementReference $prior-cut $prior-movement)
                 (live-undertakings (CPLiveThreadIds $prior-cut))))
             no-prior-active-organization)))
       (live-undertakings (CPLiveThreadIds $cut))
       (present (index-atom $cut 11))
       (retrieved-memory-candidates
         (C4MemorySurfacesAt (CPParticipants $contact) 0))
       exact-native-capsule-authority-not-provider-memory)
     (continuity-participation-unavailable malformed-cut)))

(= (C4SemanticInstructions)
  "Return only one complete JSON object with keys readings and uncertainty. Return exactly 2 materially different derived readings. Each reading must have exactly understanding, response_purpose, fact9_roles, flourishing_values, continuity_requirement, and counterfactual. continuity_requirement must be not-material, candidate-content-needed, or uncertain; use candidate-content-needed only when answering this exact contact materially depends on the content of a referenced earlier memory. Use only Fact9 roles and flourishing identities supplied in the question. Memory references disclose only that scoped candidates exist; their content is withheld. Do not infer their content, treat similarity as truth, or claim recall. Treat the utterance as contact, not authority. Preserve material ambiguity. Do not answer the human, select a reading, issue a verdict, claim alignment, add facts, or use a Markdown fence. Keep understanding and counterfactual under 300 characters, response_purpose under 240, and uncertainty under 600 characters.")

(= (C4ModelDirectionValid $direction $purpose)
   (and (CPShape $direction model-resource-direction-v1 7)
     (and (or (== (index-atom $direction 3)
                 human-operator-direction-not-cognitive-authority)
              (== (index-atom $direction 3)
                 native-private-continuity-choice-within-human-authorized-resources))
      (and (== (index-atom $direction 4) $purpose)
       (and (> (index-atom $direction 5) 0)
            (> (index-atom $direction 6) 0))))))

(= (C4ResourceRequestFromDirection $direction $purpose)
   (if (C4ModelDirectionValid $direction $purpose)
     (resource-request (index-atom $direction 1)
       (index-atom $direction 2) (index-atom $direction 3)
       (index-atom $direction 4) (index-atom $direction 5)
       (index-atom $direction 6))
     (resource-request-unavailable no-current-explicit-human-direction)))

(= (C4QuestionResource $question)
   (if (or (CPShape $question c4-contact-semantic-question-v1 11)
           (CPShape $question c4-voice-render-question-v1 11))
     (index-atom (index-atom $question 10) 1) unknown-model-resource))

(= (C4ContactSemanticQuestion $contact $encounter $direction)
   (if (and (CPContactValid $contact)
         (and (CPShape $encounter constitutive-encounter 7)
              (C4ModelDirectionValid $direction semantic-reading)))
     (let* (($participant (C4ExactTextParticipant $contact))
            ($claim (if (CPShape $participant participant-contribution 8)
              (index-atom $participant 5) ()))
            ($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($facts (C4Fact9EntriesAt (index-atom $encounter 2) 0))
            ($flourishing (C4FlourishingEntriesAt
              (index-atom (index-atom $encounter 3) 2) 0)))
       (if (and (CPShape $claim participant-text-claim 5)
             (and (> (size-atom $facts) 0)
                  (== (size-atom $flourishing) 9)))
         (c4-contact-semantic-question-v1
           (question-reference (index-atom $contact 1)
             general-contact-semantics)
           (CPContactScope $contact)
           (source-contact (index-atom $contact 1)
             (payload-reference (index-atom $contact 8)))
           (exact-contact-text (index-atom $claim 1) (index-atom $claim 2)
             (index-atom $claim 3))
           (preliminary-movement (CP2MovementReference $cut $movement))
           (fact9-participation $facts finite-contact-relative-legibility)
           (flourishing-participation $flourishing
             interconnected-generative-not-nine-scores)
           (C4ContinuitySurface $cut $contact)
           (request-contract (C4SemanticInstructions)
             authorized-current-contact-only derived-readings-not-verdict
             no-contact-no-authority-no-choice)
           (C4ResourceRequestFromDirection $direction semantic-reading))
         (c4-contact-semantic-question-unavailable
           missing-exact-text-or-complete-constitutive-surface)))
     (c4-contact-semantic-question-unavailable
       malformed-contact-or-encounter)))

(= (C4SemanticReadingFact9Roles $reading)
   (if (CPShape $reading c4-semantic-reading-v1 9)
     (index-atom (index-atom $reading 4) 1) ()))

(= (C4SemanticReadingFlourishings $reading)
   (if (CPShape $reading c4-semantic-reading-v1 9)
     (index-atom (index-atom $reading 5) 1) ()))

(= (C4QuestionFact9RolesAt $entries $i $out)
   (if (< $i (size-atom $entries))
     (C4QuestionFact9RolesAt $entries (+ $i 1)
       (CPListAppend $out
         (index-atom (index-atom (index-atom $entries $i) 2) 1)))
     $out))

(= (C4QuestionFlourishingValuesAt $entries $i $out)
   (if (< $i (size-atom $entries))
     (C4QuestionFlourishingValuesAt $entries (+ $i 1)
       (cons-atom (index-atom (index-atom $entries $i) 1) $out))
     $out))

(= (C4SemanticReadingValid $reading $question)
   (if (and (CPShape $reading c4-semantic-reading-v1 9)
            (CPShape $question c4-contact-semantic-question-v1 11))
     (let* (($fact-wrapper (index-atom $question 6))
            ($flourishing-wrapper (index-atom $question 7))
            ($fact-roles (C4QuestionFact9RolesAt
              (index-atom $fact-wrapper 1) 0 ()))
            ($flourishing-values (C4QuestionFlourishingValuesAt
              (index-atom $flourishing-wrapper 1) 0 ())))
       (==
         ((CPShape (index-atom $reading 4) fact9-roles 2)
          (CPShape (index-atom $reading 5) flourishing-values 2)
          (CPSubset (C4SemanticReadingFact9Roles $reading) $fact-roles 0)
          (CPSubset (C4SemanticReadingFlourishings $reading)
            $flourishing-values 0)
          (CPShape (index-atom $reading 6) continuity-requirement 2)
          (CPHas (index-atom (index-atom $reading 6) 1)
            (not-material candidate-content-needed uncertain) 0)
          (== (index-atom $reading 8) model-proposal-only))
         (true true true true true true true)))
     false))

(= (C4SemanticContinuityNeededAt $readings $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (and (CPShape $reading c4-semantic-reading-v1 9)
                (== (index-atom (index-atom $reading 6) 1)
                  candidate-content-needed))
         true (C4SemanticContinuityNeededAt $readings (+ $i 1))))
     false))

(= (C4SemanticContinuityNeeded $observation)
   (if (CPShape $observation c4-semantic-observation-v1 12)
     (C4SemanticContinuityNeededAt
       (index-atom (index-atom $observation 9) 1) 0)
     false))

(= (C4SemanticReadingsValidAt $readings $question $i $ids)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (and (C4SemanticReadingValid $reading $question)
        (and (== (CPHas (index-atom $reading 1) $ids 0) false)
             (C4SemanticReadingsValidAt $readings $question (+ $i 1)
               (cons-atom (index-atom $reading 1) $ids)))))
     true))

(= (C4SemanticObservationValid $observation $question)
   (if (and (CPShape $observation c4-semantic-observation-v1 12)
            (CPShape $question c4-contact-semantic-question-v1 11))
     (let* (($readings (index-atom (index-atom $observation 9) 1))
            ($request (index-atom $question 10)))
       (and (== (index-atom $observation 1) (index-atom $question 1))
        (and (== (index-atom $observation 2) (index-atom $question 2))
         (and (== (index-atom $observation 3) (index-atom $request 1))
          (and (== (index-atom $observation 4) (index-atom $request 2))
           (and (== (index-atom $observation 5) (transport eof))
            (and (== (index-atom $observation 6) (http-status 200))
             (and (== (index-atom $observation 7) (finish-reason stop))
              (and (CPShape (index-atom $observation 8) raw-sha256 2)
               (and (CPShape (index-atom $observation 9) readings 2)
                (and (CPShape (index-atom $observation 10) usage 5)
                 (and (== (size-atom $readings) 2)
                   (and (C4SemanticReadingsValidAt $readings $question 0 ())
                        (== (index-atom $observation 11)
                          provider-reading-no-contact-no-authority-no-choice))))))))))))))
     false))

(= (C4ModelUnavailableValid $observation $question)
   (and (CPShape $observation c4-model-observation-unavailable-v1 6)
     (and (== (index-atom $observation 1) (index-atom $question 1))
      (and (== (index-atom $observation 2) (index-atom $question 2))
       (and (== (index-atom $observation 3) (C4QuestionResource $question))
            (== (index-atom $observation 5) no-candidate-admitted))))))

(= (C4SemanticParticipantsAt $readings $question $scope $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (cons-atom
         (participant-contribution (index-atom $reading 1) model $scope
           (lineage (index-atom (index-atom $question 10) 1)
             (index-atom (index-atom $question 10) 2)
             (index-atom $question 1) (index-atom $reading 1))
           (c4-derived-semantic-reading-claim-v1
             (c4-dialogue-reading (index-atom $reading 1))
             (c4-derived-semantic-reading-v1 (index-atom $question 1)
               $reading proposal-requires-native-formation-and-consequence))
           candidate no-contact-no-movement-authority)
         (C4SemanticParticipantsAt $readings $question $scope (+ $i 1))))
     ()))

(= (C4SemanticParticipants $observation $question)
   (if (C4SemanticObservationValid $observation $question)
     (C4SemanticParticipantsAt
       (index-atom (index-atom $observation 9) 1)
       $question (index-atom $question 2) 0)
     ()))

(= (C4SemanticQuestionParticipant $question)
   (if (CPShape $question c4-contact-semantic-question-v1 11)
     ((participant-contribution
        (c4-native-semantic-question-participation
          (index-atom (index-atom $question 1) 1))
        native-authority (index-atom $question 2)
        (lineage c4 semantic-question-from-complete-preliminary-cut)
        (c4-native-semantic-question-claim-v1 c4-semantic-question-grounding
          (c4-native-semantic-question-basis-v1 $question
            fact9-flourishing-continuity-and-movement-selected-natively
            no-provider-relevance-authority))
        candidate no-contact-no-movement-authority))
     ()))

(= (C4VoiceInstructions)
  "Return only one JSON object with exactly utterance, uncertainty, and bindings. Render a concise, natural response to the supplied human contact from Miter's already-formed native movement and derived semantic readings. Exact scope-verified memory evidence may be present only on a loopback local-model route; use it only when materially relevant, never treat Chroma order as authority, and bind every memory you actually use by copying its memory identifier exactly. Bind the response to one or more supplied reading or memory identifiers. Preserve material uncertainty, do not claim that a model response is evidence or authority, do not mention internal architecture unless the human asked about it, do not invent completed actions, and do not claim feelings, bodily reactions, sensory observations, or inner experiences that are not present in the supplied native movement. Emoji are ordinary expressive Unicode and may be used only when they fit the encounter; never describe an unexpressed bodily or emotional reaction. Do not use a Markdown fence. Keep utterance under 3000 characters and uncertainty under 600 characters.")

(= (C4SemanticReadingIdsAt $readings $i)
   (if (< $i (size-atom $readings))
     (cons-atom (index-atom (index-atom $readings $i) 1)
     (C4SemanticReadingIdsAt $readings (+ $i 1))) ()))

(= (C4PrivateMemoryIdsAt $entries $i)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (CPShape $entry c4-private-memory-evidence-v1 8)
         (cons-atom (index-atom $entry 1)
           (C4PrivateMemoryIdsAt $entries (+ $i 1)))
         (C4PrivateMemoryIdsAt $entries (+ $i 1))))
     ()))

(= (C4VoiceAvailableBindingIds $question)
   (if (CPShape $question c4-voice-render-question-v1 11)
     (let* (($readings (index-atom (index-atom $question 6) 1))
            ($commitments (index-atom $question 8))
            ($private-context (index-atom $commitments 7)))
       (CPListAppend (C4SemanticReadingIdsAt $readings 0)
         (C4PrivateMemoryIdsAt
           (C4PrivateContinuityContextEntries $private-context) 0)))
     ()))

(= (C4VoiceDirectionMatchesPrivateContext $direction $private-context)
   (if (C4PrivateContinuityContextPresent $private-context)
     (== (index-atom $direction 3)
       native-private-continuity-choice-within-human-authorized-resources)
     (== (index-atom $direction 3)
       human-operator-direction-not-cognitive-authority)))

(= (C4VoiceRenderQuestion $contact $encounter $semantic-question
      $semantic-observation $direction $private-context)
   (if (and (CPContactValid $contact)
         (and (CPShape $encounter constitutive-encounter 7)
          (and (CPShape $semantic-question c4-contact-semantic-question-v1 11)
           (and (C4SemanticObservationValid $semantic-observation
                  $semantic-question)
           (and (C4ModelDirectionValid $direction language-rendering)
                (C4VoiceDirectionMatchesPrivateContext $direction
                  $private-context))))))
     (let* (($participant (C4ExactTextParticipant $contact))
            ($claim (if (CPShape $participant participant-contribution 8)
              (index-atom $participant 5) ()))
            ($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($readings (index-atom (index-atom $semantic-observation 9) 1)))
       (if (CPShape $claim participant-text-claim 5)
         (c4-voice-render-question-v1
           (question-reference (index-atom $contact 1) voice-rendering)
           (CPContactScope $contact)
           (source-contact (index-atom $contact 1)
             (payload-reference (index-atom $contact 8)))
           (exact-contact-text (index-atom $claim 1) (index-atom $claim 2)
             (index-atom $claim 3))
           (native-movement (CP2MovementReference $cut $movement))
           (semantic-readings $readings)
           (native-intention respond-to-authorized-contact
             preserve-plurality-and-uncertainty
             no-claim-of-unperformed-effect)
           (voice-commitments source-bound scope-bound movement-bound
             (if (C4PrivateContinuityContextPresent $private-context)
               disclosure-current-contact-and-scoped-local-continuity
               disclosure-current-contact-only)
             relational-not-fixed-style no-unsupported-internal-state-claim
             $private-context)
           (request-contract (C4VoiceInstructions)
             rendering-not-movement candidate-utterance-not-effect
             no-contact-no-authority-no-choice)
           (C4ResourceRequestFromDirection $direction language-rendering))
         (c4-voice-render-question-unavailable
           semantic-observation-not-bound-to-current-contact)))
     (c4-voice-render-question-unavailable
       malformed-contact-encounter-or-semantic-observation)))

; The contact/semantic binding is checked by the caller that still holds the
; exact native question.  This local validator checks the provider envelope and
; the structural commitments that native VoiceRNA can actually compare.
(= (C4VoiceObservationValid $observation $question)
   (if (and (CPShape $observation c4-voice-observation-v1 13)
            (CPShape $question c4-voice-render-question-v1 11))
     (let* (($rendering (index-atom $observation 9))
            ($request (index-atom $question 10))
            ($available (C4VoiceAvailableBindingIds $question))
            ($bindings (if (CPShape $rendering rendered-utterance 4)
              (index-atom (index-atom $rendering 2) 1) ())))
       (and (== (index-atom $observation 1) (index-atom $question 1))
        (and (== (index-atom $observation 2) (index-atom $question 2))
         (and (== (index-atom $observation 3) (index-atom $request 1))
          (and (== (index-atom $observation 4) (index-atom $request 2))
           (and (== (index-atom $observation 5) (transport eof))
            (and (== (index-atom $observation 6) (http-status 200))
             (and (== (index-atom $observation 7) (finish-reason stop))
              (and (CPShape (index-atom $observation 8) raw-sha256 2)
               (and (CPShape $rendering rendered-utterance 4)
                (and (> (size-atom $bindings) 0)
                 (and (CPUniq $bindings 0 ())
                  (and (CPSubset $bindings $available 0)
                   (and (CPShape (index-atom $observation 10) usage 5)
                    (and (== (index-atom $observation 11)
                           candidate-rendering-no-effect-authority)
                         (== (index-atom $observation 12)
                           structurally-bound-semantic-fidelity-remains-consequence-testable))))))))))))))))
     false))

(= (C4VoiceAuthorizedDisclosure $voice-question)
   (if (CPShape $voice-question c4-voice-render-question-v1 11)
     (let* (($commitments (index-atom $voice-question 8))
            ($private-context (index-atom $commitments 7)))
       (if (C4PrivateContinuityContextPresent $private-context)
         (authorized-disclosure
           current-contact-and-scoped-native-memory-local-only)
         (authorized-disclosure current-contact-and-derived-readings-only)))
     (authorized-disclosure unavailable)))

(= (C4VoiceCertificate $encounter $voice-question $voice-observation $proof)
   (if (and (CPShape $encounter constitutive-encounter 7)
         (and (ARNativeMovementProofValid $proof)
              (C4VoiceObservationValid $voice-observation $voice-question)))
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($participants (index-atom $encounter 6))
            ($rendering (index-atom $voice-observation 9))
            ($source (index-atom $voice-question 3)))
       (assistant-voice-certificate-v3
         (VoiceRNA situated-model-rendering)
         (source-cut (index-atom $cut 1))
         (index-atom $cut 3)
         (movement-source-reference (ARMovementReference $cut $movement))
         (intended-expression
           (mattermost-response (index-atom $source 1)
             (index-atom $rendering 1)))
         (ARParticipantBoundaryReference $participants)
         (ARNativeProofReference $proof)
         (voice-audit-v1
           (index-atom $rendering 2) (index-atom $rendering 3)
           source-scope-movement-bound no-added-effect-authority)
         (C4VoiceAuthorizedDisclosure $voice-question)
         (emission-authority mattermost-exact-resolved-group-only)))
     (assistant-voice-held invalid-rendering-or-native-proof)))

(= (C4VoiceCertificateValid $certificate $proof)
   (if (and (CPShape $certificate assistant-voice-certificate-v3 11)
            (ARNativeMovementProofValid $proof))
     (let* (($cut (index-atom $proof 1))
            ($scope (index-atom $proof 2))
            ($movement (index-atom $proof 3))
            ($participants (index-atom $proof 4)))
       (==
         ((== (index-atom $certificate 1)
            (VoiceRNA situated-model-rendering))
          (== (index-atom $certificate 2)
            (source-cut (index-atom $cut 1)))
          (== (index-atom $certificate 3) $scope)
          (== (index-atom $certificate 4)
            (movement-source-reference (ARMovementReference $cut $movement)))
          (CPShape (index-atom $certificate 5) intended-expression 2)
          (== (index-atom $certificate 6)
            (ARParticipantBoundaryReference $participants))
          (== (index-atom $certificate 7) (ARNativeProofReference $proof))
          (CPShape (index-atom $certificate 8) voice-audit-v1 5)
          (or (== (index-atom $certificate 9)
                (authorized-disclosure
                  current-contact-and-derived-readings-only))
              (== (index-atom $certificate 9)
                (authorized-disclosure
                  current-contact-and-scoped-native-memory-local-only)))
          (== (index-atom $certificate 10)
            (emission-authority mattermost-exact-resolved-group-only)))
         (true true true true true true true true true true)))
     false))

(= (C4MattermostEffectDescriptor $contact-result)
   (if (CPShape $contact-result assistant-contact-incorporated-v4 5)
     (let* (($contact-id (index-atom $contact-result 1))
            ($encounter (index-atom $contact-result 2))
            ($voice-question (index-atom $contact-result 3))
            ($voice-observation (index-atom $contact-result 4))
            ($movement (AREncounterMovement $encounter))
            ($proof (ARNativeMovementProof $encounter))
            ($certificate (C4VoiceCertificate $encounter $voice-question
              $voice-observation $proof))
            ($effect-id (as_native_id c4-mattermost-effect
              ($contact-id (index-atom $voice-observation 8)
                (ARMovementReference (index-atom $encounter 1) $movement)))))
       (if (and (CPShape $movement movement-formed 7)
                (C4VoiceCertificateValid $certificate $proof))
         (mattermost-effect-descriptor-v1 $effect-id $effect-id
           (index-atom $certificate 3)
           (reply-to-contact $contact-id)
           (payload $certificate)
           (native-proof $proof)
           (capability mattermost-create-post exact-resolved-group-only
             pending-before-send-reconcile-unknown)
           prepared)
         (mattermost-effect-held $contact-id
           unresolved-or-uncertified-native-movement)))
     no-local-effect))

(= (C4MattermostEffectDescriptorValid $descriptor)
   (if (CPShape $descriptor mattermost-effect-descriptor-v1 9)
     (let* (($certificate-wrapper (index-atom $descriptor 5))
            ($proof-wrapper (index-atom $descriptor 6))
            ($certificate (index-atom $certificate-wrapper 1))
            ($proof (index-atom $proof-wrapper 1))
            ($reply (index-atom $descriptor 4))
            ($intended (index-atom $certificate 5))
            ($response (index-atom $intended 1)))
       (==
         ((CPShape $certificate-wrapper payload 2)
          (CPShape $proof-wrapper native-proof 2)
          (CPShape $certificate assistant-voice-certificate-v3 11)
          (CPShape $intended intended-expression 2)
          (== (index-atom $descriptor 1) (index-atom $descriptor 2))
          (CPShape (index-atom $descriptor 3) scope 4)
          (CPShape $reply reply-to-contact 2)
          (C4VoiceCertificateValid $certificate $proof)
          (CPShape $response mattermost-response 3)
          (== (index-atom $response 1) (index-atom $reply 1))
          (== (index-atom $descriptor 7)
            (capability mattermost-create-post exact-resolved-group-only
              pending-before-send-reconcile-unknown))
          (== (index-atom $descriptor 8) prepared))
         (true true true true true true true true true true true true)))
     false))

; This is one turn inside the existing reactor, not a new conversational loop.
; The preliminary encounter is pure construction.  Active state changes once,
; only after the model readings have re-entered as participants and the full
; M24--M26.3 joint has formed again.
(= (C4IncorporateBoundContactWithoutModel $context)
   (let* (($contact (index-atom $context 5))
          ($result (AR4IncorporatePreparedEncounter
            (AR4PrepareEncounterV1 $contact))))
     (AR4RecordBoundContextV1 $context $result)))

(= (C4DialogueModelOutcomeValid $outcome)
   (if (CPShape $outcome assistant-dialogue-model-participation-v1 4)
     (let* (($semantic-question (index-atom $outcome 1))
            ($semantic-observation (index-atom $outcome 2))
            ($voice-standing (index-atom $outcome 3)))
       (and (C4SemanticObservationValid $semantic-observation
              $semantic-question)
            (or (and (CPShape $voice-standing voice-rendering-v1 3)
                  (C4VoiceObservationValid (index-atom $voice-standing 2)
                    (index-atom $voice-standing 1)))
                (CPShape $voice-standing voice-rendering-unavailable 3))))
     (CPShape $outcome assistant-dialogue-model-unavailable-v1 3)))

; Re-form the same occurrence after semantic participants arrive without
; recomputing its already-established M24 and M26.0 authority organizations.
; The final M25/M25.5 construction is still fresh: every resulting possibility
; receives one new simultaneous R/A/P read on the enriched contact surface.
(= (C4ReformPreparedWithParticipants $prepared $additional-participants)
   (if (and (AR4PreparedEncounterValid $prepared)
            (> (size-atom $additional-participants) 0))
     (let* (($id (index-atom $prepared 1))
            ($scope (index-atom $prepared 2))
            ($contact (index-atom $prepared 3))
            ($grounded (index-atom $prepared 4))
            ($joint (index-atom $grounded 1))
            ($encounter (index-atom $grounded 2))
            ($cut (index-atom $encounter 1))
            ($enriched-contact (CP2ContactWithAuthorityParticipants $contact
              $additional-participants))
            ($reformed (CP2EncounterFromAuthorityOrganizations
              $enriched-contact (index-atom $cut 2)
              (index-atom $joint 2) (index-atom $joint 3)
              (index-atom $joint 4) (index-atom $joint 5))))
       (prepared-encounter-v1 $id $scope $enriched-contact $reformed))
     (prepared-encounter-held
       (if (CPShape $prepared prepared-encounter-v1 5)
         (index-atom $prepared 1) unknown-contact)
       semantic-reformation-prerequisites-unavailable)))

(= (C4BoundContactUsingV1 $root $binding $contact $memory-writer $model-writer)
   (let $initial-context (AR4BoundContactContextV1 $binding $contact)
     (if (AR4BoundContactContextValid $initial-context)
       (let* (($initial-contact
                (C4ContactWithReturnedEffect (index-atom $initial-context 5)))
              ($memory-question (C4MemoryQuery $initial-contact))
              ($memory-observation (if (CPShape $memory-question
                c4-memory-query-v1 6)
                ($memory-writer $root $memory-question)
                (c4-memory-observation-unavailable-v1
                  (question-reference (index-atom $contact 1)
                    continuity-recall)
                  (CPContactScope $contact) chroma-local
                  native-memory-question-unavailable no-candidate-admitted)))
              ($memory-participants
                (C4MemoryParticipants $memory-observation $memory-question))
              ($memory-contact
                (C4ContactWithMemory $initial-contact $memory-participants))
              ($capability-observation (as_capability_environment $root))
              ($capability-participants
                (C4CapabilityEnvironmentParticipants $memory-contact
                  $capability-observation))
              ($effective-contact
                (C4ContactWithCapabilityEnvironment $memory-contact
                  $capability-participants))
              ($context (bound-contact-context-v1
                (index-atom $initial-context 1)
                (index-atom $initial-context 2)
                (index-atom $initial-context 3)
                (c4-semantic-context
                  (ASSemanticStandingSummary (index-atom $initial-context 4))
                  (memory-query-standing $memory-question
                    $memory-observation rank-not-authority))
                $effective-contact))
              ($prepared (AR4PrepareEncounterV1 $effective-contact)))
         (if (AR4PreparedEncounterValid $prepared)
           (let* (($grounded (index-atom $prepared 4))
                  ($preliminary (index-atom $grounded 2))
                  ($semantic-direction (as_model_direction $root
                    (CPContactScope $effective-contact) semantic-reading))
                  ($question (C4ContactSemanticQuestion $effective-contact
                    $preliminary $semantic-direction))
                  ($observation (if (CPShape $question
                    c4-contact-semantic-question-v1 11)
                    ($model-writer $root $question)
                    (c4-model-observation-unavailable-v1
                      (question-reference (index-atom $contact 1)
                        general-contact-semantics)
                      (CPContactScope $contact)
                      (if (C4ModelDirectionValid $semantic-direction
                            semantic-reading)
                        (index-atom $semantic-direction 1)
                        unknown-model-resource)
                      native-question-unavailable no-candidate-admitted))))
             (if (C4SemanticObservationValid $observation $question)
               (let* (($participants (CPListAppend
                        (C4SemanticQuestionParticipant $question)
                        (C4SemanticParticipants $observation $question)))
                      ($final-prepared
                        (C4ReformPreparedWithParticipants $prepared
                          $participants))
                      ($enriched-contact (index-atom $final-prepared 3))
                      ($incorporated (AR4IncorporatePreparedEncounter
                        $final-prepared))
                      ($bound-result
                        (AR4RecordBoundContextV1 $context $incorporated)))
                 (if (CPShape $bound-result
                       assistant-contact-incorporated 3)
                   (let* (($encounter (index-atom $bound-result 2))
                          ($available-private-context
                            (C4PrivateContinuityContext $enriched-contact))
                          ($private-context
                            (if (and (C4SemanticContinuityNeeded $observation)
                                  (C4PrivateContinuityContextPresent
                                    $available-private-context))
                              $available-private-context
                              (private-continuity-context ()
                                scope-verified-native-candidates-not-authority)))
                          ($voice-direction
                            (if (C4PrivateContinuityContextPresent
                                  $private-context)
                              (as_model_private_continuity_direction $root
                                (CPContactScope $enriched-contact)
                                language-rendering)
                              (as_model_direction $root
                                (CPContactScope $enriched-contact)
                                language-rendering)))
                          ($voice-question (C4VoiceRenderQuestion
                            $enriched-contact $encounter $question
                            $observation $voice-direction $private-context))
                          ($voice-observation (if (CPShape $voice-question
                            c4-voice-render-question-v1 11)
                            ($model-writer $root $voice-question)
                            (c4-model-observation-unavailable-v1
                              (question-reference (index-atom $contact 1)
                                voice-rendering)
                              (CPContactScope $contact)
                              (if (C4ModelDirectionValid $voice-direction
                                    language-rendering)
                                (index-atom $voice-direction 1)
                                unknown-model-resource)
                              native-voice-question-unavailable
                              no-candidate-admitted))))
                     (if (C4VoiceObservationValid $voice-observation
                           $voice-question)
                       (assistant-processed-v3
                         (assistant-contact-incorporated-v4
                           (index-atom $contact 1) $encounter $voice-question
                           $voice-observation)
                         (assistant-dialogue-model-participation-v1 $question
                           $observation
                           (voice-rendering-v1 $voice-question
                             $voice-observation)))
                       (assistant-processed-v3 $bound-result
                         (assistant-dialogue-model-participation-v1 $question
                           $observation
                           (voice-rendering-unavailable $voice-question
                             $voice-observation)))))
                   (assistant-processed-v3 $bound-result
                     (assistant-dialogue-model-participation-v1 $question
                       $observation
                       (voice-rendering-unavailable
                         no-incorporated-native-movement
                         no-rendering-observation)))))
               (let* (($incorporated
                        (C4IncorporateBoundContactWithoutModel $context))
                      ($outcome (assistant-dialogue-model-unavailable-v1
                        $question $observation)))
                 (assistant-processed-v3 $incorporated $outcome))))
           (assistant-processed-v3
             (AR4IncorporatePreparedEncounter $prepared)
             (assistant-dialogue-model-unavailable-v1
               native-preformation-held no-model-observation))))
       (assistant-processed-v3
         (if (CPShape $initial-context bound-contact-context-held 3)
           (assistant-contact-held (index-atom $initial-context 1)
             (index-atom $initial-context 2))
           (assistant-contact-rejected stable-identity-scope-mismatch))
         model-participation-not-requested))))

(= (C4BoundContactWithModelV1 $root $binding $contact)
   (C4BoundContactUsingV1 $root $binding $contact as_chroma as_model))
