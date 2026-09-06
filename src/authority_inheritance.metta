; Native finite authority-inheritance substrate.
; This module begins the shared M24/M26.0 lineage used by every later cut.
; It is pure MeTTa: no filesystem, process, model, memory, or effect mechanics.
; These finite witnesses are partial representations, never actuality.

; ---------- Generic finite relation helpers ----------

(= (AIAllIn $xs $ys $i)
   (if (< $i (size-atom $xs))
     (and (CPHas (index-atom $xs $i) $ys 0) (AIAllIn $xs $ys (+ $i 1))) true))

(= (AIDisjoint $xs $ys $i)
   (if (< $i (size-atom $xs))
     (and (== (CPHas (index-atom $xs $i) $ys 0) false)
          (AIDisjoint $xs $ys (+ $i 1))) true))

(= (AIRowHasAt $rows $head $field $value $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (is-expr $row) (> (size-atom $row) $field))
         (if (and (== (index-atom $row 0) $head)
                  (== (index-atom $row $field) $value))
           true (AIRowHasAt $rows $head $field $value (+ $i 1)))
         (AIRowHasAt $rows $head $field $value (+ $i 1)))) false))

(= (AIRowHas $rows $head $field $value) (AIRowHasAt $rows $head $field $value 0))

(= (AIAllRowsShape $rows $head $size $i)
   (if (< $i (size-atom $rows))
     (and (CPShape (index-atom $rows $i) $head $size)
          (AIAllRowsShape $rows $head $size (+ $i 1))) true))

; ---------- Inquiry 24: contact, standing, frames, and use ----------

(= (M24DerivationKind $kind)
   (CPHas $kind
     (internal-generation render inference memory-recall action-execution
       world-return testimony-external-input) 0))

; derivation: id kind source target provenance
(= (M24DerivationValid $row)
   (and (CPShape $row derivation 6)
        (M24DerivationKind (index-atom $row 2))))

(= (M24DerivationsValidAt $rows $i)
   (if (< $i (size-atom $rows))
     (and (M24DerivationValid (index-atom $rows $i))
          (M24DerivationsValidAt $rows (+ $i 1))) true))

(= (M24ProvenanceParentsValidAt $parents $i)
   (if (< $i (size-atom $parents))
     (and (M24ProvenanceValid (index-atom $parents $i))
          (M24ProvenanceParentsValidAt $parents (+ $i 1))) true))

(= (M24ProvenanceValid $prov)
   (if (CPShape $prov prov-contact 2) true
    (if (CPShape $prov prov-testimony 3) true
     (if (or (CPShape $prov prov-memory 3)
          (or (CPShape $prov prov-infer 3)
           (or (CPShape $prov prov-generate 3)
               (CPShape $prov prov-self-trace 3))))
       (let $parents (index-atom $prov 2)
         (and (is-expr $parents)
           (and (> (size-atom $parents) 0)
                (M24ProvenanceParentsValidAt $parents 0)))) false))))

(= (M24DirectContact $prov) (CPShape $prov prov-contact 2))

; event: id proto parents. Proto-time is partial: no event is its own parent.
(= (M24EventValid $event)
   (if (CPShape $event event 4)
     (let $parents (index-atom $event 3)
       (and (is-expr $parents)
         (and (CPUniq $parents 0 ())
              (== (CPHas (index-atom $event 1) $parents 0) false)))) false))

; governed-route: id source payload-reference carried-distinctions standing
(= (M24RouteValid $route)
   (if (CPShape $route governed-route 6)
     (let $distinctions (index-atom $route 4)
       (and (is-expr $distinctions)
         (and (> (size-atom $distinctions) 0)
              (CPUniq $distinctions 0 ())))) false))

; contact-seal: contact-id event-id route-id payload-reference
(= (M24SealMatches $contact-id $event $route $seal)
   (if (CPShape $seal contact-seal 5)
     (and (== (index-atom $seal 1) $contact-id)
      (and (== (index-atom $seal 2) (index-atom $event 1))
       (and (== (index-atom $seal 3) (index-atom $route 1))
            (== (index-atom $seal 4) (index-atom $route 3))))) false))

; raw-field: nodes relations unresolved. Contradiction and incompleteness remain legal.
(= (M24RawFieldValid $raw)
   (if (CPShape $raw raw-field 4)
     (and (is-expr (index-atom $raw 1))
       (and (is-expr (index-atom $raw 2))
            (is-expr (index-atom $raw 3)))) false))

; partial-frame: id represented omitted context resolution competence event provenance domain-witness
(= (M24FrameValid $raw $frame)
   (if (CPShape $frame partial-frame 10)
     (let* (($represented (index-atom $frame 2))
            ($omitted (index-atom $frame 3))
            ($nodes (index-atom $raw 1))
            ($domain (index-atom $frame 9)))
       (and (is-expr $represented)
        (and (is-expr $omitted)
         (and (CPUniq $represented 0 ())
          (and (CPUniq $omitted 0 ())
           (and (AIDisjoint $represented $omitted 0)
            (and (AIAllIn $represented $nodes 0)
             (and (AIAllIn $omitted $nodes 0)
                  (CPShape $domain domain-witness 4))))))))) false))

; standing: provenance warrant support pressure freshness
(= (M24StandingValid $standing)
   (if (CPShape $standing standing 6)
     (and (M24ProvenanceValid (index-atom $standing 1))
       (and (is-expr (index-atom $standing 3))
            (is-expr (index-atom $standing 4)))) false))

(= (M24StandingWarrant $standing)
   (if (M24StandingValid $standing) (index-atom $standing 2) warrant-unresolved))

(= (M24StandingPressure $standing)
   (if (M24StandingValid $standing) (index-atom $standing 4) ()))

(= (M24StandingFreshness $standing)
   (if (M24StandingValid $standing) (index-atom $standing 5) freshness-unresolved))

; m24-contact: id event route seal raw-field partial-frame standing derivations
(= (M24ContactValid $contact)
   (if (CPShape $contact m24-contact 9)
     (let* (($id (index-atom $contact 1))
            ($event (index-atom $contact 2))
            ($route (index-atom $contact 3))
            ($seal (index-atom $contact 4))
            ($raw (index-atom $contact 5))
            ($frame (index-atom $contact 6))
            ($standing (index-atom $contact 7))
            ($derivations (index-atom $contact 8)))
       (and (M24EventValid $event)
        (and (M24RouteValid $route)
         (and (M24SealMatches $id $event $route $seal)
          (and (M24RawFieldValid $raw)
           (and (M24FrameValid $raw $frame)
            (and (== (index-atom $frame 7) (index-atom $event 1))
             (and (M24StandingValid $standing)
              (and (M24DirectContact (index-atom $standing 1))
               (and (== (index-atom (index-atom $standing 1) 1) $seal)
                (and (is-expr $derivations)
                     (M24DerivationsValidAt $derivations 0)))))))))))) false))

(= (M24ContactOrganization $contact)
   (if (M24ContactValid $contact)
     (m24-contact-organization
       (contacted (index-atom $contact 1) (index-atom $contact 4))
       (frame-formation (index-atom (index-atom $contact 6) 1)
         (index-atom (index-atom $contact 6) 2)
         (index-atom (index-atom $contact 6) 3)
         (index-atom (index-atom $contact 6) 9))
       (contact-answerability-anchor
         (index-atom (index-atom $contact 6) 1)
         (index-atom $contact 1)
         (index-atom (index-atom $contact 3) 4))
       (standing-separation
         (M24StandingWarrant (index-atom $contact 7))
         (M24StandingPressure (index-atom $contact 7))
         (M24StandingFreshness (index-atom $contact 7)))
       (partial-domain-honest
         (index-atom (index-atom $contact 6) 2)
         (index-atom (index-atom $contact 6) 3))
       (derivation-and-developmental-organization
         (index-atom $contact 8)
         (M24DevelopmentalOrganization $contact)))
     (m24-contact-unresolved malformed-seal-route-frame-standing-or-derivation $contact)))

; interpretation: id frame history meaning event provenance
(= (M24InterpretationValid $interpretation)
   (if (CPShape $interpretation interpretation 7)
     (M24ProvenanceValid (index-atom $interpretation 6)) false))

; interpretation-use: event frame history interpretation scope action soul-judgment writer
(= (M24InterpretationUseValid $interpretation $use)
   (if (and (M24InterpretationValid $interpretation)
            (CPShape $use interpretation-use 9))
     (and (== (index-atom $use 2) (index-atom $interpretation 2))
      (and (== (index-atom $use 3) (index-atom $interpretation 3))
       (and (== (index-atom $use 4) (index-atom $interpretation 1))
        (and (CPShape (index-atom $use 5) scope 4)
             (== (index-atom $use 8) interpretation-use-writer))))) false))

(= (M24InterpretationParticipation $contact $interpretation $use)
   (if (and (M24ContactValid $contact)
            (M24InterpretationUseValid $interpretation $use))
     (interpretation-participated
       (index-atom $contact 1) (index-atom $interpretation 1)
       (index-atom $use 1) (index-atom $use 5)
       (index-atom $use 6) (index-atom $use 7))
     (interpretation-use-unresolved missing-contact-interpretation-or-governed-use)))

; scoped-joint-use: frames scope compatibility-witness retained-tension
(= (M24ScopedJointUseValid $joint)
   (if (CPShape $joint scoped-joint-use 5)
     (let* (($frames (index-atom $joint 1))
            ($compatibility (index-atom $joint 3))
            ($tension (index-atom $joint 4)))
       (and (is-expr $frames)
        (and (> (size-atom $frames) 1)
         (and (CPUniq $frames 0 ())
          (and (CPShape (index-atom $joint 2) scope 4)
               (or (CPShape $compatibility local-compatibility-witness 3)
                   (CPShape $tension retained-tension-witness 3))))))) false))

; branch-transaction: event pre-cut patch post-cut writer
(= (M24BranchTransactionValid $transaction)
   (if (CPShape $transaction branch-transaction 6)
     (let* (($event (index-atom $transaction 1))
            ($pre (index-atom $transaction 2))
            ($post (index-atom $transaction 4))
            ($expected (cons-atom $event $pre)))
       (and (is-expr $pre)
         (and (is-expr (index-atom $transaction 3))
          (and (is-expr $post)
           (and (== (CPHas $event $pre 0) false)
            (and (CPSetEqual $expected $post)
                 (CPHas (index-atom $transaction 5)
                   (founder contact-recorder recovery-writer action-recorder
                    consequence-recorder trace-recorder frame-former candidate-admitter
                    probe-authorizer authority-attacher durability-promoter
                    interpretation-appender interpretation-use-writer loss-recorder
                    reintroducer discharger operational-status-writer) 0)))))))
     false))

; ---------- Inquiry 24: living carrier and developmental organization ----------

(= (M24InternalDerivationKind $kind)
   (CPHas $kind (internal-generation render) 0))

(= (M24InternalClosureStepAt $rows $reachable $i $out)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (M24DerivationValid $row)
                (M24InternalDerivationKind (index-atom $row 2)))
         (let* (($source (index-atom $row 3))
                ($target (index-atom $row 4)))
           (if (and (CPHas $source $reachable 0)
                    (== (CPHas $target $out 0) false))
             (M24InternalClosureStepAt $rows $reachable (+ $i 1)
               (cons-atom $target $out))
             (M24InternalClosureStepAt $rows $reachable (+ $i 1) $out)))
         (M24InternalClosureStepAt $rows $reachable (+ $i 1) $out)))
     $out))

(= (M24InternalClosureStep $rows $reachable)
   (M24InternalClosureStepAt $rows $reachable 0 $reachable))

(= (M24InternalClosureN $rows $reachable $remaining)
   (if (> $remaining 0)
     (M24InternalClosureN $rows
       (M24InternalClosureStep $rows $reachable) (- $remaining 1))
     $reachable))

(= (M24DerivedSelfGen $derivations $seeds)
   (if (and (is-expr $derivations)
            (and (is-expr $seeds) (CPUniq $seeds 0 ())))
     (derived-selfgen-v1 $seeds
       (M24InternalClosureN $derivations $seeds (size-atom $derivations))
       $derivations computed-from-internal-generation-and-render)
     (derived-selfgen-unresolved malformed-derivations-or-seeds)))

(= (M24DerivedSelfGenValid $selfgen)
   (if (CPShape $selfgen derived-selfgen-v1 5)
     (and (== (index-atom $selfgen 2)
            (M24InternalClosureN (index-atom $selfgen 3)
              (index-atom $selfgen 1) (size-atom (index-atom $selfgen 3))))
          (== (index-atom $selfgen 4)
            computed-from-internal-generation-and-render)) false))

(= (M24VirtualEquipmentHost)
   (virtual-equipment-host-v1 local-frame-objects enacted-transformations
     graded-proarrow-relations proof-relevant-cells local-order-and-joins
     finite-source-pasting partial-composition no-global-frame
     bottleneck-fidelity-separate-from-path-effort))

(= (M24VirtualEquipmentHostValid $host)
   (== $host (M24VirtualEquipmentHost)))

(= (M24EventPrecedes $earlier $later)
   (and (M24EventValid $earlier)
     (and (M24EventValid $later)
          (CPHas (index-atom $earlier 1) (index-atom $later 3) 0))))

(= (M24CarrierOpenDischargeValid $standing)
   (if (CPShape $standing carrier-open-discharge-v1 4)
     (and (CPShape (index-atom $standing 1) carrier-open 4)
       (and (CPShape (index-atom $standing 2) discharge-standing 3)
        (and (== (index-atom (index-atom $standing 2) 1) unresolved)
             (== (index-atom $standing 3) non-equivalent)))) false))

(= (M24ProspectiveAttachmentValid $prospective)
   (if (CPShape $prospective prospective-attachment-v1 13)
     (let* (($formation (index-atom $prospective 2))
            ($assembly (index-atom $prospective 3))
            ($anchor (index-atom $prospective 4))
            ($live (index-atom $prospective 5))
            ($domain (index-atom $prospective 6))
            ($standing (index-atom $prospective 7)))
       (and (M24EventPrecedes $formation $assembly)
        (and (CPShape $anchor contact-answerability-anchor 4)
         (and (CPShape $live live-continuation 4)
          (and (CPShape $domain domain-witness 4)
           (and (M24StandingValid $standing)
            (and (CPShape (index-atom $prospective 8)
                   consequence-interpretation-accounting 2)
             (and (CPShape (index-atom $prospective 9)
                    preservation-loss-standing 3)
              (and (CPShape (index-atom $prospective 10)
                     transformation-lineage 3)
               (and (CPShape (index-atom $prospective 11)
                      prospective-affordance 4)
                    (== (index-atom $prospective 12)
                      evidence-not-writer-or-authority))))))))))) false))

(= (M24LifecycleValid $lifecycle)
   (if (CPShape $lifecycle lifecycle-v1 7)
     (and (CPShape (index-atom $lifecycle 1) candidate-standing 4)
      (and (or (CPShape (index-atom $lifecycle 2) probe-eligible-standing 3)
               (CPShape (index-atom $lifecycle 2) probe-eligible-standing 4))
       (and (or (CPShape (index-atom $lifecycle 3) authoritative-standing 3)
                (CPShape (index-atom $lifecycle 3) authoritative-standing 4))
        (and (or (CPShape (index-atom $lifecycle 4) durable-standing 3)
                 (CPShape (index-atom $lifecycle 4) durable-standing 4))
         (and (== (index-atom $lifecycle 5) historical-attainment-append-only)
              (== (index-atom $lifecycle 6) lifecycle-non-collapse)))))) false))

(= (M24InitialLifecycle $frame $prospective)
   (lifecycle-v1
     (candidate-standing $frame lawful-formation $prospective)
     (probe-eligible-standing unresolved bounded-reversible-probe-not-yet-observed)
     (authoritative-standing unresolved governing-package-not-yet-earned)
     (durable-standing unresolved retrospective-participation-not-yet-observed)
     historical-attainment-append-only lifecycle-non-collapse))

(= (M24ProbeWitnessValid $candidate $probe)
   (if (and (CPShape $candidate candidate-standing 4)
            (CPShape $probe probe-witness-v1 9))
     (and (== (index-atom $probe 1) (index-atom $candidate 1))
       (and (== (index-atom $probe 2) $candidate)
       (and (CPShape (index-atom $probe 4) scope 4)
        (and (== (index-atom $probe 5) bounded-reversible)
         (and (== (index-atom $probe 6) information-seeking)
          (and (CPShape (index-atom $probe 7) returned-contact 4)
              (== (index-atom $probe 8) probe-authorizer))))))) false))

(= (M24AdvanceProbeEligible $lifecycle $probe)
   (if (and (M24LifecycleValid $lifecycle)
            (M24ProbeWitnessValid (index-atom $lifecycle 1) $probe))
     (lifecycle-v1 (index-atom $lifecycle 1)
       (probe-eligible-standing (index-atom (index-atom $lifecycle 1) 1)
         actual-prior-candidate $probe)
       (index-atom $lifecycle 3) (index-atom $lifecycle 4)
       historical-attainment-append-only lifecycle-non-collapse)
     (lifecycle-transition-unresolved missing-candidate-or-bounded-probe)))

(= (M24DiscriminationWitnessValid $route $witness)
   (if (CPShape $witness route-discrimination-v1 8)
     (and (== (index-atom $witness 1) (index-atom $route 1))
       (and (!= (index-atom $witness 2) (index-atom $witness 4))
        (and (!= (index-atom $witness 3) (index-atom $witness 5))
             (== (index-atom $witness 7) inquiry-relevant-distinction)))) false))

(= (M24GoverningContactValid $contact $probe-standing $package)
   (and (M24ContactValid $contact)
    (and (CPShape $probe-standing probe-eligible-standing 4)
     (and (CPShape $package governing-authority-package-v1 10)
      (and (== (index-atom $package 1) $probe-standing)
       (and (== (index-atom $package 2) (index-atom $contact 4))
        (and (== (index-atom $package 3) (index-atom $contact 3))
         (and (M24DiscriminationWitnessValid (index-atom $contact 3)
                (index-atom $package 4))
          (and (CPShape (index-atom $package 8) soul-admission 3)
           (and (CPShape (index-atom $package 9) live-continuation 4)
                (M24SealMatches (index-atom $contact 1)
                  (index-atom $contact 2) (index-atom $contact 3)
                  (index-atom $contact 4))))))))))))

(= (M24GoverningSupportValid $selfgen $package)
   (and (M24DerivedSelfGenValid $selfgen)
    (and (CPShape (index-atom $package 5) material-contribution 5)
     (and (CPShape (index-atom $package 6) fresh-material-support 6)
      (and (== (index-atom (index-atom $package 5) 1)
             (index-atom (index-atom $package 6) 1))
       (and (== (index-atom (index-atom $package 6) 3) contact-support)
        (and (== (index-atom (index-atom $package 6) 4)
               not-in-witness-support)
         (and (== (CPHas (index-atom (index-atom $package 6) 1)
                    (index-atom $selfgen 2) 0) false)
           (and (CPShape (index-atom $package 7) independent-of-selfgen 3)
               (== (index-atom (index-atom $package 7) 1)
                 (index-atom (index-atom $package 6) 1)))))))))))

(= (M24GoverningPackageValid $contact $selfgen $probe-standing $package)
   (and (M24GoverningContactValid $contact $probe-standing $package)
        (M24GoverningSupportValid $selfgen $package)))

(= (M24AdvanceAuthoritative $lifecycle $contact $selfgen $package)
   (let $probe-standing (index-atom $lifecycle 2)
     (if (and (M24LifecycleValid $lifecycle)
              (M24GoverningPackageValid $contact $selfgen $probe-standing $package))
       (lifecycle-v1 (index-atom $lifecycle 1) $probe-standing
         (authoritative-standing (index-atom (index-atom $lifecycle 1) 1)
           actual-prior-probe $package)
         (index-atom $lifecycle 4)
         historical-attainment-append-only lifecycle-non-collapse)
       (lifecycle-transition-unresolved incomplete-governing-package))))

