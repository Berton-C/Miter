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

; The hardened M26.0 primitive basis is carried explicitly.  These are
; semantic/interface primitives whose live instantiation is checked here;
; they are neither Lean axioms nor derived behavioral rules.
(= (CP2M260PrimitiveLawBasis $m24-organization $m260 $pre)
   (m260-primitive-law-basis-v1
     (primitive-law participation-grounding-of-views
       (M260ViewsGroundedAt $m260 (index-atom $m260 3) 0)
       explicit-semantic-primitive-not-derived)
     (primitive-law manifestation-soundness
       (M260ManifestationsGroundedAt $m260 (index-atom $m260 5) 0)
       explicit-semantic-primitive-not-derived)
     (primitive-law recognition-soundness
       (M260RecognitionsGroundedAt $m260 (index-atom $m260 6) 0)
       explicit-semantic-primitive-not-derived)
     (primitive-law inherited-m24-contact-domain-nonamalgamation
       (m24-minimum-interface
         (index-atom $m24-organization 1)
         (index-atom $m24-organization 5)
         scoped-joint-use-without-global-amalgamation)
       explicit-interface-primitive-not-derived)
     (primitive-law relational-same-becoming-with-embedded-l2425
       proof-relevant-non-functional-no-total-attachment
       explicit-semantic-primitive-not-derived)
     (primitive-law finite-observational-ambiguity
       (index-atom (index-atom $pre 6) 1)
       explicit-semantic-primitive-not-derived)
     (primitive-law unity-without-independent-aspect-domain
       (M260AspectSupportValidAt $m260 (index-atom $m260 4) 0)
       explicit-semantic-primitive-not-derived)
     (primitive-law continuity-and-local-boundary
       (index-atom $pre 3)
       explicit-interface-primitive-not-derived)))

(= (CP2M260DerivedExportBasis $m24-organization $m260 $pre)
   (m260-derived-export-basis-v1
     (occurrence-reference (index-atom $m260 1))
     (partial-views (index-atom $m260 3))
     (same-occurrence-standing (index-atom $pre 2))
     (unity-aspect-standing (index-atom $m260 4))
     (manifestation-recognition-standing
       (index-atom $m260 5) (index-atom $m260 6)
       distinct-with-recognition-grounded-in-manifestation)
     (opc-distinction-standing (index-atom $pre 5))
     (dws-standing (index-atom $pre 4))
     (opacity-standing (index-atom $pre 6))
     (representation-standing (index-atom $pre 8))
     (scoped-nonamalgamation-standing
       (index-atom $m24-organization 5) no-required-global-view)
     (finite-form-nonself-standing
       (index-atom $pre 3) continuity-with-changing-local-boundary)
     (relational-same-becoming-interface
       proof-relevant non-functional generated-must-remain-occurrence-qualified)
     (structural-fidelity-standing
       (index-atom $pre 7) relation-preservation-not-scalar-distance)))

(= (CP2M260ConstitutiveCertificate $m24 $m24-organization $m260 $pre)
   (if (and (M24ContactValid $m24)
         (and (CP2M24ContactOrganizationValid $m24 $m24-organization)
          (and (M260OrganizationValid $m260)
               (CP2M260PreMovementValid $m260 $pre))))
     (m260-constitutive-export-certificate-v1
       (index-atom $m260 1)
       (M260PreMovementExportRelationIds)
       (CP2M260PrimitiveLawBasis $m24-organization $m260 $pre)
       (CP2M260DerivedExportBasis $m24-organization $m260 $pre)
       (formal-evidence-boundary
         formally-supported-under-hardened-lean-encoding
         adapter-mediated-inquiry24-specialization
         finite-runtime-witness-does-not-prove-actuality)
       (nonclaims no-global-actuality-state no-finite-reconstruction
         no-product-opc no-scalar-fidelity no-generated-equals-actuality
         no-universal-fact9-or-generative-exhaustiveness)
       no-contact-no-movement-authority)
     (m260-constitutive-export-certificate-unresolved
       invalid-authority-or-occurrence-organization)))

