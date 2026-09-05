!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v2.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-runtime-data.metta")

(= (R3M25TestData)
   (let* (($contact (R3RuntimeContact))
          ($m24 (CP2M24Contact $contact))
          ($m24-organization (M24ContactOrganization $m24))
          ($developmental (CP2M24DevelopmentalOrganization $m24-organization))
          ($m260 (CP2M260Organization $contact))
          ($m260-pre (CP2M260PreMovementOrganization $m260))
          ($participants (CP2AuthorityParticipants $contact $m24-organization $m260-pre))
          ($participating-contact (CP2ContactWithAuthorityParticipants $contact $participants))
          ($cut (CPMakeCut $participating-contact ()))
          ($configuration (CPContactConfiguration $participating-contact))
          ($facts (CPFactExpressionsAt $cut (index-atom $configuration 7) 0))
          ($flourishing (CPFlourishingOrganizationV2 $cut (index-atom $configuration 8)))
          ($readings (participant-reentry-organization
            differentiated-by-source-scope-and-lineage
            (CPParticipantAt $cut (index-atom $configuration 10) 0)
            repeated-same-lineage-is-not-independent-support))
          ($participant-relations (CPParticipantRelationOrganization $readings))
          ($revised-cut (CPApplyParticipantRelations $cut $participant-relations))
          ($bridge (CPBridgeOrganizationV2 $revised-cut $facts $flourishing
            $readings $participant-relations))
          ($possibilities (CPNativePossibilitiesV2 $revised-cut $facts
            $flourishing $participant-relations))
          ($primaries (M25PrimaryAt $possibilities $revised-cut $facts
            $flourishing $participant-relations $bridge
            (index-atom $configuration 7)
            (index-atom $configuration 8) (index-atom $configuration 10)
            (index-atom $contact 8) $developmental 0)))
     (m25-test-data $revised-cut $facts $flourishing $participant-relations
       $developmental (index-atom $configuration 7)
       (index-atom $configuration 8) (index-atom $configuration 10)
       (index-atom $contact 8) $possibilities $primaries $readings $bridge)))

(= (R3M25PrimaryForAt $primaries $form $i)
   (if (< $i (size-atom $primaries))
     (let $primary (index-atom $primaries $i)
       (if (== (index-atom $primary 2) $form) $primary
         (R3M25PrimaryForAt $primaries $form (+ $i 1))))
     (m25-primary-unresolved $form)))

(= (R3M25PrimaryFor $data $form)
   (R3M25PrimaryForAt (index-atom $data 11) $form 0))

(= (R3M25PrimaryOnCut $data $form $cut)
   (let* (($source (R3M25PrimaryFor $data $form))
          ($bridge (CPBridgeOrganizationV2 $cut (index-atom $data 2)
            (index-atom $data 3) (index-atom $data 12)
            (index-atom $data 4))))
     (M25PrimaryMovement (index-atom $source 9) $cut
       (index-atom $data 2) (index-atom $data 3) (index-atom $data 4) $bridge
       (index-atom $data 6) (index-atom $data 7) (index-atom $data 8)
       (index-atom $data 9) (index-atom $data 5))))

(= (R3M25PrimaryWithBalance $primary $balance)
   (m25-primary-movement-v2
     (index-atom $primary 1) (index-atom $primary 2)
     (index-atom $primary 3) (index-atom $primary 4) $balance
     (index-atom $primary 6) (index-atom $primary 7)
     (index-atom $primary 8) (index-atom $primary 9)
     (index-atom $primary 10)))

(= (R3M25BalanceWithBridge $balance $bridge)
   (balance-unfolding-as-intelligence
     (index-atom $balance 1)
     (fact9-flourishing-constitutive-joint $bridge)
     (index-atom $balance 3) (index-atom $balance 4)))

(= (R3M25BridgeFact9Severed $bridge)
   (bridge-organization
     (index-atom $bridge 1) (index-atom $bridge 2) (index-atom $bridge 3)
     (fact9-expressions-severed (index-atom (index-atom $bridge 4) 1))
     (index-atom $bridge 5) (index-atom $bridge 6) (index-atom $bridge 7)
     (index-atom $bridge 8) (index-atom $bridge 9) (index-atom $bridge 10)
     (index-atom $bridge 11) (index-atom $bridge 12)))