(= (M24DurabilityWitnessValid $authoritative $witness)
   (if (and (CPShape $authoritative authoritative-standing 4)
            (CPShape $witness durability-witness-v1 6))
     (and (== (index-atom $witness 1) $authoritative)
      (and (CPShape (index-atom $witness 2) retrospective-affordance-v1 6)
       (and (== (index-atom $witness 3) permeability-preserved)
        (and (== (index-atom $witness 4) developmental-standing-preserved)
             (CPShape (index-atom $witness 5) soul-admission 3))))) false))

(= (M24AdvanceDurable $lifecycle $witness)
   (let $authoritative (index-atom $lifecycle 3)
     (if (and (M24LifecycleValid $lifecycle)
              (M24DurabilityWitnessValid $authoritative $witness))
       (lifecycle-v1 (index-atom $lifecycle 1) (index-atom $lifecycle 2)
         $authoritative
         (durable-standing (index-atom $authoritative 1)
           actual-prior-authority-and-retrospective-evidence $witness)
         historical-attainment-append-only lifecycle-non-collapse)
       (lifecycle-transition-unresolved missing-retrospective-evidence))))

(= (M24InterpretationStateValid $state)
   (if (CPShape $state interpretation-state-v1 4)
     (let* (($interpretation (index-atom $state 1))
            ($use (index-atom $state 2)))
       (and (M24InterpretationValid $interpretation)
        (and (M24InterpretationUseValid $interpretation $use)
             (== (index-atom $state 3) additive-history-no-rewrite)))) false))

(= (M24AvailabilityStateValid $state)
   (if (CPShape $state availability-state-v1 5)
     (let* (($available (index-atom $state 1))
            ($losses (index-atom $state 2))
            ($recoveries (index-atom $state 3)))
       (and (is-expr $available)
        (and (> (size-atom $available) 0)
         (and (AIAllRowsShape $available available-in 4 0)
          (and (is-expr $losses)
           (and (is-expr $recoveries)
                (== (index-atom $state 4)
                  recovery-requires-exact-dependent-witness))))))) false))

(= (M24LossKnownAt $losses $distinction $context $i)
   (if (< $i (size-atom $losses))
     (let $loss (index-atom $losses $i)
       (if (and (CPShape $loss lost-in 4)
                (and (== (index-atom $loss 1) $distinction)
                     (== (index-atom $loss 2) $context)))
         true (M24LossKnownAt $losses $distinction $context (+ $i 1)))) false))

(= (M24AvailabilityKnownAt $available $distinction $context $i)
   (if (< $i (size-atom $available))
     (let $row (index-atom $available $i)
       (if (and (CPShape $row available-in 4)
                (and (== (index-atom $row 1) $distinction)
                     (== (index-atom $row 2) $context)))
         true (M24AvailabilityKnownAt $available $distinction $context (+ $i 1)))) false))

(= (M24ReintroductionValid $losses $available $reintroduction)
   (if (CPShape $reintroduction reintroduce 7)
     (and (M24LossKnownAt $losses (index-atom $reintroduction 1)
            (index-atom $reintroduction 2) 0)
      (and (M24AvailabilityKnownAt $available (index-atom $reintroduction 1)
             (index-atom $reintroduction 2) 0)
         (and (!= (index-atom $reintroduction 3) (index-atom $reintroduction 4))
          (and (CPShape (index-atom $reintroduction 5)
                 semantic-recovery-witness 5)
           (and (== (index-atom (index-atom $reintroduction 5) 1)
                  (index-atom $reintroduction 1))
            (and (== (index-atom (index-atom $reintroduction 5) 2)
                   (index-atom $reintroduction 2))
                 (== (index-atom (index-atom $reintroduction 5) 4)
                   exact-dependent-witness))))))) false))

(= (M24AffordanceStateValid $state)
   (if (CPShape $state affordance-state-v1 4)
     (and (CPShape (index-atom $state 1) prospective-affordance 4)
       (and (or (CPShape (index-atom $state 2) retrospective-affordance-standing 3)
                (M24RetrospectiveAffordanceValid (index-atom $state 2)))
            (== (index-atom $state 3) prospective-does-not-certify-outcome))) false))

(= (M24ComputedStuck $witness)
   (if (CPShape $witness stuck-evidence-v1 8)
     (and (== (index-atom $witness 1) live-demand-persists)
      (and (== (index-atom $witness 2) discrepancy-persists)
       (and (== (index-atom $witness 3) effect-equivalent-recurrence)
        (and (== (index-atom $witness 4) frame-reinforcement)
         (and (== (index-atom $witness 5) reachability-not-opening)
          (and (== (index-atom $witness 6) relevant-contact-discriminating)
               (== (index-atom $witness 7) distinction-dies-in-active-frame))))))) false))

(= (M24TractionStateValid $state)
   (if (CPShape $state traction-state-v1 4)
     (and (CPShape (index-atom $state 1) structured-traction 7)
       (and (CPShape (index-atom $state 2) trajectory-pathology-v1 5)
         (and (== (index-atom $state 3) no-canonical-scalar-authority)
          (and (== (index-atom (index-atom $state 2) 1) contact-starvation-unresolved)
           (and (== (index-atom (index-atom $state 2) 2)
                  frame-distinction-death-unresolved)
                (== (index-atom (index-atom $state 2) 3) stuck-unresolved)))))) false))

(= (M24FramePluralityValid $plurality)
   (if (CPShape $plurality frame-plurality-v1 4)
     (let* (($frames (index-atom $plurality 1))
            ($joint (index-atom $plurality 2)))
       (and (is-expr $frames)
        (and (> (size-atom $frames) 0)
         (and (CPUniq $frames 0 ())
          (and (== (index-atom $plurality 3) no-global-amalgamation-required)
               (if (> (size-atom $frames) 1)
                 (M24ScopedJointUseValid $joint)
                 (== $joint single-frame-no-joint-use))))))) false))

(= (M24Writers)
   (founder contact-recorder recovery-writer action-recorder
     consequence-recorder trace-recorder frame-former candidate-admitter
     probe-authorizer authority-attacher durability-promoter
     interpretation-appender interpretation-use-writer loss-recorder
     reintroducer discharger operational-status-writer))

(= (M24NonWriters)
   (renderer evaluator frame witness capability generic-carrier))

(= (M24WriterBoundaryValid $boundary)
   (if (CPShape $boundary writer-boundary-v1 4)
     (and (CPSetEqual (index-atom $boundary 1) (M24Writers))
      (and (CPSetEqual (index-atom $boundary 2) (M24NonWriters))
           (== (index-atom $boundary 3) closed-no-implicit-write-authority))) false))

(= (M24CarrierCollectionsValid $carrier $i)
   (if (< $i 12)
     (and (is-expr (index-atom $carrier $i))
          (M24CarrierCollectionsValid $carrier (+ $i 1))) true))

(= (M24FormalCarrierValid $carrier)
   (if (CPShape $carrier formal-carrier-v1 12)
     (and (M24CarrierCollectionsValid $carrier 2)
       (and (> (size-atom (index-atom $carrier 2)) 0)
        (and (> (size-atom (index-atom $carrier 3)) 0)
             (> (size-atom (index-atom $carrier 5)) 0)))) false))

(= (M24Current $rows)
   (if (and (is-expr $rows) (> (size-atom $rows) 0))
     (index-atom $rows 0)
     (m24-current-unresolved empty-or-malformed-collection)))

(= (M24LifecycleProbeStanding $lifecycle)
   (if (CPShape (index-atom $lifecycle 2) probe-eligible-standing 4)
     probe-eligible probe-unresolved))

(= (M24LifecycleAuthorityStanding $lifecycle)
   (if (CPShape (index-atom $lifecycle 3) authoritative-standing 4)
     authoritative authoritative-unresolved))

(= (M24LifecycleDurableStanding $lifecycle)
   (if (CPShape (index-atom $lifecycle 4) durable-standing 4)
     durable durable-unresolved))

(= (M24DevelopmentalStandingFor $lifecycle)
   (developmental-standing-v1 candidate
     (M24LifecycleProbeStanding $lifecycle)
     (M24LifecycleAuthorityStanding $lifecycle)
     (M24LifecycleDurableStanding $lifecycle) discharge-unresolved))

(= (M24DevelopmentalCarrierCoherent $organization)
   (let* (($carrier (index-atom $organization 1))
          ($lifecycle (M24Current (index-atom $carrier 10))))
     (and (M24LifecycleValid $lifecycle)
      (and (== (M24Current (index-atom $carrier 7))
             (index-atom $organization 7))
       (and (== (M24Current (index-atom $carrier 8))
              (index-atom $organization 6))
        (and (== (M24Current (index-atom $carrier 9))
               (index-atom $organization 8))
         (and (== (M24Current (index-atom $carrier 11))
                (index-atom $organization 12))
              (== (index-atom $organization 13)
                (M24DevelopmentalStandingFor $lifecycle)))))))))

(= (M24DevelopmentalOrganizationValid $organization)
   (if (CPShape $organization m24-developmental-organization-v1 14)
     (and (M24FormalCarrierValid (index-atom $organization 1))
      (and (M24VirtualEquipmentHostValid (index-atom $organization 2))
       (and (M24CarrierOpenDischargeValid (index-atom $organization 3))
        (and (M24ProspectiveAttachmentValid (index-atom $organization 4))
         (and (M24DerivedSelfGenValid (index-atom $organization 5))
          (and (M24InterpretationStateValid (index-atom $organization 6))
           (and (M24AvailabilityStateValid (index-atom $organization 7))
            (and (M24AffordanceStateValid (index-atom $organization 8))
             (and (M24TractionStateValid (index-atom $organization 9))
              (and (M24FramePluralityValid (index-atom $organization 10))
               (and (M24WriterBoundaryValid (index-atom $organization 11))
                (and (M24BranchTransactionValid (index-atom $organization 12))
                 (and (CPShape (index-atom $organization 13)
                        developmental-standing-v1 6)
                      (M24DevelopmentalCarrierCoherent $organization)))))))))))))) false))

(= (M24ProspectiveFor $contact)
   (let* (($id (index-atom $contact 1))
          ($event (index-atom $contact 2))
          ($route (index-atom $contact 3))
          ($frame (index-atom $contact 6))
          ($frame-id (index-atom $frame 1))
          ($formation (event (formation-event $id) formation-proto
            (index-atom $event 3)))
          ($assembly (event (assembly-event $id) assembly-proto
            ((formation-event $id)))))
     (prospective-attachment-v1 $frame-id $formation $assembly
       (contact-answerability-anchor $frame-id $id (index-atom $route 4))
       (live-continuation (live-item $id) (index-atom $frame 4) grounded)
       (index-atom $frame 9) (index-atom $contact 7)
       (consequence-interpretation-accounting unresolved)
       (preservation-loss-standing exact no-loss-observed)
       (transformation-lineage contact $frame-id)
       (prospective-affordance $frame-id inquiry-reach preserve-without-action)
       evidence-not-writer-or-authority)))

(= (M24InterpretationStateFor $contact)
   (let* (($id (index-atom $contact 1))
          ($event (index-atom $contact 2))
          ($seal (index-atom $contact 4))
          ($frame (index-atom $contact 6))
          ($frame-id (index-atom $frame 1))
          ($interpretation (interpretation (interpretation-of $id) $frame-id
            (history-of $id) partial-contact-remains-live (index-atom $event 1)
            (prov-contact $seal)))
          ($use (interpretation-use (interpretation-use-event $id) $frame-id
            (history-of $id) (interpretation-of $id) (index-atom $frame 4)
            possible-continuation-formation constitutive-soul-judgment
            interpretation-use-writer)))
     (interpretation-state-v1 $interpretation $use additive-history-no-rewrite)))

(= (M24AvailabilityStateFor $contact)
   (let* (($event (index-atom $contact 2))
          ($frame (index-atom $contact 6))
          ($represented-domain (index-atom $frame 9)))
     (availability-state-v1
       ((available-in $represented-domain (index-atom $frame 4)
          (index-atom $event 1))) () ()
       recovery-requires-exact-dependent-witness)))

(= (M24AffordanceStateFor $contact)
   (let $frame-id (index-atom (index-atom $contact 6) 1)
     (affordance-state-v1
       (prospective-affordance $frame-id inquiry-reach preserve-without-action)
       (retrospective-affordance-standing unresolved not-yet-exercised)
       prospective-does-not-certify-outcome)))

(= (M24TractionStateFor $contact)
   (traction-state-v1
     (structured-traction contact-uptake-present discrimination-unresolved
       frame-permeability-present prospective-affordance-live
       provenance-continuity-present soul-admissibility-present)
     (trajectory-pathology-v1 contact-starvation-unresolved
       frame-distinction-death-unresolved stuck-unresolved
       insufficient-trajectory-for-pathology)
     no-canonical-scalar-authority))

(= (M24BranchTransactionFor $contact)
   (let* (($id (index-atom $contact 1))
          ($event (index-atom $contact 2))
          ($occurrence (index-atom $event 1))
          ($parents (index-atom $event 3)))
     (branch-transaction $occurrence $parents
       ((contact-patch $id (index-atom $contact 4)))
       (cons-atom $occurrence $parents) contact-recorder)))

(= (M24FormalCarrierFor $contact)
   (let* (($id (index-atom $contact 1))
          ($event (index-atom $contact 2))
          ($route (index-atom $contact 3))
          ($seal (index-atom $contact 4))
          ($frame (index-atom $contact 6))
          ($frame-id (index-atom $frame 1))
          ($prospective (M24ProspectiveFor $contact))
          ($lifecycle (M24InitialLifecycle $frame-id $prospective)))
     (formal-carrier-v1 $id
       ((contact-record $id $seal $route))
       ((frame-record $frame-id (index-atom $frame 9))) (index-atom $contact 8)
       ((live-item (live-item $id) (index-atom $frame 4) grounded))
       ((history-record (index-atom $event 1) contact $seal))
       ((M24AvailabilityStateFor $contact))
       ((M24InterpretationStateFor $contact))
       ((M24AffordanceStateFor $contact))
       ($lifecycle) ((M24BranchTransactionFor $contact)))))

(= (M24DevelopmentalLifecycle $developmental)
   (if (CPShape $developmental m24-developmental-organization-v1 14)
     (M24Current (index-atom (index-atom $developmental 1) 10))
     (lifecycle-unresolved malformed-developmental-organization)))

(= (M24DevelopmentalOrganization $contact)
   (if (M24ContactValid $contact)
     (let* (($id (index-atom $contact 1))
            ($frame (index-atom $contact 6))
            ($frame-id (index-atom $frame 1))
            ($scope (index-atom $frame 4))
            ($prospective (M24ProspectiveFor $contact)))
       (m24-developmental-organization-v1 (M24FormalCarrierFor $contact)
         (M24VirtualEquipmentHost)
         (carrier-open-discharge-v1
           (carrier-open (live-item $id) $scope grounded)
           (discharge-standing unresolved soul-judgment-required) non-equivalent)
         $prospective (M24DerivedSelfGen (index-atom $contact 8) ())
         (M24InterpretationStateFor $contact)
         (M24AvailabilityStateFor $contact)
         (M24AffordanceStateFor $contact) (M24TractionStateFor $contact)
         (frame-plurality-v1 ($frame-id) single-frame-no-joint-use
           no-global-amalgamation-required)
         (writer-boundary-v1 (M24Writers) (M24NonWriters)
           closed-no-implicit-write-authority)
         (M24BranchTransactionFor $contact)
         (developmental-standing-v1 candidate probe-unresolved
           authoritative-unresolved durable-unresolved discharge-unresolved)))
     (m24-developmental-organization-unresolved malformed-contact)))

; A native inquiry is probe-eligible only through its retained non-certifying
; consequence route. This basis describes the already-formed movement; it does
; not select a movement or promote a lifecycle standing.
(= (M24ProbeBasisValid $basis)
   (if (CPShape $basis probe-basis-v1 5)
     (and (== (index-atom $basis 1) inquiry)
      (and (CPShape (index-atom $basis 3) source-cut 2)
       (and (CPShape (index-atom $basis 4) bounded-probe-route 5)
        (and (CPShape (index-atom (index-atom $basis 4) 1)
               consequence-route 3)
         (and (== (index-atom (index-atom $basis 4) 2)
                information-seeking)
          (and (== (index-atom (index-atom $basis 4) 3)
                 no-persistent-authority)
               (== (index-atom (index-atom $basis 4) 4)
                 non-certifying))))))) false))

(= (M24ProbeBasisForMovement $movement)
   (if (and (CPShape $movement movement-formed 7)
            (== (index-atom $movement 1) inquiry))
     (let $answerability (index-atom $movement 5)
       (if (CPShape $answerability answerability 2)
         (let $o-star (index-atom $answerability 1)
           (if (CPShape $o-star o-star 2)
             (let $route (index-atom $o-star 1)
               (if (and (CPShape $route consequence-route 3)
                        (== (index-atom $route 2) non-certifying))
                 (probe-basis-v1 inquiry (index-atom $movement 2)
                   (index-atom $movement 3)
                   (bounded-probe-route $route information-seeking
                     no-persistent-authority non-certifying))
                 (probe-basis-unresolved certifying-or-malformed-route)))
             (probe-basis-unresolved missing-o-star)))
         (probe-basis-unresolved missing-answerability)))
     (probe-basis-unresolved movement-not-native-inquiry)))

; A returned consequence is broader than a probe result. Only an inquiry may
; cross the ProbeEligible boundary, but another already-formed continuation
; (for example defer/wait-for-contact) can lawfully receive contact, extend
; immutable history, and reorganize later participation without earning probe
; or authority standing. Keeping these constructors disjoint prevents a
; generic return from being laundered into lifecycle promotion.
(= (M24ContinuationReturnBasisValid $basis)
   (if (CPShape $basis continuation-return-basis-v1 6)
     (and (!= (index-atom $basis 1) inquiry)
      (and (CPShape (index-atom $basis 3) source-cut 2)
       (and (CPShape (index-atom $basis 4) answerability 2)
            (== (index-atom $basis 5) no-probe-no-authority-promotion))))
     false))

(= (M24ConsequenceBasisForMovement $movement)
   (let $probe (M24ProbeBasisForMovement $movement)
     (if (M24ProbeBasisValid $probe) $probe
       (if (and (CPShape $movement movement-formed 7)
                (!= (index-atom $movement 1) inquiry))
         (continuation-return-basis-v1 (index-atom $movement 1)
           (index-atom $movement 2) (index-atom $movement 3)
           (index-atom $movement 5) no-probe-no-authority-promotion)
         (continuation-return-basis-unresolved
           movement-not-formed-or-inquiry-probe-invalid)))))

(= (M24ConsequenceBasisValid $basis)
   (or (M24ProbeBasisValid $basis)
       (M24ContinuationReturnBasisValid $basis)))

(= (M24ProbeWitnessFromConsequence $lifecycle $basis $consequence $scope)
   (if (and (M24LifecycleValid $lifecycle)
         (and (M24ProbeBasisValid $basis)
          (and (CPConsequenceV2Valid $consequence)
           (and (CPShape $scope scope 4)
                (== (index-atom $consequence 2) (index-atom $basis 2))))))
     (let $candidate (index-atom $lifecycle 1)
       (probe-witness-v1 (index-atom $candidate 1) $candidate
         (index-atom $consequence 1) $scope bounded-reversible
         information-seeking
         (returned-contact (index-atom $consequence 3)
           (index-atom $consequence 4) (index-atom $consequence 12))
         probe-authorizer))
     (probe-witness-unresolved missing-inquiry-basis-or-returned-consequence)))

