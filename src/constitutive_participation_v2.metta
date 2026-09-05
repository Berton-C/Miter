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

(= (CP2AuthorityParticipants $contact $m24-organization $m260-organization)
   (let* (($id (index-atom $contact 1))
          ($scope (CPContactScope $contact))
          ($occurrence (index-atom $contact 6)))
     ((participant-contribution (m24-participation $id) native-authority $scope
        (lineage Inquiry-24 $id)
        (participant-relation-claim contact-occurrence-grounding support
          (m24-evidence (contact-organization-ref $id)))
        supported no-contact-no-movement-authority)
      (participant-contribution (m260-participation $id) native-authority $scope
        (lineage Inquiry-26.0 $occurrence)
        (participant-relation-claim contact-occurrence-grounding support
          (m260-evidence (occurrence-organization-ref $occurrence)))
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

(= (CP2AuthorityJointValid $joint)
   (and (CPShape $joint authority-participation-joint-v1 10)
     (and (M24ContactValid (index-atom $joint 2))
      (and (CPShape (index-atom $joint 3) m24-contact-organization 7)
       (and (M260OrganizationValid (index-atom $joint 4))
        (and (== (index-atom $joint 5) true)
         (and (CPShape (index-atom $joint 6) dws-family 8)
          (and (CPShape (index-atom $joint 7) opc-at 5)
           (and (== (index-atom $joint 8) true)
                (== (index-atom $joint 9) finite-non-reconstruction))))))))))

(= (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)
   (let* (($m24-valid (M24ContactValid $m24))
          ($m24-organization (M24ContactOrganization $m24))
          ($m260-valid (M260OrganizationValid $m260)))
     (if (and $m24-valid $m260-valid)
       (let* (($authority-participants
                (CP2AuthorityParticipants $contact $m24-organization $m260))
              ($participating-contact
                (CP2ContactWithAuthorityParticipants $contact $authority-participants))
              ($encounter (CPEncounter $participating-contact $predecessor)))
         (if (CPShape $encounter constitutive-encounter 7)
           (let* (($cut (index-atom $encounter 1))
                  ($movement (index-atom $encounter 5))
                  ($l2425 (l2425 $movement (source-cut (index-atom $cut 1))))
                  ($same-witness (same-becoming-witness $movement
                    (index-atom $m260 1) $l2425 contact-to-movement))
                  ($same (M260SameBecoming $m260 $movement $l2425 $same-witness))
                  ($dws (M260DWS $m260
                    ((relational-organization (index-atom $contact 1))
                     (participated-contact (index-atom $contact 1))
                     (self-relating-organization (index-atom $contact 1)))))
                  ($opc (M260OPCAt $m260))
                  ($joint (authority-participation-joint-v1
                    (index-atom $contact 1) $m24 $m24-organization $m260
                    (CPDRelationKnown $cut contact-occurrence-grounding)
                    $dws $opc $same finite-non-reconstruction)))
             (if (CP2AuthorityJointValid $joint)
               (authority-grounded-encounter $joint $encounter)
               (authority-grounded-encounter-unresolved joint-not-causal $joint)))
           (authority-grounded-encounter-unresolved encounter-not-formed $encounter)))
       (authority-grounded-encounter-unresolved
         contact-or-occurrence-not-grounded (m24 $m24-valid) (m260 $m260-valid)))))

(= (CP2Encounter $contact $predecessor)
   (let* (($m24 (CP2M24Contact $contact))
          ($m260 (CP2M260Organization $contact)))
     (CP2EncounterFromAuthority $contact $predecessor $m24 $m260)))