(= (R3M25BridgeFlourishingSevered $bridge)
   (bridge-organization
     (index-atom $bridge 1) (index-atom $bridge 2) (index-atom $bridge 3)
     (index-atom $bridge 4)
     (flourishing-expressions-severed
       (index-atom (index-atom $bridge 5) 1))
     (index-atom $bridge 6) (index-atom $bridge 7) (index-atom $bridge 8)
     (index-atom $bridge 9) (index-atom $bridge 10) (index-atom $bridge 11)
     (index-atom $bridge 12)))

(= (R3M25SurfaceWithBalance $surface $balance)
   (m25-rap-surface-v2
     (index-atom $surface 1) (index-atom $surface 2)
     (index-atom $surface 3) (index-atom $surface 4)
     (index-atom $surface 5) (balance-unfolding-alignment $balance)
     (index-atom $surface 7)))

(= (R3M25RAPWithSurface $rap $surface)
   (rap-read-v2 $surface (index-atom $rap 2) (index-atom $rap 3)
     (index-atom $rap 4) (index-atom $rap 5)))

(= (R3M25CutWithoutInterfaces $cut)
   (constitutive-cut
     (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
     (index-atom $cut 4) (index-atom $cut 5) (index-atom $cut 6)
     (index-atom $cut 7) (I ()) (index-atom $cut 9) (index-atom $cut 10)
     (index-atom $cut 11) (index-atom $cut 12) (index-atom $cut 13)))

(= (R3M25DPFWithSoulStanding $dpf)
   (dynamic-participatory-fourthness-v1
     (index-atom $dpf 1) (index-atom $dpf 2) (index-atom $dpf 3)
     (index-atom $dpf 4) (index-atom $dpf 5) (index-atom $dpf 6)
     (C ((soul-standing accepted-as-carrier-field)))
     (index-atom $dpf 8) (index-atom $dpf 9) (index-atom $dpf 10)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($possibilities (index-atom $data 10))
        ($primaries (index-atom $data 11)))
  (m25-primary-case formation
    (CPCutValid $cut)
    (M24DevelopmentalOrganizationValid $developmental)
    (size-atom $possibilities) (size-atom $primaries)
    (M25PrimaryMovementValid (index-atom $primaries 0))
    (M25PrimaryMovementValid (index-atom $primaries 1))
    (M25PrimaryMovementValid (index-atom $primaries 2))))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($relatedness (M25RelatednessProfile $primary $cut))
        ($precision (M25PrecisionProfile $primary $cut)))
  (m25-primary-case material-floors
    (index-atom $primary 2)
    (CPShape $relatedness relatedness-profile 4)
    (index-atom $relatedness 3)
    (CPShape $precision precision-profile 4)
    (index-atom $precision 3)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($rap (M25RAPReadings $primary $cut $developmental))
        ($surface (index-atom $rap 1))
        ($perspectives (index-atom $rap 2))
        ($appropriateness (index-atom $perspectives 2))
        ($read-app (index-atom $appropriateness 3))
        ($admissibility (index-atom $read-app 3)))
  (m25-primary-case rap
    (M25Adm25WitnessValid $primary $admissibility)
    (M25AppropriatenessValid $primary $surface $appropriateness)
    (M25RAPValid $primary $rap)
    (index-atom (index-atom $rap 3) 1)
    (index-atom $surface 7)
    (CPShape (M25HarmonicAlignment $primary $rap)
      harmonic-alignment-witness 7)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($balance (index-atom $primary 5))
        ($bridge (index-atom (index-atom $balance 2) 1))
        ($rap (M25RAPReadings $primary $cut $developmental))
        ($surface (index-atom $rap 1))
        ($perspectives (index-atom $rap 2)))
  (m25-primary-case constitutive-joint
    (M25Fact9FlourishingBridgeValid $bridge
      (index-atom $primary 3) (index-atom $primary 4))
    (M25BalanceUnfoldingValid $balance
      (index-atom $primary 3) (index-atom $primary 4))
    (== $bridge (index-atom $data 13))
    (== (index-atom (index-atom $surface 6) 1) $balance)
    (== (index-atom (index-atom $perspectives 1) 1)
      (index-atom (index-atom $perspectives 2) 1))
    (== (index-atom (index-atom $perspectives 2) 1)
      (index-atom (index-atom $perspectives 3) 1))))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($balance (index-atom $primary 5))
        ($bridge (index-atom (index-atom $balance 2) 1))
        ($fact-severed-balance (R3M25BalanceWithBridge $balance
          (R3M25BridgeFact9Severed $bridge)))
        ($flourishing-severed-balance (R3M25BalanceWithBridge $balance
          (R3M25BridgeFlourishingSevered $bridge)))
        ($fact-severed-primary
          (R3M25PrimaryWithBalance $primary $fact-severed-balance))
        ($flourishing-severed-primary
          (R3M25PrimaryWithBalance $primary $flourishing-severed-balance))
        ($rap (M25RAPReadings $primary $cut $developmental))
        ($disconnected-surface
          (R3M25SurfaceWithBalance (index-atom $rap 1) $fact-severed-balance)))
  (m25-causal-case constitutive-joint-severed
    (M25PrimaryMovementValid $primary)
    (M25PrimaryMovementValid $fact-severed-primary)
    (M25PrimaryMovementValid $flourishing-severed-primary)
    (M25RAPValid $primary (R3M25RAPWithSurface $rap $disconnected-surface))))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($primaries (index-atom $data 11))
        ($movement-readings (M25ReadingsAt $primaries $cut $developmental 0))
        ($movement (M25ConstructMovement $movement-readings)))
  (m25-primary-case construction
    (size-atom $movement-readings)
    (index-atom $movement 0)
    (if (CPShape $movement movement-formed 7)
      (index-atom $movement 1) no-form)
    (if (CPShape $movement movement-formed 7)
      (index-atom $movement 2) no-id)
    (if (CPShape $movement movement-formed 7)
      (CPShape (index-atom (index-atom $movement 6) 2)
        continuation-basis-v3 6) false)))