(= (M24RetrospectiveAffordanceValid $retrospective)
   (if (CPShape $retrospective retrospective-affordance-v1 6)
     (and (CPShape (index-atom $retrospective 4) returned-contact 4)
      (and (CPShape (index-atom $retrospective 5) changed-participation 3)
           (!= (index-atom (index-atom $retrospective 5) 1)
             (index-atom (index-atom $retrospective 5) 2)))) false))

(= (M24RetrospectiveAffordanceFor $lifecycle $basis $consequence $next-cut)
   (retrospective-affordance-v1
     (index-atom (index-atom $lifecycle 1) 1)
     (index-atom $basis 2) (index-atom $consequence 1)
     (returned-contact (index-atom $consequence 4)
       (index-atom $consequence 12) consequence-provenance-retained)
     (changed-participation (index-atom (index-atom $basis 3) 1)
       (index-atom $next-cut 1))))

(= (M24AffordanceAfterConsequence $prior $retrospective)
   (if (and (M24AffordanceStateValid $prior)
            (M24RetrospectiveAffordanceValid $retrospective))
     (affordance-state-v1 (index-atom $prior 1) $retrospective
       prospective-does-not-certify-outcome)
     (affordance-state-unresolved missing-prospective-or-retrospective-evidence)))

(= (M24TractionAfterConsequence)
   (traction-state-v1
     (structured-traction contact-uptake-returned discrimination-unresolved
       frame-permeability-preserved affordance-vitality-exercised
       provenance-continuity-preserved soul-admissibility-unresolved)
     (trajectory-pathology-v1 contact-starvation-unresolved
       frame-distinction-death-unresolved stuck-unresolved
       insufficient-trajectory-for-pathology)
     no-canonical-scalar-authority))

(= (M24ConsequenceTransactionFor $prior $consequence)
   (let* (($event (index-atom $consequence 1))
          ($pre (index-atom $prior 4)))
     (branch-transaction $event $pre
       ((consequence-patch $event (index-atom $consequence 4)
          (index-atom $consequence 12)))
       (cons-atom $event $pre) consequence-recorder)))

(= (M24FormalCarrierAfterProbe $carrier $availability $interpretation
      $affordance $lifecycle $transaction $consequence)
   (formal-carrier-v1 (index-atom $carrier 1)
     (index-atom $carrier 2) (index-atom $carrier 3)
     (index-atom $carrier 4) (index-atom $carrier 5)
     (CPListAppend (index-atom $carrier 6)
       ((history-record (index-atom $consequence 1) consequence
          (index-atom $consequence 12))))
     (index-atom $carrier 7) (index-atom $carrier 8)
     (CPListAppend (index-atom $carrier 9) ($affordance))
     (CPListAppend (index-atom $carrier 10) ($lifecycle))
     (CPListAppend (index-atom $carrier 11) ($transaction))))

(= (M24DevelopmentalAfterProbe $prior $basis $consequence $scope $next-cut)
   (if (and (M24DevelopmentalOrganizationValid $prior)
         (and (M24ProbeBasisValid $basis)
          (and (CPConsequenceV2Valid $consequence)
           (and (== (index-atom $consequence 2) (index-atom $basis 2))
            (and (CPShape $scope scope 4) (CPCutValid $next-cut))))))
     (let* (($old-lifecycle (M24DevelopmentalLifecycle $prior))
            ($probe (M24ProbeWitnessFromConsequence $old-lifecycle $basis
              $consequence $scope))
            ($lifecycle (M24AdvanceProbeEligible $old-lifecycle $probe))
            ($retrospective (M24RetrospectiveAffordanceFor $old-lifecycle
              $basis $consequence $next-cut))
            ($affordance (M24AffordanceAfterConsequence
              (index-atom $prior 8) $retrospective))
            ($transaction (M24ConsequenceTransactionFor
              (index-atom $prior 12) $consequence))
            ($carrier (M24FormalCarrierAfterProbe (index-atom $prior 1)
              (index-atom $prior 7) (index-atom $prior 6) $affordance
              $lifecycle $transaction $consequence)))
       (m24-developmental-organization-v1 $carrier
         (index-atom $prior 2) (index-atom $prior 3) (index-atom $prior 4)
         (index-atom $prior 5) (index-atom $prior 6) (index-atom $prior 7)
         $affordance (M24TractionAfterConsequence) (index-atom $prior 10)
         (index-atom $prior 11) $transaction
         (M24DevelopmentalStandingFor $lifecycle)))
     (m24-developmental-organization-unresolved
       missing-prior-inquiry-consequence-or-next-cut)))

(= (M24ContinuationReturnWitness $basis $consequence $scope)
   (if (and (M24ContinuationReturnBasisValid $basis)
         (and (CPConsequenceV2Valid $consequence)
          (and (CPShape $scope scope 4)
               (== (index-atom $consequence 2) (index-atom $basis 2)))))
     (continuation-return-witness-v1 (index-atom $basis 2)
       (index-atom $basis 1) (index-atom $consequence 1) $scope
       (returned-contact (index-atom $consequence 3)
         (index-atom $consequence 4) (index-atom $consequence 12))
       history-and-participation-only no-probe-no-authority-promotion)
     (continuation-return-witness-unresolved
       missing-formed-continuation-or-returned-consequence)))

(= (M24ContinuationReturnWitnessValid $witness $basis $consequence $scope)
   (if (CPShape $witness continuation-return-witness-v1 8)
     (and (M24ContinuationReturnBasisValid $basis)
       (== $witness (M24ContinuationReturnWitness $basis $consequence $scope)))
     false))

(= (M24DevelopmentalAfterReturn $prior $basis $consequence $scope $next-cut)
   (if (and (M24DevelopmentalOrganizationValid $prior)
         (and (M24ContinuationReturnBasisValid $basis)
          (and (CPConsequenceV2Valid $consequence)
           (and (== (index-atom $consequence 2) (index-atom $basis 2))
            (and (CPShape $scope scope 4) (CPCutValid $next-cut))))))
     (let* (($lifecycle (M24DevelopmentalLifecycle $prior))
            ($retrospective (M24RetrospectiveAffordanceFor $lifecycle
              $basis $consequence $next-cut))
            ($affordance (M24AffordanceAfterConsequence
              (index-atom $prior 8) $retrospective))
            ($transaction (M24ConsequenceTransactionFor
              (index-atom $prior 12) $consequence))
            ($carrier (M24FormalCarrierAfterProbe (index-atom $prior 1)
              (index-atom $prior 7) (index-atom $prior 6) $affordance
              $lifecycle $transaction $consequence)))
       (m24-developmental-organization-v1 $carrier
         (index-atom $prior 2) (index-atom $prior 3) (index-atom $prior 4)
         (index-atom $prior 5) (index-atom $prior 6) (index-atom $prior 7)
         $affordance (M24TractionAfterConsequence) (index-atom $prior 10)
         (index-atom $prior 11) $transaction
         (M24DevelopmentalStandingFor $lifecycle)))
     (m24-developmental-organization-unresolved
       missing-prior-continuation-return-or-next-cut)))

(= (M24DevelopmentalTransition $prior $basis $consequence $scope $next-cut)
   (if (M24ProbeBasisValid $basis)
     (let* (($lifecycle (M24DevelopmentalLifecycle $prior))
            ($probe (M24ProbeWitnessFromConsequence $lifecycle $basis
              $consequence $scope))
            ($evolved (M24DevelopmentalAfterProbe $prior $basis $consequence
              $scope $next-cut)))
       (if (M24DevelopmentalOrganizationValid $evolved)
         (m24-developmental-transition-v1 $prior $evolved $basis $consequence
           $scope $next-cut $probe)
         (m24-developmental-transition-unresolved $evolved)))
     (if (M24ContinuationReturnBasisValid $basis)
       (let* (($witness (M24ContinuationReturnWitness $basis $consequence
                $scope))
              ($evolved (M24DevelopmentalAfterReturn $prior $basis
                $consequence $scope $next-cut)))
         (if (M24DevelopmentalOrganizationValid $evolved)
           (m24-developmental-transition-v2 $prior $evolved $basis
             $consequence $scope $next-cut $witness)
           (m24-developmental-transition-unresolved $evolved)))
       (m24-developmental-transition-unresolved
         missing-probe-or-continuation-return-basis))))

(= (M24DevelopmentalTransitionValid $transition)
   (if (CPShape $transition m24-developmental-transition-v1 8)
     (and (M24DevelopmentalOrganizationValid (index-atom $transition 1))
      (and (M24DevelopmentalOrganizationValid (index-atom $transition 2))
       (and (M24ProbeBasisValid (index-atom $transition 3))
        (and (CPConsequenceV2Valid (index-atom $transition 4))
         (and (CPShape (index-atom $transition 5) scope 4)
          (and (CPCutValid (index-atom $transition 6))
           (and (M24ProbeWitnessValid
                  (index-atom (M24DevelopmentalLifecycle
                    (index-atom $transition 1)) 1)
                  (index-atom $transition 7))
                (== $transition
                  (M24DevelopmentalTransition (index-atom $transition 1)
                    (index-atom $transition 3) (index-atom $transition 4)
                    (index-atom $transition 5)
                    (index-atom $transition 6))))))))))
     (if (CPShape $transition m24-developmental-transition-v2 8)
       (and (M24DevelopmentalOrganizationValid (index-atom $transition 1))
        (and (M24DevelopmentalOrganizationValid (index-atom $transition 2))
         (and (M24ContinuationReturnBasisValid (index-atom $transition 3))
          (and (CPConsequenceV2Valid (index-atom $transition 4))
           (and (CPShape (index-atom $transition 5) scope 4)
            (and (CPCutValid (index-atom $transition 6))
             (and (M24ContinuationReturnWitnessValid
                    (index-atom $transition 7) (index-atom $transition 3)
                    (index-atom $transition 4) (index-atom $transition 5))
                  (== $transition
                    (M24DevelopmentalTransition (index-atom $transition 1)
                      (index-atom $transition 3) (index-atom $transition 4)
                      (index-atom $transition 5)
                      (index-atom $transition 6))))))))))
       false)))

; ---------- Investigation 25: movement-primary DPF and R/A/P ----------

; These constructors read an already-formed primary movement candidate. R/A/P
; never supply its identity, form, source cut, answerability, or continuation
; basis, and no scalar aggregation exists in this surface.

(= (M25RowsWithoutIdAt $rows $id $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (is-expr $row)
                (and (> (size-atom $row) 1)
                     (== (index-atom $row 1) $id)))
         (M25RowsWithoutIdAt $rows $id (+ $i 1))
         (cons-atom $row (M25RowsWithoutIdAt $rows $id (+ $i 1))))) ()))

(= (M25RowsWithoutId $rows $id)
   (M25RowsWithoutIdAt $rows $id 0))

