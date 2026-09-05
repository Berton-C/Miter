; AMA-1.2 R3 constitutive authority join.
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

(= (CP2M260Organization $contact)
   (if (CPContactValid $contact)
     (let* (($id (index-atom $contact 1))
            ($occurrence (index-atom $contact 6))
            ($payload (CP2PayloadReference $contact))
            ($contact-part (contact-part $id))
            ($frame-part (frame-part $id))
            ($soul-part (soul-part $id))
            ($contact-view (contact-view $id))
            ($frame-view (frame-view $id))
            ($soul-view (soul-view $id))
            ($relational-aspect (relational-organization $id))
            ($participated-aspect (participated-contact $id))
            ($self-aspect (self-relating-organization $id)))
       (m260-occurrence-organization $occurrence
         ((participates $contact-part $occurrence)
          (participates $frame-part $occurrence)
          (participates $soul-part $occurrence))
         ((view-grounding $contact-view $contact-part $payload)
          (view-grounding $frame-view $frame-part (frame-of $id))
          (view-grounding $soul-view $soul-part (CPContactScope $contact)))
         ((unity-aspect $relational-aspect $occurrence non-independent)
          (unity-aspect $participated-aspect $occurrence non-independent)
          (unity-aspect $self-aspect $occurrence non-independent))
         ((manifests-through $relational-aspect $contact-view $contact-part $occurrence)
          (manifests-through $participated-aspect $frame-view $frame-part $occurrence)
          (manifests-through $self-aspect $soul-view $soul-part $occurrence))
         ((recognizes $contact-view $relational-aspect (prov-contact-reference $payload)
            $contact-part)
          (recognizes $frame-view $participated-aspect (partial-frame-reference (frame-of $id))
            $frame-part)
          (recognizes $soul-view $self-aspect (soul-participation-reference $id) $soul-part))
         ((observation $contact-view $occurrence $payload)
          (observation $frame-view $occurrence partial-finite-frame)
          (observation $soul-view $occurrence constitutive-participation))
         (finite-ambiguity ($contact-view $frame-view $soul-view)
           $occurrence (unrepresented-occurrence-alternative $id) equal-observations)
         ((local-boundary $contact-part (contact-boundary $payload))
          (local-boundary $frame-part (frame-boundary (frame-of $id)))
          (local-boundary $soul-part (soul-boundary (CPContactScope $contact))))
         ((preserves $contact-view sealed-contact)
          (preserves $frame-view partial-frame)
          (preserves $soul-view scope-and-constitutional-participation))
         ((continues $contact-part $frame-part contact-to-frame)
          (continues $frame-part $soul-part frame-to-soul-participation))
         ((mode-reading $relational-aspect ontology)
          (mode-reading $participated-aspect phenomenology)
          (mode-reading $self-aspect consciousness))))
     (m260-occurrence-unresolved malformed-contact $contact)))

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

(= (CP2AuthorityParticipants $contact $m24-organization $m260-pre)
   (let* (($id (index-atom $contact 1))
          ($scope (CPContactScope $contact))
          ($occurrence (index-atom $contact 6)))
     ((participant-contribution (m24-participation $id) native-authority $scope
        (lineage Inquiry-24 $id)
        (participant-relation-claim contact-occurrence-grounding support
          (m24-evidence $m24-organization))
        supported no-contact-no-movement-authority)
      (participant-contribution (m260-participation $id) native-authority $scope
        (lineage Inquiry-26.0 $occurrence)
        (participant-relation-claim contact-occurrence-grounding support
          (m260-evidence $m260-pre))
        supported no-contact-no-movement-authority))))

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
        (and (== $m24-organization (M24ContactOrganization $m24))
         (and (CP2M260PreMovementValid $m260 $pre)
          (and (== (index-atom $joint 6) true)
           (and (CP2SameBecomingCertificateValid $m260 $same)
            (and (== $g-reading (CP2GReading $m260 $pre $same))
             (and (CPShape $g-reading g-reading-of 5)
              (and (== (index-atom $joint 9)
                     (index-atom $m24-organization 3))
                   (== (index-atom $joint 10)
                     finite-non-reconstruction)))))))))) false))

(= (CP2AuthorityJointValid $joint)
   (or (CP2AuthorityJointV1Valid $joint)
       (CP2AuthorityJointV2Valid $joint)))

(= (CP2JointMovementReference $joint)
   (if (CPShape $joint authority-participation-joint-v2 11)
     (index-atom (index-atom $joint 8) 1) no-movement-reference))

(= (CP2AuthorityJointMatchesEncounter $joint $encounter)
   (if (and (CP2AuthorityJointV2Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (== (CP2JointMovementReference $joint)
       (CP2MovementReference (index-atom $encounter 1)
         (index-atom $encounter 5)))
     (CP2AuthorityJointV1Valid $joint)))

(= (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)
   (let* (($m24-valid (M24ContactValid $m24))
          ($m24-organization (M24ContactOrganization $m24))
          ($m260-valid (M260OrganizationValid $m260))
          ($m260-pre (if $m260-valid
            (CP2M260PreMovementOrganization $m260)
            (pre-movement-occurrence-organization-unresolved))))
     (if (and $m24-valid
           (and $m260-valid (CP2M260PreMovementValid $m260 $m260-pre)))
       (let* (($authority-participants
                (CP2AuthorityParticipants $contact $m24-organization $m260-pre))
              ($participating-contact
                (CP2ContactWithAuthorityParticipants $contact $authority-participants))
              ($encounter (CPEncounter $participating-contact $predecessor)))
         (if (CPShape $encounter constitutive-encounter 7)
           (let* (($cut (index-atom $encounter 1))
                  ($movement (index-atom $encounter 5))
                  ($same (CP2SameBecomingCertificate $m260 $cut $movement))
                  ($g-reading (CP2GReading $m260 $m260-pre $same))
                  ($joint (authority-participation-joint-v2
                    (index-atom $contact 1) $m24 $m24-organization $m260 $m260-pre
                    (CPDRelationKnown $cut contact-occurrence-grounding)
                    $g-reading $same (index-atom $m24-organization 3)
                    finite-non-reconstruction)))
             (if (CP2AuthorityJointMatchesEncounter $joint $encounter)
               (authority-grounded-encounter $joint $encounter)
               (authority-grounded-encounter-unresolved joint-not-causal $joint)))
           (authority-grounded-encounter-unresolved encounter-not-formed $encounter)))
       (authority-grounded-encounter-unresolved
         contact-or-occurrence-not-grounded (m24 $m24-valid) (m260 $m260-valid)))))

(= (CP2Encounter $contact $predecessor)
   (let* (($m24 (CP2M24Contact $contact))
          ($m260 (CP2M260Organization $contact)))
     (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)))