!(let* (($contact (R3RuntimeContact))
        ($grounded (CP2Encounter $contact ()))
        ($encounter (if (CPShape $grounded authority-grounded-encounter 3)
          (index-atom $grounded 2) ()))
        ($movement (if (CPShape $encounter constitutive-encounter 7)
          (index-atom $encounter 5) ())))
  (m25-primary-case runtime
    (CPShape $grounded authority-grounded-encounter 3)
    (CPShape $encounter constitutive-encounter 7)
    (if (is-expr $movement) (index-atom $movement 0) no-movement)
    (ARMovementSummary $movement)
    (AR2MovementConstitutivelyConsistent
      (if (CPShape $encounter constitutive-encounter 7)
        (index-atom $encounter 1) ()) $movement)))

!(let* (($data (R3M25TestData))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($dpf (index-atom $primary 4)))
  (m25-causal-case ambient-soul
    (M25DynamicParticipatoryFourthnessValid $dpf)
    (M25DynamicParticipatoryFourthnessValid
      (R3M25DPFWithSoulStanding $dpf))
    (M25RAPValid $primary (rap-scalar 1 1 1))))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($severed-cut (M25CutWithoutRelation $cut relation-request))
        ($primary (R3M25PrimaryOnCut $data undertaking $severed-cut))
        ($relatedness (M25RelatednessProfile $primary $severed-cut))
        ($rap (M25RAPReadings $primary $severed-cut (index-atom $data 5)))
        ($appropriateness (index-atom (index-atom $rap 2) 2)))
  (m25-causal-case relation-severed
    (CPCutValid $severed-cut) (index-atom $primary 0)
    (index-atom $relatedness 3)
    (index-atom (index-atom $appropriateness 3) 0)
    (index-atom (index-atom $rap 3) 1)
    (index-atom (M25HarmonicAlignment $primary $rap) 0)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($severed-cut (M25CutWithoutDistinction $cut distinction-authorship))
        ($primary (R3M25PrimaryOnCut $data undertaking $severed-cut))
        ($precision (M25PrecisionProfile $primary $severed-cut))
        ($rap (M25RAPReadings $primary $severed-cut (index-atom $data 5)))
        ($appropriateness (index-atom (index-atom $rap 2) 2)))
  (m25-causal-case distinction-severed
    (CPCutValid $severed-cut) (index-atom $primary 0)
    (index-atom $precision 3)
    (index-atom (index-atom $appropriateness 3) 0)
    (index-atom (index-atom $rap 3) 1)
    (index-atom (M25HarmonicAlignment $primary $rap) 0)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($defer-cut (R3M25CutWithoutInterfaces $cut))
        ($defer-primary (R3M25PrimaryOnCut $data defer $defer-cut))
        ($change (M25InterfaceChange $defer-primary)))
  (m25-causal-case interface-change
    (CPCutValid $defer-cut)
    (index-atom (index-atom $defer-primary 6) 1)
    (CPShape $change interface-change 5)
    (index-atom $change 3)))