(= (CP2M260ConstitutiveCertificateValid $certificate $m24
      $m24-organization $m260 $pre)
   (if (CPShape $certificate m260-constitutive-export-certificate-v1 8)
     (== $certificate
       (CP2M260ConstitutiveCertificate $m24 $m24-organization $m260 $pre))
     false))

; One compact D relation carries the conjunction of all fourteen pre-movement
; exports.  The complete exact certificate remains in the authority joint.
; This keeps every constituent counterfactually load-bearing while avoiding a
; combinatorial copy of the export vocabulary through Generated carriers.
(= (CP2M260CertificateDRelation $certificate)
   (relation m260-constitutive-export-grounding m260-authority-derived support
     (m260-certificate-reference
       (index-atom $certificate 1)
       (export-count (size-atom (index-atom $certificate 2)))
       (primitive-count (- (size-atom (index-atom $certificate 3)) 1)))))

(= (CP2CutWithM260Certificate $cut $certificate $m24 $m24-organization
      $m260 $pre)
   (if (and (CPCutValid $cut)
         (and (CP2M260ConstitutiveCertificateValid $certificate $m24
                $m24-organization $m260 $pre)
          (and (== (index-atom $certificate 2)
                 (M260PreMovementExportRelationIds))
               (== (size-atom (index-atom $certificate 3)) 9))))
     (let* (($d (index-atom $cut 6))
            ($rows (index-atom $d 1))
            ($relation (CP2M260CertificateDRelation $certificate)))
       (constitutive-cut
         (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
         (index-atom $cut 4) (index-atom $cut 5)
         (D (CPMergeNewRelationsAt $rows ($relation) 0)
            (index-atom $d 2))
         (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
         (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
         (index-atom $cut 13)))
     (constitutive-cut-unresolved invalid-m260-certificate)))

(= (CP2M260CertificateRelationKnown $cut $certificate)
   (CPHas (CP2M260CertificateDRelation $certificate)
     (CPDRelations $cut) 0))

; Inquiry 26.3 is admitted only as the exact finite certificate constructed
; from this cut, its actual Fact9 expression family, and the already validated
; M26.0 occurrence organization. A compact reference enters D; the full
; inspectable certificate remains in the authority joint.
; Retaining all upstream authority arguments prevents the M26.3 certificate
; from being validated against a detached occurrence.
(= (CP2M263ConstitutiveCertificateValid $certificate $cut $facts $m24
      $m24-organization $m260 $m260-pre $m260-certificate)
   (==
     ((CP2M260ConstitutiveCertificateValid $m260-certificate $m24
        $m24-organization $m260 $m260-pre)
      (M263ConstitutiveCertificateValid $certificate $cut $facts $m260
        $m260-pre $m260-certificate))
     (true true)))

(= (CP2M263CertificateDRelation $certificate)
   (relation m263-constitutive-grammar-grounding m263-authority-derived support
     (M263CertificateReference $certificate)))

(= (CP2CutWithM263Certificate $cut $facts $certificate $m24
      $m24-organization $m260 $m260-pre $m260-certificate)
   (if (==
         ((CPCutValid $cut)
          (CP2M260CertificateRelationKnown $cut $m260-certificate)
          (CP2M263ConstitutiveCertificateValid $certificate $cut $facts $m24
            $m24-organization $m260 $m260-pre $m260-certificate))
         (true true true))
     (let* (($d (index-atom $cut 6))
            ($rows (index-atom $d 1))
            ($relation (CP2M263CertificateDRelation $certificate)))
       (constitutive-cut
         (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
         (index-atom $cut 4) (index-atom $cut 5)
         (D (CPMergeNewRelationsAt $rows ($relation) 0)
            (index-atom $d 2))
         (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
         (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
         (index-atom $cut 13)))
     (constitutive-cut-unresolved invalid-m263-certificate)))

(= (CP2M263CertificateRelationKnown $cut $certificate)
   (CPHas (CP2M263CertificateDRelation $certificate)
     (CPDRelations $cut) 0))

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

(= (CP2M24CertificateDRelation $certificate)
   (relation m24-constitutive-export-grounding m24-authority-derived support
     (M24CertificateReference $certificate)))

(= (CP2CutWithM24Certificate $cut $certificate $m24 $m24-organization)
   (if (and (CPCutValid $cut)
            (M24ConstitutiveCertificateValid $certificate $m24
              $m24-organization))
     (let* (($d (index-atom $cut 6))
            ($rows (index-atom $d 1))
            ($relation (CP2M24CertificateDRelation $certificate)))
       (constitutive-cut
         (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
         (index-atom $cut 4) (index-atom $cut 5)
         (D (CPMergeNewRelationsAt $rows ($relation) 0)
            (index-atom $d 2))
         (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
         (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
         (index-atom $cut 13)))
     (constitutive-cut-unresolved invalid-m24-certificate)))

(= (CP2M24CertificateRelationKnown $cut $certificate)
   (CPHas (CP2M24CertificateDRelation $certificate)
     (CPDRelations $cut) 0))

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
(= (CP2M24BridgeFromReading $reading)
   (if (CPShape $reading m25-movement-reading-v3 9)
     (let $rap (index-atom $reading 2)
       (if (CPShape $rap rap-read-v2 6)
         (M25RAPM24Precursor (index-atom $rap 1))
         (m24-primary-constitutive-bridge-unresolved malformed-rap)))
     (m24-primary-constitutive-bridge-unresolved malformed-reading)))

(= (CP2M24CausalInPrimariesAt $readings $cut $developmental $certificate $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPShape $reading m25-movement-reading-v3 9)
         (let* (($primary (index-atom $reading 1))
                ($bridge (CP2M24BridgeFromReading $reading))
                ($checks
                  ((M25PrimaryMovementValid $primary)
                   (AIAllIn (M24PreMovementCausalRelationIds)
                     (index-atom (index-atom $primary 9) 3) 0)
                   (M24PrimaryBridgeFromCutValid $bridge $primary $cut
                     $developmental)
                   (== (index-atom $bridge 3)
                     (M24CertificateReference $certificate))
                   (CP2M24CausalInPrimariesAt $readings $cut $developmental
                     $certificate (+ $i 1)))))
           (== $checks (true true true true true)))
         false))
     true))

(= (CP2M24ExportsCausalInEncounter $encounter $developmental $certificate)
   (if (and (CPShape $encounter constitutive-encounter 7)
            (CPShape $certificate m24-constitutive-export-certificate-v1 8))
     (let* (($cut (index-atom $encounter 1))
            ($readings (CP2EncounterM25Readings $encounter)))
       (==
         ((CP2M24CertificateRelationKnown $cut $certificate)
          (> (size-atom $readings) 0)
          (CP2M24CausalInPrimariesAt $readings $cut $developmental
            $certificate 0))
         (true true true)))
     false))

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

; The M25 completion certificate is derived only after the encounter has
; formed its primary movements and one simultaneous R/A/P read. It validates
; that live organization and cannot construct or choose the movement.
!(import! &self "./src/m25_completion.metta")

; Inquiry 25.5 closes over the exact Generated/carrier/participation
; organization already present before R/A/P.  Its package validates that
; organization; it does not add a generator or select among movements.
!(import! &self "./src/m255_completion.metta")

(= (CP2M260CausalRelationInPrimariesAt $readings $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPShape $reading m25-movement-reading-v3 9)
         (let $primary (index-atom $reading 1)
           (and (M25PrimaryMovementValid $primary)
             (and (AIAllIn (M260PreMovementCausalRelationIds)
                    (index-atom (index-atom $primary 9) 3) 0)
                  (CP2M260CausalRelationInPrimariesAt $readings (+ $i 1)))))
         false))
     true))

(= (CP2M260ExportsCausalInEncounter $encounter $certificate)
   (if (and (CPShape $encounter constitutive-encounter 7)
            (CPShape $certificate m260-constitutive-export-certificate-v1 8))
     (let* (($cut (index-atom $encounter 1))
            ($ids (index-atom $certificate 2))
            ($readings (CP2EncounterM25Readings $encounter)))
       (and (== $ids (M260PreMovementExportRelationIds))
        (and (CP2M260CertificateRelationKnown $cut $certificate)
         (and (> (size-atom $readings) 0)
              (CP2M260CausalRelationInPrimariesAt $readings 0)))))
     false))

(= (CP2M263BridgeFromReading $reading)
   (if (CPShape $reading m25-movement-reading-v3 9)
     (let $rap (index-atom $reading 2)
       (if (CPShape $rap rap-read-v2 6)
         (M25RAPM263Precursor (index-atom $rap 1))
         (m263-primary-constitutive-bridge-unresolved malformed-rap)))
     (m263-primary-constitutive-bridge-unresolved malformed-reading)))

(= (CP2M263CausalInPrimariesAt $readings $cut $certificate $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPShape $reading m25-movement-reading-v3 9)
         (let* (($primary (index-atom $reading 1))
                ($bridge (CP2M263BridgeFromReading $reading))
                ($checks
                  ((M25PrimaryMovementValid $primary)
                   (AIAllIn (M263PreMovementCausalRelationIds)
                     (index-atom (index-atom $primary 9) 3) 0)
                   (M263PrimaryBridgeFromCutValid $bridge $primary $cut)
                   (== (index-atom $bridge 3)
                     (M263CertificateReference $certificate))
                   (CP2M263CausalInPrimariesAt $readings $cut $certificate
                     (+ $i 1)))))
           (== $checks (true true true true true)))
         false))
     true))

