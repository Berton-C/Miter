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
     (if (CPShape $operation direct-argv-v1 4)
       (and (== (is-expr (index-atom $operation 1)) false)
        (and (is-expr (index-atom $operation 2))
             (== (is-expr (index-atom $operation 3)) false)))
       (if (CPShape $operation workspace-write-v1 4)
         (and (== (is-expr (index-atom $operation 1)) false)
          (and (== (is-expr (index-atom $operation 2)) false)
               (or (== (index-atom $operation 3) no-prior-content)
                   (CPShape (index-atom $operation 3) prior-sha256 2))))
         (if (or (CPShape $operation workspace-read-v1 2)
                 (CPShape $operation workspace-list-v1 2))
           (== (is-expr (index-atom $operation 1)) false)
           (if (CPShape $operation workspace-rollback-v1 4)
             (and (== (is-expr (index-atom $operation 1)) false)
              (and (== (is-expr (index-atom $operation 2)) false)
                   (CPShape (index-atom $operation 3)
                     expected-current-sha256 2)))
             (if (CPShape $operation workspace-version-read-v1 4)
               (and (== (is-expr (index-atom $operation 1)) false)
                (and (== (is-expr (index-atom $operation 2)) false)
                     (CPShape (index-atom $operation 3) version-sha256 2)))
               (C4ExecutableExtensionOperationValid $operation))))))))

(= (C4CapabilityForOperation $operation)
   (if (CPShape $operation informational-http-v1 3)
     (capability open-http-https no-credential informational-read-only)
     (if (CPShape $operation direct-argv-v1 4)
       (capability typed-direct-argv no-credential
         dedicated-user-owned-workspace)
       (if (or (CPShape $operation workspace-write-v1 4)
            (or (CPShape $operation workspace-read-v1 2)
             (or (CPShape $operation workspace-list-v1 2)
                 (CPShape $operation workspace-rollback-v1 4))))
         (capability versioned-owned-workspace no-credential
           reversible-local-artifact)
         (if (CPShape $operation workspace-version-read-v1 4)
           (capability versioned-owned-workspace no-credential
             historical-read-only)
           (C4ExecutableExtensionCapability $operation))))))

(= (C4CapabilityResourceForOperation $operation)
   (if (CPShape $operation informational-http-v1 3)
     (resource open-http-https)
     (if (CPShape $operation direct-argv-v1 4)
       (resource typed-direct-argv)
       (if (or (CPShape $operation workspace-write-v1 4)
            (or (CPShape $operation workspace-read-v1 2)
             (or (CPShape $operation workspace-list-v1 2)
                 (CPShape $operation workspace-rollback-v1 4))))
         (resource versioned-owned-workspace)
         (if (CPShape $operation workspace-version-read-v1 4)
           (resource versioned-owned-workspace)
           (C4ExecutableExtensionResource $operation))))))