!(let* (($data (R3M25TestData))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($canonical (M25Energetics $primary))
        ($high-action-low-forcing (m25-energetics-v1
          (index-atom $primary 1)
          (E-phys synthetic-process-participating)
          (E-rep symbolic-representation-participating)
          (E-act high-action-expenditure)
          (E-force no-demonstrated-unnecessary-forcing)
          (G generation-is-not-energy) pairwise-non-identical-types)))
  (m25-causal-case energetics
    (M25EnergeticsValid $primary $canonical)
    (M25EnergeticsValid $primary $high-action-low-forcing)
    (!= (index-atom $high-action-low-forcing 4)
      (index-atom $high-action-low-forcing 5))))

!(let* (($pns (m25-trajectory-basis-v1 trajectory-pns
          contact-uptake-returned relational-openness-retained
          material-distinctions-preserved receptive-attention-present
          differentiation-with-coherence-present
          no-demonstrated-unnecessary-forcing consequence-answerable
          interface-open self-weaving-plasticity-present
          frame-topology-revisable pivot-available decisive-fast
          (trajectory-provenance returned-contact consequence-alpha)))
        ($sns (m25-trajectory-basis-v1 trajectory-sns
          material-contact-excluded relational-openness-collapsed
          material-distinctions-preserved attention-captured
          differentiation-with-coherence-present unnecessary-forcing-present
          consequence-unanswerable interface-narrowed self-weaving-rigid
          frame-topology-persists pivot-available forced-velocity-present
          (trajectory-provenance returned-contact consequence-beta)))
        ($stuck (m25-trajectory-basis-v1 trajectory-stuck
          material-contact-excluded relational-openness-collapsed
          material-distinctions-preserved attention-captured
          differentiation-with-coherence-present force-residue-present
          consequence-unanswerable interface-narrowed self-weaving-rigid
          frame-topology-persists pivot-functionally-unavailable
          forced-velocity-present
          (trajectory-provenance returned-contact consequence-gamma))))
  (m25-causal-case shared-trajectory
    (M25PNSLike $pns) (M25SNSLike $pns) (M25Stuck $pns)
    (M25PNSLike $sns) (M25SNSLike $sns) (M25Stuck $sns)
    (M25SNSLike $stuck) (M25Stuck $stuck)
    (index-atom (M25OrientationFromBasis $pns) 2)
    (index-atom (M25OrientationFromBasis $sns) 2)
    (index-atom (M25OrientationFromBasis $stuck) 2)))

!(let* (($data (R3M25TestData))
        ($cut (index-atom $data 1))
        ($developmental (index-atom $data 5))
        ($primary (R3M25PrimaryFor $data undertaking))
        ($rap (M25RAPReadings $primary $cut $developmental))
        ($model (bounded-model-witness-v1 bounded-model-alpha
          (index-atom $primary 1)
          (bounded-model-domain exact-fixture-scope finite)
          (independent-evaluation witness-alpha non-self-certifying)
          correct-consequence-law-witnessed no-omitted-disturbance-witnessed
          (provenance evaluator-alpha evaluation-event-alpha)))
        ($self-certified (bounded-model-witness-v1 bounded-model-alpha
          (index-atom $primary 1)
          (bounded-model-domain exact-fixture-scope finite)
          movement-self-certification
          correct-consequence-law-witnessed no-omitted-disturbance-witnessed
          (provenance movement-self evaluation-event-alpha)))
        ($outcome (harmonic-outcome-witness-v1 (index-atom $primary 1)
          (returned-consequence consequence-alpha contact-retained)
          (continued-material-organization relation-request)
          (provenance consequence-alpha exact-lineage))))
  (m25-causal-case bounded-harmonic
    (M25BoundedModelWitnessValid $primary $model)
    (M25BoundedModelWitnessValid $primary $self-certified)
    (CPShape (M25BoundedHarmonicContinuation $primary $rap $model $outcome)
      bounded-harmonic-continuation-consistent-v1 6)
    (CPShape (M25BoundedHarmonicContinuation $primary $rap $model
      (non-harmonic-outcome consequence-beta))
      renewed-actuality-premise-gap-v1 7)))

!(let* (($canonical (CP2Encounter (R3RuntimeContact) ()))
        ($neutral (CP2Encounter (R3NeutralRuntimeContact) ()))
        ($canonical-encounter (index-atom $canonical 2))
        ($neutral-encounter (index-atom $neutral 2)))
  (m25-causal-case neutral-permutation
    (CPShape $canonical authority-grounded-encounter 3)
    (CPShape $neutral authority-grounded-encounter 3)
    (ARMovementSummary (index-atom $canonical-encounter 5))
    (ARMovementSummary (index-atom $neutral-encounter 5))))
