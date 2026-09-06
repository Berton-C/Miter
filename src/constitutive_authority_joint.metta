; Constitutive authority joint.
; M24 and M26.0 participate before native possibility formation. They are not
; post-hoc verdicts and do not choose a behavioral response.

(= (CP2PayloadReference $contact)
   (if (CPShape $contact contact-v2 11)
     (index-atom $contact 8)
     (legacy-contact-reference (index-atom $contact 1))))

(= (CP2M24Contact $contact)
   (if (and (CPContactValid $contact)
            (== (index-atom $contact 2) human-contact))
     (let* (($id (index-atom $contact 1))
            ($occurrence (index-atom $contact 6))
            ($proto (index-atom $contact 7))
            ($payload (CP2PayloadReference $contact))
            ($parents (CPContactParents $contact))
            ($route-id (route-of $id))
            ($seal (contact-seal $id $occurrence $route-id $payload))
            ($represented (source principal audience project occurrence proto
              payload-reference configuration))
            ($omitted (unrepresented-actuality)))
       (m24-contact $id
         (event $occurrence $proto $parents)
         (governed-route $route-id human-contact $payload
           (source principal audience project occurrence proto payload-reference configuration)
           authorized-before-payload-cognition)
         $seal
         (raw-field
           (source principal audience project occurrence proto payload-reference
             configuration unrepresented-actuality)
           ((raw-relation principal audience) (raw-relation project occurrence)
             (raw-relation occurrence configuration))
           $omitted)
         (partial-frame (frame-of $id) $represented $omitted
           (CPContactScope $contact) carrier-structured finite-no-actuality-reconstruction
           $occurrence (prov-contact $seal)
           (domain-witness $represented $omitted partial-and-explicit))
         (standing (prov-contact $seal) contact-warrant $parents () fresh-current-cycle)
         ((derivation (derivation-of $id) testimony-external-input human-contact
            $id (prov-contact $seal)))))
     (m24-contact-unresolved non-human-or-malformed-contact $contact)))

(= (CP2M260OrganizationFor $id $occurrence $payload $scope)
   (M260OccurrenceOrganizationFor $id $occurrence $payload $scope))

(= (CP2M260Organization $contact)
   (if (CPContactValid $contact)
     (CP2M260OrganizationFor (index-atom $contact 1)
       (index-atom $contact 6) (CP2PayloadReference $contact)
       (CPContactScope $contact))
     (m260-occurrence-unresolved malformed-contact $contact)))

; The supported runtime must be able to re-form the same M26.0 organization
; from its persisted cut, including after consequence and restart.  Cut
; projection changes the local boundary while retaining the root contact frame;
; neither operation creates a second occurrence ontology.
(= (CP2RootContactFrame $frame)
   (M260RootContactFrame $frame))

(= (CP2RootPayloadReference $frame)
   (M260RootPayloadReference $frame))

(= (CP2M260OrganizationFromCut $cut)
   (M260OccurrenceOrganizationFromCut $cut))