(= (CP2M263ExportsCausalInEncounter $encounter $certificate)
   (if (and (CPShape $encounter constitutive-encounter 7)
            (CPShape $certificate
              m263-constitutive-grammar-certificate-v1 18))
     (let* (($cut (index-atom $encounter 1))
            ($readings (CP2EncounterM25Readings $encounter)))
       (==
         ((CP2M263CertificateRelationKnown $cut $certificate)
          (> (size-atom $readings) 0)
          (CP2M263CausalInPrimariesAt $readings $cut $certificate 0))
         (true true true)))
     false))

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

; V4 retains V3's exact per-primary one-becoming family and adds the bounded
; M26.0 constitutive certificate.  The certificate makes all eight primitive
; laws and the remaining derived export structures inspectable without
; granting a finite representation actuality or movement authority.
(= (CP2AuthorityJointV4Valid $joint)
   (if (CPShape $joint authority-participation-joint-v4 12)
     (let* (($v3 (authority-participation-joint-v3
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)))
            ($certificate (index-atom $joint 11)))
       (and (CP2AuthorityJointV3Valid $v3)
            (CP2M260ConstitutiveCertificateValid $certificate
              (index-atom $joint 2) (index-atom $joint 3)
              (index-atom $joint 4) (index-atom $joint 5))))
     false))

