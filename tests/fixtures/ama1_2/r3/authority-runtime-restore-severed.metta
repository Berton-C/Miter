!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

!(let* (($contact (R3RuntimeContact))
        ($grounded (CP2Encounter $contact ()))
        ($joint (index-atom $grounded 1))
        ($severed (R3JointWithoutSameBecoming $joint))
        ($snapshot (R3SnapshotFromGrounded $contact $grounded $severed))
        ($restored (AssistantRestoreV2 $snapshot))
        ($history (collapse (match &assistant_history $row $row)))
        ($active (collapse (match &assistant_state $row $row))))
  (restore-case severed-same-becoming $restored
    (size-atom $history) (size-atom $active)))