(= (C4CapabilityRouteFromMovement $movement)
   ; PeTTa evaluates both `and` operands: shape checks must guard field access
   ; with `if`, including a lawful inquiry with no structured tool route.
   (if (if (CPShape $movement movement-formed 7)
         (== (index-atom $movement 1) inquiry) false)
     (let* (($answerability (index-atom $movement 5))
            ($o-star (if (CPShape $answerability answerability 2)
              (index-atom $answerability 1) ()))
            ($route-wrapper (if (CPShape $o-star o-star 2)
              (index-atom $o-star 1) ()))
            ($route (if (CPShape $route-wrapper consequence-route 3)
              (index-atom $route-wrapper 1) ())))
       (if (if (CPShape $route c4-capability-request-route-v1 5)
             (if (CPShape (index-atom $route 2) native-purpose 2)
               (and (!= (index-atom (index-atom $route 2) 1) "")
                (and (C4CapabilityOperationValid (index-atom $route 3))
                 (and (== (index-atom $route 4)
                      dedicated-user-open-growth-environment)
                      (== (index-atom $route-wrapper 2) non-certifying))))
               false)
             false)
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

(= (C4CapabilityProofIdentityBasis $cut-id $movement-reference)
   (capability-native-proof-v1 $cut-id $movement-reference))

(= (C4CapabilityProofId $encounter)
   (if (CPShape $encounter constitutive-encounter 7)
     (let* (($proof (ARNativeMovementProof $encounter))
            ($cut (index-atom $proof 1))
            ($movement (index-atom $proof 3)))
       (if (ARNativeMovementProofValid $proof)
         (as_native_id c4-capability-proof
           (C4CapabilityProofIdentityBasis (index-atom $cut 1)
             (ARMovementReference $cut $movement)))
         invalid-native-capability-proof))
     invalid-native-capability-encounter))

(= (C4CapabilityProofFlourishingsFromProof $proof)
   (if (ARNativeMovementProofValid $proof)
     (let* (($movement (index-atom $proof 3))
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

(= (C4CapabilityProofObjectRecordValid $object)
   (if (CPShape $object proof-object 5)
     (==
       ((== (index-atom $object 1) prolog-factorized-term-v1)
        (!= (index-atom $object 2) "")
        (CPShape (index-atom $object 3) object-sha256 2)
        (CPShape (index-atom $object 4) factor-count 2))
       (true true true true))
     false))

(= (C4CapabilityProofRecordValid $record $contact $encounter)
   (if (and (CPContactValid $contact)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($proof (ARNativeMovementProof $encounter))
            ($cut (index-atom $proof 1))
            ($movement (index-atom $proof 3)))
       (and (CPShape $record capability-native-proof-record-v2 8)
        (and (ARNativeMovementProofValid $proof)
         (==
           ((index-atom $record 1)
            (index-atom $record 2)
            (index-atom $record 3)
            (index-atom $record 4)
            (C4CapabilityProofObjectRecordValid (index-atom $record 5))
            (index-atom $record 6)
            (index-atom $record 7))
           ((C4CapabilityProofId $encounter)
            (CPContactScope $contact)
            (index-atom $cut 1)
            (ARMovementReference $cut $movement)
            true
            (proof-flourishings
              (C4CapabilityProofFlourishingsFromProof $proof))
            persisted-before-capability)))))
     false))

(= (C4CapabilityRequestDescriptor $contact $encounter $proof-record)
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
            ($movement-reference (ARMovementReference $cut $movement))
            ($deadline 30)
            ($maximum-bytes 32768)
            ($request-id (as_native_id c4-capability-request
              (C4CapabilityRequestIdentityBasis (index-atom $contact 1)
                $movement-reference $operation $deadline $maximum-bytes))))
       (if (and (C4CapabilityOperationValid $operation)
                (C4CapabilityProofRecordValid $proof-record $contact
                  $encounter))
         (capability-request-descriptor-v2 $request-id $request-id
           (CPContactScope $contact)
           (source-contact (index-atom $contact 1))
           (source-movement $movement-reference)
           $purpose
           (exact-operation $operation)
           (limits (deadline-seconds $deadline)
             (maximum-body-bytes $maximum-bytes))
           (native-proof-record $proof-record)
           (C4CapabilityForOperation $operation)
           prepared)
         (capability-request-held (index-atom $contact 1)
           no-proof-bound-exact-operation)))
     (capability-request-held unknown-contact malformed-contact-or-encounter)))

(= (C4CapabilityRequestDescriptorValid $descriptor $contact $encounter)
   (if (CPShape $descriptor capability-request-descriptor-v2 12)
     (let $proof-record (index-atom (index-atom $descriptor 9) 1)
       (== $descriptor (C4CapabilityRequestDescriptor $contact $encounter
         $proof-record)))
     false))

(= (C4CapabilityRequestDescriptorStructuralValid $descriptor)
   (if (CPShape $descriptor capability-request-descriptor-v2 12)
     (let* (($record-wrapper (index-atom $descriptor 9))
            ($record (if (CPShape $record-wrapper native-proof-record 2)
              (index-atom $record-wrapper 1) ())))
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
          (CPShape $record capability-native-proof-record-v2 8)
          (== (index-atom $descriptor 3) (index-atom $record 2))
          (== (index-atom $descriptor 4)
            (source-contact
              (index-atom (index-atom $record 3) 1)))
          (== (index-atom $descriptor 5)
            (source-movement (index-atom $record 4)))
          (C4CapabilityProofObjectRecordValid (index-atom $record 5))
          (CPShape (index-atom $record 6) proof-flourishings 2)
          (== (index-atom $record 7) persisted-before-capability)
          (== (index-atom $descriptor 10)
            (C4CapabilityForOperation
              (index-atom (index-atom $descriptor 7) 1)))
          (== (index-atom $descriptor 11) prepared))
         (true true true true true true true true true true true true true
           true true true true true)))
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

(= (C4WorkspaceVersionOutcomeValid $outcome $operation)
   (if (CPShape $outcome workspace-version-result-v1 8)
     (and (CPHas (index-atom $outcome 1) (read unavailable) 0)
      (and (== (index-atom $outcome 2) (path (index-atom $operation 2)))
       (and (== (index-atom $outcome 3)
                (source-request (index-atom $operation 1)))
        (and (CPShape (index-atom $outcome 4) contents 3)
         (and (== (index-atom (index-atom $outcome 4) 1)
                  (index-atom (index-atom $operation 3) 1))
          (and (== (index-atom $outcome 5)
                   (origin workspace-write-proposal-content))
           (and (== (index-atom $outcome 6)
                    historical-version-not-current-file-state)
                (== (index-atom $outcome 7)
                    proof-bound-source-not-truth-or-write-authority))))))))
     false))

(= (C4CapabilityObservationV2OutcomeValid $outcome $operation)
   (if (CPShape $operation informational-http-v1 3)
     (and (CPShape $outcome http-result-v1 5)
      (and (CPHas (index-atom $outcome 1)
             (eof truncated deadline failed) 0)
       (and (CPShape (index-atom $outcome 2) http-status 2)
        (and (CPShape (index-atom $outcome 3) body 3)
             (CPShape (index-atom $outcome 4) redirect-location 2)))))
    (if (CPShape $operation direct-argv-v1 4)
     (and (CPShape $outcome process-result-v1 6)
      (and (CPHas (index-atom $outcome 1)
             (eof truncated deadline failed) 0)
           (CPShape (index-atom $outcome 2) exit-code 2)))
     (if (or (CPShape $operation workspace-write-v1 4)
          (or (CPShape $operation workspace-read-v1 2)
           (or (CPShape $operation workspace-list-v1 2)
               (CPShape $operation workspace-rollback-v1 4))))
       (and (CPShape $outcome workspace-result-v1 6)
            (CPHas (index-atom $outcome 1)
              (written read listed rolled-back conflict failed) 0))
       (if (CPShape $operation workspace-version-read-v1 4)
         (C4WorkspaceVersionOutcomeValid $outcome $operation)
         (C4ExecutableExtensionOutcomeValid $outcome $operation))))))

(= (C4CapabilityObservationV2Valid $observation $descriptor)
   (if (and (CPShape $observation capability-observation-v2 9)
            (C4CapabilityRequestDescriptorStructuralValid $descriptor))
     (let* (($operation (index-atom (index-atom $descriptor 7) 1))
            ($outcome (index-atom $observation 5)))
       (==
         ((index-atom $observation 1) (index-atom $observation 2)
          (CPShape (index-atom $observation 3)
            request-descriptor-sha256 2)
          (index-atom $observation 4)
          (C4CapabilityObservationV2OutcomeValid $outcome $operation)
          (CPShape (index-atom $observation 6) elapsed-milliseconds 2)
          (CPShape (index-atom $observation 7) failure 2)
          (index-atom $observation 8))
         ((index-atom $descriptor 1) (index-atom $descriptor 3)
          true (C4CapabilityResourceForOperation $operation) true true true
          mechanical-observation-no-meaning-no-movement-authority)))
     false))

(= (C4AnyCapabilityObservationValid $observation $descriptor)
   (or (C4CapabilityObservationValid $observation $descriptor)
       (C4CapabilityObservationV2Valid $observation $descriptor)))

(= (C4CapabilityObservationParticipant $descriptor $observation)
   (if (C4AnyCapabilityObservationValid $observation $descriptor)
     (participant-contribution
       (c4-open-growth-observation-participation
         (index-atom $observation 1))
       tool (index-atom $observation 2)
       (lineage miter-open-growth-environment-v1
         (index-atom $observation 3))
       (participant-relation-claim open-growth-request-returned unresolved
       (if (CPShape $observation capability-observation-v1 11)
         (c4-open-growth-observation-evidence-v1
             (request-descriptor $descriptor)
             (index-atom $observation 4) (index-atom $observation 5)
             (index-atom $observation 6) (index-atom $observation 7)
             (index-atom $observation 8) (index-atom $observation 9))
         (c4-open-growth-observation-evidence-v2
             (request-descriptor $descriptor)
             (index-atom $observation 4) (index-atom $observation 5)
             (index-atom $observation 6) (index-atom $observation 7))))
       unresolved no-contact-no-movement-authority)
     (participant-unresolved unknown-capability-observation
       carrier-schema-or-provenance-invalid)))

; Historical source participation is not a fresh returned operation. Its exact
; saved descriptor/observation must still be checked at the mechanical reader.
; Keeping a distinct relation prevents old writes from becoming new requests.
(= (C4WorkspaceVersionSourceParticipant $descriptor $observation)
   (if (C4CapabilityObservationV2Valid $observation $descriptor)
     (let* (($operation (index-atom (index-atom $descriptor 7) 1))
            ($outcome (index-atom $observation 5)))
       (if (and (CPShape $operation workspace-write-v1 4)
             (and (CPShape $outcome workspace-result-v1 6)
              (and (== (index-atom $outcome 1) written)
                   (== (index-atom $observation 7) (failure none)))))
         (participant-contribution
           (c4-workspace-version-source (index-atom $descriptor 1))
           tool (index-atom $descriptor 3)
           (lineage miter-open-growth-environment-v1
             (index-atom $observation 3))
           (participant-relation-claim workspace-version-source unresolved
             (c4-workspace-version-source-v1 $descriptor $observation
               historical-only-no-current-file-or-write-authority))
           unresolved no-contact-no-movement-authority)
         (participant-unresolved unknown-workspace-version
           no-completed-write-source)))
     (participant-unresolved unknown-workspace-version
       carrier-schema-or-provenance-invalid)))

; Exact historical index in the ordinary checkpoint, never a mutable head.
; Only incorporated returned writes enter; unrelated contacts cannot replace
; another identity. Source lookup does not traverse earlier proof graphs.
(= (C4WorkspaceVersionRows $scope $id)
   (collapse (match &assistant_history
     (assistant-history artifact-version $id $scope $record) $record)))

(= (C4WorkspaceVersionRecordValid $record)
   (if (CPShape $record c4-workspace-version-record-v1 3)
     (CPShape (C4WorkspaceVersionSourceParticipant
       (index-atom $record 1) (index-atom $record 2))
       participant-contribution 8)
     false))

(= (C4WorkspaceVersionHistoryValid $row)
   (if (CPShape $row assistant-history 5)
     (let $record (index-atom $row 4)
       (if (C4WorkspaceVersionRecordValid $record)
         (and (== (index-atom $row 1) artifact-version)
          (and (== (index-atom $row 2)
                   (index-atom (index-atom $record 1) 1))
               (== (index-atom $row 3)
                   (index-atom (index-atom $record 1) 3))))
         false))
     false))

(= (C4WorkspaceVersionFromParticipant $participant $scope)
   (if (CPShape $participant participant-contribution 8)
     (let* (($claim (index-atom $participant 5))
            ($evidence (if (CPShape $claim participant-relation-claim 4)
              (index-atom $claim 3) ())))
       (if (and (== (index-atom $participant 2) tool)
             (and (== (index-atom $participant 3) $scope)
              (and (CPShape (index-atom $participant 4) lineage 3)
               (if (CPShape $evidence c4-open-growth-observation-evidence-v2 6)
                 (if (CPShape (index-atom $evidence 1) request-descriptor 2)
                   (C4CapabilityRequestDescriptorStructuralValid
                     (index-atom (index-atom $evidence 1) 1)) false)
                 false))))
         (let* (($descriptor (index-atom (index-atom $evidence 1) 1))
                ($observation (capability-observation-v2
                  (index-atom $descriptor 1) $scope
                  (index-atom (index-atom $participant 4) 2)
                  (index-atom $evidence 2) (index-atom $evidence 3)
                  (index-atom $evidence 4) (index-atom $evidence 5)
                  mechanical-observation-no-meaning-no-movement-authority))
                ($expected (C4CapabilityObservationParticipant
                  $descriptor $observation))
                ($record (c4-workspace-version-record-v1
                  $descriptor $observation)))
           (if (and (== $participant $expected)
                    (C4WorkspaceVersionRecordValid $record))
             $record no-workspace-version))
         no-workspace-version))
     no-workspace-version))

(= (C4WorkspaceVersionRecordsAt $participants $scope $i)
   (if (< $i (size-atom $participants))
     (let $record (C4WorkspaceVersionFromParticipant
       (index-atom $participants $i) $scope)
       (if (== $record no-workspace-version)
         (C4WorkspaceVersionRecordsAt $participants $scope (+ $i 1))
         (cons-atom $record
           (C4WorkspaceVersionRecordsAt $participants $scope (+ $i 1)))))
     ()))

(= (C4WorkspaceVersionPeersCompatible $record $records $i)
   (if (< $i (size-atom $records))
     (let $other (index-atom $records $i)
       (and (if (== (index-atom (index-atom $record 1) 1)
                    (index-atom (index-atom $other 1) 1))
              (== $record $other) true)
            (C4WorkspaceVersionPeersCompatible $record $records (+ $i 1))))
     true))

(= (C4WorkspaceVersionsCompatible $records $scope $i)
   (if (< $i (size-atom $records))
     (let* (($record (index-atom $records $i))
            ($id (index-atom (index-atom $record 1) 1))
            ($rows (collapse (match &assistant_history
              (assistant-history artifact-version $id $other-scope $other)
              ($other-scope $other)))))
       (and (or (== $rows ()) (== $rows (($scope $record))))
        (and (C4WorkspaceVersionPeersCompatible $record $records (+ $i 1))
             (C4WorkspaceVersionsCompatible $records $scope (+ $i 1)))))
     true))

(= (C4RecordWorkspaceVersions $records $scope $i)
   (if (< $i (size-atom $records))
     (let* (($record (index-atom $records $i))
            ($stored (ARRecord artifact-version
              (index-atom (index-atom $record 1) 1) $scope $record)))
       (C4RecordWorkspaceVersions $records $scope (+ $i 1)))
     workspace-versions-recorded))

(= (C4WorkspaceVersionSourceForOperation $scope $operation)
   (if (CPShape $operation workspace-version-read-v1 4)
     (let $rows (C4WorkspaceVersionRows $scope (index-atom $operation 1))
       (if (== (size-atom $rows) 1)
         (let $record (index-atom $rows 0)
           (C4WorkspaceVersionSourceParticipant
             (index-atom $record 1) (index-atom $record 2)))
         (participant-unresolved unknown-workspace-version
           exact-source-unavailable-not-absence)))
     (participant-unresolved unknown-workspace-version
       not-a-version-read)))

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

(= (C4ReturnedProposalSourceValid $source)
   (if (CPShape $source c4-returned-inquiry-source-v1 5)
     (and (CPShape (index-atom $source 1) native-proof-reference 5)
       (and (== (is-expr (index-atom $source 2)) false)
         (and (CPShape (index-atom $source 3) question-reference 3)
              (CPShape (index-atom $source 4) raw-sha256 2)))) false))

(= (C4CapabilityProposalEvidenceValid $evidence)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (and (CPShape (index-atom $evidence 1) question-reference 3)
      (and (CPShape (index-atom $evidence 3) fact9-roles 2)
       (and (CPShape (index-atom $evidence 4) flourishing-values 2)
        (and (> (size-atom (index-atom (index-atom $evidence 3) 1)) 0)
         (and (> (size-atom (index-atom (index-atom $evidence 4) 1)) 0)
          (and (!= (index-atom $evidence 5) "")
               (C4CapabilityOperationValid (index-atom $evidence 6))))))))
     (if (CPShape $evidence c4-capability-proposal-evidence-v2 5)
       (and (CPShape (index-atom $evidence 1)
              source-capability-proposal 3)
        (and (!= (index-atom $evidence 2) "")
             (C4CapabilityOperationValid (index-atom $evidence 3))))
       (if (CPShape $evidence c4-capability-proposal-evidence-v3 8)
         (and (C4ReturnedProposalSourceValid (index-atom $evidence 1))
           (and (== (index-atom (index-atom $evidence 1) 3)
                    (index-atom $evidence 2))
             (C4CapabilityProposalEvidenceValid
               (c4-capability-proposal-evidence-v1
                 (index-atom $evidence 2) (index-atom $evidence 3)
                 (index-atom $evidence 4) (index-atom $evidence 5)
                 (index-atom $evidence 6) (index-atom $evidence 7)))))
         false))))

(= (C4CapabilityProposalMovementId $evidence)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (index-atom $evidence 2)
     (if (or (CPShape $evidence c4-capability-proposal-evidence-v2 5)
             (CPShape $evidence c4-capability-proposal-evidence-v3 8))
       (as_native_id c4-capability-proposal $evidence)
       malformed-capability-proposal)))

(= (C4CapabilityProposalPurpose $evidence)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (index-atom $evidence 5)
     (if (CPShape $evidence c4-capability-proposal-evidence-v2 5)
       (index-atom $evidence 2)
       (if (CPShape $evidence c4-capability-proposal-evidence-v3 8)
         (index-atom $evidence 6) ""))))

(= (C4CapabilityProposalOperation $evidence)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (index-atom $evidence 6)
     (if (CPShape $evidence c4-capability-proposal-evidence-v2 5)
       (index-atom $evidence 3)
       (if (CPShape $evidence c4-capability-proposal-evidence-v3 8)
         (index-atom $evidence 7) malformed-capability-operation))))