(= (M25CutWithoutRelation $cut $id)
   (let* (($d (index-atom $cut 6))
          ($omega (index-atom $cut 7)))
     (constitutive-cut
       (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
       (index-atom $cut 4) (index-atom $cut 5)
       (D (M25RowsWithoutId (index-atom $d 1) $id) (index-atom $d 2))
       (Omega (M25RowsWithoutId (index-atom $omega 1) $id))
       (index-atom $cut 8) (index-atom $cut 9) (index-atom $cut 10)
       (index-atom $cut 11) (index-atom $cut 12) (index-atom $cut 13))))

(= (M25CutWithoutDistinction $cut $id)
   (let $d (index-atom $cut 6)
     (constitutive-cut
       (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
       (index-atom $cut 4) (index-atom $cut 5)
       (D (index-atom $d 1) (M25RowsWithoutId (index-atom $d 2) $id))
       (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
       (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
       (index-atom $cut 13))))

(= (M25RelationOccurrenceCount $cut $id)
   (+ (size-atom (CPFind (CPDRelations $cut) $id))
      (size-atom (CPFind (CPOmegaRelations $cut) $id))))

(= (M25RelationDomain $cut $id)
   (if (== (size-atom (CPFind (CPDRelations $cut) $id)) 1) D
     (if (== (size-atom (CPFind (CPOmegaRelations $cut) $id)) 1) Omega
       relation-domain-unresolved)))

(= (M25RelationRow $cut $id)
   (let $d (CPFind (CPDRelations $cut) $id)
     (if (== (size-atom $d) 1) (index-atom $d 0)
       (let $omega (CPFind (CPOmegaRelations $cut) $id)
         (if (== (size-atom $omega) 1) (index-atom $omega 0)
           (relation-row-unresolved $id))))))

(= (M25RelatednessFloor $cut $id)
   (== (M25RelationOccurrenceCount $cut $id) 1))

(= (M25PrecisionFloor $cut $id)
   (== (size-atom (CPFind (CPDDistinctions $cut) $id)) 1))

(= (M25FourthDiscrimination $movement-id $cut $id)
   (if (M25RelatednessFloor $cut $id)
     (let $counterfactual (M25CutWithoutRelation $cut $id)
       (fourth-discrimination $movement-id $id
         (counterfactual remove-material-relation)
         (if (M25RelatednessFloor $counterfactual $id)
           no-material-difference changes-material-relatedness-floor)))
     (fourth-discrimination-unresolved $movement-id $id
       missing-material-relation)))

(= (M25PrecisionDiscrimination $movement-id $cut $id)
   (if (M25PrecisionFloor $cut $id)
     (let $counterfactual (M25CutWithoutDistinction $cut $id)
       (precision-discrimination $movement-id $id
         (counterfactual remove-material-distinction)
         (if (M25PrecisionFloor $counterfactual $id)
           no-material-difference changes-material-precision-floor)))
     (precision-discrimination-unresolved $movement-id $id
       missing-material-distinction)))

(= (M25RelatednessWitness $movement-id $cut $id)
   (if (M25RelatednessFloor $cut $id)
     (relatedness-witness $movement-id $id
       (material-floor satisfied
         (relation-standing (index-atom (M25RelationRow $cut $id) 3)))
       (provenance (M25RelationDomain $cut $id)
         (index-atom $cut 12) (M25FourthDiscrimination $movement-id $cut $id)))
     (relatedness-witness $movement-id $id
       (material-floor failed missing-or-ambiguous-relation)
       (provenance unresolved))))

(= (M25PrecisionWitness $movement-id $cut $id)
   (if (M25PrecisionFloor $cut $id)
     (let $row (index-atom (CPFind (CPDDistinctions $cut) $id) 0)
       (precision-witness $movement-id $id
         (material-floor satisfied
           (distinction-standing (index-atom $row 2)))
         (provenance D (index-atom $cut 12)
           (M25PrecisionDiscrimination $movement-id $cut $id))))
     (precision-witness $movement-id $id
       (material-floor failed missing-or-ambiguous-distinction)
       (provenance unresolved))))

(= (M25RelatednessWitnessValid $movement-id $witness)
   (if (CPShape $witness relatedness-witness 5)
     (if (== (index-atom $witness 1) $movement-id)
       (if (== (index-atom (index-atom $witness 3) 1) satisfied)
         (if (CPShape (index-atom $witness 4) provenance 4)
           (== (index-atom (index-atom $witness 4) 3)
             (fourth-discrimination $movement-id (index-atom $witness 2)
               (counterfactual remove-material-relation)
               changes-material-relatedness-floor)) false)
         false) false) false))

(= (M25PrecisionWitnessValid $movement-id $witness)
   (if (CPShape $witness precision-witness 5)
     (if (== (index-atom $witness 1) $movement-id)
       (if (== (index-atom (index-atom $witness 3) 1) satisfied)
         (if (CPShape (index-atom $witness 4) provenance 4)
           (== (index-atom (index-atom $witness 4) 3)
             (precision-discrimination $movement-id (index-atom $witness 2)
               (counterfactual remove-material-distinction)
               changes-material-precision-floor)) false)
         false) false) false))

(= (M25RelatednessAt $movement-id $cut $required $i)
   (if (< $i (size-atom $required))
     (cons-atom (M25RelatednessWitness $movement-id $cut
       (index-atom $required $i))
       (M25RelatednessAt $movement-id $cut $required (+ $i 1))) ()))

(= (M25PrecisionAt $movement-id $cut $required $i)
   (if (< $i (size-atom $required))
     (cons-atom (M25PrecisionWitness $movement-id $cut
       (index-atom $required $i))
       (M25PrecisionAt $movement-id $cut $required (+ $i 1))) ()))

(= (M25AllRelatednessValid $movement-id $rows $i)
   (if (< $i (size-atom $rows))
     (and (M25RelatednessWitnessValid $movement-id (index-atom $rows $i))
          (M25AllRelatednessValid $movement-id $rows (+ $i 1))) true))

(= (M25AllPrecisionValid $movement-id $rows $i)
   (if (< $i (size-atom $rows))
     (and (M25PrecisionWitnessValid $movement-id (index-atom $rows $i))
          (M25AllPrecisionValid $movement-id $rows (+ $i 1))) true))

(= (M25RelatednessProfile $primary $cut)
   (let* (($id (index-atom $primary 1))
          ($required (index-atom (index-atom $primary 9) 3))
          ($witnesses (M25RelatednessAt $id $cut $required 0)))
     (relatedness-profile $required $witnesses
       (M25AllRelatednessValid $id $witnesses 0))))

(= (M25PrecisionProfile $primary $cut)
   (let* (($id (index-atom $primary 1))
          ($required (index-atom (index-atom $primary 9) 4))
          ($witnesses (M25PrecisionAt $id $cut $required 0)))
     (precision-profile $required $witnesses
       (M25AllPrecisionValid $id $witnesses 0))))

(= (M25DPFDiscriminationsAt $movement-id $cut $ids $i)
   (if (< $i (size-atom $ids))
     (cons-atom (M25FourthDiscrimination $movement-id $cut
       (index-atom $ids $i))
       (M25DPFDiscriminationsAt $movement-id $cut $ids (+ $i 1))) ()))

; C carries finite constitutional relations as encounter data. It can never
; carry a Soul verdict or standing as though the cut itself owned doctrine.
(= (M25AmbientSoulRelationsValidAt $relations $i)
   (if (< $i (size-atom $relations))
     (and (CPShape (index-atom $relations $i) soul-relation 4)
          (M25AmbientSoulRelationsValidAt $relations (+ $i 1))) true))

(= (M25AmbientSoulCarrierValid $c)
   (if (CPShape $c C 2)
     (let $relations (index-atom $c 1)
       (and (is-expr $relations)
         (and (> (size-atom $relations) 0)
              (M25AmbientSoulRelationsValidAt $relations 0)))) false))

(= (M25DynamicParticipatoryFourthness $movement-id $cut)
   (let* (($relation-ids (CPNativeRequirementRelations $cut))
          ($discriminations
            (M25DPFDiscriminationsAt $movement-id $cut $relation-ids 0)))
     (dynamic-participatory-fourthness-v1 $movement-id
       (source-cut (index-atom $cut 1))
       (index-atom $cut 6) (index-atom $cut 7) (index-atom $cut 8)
       (index-atom $cut 9) (index-atom $cut 10)
       (counterfactual-bite $discriminations)
       ambient-soul-doctrine finite-partial-non-reconstructive)))

(= (M25DynamicParticipatoryFourthnessValid $dpf)
   (if (CPShape $dpf dynamic-participatory-fourthness-v1 11)
     (and (CPShape (index-atom $dpf 2) source-cut 2)
      (and (CPShape (index-atom $dpf 3) D 3)
       (and (CPShape (index-atom $dpf 4) Omega 2)
        (and (CPShape (index-atom $dpf 5) I 2)
          (and (CPShape (index-atom $dpf 6) W 2)
          (and (M25AmbientSoulCarrierValid (index-atom $dpf 7))
           (and (CPShape (index-atom $dpf 8) counterfactual-bite 2)
            (and (> (size-atom (index-atom (index-atom $dpf 8) 1)) 0)
             (and (== (index-atom $dpf 9) ambient-soul-doctrine)
                  (== (index-atom $dpf 10)
                    finite-partial-non-reconstructive)))))))))) false))

(= (M25MovementAvailability $possibility $cut $facts $flourishing
      $participant-relations)
   (let $form (index-atom $possibility 2)
     (if (== $form undertaking)
       (if (and (CPInterfacesLive $cut)
             (and (> (size-atom (CPLiveThreadIds $cut)) 0)
               (== (CPInquiryNeededV2 $cut $facts $flourishing
                 $participant-relations) false)))
         (movement-availability available live-undertaking)
         (movement-availability unavailable inquiry-or-thread-gap))
       (if (== $form inquiry)
         (if (and (CPInterfacesLive $cut)
               (CPInquiryNeededV2 $cut $facts $flourishing
                 $participant-relations))
           (movement-availability available discriminating-contact-needed)
           (movement-availability unavailable inquiry-not-needed))
         (if (== $form defer)
           (if (== (CPInterfacesLive $cut) false)
             (movement-availability available interface-contact-needed)
             (movement-availability unavailable interface-remains-live))
           (movement-availability unavailable unsupported-form))))))

; Balance unfolding is the one movement/contact organization. Fact9 makes the
; one becoming finitely legible and the interconnected Flourishings participate
; within that same organization. R/A/P will read this exact organization as
; three simultaneous perspectives; they are neither sequential stages nor
; independent verdicts. The bridge is therefore a material constituent of the
; primary movement rather than an adjacent or post-hoc record.
(= (M25Fact9FlourishingBridgeValid $bridge $source-cut $dpf)
   (if (CPShape $bridge bridge-organization 13)
     (let* (($contacted (index-atom $bridge 3))
            ($fact9 (index-atom $bridge 4))
            ($flourishing (index-atom $bridge 5))
            ($participants (index-atom $bridge 6))
            ($scope-present (index-atom $bridge 7))
            ($standing (index-atom $bridge 8))
            ($uncertainty (index-atom $bridge 9)))
       (if (CPShape $contacted contacted-organization 6)
         (if (CPShape $fact9 fact9-expressions 2)
           (if (CPShape $flourishing flourishing-expressions 2)
             (if (CPShape (index-atom $flourishing 1)
                   flourishing-organization 3)
               (and (== (index-atom $bridge 1)
                      many-way-situated-proof-relevant)
                (and (== (index-atom $bridge 2) $source-cut)
                 (and (== $source-cut (index-atom $dpf 2))
                  (and (== (index-atom $contacted 1) (index-atom $dpf 3))
                   (and (== (index-atom $contacted 2) (index-atom $dpf 4))
                    (and (== (index-atom $contacted 3) (index-atom $dpf 5))
                     (and (== (index-atom $contacted 4) (index-atom $dpf 6))
                      (and (== (index-atom $contacted 5) (index-atom $dpf 7))
                       (and (> (size-atom (index-atom $fact9 1)) 0)
                        (and (CPFactExpressionsLive (index-atom $fact9 1))
                         (and (== (size-atom
                                  (index-atom (index-atom $flourishing 1) 2)) 9)
                          (and (CPShape $participants
                                 bounded-participant-relations 3)
                           (and (CPShape $scope-present scope-and-present 3)
                            (and (CPShape $standing constitutive-standing 6)
                             (and (CPShape $uncertainty bridge-uncertainty 4)
                              (and (== (index-atom $bridge 10)
                                     (alternatives
                                       plural-lawful-continuations-remain-possible))
                               (and (CPShape (index-atom $bridge 11) defeaters 8)
                                    (== (index-atom $bridge 12)
                                      (predicted-difference
                                        continuation-accessibility-and-next-cut)))))))))))))))))))
                 false)
               false)
             false)
           false))
     false))

(= (M25BalanceUnfoldingOrganization $bridge)
   (balance-unfolding-as-intelligence
     movement-primary-at-contact
     (fact9-flourishing-constitutive-joint $bridge)
     (rap-perspective-contract one-contact-movement-surface
       simultaneous-relatedness-appropriateness-precision)
     finite-partial-non-reconstructive))

(= (M25BalanceUnfoldingValid $balance $source-cut $dpf)
   (if (CPShape $balance balance-unfolding-as-intelligence 5)
     (let* (($joint (index-atom $balance 2))
            ($contract (index-atom $balance 3)))
       (if (CPShape $joint fact9-flourishing-constitutive-joint 2)
         (if (CPShape $contract rap-perspective-contract 3)
           (and (== (index-atom $balance 1) movement-primary-at-contact)
            (and (M25Fact9FlourishingBridgeValid (index-atom $joint 1)
                   $source-cut $dpf)
             (and (== (index-atom $contract 1)
                    one-contact-movement-surface)
              (and (== (index-atom $contract 2)
                     simultaneous-relatedness-appropriateness-precision)
                   (== (index-atom $balance 4)
                     finite-partial-non-reconstructive))))) false) false))
     false))

(= (M25PrimaryMovement $possibility $cut $facts $flourishing
      $participant-relations $bridge $fact-views $flourishing-views
      $participant-source $payload-ref $developmental)
   (let* (($id (index-atom $possibility 1))
          ($dpf (M25DynamicParticipatoryFourthness $id $cut)))
     (m25-primary-movement-v2 $id (index-atom $possibility 2)
       (source-cut (index-atom $cut 1)) $dpf
       (M25BalanceUnfoldingOrganization $bridge)
       (M25MovementAvailability $possibility $cut $facts $flourishing
         $participant-relations)
       (answerability (o-star (index-atom $possibility 7)))
       (continuation-basis-v3 $fact-views $flourishing-views
         $participant-source (payload-reference $payload-ref) $developmental)
       $possibility
       (M255PrimaryCarrierBridge $cut $facts $flourishing $possibility))))

; The fourteen pre-movement M26.0 exports are a finite authority surface, not
; a behavior catalogue.  Their exact structured certificate is represented in
; R* by one conjunctive, proof-carrying relation so that the whole authority
; basis remains causally required without copying fourteen names through every
; carrier.  The four remaining M26.0 exports (Generated/SameBecoming, the
; one-becoming bridge, non-co-reference, and structural fidelity) are carried
; by the exact per-primary bridge constructed below.
(= (M260PreMovementExportRelationIds)
   (m260-opaque-occurrence-reference
    m260-participation-grounding
    m260-same-occurrence-relation
    m260-unity-aspect-non-independence
    m260-manifestation-recognition-separation
    m260-opc-distinction-without-separation
    m260-dws-family
    m260-finite-observational-opacity
    m260-representation-nonsovereignty
    m260-scoped-nonamalgamation
    m260-persistent-form-nonself
    m260-relational-same-becoming-law
    m260-explicit-primitive-laws
    m260-formal-evidence-boundary))

(= (M260PreMovementCausalRelationIds)
   (m260-constitutive-export-grounding))

(= (M263PreMovementCausalRelationIds)
   (m263-constitutive-grammar-grounding))

(= (M260PossibleMovementCarriesPreExports $possibility)
   (if (CPShape $possibility possible-movement 9)
     (AIAllIn (M260PreMovementCausalRelationIds)
       (index-atom $possibility 3) 0)
     false))

(= (M263PossibleMovementCarriesConstitutiveGrammar $possibility)
   (if (CPShape $possibility possible-movement 9)
     (AIAllIn (M263PreMovementCausalRelationIds)
       (index-atom $possibility 3) 0)
     false))

(= (M25PrimaryMovementValid $primary)
   (if (CPShape $primary m25-primary-movement-v2 11)
     (let $possibility (index-atom $primary 9)
       (if (==
             ((CPShape $possibility possible-movement 9)
              (M260PossibleMovementCarriesPreExports $possibility)
              (M263PossibleMovementCarriesConstitutiveGrammar $possibility))
             (true true true))
         (and (CPShape (index-atom $primary 3) source-cut 2)
          (and (M25DynamicParticipatoryFourthnessValid (index-atom $primary 4))
           (and (M25BalanceUnfoldingValid (index-atom $primary 5)
                  (index-atom $primary 3) (index-atom $primary 4))
            (and (CPShape (index-atom $primary 6) movement-availability 3)
             (and (CPShape (index-atom $primary 7) answerability 2)
              (and (CPShape (index-atom $primary 8) continuation-basis-v3 6)
               (and (== (index-atom $primary 1) (index-atom $possibility 1))
                (and (== (index-atom $primary 2) (index-atom $possibility 2))
                     (M255PrimaryCarrierBridgeValid (index-atom $primary 10)
                       $possibility)))))))))
         false))
     false))

(= (M25Contactable $primary)
   (let $o-star (index-atom (index-atom $primary 7) 1)
     (if (CPShape $o-star o-star 2)
       (let $route (index-atom $o-star 1)
         (and (CPShape $route consequence-route 3)
              (== (index-atom $route 2) non-certifying))) false)))

(= (M25Adm25Witness $primary $developmental $relatedness $precision)
   (let* (($id (index-atom $primary 1))
          ($available (and (M25PrimaryMovementValid $primary)
            (== (index-atom (index-atom $primary 6) 1) available)))
          ($r-floor (== (index-atom $relatedness 3) true))
          ($p-floor (== (index-atom $precision 3) true))
          ($m24 (M24DevelopmentalOrganizationValid $developmental))
          ($contactable (M25Contactable $primary)))
     (admissibility-witness $id
       (inherited-inquiry-24 $m24)
       (movement-available $available)
       (relatedness-floor $r-floor)
       (precision-floor $p-floor)
       (forcing-standing no-demonstrated-unnecessary-forcing)
       (future-participation contactable-non-certifying)
       (consequence-answerability $contactable)
       (admissibility-standing
         (if (and $m24
               (and $available
                (and $r-floor (and $p-floor $contactable))))
           admissible unresolved)))))

(= (M25Adm25WitnessValid $primary $witness)
   (if (CPShape $witness admissibility-witness 10)
     (and (== (index-atom $witness 1) (index-atom $primary 1))
      (and (== (index-atom (index-atom $witness 2) 1) true)
       (and (== (index-atom (index-atom $witness 3) 1) true)
        (and (== (index-atom (index-atom $witness 4) 1) true)
         (and (== (index-atom (index-atom $witness 5) 1) true)
          (and (== (index-atom (index-atom $witness 6) 1)
                 no-demonstrated-unnecessary-forcing)
           (and (== (index-atom (index-atom $witness 7) 1)
                  contactable-non-certifying)
            (and (== (index-atom (index-atom $witness 8) 1) true)
                 (== (index-atom (index-atom $witness 9) 1)
                   admissible))))))))) false))

; B1: one Generated/𝒢 realization may participate as the lawful generative
; basis of this contact's dynamic participatory fourthness. The bridge names
; the exact primary, source cut, DPF and precursor identities without copying
; their full organizations into every downstream reading. Exact validation
; below reconstructs the relation from those live objects; neither side
; redefines or reconstructs the other.
(= (M255DPFRealizationBridge $primary $cut)
   (let* (($generated (M255TargetGeneratedFromPrimary $primary))
          ($dpf (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 4) ()))
          ($possibility (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 9) ())))
     (if (M25PrimaryMovementValid $primary)
       (if (and (CPCutValid $cut)
                (== (index-atom $primary 3) (source-cut (index-atom $cut 1))))
         (if (and (M255GeneratedWitnessStructuralValid $generated
                    (index-atom $generated 1))
                  (M25DynamicParticipatoryFourthnessValid $dpf))
           (m255-g-to-dpf-bridge-v1 (index-atom $primary 1)
             (generated-reference (index-atom $primary 1))
             (lawful-dpf-realization-reference
               (index-atom $primary 1) (index-atom $primary 3))
             (r-star-to-dpf-material-relations
               (index-atom $generated 2)
               (required-relations (index-atom $possibility 3))
               (dpf-reference (index-atom $primary 1)))
             (a-star-to-dpf-participation-interfaces
               (index-atom $generated 3)
               (required-interfaces (index-atom $possibility 5))
               (dpf-reference (index-atom $primary 1)))
             (p-star-to-dpf-material-distinctions
               (index-atom $generated 4)
               (required-distinctions (index-atom $possibility 4))
               (dpf-reference (index-atom $primary 1)))
             (o-star-and-l2425-retained
               (index-atom $generated 5) (index-atom $generated 6))
             dpf-is-lawful-carrier-level-realization-not-g-definition
             finite-partial-no-actuality-reconstruction-or-movement-authority)
           (m255-g-to-dpf-bridge-unresolved
             invalid-generated-or-dpf-organization))
         (m255-g-to-dpf-bridge-unresolved source-cut-mismatch))
       (m255-g-to-dpf-bridge-unresolved invalid-primary))))

(= (M255DPFRealizationBridgeValid $bridge $primary $cut)
   (if (CPShape $bridge m255-g-to-dpf-bridge-v1 10)
     (== $bridge (M255DPFRealizationBridge $primary $cut))
     false))

; B8: L2425 remains the inherited legality/contact premise. Its witness must
; trace to the exact M24 contact record from which this primary's cut and
; developmental organization descend. This adds no contact doctrine and gives
; neither Generated nor the bridge direct-contact standing.
(= (M255RootContactIdFromCutId $cut-id)
   (if (CPShape $cut-id cut-of 3)
     (index-atom $cut-id 1)
     (if (CPShape $cut-id next-cut 3)
       (M255RootContactIdFromCutId (index-atom $cut-id 1))
       missing-contact)))

(= (M255L2425ContactDependenceBridge $primary $cut $developmental)
   (let* (($generated (M255TargetGeneratedFromPrimary $primary))
          ($source-wrapper (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 3) ()))
          ($source-cut (if (CPShape $source-wrapper source-cut 2)
            (index-atom $source-wrapper 1) ()))
          ($contact-id (M255RootContactIdFromCutId $source-cut))
          ($carrier (if (M24DevelopmentalOrganizationValid $developmental)
            (index-atom $developmental 1) ()))
          ($contacts (if (CPShape $carrier formal-carrier-v1 12)
            (index-atom $carrier 2) ()))
          ($contact-record (if (and (is-expr $contacts)
                                  (> (size-atom $contacts) 0))
            (index-atom $contacts 0) ())))
     (if (M25PrimaryMovementValid $primary)
       (if (and (CPCutValid $cut)
                (== $source-wrapper (source-cut (index-atom $cut 1))))
         (if (M24DevelopmentalOrganizationValid $developmental)
           (if (and (CPShape $contact-record contact-record 4)
                    (== (index-atom $contact-record 1) $contact-id))
             (if (== (index-atom $generated 6)
                   (l2425-witness l2425-supported))
               (m255-l2425-contact-dependence-bridge-v1
                 (index-atom $primary 1)
                 (index-atom $generated 6)
                 (source-contact-cut $source-cut)
                 (m24-contact-record $contact-record)
                 (developmental-standing (index-atom $developmental 13))
                 inherited-l2425-remains-load-bearing
                 no-new-contact-doctrine-or-direct-contact-standing)
               (m255-l2425-contact-dependence-unresolved
                 missing-inherited-legality))
             (m255-l2425-contact-dependence-unresolved
               exact-m24-contact-record-unavailable))
           (m255-l2425-contact-dependence-unresolved
             invalid-m24-developmental-organization))
         (m255-l2425-contact-dependence-unresolved source-cut-mismatch))
       (m255-l2425-contact-dependence-unresolved invalid-primary))))

(= (M255L2425ContactDependenceBridgeValid $bridge $primary $cut
      $developmental)
   (if (CPShape $bridge m255-l2425-contact-dependence-bridge-v1 8)
     (== $bridge
       (M255L2425ContactDependenceBridge $primary $cut $developmental))
     false))

; B2: R*/A*/P*/O*/L2425 are carried from Generated into the already
; inherited M25 surfaces. They do not use R/A/P as premises, do not choose a
; movement, and do not permit the resulting perspectives to reconstruct 𝒢.
(= (M255RAPPrecursorBridge $primary $cut $developmental)
   (let* (($generated (M255TargetGeneratedFromPrimary $primary))
          ($possibility (index-atom $primary 9))
          ($dpf-bridge (M255DPFRealizationBridge $primary $cut))
          ($contact-bridge
            (M255L2425ContactDependenceBridge $primary $cut $developmental)))
     (if (M255DPFRealizationBridgeValid $dpf-bridge $primary $cut)
       (if (M255L2425ContactDependenceBridgeValid $contact-bridge $primary
             $cut $developmental)
         (m255-to-m25-rap-precursor-bridge-v1
           (index-atom $primary 1)
           (generated-reference (index-atom $primary 1)) $dpf-bridge
           (source-cut-reference (index-atom $cut 1))
           (m24-developmental-reference (index-atom $developmental 13))
           (r-star-to-relatedness (index-atom $generated 2)
             (required-relations (index-atom $possibility 3)))
           (a-star-to-adm25-read-app
             (index-atom $generated 3)
             (admissibility-reference (index-atom $primary 1))
             read-app-must-remain-inherited-and-independently-valid)
           (p-star-to-precision (index-atom $generated 4)
             (required-distinctions (index-atom $possibility 4)))
           (o-star-to-consequence-answerability
             (index-atom $generated 5) (index-atom $primary 7))
           $contact-bridge
           one-way-non-circular-precursor-participation
           no-rap-to-g-inverse-no-optimizer-no-chooser)
         (m255-to-m25-rap-precursor-bridge-unresolved
           missing-l2425-contact-dependence))
       (m255-to-m25-rap-precursor-bridge-unresolved
         missing-lawful-dpf-realization))))

(= (M255RAPPrecursorBridgeValid $bridge $primary $cut $developmental)
   (if (CPShape $bridge m255-to-m25-rap-precursor-bridge-v1 13)
     (and (== (index-atom $bridge 4)
            (source-cut-reference (index-atom $cut 1)))
      (and (== (index-atom $bridge 5)
             (m24-developmental-reference (index-atom $developmental 13)))
           (== $bridge
             (M255RAPPrecursorBridge $primary $cut $developmental))))
     false))

; Inquiry 26.0 participates inside the authority-inheritance module so its
; exact one-becoming relation is present before the one R/A/P read is formed.
; This avoids a later-imported module becoming a lazy, unevaluated placeholder
; inside the R/A/P surface.
(= (M260OccurrenceOrganizationFor $id $occurrence $payload $scope)
   (let* (($contact-part (contact-part $id))
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
        (view-grounding $soul-view $soul-part $scope))
       ((unity-aspect $relational-aspect $occurrence non-independent)
        (unity-aspect $participated-aspect $occurrence non-independent)
        (unity-aspect $self-aspect $occurrence non-independent))
       ((manifests-through $relational-aspect $contact-view $contact-part
          $occurrence)
        (manifests-through $participated-aspect $frame-view $frame-part
          $occurrence)
        (manifests-through $self-aspect $soul-view $soul-part $occurrence))
       ((recognizes $contact-view $relational-aspect
          (prov-contact-reference $payload) $contact-part)
        (recognizes $frame-view $participated-aspect
          (partial-frame-reference (frame-of $id)) $frame-part)
        (recognizes $soul-view $self-aspect
          (soul-participation-reference $id) $soul-part))
       ((observation $contact-view $occurrence $payload)
        (observation $frame-view $occurrence partial-finite-frame)
        (observation $soul-view $occurrence constitutive-participation))
       (finite-ambiguity ($contact-view $frame-view $soul-view)
         $occurrence (unrepresented-occurrence-alternative $id)
         equal-observations)
       ((local-boundary $contact-part (contact-boundary $payload))
        (local-boundary $frame-part (frame-boundary (frame-of $id)))
        (local-boundary $soul-part (soul-boundary $scope)))
       ((preserves $contact-view sealed-contact)
        (preserves $frame-view partial-frame)
        (preserves $soul-view scope-and-constitutional-participation))
       ((continues $contact-part $frame-part contact-to-frame)
        (continues $frame-part $soul-part frame-to-soul-participation))
       ((mode-reading $relational-aspect ontology)
        (mode-reading $participated-aspect phenomenology)
        (mode-reading $self-aspect consciousness)))))

