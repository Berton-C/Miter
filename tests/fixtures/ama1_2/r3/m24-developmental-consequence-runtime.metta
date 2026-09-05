!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

!(let $result (AssistantEncounterV2 (R3ProbeRuntimeContact))
  (m24-runtime-consequence contact (index-atom $result 0)))

!(let* (($scope (CPContactScope (R3ProbeRuntimeContact)))
        ($active (ARActiveRows $scope))
        ($movement (index-atom (index-atom $active 0) 3))
        ($result (AssistantConsequenceV2 $scope
          (R3ProbeConsequence (index-atom $movement 2)))))
  (m24-runtime-consequence returned (index-atom $result 0)))

!(let* (($scope (CPContactScope (R3ProbeRuntimeContact)))
        ($history (collapse (match &assistant_history $row $row)))
        ($active (ARActiveRows $scope))
        ($next-cut (index-atom (index-atom $active 0) 2))
        ($consequence-rows (collapse (match &assistant_history
          (assistant-history consequence consequence-probe-return $row-scope $payload)
          $payload)))
        ($payload (index-atom $consequence-rows 0))
        ($transition (index-atom (index-atom $payload 1) 2))
        ($evolved (index-atom $transition 2))
        ($lifecycle (M24DevelopmentalLifecycle $evolved)))
  (m24-runtime-consequence canonical
    (size-atom $history) (size-atom $active)
    (CPDRelationKnown $next-cut m24-consequence-developmental-grounding)
    (M24DevelopmentalTransitionValid $transition)
    (M24LifecycleProbeStanding $lifecycle)
    (M24RetrospectiveAffordanceValid
      (index-atom (index-atom $evolved 8) 2))
    (AR2AllHistoryValid $history 0)))

!(let* (($scope (CPContactScope (R3ProbeRuntimeContact)))
        ($active (ARActiveRows $scope))
        ($movement (index-atom (index-atom $active 0) 3))
        ($duplicate (AssistantConsequenceV2 $scope
          (R3ProbeConsequence (index-atom $movement 2))))
        ($history (collapse (match &assistant_history $row $row))))
  (m24-runtime-consequence duplicate
    (index-atom $duplicate 0) (size-atom $history)))