(= (C4CapabilityProposalFlourishings $evidence $flourishing)
   (if (CPShape $evidence c4-capability-proposal-evidence-v1 7)
     (index-atom (index-atom $evidence 4) 1)
     (if (CPShape $evidence c4-capability-proposal-evidence-v3 8)
       (index-atom (index-atom $evidence 5) 1)
       (CPBeneficialFlourishingValues $flourishing))))

(= (C4CapabilityProposalPossibilitiesAt $claims $cut $flourishing $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (and (CPHas (index-atom $claim 2) (model human tool) 0)
             (and (== (index-atom $claim 4) unresolved)
                  (C4CapabilityProposalEvidenceValid $evidence)))
         (cons-atom
           (possible-movement (C4CapabilityProposalMovementId $evidence)
             inquiry
             (CPNativeRequirementRelations $cut)
             (CPNativeRequirementDistinctions $cut)
             (CPNativeRequirementInterfaces $cut)
             (C4CapabilityProposalFlourishings $evidence $flourishing)
             (consequence-route
               (c4-capability-request-route-v1
                 (C4CapabilityProposalMovementId $evidence)
                 (native-purpose (C4CapabilityProposalPurpose $evidence))
                 (C4CapabilityProposalOperation $evidence)
                 dedicated-user-open-growth-environment)
               non-certifying)
             l2425-supported)
           (C4CapabilityProposalPossibilitiesAt $claims $cut $flourishing
             (+ $i 1)))
         (C4CapabilityProposalPossibilitiesAt $claims $cut $flourishing
           (+ $i 1))))
     ()))