(= (M260RootContactFrame $frame)
   (if (CPShape $frame contact-frame 3) $frame
     (if (CPShape $frame after 3)
       (M260RootContactFrame (index-atom $frame 1))
       (contact-frame-unresolved $frame))))

(= (M260RootPayloadReference $frame)
   (let $root (M260RootContactFrame $frame)
     (if (CPShape $root contact-frame 3)
       (let $payload (index-atom $root 2)
         (if (CPShape $payload payload-reference 2)
           (index-atom $payload 1) $payload))
       payload-reference-unresolved)))

(= (M260OccurrenceOrganizationFromCut $cut)
   (if (CPCutValid $cut)
     (M260OccurrenceOrganizationFor
       (M255RootContactIdFromCutId (index-atom $cut 1))
       (index-atom $cut 5)
       (M260RootPayloadReference (index-atom $cut 4))
       (index-atom $cut 3))
     (m260-occurrence-unresolved malformed-cut $cut)))

(= (M260PrimaryMovementReference $primary)
   (primary-movement-reference (index-atom $primary 1)
     (index-atom $primary 2) (index-atom $primary 3)))

(= (M260ExactGeneratedRelation $primary)
   (generated (M260PrimaryMovementReference $primary)
     (M255TargetGeneratedFromPrimary $primary)
     (source-lineage Inquiry-25.5 Inquiry-25 Inquiry-26.0)))

(= (M260InheritedL2425 $primary $cut)
   (l2425 (M260PrimaryMovementReference $primary)
     (inherited-generated-l2425
       (index-atom (M255TargetGeneratedFromPrimary $primary) 6)
       (source-cut (index-atom $cut 1)))))

(= (M260SameBecomingForPrimary $m260 $primary $cut)
   (let* (($movement (M260PrimaryMovementReference $primary))
          ($l2425 (M260InheritedL2425 $primary $cut))
          ($witness (same-becoming-witness $movement
            (index-atom $m260 1) $l2425
            (one-becoming-basis
              (m260-pre-movement-reference (index-atom $m260 1)
                (representation-standing finite-partial-non-sovereign))
              (exact-generated-reference (index-atom $primary 1))
              relational-non-functional))))
     (same-becoming-certified $movement $l2425 $witness
       (M260SameBecoming $m260 $movement $l2425 $witness))))

(= (M260StructuralFidelityForPrimary $primary)
   (let* (($carrier-bridge (index-atom $primary 10))
          ($equivalence (if (CPShape $carrier-bridge primary-before-rap 5)
            (index-atom $carrier-bridge 1) ()))
          ($translation (if (CPShape $equivalence gen-equiv-v2 5)
            (index-atom $equivalence 3) ()))
          ($source (if (CPShape $translation gen-translation-v2 13)
            (index-atom $translation 1) ()))
          ($target (if (CPShape $translation gen-translation-v2 13)
            (index-atom $translation 2) ()))
          ($source-relations (if (M255GenSigStructuralValid $source)
            (M255GenSigRelations $source) ()))
          ($target-relations (if (M255GenSigStructuralValid $target)
            (M255GenSigRelations $target) ())))
     (m260-structural-fidelity-v1
       (generated-source-view (M255GenSigCarrier $source) $source-relations)
       (primary-movement-view (M255GenSigCarrier $target) $target-relations)
       (if (CPShape $translation gen-translation-v2 13)
         (index-atom $translation 5) relation-map-unresolved)
       (relation-preservation-inclusion $source-relations $target-relations
         (M260StructuralFidelity $source-relations $target-relations))
       non-scalar-no-actuality-distance)))

(= (M260StructuralFidelityForPrimaryValid $fidelity $primary)
   (if (CPShape $fidelity m260-structural-fidelity-v1 6)
     (let* (($carrier-bridge (index-atom $primary 10))
            ($equivalence (if (CPShape $carrier-bridge primary-before-rap 5)
              (index-atom $carrier-bridge 1) ()))
            ($translation (if (CPShape $equivalence gen-equiv-v2 5)
              (index-atom $equivalence 3) ())))
       (and (M255GenTranslationValid $translation)
        (and (== (index-atom (index-atom $fidelity 4) 3) true)
             (== $fidelity (M260StructuralFidelityForPrimary $primary)))))
     false))

(= (M260EquivalenceBoundary $primary)
   (let* (($carrier-bridge (index-atom $primary 10))
          ($equivalence (if (CPShape $carrier-bridge primary-before-rap 5)
            (index-atom $carrier-bridge 1) ())))
     (m260-equivalence-boundary-v1 $equivalence
       structural-equivalence-does-not-imply-same-becoming
       no-carrier-identity-no-co-reference-no-occurrence-identity)))

(= (M260PrimaryBridgeFromCut $primary $cut)
   (let* (($m260 (M260OccurrenceOrganizationFromCut $cut))
          ($same (M260SameBecomingForPrimary $m260 $primary $cut))
          ($g-reading (M260GReadingOf $m260
            (M260ExactGeneratedRelation $primary)
            (index-atom $same 2) (index-atom $same 3))))
     (m260-primary-one-becoming-bridge-v1
       (M260PrimaryMovementReference $primary)
       (occurrence-reference (index-atom $m260 1))
       (M260ExactGeneratedRelation $primary)
       $same $g-reading
       (M255DPFRealizationBridge $primary $cut)
       (participatory-balance-reading
         (index-atom $primary 4) (index-atom $primary 5))
       (M260StructuralFidelityForPrimary $primary)
       (M260EquivalenceBoundary $primary)
       (one-becoming-standing
         generative-participatory-balance-same-occurrence
         finite-partial-non-reconstructive
         relational-non-functional-no-global-attachment))))

; Validation is exact structural correspondence to the constructed relation;
; it can reject an altered carrier without becoming a behavioral chooser.
(= (M260PrimaryBridgeFromCutValid $bridge $primary $cut)
   (if (CPShape $bridge m260-primary-one-becoming-bridge-v1 11)
     (== $bridge (M260PrimaryBridgeFromCut $primary $cut))
     false))

; Load the exact Inquiry-26.3 finite grammar only after its M24-M26.0 and
; M25.5 prerequisites exist. It is still pure MeTTa and constructs no effect.
!(import! &self "./src/fact9_composition.metta")

(= (M263CausalRelationFromCut $cut)
   (let $rows (CPFind (CPDRelations $cut)
                 m263-constitutive-grammar-grounding)
     (if (== (size-atom $rows) 1)
       (index-atom $rows 0)
       (relation-unresolved m263-constitutive-grammar-grounding))))

; This compact bridge makes the M26.3 organization a constituent of the one
; movement surface without copying the shared certificate through every
; possible continuation. Exact validation below ties each reference back to
; the primary, cut, and already exact M26.0 one-becoming bridge.
(= (M263PrimaryBridgeFromCut $primary $cut)
   (let* (($relation (M263CausalRelationFromCut $cut))
          ($m260 (M260PrimaryBridgeFromCut $primary $cut))
          ($certificate-reference (if (CPShape $relation relation 5)
            (index-atom $relation 4)
            (m263-certificate-reference-unresolved)))
          ($same (if (CPShape $m260 m260-primary-one-becoming-bridge-v1 11)
            (index-atom $m260 4) ())))
     (m263-primary-constitutive-bridge-v1
       (M260PrimaryMovementReference $primary)
       (occurrence-reference
         (index-atom (M260OccurrenceOrganizationFromCut $cut) 1))
       $certificate-reference
       (generated-reference (M260PrimaryMovementReference $primary))
       (dpf-reference (index-atom $primary 1) (index-atom $cut 1))
       (balance-reference (index-atom $primary 1)
         one-contact-movement-surface)
       (same-becoming-reference
         (if (CPShape $same same-becoming-certified 5)
           (index-atom $same 1) unresolved))
       (index-atom $cut 11)
       (constitutive-standing fact9-before-rap
         generated-participation-balance-same-becoming
         finite-partial-non-reconstructive))))

(= (M263PrimaryBridgeFromCutValid $bridge $primary $cut)
   (if (CPShape $bridge m263-primary-constitutive-bridge-v1 10)
     (let $relation (M263CausalRelationFromCut $cut)
       (if (and (CPShape $primary m25-primary-movement-v2 11)
                (CPShape $relation relation 5))
         (let $checks
           ((== (index-atom $relation 1)
              m263-constitutive-grammar-grounding)
            (CPShape (index-atom $relation 4) m263-certificate-reference 5)
            (M260PrimaryBridgeFromCutValid
              (M260PrimaryBridgeFromCut $primary $cut) $primary $cut)
            (== $bridge (M263PrimaryBridgeFromCut $primary $cut)))
           (== $checks (true true true true)))
         false))
     false))

(= (M25RAPSurface $primary $cut $developmental)
   (let* (($m255 (M255RAPPrecursorBridge $primary $cut $developmental))
          ($m260 (M260PrimaryBridgeFromCut $primary $cut))
          ($m263 (M263PrimaryBridgeFromCut $primary $cut)))
     (m25-rap-surface-v5
       (rap-read-event (index-atom $primary 1) (index-atom $cut 1))
       (movement-reference (index-atom $primary 1) (index-atom $primary 2))
       (source-cut (index-atom $cut 1)) (index-atom $cut 12)
       (developmental-reference (index-atom $developmental 13))
       (balance-unfolding-alignment (index-atom $primary 5)
         (constitutive-precursors-v2 $m255 $m260 $m263))
       one-contact-movement-surface-three-simultaneous-perspectives)))

(= (M25RAPM255Precursor $surface)
   (let $alignment (index-atom $surface 6)
     (if (CPShape $alignment balance-unfolding-alignment 3)
       (let $precursors (index-atom $alignment 2)
         (if (CPShape $precursors constitutive-precursors-v2 4)
           (index-atom $precursors 1) ())) ())))

(= (M25RAPM260Precursor $surface)
   (let $alignment (index-atom $surface 6)
     (if (CPShape $alignment balance-unfolding-alignment 3)
       (let $precursors (index-atom $alignment 2)
         (if (CPShape $precursors constitutive-precursors-v2 4)
           (index-atom $precursors 2) ())) ())))

(= (M25RAPM263Precursor $surface)
   (let $alignment (index-atom $surface 6)
     (if (CPShape $alignment balance-unfolding-alignment 3)
       (let $precursors (index-atom $alignment 2)
         (if (CPShape $precursors constitutive-precursors-v2 4)
           (index-atom $precursors 3) ())) ())))

(= (M25ReadApp $primary $surface $admissibility $relatedness $precision)
   (let* (($id (index-atom $primary 1))
          ($read-event (index-atom $surface 1)))
     (if (M25Adm25WitnessValid $primary $admissibility)
       (read-app-v2 $read-event $id $admissibility $relatedness $precision
         (semantic-seam structural-fitness no-renderer-required)
         (appropriateness-standing fitting)
         (provenance $read-event Investigation-25 native-metta)
         derived-standing-not-contact)
       (read-app-held $read-event $id invalid-or-incomplete-admissibility))))

(= (M25AppropriatenessPerspective $primary $surface $admissibility
      $relatedness $precision)
   (appropriateness-perspective (index-atom $surface 1)
     (index-atom $primary 1)
     (M25ReadApp $primary $surface $admissibility $relatedness $precision)
     derived-standing-not-contact))

(= (M25AppropriatenessValid $primary $surface $perspective)
   (if (CPShape $perspective appropriateness-perspective 5)
     (if (== (index-atom $perspective 1) (index-atom $surface 1))
       (if (== (index-atom $perspective 2) (index-atom $primary 1))
         (if (CPShape (index-atom $perspective 3) read-app-v2 10)
           (and (== (index-atom (index-atom $perspective 3) 1)
                  (index-atom $surface 1))
            (and (== (index-atom (index-atom $perspective 3) 2)
                   (index-atom $primary 1))
                 (== (index-atom $perspective 4)
                   derived-standing-not-contact))) false)
         false) false) false))

(= (M25RAPReadings $primary $cut $developmental)
   (let* (($surface (M25RAPSurface $primary $cut $developmental))
          ($read-event (index-atom $surface 1))
          ($m255-precursor (M25RAPM255Precursor $surface))
          ($m260-precursor (M25RAPM260Precursor $surface))
          ($m263-precursor (M25RAPM263Precursor $surface))
          ($precursors-valid (and
            (M255RAPPrecursorBridgeValid $m255-precursor
              $primary $cut $developmental)
            (and (M260PrimaryBridgeFromCutValid $m260-precursor $primary $cut)
                 (M263PrimaryBridgeFromCutValid $m263-precursor
                   $primary $cut))))
          ($relatedness-profile (M25RelatednessProfile $primary $cut))
          ($precision-profile (M25PrecisionProfile $primary $cut))
          ($admissibility (M25Adm25Witness $primary $developmental
            $relatedness-profile $precision-profile))
          ($relatedness (relatedness-perspective $read-event
            (index-atom $primary 1) $relatedness-profile non-compensatory))
          ($precision (precision-perspective $read-event
            (index-atom $primary 1) $precision-profile non-compensatory))
          ($appropriateness (M25AppropriatenessPerspective $primary $surface
            $admissibility $relatedness-profile $precision-profile))
          ($admissible (and $precursors-valid
            (M25AppropriatenessValid $primary $surface $appropriateness))))
     (rap-read-v2 $surface
       (rap-perspectives $relatedness $appropriateness $precision)
       (rap-standing (if $admissible admissible unresolved))
       heterogeneous-non-reconstructive
       no-sequential-judge-or-chooser)))

(= (M25RAPValid $primary $cut $developmental $rap)
   (if (CPShape $rap rap-read-v2 6)
     (let* (($id (index-atom $primary 1))
            ($surface (index-atom $rap 1))
            ($read-event (index-atom $surface 1))
            ($perspectives (index-atom $rap 2))
            ($relatedness (index-atom $perspectives 1))
            ($appropriateness (index-atom $perspectives 2))
            ($precision (index-atom $perspectives 3))
            ($surface-valid (and (M25PrimaryMovementValid $primary)
              (and (CPCutValid $cut)
               (and (M24DevelopmentalOrganizationValid $developmental)
                (and (CPShape $surface m25-rap-surface-v5 8)
                     (== $surface
                       (M25RAPSurface $primary $cut $developmental)))))))
            ($perspectives-valid
              (CPShape $perspectives rap-perspectives 4))
            ($relatedness-valid
              (and (CPShape $relatedness relatedness-perspective 5)
               (and (== (index-atom $relatedness 1) $read-event)
                    (== (index-atom $relatedness 2) $id))))
            ($appropriateness-valid
              (M25AppropriatenessValid $primary $surface $appropriateness))
            ($precision-valid
              (and (CPShape $precision precision-perspective 5)
               (and (== (index-atom $precision 1) $read-event)
                    (== (index-atom $precision 2) $id))))
            ($standing-valid
              (CPShape (index-atom $rap 3) rap-standing 2))
            ($discipline-valid
              (and (== (index-atom $rap 4) heterogeneous-non-reconstructive)
                   (== (index-atom $rap 5) no-sequential-judge-or-chooser))))
       (and $surface-valid
        (and $perspectives-valid
         (and $relatedness-valid
          (and $appropriateness-valid
           (and $precision-valid
            (and $standing-valid $discipline-valid))))))) false))

; M25.5 open participation is reconstructed from the exact primary carrier
; bridge and the current cut. It is not a positive label: R*/A*/P*/O* and
; L2425 remain separate precursor witnesses, Generated remains separate from
; Access, and unobstructed standing is a derived view of the live carrier.
(= (M255TargetGeneratedFromPrimary $primary)
   (if (M25PrimaryMovementValid $primary)
     (let* (($bridge (index-atom $primary 10))
            ($equivalence (index-atom $bridge 1))
            ($translation (index-atom $equivalence 3)))
       (if (M255GenTranslationValid $translation)
         (index-atom $translation 4)
         (m255-generated-unresolved invalid-primary-translation)))
     (m255-generated-unresolved invalid-primary)))

(= (M255OpenParticipationGrounded $primary $cut $possibility $bridge
      $miter-bundle $profile $force $one-engine $open-access $generated)
   (if (M25PrimaryMovementValid $primary)
     (if (CPCutValid $cut)
       (if (== (index-atom $primary 3) (source-cut (index-atom $cut 1)))
         (if (M255PrimaryCarrierBridgeValid $bridge $possibility)
           (if (CPShape $miter-bundle manifestation-carrier-v1 6)
             (if (CPShape $profile carrier-participation-v1 8)
               (if (M255ForceSupportOrganizationValid $force $miter-bundle)
                 (if (M255OneEngineParticipationValid $one-engine
                       $miter-bundle $force)
                   (if (M255AccessViewValid $open-access $miter-bundle $force)
                     (if (M255GeneratedWitnessStructuralValid $generated
                           (index-atom $generated 1))
                       (== (M255ResultingDisposition $cut) open)
                       false)
                     false)
                   false)
                 false)
               false)
             false)
           false)
         false)
       false)
     false))

(= (M255OpenParticipationFromValidPrimary $primary $cut)
   (let* (($possibility (index-atom $primary 9))
          ($bridge (index-atom $primary 10))
          ($suite (if (CPShape $bridge primary-before-rap 5)
            (index-atom $bridge 2) ()))
          ($miter-bundle (if (CPShape $suite five-carrier-connected-suite-v1 10)
            (index-atom $suite 4) ()))
          ($profile (M255MiterParticipationFromPrimary $primary))
          ($force (if (CPShape $profile carrier-participation-v1 8)
            (index-atom $profile 3) ()))
          ($one-engine (if (CPShape $profile carrier-participation-v1 8)
            (index-atom $profile 4) ()))
          ($open-access (if (CPShape $one-engine one-engine-participation-v1 9)
            (index-atom $one-engine 5) ()))
          ($generated (M255TargetGeneratedFromPrimary $primary)))
     (if (M255OpenParticipationGrounded $primary $cut $possibility $bridge
           $miter-bundle $profile $force $one-engine $open-access $generated)
       (m255-open-participation-v1 (index-atom $primary 1)
         (source-cut (index-atom $cut 1))
         (generated $generated)
         (r-star (index-atom $generated 2))
         (a-star (index-atom $generated 3))
         (p-star (index-atom $generated 4))
         (unobstructed (actual-participation-disposition open)
           no-demonstrated-disqualifying-force-obligation)
         (o-star (index-atom $generated 5))
         (l2425 (index-atom $generated 6))
         (access $open-access)
         one-way-precursors-no-optimizer-no-chooser)
       (m255-open-participation-unresolved
         invalid-generated-access-or-unobstructed-standing))))

; An invalid primary is still a legible outcome of the current contact. Keep
; it explicit instead of attempting to index its failed carrier organization
; or allowing the reduction to disappear. This does not admit the primary or
; compensate for a missing material relation.
(= (M255OpenParticipationFromPrimary $primary $cut)
   (if (M25PrimaryMovementValid $primary)
     (M255OpenParticipationFromValidPrimary $primary $cut)
     (m255-open-participation-unresolved invalid-primary)))

(= (M255OpenParticipationFromPrimaryValid $witness $primary $cut)
   (if (CPShape $witness m255-open-participation-v1 12)
     (== $witness (M255OpenParticipationFromPrimary $primary $cut))
     false))