; V5 adds the complete Inquiry-26.3 certificate to the same authority joint.
; Structural validity here is deliberately bounded; exact cut-relative
; validity and causal participation are established against the encounter in
; CP2AuthorityJointMatchesEncounter.
(= (CP2AuthorityJointV5Valid $joint)
   (if (CPShape $joint authority-participation-joint-v5 13)
     (let* (($v4 (authority-participation-joint-v4
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11)))
            ($m260-certificate (index-atom $joint 11))
            ($m263-certificate (index-atom $joint 12)))
       (and (CP2AuthorityJointV4Valid $v4)
            (M263ConstitutiveCertificateStructuralValid $m263-certificate
              $m260-certificate)))
     false))

; V6 makes the complete Inquiry-24 inheritance surface an exact constituent
; of the same joint.  M24 grounds every later authority and is therefore
; validated both structurally here and cut-relatively below.
(= (CP2AuthorityJointV6Valid $joint)
   (if (CPShape $joint authority-participation-joint-v6 14)
     (let* (($v5 (authority-participation-joint-v5
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11) (index-atom $joint 12)))
            ($m24-certificate (index-atom $joint 13)))
       (and (CP2AuthorityJointV5Valid $v5)
            (M24ConstitutiveCertificateStructuralValid $m24-certificate)))
     false))