(= (C4CapabilityProposalPossibilities $cut $flourishing
      $participant-relations)
   (if (C4EnvironmentAvailableInRelations $participant-relations)
     (C4CapabilityProposalPossibilitiesAt
       (C4CapabilityProposalClaims $participant-relations) $cut
       $flourishing 0)
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
     (if (CPShape $evidence c4-open-growth-observation-evidence-v2 6)
       (let* (($wrapper (index-atom $evidence 1))
              ($descriptor (if (CPShape $wrapper request-descriptor 2)
                (index-atom $wrapper 1) ()))
              ($operation (if
                (C4CapabilityRequestDescriptorStructuralValid $descriptor)
                (index-atom (index-atom $descriptor 7) 1) ())))
         (and (C4CapabilityRequestDescriptorStructuralValid $descriptor)
          (and (== (index-atom $evidence 2)
                 (C4CapabilityResourceForOperation $operation))
           (and (C4CapabilityObservationV2OutcomeValid
                  (index-atom $evidence 3) $operation)
            (and (CPShape (index-atom $evidence 4)
                   elapsed-milliseconds 2)
                 (CPShape (index-atom $evidence 5) failure 2))))))
       false)))

(= (C4CapabilityProofFlourishings $descriptor)
   (if (C4CapabilityRequestDescriptorStructuralValid $descriptor)
     (let* (($record (index-atom (index-atom $descriptor 9) 1))
            ($wrapper (index-atom $record 6)))
       (if (CPShape $wrapper proof-flourishings 2)
         (index-atom $wrapper 1) ()))
     ()))

