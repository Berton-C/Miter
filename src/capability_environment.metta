; Native participation of the dedicated-user open growth environment.
; Availability is contact, not authority and not a selected tool action.

(= (C4CapabilityEnvironmentObservationValid $observation)
   (if (CPShape $observation capability-environment-observation-v1 10)
     (and (== (index-atom $observation 1)
            miter-open-growth-environment-v1)
      (and (CPShape (index-atom $observation 2) runtime-identity 4)
       (and (CPShape (index-atom $observation 3) workspace 3)
        (and (CPShape (index-atom $observation 4) informational-network 3)
         (and (CPShape (index-atom $observation 5) terminal 3)
          (and (CPShape (index-atom $observation 6) reversible-writes 3)
           (and (CPShape (index-atom $observation 7) credential-access 3)
            (and (CPShape (index-atom $observation 8)
                   human-authority-boundaries 7)
             (CPHas (index-atom $observation 9)
               (held-environment-disabled held-runtime-identity-mismatch
                 held-workspace-unavailable held-request-broker-unimplemented
                 available-open-growth-environment) 0)))))))))
     false))

(= (C4CapabilityEnvironmentStanding $observation)
   (if (C4CapabilityEnvironmentObservationValid $observation)
     (index-atom $observation 9)
     capability-environment-observation-invalid))

(= (C4CapabilityEnvironmentParticipants $contact $observation)
   (if (and (CPContactValid $contact)
            (C4CapabilityEnvironmentObservationValid $observation))
     (let* (($standing (C4CapabilityEnvironmentStanding $observation))
            ($available (== $standing available-open-growth-environment)))
       ((participant-contribution
          (c4-capability-environment-participation (index-atom $contact 1))
          tool (CPContactScope $contact)
          (lineage miter-open-growth-environment-v1
            mechanical-runtime-observation)
          (participant-relation-claim open-growth-environment-standing
            (if $available support unresolved)
            (capability-environment-evidence $observation))
          (if $available supported unresolved)
          no-contact-no-movement-authority)))
     ()))

(= (C4ContactWithCapabilityEnvironment $contact $participants)
   (if (and (CPShape $contact contact-v2 11)
            (> (size-atom $participants) 0))
     (let* (($configuration (index-atom $contact 9))
            ($existing (index-atom $configuration 10))
            ($joined (CPListAppend $existing $participants)))
       (contact-v2
         (index-atom $contact 1) (index-atom $contact 2)
         (index-atom $contact 3) (index-atom $contact 4)
         (index-atom $contact 5) (index-atom $contact 6)
         (index-atom $contact 7) (index-atom $contact 8)
         (encounter-configuration
           (index-atom $configuration 1) (index-atom $configuration 2)
           (index-atom $configuration 3) (index-atom $configuration 4)
           (index-atom $configuration 5) (index-atom $configuration 6)
           (index-atom $configuration 7) (index-atom $configuration 8)
           (index-atom $configuration 9) $joined)
         (index-atom $contact 10)))
     $contact))

; An exact operation becomes executable only when it is the answerability route
; of one already-formed native movement.  The complete proof retains the one
; simultaneous R/A/P read plus the Fact9/flourishing organization that formed
; that movement.  No model string or mechanical availability flag can create
; this descriptor directly.
(= (C4CapabilityOperationValid $operation)
   (if (CPShape $operation informational-http-v1 3)
     (and (CPHas (index-atom $operation 1) (get head) 0)
          (== (is-expr (index-atom $operation 2)) false))
     false))