; V7 retains the exact M25 organization formed by the encounter itself. The
; certificate is downstream of primary formation and therefore cannot select
; a movement from R/A/P; it makes the ratified movement/read limits explicit
; in the same persisted authority joint.
(= (CP2AuthorityJointV7Valid $joint)
   (if (CPShape $joint authority-participation-joint-v7 15)
     (let* (($v6 (authority-participation-joint-v6
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11) (index-atom $joint 12)
                   (index-atom $joint 13)))
            ($m25-certificate (index-atom $joint 14)))
       (and (CP2AuthorityJointV6Valid $v6)
            (M25ConstitutiveCertificateStructuralValid $m25-certificate)))
     false))

; V8 retains the bounded Inquiry-25.5 three-point-shot package derived from
; the encounter's own carrier bridges, participation profiles, recognition,
; inherited bridge family, and one R/A/P surface.
(= (CP2AuthorityJointV8Valid $joint)
   (if (CPShape $joint authority-participation-joint-v8 16)
     (let* (($v7 (authority-participation-joint-v7
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11) (index-atom $joint 12)
                   (index-atom $joint 13) (index-atom $joint 14)))
            ($m255-certificate (index-atom $joint 15)))
       (and (CP2AuthorityJointV7Valid $v7)
            (M255ConstitutiveCertificateStructuralValid $m255-certificate)))
     false))

(= (CP2AuthorityJointValid $joint)
   (or (CP2AuthorityJointV1Valid $joint)
     (or (CP2AuthorityJointV2Valid $joint)
      (or (CP2AuthorityJointV3Valid $joint)
       (or (CP2AuthorityJointV4Valid $joint)
        (or (CP2AuthorityJointV5Valid $joint)
         (or (CP2AuthorityJointV6Valid $joint)
          (or (CP2AuthorityJointV7Valid $joint)
              (CP2AuthorityJointV8Valid $joint)))))))))

(= (CP2JointMovementReference $joint)
   (if (CPShape $joint authority-participation-joint-v8 16)
     (index-atom (index-atom $joint 8) 1)
    (if (CPShape $joint authority-participation-joint-v7 15)
     (index-atom (index-atom $joint 8) 1)
    (if (CPShape $joint authority-participation-joint-v6 14)
     (index-atom (index-atom $joint 8) 1)
    (if (CPShape $joint authority-participation-joint-v5 13)
     (index-atom (index-atom $joint 8) 1)
    (if (CPShape $joint authority-participation-joint-v4 12)
     (index-atom (index-atom $joint 8) 1)
    (if (CPShape $joint authority-participation-joint-v3 11)
     (index-atom (index-atom $joint 8) 1)
     (if (CPShape $joint authority-participation-joint-v2 11)
       (index-atom (index-atom $joint 8) 1) no-movement-reference))))))))

