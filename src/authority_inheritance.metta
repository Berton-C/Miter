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

(= (M24DevelopmentalTransition $prior $basis $consequence $scope $next-cut)
   (let* (($lifecycle (M24DevelopmentalLifecycle $prior))
          ($probe (M24ProbeWitnessFromConsequence $lifecycle $basis
            $consequence $scope))
          ($evolved (M24DevelopmentalAfterProbe $prior $basis $consequence
            $scope $next-cut)))
     (if (M24DevelopmentalOrganizationValid $evolved)
       (m24-developmental-transition-v1 $prior $evolved $basis $consequence
         $scope $next-cut $probe)
       (m24-developmental-transition-unresolved $evolved))))

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
                    (index-atom $transition 6)))))))))) false))

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
       (if (and (> (size-atom (CPLiveThreadIds $cut)) 0)
                (== (CPInquiryNeededV2 $cut $facts $flourishing
                  $participant-relations) false))
         (movement-availability available live-undertaking)
         (movement-availability unavailable inquiry-or-thread-gap))
       (if (== $form inquiry)
         (if (CPInquiryNeededV2 $cut $facts $flourishing $participant-relations)
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

(= (M25PrimaryMovementValid $primary)
   (if (CPShape $primary m25-primary-movement-v2 11)
     (and (CPShape (index-atom $primary 3) source-cut 2)
      (and (M25DynamicParticipatoryFourthnessValid (index-atom $primary 4))
       (and (M25BalanceUnfoldingValid (index-atom $primary 5)
              (index-atom $primary 3) (index-atom $primary 4))
        (and (CPShape (index-atom $primary 6) movement-availability 3)
         (and (CPShape (index-atom $primary 7) answerability 2)
          (and (CPShape (index-atom $primary 8) continuation-basis-v3 6)
           (and (CPShape (index-atom $primary 9) possible-movement 9)
             (and (== (index-atom $primary 1)
                   (index-atom (index-atom $primary 9) 1))
             (and (== (index-atom $primary 2)
                    (index-atom (index-atom $primary 9) 2))
                  (M255PrimaryCarrierBridgeValid (index-atom $primary 10)
                    (index-atom $primary 9)))))))))))
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

(= (M25RAPSurface $primary $cut $developmental)
   (m25-rap-surface-v2
     (rap-read-event (index-atom $primary 1) (index-atom $cut 1))
     (movement-reference (index-atom $primary 1) (index-atom $primary 2))
     (source-cut (index-atom $cut 1)) (index-atom $cut 12)
     (developmental-reference (index-atom $developmental 13))
     (balance-unfolding-alignment (index-atom $primary 5))
     one-contact-movement-surface-three-simultaneous-perspectives))

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
          ($admissible (M25AppropriatenessValid $primary $surface
            $appropriateness)))
     (rap-read-v2 $surface
       (rap-perspectives $relatedness $appropriateness $precision)
       (rap-standing (if $admissible admissible unresolved))
       heterogeneous-non-reconstructive
       no-sequential-judge-or-chooser)))

(= (M25RAPValid $primary $rap)
   (if (CPShape $rap rap-read-v2 6)
     (let* (($id (index-atom $primary 1))
            ($surface (index-atom $rap 1))
            ($read-event (index-atom $surface 1))
            ($perspectives (index-atom $rap 2))
            ($relatedness (index-atom $perspectives 1))
            ($appropriateness (index-atom $perspectives 2))
            ($precision (index-atom $perspectives 3))
            ($surface-valid (and (M25PrimaryMovementValid $primary)
              (and (CPShape $surface m25-rap-surface-v2 8)
               (and (== (index-atom (index-atom $surface 2) 1) $id)
                (and (== (index-atom $surface 3) (index-atom $primary 3))
                 (and (CPShape (index-atom $surface 6)
                        balance-unfolding-alignment 2)
                  (and (== (index-atom (index-atom $surface 6) 1)
                         (index-atom $primary 5))
                       (== (index-atom $surface 7)
                         one-contact-movement-surface-three-simultaneous-perspectives))))))))
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

(= (M25HarmonicAlignment $primary $rap)
   (let $id (index-atom $primary 1)
     (if (and (M25RAPValid $primary $rap)
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

(= (M25HarmonicAlignmentValid $primary $alignment)
   (if (CPShape $alignment harmonic-alignment-witness 7)
     (and (== (index-atom $alignment 1) (index-atom $primary 1))
      (and (CPShape (index-atom $alignment 2) material-basis 5)
       (and (CPShape (index-atom (index-atom $alignment 2) 1)
              m25-rap-surface-v2 8)
        (and (== (index-atom
                   (index-atom (index-atom $alignment 2) 1) 6)
                 (balance-unfolding-alignment (index-atom $primary 5)))
         (and (== (index-atom (index-atom $alignment 3) 1)
              no-demonstrated-unnecessary-forcing)
          (and (== (index-atom (index-atom $alignment 4) 1) retained)
           (and (CPShape (index-atom $alignment 5) aligned-extensions 2)
                (CPShape (index-atom $alignment 6) provenance 3))))))))
     false))

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

(= (M25BoundedHarmonicContinuation $primary $rap $model $outcome)
   (let* (($alignment (M25HarmonicAlignment $primary $rap))
          ($aligned (M25HarmonicAlignmentValid $primary $alignment))
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

(= (M25TrajectoryBasis $primary $developmental)
   (let* (($traction (index-atom $developmental 9))
          ($structured (index-atom $traction 1))
          ($pathology (index-atom $traction 2))
          ($dpf (index-atom $primary 4))
          ($interface (index-atom $dpf 5)))
     (m25-trajectory-basis-v1 (index-atom $primary 1)
       (index-atom $structured 1)
       relational-openness-retained
       material-distinctions-preserved
       receptive-attention-unresolved
       differentiation-with-coherence-present
       no-demonstrated-unnecessary-forcing
       (if (M25Contactable $primary) consequence-answerable
         consequence-answerability-unresolved)
       (if (> (size-atom (index-atom $interface 1)) 0)
         interface-open interface-unavailable)
       self-weaving-plasticity-unresolved
       (index-atom $pathology 2)
       pivot-availability-unresolved urgency-unresolved
       (trajectory-provenance (index-atom $primary 3)
         (index-atom $developmental 13)))))

(= (M25PNSLike $basis)
   (if (CPShape $basis m25-trajectory-basis-v1 15)
     (and (CPHas (index-atom $basis 2)
            (contact-uptake-present contact-uptake-returned) 0)
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
     (and (CPHas (index-atom $basis 2)
            (material-contact-excluded contact-uptake-rejected) 0)
      (and (== (index-atom $basis 11) frame-topology-persists)
       (and (== (index-atom $basis 9) interface-narrowed)
        (and (== (index-atom $basis 13) forced-velocity-present)
             (CPHas (index-atom $basis 7)
               (unnecessary-forcing-present force-residue-present) 0))))) false))

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

(= (M25Orientation $primary $developmental)
   (M25OrientationFromBasis (M25TrajectoryBasis $primary $developmental)))

(= (M25MovementReading $primary $cut $developmental)
   (let* (($rap (M25RAPReadings $primary $cut $developmental))
          ($standing (index-atom (index-atom $rap 3) 1)))
     (m25-movement-reading-v2 $primary $rap
       (M25HarmonicAlignment $primary $rap) (M25Energetics $primary)
       (M25Orientation $primary $developmental) (M25InterfaceChange $primary)
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
       (if (and (CPShape $reading m25-movement-reading-v2 8)
                (== (index-atom (index-atom $reading 7) 1) admissible))
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
         (m25-readings $rap (index-atom $reading 3)
           (index-atom $reading 4) (index-atom $reading 5)
           (index-atom $reading 6))
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