(= (C4CapabilityRouteFromMovement $movement)
   (if (and (CPShape $movement movement-formed 7)
            (== (index-atom $movement 1) inquiry))
     (let* (($answerability (index-atom $movement 5))
            ($o-star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($route-wrapper (if (CPShape $o-star o-star 2)
              (index-atom $o-star 1) ()))
            ($route (if (CPShape $route-wrapper consequence-route 3)
              (index-atom $route-wrapper 1) ())))
       (if (and (CPShape $route c4-capability-request-route-v1 5)
             (and (CPShape (index-atom $route 2) native-purpose 2)
              (and (!= (index-atom (index-atom $route 2) 1) "")
               (and (C4CapabilityOperationValid (index-atom $route 3))
                (and (== (index-atom $route 4)
                     dedicated-user-open-growth-environment)
                     (== (index-atom $route-wrapper 2) non-certifying))))))
         $route
         (c4-capability-request-route-unavailable
           movement-answerability-is-not-an-exact-tool-request)))
     (c4-capability-request-route-unavailable
       movement-is-not-a-formed-inquiry)))

(= (C4CapabilityRequestIdentityBasis $contact-id $movement-reference
      $operation $deadline $maximum-bytes)
   (capability-request-v1 $contact-id $movement-reference $operation
     (limits (deadline-seconds $deadline)
       (maximum-body-bytes $maximum-bytes))))

(= (C4CapabilityRequestDescriptor $contact $encounter)
   (if (and (CPContactValid $contact)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($route (C4CapabilityRouteFromMovement $movement))
            ($operation (if (CPShape $route
              c4-capability-request-route-v1 5)
              (index-atom $route 3) ()))
            ($purpose (if (CPShape $route
              c4-capability-request-route-v1 5)
              (index-atom $route 2) (native-purpose "")))
            ($proof (ARNativeMovementProof $encounter))
            ($movement-reference (ARMovementReference $cut $movement))
            ($deadline 30)
            ($maximum-bytes 32768)
            ($request-id (as_native_id c4-capability-request
              (C4CapabilityRequestIdentityBasis (index-atom $contact 1)
                $movement-reference $operation $deadline $maximum-bytes))))
       (if (and (C4CapabilityOperationValid $operation)
                (ARNativeMovementProofValid $proof))
         (capability-request-descriptor-v1 $request-id $request-id
           (CPContactScope $contact)
           (source-contact (index-atom $contact 1))
           (source-movement $movement-reference)
           $purpose
           (exact-operation $operation)
           (limits (deadline-seconds $deadline)
             (maximum-body-bytes $maximum-bytes))
           (native-proof $proof)
           (capability open-http-https no-credential informational-read-only)
           prepared)
         (capability-request-held (index-atom $contact 1)
           no-proof-bound-exact-operation)))
     (capability-request-held unknown-contact malformed-contact-or-encounter)))

(= (C4CapabilityRequestDescriptorValid $descriptor $contact $encounter)
   (and (CPShape $descriptor capability-request-descriptor-v1 12)
        (== $descriptor (C4CapabilityRequestDescriptor $contact $encounter))))

(= (C4CapabilityRequestDescriptorStructuralValid $descriptor)
   (if (CPShape $descriptor capability-request-descriptor-v1 12)
     (let* (($proof-wrapper (index-atom $descriptor 9))
            ($proof (if (CPShape $proof-wrapper native-proof 2)
              (index-atom $proof-wrapper 1) ())))
       (==
         ((== (index-atom $descriptor 1) (index-atom $descriptor 2))
          (CPShape (index-atom $descriptor 3) scope 4)
          (CPShape (index-atom $descriptor 4) source-contact 2)
          (CPShape (index-atom $descriptor 5) source-movement 2)
          (CPShape (index-atom $descriptor 6) native-purpose 2)
          (!= (index-atom (index-atom $descriptor 6) 1) "")
          (CPShape (index-atom $descriptor 7) exact-operation 2)
          (C4CapabilityOperationValid
            (index-atom (index-atom $descriptor 7) 1))
          (CPShape (index-atom $descriptor 8) limits 3)
          (ARNativeMovementProofValid $proof)
          (== (index-atom $descriptor 3) (index-atom $proof 2))
          (== (index-atom $descriptor 5)
            (source-movement (ARMovementReference
              (index-atom $proof 1) (index-atom $proof 3))))
          (== (index-atom $descriptor 10)
            (capability open-http-https no-credential
              informational-read-only))
          (== (index-atom $descriptor 11) prepared))
         (true true true true true true true true true true true true true
           true)))
     false))

(= (C4CapabilityObservationValid $observation $descriptor)
   (if (and (CPShape $observation capability-observation-v1 11)
            (C4CapabilityRequestDescriptorStructuralValid $descriptor))
     (==
       ((== (index-atom $observation 1) (index-atom $descriptor 1))
        (== (index-atom $observation 2) (index-atom $descriptor 3))
        (CPShape (index-atom $observation 3)
          request-descriptor-sha256 2)
        (== (index-atom $observation 4) (resource open-http-https))
        (CPShape (index-atom $observation 5) transport 2)
        (CPHas (index-atom (index-atom $observation 5) 1)
          (eof truncated deadline failed) 0)
        (CPShape (index-atom $observation 6) http-status 2)
        (CPShape (index-atom $observation 7) body 3)
        (CPShape (index-atom $observation 8) elapsed-milliseconds 2)
        (CPShape (index-atom $observation 9) failure 2)
        (== (index-atom $observation 10)
          mechanical-observation-no-meaning-no-movement-authority))
       (true true true true true true true true true true true))
     false))