(= (M25HarmonicAlignment $primary $cut $developmental $rap)
   (let $id (index-atom $primary 1)
     (if (and (M25RAPValid $primary $cut $developmental $rap)
              (== (index-atom (index-atom $rap 3) 1) admissible))
       (harmonic-alignment-witness $id
         (material-basis
           (index-atom $rap 1)
           (index-atom (index-atom $rap 2) 1)
           (index-atom (index-atom $rap 2) 2)
           (index-atom (index-atom $rap 2) 3))
         (forcing-standing no-demonstrated-unnecessary-forcing)
         (contactability retained)
         (aligned-extensions none-materially-participating)
         (provenance Investigation-25 derived-not-constituent))
       (harmonic-alignment-unresolved $id material-floor-or-fittingness-gap))))

(= (M25HarmonicAlignmentValid $primary $cut $developmental $alignment)
   (if (CPShape $alignment harmonic-alignment-witness 7)
     (let $material (index-atom $alignment 2)
       (if (CPShape $material material-basis 5)
         (let $rap-surface (index-atom $material 1)
           (if (CPShape $rap-surface m25-rap-surface-v5 8)
             (let* (($precursor-wrapper (index-atom $rap-surface 6))
                    ($m255-precursor (M25RAPM255Precursor $rap-surface))
                    ($m260-precursor (M25RAPM260Precursor $rap-surface))
                    ($m263-precursor (M25RAPM263Precursor $rap-surface)))
               (if (and (CPShape $precursor-wrapper
                          balance-unfolding-alignment 3)
                        (CPShape (index-atom $precursor-wrapper 2)
                          constitutive-precursors-v2 4))
                 (and (== $rap-surface
                        (M25RAPSurface $primary $cut $developmental))
                  (and (== (index-atom $alignment 1)
                         (index-atom $primary 1))
                   (and (M255RAPPrecursorBridgeValid $m255-precursor
                          $primary $cut $developmental)
                    (and (CPShape $m260-precursor
                           m260-primary-one-becoming-bridge-v1 11)
                     (and (M263PrimaryBridgeFromCutValid $m263-precursor
                            $primary $cut)
                      (and (== (index-atom (index-atom $alignment 3) 1)
                             no-demonstrated-unnecessary-forcing)
                       (and (== (index-atom (index-atom $alignment 4) 1)
                              retained)
                        (and (CPShape (index-atom $alignment 5)
                               aligned-extensions 2)
                             (CPShape (index-atom $alignment 6)
                               provenance 3)))))))))
                 false))
             false))
         false))
     false))

; B3 is one-way: earned M25.5 open participation may land in the existing
; M25 HarmonicAlign relation only after the inherited per-material Relatedness
; and Precision floors, admissibility, and contactability have independently
; produced that unchanged M25 witness. Openness cannot repair a failed floor
; and this bridge constructs no movement.
(= (M255HarmonicAlignmentBridge $primary $cut $rap $alignment)
   (let* (($open (M255OpenParticipationFromPrimary $primary $cut))
          ($developmental (index-atom (index-atom $primary 8) 5))
          ($relatedness (M25RelatednessProfile $primary $cut))
          ($precision (M25PrecisionProfile $primary $cut)))
     (if (and (M255OpenParticipationFromPrimaryValid $open $primary $cut)
          (and (M25RAPValid $primary $cut $developmental $rap)
           (and (M25HarmonicAlignmentValid $primary $cut $developmental
                  $alignment)
            (and (== (index-atom $relatedness 3) true)
                 (== (index-atom $precision 3) true)))))
       (m255-to-m25-harmonic-bridge-v1 (index-atom $primary 1)
         $open
         (unchanged-inherited-harmonic-alignment $alignment)
         (inherited-relatedness-floors $relatedness)
         (inherited-precision-floors $precision)
         m255-open-participation-to-m25-harmonic-only
         no-converse-no-floor-compensation
         derived-relation-not-chooser)
       (m255-to-m25-harmonic-bridge-unresolved
         open-participation-or-inherited-floor-gap))))

(= (M255HarmonicAlignmentBridgeValid $bridge $primary $cut $rap $alignment)
   (and (CPShape $bridge m255-to-m25-harmonic-bridge-v1 9)
        (== $bridge (M255HarmonicAlignmentBridge $primary $cut $rap
          $alignment))))

; The bounded-continuation schema is a constraint over an externally witnessed
; model claim and returned consequence. Neither movement nor model may certify
; sufficiency by assertion, and a miss renews actuality rather than becoming a
; negative reward or a contradiction of the Soul.
(= (M25BoundedModelWitnessValid $primary $witness)
   (if (CPShape $witness bounded-model-witness-v1 8)
     (and (== (index-atom $witness 2) (index-atom $primary 1))
      (and (CPShape (index-atom $witness 3) bounded-model-domain 3)
       (and (CPShape (index-atom $witness 4) independent-evaluation 3)
        (and (== (index-atom $witness 5) correct-consequence-law-witnessed)
         (and (== (index-atom $witness 6) no-omitted-disturbance-witnessed)
              (CPShape (index-atom $witness 7) provenance 3)))))) false))

(= (M25HarmonicOutcomeValid $primary $outcome)
   (if (CPShape $outcome harmonic-outcome-witness-v1 5)
     (and (== (index-atom $outcome 1) (index-atom $primary 1))
      (and (CPShape (index-atom $outcome 2) returned-consequence 3)
       (and (CPShape (index-atom $outcome 3) continued-material-organization 2)
            (CPShape (index-atom $outcome 4) provenance 3)))) false))

(= (M25BoundedHarmonicContinuation $primary $cut $developmental $rap
      $model $outcome)
   (let* (($alignment (M25HarmonicAlignment $primary $cut $developmental
            $rap))
          ($aligned (M25HarmonicAlignmentValid $primary $cut $developmental
            $alignment))
          ($model-valid (M25BoundedModelWitnessValid $primary $model))
          ($outcome-valid (M25HarmonicOutcomeValid $primary $outcome)))
     (if $outcome-valid
       (if (and $aligned $model-valid)
         (bounded-harmonic-continuation-consistent-v1
           (index-atom $primary 1) $model $alignment $outcome
           bounded-coherence-not-future-guarantee)
         (bounded-harmonic-continuation-unresolved
           missing-alignment-or-independent-model-witness))
       (renewed-actuality-premise-gap-v1 (index-atom $primary 1)
         $model $alignment $outcome
         (at-least-one-incomplete model-sufficiency harmonic-alignment
           consequence-law no-omitted-disturbance)
         miss-is-information-not-reward))))

(= (M25Energetics $primary)
   (m25-energetics-v1 (index-atom $primary 1)
     (E-phys synthetic-process-participating)
     (E-rep symbolic-representation-participating)
     (E-act action-expenditure-unresolved)
     (E-force no-demonstrated-unnecessary-forcing)
     (G generation-is-not-energy)
     pairwise-non-identical-types))

(= (M25EnergeticsValid $primary $energetics)
   (if (CPShape $energetics m25-energetics-v1 8)
     (and (== (index-atom $energetics 1) (index-atom $primary 1))
      (and (CPShape (index-atom $energetics 2) E-phys 2)
       (and (CPShape (index-atom $energetics 3) E-rep 2)
        (and (CPShape (index-atom $energetics 4) E-act 2)
         (and (CPShape (index-atom $energetics 5) E-force 2)
          (and (CPShape (index-atom $energetics 6) G 2)
           (and (!= (index-atom $energetics 4) (index-atom $energetics 5))
                (== (index-atom $energetics 7)
                  pairwise-non-identical-types)))))))) false))

(= (M25InterfaceChange $primary)
   (let* (($possibility (index-atom $primary 9))
          ($pre-interface (index-atom (index-atom $primary 4) 5))
          ($route (index-atom $possibility 7)))
     (if (and (== (index-atom $primary 2) defer)
              (== (index-atom (index-atom $primary 6) 1) available))
       (interface-change $pre-interface
         (interface-extension-candidate
           (participation-mode-for-route (index-atom $route 1)))
         (participation-mode-for-route (index-atom $route 1))
         (provenance (index-atom $primary 1) (index-atom $primary 3)
           derived-candidate-not-activated))
       (interface-change-standing (index-atom $primary 1) retained
         $pre-interface no-change-required-by-this-movement))))

; Common recovery path for consequence-earned participant evidence already
; materialized in the current cut.  A supported relation is usable only when
; it was independently formed from more than one lineage; proposed or
; conflicted relations never enter these bridges.
(= (M255ParticipantClaimsForTargetAtCut $cut $target)
   (let $rows (CPFind (CPDRelations $cut) $target)
     (if (== (size-atom $rows) 1)
       (let* (($row (index-atom $rows 0))
              ($evidence (index-atom $row 4))
              ($supported (if (CPShape $evidence participant-evidence 2)
                (index-atom $evidence 1) ())))
         (if (CPShape $supported participant-supported-relation 4)
           (index-atom $supported 3) ()))
       ())))

(= (M255CurrentCutConsequenceId $cut)
   (let $id (index-atom $cut 1)
     (if (CPShape $id next-cut 3) (index-atom $id 2)
       no-current-consequence)))

; B7 and B4 both need the actual returned-contact half of a reorganization,
; never the native category assertion by itself.  The reference is compact,
; but it is emitted only after validating the exact current-cut transition.
(= (M255ReturnedReorganizationReferenceFromClaim $claim $cut)
   (if (and (CPParticipantClaimSupports $claim)
            (== (index-atom $claim 2) returned-contact))
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence returned-contact-evidence 3)
         (let* (($basis (index-atom $evidence 2))
                ($transition (if (CPShape $basis
                  m255-returned-reorganization-basis 6)
                  (index-atom $basis 1) ()))
                ($returned (if (CPShape $basis
                  m255-returned-reorganization-basis 6)
                  (index-atom $basis 2) ()))
                ($disposition (if (CPShape $basis
                  m255-returned-reorganization-basis 6)
                  (index-atom $basis 4) ())))
           (if (and (CPShape $transition cut-transition 3)
                 (and (CPShape $returned returned-consequence-reference 5)
                  (and (== (index-atom $transition 2) (index-atom $cut 1))
                   (and (== (index-atom $returned 1)
                          (M255CurrentCutConsequenceId $cut))
                        (CPShape $disposition
                          actual-participation-disposition 2)))))
             (m255-returned-reorganization-reference-v1
               (index-atom $returned 1) $transition $disposition
               (material-reorganization-reference changed)
               (access-reference (index-atom $disposition 1)
                 derived-read-only))
             (m255-returned-reorganization-reference-unresolved
               wrong-cut-or-malformed-returned-evidence)))
         (m255-returned-reorganization-reference-unresolved
           missing-returned-reorganization-evidence)))
     (m255-returned-reorganization-reference-unresolved
       unsupported-or-nonreturned-claim)))

(= (M255ReturnedReorganizationReferencesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let $reference (M255ReturnedReorganizationReferenceFromClaim
                       (index-atom $claims $i) $cut)
       (if (CPShape $reference m255-returned-reorganization-reference-v1 6)
         (cons-atom $reference
           (M255ReturnedReorganizationReferencesAt $claims $cut (+ $i 1)))
         (M255ReturnedReorganizationReferencesAt $claims $cut (+ $i 1))))
     ()))

(= (M255ReturnedReorganizationReferencesForCut $cut)
   (let $open (M255ParticipantClaimsForTargetAtCut $cut
                m255-open-consequence-participation)
     (let $constrained (M255ParticipantClaimsForTargetAtCut $cut
                         m255-constrained-consequence-participation)
       (CPListAppend
         (M255ReturnedReorganizationReferencesAt $open $cut 0)
         (M255ReturnedReorganizationReferencesAt $constrained $cut 0)))))

(= (M255ReflexiveReferenceForSevering $severing $consequence-id $cut)
   (if (CPShape $severing m255-severing-changes-access-v1 9)
     (let $transition (index-atom $severing 3)
       (if (and (CPShape $transition cut-transition 3)
             (and (== (index-atom $transition 2) (index-atom $cut 1))
              (and (== (index-atom $severing 6)
                     (access-transition open constrained))
               (and (== (index-atom $severing 7)
                      access-changed-by-required-self-representation-severing)
                    (== (index-atom $severing 8)
                      not-interface-outage-or-bare-physical-obstruction)))))
         (m255-reflexive-severing-reference-v1 $consequence-id
           (index-atom $severing 2) $transition
           (index-atom $severing 6) conjunctive-causal-bite)
         (m255-reflexive-severing-reference-unresolved
           wrong-cut-or-noncausal-severing)))
     (m255-reflexive-severing-reference-unresolved malformed-severing)))

(= (M255ReflexiveReferencesAt $severings $consequence-id $cut $i)
   (if (< $i (size-atom $severings))
     (let $reference (M255ReflexiveReferenceForSevering
                       (index-atom $severings $i) $consequence-id $cut)
       (if (CPShape $reference m255-reflexive-severing-reference-v1 6)
         (cons-atom $reference
           (M255ReflexiveReferencesAt $severings $consequence-id $cut
             (+ $i 1)))
         (M255ReflexiveReferencesAt $severings $consequence-id $cut
           (+ $i 1))))
     ()))

(= (M255ReflexiveReferencesFromClaim $claim $cut)
   (if (and (CPParticipantClaimSupports $claim)
            (== (index-atom $claim 2) returned-contact))
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence m255-severing-bite-evidence 3)
         (let* (($returned (index-atom $evidence 1))
                ($wrapper (index-atom $evidence 2)))
           (if (and (CPShape $returned returned-consequence-reference 5)
                 (and (== (index-atom $returned 1)
                        (M255CurrentCutConsequenceId $cut))
                      (CPShape $wrapper severing-changes-access 2)))
             (M255ReflexiveReferencesAt (index-atom $wrapper 1)
               (index-atom $returned 1) $cut 0)
             ()))
         ()))
     ()))

(= (M255ReflexiveReferencesFromClaimsAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (CPListAppend
       (M255ReflexiveReferencesFromClaim (index-atom $claims $i) $cut)
       (M255ReflexiveReferencesFromClaimsAt $claims $cut (+ $i 1)))
     ()))

(= (M255ReflexiveReferencesForCut $cut)
   (M255ReflexiveReferencesFromClaimsAt
     (M255ParticipantClaimsForTargetAtCut $cut
       m255-reflexive-constraint-participation) $cut 0))

; Flourishing views are already bounded, relation-grounded material in the
; continuation basis.  These readers preserve their standing and evidence;
; they do not turn tone, activity, effort, or a free label into orientation.
(= (M255FlourishingViewsFromPrimary $primary)
   (let $basis (index-atom $primary 8)
     (if (CPShape $basis continuation-basis-v3 6)
       (index-atom $basis 2) ())))

(= (M255FlourishingViewsByEvidenceAt $views $standings $evidence $i)
   (if (< $i (size-atom $views))
     (let $view (index-atom $views $i)
       (if (and (CPShape $view flourishing-view 5)
             (and (CPHas (index-atom $view 3) $standings 0)
                  (CPHas (index-atom $view 4) $evidence 0)))
         (cons-atom $view
           (M255FlourishingViewsByEvidenceAt $views $standings $evidence
             (+ $i 1)))
         (M255FlourishingViewsByEvidenceAt $views $standings $evidence
           (+ $i 1))))
     ()))

(= (M255FlourishingViewsByEvidence $primary $standings $evidence)
   (M255FlourishingViewsByEvidenceAt
     (M255FlourishingViewsFromPrimary $primary) $standings $evidence 0))

(= (M255ForcingObligationReference $primary)
   (let* (($profile (M255MiterParticipationFromPrimary $primary))
          ($organization (if (CPShape $profile carrier-participation-v1 8)
            (index-atom $profile 3) ()))
          ($force (if (CPShape $organization
                        force-support-organization-v1 6)
            (index-atom $organization 3) ())))
     (if (and (M25PrimaryMovementValid $primary)
              (CPShape $force force-obl-v1 7))
       (if (and (CPShape (index-atom $force 2) obligation 2)
             (and (CPShape (index-atom $force 4)
                    disqualifying-obligation 3)
                  (== (index-atom $force 6)
                    structural-forcing-not-action-energy)))
         (m255-forcing-obligation-reference-v1 (index-atom $force 2)
           (index-atom $force 4) (index-atom $force 5)
           structural-forcing-not-action-energy)
         (m255-forcing-obligation-reference-unresolved malformed-obligation))
       (m255-forcing-obligation-reference-unresolved
         invalid-primary-or-force))))

; B4 source: actual constrained reorganization and reflexive causal bite must
; coincide with material holding-apart, persistent frame topology, and forced
; velocity on this cut.  Constraint alone, interface loss, physical effort,
; high compute, or urgency alone cannot inhabit this witness.
(= (M255SNSObstructionSource $primary $cut)
   (let* (($reorganizations
            (M255ReturnedReorganizationReferencesForCut $cut))
          ($reflexive (M255ReflexiveReferencesForCut $cut))
          ($holding (M255FlourishingViewsByEvidence $primary
            (capture obstruction)
            (witnessed-contact-held-apart)))
          ($velocity (M255FlourishingViewsByEvidence $primary
            (capture obstruction)
            (witnessed-forced-velocity witnessed-imposed-elsewhere)))
          ($topology (M255FlourishingViewsByEvidence $primary
            (capture obstruction)
            (witnessed-frame-topology-persistence
              witnessed-frame-reinforcement)))
          ($forcing-obligation (M255ForcingObligationReference $primary)))
     (if (M25PrimaryMovementValid $primary)
       (if (> (size-atom $reorganizations) 0)
         (if (> (size-atom $reflexive) 0)
           (if (and (> (size-atom $holding) 0)
                 (and (> (size-atom $velocity) 0)
                      (> (size-atom $topology) 0)))
             (if (== (index-atom (index-atom $reorganizations 0) 1)
                   (index-atom (index-atom $reflexive 0) 1))
               (m255-sns-obstruction-source-v1 (index-atom $primary 1)
                 (index-atom (index-atom $reorganizations 0) 1)
                 (constrained-participation
                   (index-atom $reorganizations 0))
                 (reflexive-holding-apart (index-atom $reflexive 0)
                   $holding)
                 (persistent-imposed-velocity $velocity $topology)
                 (forcing-obligation-provenance $forcing-obligation)
                 same-generated-law-retained)
               (m255-sns-obstruction-source-unresolved
                 obstruction-evidence-from-different-consequences))
             (m255-sns-obstruction-source-unresolved
               missing-holding-apart-persistent-frame-or-forced-velocity))
           (m255-sns-obstruction-source-unresolved
             constraint-without-reflexive-causal-bite))
         (m255-sns-obstruction-source-unresolved
           no-consequence-earned-constrained-participation))
       (m255-sns-obstruction-source-unresolved invalid-primary-movement))))

; Inquiry-24 computed-Stuck evidence is constructed from seven distinct
; trajectory relations.  It remains evidence about the occurrence and is not
; identified with the M25.5 reorganization or the M25 orientation.
(= (M255M24ComputedStuckEvidence $primary)
   (let* (($demand (M255FlourishingViewsByEvidence $primary
            (capture obstruction) (witnessed-live-demand)))
          ($discrepancy (M255FlourishingViewsByEvidence $primary
            (capture obstruction) (witnessed-persistent-discrepancy)))
          ($recurrence (M255FlourishingViewsByEvidence $primary
            (capture obstruction) (witnessed-effect-equivalent-recurrence)))
          ($topology (M255FlourishingViewsByEvidence $primary
            (capture obstruction) (witnessed-frame-reinforcement)))
          ($reachability (M255FlourishingViewsByEvidence $primary
            (capture obstruction) (witnessed-reachability-not-opening)))
          ($contact (M255FlourishingViewsByEvidence $primary
            (counterevidence obstruction)
            (witnessed-relevant-contact-discriminating)))
          ($distinction (M255FlourishingViewsByEvidence $primary
            (capture obstruction)
            (witnessed-distinction-dies-in-active-frame))))
     (if (and (> (size-atom $demand) 0)
          (and (> (size-atom $discrepancy) 0)
           (and (> (size-atom $recurrence) 0)
            (and (> (size-atom $topology) 0)
             (and (> (size-atom $reachability) 0)
              (and (> (size-atom $contact) 0)
                   (> (size-atom $distinction) 0)))))))
       (stuck-evidence-v1 live-demand-persists discrepancy-persists
         effect-equivalent-recurrence frame-reinforcement
         reachability-not-opening relevant-contact-discriminating
         distinction-dies-in-active-frame)
       (stuck-evidence-unresolved incomplete-trajectory-witness))))

