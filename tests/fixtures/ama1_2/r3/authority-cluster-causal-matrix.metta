!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/authority_inheritance_v1.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-cluster-data.metta")

; M24 contact/provenance/frame causality.
!(let* (($contact (R3M24Canonical))
        ($valid (M24ContactValid $contact)))
  (case-result m24-canonical $valid))

!(let* (($contact (R3M24SealSevered))
        ($valid (M24ContactValid $contact)))
  (case-result m24-sever-seal $valid))

!(let* (($contact (R3M24FrameOverlapSevered))
        ($valid (M24ContactValid $contact)))
  (case-result m24-sever-frame-partiality $valid))

!(let* (($contact (R3M24ContactStandingSevered))
        ($valid (M24ContactValid $contact)))
  (case-result m24-sever-direct-contact-standing $valid))

!(let* (($contact (R3M24Canonical))
        ($valid (M24ContactValid $contact)))
  (case-result m24-restored $valid))

; M26.0 one-occurrence, opacity, and persistence causality.
!(let* (($organization (R3M260Canonical))
        ($valid (M260OrganizationValid $organization))
        ($same (M260SameOcc $organization part-before part-after))
        ($persistent (M260PersistentForm $organization part-before part-after)))
  (case-result m260-canonical (result $valid $same $persistent)))

!(let* (($organization (R3M260ManifestationSevered))
        ($valid (M260OrganizationValid $organization))
        ($recognition (M260RecognitionGrounded $organization
          (recognizes view-observer aspect-consciousness evidence-observer part-observer))))
  (case-result m260-sever-manifestation (result $valid $recognition)))

!(let* (($organization (R3M260BoundarySevered))
        ($valid (M260OrganizationValid $organization))
        ($persistent (M260PersistentForm $organization part-before part-after)))
  (case-result m260-sever-boundary-change (result $valid $persistent)))

!(let* (($organization (R3M260Canonical))
        ($same (M260SameBecoming $organization movement-alpha
          (l2425 movement-other evidence-l2425)
          (same-becoming-witness movement-alpha occurrence-alpha
            (l2425 movement-alpha evidence-l2425) evidence-same-becoming))))
  (case-result m260-sever-l2425 $same))

!(let* (($organization (R3M260NeutralOrder))
        ($valid (M260OrganizationValid $organization))
        ($same (M260SameOcc $organization part-before part-after))
        ($persistent (M260PersistentForm $organization part-before part-after))
        ($opc (M260OPCAt $organization)))
  (case-result m260-neutral-order (result $valid $same $persistent $opc)))

!(let* (($organization (R3M260Canonical))
        ($valid (M260OrganizationValid $organization))
        ($same (M260SameOcc $organization part-before part-after))
        ($persistent (M260PersistentForm $organization part-before part-after))
        ($opc (M260OPCAt $organization)))
  (case-result m260-restored (result $valid $same $persistent $opc)))
