!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($organization (M24ContactOrganization $m24))
        ($developmental (CP2M24DevelopmentalOrganization $organization))
        ($grounded (CP2Encounter $contact ()))
        ($cut (index-atom (index-atom $grounded 2) 1)))
  (m24-developmental-case canonical
    (M24DevelopmentalOrganizationValid $developmental)
    (M24CarrierOpenDischargeValid (index-atom $developmental 3))
    (M24ProspectiveAttachmentValid (index-atom $developmental 4))
    (M24DerivedSelfGenValid (index-atom $developmental 5))
    (M24InterpretationStateValid (index-atom $developmental 6))
    (M24AvailabilityStateValid (index-atom $developmental 7))
    (M24AffordanceStateValid (index-atom $developmental 8))
    (M24TractionStateValid (index-atom $developmental 9))
    (M24FramePluralityValid (index-atom $developmental 10))
    (M24WriterBoundaryValid (index-atom $developmental 11))
    (M24BranchTransactionValid (index-atom $developmental 12))
    (CPDRelationKnown $cut m24-developmental-grounding)))

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($organization (M24ContactOrganization $m24))
        ($developmental (CP2M24DevelopmentalOrganization $organization))
        ($severed (R3M24DevelopmentalWithCollapsedDischarge $developmental))
        ($severed-organization
          (R3M24OrganizationWithDevelopmental $organization $severed))
        ($m260 (CP2M260Organization $contact))
        ($pre (CP2M260PreMovementOrganization $m260))
        ($grounded (CP2EncounterFromAuthorityOrganizations $contact ()
          $m24 $severed-organization $m260 $pre)))
  (m24-developmental-case open-discharge-severed
    (M24DevelopmentalOrganizationValid $severed)
    (CP2M24ContactOrganizationValid $m24 $severed-organization)
    (CPShape $grounded authority-grounded-encounter 3)))

!(let* (($derivations
          ((derivation d1 internal-generation seed atom-a (prov-generate e1 ((prov-contact s1))))
           (derivation d2 render atom-a atom-b (prov-generate e2 ((prov-contact s1))))
           (derivation d3 inference atom-b atom-c (prov-infer e3 ((prov-contact s1))))))
        ($selfgen (M24DerivedSelfGen $derivations (seed)))
        ($reach (index-atom $selfgen 2)))
  (m24-developmental-case derived-selfgen
    (M24DerivedSelfGenValid $selfgen)
    (CPHas seed $reach 0) (CPHas atom-a $reach 0)
    (CPHas atom-b $reach 0) (CPHas atom-c $reach 0)))

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($developmental (M24DevelopmentalOrganization $m24))
        ($initial (M24DevelopmentalLifecycle $developmental))
        ($candidate (index-atom $initial 1))
        ($frame (index-atom $candidate 1))
        ($scope (index-atom (index-atom $m24 6) 4))
        ($probe (probe-witness-v1 $frame $candidate inspect-route $scope
          bounded-reversible information-seeking
          (returned-contact probe-effect observed probe-evidence) probe-authorizer))
        ($probed (M24AdvanceProbeEligible $initial $probe))
        ($probe-standing (index-atom $probed 2))
        ($selfgen (index-atom $developmental 5))
        ($route (index-atom $m24 3))
        ($seal (index-atom $m24 4))
        ($package (governing-authority-package-v1 $probe-standing $seal $route
          (route-discrimination-v1 (index-atom $route 1)
            world-one observation-one world-two observation-two
            distinction-alpha inquiry-relevant-distinction)
          (material-contribution fresh-event contact $scope distinction-alpha)
          (fresh-material-support fresh-event after-assembly contact-support
            not-in-witness-support materially-relevant)
          (independent-of-selfgen fresh-event true)
          (soul-admission admitted constitutional-organization)
          (live-continuation live-item-alpha $scope grounded)))
        ($authoritative (M24AdvanceAuthoritative $probed $m24 $selfgen $package))
        ($authority-standing (index-atom $authoritative 3))
        ($retrospective (retrospective-affordance-v1 $frame inspect-route
          exercise-event returned-contact changed-participation))
        ($durability (durability-witness-v1 $authority-standing $retrospective
          permeability-preserved developmental-standing-preserved
          (soul-admission admitted constitutional-organization)))
        ($durable (M24AdvanceDurable $authoritative $durability)))
  (m24-developmental-case lifecycle
    (M24LifecycleValid $initial)
    (M24LifecycleValid $probed)
    (M24GoverningPackageValid $m24 $selfgen $probe-standing $package)
    (M24LifecycleValid $authoritative)
    (M24LifecycleValid $durable)
    (CPShape (index-atom $durable 4) durable-standing 4)))

!(let* (($scope (scope principal-alpha audience-alpha project-alpha))
        ($losses ((lost-in distinction-latency $scope loss-event)))
        ($available ((available-in distinction-latency $scope recovery-cut)))
        ($recovery (reintroduce distinction-latency $scope prior-cut recovery-cut
          (semantic-recovery-witness distinction-latency $scope retained-side-information
            exact-dependent-witness) reintroducer))
        ($wrong (reintroduce distinction-latency other-context prior-cut recovery-cut
          (semantic-recovery-witness distinction-latency other-context
            retained-side-information exact-dependent-witness) reintroducer)))
  (m24-developmental-case recovery
    (M24ReintroductionValid $losses $available $recovery)
    (M24ReintroductionValid $losses $available $wrong)))

!(let* (($full (stuck-evidence-v1 live-demand-persists discrepancy-persists
          effect-equivalent-recurrence frame-reinforcement reachability-not-opening
          relevant-contact-discriminating distinction-dies-in-active-frame))
        ($repetition-only (stuck-evidence-v1 no-live-demand no-discrepancy
          effect-equivalent-recurrence no-frame-reinforcement reachability-open
          contact-not-established distinction-not-dead)))
  (m24-developmental-case stuck
    (M24ComputedStuck $full) (M24ComputedStuck $repetition-only)))

!(let* (($scope (scope principal-alpha audience-alpha project-alpha))
        ($plural (frame-plurality-v1 (frame-a frame-b)
          (scoped-joint-use (frame-a frame-b) $scope
            (local-compatibility-witness frame-a frame-b)
            (retained-tension-witness tension-a tension-b))
          no-global-amalgamation-required))
        ($collapsed (frame-plurality-v1 (frame-a frame-b)
          global-frame-implied no-global-amalgamation-required)))
  (m24-developmental-case plurality
    (M24FramePluralityValid $plural) (M24FramePluralityValid $collapsed)))

!(let* (($contact (R3RuntimeContact))
        ($m24 (CP2M24Contact $contact))
        ($transaction (M24BranchTransactionFor $m24))
        ($event (index-atom $transaction 1))
        ($recommit (branch-transaction $event ($event)
          ((contact-patch duplicate)) ($event) contact-recorder)))
  (m24-developmental-case branch-transaction
    (M24BranchTransactionValid $transaction)
    (M24BranchTransactionValid $recommit)))
