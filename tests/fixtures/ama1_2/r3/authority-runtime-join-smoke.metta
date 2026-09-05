!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

!(let* (($contact (R3RuntimeContact))
        ($result (AssistantEncounterV2 $contact))
        ($incorporated (CPShape $result assistant-contact-incorporated 3)))
  (join-incorporated $incorporated
    (index-atom $result 0)
    (if $incorporated
      (let $reason (index-atom $result 2)
        (if (is-expr $reason) (index-atom $reason 0) $reason)) no-reason)))

!(let $history (collapse (match &assistant_history
    (assistant-history encounter contact-scope-alpha $scope $payload)
    (assistant-history encounter contact-scope-alpha $scope $payload)))
  (join-history-count (size-atom $history)))

!(match &assistant_history
  (assistant-history encounter contact-scope-alpha $scope $payload)
  (join-history-valid (AR2HistoryValid
    (assistant-history encounter contact-scope-alpha $scope $payload))))

!(match &assistant_state
  (active-organization $scope $cut $movement)
  (join-active (CPDRelationKnown $cut contact-occurrence-grounding)
    (ARMovementSummary $movement)))