(= (CP2AuthorityJointMatchesEncounter $joint $encounter)
   (if (and (CP2AuthorityJointV8Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($v7 (authority-participation-joint-v7
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11) (index-atom $joint 12)
                   (index-atom $joint 13) (index-atom $joint 14)))
            ($developmental
              (CP2M24DevelopmentalOrganization (index-atom $joint 3)))
            ($m25-certificate (index-atom $joint 14))
            ($m255-certificate (index-atom $joint 15)))
       (and (CP2AuthorityJointMatchesEncounter $v7 $encounter)
            (M255ConstitutiveCertificateDependentValid $m255-certificate
              $encounter $developmental $m25-certificate)))
    (if (and (CP2AuthorityJointV7Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($v6 (authority-participation-joint-v6
                   (index-atom $joint 1) (index-atom $joint 2)
                   (index-atom $joint 3) (index-atom $joint 4)
                   (index-atom $joint 5) (index-atom $joint 6)
                   (index-atom $joint 7) (index-atom $joint 8)
                   (index-atom $joint 9) (index-atom $joint 10)
                   (index-atom $joint 11) (index-atom $joint 12)
                   (index-atom $joint 13)))
            ($developmental
              (CP2M24DevelopmentalOrganization (index-atom $joint 3)))
            ($m25-certificate (index-atom $joint 14)))
       (and (CP2AuthorityJointMatchesEncounter $v6 $encounter)
            (M25ConstitutiveCertificateValid $m25-certificate $encounter
              $developmental)))
    (if (and (CP2AuthorityJointV6Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($cut (index-atom $encounter 1))
            ($facts (index-atom $encounter 2))
            ($movement (index-atom $encounter 5))
            ($m24 (index-atom $joint 2))
            ($m24-organization (index-atom $joint 3))
            ($developmental
              (CP2M24DevelopmentalOrganization $m24-organization))
            ($m260 (index-atom $joint 4))
            ($m260-pre (index-atom $joint 5))
            ($family (CP2M260BridgeFamilyForEncounter $encounter))
            ($m260-certificate (index-atom $joint 11))
            ($m263-certificate (index-atom $joint 12))
            ($m24-certificate (index-atom $joint 13))
            ($checks
              ((M24ConstitutiveCertificateValid $m24-certificate $m24
                 $m24-organization)
               (CP2M24ExportsCausalInEncounter $encounter $developmental
                 $m24-certificate)
               (== $m260 (CP2M260OrganizationFromCut $cut))
               (== (index-atom $joint 7) $family)
               (== (index-atom $joint 8)
                 (CP2M260MovementOccurrenceStanding $cut $movement $m260
                   $family))
               (CP2M260ExportsCausalInEncounter $encounter $m260-certificate)
               (CP2M263ConstitutiveCertificateValid $m263-certificate $cut
                 $facts $m24 $m24-organization $m260 $m260-pre
                 $m260-certificate)
               (CP2M263ExportsCausalInEncounter $encounter $m263-certificate)
               (CPDRelationKnown $cut contact-occurrence-grounding)
               (CPDRelationKnown $cut m24-developmental-grounding))))
       (== $checks (true true true true true true true true true true)))
    (if (and (CP2AuthorityJointV5Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($cut (index-atom $encounter 1))
            ($facts (index-atom $encounter 2))
            ($movement (index-atom $encounter 5))
            ($m24 (index-atom $joint 2))
            ($m24-organization (index-atom $joint 3))
            ($m260 (index-atom $joint 4))
            ($m260-pre (index-atom $joint 5))
            ($family (CP2M260BridgeFamilyForEncounter $encounter))
            ($m260-certificate (index-atom $joint 11))
            ($m263-certificate (index-atom $joint 12))
            ($checks
              ((== $m260 (CP2M260OrganizationFromCut $cut))
               (== (index-atom $joint 7) $family)
               (== (index-atom $joint 8)
                 (CP2M260MovementOccurrenceStanding $cut $movement $m260
                   $family))
               (CP2M260ExportsCausalInEncounter $encounter $m260-certificate)
               (CP2M263ConstitutiveCertificateValid $m263-certificate $cut
                 $facts $m24 $m24-organization $m260 $m260-pre
                 $m260-certificate)
               (CP2M263ExportsCausalInEncounter $encounter $m263-certificate)
               (CPDRelationKnown $cut contact-occurrence-grounding)
               (CPDRelationKnown $cut m24-developmental-grounding))))
       (== $checks (true true true true true true true true)))
    (if (and (CP2AuthorityJointV4Valid $joint)
            (CPShape $encounter constitutive-encounter 7))
     (let* (($cut (index-atom $encounter 1))
            ($movement (index-atom $encounter 5))
            ($m260 (index-atom $joint 4))
            ($family (CP2M260BridgeFamilyForEncounter $encounter))
            ($certificate (index-atom $joint 11)))
       (and (== $m260 (CP2M260OrganizationFromCut $cut))
        (and (== (index-atom $joint 7) $family)
         (and (== (index-atom $joint 8)
                (CP2M260MovementOccurrenceStanding $cut $movement $m260 $family))
          (and (CP2M260ExportsCausalInEncounter $encounter $certificate)
           (and (CPDRelationKnown $cut contact-occurrence-grounding)
                (CPDRelationKnown $cut m24-developmental-grounding)))))))
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
       (CP2AuthorityJointV1Valid $joint)))))))))