(= (C4CapabilityObservationParticipant $descriptor $observation)
   (if (C4CapabilityObservationValid $observation $descriptor)
     (participant-contribution
       (c4-open-growth-observation-participation
         (index-atom $observation 1))
       tool (index-atom $observation 2)
       (lineage miter-open-growth-environment-v1
         (index-atom $observation 3))
       (participant-relation-claim open-growth-request-returned unresolved
       (c4-open-growth-observation-evidence-v1
           (request-descriptor $descriptor)
           (index-atom $observation 4) (index-atom $observation 5)
           (index-atom $observation 6) (index-atom $observation 7)
           (index-atom $observation 8) (index-atom $observation 9)))
       unresolved no-contact-no-movement-authority)
     (participant-unresolved unknown-capability-observation
       carrier-schema-or-provenance-invalid)))

(= (C4EnvironmentAvailableClaimAt $claims $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($observation (if (CPShape $evidence
              capability-environment-evidence 2)
              (index-atom $evidence 1) ())))
       (if (and (C4CapabilityEnvironmentObservationValid $observation)
                (== (C4CapabilityEnvironmentStanding $observation)
                  available-open-growth-environment))
         true (C4EnvironmentAvailableClaimAt $claims (+ $i 1))))
     false))

(= (C4EnvironmentAvailableInRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 5)
                (== (index-atom $relation 1)
                  open-growth-environment-standing))
         (C4EnvironmentAvailableClaimAt (index-atom $relation 4) 0)
         (C4EnvironmentAvailableInRelationsAt $relations (+ $i 1))))
     false))

(= (C4EnvironmentAvailableInRelations $organization)
   (if (CPShape $organization participant-relation-organization 2)
     (C4EnvironmentAvailableInRelationsAt (index-atom $organization 1) 0)
     false))

(= (C4CapabilityProposalClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       ; CPParticipantRelationOne gives unresolved proposal families their
       ; canonical four-field form.  The five-field form is reserved for a
       ; supported same-lineage relation and must not be mistaken for a
       ; selected capability.
       (if (and (CPShape $relation participant-proposed-relation 4)
                (== (index-atom $relation 1)
                  open-growth-capability-request-proposal))
         (index-atom $relation 3)
         (C4CapabilityProposalClaimsAt $relations (+ $i 1))))
     ()))

(= (C4CapabilityProposalClaims $organization)
   (if (CPShape $organization participant-relation-organization 2)
     (C4CapabilityProposalClaimsAt (index-atom $organization 1) 0)
     ()))

(= (C4CapabilityProposalEvidenceValid $evidence)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (and (CPShape (index-atom $evidence 1) question-reference 3)
      (and (CPShape (index-atom $evidence 3) fact9-roles 2)
       (and (CPShape (index-atom $evidence 4) flourishing-values 2)
        (and (> (size-atom (index-atom (index-atom $evidence 3) 1)) 0)
         (and (> (size-atom (index-atom (index-atom $evidence 4) 1)) 0)
          (and (!= (index-atom $evidence 5) "")
               (C4CapabilityOperationValid (index-atom $evidence 6))))))))
     false))

(= (C4CapabilityProposalPossibilitiesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (== (index-atom $claim 2) model)
             (and (== (index-atom $claim 4) unresolved)
                  (C4CapabilityProposalEvidenceValid $evidence)))
         (cons-atom
           (possible-movement (index-atom $evidence 2) inquiry
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (index-atom (index-atom $evidence 4) 1)
             (consequence-route
               (c4-capability-request-route-v1
                 (index-atom $evidence 2)
                 (native-purpose (index-atom $evidence 5))
                 (index-atom $evidence 6)
                 dedicated-user-open-growth-environment)
               non-certifying)
             l2425-supported)
           (C4CapabilityProposalPossibilitiesAt $claims $cut (+ $i 1)))
         (C4CapabilityProposalPossibilitiesAt $claims $cut (+ $i 1))))
     ()))

(= (C4CapabilityProposalPossibilities $cut $participant-relations)
   (if (C4EnvironmentAvailableInRelations $participant-relations)
     (C4CapabilityProposalPossibilitiesAt
       (C4CapabilityProposalClaims $participant-relations) $cut 0)
     ()))

; Returned bytes remain untrusted contact.  They are neither a verdict nor an
; answer, but their exact request/proof lineage forms a materially different
; continuation from the request that produced them.
(= (C4CapabilityReturnedClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation participant-proposed-relation 4)
                (== (index-atom $relation 1) open-growth-request-returned))
         (index-atom $relation 3)
         (C4CapabilityReturnedClaimsAt $relations (+ $i 1))))
     ()))