(= (C4CapabilityReturnedRoute $request-id $evidence)
   (if (CPShape $evidence c4-open-growth-observation-evidence-v1 8)
     (returned-informational-contact $request-id
       (index-atom $evidence 2) (index-atom $evidence 3)
       (index-atom $evidence 4) (index-atom $evidence 5)
       (index-atom $evidence 7))
     (if (CPShape $evidence c4-open-growth-observation-evidence-v2 6)
       (returned-capability-contact $request-id
         (index-atom $evidence 2) (index-atom $evidence 3)
         (index-atom $evidence 4) (index-atom $evidence 5))
       returned-capability-contact-invalid)))

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
                 (C4CapabilityReturnedRoute $request-id $evidence)
                 non-certifying)
               l2425-supported)
             (C4CapabilityResultPossibilitiesAt $claims $cut (+ $i 1))))
         (C4CapabilityResultPossibilitiesAt $claims $cut (+ $i 1))))
     ()))

(= (C4CapabilityResultPossibilities $cut $participant-relations)
   (if (CPShape $participant-relations participant-relation-organization 2)
    (let* (($returned (C4CapabilityReturnedClaims $participant-relations))
          ($redirects (C4HTTPRedirectPossibilitiesAt
            (C4HTTPRedirectClaimsAt
              (index-atom $participant-relations 1) 0)
            $returned $cut 0)))
     ; A sourced redirect inquiry refines its returned-contact inquiry, not
     ; the original semantic proposal. All prior observations remain in the
     ; participant organization and the fresh movement proof.
     (if (> (size-atom $redirects) 0) $redirects
       (C4CapabilityResultPossibilitiesAt
         (C4CurrentReturnedClaimsAt $returned $returned 0) $cut 0)))
    ()))