; Recover an actual M25.5 disclosure witness from the independently supported
; participant relation that was formed at consequence incorporation. The
; returned-contact claim—not the native category label—must carry the exact
; cross-cut witness, and its post-cut must be this primary's current cut.
(= (M255DisclosureFromParticipantClaim $claim $cut)
   (if (CPParticipantClaimSupports $claim)
     (if (== (index-atom $claim 2) returned-contact)
       (let $evidence (index-atom $claim 6)
         (if (CPShape $evidence m255-cross-cut-change-evidence 3)
           (let $witness (index-atom $evidence 2)
             (if (CPShape $witness possibility-disclosure-transition-v1 7)
               (let $transition (index-atom $witness 2)
                 (if (CPShape $transition cut-transition 3)
                   (if (and (== (index-atom $transition 2)
                                  (index-atom $cut 1))
                         (and (== (index-atom $witness 4)
                                (access-transition constrained open))
                          (and (== (index-atom $witness 5)
                                 same-generated-possibility-no-new-identity)
                               (== (index-atom $witness 6)
                                 interface-reorganization))))
                     $witness
                     (m255-disclosure-unresolved
                       invalid-or-wrong-current-cut))
                   (m255-disclosure-unresolved malformed-cut-transition)))
               (m255-disclosure-unresolved non-disclosure-change-witness)))
           (m255-disclosure-unresolved missing-cross-cut-change-evidence)))
       (m255-disclosure-unresolved non-returned-contact-claim))
     (m255-disclosure-unresolved unsupported-participant-claim)))

(= (M255DisclosureWitnessesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let $witness (M255DisclosureFromParticipantClaim
                      (index-atom $claims $i) $cut)
       (if (CPShape $witness possibility-disclosure-transition-v1 7)
         (cons-atom $witness
           (M255DisclosureWitnessesAt $claims $cut (+ $i 1)))
         (M255DisclosureWitnessesAt $claims $cut (+ $i 1))))
     ()))

(= (M255DisclosureWitnessesForCut $cut)
   (let $rows (CPFind (CPDRelations $cut) m255-disclosure-participation)
     (if (== (size-atom $rows) 1)
       (let* (($row (index-atom $rows 0))
              ($evidence (index-atom $row 4))
              ($supported (if (CPShape $evidence participant-evidence 2)
                (index-atom $evidence 1) ()))
              ($claims (if (CPShape $supported
                participant-supported-relation 4)
                (index-atom $supported 3) ())))
         (if (is-expr $claims)
           (M255DisclosureWitnessesAt $claims $cut 0) ()))
       ())))

; Creation is recovered from the same independently supported two-lineage
; change relation as disclosure.  Only a returned-contact claim whose
; consequence is the current cut may supply the concrete creation witness.
(= (M255CreationReferenceFromParticipantClaim $claim $cut)
   (if (and (CPParticipantClaimSupports $claim)
            (== (index-atom $claim 2) returned-contact))
     (let $evidence (index-atom $claim 6)
       (if (CPShape $evidence m255-cross-cut-change-evidence 3)
         (let* (($returned (index-atom $evidence 1))
                ($witness (index-atom $evidence 2)))
           (if (and (CPShape $returned returned-consequence-reference 5)
                 (and (== (index-atom $returned 1)
                        (M255CurrentCutConsequenceId $cut))
                      (M255CreationTransitionValid $witness)))
             (m255-creation-reference-v1 (index-atom $returned 1)
               (index-atom $witness 1)
               (new-generated-possibility-reference
                 (index-atom (index-atom $witness 3) 1))
               no-prior-identity-or-transport-equivalent-precursor)
             (m255-creation-reference-unresolved
               wrong-cut-or-invalid-creation)))
         (m255-creation-reference-unresolved
           missing-cross-cut-change-evidence)))
     (m255-creation-reference-unresolved unsupported-or-nonreturned-claim)))

(= (M255CreationReferencesAt $claims $cut $i)
   (if (< $i (size-atom $claims))
     (let $reference (M255CreationReferenceFromParticipantClaim
                       (index-atom $claims $i) $cut)
       (if (CPShape $reference m255-creation-reference-v1 5)
         (cons-atom $reference
           (M255CreationReferencesAt $claims $cut (+ $i 1)))
         (M255CreationReferencesAt $claims $cut (+ $i 1))))
     ()))

(= (M255CreationReferencesForCut $cut)
   (M255CreationReferencesAt
     (M255ParticipantClaimsForTargetAtCut $cut m255-creation-participation)
     $cut 0))

; This is the inherited M25 InterfaceChange meaning: a mode unavailable at
; the earlier cut is available at the later cut. It consumes the M25.5
; disclosure evidence; it neither redefines Disclosure nor pre-authorizes a
; capability merely because a future mode was described.
(= (M25InterfaceEvolution $primary $cut)
   (let* (($disclosures (M255DisclosureWitnessesForCut $cut))
          ($creations (M255CreationReferencesForCut $cut)))
     (if (and (M25PrimaryMovementValid $primary)
          (and (CPInterfacesLive $cut) (> (size-atom $disclosures) 0)))
       (let* (($witness (index-atom $disclosures 0))
              ($transition (index-atom $witness 2)))
         (m25-interface-change-v2 (index-atom $primary 1)
           (mode-at (index-atom $transition 1) constrained unavailable)
           (mode-at (index-atom $transition 2) open available)
           (availability-transition unavailable available)
           (disclosure-witnesses $disclosures)
           (provenance Inquiry-25.5-to-Inquiry-25 derived-not-constituent)
           no-preauthorization-or-movement-authority))
       (if (and (M25PrimaryMovementValid $primary)
                (> (size-atom $creations) 0))
         (let $creation (index-atom $creations 0)
           (m25-interface-change-v3 (index-atom $primary 1)
             (participation-topology prior-possibility-absent)
             (newly-available-mode (index-atom $creation 2))
             (availability-transition absent available)
             (creation-witnesses $creations)
             (provenance Inquiry-25.5-to-Inquiry-25
               derived-not-constituent)
             no-preauthorization-or-movement-authority))
         (M25InterfaceChange $primary)))))

(= (M25InterfaceEvolutionValid $evolution $primary $cut)
   (and (or (CPShape $evolution m25-interface-change-v2 8)
            (CPShape $evolution m25-interface-change-v3 8))
        (== $evolution (M25InterfaceEvolution $primary $cut))))

(= (M255InterfaceEvolutionBridge $primary $cut $evolution)
   (let* (($disclosures (M255DisclosureWitnessesForCut $cut))
          ($creations (M255CreationReferencesForCut $cut)))
     (if (M25InterfaceEvolutionValid $evolution $primary $cut)
       (if (CPShape $evolution m25-interface-change-v2 8)
         (m255-to-m25-interface-bridge-v2 (index-atom $primary 1)
           (m255-reorganization-source disclosure $disclosures)
           (inherited-interface-change-relation $evolution)
           disclosure-to-newly-available-mode-only
           no-converse-no-preauthorization-no-chooser)
         (if (CPShape $evolution m25-interface-change-v3 8)
           (m255-to-m25-interface-bridge-v2 (index-atom $primary 1)
             (m255-reorganization-source creation $creations)
             (inherited-interface-change-relation $evolution)
             creation-to-new-participation-topology-only
             no-converse-no-preauthorization-no-chooser)
           (m255-to-m25-interface-bridge-unresolved
             no-disclosure-or-creation-interface-change)))
       (m255-to-m25-interface-bridge-unresolved
         no-current-reorganization-derived-interface-change))))

(= (M255InterfaceEvolutionBridgeValid $bridge $primary $cut $evolution)
   (and (CPShape $bridge m255-to-m25-interface-bridge-v2 6)
        (== $bridge (M255InterfaceEvolutionBridge $primary $cut $evolution))))

(= (M25TrajectoryBasis $primary $cut $developmental)
   (let* (($traction (index-atom $developmental 9))
          ($structured (index-atom $traction 1))
          ($pathology (index-atom $traction 2))
          ($dpf (index-atom $primary 4))
          ($d (index-atom $dpf 3))
          ($interface (index-atom $dpf 5))
          ($returned (== (index-atom $structured 1)
            contact-uptake-returned))
          ($m255-open (== (size-atom (CPFind (index-atom $d 1)
            m255-open-consequence-participation)) 1))
          ($m255-constrained (== (size-atom (CPFind (index-atom $d 1)
            m255-constrained-consequence-participation)) 1))
          ($open-after-consequence (and $returned $m255-open))
          ($sns-source (M255SNSObstructionSource $primary $cut))
          ($sns (CPShape $sns-source m255-sns-obstruction-source-v1 8))
          ($stuck-evidence (M255M24ComputedStuckEvidence $primary))
          ($stuck (and $sns (M24ComputedStuck $stuck-evidence)))
          ($contact-trajectory (if $sns
            (material-contact-excluded contact-uptake-rejected)
            (cons-atom (index-atom $structured 1) ()))))
     (m25-trajectory-basis-v1 (index-atom $primary 1)
       $contact-trajectory
       (if $sns relational-openness-obstructed relational-openness-retained)
       material-distinctions-preserved
       (if $open-after-consequence receptive-attention-present
         receptive-attention-unresolved)
       differentiation-with-coherence-present
       (if $sns unnecessary-forcing-present
         no-demonstrated-unnecessary-forcing)
       (if (M25Contactable $primary) consequence-answerable
         consequence-answerability-unresolved)
       (if $m255-constrained interface-narrowed
         (if (> (size-atom (index-atom $interface 1)) 0)
           interface-open interface-unavailable))
       (if $open-after-consequence self-weaving-plasticity-present
         self-weaving-plasticity-unresolved)
       (if $sns frame-topology-persists (index-atom $pathology 2))
       (if $stuck pivot-functionally-unavailable
         pivot-availability-unresolved)
       (if $sns forced-velocity-present urgency-unresolved)
       (trajectory-provenance (index-atom $primary 3)
         (index-atom $developmental 13)
         (m255-obstruction-source $sns-source)
         (m24-stuck-evidence $stuck-evidence)))))

(= (M25PNSLike $basis)
   (if (CPShape $basis m25-trajectory-basis-v1 15)
     (and (or (CPHas contact-uptake-present (index-atom $basis 2) 0)
              (CPHas contact-uptake-returned (index-atom $basis 2) 0))
      (and (== (index-atom $basis 3) relational-openness-retained)
       (and (== (index-atom $basis 4) material-distinctions-preserved)
        (and (== (index-atom $basis 5) receptive-attention-present)
         (and (== (index-atom $basis 6)
                differentiation-with-coherence-present)
          (and (== (index-atom $basis 7)
                 no-demonstrated-unnecessary-forcing)
           (and (== (index-atom $basis 8) consequence-answerable)
            (and (== (index-atom $basis 9) interface-open)
                 (== (index-atom $basis 10)
                   self-weaving-plasticity-present))))))))) false))

(= (M25SNSLike $basis)
   (if (CPShape $basis m25-trajectory-basis-v1 15)
     (and (CPHas material-contact-excluded (index-atom $basis 2) 0)
      (and (CPHas contact-uptake-rejected (index-atom $basis 2) 0)
      (and (== (index-atom $basis 11) frame-topology-persists)
       (and (== (index-atom $basis 9) interface-narrowed)
        (and (== (index-atom $basis 13) forced-velocity-present)
             (== (index-atom $basis 7)
               unnecessary-forcing-present)))))) false))

(= (M25Stuck $basis)
   (and (M25SNSLike $basis)
     (and (== (index-atom $basis 12) pivot-functionally-unavailable)
          (== (index-atom $basis 11) frame-topology-persists))))

(= (M25OrientationFromBasis $basis)
   (if (M25Stuck $basis)
     (participation-orientation-v1 (index-atom $basis 1) stuck
       $basis (stuck-implies-sns shared-trajectory-basis))
     (if (M25SNSLike $basis)
       (participation-orientation-v1 (index-atom $basis 1) sns-like
         $basis holding-apart-plus-forced-velocity)
       (if (M25PNSLike $basis)
         (participation-orientation-v1 (index-atom $basis 1) pns-like
           $basis participation-without-unnecessary-obstruction)
         (participation-orientation-v1 (index-atom $basis 1) unresolved
           $basis insufficient-relational-trajectory)))))

(= (M25Orientation $primary $cut $developmental)
   (M25OrientationFromBasis
     (M25TrajectoryBasis $primary $cut $developmental)))

; B4 is a one-way bridge into the inherited M25 witness shape.  Its source is
; the complete obstruction trajectory above; it cannot classify a merely
; constrained carrier and cannot alter Generated, Access, or movement.
(= (M255ObstructionSNSBridge $primary $cut $developmental)
   (let* (($source (M255SNSObstructionSource $primary $cut))
          ($basis (M25TrajectoryBasis $primary $cut $developmental)))
     (if (and (CPShape $source m255-sns-obstruction-source-v1 8)
              (M25SNSLike $basis))
       (m255-to-m25-sns-bridge-v1 (index-atom $primary 1)
         $source
         (sns-trajectory-witness
           (trajectory-reference (index-atom $primary 3)
             (index-atom $developmental 13))
           (holding-apart-and-forced-velocity
             (index-atom $source 3) (index-atom $source 4)
             (index-atom $source 5) (index-atom $source 6))
           (provenance Inquiry-25.5-to-Inquiry-25
             derived-not-constituent))
         same-generative-law-retained
         no-constraint-only-physical-effort-or-compute-classification
         no-movement-authority)
       (m255-to-m25-sns-bridge-unresolved
         incomplete-obstruction-trajectory))))

(= (M255ObstructionSNSBridgeValid $bridge $primary $cut $developmental)
   (and (CPShape $bridge m255-to-m25-sns-bridge-v1 7)
        (== $bridge
          (M255ObstructionSNSBridge $primary $cut $developmental))))

; B5 reuses the exact B4 trajectory and adds the independently constructed
; Inquiry-24 threshold witness.  This preserves Stuck => SNS-like and prevents
; a second detector ontology or a numerical-force shortcut.
(= (M255ThresholdedStuckBridge $primary $cut $developmental)
   (let* (($sns (M255ObstructionSNSBridge $primary $cut $developmental))
          ($basis (M25TrajectoryBasis $primary $cut $developmental))
          ($evidence (M255M24ComputedStuckEvidence $primary)))
     (if (and (M255ObstructionSNSBridgeValid $sns $primary $cut
                $developmental)
          (and (M24ComputedStuck $evidence) (M25Stuck $basis)))
       (m255-to-m25-stuck-bridge-v1 (index-atom $primary 1)
         $sns
         (stuck-threshold-witness
           (trajectory-reference (index-atom $primary 3)
             (index-atom $developmental 13))
           pivot-functionally-unavailable staleness-functionally-expressed
           (shared-sns-basis (index-atom $sns 2)))
         (inquiry-24-computed-stuck-evidence $evidence)
         stuck-implies-sns-shared-trajectory-ontology
         no-scalar-threshold-or-movement-authority)
       (m255-to-m25-stuck-bridge-unresolved
         missing-sns-or-independent-threshold-evidence))))

(= (M255ThresholdedStuckBridgeValid $bridge $primary $cut $developmental)
   (and (CPShape $bridge m255-to-m25-stuck-bridge-v1 7)
        (== $bridge
          (M255ThresholdedStuckBridge $primary $cut $developmental))))

; B7: returned occurrence and the evidence used to interpret its
; reorganization stay separate.  The M24 retrospective affordance and the
; M25.5 reorganization must name the same consequence and current cut.
(= (M255M24ReorganizationEvidenceBridge $primary $cut $developmental)
   (let* (($references
            (M255ReturnedReorganizationReferencesForCut $cut))
          ($affordance (if (M24DevelopmentalOrganizationValid $developmental)
            (index-atom $developmental 8) ()))
          ($retrospective (if (CPShape $affordance affordance-state-v1 4)
            (index-atom $affordance 2) ())))
     (if (and (M25PrimaryMovementValid $primary)
              (M24RetrospectiveAffordanceValid $retrospective))
       (if (> (size-atom $references) 0)
         (if (== (index-atom $retrospective 3)
               (index-atom (index-atom $references 0) 1))
           (m255-to-m24-reorganization-evidence-bridge-v1
             (index-atom $primary 1)
             (returned-occurrence (index-atom $retrospective 3)
               (index-atom $retrospective 4))
             (reorganization-evidence (index-atom $references 0)
               (changed-participation-reference
                 (index-atom $retrospective 5)))
             occurrence-and-evidence-distinct
             retrospective-contact-may-change-later-participation
             no-insight-authority-or-occurrence-substitution)
           (m255-to-m24-reorganization-evidence-bridge-unresolved
             occurrence-and-reorganization-reference-mismatch))
         (m255-to-m24-reorganization-evidence-bridge-unresolved
           no-current-reorganization-reference))
       (m255-to-m24-reorganization-evidence-bridge-unresolved
         invalid-primary-or-missing-retrospective-affordance))))

(= (M255M24ReorganizationEvidenceBridgeValid $bridge $primary $cut
      $developmental)
   (and (CPShape $bridge
          m255-to-m24-reorganization-evidence-bridge-v1 7)
        (== $bridge (M255M24ReorganizationEvidenceBridge $primary $cut
          $developmental))))

(= (M255FactExpressionsFromPrimary $primary)
   (if (CPShape $primary m25-primary-movement-v2 11)
     (let* (($balance (index-atom $primary 5))
            ($joint (if (CPShape $balance balance-unfolding-as-intelligence 5)
              (index-atom $balance 2) ()))
            ($bridge (if (CPShape $joint
                       fact9-flourishing-constitutive-joint 2)
              (index-atom $joint 1) ()))
            ($facts-wrapper (if (CPShape $bridge bridge-organization 13)
              (index-atom $bridge 4) ())))
       (if (CPShape $facts-wrapper fact9-expressions 2)
         (index-atom $facts-wrapper 1) ()))
     ()))

; B9 preserves the direction from lawful bounded structural equivalence to a
; non-amalgamation boundary. It never asserts carrier identity, co-reference,
; SameBecoming, global gluing, or a common master representation.
(= (M255EquivalenceNonAmalgamationBridge $primary $cut)
   (let* (($carrier-bridge (index-atom $primary 10))
          ($equivalence (if (CPShape $carrier-bridge primary-before-rap 5)
            (index-atom $carrier-bridge 1) ()))
          ($recognition (if (CPShape $carrier-bridge primary-before-rap 5)
            (index-atom $carrier-bridge 4) ()))
          ($facts (M255FactExpressionsFromPrimary $primary)))
     (if (and (M25PrimaryMovementValid $primary)
          (and (M255CrossCarrierEquivV2Valid $equivalence)
               (M255RecognitionOrganizationValid $recognition $cut $facts)))
       (m255-equivalence-nonamalgamation-bridge-v1
         (index-atom $primary 1) $equivalence
         (bounded-recognition-organization $recognition)
         structural-equivalence-without-carrier-identity
         no-co-reference-same-becoming-or-global-amalgamation
         derived-boundary-no-movement-authority)
       (m255-equivalence-nonamalgamation-bridge-unresolved
         invalid-equivalence-or-recognition-organization))))