(= (C4CapabilityReturnedClaims $organization)
   (if (CPShape $organization participant-relation-organization 2)
     (C4CapabilityReturnedClaimsAt (index-atom $organization 1) 0)
     ()))

(= (C4CapabilityReturnedEvidenceValid $evidence)
   (if (CPShape $evidence c4-open-growth-observation-evidence-v1 8)
     (and (CPShape (index-atom $evidence 1) request-descriptor 2)
       (and (C4CapabilityRequestDescriptorStructuralValid
              (index-atom (index-atom $evidence 1) 1))
        (and (== (index-atom $evidence 2) (resource open-http-https))
         (and (CPShape (index-atom $evidence 3) transport 2)
          (and (CPShape (index-atom $evidence 4) http-status 2)
           (and (CPShape (index-atom $evidence 5) body 3)
            (and (CPShape (index-atom $evidence 6)
                   elapsed-milliseconds 2)
                 (CPShape (index-atom $evidence 7) failure 2))))))))
     false))

(= (C4CapabilityProofFlourishings $descriptor)
   (if (C4CapabilityRequestDescriptorStructuralValid $descriptor)
     (let* (($proof (index-atom (index-atom $descriptor 9) 1))
            ($movement (index-atom $proof 3))
            ($derivation (index-atom $movement 4))
            ($requirements
              (if (CPShape $derivation material-derivation 7)
                (index-atom $derivation 6)
                (if (CPShape $derivation material-derivation-v2 7)
                  (index-atom $derivation 5)
                  (flourishing-requirements ())))))
       (if (CPShape $requirements flourishing-requirements 2)
         (index-atom $requirements 1) ()))
     ()))

(= (C4CapabilityResultPossibilitiesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (== (index-atom $claim 2) tool)
             (and (== (index-atom $claim 4) unresolved)
                  (C4CapabilityReturnedEvidenceValid $evidence)))
         (let* (($descriptor
                  (index-atom (index-atom $evidence 1) 1))
                ($request-id (index-atom $descriptor 1)))
           (cons-atom
             (possible-movement $request-id inquiry
               (CPNativeRequirementRelations $cut)
               (CPNativeRequirementDistinctions $cut)
               (CPNativeRequirementInterfaces $cut)
               (C4CapabilityProofFlourishings $descriptor)
               (consequence-route
                 (returned-informational-contact $request-id
                   (index-atom $evidence 2) (index-atom $evidence 3)
                   (index-atom $evidence 4) (index-atom $evidence 5)
                   (index-atom $evidence 7))
                 non-certifying)
               l2425-supported)
             (C4CapabilityResultPossibilitiesAt $claims $cut (+ $i 1))))
         (C4CapabilityResultPossibilitiesAt $claims $cut (+ $i 1))))
     ()))

(= (C4CapabilityResultPossibilities $cut $participant-relations)
   (C4CapabilityResultPossibilitiesAt
     (C4CapabilityReturnedClaims $participant-relations) $cut 0))

(= (C4CapabilityContactContext $descriptor $observation)
   (if (C4CapabilityObservationValid $observation $descriptor)
     (capability-contact-context-v1
       (request-id (index-atom $descriptor 1))
       (index-atom $descriptor 5) (index-atom $descriptor 6)
       (index-atom $descriptor 7)
       (index-atom $observation 4) (index-atom $observation 5)
       (index-atom $observation 6) (index-atom $observation 7)
       (index-atom $observation 8) (index-atom $observation 9)
       untrusted-returned-contact-no-authority)
     (capability-contact-context-v1 no-capability-request
       no-returned-capability-contact)))

(= (C4CapabilityContactContextValid $context)
   (if (CPShape $context capability-contact-context-v1 12)
     (and (CPShape (index-atom $context 1) request-id 2)
       (and (CPShape (index-atom $context 2) source-movement 2)
        (and (CPShape (index-atom $context 3) native-purpose 2)
         (and (CPShape (index-atom $context 4) exact-operation 2)
          (and (CPShape (index-atom $context 5) resource 2)
           (and (CPShape (index-atom $context 6) transport 2)
            (and (CPShape (index-atom $context 7) http-status 2)
             (and (CPShape (index-atom $context 8) body 3)
              (and (CPShape (index-atom $context 9) elapsed-milliseconds 2)
               (and (CPShape (index-atom $context 10) failure 2)
                    (== (index-atom $context 11)
                      untrusted-returned-contact-no-authority)))))))))))
     (== $context (capability-contact-context-v1 no-capability-request
       no-returned-capability-contact))))