; A completed redirect continues the exact inquiry that produced it. Its
; predecessor remains evidence in the participant organization, but is not a
; second independent present result. Only the successor's proof-bound movement
; identity, same contact/scope and exact redirected operation establish this
; relation. Equal URLs, order, status preference or model opinion do not.
(= (C4ReturnedRedirectContinuation $parent $child)
   (if (and (C4CapabilityReturnedEvidenceValid $parent)
            (C4CapabilityReturnedEvidenceValid $child))
     (if (CPShape $parent c4-open-growth-observation-evidence-v2 6)
       (let* (($before (index-atom (index-atom $parent 1) 1))
              ($after (index-atom (index-atom $child 1) 1))
              ($operation (index-atom (index-atom $before 7) 1))
              ($outcome (index-atom $parent 3))
              ($movement (index-atom (index-atom $after 5) 1)))
         (if (and (CPShape $operation informational-http-v1 3)
                  (CPShape $outcome http-result-v1 5))
           (and (CPHas (index-atom $outcome 1) (eof truncated) 0)
            (and (CPHas (index-atom (index-atom $outcome 2) 1)
                   (301 302 303 307 308) 0)
             (and (== (index-atom $parent 5) (failure none))
              (and (== (index-atom $before 3) (index-atom $after 3))
               (and (== (index-atom $before 4) (index-atom $after 4))
                (and (== (index-atom $after 7)
                       (exact-operation (informational-http-v1
                         (index-atom $operation 1)
                         (index-atom (index-atom $outcome 4) 1))))
                 (if (CPShape $movement movement-reference 5)
                   (== ((index-atom $movement 2) (index-atom $movement 3)
                         (index-atom $movement 4))
                       (formed inquiry
                         (c4-http-redirect-request (index-atom $before 1))))
                   false)))))))
           false))
       false)
     false))

(= (C4ReturnedContinuedAt $parent $claims $i)
   (if (< $i (size-atom $claims))
     (let $claim (index-atom $claims $i)
       (if (and (== (index-atom $claim 2) tool)
                (== (index-atom $claim 4) unresolved))
         (if (C4ReturnedRedirectContinuation $parent (index-atom $claim 6))
           true (C4ReturnedContinuedAt $parent $claims (+ $i 1)))
         (C4ReturnedContinuedAt $parent $claims (+ $i 1))))
     false))

(= (C4CurrentReturnedClaimsAt $claims $all $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($tail (C4CurrentReturnedClaimsAt $claims $all (+ $i 1))))
       (if (C4ReturnedContinuedAt (index-atom $claim 6) $all 0)
         $tail (cons-atom $claim $tail)))
     ()))

(= (C4HTTPRedirectOperation $descriptor $observation)
   (if (C4CapabilityObservationV2Valid $observation $descriptor)
     (let* (($operation (index-atom (index-atom $descriptor 7) 1))
            ($outcome (index-atom $observation 5)))
       (if (CPShape $operation informational-http-v1 3)
         (if (and (CPHas (index-atom $outcome 1) (eof truncated) 0)
              (and (CPHas (index-atom (index-atom $outcome 2) 1)
                     (301 302 303 307 308) 0)
               (and (== (index-atom $observation 7) (failure none))
                (and (!= (index-atom (index-atom $outcome 4) 1) none)
                 (== (is-expr
                   (index-atom (index-atom $outcome 4) 1)) false)))))
           (informational-http-v1 (index-atom $operation 1)
             (index-atom (index-atom $outcome 4) 1))
           no-http-redirect)
         no-http-redirect))
     no-http-redirect))

(= (C4HTTPRedirectParticipant $descriptor $observation)
   (participant-contribution
     (c4-http-redirect-participation (index-atom $descriptor 1))
     tool (index-atom $descriptor 3)
     (lineage miter-open-growth-environment-v1
       (index-atom $observation 3))
     (participant-relation-claim open-growth-http-redirect-proposal unresolved
       (c4-http-redirect-proposal-v1 $descriptor $observation))
     unresolved no-contact-no-movement-authority))