(= (CP2M25Encounter $contact $predecessor $developmental $m24-certificate
      $m260-certificate $m263-certificate $m24 $m24-organization $m260
      $m260-pre)
   (let* (($cut (CPMakeCut $contact $predecessor))
          ($m24-cut (CP2CutWithM24Certificate $cut $m24-certificate $m24
            $m24-organization))
          ($m260-cut (CP2CutWithM260Certificate $m24-cut $m260-certificate
            $m24 $m24-organization $m260 $m260-pre))
          ($configuration (CPContactConfiguration $contact))
          ($facts (CPFactExpressionsAt $m260-cut
            (index-atom $configuration 7) 0))
          ($authority-cut (CP2CutWithM263Certificate $m260-cut $facts
            $m263-certificate $m24 $m24-organization $m260 $m260-pre
            $m260-certificate)))
     (if (CPCutValid $authority-cut)
       (M25ConstitutiveEncounter $authority-cut
         (index-atom $configuration 7) (index-atom $configuration 8)
         (index-atom $configuration 10) (index-atom $contact 8)
         $developmental)
       $authority-cut)))

(= (CP2EncounterFromAuthorityOrganizations $contact $predecessor
      $m24 $m24-organization $m260 $m260-pre)
   (if (and (M24ContactValid $m24)
         (and (CP2M24ContactOrganizationValid $m24 $m24-organization)
          (and (M260OrganizationValid $m260)
               (CP2M260PreMovementValid $m260 $m260-pre))))
     (let* (($m260-certificate (CP2M260ConstitutiveCertificate $m24
              $m24-organization $m260 $m260-pre))
            ($m24-certificate (M24ConstitutiveCertificate $m24
              $m24-organization))
            ($authority-participants
              (CP2AuthorityParticipants $contact $m24-organization $m260-pre))
            ($participating-contact
              (CP2ContactWithAuthorityParticipants $contact $authority-participants))
            ($developmental
              (CP2M24DevelopmentalOrganization $m24-organization))
            ($base-cut (CPMakeCut $participating-contact $predecessor))
            ($m24-cut (CP2CutWithM24Certificate $base-cut $m24-certificate
              $m24 $m24-organization))
            ($m260-cut (CP2CutWithM260Certificate $m24-cut $m260-certificate
              $m24 $m24-organization $m260 $m260-pre))
            ($configuration (CPContactConfiguration $participating-contact))
            ($facts (CPFactExpressionsAt $m260-cut
              (index-atom $configuration 7) 0))
            ($m263-certificate (M263ConstitutiveCertificate $m260-cut $facts
              $m260 $m260-pre $m260-certificate))
            ($encounter (CP2M25Encounter $participating-contact $predecessor
              $developmental $m24-certificate $m260-certificate
              $m263-certificate $m24 $m24-organization $m260 $m260-pre)))
       (if (CPShape $encounter constitutive-encounter 7)
         (let* (($cut (index-atom $encounter 1))
                ($movement (index-atom $encounter 5))
                ($family (CP2M260BridgeFamilyForEncounter $encounter))
                ($standing (CP2M260MovementOccurrenceStanding $cut $movement
                  $m260 $family))
                ($m25-certificate
                  (M25ConstitutiveCertificate $encounter $developmental))
                ($m255-certificate
                  (M255ConstitutiveCertificate $encounter $developmental
                    $m25-certificate))
                ($joint (authority-participation-joint-v8
                  (index-atom $contact 1) $m24 $m24-organization $m260 $m260-pre
                  (CPDRelationKnown $cut contact-occurrence-grounding)
                  $family $standing (index-atom $m24-organization 3)
                  finite-non-reconstruction $m260-certificate
                  $m263-certificate $m24-certificate $m25-certificate
                  $m255-certificate)))
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
