!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

; Canonical: the M24 answerability anchor and M26.0 occurrence relations are
; material inside the same joint carried by the formed encounter.
!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m24-organization (M24ContactOrganization $m24))
        ($m260 (CP2M260Organization $contact))
        ($pre (CP2M260PreMovementOrganization $m260))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $m260))
        ($joint (index-atom $grounded 1))
        ($encounter (index-atom $grounded 2)))
  (footprint-case canonical
    (== (index-atom $joint 9) (index-atom $m24-organization 3))
    (CP2SameOccurrenceFamilyValid (index-atom $pre 2))
    (CP2PersistentFormFamilyValid (index-atom $pre 3))
    (CPShape (index-atom $pre 4) dws-family 8)
    (CPShape (index-atom $pre 5) opc-at 5)
    (== (index-atom (index-atom $pre 6) 1) true)
    (== (index-atom (index-atom $pre 7) 3) true)
    (CPShape (index-atom $joint 7) g-reading-of 5)
    (CP2SameBecomingCertificateValid $m260 (index-atom $joint 8))
    (CP2AuthorityJointMatchesEncounter $joint $encounter)))

; M26.0 remains valid at its base schema, but losing one required preserved
; relation defeats structural fidelity and therefore holds the encounter.
!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (R3M260WithoutPreservedStructure
          (CP2M260Organization $contact)))
        ($pre (CP2M260PreMovementOrganization $m260))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $m260)))
  (footprint-case structural-fidelity-severed
    (M260OrganizationValid $m260)
    (== (index-atom (index-atom $pre 7) 3) false)
    (CP2M260PreMovementValid $m260 $pre)
    (CPShape $grounded authority-grounded-encounter 3)))

; Finite observations cannot be promoted to reconstruction of the occurrence.
; Collapsing the explicit alternative defeats opacity and contact incorporation.
!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (R3M260WithCollapsedAmbiguity
          (CP2M260Organization $contact)))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $m260)))
  (footprint-case opacity-severed
    (M260AmbiguityValid $m260)
    (M260OrganizationValid $m260)
    (CPShape $grounded authority-grounded-encounter 3)))

; SameOccurrence alone cannot compensate for unchanged local boundaries:
; persistent form becomes unresolved before possible movement is admitted.
!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (R3M260WithUnchangedBoundary
          (CP2M260Organization $contact)))
        ($pre (CP2M260PreMovementOrganization $m260))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $m260)))
  (footprint-case persistent-form-severed
    (M260OrganizationValid $m260)
    (CP2SameOccurrenceFamilyValid (index-atom $pre 2))
    (CPShape (index-atom (index-atom $pre 3) 1)
      persistent-form-unresolved 2)
    (CP2M260PreMovementValid $m260 $pre)
    (CPShape $grounded authority-grounded-encounter 3)))

; Collapsing O/P/C onto one aspect leaves the base occurrence legible while
; defeating the differentiated OPC participation needed by this joint.
!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (R3M260WithCollapsedOPC (CP2M260Organization $contact)))
        ($pre (CP2M260PreMovementOrganization $m260))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $m260)))
  (footprint-case opc-severed
    (M260OrganizationValid $m260)
    (CPShape (index-atom $pre 4) dws-family 8)
    (CPShape (index-atom $pre 5) opc-unresolved 2)
    (CP2M260PreMovementValid $m260 $pre)
    (CPShape $grounded authority-grounded-encounter 3)))

; These are post-movement qualification severances: neither a detached
; Generated reading nor a detached contact anchor can survive the joint.
!(let* (($contact (R3RuntimeContact))
        ($grounded (CP2Encounter $contact ()))
        ($joint (index-atom $grounded 1)))
  (footprint-case qualified-generated-severed
    (CP2AuthorityJointValid (R3JointWithoutQualifiedGenerated $joint))))

!(let* (($contact (R3RuntimeContact))
        ($grounded (CP2Encounter $contact ()))
        ($joint (index-atom $grounded 1)))
  (footprint-case contact-answerability-severed
    (CP2AuthorityJointValid (R3JointWithoutContactAnswerability $joint))))
