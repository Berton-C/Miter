!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (CP2M260Organization $contact))
        ($severed (R3M24WithoutSeal $m24))
        ($grounded (CP2EncounterFromAuthority $contact () $severed $m260))
        ($result (AR2IncorporateGrounded contact-scope-alpha
          (CPContactScope $contact) $grounded))
        ($history (collapse (match &assistant_history $row $row))))
  (runtime-case m24-sever
    (CPShape $grounded authority-grounded-encounter 3)
    (index-atom $result 0) (size-atom $history)))

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($m260 (CP2M260Organization $contact))
        ($severed (R3M260WithoutManifestation $m260))
        ($grounded (CP2EncounterFromAuthority $contact () $m24 $severed))
        ($result (AR2IncorporateGrounded contact-scope-alpha
          (CPContactScope $contact) $grounded))
        ($history (collapse (match &assistant_history $row $row))))
  (runtime-case m260-sever
    (CPShape $grounded authority-grounded-encounter 3)
    (index-atom $result 0) (size-atom $history)))

!(let* (($result (AssistantEncounterV2 (malformed-contact)))
        ($history (collapse (match &assistant_history $row $row))))
  (runtime-case malformed-contact (index-atom $result 0) (size-atom $history)))

!(let* (($contact (R3NeutralRuntimeContact))
        ($result (AssistantEncounterV2 $contact))
        ($history (collapse (match &assistant_history $row $row)))
        ($active (collapse (match &assistant_state $row $row))))
  (runtime-case neutral-order (index-atom $result 0)
    (size-atom $history) (size-atom $active)))

!(let* (($contact (R3NeutralRuntimeContact))
        ($duplicate (AssistantEncounterV2 $contact))
        ($history (collapse (match &assistant_history $row $row)))
        ($active (collapse (match &assistant_state $row $row))))
  (runtime-case duplicate (index-atom $duplicate 0)
    (size-atom $history) (size-atom $active)))