(= (C4HTTPRedirectClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (CPShape $relation participant-proposed-relation 4)
         (if (== (index-atom $relation 1) open-growth-http-redirect-proposal)
           (index-atom $relation 3)
           (C4HTTPRedirectClaimsAt $relations (+ $i 1)))
         (C4HTTPRedirectClaimsAt $relations (+ $i 1))))
     ()))

(= (C4HTTPReturnedOperationAt $claims $operation $i)
   (if (< $i (size-atom $claims))
     (let $evidence (index-atom (index-atom $claims $i) 6)
       (if (C4CapabilityReturnedEvidenceValid $evidence)
         (if (== (index-atom
               (index-atom (index-atom $evidence 1) 1) 7)
               (exact-operation $operation))
           true (C4HTTPReturnedOperationAt $claims $operation (+ $i 1)))
         (C4HTTPReturnedOperationAt $claims $operation (+ $i 1))))
     false))

(= (C4HTTPReturnedEvidenceAt $claims $evidence $i)
   (if (< $i (size-atom $claims))
     (if (== (index-atom (index-atom $claims $i) 6) $evidence)
       true (C4HTTPReturnedEvidenceAt $claims $evidence (+ $i 1)))
     false))

(= (C4HTTPRedirectPossibilitiesAt $claims $returned $cut $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (index-atom $claim 6))
            ($tail (C4HTTPRedirectPossibilitiesAt
              $claims $returned $cut (+ $i 1))))
       (if (CPShape $evidence c4-http-redirect-proposal-v1 3)
         (let* (($descriptor (index-atom $evidence 1))
                ($observation (index-atom $evidence 2))
                ($operation (C4HTTPRedirectOperation $descriptor $observation)))
           (if (C4CapabilityOperationValid $operation)
             (let $source (C4CapabilityObservationParticipant
               $descriptor $observation)
               (if (and (== (index-atom $claim 2) tool)
                    (and (== (index-atom $claim 4) unresolved)
                     (and (C4HTTPReturnedEvidenceAt $returned
                       (index-atom (index-atom $source 5) 3) 0)
                      (== (C4HTTPReturnedOperationAt $returned
                        $operation 0) false))))
                 (cons-atom
                   (possible-movement
                     (c4-http-redirect-request (index-atom $descriptor 1))
                     inquiry
                     (CPNativeRequirementRelations $cut)
                     (CPNativeRequirementDistinctions $cut)
                     (CPNativeRequirementInterfaces $cut)
                     (C4CapabilityProofFlourishings $descriptor)
                     (consequence-route
                       (c4-capability-request-route-v1
                         (c4-http-redirect-request (index-atom $descriptor 1))
                         (index-atom $descriptor 6) $operation
                         dedicated-user-open-growth-environment)
                       non-certifying)
                     l2425-supported)
                   $tail)
                 $tail))
             $tail))
         $tail))
     ()))

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
     (if (C4CapabilityObservationV2Valid $observation $descriptor)
       (capability-contact-context-v2
         (request-id (index-atom $descriptor 1))
         (index-atom $descriptor 5) (index-atom $descriptor 6)
         (index-atom $descriptor 7)
         (index-atom $observation 4) (index-atom $observation 5)
         (index-atom $observation 6) (index-atom $observation 7)
         untrusted-returned-contact-no-authority)
       (capability-contact-context-v1 no-capability-request
         no-returned-capability-contact))))

; A newly supplied proposal is a prospective opening, not a replacement for
; every unresolved route on the encounter. A V2 source proposal has its own
; source identity; V1 readings are contrasts within one semantic family, not
; independently issued requests. Record the exact source so older
; checkpoints keep their original formation and new openings cannot be hidden
; by a category-wide recovery/result preference. This grants consideration,
; never execution: ordinary M25 formation and the proof-bound writer remain.
(= (C4ContinuationProposalValid $participant $scope)
   (if (CPShape $participant participant-contribution 8)
     (if (CPShape (index-atom $participant 5) participant-relation-claim 4)
       (let $claim (index-atom $participant 5)
         (==
           ((CPHas (index-atom $participant 2) (model human tool) 0)
            (== (index-atom $participant 3) $scope)
            (== (index-atom $participant 7) no-contact-no-movement-authority)
            (== (index-atom $claim 1) open-growth-capability-request-proposal)
            (== (index-atom $claim 2) unresolved)
            (or (CPShape (index-atom $claim 3) c4-capability-proposal-evidence-v2 5)
                (CPShape (index-atom $claim 3) c4-capability-proposal-evidence-v3 8))
            (C4CapabilityProposalEvidenceValid (index-atom $claim 3)))
           (true true true true true true true))) false)
     false))

(= (C4ContinuationOpeningParticipantsAt $contact $additional $i)
   (if (< $i (size-atom $additional))
     (let* (($proposal (index-atom $additional $i))
            ($rest (C4ContinuationOpeningParticipantsAt $contact $additional (+ $i 1))))
       (if (if (C4ContinuationProposalValid $proposal (CPContactScope $contact))
             (== (CPHas $proposal (CPParticipants $contact) 0) false) false)
         (cons-atom
           (participant-contribution
             (as_native_id c4-continuation-opening
               ((index-atom $contact 1) $proposal))
             native-authority (CPContactScope $contact)
             (lineage c4 prospective-candidate-participation (index-atom $proposal 1))
             (participant-relation-claim continuation-opening unresolved
               (c4-continuation-opening-v1 (index-atom $contact 1) $proposal))
             candidate no-contact-no-movement-authority)
           $rest)
         $rest)) ()))

(= (C4ContinuationOpeningClaimsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (if (CPShape $relation participant-proposed-relation 4)
             (== (index-atom $relation 1) continuation-opening) false)
         (index-atom $relation 3)
         (C4ContinuationOpeningClaimsAt $relations (+ $i 1)))) ()))

(= (C4ContinuationProposalClaim $proposal)
   (participant-relation-evidence (index-atom $proposal 1)
     (index-atom $proposal 2) (index-atom $proposal 4)
     (index-atom (index-atom $proposal 5) 2) (index-atom $proposal 6)
     (index-atom (index-atom $proposal 5) 3)))

; Any correlated returned outcome retires this exact execution opening,
; including uncertainty. Failure does not license replay. Equal operations
; alone do not establish correlation; source, scope and movement must agree.
(= (C4ContinuationHasReturnAt $claims $cut $id $operation $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($evidence (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ())))
       (if (if (C4CapabilityReturnedEvidenceValid $evidence)
             (let* (($descriptor (index-atom (index-atom $evidence 1) 1))
                    ($movement (index-atom (index-atom $descriptor 5) 1)))
               (if (CPShape $movement movement-reference 5)
                 (==
                   ((index-atom $claim 2) (index-atom $descriptor 3)
                    (index-atom $descriptor 4) (index-atom $movement 1)
                    (index-atom $movement 2) (index-atom $movement 3)
                    (index-atom $movement 4) (index-atom $descriptor 7))
                   (tool (index-atom $cut 3)
                    (source-contact (index-atom (index-atom $cut 1) 1))
                    (index-atom $cut 1) formed inquiry $id (exact-operation $operation)))
                 false)) false)
         true (C4ContinuationHasReturnAt $claims $cut $id $operation (+ $i 1)))) false))

(= (C4ContinuationReturnedClaimsAt $claims $cut $id $operation $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($rest (C4ContinuationReturnedClaimsAt $claims $cut $id $operation (+ $i 1))))
       (if (C4ContinuationHasReturnAt ($claim) $cut $id $operation 0)
         (cons-atom $claim $rest) $rest)) ()))

(= (C4ContinuationPossibilitiesAt $claims $cut $flourishing $relations $i)
   (if (< $i (size-atom $claims))
     (let* (($claim (index-atom $claims $i))
            ($opening (if (CPShape $claim participant-relation-evidence 7)
              (index-atom $claim 6) ()))
            ($rest (C4ContinuationPossibilitiesAt $claims $cut $flourishing $relations (+ $i 1))))
       (if (if (CPShape $opening c4-continuation-opening-v1 3)
             (and (== (index-atom $claim 2) native-authority)
               (and (== (index-atom $opening 1) (index-atom (index-atom $cut 1) 1))
                    (C4ContinuationProposalValid (index-atom $opening 2) (index-atom $cut 3)))) false)
         (let* (($proposal (index-atom $opening 2))
                ($source (C4ContinuationProposalClaim $proposal))
                ($evidence (index-atom $source 6))
                ($returned (C4ContinuationReturnedClaimsAt (C4CapabilityReturnedClaims $relations)
                  $cut (C4CapabilityProposalMovementId $evidence)
                  (C4CapabilityProposalOperation $evidence) 0)))
           (if (CPHas $source (C4CapabilityProposalClaims $relations) 0)
             (CPListAppend
               (if (> (size-atom $returned) 0)
                 (C4CapabilityResultPossibilitiesAt $returned $cut 0)
                 (if (C4EnvironmentAvailableInRelations $relations)
                   (C4CapabilityProposalPossibilitiesAt ($source) $cut $flourishing 0) ()))
               $rest)
             $rest))
         $rest)) ()))

(= (C4ContinuationPossibilities $cut $flourishing $relations)
   (if (CPShape $relations participant-relation-organization 2)
     (C4ContinuationPossibilitiesAt
       (C4ContinuationOpeningClaimsAt (index-atom $relations 1) 0)
       $cut $flourishing $relations 0) ()))

; Exact duplicates represent one possibility. Different openings stay live;
; this function neither ranks them nor chooses the first for enactment.
(= (C4ContinuationJoinAt $base $openings $i)
   (if (< $i (size-atom $openings))
     (let $opening (index-atom $openings $i)
       (C4ContinuationJoinAt
         (if (CPHas $opening $base 0) $base
           (CPListAppend $base ($opening))) $openings (+ $i 1))) $base))

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
     (if (CPShape $context capability-contact-context-v2 10)
       (and (CPShape (index-atom $context 1) request-id 2)
        (and (CPShape (index-atom $context 2) source-movement 2)
         (and (CPShape (index-atom $context 3) native-purpose 2)
          (and (CPShape (index-atom $context 4) exact-operation 2)
           (and (CPShape (index-atom $context 5) resource 2)
            (and (CPShape (index-atom $context 7)
                   elapsed-milliseconds 2)
             (and (CPShape (index-atom $context 8) failure 2)
                  (== (index-atom $context 9)
                    untrusted-returned-contact-no-authority))))))))
       (== $context (capability-contact-context-v1 no-capability-request
         no-returned-capability-contact)))))