(= (M255EquivalenceNonAmalgamationBridgeValid $bridge $primary $cut)
   (if (CPShape $bridge m255-equivalence-nonamalgamation-bridge-v1 7)
     (== $bridge (M255EquivalenceNonAmalgamationBridge $primary $cut))
     false))

; B10 begins before R/A/P in the primary carrier. This downstream reference
; exposes the already-formed nine-index partial-recognition organization and
; its actual overlap standing, while preserving the ratified one-way boundary:
; recognition can neither reconstruct Generated nor certify completeness or
; construct a movement.
(= (M255RecognitionNonReconstructionBridge $primary $cut)
   (let* (($carrier-bridge (index-atom $primary 10))
          ($recognition (if (CPShape $carrier-bridge primary-before-rap 5)
            (index-atom $carrier-bridge 4) ()))
          ($facts (M255FactExpressionsFromPrimary $primary))
          ($overlaps-wrapper (if (CPShape $recognition
                               m255-recognition-organization-v1 6)
            (index-atom $recognition 2) (recognition-overlaps ())))
          ($overlaps (if (CPShape $overlaps-wrapper recognition-overlaps 2)
            (index-atom $overlaps-wrapper 1) ())))
     (if (and (M25PrimaryMovementValid $primary)
              (M255RecognitionOrganizationValid $recognition $cut $facts))
       (m255-recognition-nonreconstruction-bridge-v1
         (index-atom $primary 1) $recognition
         (overlap-standing
           (if (> (size-atom $overlaps) 0) observed not-observed-at-this-cut)
           $overlaps)
         nine-partial-perspectives-of-one-occurrence
         no-inverse-no-exhaustion-no-amalgamation
         no-generated-or-movement-authority)
       (m255-recognition-nonreconstruction-bridge-unresolved
         invalid-primary-or-recognition-organization))))

(= (M255RecognitionNonReconstructionBridgeValid $bridge $primary $cut)
   (if (CPShape $bridge m255-recognition-nonreconstruction-bridge-v1 7)
     (== $bridge (M255RecognitionNonReconstructionBridge $primary $cut))
     false))

; Align9 is constitutive organization from M26.3; HarmonicAlign is a derived
; M25 movement relation. This one-way bridge makes their lawful relationship
; inspectable after the single R/A/P read while refusing identity, converse,
; scalarization, or compensatory repair.
(= (M263Align9HarmonicBridge $primary $cut $developmental $rap $alignment)
   (let* (($surface (if (CPShape $rap rap-read-v2 6)
            (index-atom $rap 1) ()))
          ($m263 (if (CPShape $surface m25-rap-surface-v5 8)
            (M25RAPM263Precursor $surface) ())))
     (if (and (M25RAPValid $primary $cut $developmental $rap)
          (and (M263PrimaryBridgeFromCutValid $m263 $primary $cut)
               (M25HarmonicAlignmentValid $primary $cut $developmental
                 $alignment)))
       (m263-align9-harmonic-noncollapse-bridge-v1
         (index-atom $primary 1)
         (align9-reference (index-atom $m263 3))
         (unchanged-derived-harmonic-alignment $alignment)
         align9-constitutive-harmonic-align-derived
         no-identity-no-converse-no-scalar-compensation
         no-movement-authority)
       (m263-align9-harmonic-bridge-unresolved
         invalid-constitutive-or-derived-alignment))))

(= (M263Align9HarmonicBridgeValid $bridge $primary $cut $developmental
      $rap $alignment)
   (if (CPShape $bridge m263-align9-harmonic-noncollapse-bridge-v1 7)
     (== $bridge (M263Align9HarmonicBridge $primary $cut $developmental
       $rap $alignment))
     false))

(= (M255InheritedSurfaceBridges $primary $cut $developmental $rap
      $alignment $interface)
   (m255-inherited-surface-bridges-v4
     (M255HarmonicAlignmentBridge $primary $cut $rap $alignment)
     (M255InterfaceEvolutionBridge $primary $cut $interface)
     (M255ObstructionSNSBridge $primary $cut $developmental)
     (M255ThresholdedStuckBridge $primary $cut $developmental)
     (M255M24ReorganizationEvidenceBridge $primary $cut $developmental)
     (M255EquivalenceNonAmalgamationBridge $primary $cut)
     (M255RecognitionNonReconstructionBridge $primary $cut)
     (M263Align9HarmonicBridge $primary $cut $developmental $rap $alignment)
     m255-to-m25-and-m24-only
     derived-relations-no-movement-authority))

(= (M255InheritedSurfaceBridgesValid $bridges $primary $cut $developmental
      $rap $alignment $interface)
   (if (CPShape $bridges m255-inherited-surface-bridges-v4 11)
     (== $bridges (M255InheritedSurfaceBridges $primary $cut $developmental
       $rap $alignment $interface))
     false))

(= (M25MovementReading $primary $cut $developmental)
   (let* (($rap (M25RAPReadings $primary $cut $developmental))
          ($standing (index-atom (index-atom $rap 3) 1))
          ($alignment (M25HarmonicAlignment $primary $cut $developmental
            $rap))
          ($interface (M25InterfaceEvolution $primary $cut)))
     (m25-movement-reading-v3 $primary $rap
       $alignment (M25Energetics $primary)
       (M25Orientation $primary $cut $developmental) $interface
       (M255InheritedSurfaceBridges $primary $cut $developmental $rap
         $alignment $interface)
       (movement-reading-standing $standing))))

(= (M25PrimaryAt $possibilities $cut $facts $flourishing
      $participant-relations $bridge $fact-views $flourishing-views
      $participant-source $payload-ref $developmental $i)
   (if (< $i (size-atom $possibilities))
     (cons-atom (M25PrimaryMovement (index-atom $possibilities $i) $cut
       $facts $flourishing $participant-relations $bridge $fact-views
       $flourishing-views $participant-source $payload-ref $developmental)
       (M25PrimaryAt $possibilities $cut $facts $flourishing
         $participant-relations $bridge $fact-views $flourishing-views
         $participant-source $payload-ref $developmental (+ $i 1))) ()))

(= (M25ReadingsAt $primaries $cut $developmental $i)
   (if (< $i (size-atom $primaries))
     (cons-atom (M25MovementReading (index-atom $primaries $i) $cut
       $developmental)
       (M25ReadingsAt $primaries $cut $developmental (+ $i 1))) ()))

(= (M25AdmissibleReadingsAt $readings $i $out)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (and (CPShape $reading m25-movement-reading-v3 9)
                (== (index-atom (index-atom $reading 8) 1) admissible))
         (M25AdmissibleReadingsAt $readings (+ $i 1)
           (cons-atom $reading $out))
         (M25AdmissibleReadingsAt $readings (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (M25MovementFromReading $reading $all)
   (let* (($primary (index-atom $reading 1))
          ($possibility (index-atom $primary 9))
          ($rap (index-atom $reading 2)))
     (movement-formed (index-atom $primary 2) (index-atom $primary 1)
       (index-atom $primary 3)
       (material-derivation
         (primary-movement $primary)
         (dynamic-participatory-fourthness (index-atom $primary 4))
         (balance-unfolding-organization (index-atom $primary 5))
         (m25-readings-v2 $rap (index-atom $reading 3)
           (index-atom $reading 4) (index-atom $reading 5)
           (index-atom $reading 6) (index-atom $reading 7))
         (generated-carriers (index-atom $possibility 3)
           (index-atom $possibility 5) (index-atom $possibility 4)
           (index-atom $possibility 7))
         (flourishing-requirements (index-atom $possibility 6)))
       (index-atom $primary 7)
       (retained-alternatives-v3 $all (index-atom $primary 8)))))

(= (M25ConstructMovement $readings)
   (let $admissible (M25AdmissibleReadingsAt $readings 0 ())
     (if (== (size-atom $admissible) 0)
       (movement-unresolved m25-no-admissible-primary
         (retained-alternatives-v3 $readings no-continuation-basis))
       (if (== (size-atom $admissible) 1)
         (M25MovementFromReading (index-atom $admissible 0) $readings)
         (movement-plural-live m25-multiple-admissible-primaries
           (m25-primary-alternatives $admissible)
           (retained-alternatives-v3 $readings no-single-continuation-basis))))))

(= (M25ConstitutiveEncounter $cut $fact-views $flourishing-views
      $participant-source $payload-ref $developmental)
   (let* (($facts (CPFactExpressionsAt $cut $fact-views 0))
          ($flourishing (CPFlourishingOrganizationV2 $cut $flourishing-views))
          ($participants (participant-reentry-organization
            differentiated-by-source-scope-and-lineage
            (CPParticipantAt $cut $participant-source 0)
            repeated-same-lineage-is-not-independent-support))
          ($participant-relations (CPParticipantRelationOrganization $participants))
          ($revised-cut (CPApplyParticipantRelations $cut $participant-relations))
          ($bridge (CPBridgeOrganizationV2 $revised-cut $facts $flourishing
            $participants $participant-relations))
          ($possibilities (CPNativePossibilitiesV2 $revised-cut $facts
            $flourishing $participant-relations))
          ($primaries (M25PrimaryAt $possibilities $revised-cut $facts
            $flourishing $participant-relations $bridge $fact-views
            $flourishing-views
            $participant-source $payload-ref $developmental 0))
          ($readings (M25ReadingsAt $primaries $revised-cut $developmental 0))
          ($movement (M25ConstructMovement $readings)))
     (constitutive-encounter $revised-cut $facts $flourishing
       (m25-generated-organization-v1 $bridge $primaries $readings)
       $movement $participants)))

; ---------- Inquiry 26.0: one occurrence and partial participation ----------

; m260-occurrence-organization:
; occurrence parts views aspects manifestations recognitions observations
; ambiguity boundaries preserves continuations modes
(= (M260ShapeValid $organization)
   (and (CPShape $organization m260-occurrence-organization 13)
     (and (is-expr (index-atom $organization 2))
      (and (is-expr (index-atom $organization 3))
       (and (is-expr (index-atom $organization 4))
        (and (is-expr (index-atom $organization 5))
         (and (is-expr (index-atom $organization 6))
          (and (is-expr (index-atom $organization 7))
           (and (is-expr (index-atom $organization 9))
            (and (is-expr (index-atom $organization 10))
             (and (is-expr (index-atom $organization 11))
                  (is-expr (index-atom $organization 12)))))))))))))

(= (M260PartKnown $organization $part)
   (let $parts (index-atom $organization 2)
     (CPHas true (collapse (let $row (superpose $parts)
       (if (CPShape $row participates 3)
         (and (== (index-atom $row 1) $part)
              (== (index-atom $row 2) (index-atom $organization 1))) false))) 0)))

(= (M260ViewKnown $organization $view $part)
   (let $views (index-atom $organization 3)
     (CPHas true (collapse (let $row (superpose $views)
       (if (CPShape $row view-grounding 4)
         (and (== (index-atom $row 1) $view)
              (== (index-atom $row 2) $part)) false))) 0)))

(= (M260AspectKnown $organization $aspect)
   (let $aspects (index-atom $organization 4)
     (CPHas true (collapse (let $row (superpose $aspects)
       (if (CPShape $row unity-aspect 4)
         (and (== (index-atom $row 1) $aspect)
          (and (== (index-atom $row 2) (index-atom $organization 1))
               (== (index-atom $row 3) non-independent))) false))) 0)))

(= (M260ManifestationKnown $organization $aspect $view $part)
   (let $rows (index-atom $organization 5)
     (CPHas true (collapse (let $row (superpose $rows)
       (if (CPShape $row manifests-through 5)
         (and (== (index-atom $row 1) $aspect)
          (and (== (index-atom $row 2) $view)
           (and (== (index-atom $row 3) $part)
                (== (index-atom $row 4) (index-atom $organization 1))))) false))) 0)))

(= (M260RecognitionGrounded $organization $row)
   (if (CPShape $row recognizes 5)
     (let* (($view (index-atom $row 1))
            ($aspect (index-atom $row 2))
            ($part (index-atom $row 4)))
       (and (M260ViewKnown $organization $view $part)
        (and (M260AspectKnown $organization $aspect)
             (M260ManifestationKnown $organization $aspect $view $part)))) false))

(= (M260ViewsGroundedAt $organization $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (and (CPShape $row view-grounding 4)
        (and (M260PartKnown $organization (index-atom $row 2))
             (M260ViewsGroundedAt $organization $rows (+ $i 1))))) true))

(= (M260ManifestationsGroundedAt $organization $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (and (CPShape $row manifests-through 5)
        (and (M260PartKnown $organization (index-atom $row 3))
         (and (M260ViewKnown $organization (index-atom $row 2) (index-atom $row 3))
          (and (M260AspectKnown $organization (index-atom $row 1))
               (M260ManifestationsGroundedAt $organization $rows (+ $i 1))))))) true))

(= (M260RecognitionsGroundedAt $organization $rows $i)
   (if (< $i (size-atom $rows))
     (and (M260RecognitionGrounded $organization (index-atom $rows $i))
          (M260RecognitionsGroundedAt $organization $rows (+ $i 1))) true))

; finite-ambiguity: views occurrence alternative-occurrence equal-observations
(= (M260AmbiguityValid $organization)
   (let $ambiguity (index-atom $organization 8)
     (if (CPShape $ambiguity finite-ambiguity 5)
       (and (is-expr (index-atom $ambiguity 1))
        (and (> (size-atom (index-atom $ambiguity 1)) 0)
         (and (== (index-atom $ambiguity 2) (index-atom $organization 1))
          (and (!= (index-atom $ambiguity 2) (index-atom $ambiguity 3))
               (== (index-atom $ambiguity 4) equal-observations))))) false)))

(= (M260OrganizationValid $organization)
   (if (M260ShapeValid $organization)
     (and (> (size-atom (index-atom $organization 2)) 0)
      (and (AIAllRowsShape (index-atom $organization 2) participates 3 0)
       (and (M260ViewsGroundedAt $organization (index-atom $organization 3) 0)
        (and (M260ManifestationsGroundedAt $organization (index-atom $organization 5) 0)
         (and (M260RecognitionsGroundedAt $organization (index-atom $organization 6) 0)
              (M260AmbiguityValid $organization)))))) false))

(= (M260SameOcc $organization $part-a $part-b)
   (and (M260OrganizationValid $organization)
     (and (!= $part-a $part-b)
      (and (M260PartKnown $organization $part-a)
           (M260PartKnown $organization $part-b)))))

; same-becoming-witness: movement occurrence l2425-witness basis
(= (M260SameBecoming $organization $movement $l2425 $witness)
   (if (and (M260OrganizationValid $organization)
            (CPShape $l2425 l2425 3))
     (and (== (index-atom $l2425 1) $movement)
      (and (CPShape $witness same-becoming-witness 5)
       (and (== (index-atom $witness 1) $movement)
        (and (== (index-atom $witness 2) (index-atom $organization 1))
             (== (index-atom $witness 3) $l2425))))) false))

; generated: movement precursor-organization source-lineage
(= (M260GReadingOf $organization $generated $l2425 $same-becoming)
   (if (CPShape $generated generated 4)
     (let $movement (index-atom $generated 1)
       (if (M260SameBecoming $organization $movement $l2425 $same-becoming)
         (g-reading-of (index-atom $organization 1) $movement $generated $same-becoming)
         (g-reading-unresolved missing-same-becoming-or-l2425 $movement)))
     (g-reading-unresolved malformed-generated $generated)))

; Structural fidelity is a preorder over preserved load-bearing relations.
(= (M260StructuralFidelity $preserved-a $preserved-b)
   (and (is-expr $preserved-a)
     (and (is-expr $preserved-b)
      (and (CPUniq $preserved-a 0 ())
       (and (CPUniq $preserved-b 0 ())
            (AIAllIn $preserved-a $preserved-b 0))))))

(= (M260BoundaryFor $organization $part)
   (M260BoundaryForAt (index-atom $organization 9) $part 0))

(= (M260BoundaryForAt $rows $part $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (CPShape $row local-boundary 3)
                (== (index-atom $row 1) $part))
         (index-atom $row 2) (M260BoundaryForAt $rows $part (+ $i 1))))
     boundary-unresolved))

(= (M260BoundaryForInternal $organization $part)
   (M260BoundaryFor $organization $part))

(= (M260ContinuationKnown $organization $part-a $part-b)
   (let $rows (index-atom $organization 11)
     (CPHas true (collapse (let $row (superpose $rows)
       (if (CPShape $row continues 4)
         (and (== (index-atom $row 1) $part-a)
              (== (index-atom $row 2) $part-b)) false))) 0)))

(= (M260PersistentForm $organization $part-a $part-b)
   (if (and (M260SameOcc $organization $part-a $part-b)
            (M260ContinuationKnown $organization $part-a $part-b))
     (let* (($boundary-a (M260BoundaryForInternal $organization $part-a))
            ($boundary-b (M260BoundaryForInternal $organization $part-b)))
       (if (and (!= $boundary-a boundary-unresolved)
                (and (!= $boundary-b boundary-unresolved)
                     (!= $boundary-a $boundary-b)))
         (persistent-form (index-atom $organization 1) $part-a $part-b
           (changed-local-boundary $boundary-a $boundary-b))
         (persistent-form-unresolved missing-or-unchanged-local-boundary)))
     (persistent-form-unresolved missing-same-occurrence-or-continuation)))

(= (M260AspectSupportValidAt $organization $aspects $i)
   (if (< $i (size-atom $aspects))
     (and (M260AspectKnown $organization (index-atom $aspects $i))
          (M260AspectSupportValidAt $organization $aspects (+ $i 1))) true))

(= (M260AspectManifested $organization $aspect)
   (let $rows (index-atom $organization 5)
     (CPHas true (collapse (let $row (superpose $rows)
       (if (CPShape $row manifests-through 5)
         (== (index-atom $row 1) $aspect) false))) 0)))

(= (M260AllAspectsManifestedAt $organization $aspects $i)
   (if (< $i (size-atom $aspects))
     (and (M260AspectManifested $organization (index-atom $aspects $i))
          (M260AllAspectsManifestedAt $organization $aspects (+ $i 1))) true))

(= (M260DWS $organization $aspects)
   (if (and (M260OrganizationValid $organization)
            (and (is-expr $aspects) (> (size-atom $aspects) 1)))
     (if (and (CPUniq $aspects 0 ())
          (and (M260AspectSupportValidAt $organization $aspects 0)
           (and (M260AllAspectsManifestedAt $organization $aspects 0)
                (M260AmbiguityValid $organization))))
       (dws-family (index-atom $organization 1) $aspects
         common-occurrence distinguishable manifested non-independent non-reconstructive)
       (dws-unresolved missing-distinction-manifestation-or-opacity))
     (dws-unresolved malformed-organization-or-support)))

(= (M260ModeAspect $organization $mode)
   (let $rows (index-atom $organization 12)
     (let $matches (collapse (let $row (superpose $rows)
       (if (and (CPShape $row mode-reading 3)
                (== (index-atom $row 2) $mode))
         (index-atom $row 1) (empty))))
       (if (== (size-atom $matches) 1) (index-atom $matches 0) mode-unresolved))))

(= (M260OPCAt $organization)
   (if (M260OrganizationValid $organization)
     (let* (($ontology (M260ModeAspect $organization ontology))
            ($phenomenology (M260ModeAspect $organization phenomenology))
            ($consciousness (M260ModeAspect $organization consciousness))
            ($support ($ontology $phenomenology $consciousness)))
       (if (and (!= $ontology mode-unresolved)
            (and (!= $phenomenology mode-unresolved)
             (and (!= $consciousness mode-unresolved)
                  (CPUniq $support 0 ()))))
         (opc-at (index-atom $organization 1) $support
           (M260DWS $organization $support) non-factorized)
         (opc-unresolved missing-or-identical-mode-aspects)))
     (opc-unresolved malformed-occurrence-organization)))