(= (CP2PreservedRelationsAt $rows $i $out)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (CPShape $row preserves 3)
         (let $relation (index-atom $row 2)
           (if (CPHas $relation $out 0)
             (CP2PreservedRelationsAt $rows (+ $i 1) $out)
             (CP2PreservedRelationsAt $rows (+ $i 1)
               (cons-atom $relation $out))))
         (CP2PreservedRelationsAt $rows (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (CP2PreservedRelations $m260)
   (CP2PreservedRelationsAt (index-atom $m260 10) 0 ()))

; This is the authority-required pre-movement occurrence organization. It is
; built from the lawful M26.0 structure and enters participant evidence before
; possibility formation. It is not a diagnostic appended after selection.
(= (CP2M260PreMovementOrganization $m260)
   (if (M260OrganizationValid $m260)
     (let* (($occurrence (index-atom $m260 1))
            ($parts (index-atom $m260 2))
            ($contact-part (index-atom (index-atom $parts 0) 1))
            ($frame-part (index-atom (index-atom $parts 1) 1))
            ($soul-part (index-atom (index-atom $parts 2) 1))
            ($aspect-1 (index-atom (index-atom (index-atom $m260 4) 0) 1))
            ($aspect-2 (index-atom (index-atom (index-atom $m260 4) 1) 1))
            ($aspect-3 (index-atom (index-atom (index-atom $m260 4) 2) 1))
            ($aspects ($aspect-1 $aspect-2 $aspect-3))
            ($preserved (CP2PreservedRelations $m260))
            ($required (sealed-contact partial-frame
              scope-and-constitutional-participation)))
       (pre-movement-occurrence-organization-v2 $occurrence
         (same-occurrence-family
           (same-occurrence $contact-part $frame-part
             (M260SameOcc $m260 $contact-part $frame-part))
           (same-occurrence $frame-part $soul-part
             (M260SameOcc $m260 $frame-part $soul-part)))
         (persistent-form-family
           (M260PersistentForm $m260 $contact-part $frame-part)
           (M260PersistentForm $m260 $frame-part $soul-part))
         (M260DWS $m260 $aspects)
         (M260OPCAt $m260)
         (finite-observational-opacity
           (M260AmbiguityValid $m260) finite-family-non-reconstruction)
         (structural-fidelity-witness $required $preserved
           (M260StructuralFidelity $required $preserved))
         (representation-standing finite-partial-non-sovereign)))
     (pre-movement-occurrence-organization-unresolved
       malformed-occurrence-organization)))

(= (CP2SameOccurrenceFamilyValid $family)
   (and (CPShape $family same-occurrence-family 3)
     (and (CPShape (index-atom $family 1) same-occurrence 4)
      (and (== (index-atom (index-atom $family 1) 3) true)
       (and (CPShape (index-atom $family 2) same-occurrence 4)
            (== (index-atom (index-atom $family 2) 3) true))))))

(= (CP2PersistentFormFamilyValid $family)
   (and (CPShape $family persistent-form-family 3)
     (and (CPShape (index-atom $family 1) persistent-form 5)
          (CPShape (index-atom $family 2) persistent-form 5))))

(= (CP2M260PreMovementValid $m260 $organization)
   (if (M260OrganizationValid $m260)
     (and (== $organization (CP2M260PreMovementOrganization $m260))
      (and (CPShape $organization pre-movement-occurrence-organization-v2 9)
       (and (CP2SameOccurrenceFamilyValid (index-atom $organization 2))
        (and (CP2PersistentFormFamilyValid (index-atom $organization 3))
         (and (CPShape (index-atom $organization 4) dws-family 8)
          (and (CPShape (index-atom $organization 5) opc-at 5)
           (and (== (index-atom (index-atom $organization 6) 1) true)
            (and (== (index-atom (index-atom $organization 7) 3) true)
                 (CPShape (index-atom $organization 8)
                   representation-standing 2))))))))) false))

; Inquiry 26.0 joins the exact Inquiry-25.5 Generated witness to the same
; primary movement that is about to receive its single M25 R/A/P read.  The
; occurrence is rebuilt from the cut; Generated is neither copied into a new
; generative object nor identified with actuality.  SameBecoming remains a
; proof-relevant relation and carries the inherited L2425 witness explicitly.
(= (CP2M260PrimaryMovementReference $primary)
   (M260PrimaryMovementReference $primary))

(= (CP2M260ExactGeneratedRelation $primary)
   (M260ExactGeneratedRelation $primary))

(= (CP2M260InheritedL2425 $primary $cut)
   (M260InheritedL2425 $primary $cut))

(= (CP2M260SameBecomingForPrimary $m260 $pre $primary $cut)
   (M260SameBecomingForPrimary $m260 $primary $cut))

(= (CP2M260StructuralFidelityForPrimary $primary)
   (M260StructuralFidelityForPrimary $primary))

(= (CP2M260StructuralFidelityForPrimaryValid $fidelity $primary)
   (M260StructuralFidelityForPrimaryValid $fidelity $primary))

(= (CP2M260EquivalenceBoundary $primary)
   (M260EquivalenceBoundary $primary))

(= (CP2M260PrimaryBridgeFromCut $primary $cut)
   (M260PrimaryBridgeFromCut $primary $cut))

(= (CP2M260PrimaryBridgeFromCutValid $bridge $primary $cut)
   (M260PrimaryBridgeFromCutValid $bridge $primary $cut))

(= (CP2AuthorityParticipants $contact $m24-organization $m260-pre)
   (let* (($id (index-atom $contact 1))
          ($scope (CPContactScope $contact))
          ($occurrence (index-atom $contact 6))
          ($developmental (CP2M24DevelopmentalOrganization $m24-organization))
          ($m24-reference (m24-organization-reference $id
            (index-atom $m24-organization 3)
            (index-atom $m24-organization 4)))
          ($m260-reference (m260-pre-movement-reference $occurrence
            (index-atom $m260-pre 8)))
          ($developmental-reference (m24-developmental-reference $id
            (index-atom $developmental 3)
            (index-atom $developmental 13))))
     ((participant-contribution (m24-participation $id) native-authority $scope
        (lineage Inquiry-24 $id)
        (participant-relation-claim contact-occurrence-grounding support
          (m24-evidence $m24-reference))
        supported no-contact-no-movement-authority)
      (participant-contribution (m260-participation $id) native-authority $scope
        (lineage Inquiry-26.0 $occurrence)
        (participant-relation-claim contact-occurrence-grounding support
          (m260-evidence $m260-reference))
        supported no-contact-no-movement-authority)
      (participant-contribution (m24-developmental-participation $id)
        native-authority $scope (lineage Inquiry-24-developmental $id)
        (participant-relation-claim m24-developmental-grounding support
          (m24-developmental-evidence $developmental-reference))
        supported no-contact-no-movement-authority)
      (participant-contribution (m260-developmental-participation $id)
        native-authority $scope (lineage Inquiry-26.0-bridge $occurrence)
        (participant-relation-claim m24-developmental-grounding support
          (occurrence-accepts-developmental-carrier $m260-reference
            $developmental-reference))
        supported no-contact-no-movement-authority))))

(= (CP2M24DevelopmentalOrganization $m24-organization)
   (if (CPShape $m24-organization m24-contact-organization 7)
     (let $joined (index-atom $m24-organization 6)
       (if (CPShape $joined derivation-and-developmental-organization 3)
         (index-atom $joined 2)
         (m24-developmental-organization-unresolved missing-developmental-carrier)))
     (m24-developmental-organization-unresolved malformed-contact-organization)))

(= (CP2M24ContactOrganizationValid $m24 $m24-organization)
   (and (== $m24-organization (M24ContactOrganization $m24))
        (M24DevelopmentalOrganizationValid
          (CP2M24DevelopmentalOrganization $m24-organization))))

(= (CP2ContactWithAuthorityParticipants $contact $participants)
   (if (CPShape $contact contact-v2 11)
     (let* (($configuration (index-atom $contact 9))
            ($existing (index-atom $configuration 10))
            ($joined (CPListAppend $existing $participants)))
       (contact-v2
         (index-atom $contact 1) (index-atom $contact 2) (index-atom $contact 3)
         (index-atom $contact 4) (index-atom $contact 5) (index-atom $contact 6)
         (index-atom $contact 7) (index-atom $contact 8)
         (encounter-configuration
           (index-atom $configuration 1) (index-atom $configuration 2)
           (index-atom $configuration 3) (index-atom $configuration 4)
           (index-atom $configuration 5) (index-atom $configuration 6)
           (index-atom $configuration 7) (index-atom $configuration 8)
           (index-atom $configuration 9) $joined)
         (index-atom $contact 10)))
     (authority-contact-unresolved requires-contact-v2)))

(= (CP2AuthorityJointV1Valid $joint)
   (and (CPShape $joint authority-participation-joint-v1 10)
     (and (M24ContactValid (index-atom $joint 2))
      (and (CPShape (index-atom $joint 3) m24-contact-organization 7)
       (and (M260OrganizationValid (index-atom $joint 4))
        (and (== (index-atom $joint 5) true)
         (and (CPShape (index-atom $joint 6) dws-family 8)
          (and (CPShape (index-atom $joint 7) opc-at 5)
           (and (== (index-atom $joint 8) true)
                (== (index-atom $joint 9) finite-non-reconstruction))))))))))

(= (CP2MovementReference $cut $movement)
   (if (CPShape $movement movement-formed 7)
     (movement-reference (index-atom $cut 1) formed
       (index-atom $movement 1) (index-atom $movement 2))
     (if (CPShape $movement movement-plural-live 4)
       (movement-reference (index-atom $cut 1) plural-live
         (size-atom (index-atom (index-atom $movement 2) 1)) unresolved)
       (movement-reference (index-atom $cut 1) unresolved
         (index-atom $movement 1) unresolved))))

(= (CP2SameBecomingCertificate $m260 $cut $movement)
   (let* (($reference (CP2MovementReference $cut $movement))
          ($l2425 (l2425 $reference (source-cut (index-atom $cut 1))))
          ($witness (same-becoming-witness $reference
            (index-atom $m260 1) $l2425
            (movement-emerged-through-constitutive-participation
              (index-atom $cut 1))))
          ($standing (M260SameBecoming $m260 $reference $l2425 $witness)))
     (same-becoming-certified $reference $l2425 $witness $standing)))

(= (CP2GReading $m260 $pre $certificate)
   (let* (($movement (index-atom $certificate 1))
          ($l2425 (index-atom $certificate 2))
          ($witness (index-atom $certificate 3))
          ($generated (generated $movement $pre
            (source-lineage Inquiry-25.5 Inquiry-25 Inquiry-26.0))))
     (M260GReadingOf $m260 $generated $l2425 $witness)))

(= (CP2SameBecomingCertificateValid $m260 $certificate)
   (if (CPShape $certificate same-becoming-certified 5)
     (and (== (index-atom $certificate 4) true)
       (M260SameBecoming $m260 (index-atom $certificate 1)
         (index-atom $certificate 2) (index-atom $certificate 3))) false))

(= (CP2AuthorityJointV2Valid $joint)
   (if (CPShape $joint authority-participation-joint-v2 11)
     (let* (($m24 (index-atom $joint 2))
            ($m24-organization (index-atom $joint 3))
            ($m260 (index-atom $joint 4))
            ($pre (index-atom $joint 5))
            ($g-reading (index-atom $joint 7))
            ($same (index-atom $joint 8)))
       (and (M24ContactValid $m24)
        (and (CP2M24ContactOrganizationValid $m24 $m24-organization)
         (and (CP2M260PreMovementValid $m260 $pre)
          (and (== (index-atom $joint 6) true)
           (and (CP2SameBecomingCertificateValid $m260 $same)
            (and (== $g-reading (CP2GReading $m260 $pre $same))
             (and (CPShape $g-reading g-reading-of 5)
              (and (== (index-atom $joint 9)
                     (index-atom $m24-organization 3))
                   (== (index-atom $joint 10)
                     finite-non-reconstruction)))))))))) false))

; V3 carries the exact per-primary one-becoming bridges already present inside
; the encounter's R/A/P surfaces.  It therefore works for a formed, plural, or
; unresolved movement without manufacturing a post-selection Generated object.
(= (CP2M260BridgeFromReading $reading)
   (if (CPShape $reading m25-movement-reading-v3 9)
     (let $rap (index-atom $reading 2)
       (if (CPShape $rap rap-read-v2 6)
         (M25RAPM260Precursor (index-atom $rap 1))
         (m260-primary-one-becoming-bridge-unresolved malformed-rap)))
     (m260-primary-one-becoming-bridge-unresolved malformed-reading)))

(= (CP2M260BridgeFamilyAt $readings $cut $i)
   (if (< $i (size-atom $readings))
     (let* (($reading (index-atom $readings $i))
            ($primary (if (CPShape $reading m25-movement-reading-v3 9)
              (index-atom $reading 1) ()))
            ($bridge (CP2M260BridgeFromReading $reading)))
       (if (CP2M260PrimaryBridgeFromCutValid $bridge $primary $cut)
         (cons-atom (m260-primary-bridge-entry
           (index-atom $primary 1) $bridge)
           (CP2M260BridgeFamilyAt $readings $cut (+ $i 1)))
         (CP2M260BridgeFamilyAt $readings $cut (+ $i 1))))
     ()))

(= (CP2EncounterM25Readings $encounter)
   (if (CPShape $encounter constitutive-encounter 7)
     (let $generated (index-atom $encounter 4)
       (if (CPShape $generated m25-generated-organization-v1 4)
         (index-atom $generated 3) ())) ()))

(= (CP2M260BridgeFamilyForEncounter $encounter)
   (let $cut (index-atom $encounter 1)
     (m260-primary-bridge-family
       (CP2M260BridgeFamilyAt (CP2EncounterM25Readings $encounter) $cut 0)
       relational-same-becoming-no-total-attachment)))

(= (CP2M260PrimaryBridgeStructuralValid $bridge $m260)
   (if (CPShape $bridge m260-primary-one-becoming-bridge-v1 11)
     (let* (($movement (index-atom $bridge 1))
            ($occurrence (index-atom $bridge 2))
            ($generated (index-atom $bridge 3))
            ($same (index-atom $bridge 4))
            ($g-reading (index-atom $bridge 5))
            ($generated-witness (if (CPShape $generated generated 4)
              (index-atom $generated 2) ()))
            ($equivalence-boundary (index-atom $bridge 9)))
       (and (M260OrganizationValid $m260)
        (and (CPShape $movement primary-movement-reference 4)
         (and (== $occurrence (occurrence-reference (index-atom $m260 1)))
          (and (M255GeneratedWitnessStructuralValid $generated-witness
                 (index-atom $generated-witness 1))
           (and (== (index-atom $generated 1) $movement)
            (and (== (index-atom $generated-witness 6)
                   (l2425-witness l2425-supported))
             (and (CP2SameBecomingCertificateValid $m260 $same)
              (and (== (index-atom $same 1) $movement)
               (and (== $g-reading (M260GReadingOf $m260 $generated
                      (index-atom $same 2) (index-atom $same 3)))
                (and (CPShape (index-atom $bridge 6)
                       m255-g-to-dpf-bridge-v1 10)
                 (and (CPShape (index-atom $bridge 7)
                        participatory-balance-reading 3)
                  (and (== (index-atom
                             (index-atom (index-atom $bridge 8) 4) 3) true)
                   (and (CPShape $equivalence-boundary
                          m260-equivalence-boundary-v1 4)
                    (and (M255CrossCarrierEquivV2Valid
                           (index-atom $equivalence-boundary 1))
                     (and (== (index-atom $equivalence-boundary 2)
                            structural-equivalence-does-not-imply-same-becoming)
                          (CPShape (index-atom $bridge 10)
                            one-becoming-standing 4)))))))))))))))))
     false))

(= (CP2M260BridgeEntriesValidAt $entries $m260 $i $ids)
   (if (< $i (size-atom $entries))
     (let $entry (index-atom $entries $i)
       (if (CPShape $entry m260-primary-bridge-entry 3)
         (let* (($id (index-atom $entry 1))
                ($bridge (index-atom $entry 2)))
           (and (== $id (index-atom (index-atom $bridge 1) 1))
            (and (== (CPHas $id $ids 0) false)
             (and (CP2M260PrimaryBridgeStructuralValid $bridge $m260)
                  (CP2M260BridgeEntriesValidAt $entries $m260 (+ $i 1)
                    (cons-atom $id $ids)))))) false))
     true))

(= (CP2M260BridgeFamilyValid $family $m260)
   (if (CPShape $family m260-primary-bridge-family 3)
     (and (is-expr (index-atom $family 1))
      (and (CP2M260BridgeEntriesValidAt (index-atom $family 1) $m260 0 ())
           (== (index-atom $family 2)
             relational-same-becoming-no-total-attachment)))
     false))

(= (CP2M260MovementOccurrenceStanding $cut $movement $m260 $family)
   (m260-movement-occurrence-standing
     (CP2MovementReference $cut $movement)
     (occurrence-reference (index-atom $m260 1))
     (bridge-count (size-atom (index-atom $family 1)))
     (if (> (size-atom (index-atom $family 1)) 0)
       occurrence-qualified-generated-present no-current-generated-primary)
     relational-non-functional-no-global-attachment))

(= (CP2AuthorityJointV3Valid $joint)
   (if (CPShape $joint authority-participation-joint-v3 11)
     (let* (($m24 (index-atom $joint 2))
            ($m24-organization (index-atom $joint 3))
            ($m260 (index-atom $joint 4))
            ($pre (index-atom $joint 5))
            ($family (index-atom $joint 7))
            ($standing (index-atom $joint 8)))
       (and (M24ContactValid $m24)
        (and (CP2M24ContactOrganizationValid $m24 $m24-organization)
         (and (CP2M260PreMovementValid $m260 $pre)
          (and (== (index-atom $joint 6) true)
           (and (CP2M260BridgeFamilyValid $family $m260)
            (and (CPShape $standing m260-movement-occurrence-standing 6)
             (and (== (index-atom $standing 2)
                    (occurrence-reference (index-atom $m260 1)))
              (and (== (index-atom (index-atom $standing 3) 1)
                     (size-atom (index-atom $family 1)))
               (and (== (index-atom $joint 9)
                      (index-atom $m24-organization 3))
                    (== (index-atom $joint 10)
                      finite-non-reconstruction)))))))))))
     false))

(= (CP2AuthorityJointValid $joint)
   (or (CP2AuthorityJointV1Valid $joint)
     (or (CP2AuthorityJointV2Valid $joint)
         (CP2AuthorityJointV3Valid $joint))))

(= (CP2JointMovementReference $joint)
   (if (CPShape $joint authority-participation-joint-v3 11)
     (index-atom (index-atom $joint 8) 1)
     (if (CPShape $joint authority-participation-joint-v2 11)
       (index-atom (index-atom $joint 8) 1) no-movement-reference)))

(= (CP2AuthorityJointMatchesEncounter $joint $encounter)
   (if (and (CP2AuthorityJointV3Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($m260 (index-atom $joint 4))
            ($family (CP2M260BridgeFamilyForEncounter $encounter)))
       (and (== $m260 (CP2M260OrganizationFromCut $cut))
        (and (== (index-atom $joint 7) $family)
         (and (== (index-atom $joint 8)
                (CP2M260MovementOccurrenceStanding $cut $movement $m260 $family))
          (and (CPDRelationKnown $cut contact-occurrence-grounding)
               (CPDRelationKnown $cut m24-developmental-grounding))))))
     (if (and (CP2AuthorityJointV2Valid $joint)
              (CPShape $encounter constitutive-encounter 7))
       (and (== (CP2JointMovementReference $joint)
              (CP2MovementReference (index-atom $encounter 1)
                (index-atom $encounter 5)))
            (and (CPDRelationKnown (index-atom $encounter 1)
                   contact-occurrence-grounding)
                 (CPDRelationKnown (index-atom $encounter 1)
                   m24-developmental-grounding)))
       (CP2AuthorityJointV1Valid $joint))))

(= (CP2M25Encounter $contact $predecessor $developmental)
   (let $cut (CPMakeCut $contact $predecessor)
     (if (CPCutValid $cut)
       (let $configuration (CPContactConfiguration $contact)
         (M25ConstitutiveEncounter $cut
           (index-atom $configuration 7) (index-atom $configuration 8)
           (index-atom $configuration 10) (index-atom $contact 8)
           $developmental))
       $cut)))

(= (CP2EncounterFromAuthorityOrganizations $contact $predecessor
      $m24 $m24-organization $m260 $m260-pre)
   (if (and (M24ContactValid $m24)
         (and (CP2M24ContactOrganizationValid $m24 $m24-organization)
          (and (M260OrganizationValid $m260)
               (CP2M260PreMovementValid $m260 $m260-pre))))
     (let* (($authority-participants
              (CP2AuthorityParticipants $contact $m24-organization $m260-pre))
              ($participating-contact
                (CP2ContactWithAuthorityParticipants $contact $authority-participants))
              ($developmental
                (CP2M24DevelopmentalOrganization $m24-organization))
              ($encounter (CP2M25Encounter $participating-contact $predecessor
                $developmental)))
       (if (CPShape $encounter constitutive-encounter 7)
         (let* (($cut (index-atom $encounter 1))
                ($movement (index-atom $encounter 5))
                ($family (CP2M260BridgeFamilyForEncounter $encounter))
                ($standing (CP2M260MovementOccurrenceStanding $cut $movement
                  $m260 $family))
                ($joint (authority-participation-joint-v3
                  (index-atom $contact 1) $m24 $m24-organization $m260 $m260-pre
                  (CPDRelationKnown $cut contact-occurrence-grounding)
                  $family $standing (index-atom $m24-organization 3)
                  finite-non-reconstruction)))
           (if (CP2AuthorityJointMatchesEncounter $joint $encounter)
             (authority-grounded-encounter $joint $encounter)
             (authority-grounded-encounter-unresolved joint-not-causal $joint)))
         (authority-grounded-encounter-unresolved encounter-not-formed $encounter)))
     (authority-grounded-encounter-unresolved
       contact-or-authority-organization-not-grounded)))

(= (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)
   (let* (($m24-organization (M24ContactOrganization $m24))
          ($m260-valid (M260OrganizationValid $m260))
          ($m260-pre (if $m260-valid
            (CP2M260PreMovementOrganization $m260)
            (pre-movement-occurrence-organization-unresolved))))
     (CP2EncounterFromAuthorityOrganizations $contact $predecessor
       $m24 $m24-organization $m260 $m260-pre)))

(= (CP2Encounter $contact $predecessor)
   (let* (($m24 (CP2M24Contact $contact))
          ($m260 (CP2M260Organization $contact)))
     (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)))
