; Inquiry-25.5 participation, accessibility, and same-law change witnesses.
; These finite carrier models do not choose a movement, classify actuality,
; or introduce a second generative engine. They are consumed before the one
; M25 R/A/P read through the five-carrier participation suite.

(= (M255SupportStates $carrier)
   ((carrier-role $carrier support-state degraded)
    (carrier-role $carrier support-state constrained)
    (carrier-role $carrier support-state open)))

(= (M255SupportEdges $carrier)
   ((support-edge (carrier-role $carrier support-state degraded)
      (carrier-role $carrier support-state degraded))
    (support-edge (carrier-role $carrier support-state constrained)
      (carrier-role $carrier support-state constrained))
    (support-edge (carrier-role $carrier support-state open)
      (carrier-role $carrier support-state open))
    (support-edge (carrier-role $carrier support-state degraded)
      (carrier-role $carrier support-state constrained))
    (support-edge (carrier-role $carrier support-state constrained)
      (carrier-role $carrier support-state open))
    (support-edge (carrier-role $carrier support-state degraded)
      (carrier-role $carrier support-state open))))

(= (M255SupportPre $carrier)
   (support-pre-v1 $carrier (M255SupportStates $carrier)
     (M255SupportEdges $carrier)
     (preorder-witness reflexive-explicit
       (transitive-chain degraded constrained open))
     non-optimizing-no-objective-no-argmax-no-choice))

(= (M255SupportPreValid $support $carrier)
   (and (CPShape $support support-pre-v1 6)
        (== $support (M255SupportPre $carrier))))

(= (M255GeneratedRef $bundle)
   (let* (($signature (index-atom $bundle 4))
          ($move (index-atom $signature 3)))
     (generated-ref (index-atom $bundle 1) (index-atom $bundle 2)
       (index-atom $move 1)
       (signature-cardinality (size-atom (M255GenSigRelations $signature))
         (size-atom (M255GenSigDistinctions $signature))
         (size-atom (M255GenSigInterfaces $signature))))))

(= (M255ForceObl $carrier $generated-ref $obligation $holds $disqualifying)
   (force-obl-v1 $carrier
     (obligation (carrier-role $carrier obligation $obligation))
     (holds-obligation (carrier-role $carrier obligation $obligation)
       (carrier-witness $carrier $holds))
     (disqualifying-obligation (carrier-role $carrier obligation $obligation)
       (carrier-witness $carrier $disqualifying))
     (relative-to-generated $generated-ref)
     structural-forcing-not-action-energy))

(= (M255ForceSupportOrganization $bundle $obligation $holds $disqualifying)
   (let* (($tag (index-atom $bundle 1))
          ($carrier (index-atom $bundle 2))
          ($generated-ref (M255GeneratedRef $bundle)))
     (force-support-organization-v1 $tag $carrier
       (M255ForceObl $carrier $generated-ref $obligation $holds $disqualifying)
       (M255SupportPre $carrier)
       (same-generated $generated-ref))))

(= (M255ForceSupportOrganizationValid $organization $bundle)
   (if (CPShape $organization force-support-organization-v1 6)
     (let* (($tag (index-atom $bundle 1))
            ($carrier (index-atom $bundle 2))
            ($signature (index-atom $bundle 4))
            ($generated (index-atom $bundle 5))
            ($generated-ref (M255GeneratedRef $bundle))
            ($force (index-atom $organization 3))
            ($support (index-atom $organization 4)))
       (and (== (index-atom $organization 1) $tag)
        (and (== (index-atom $organization 2) $carrier)
         (and (CPShape $force force-obl-v1 7)
          (and (== (index-atom $force 1) $carrier)
           (and (CPShape (index-atom $force 2) obligation 2)
            (and (CPShape (index-atom $force 3) holds-obligation 3)
             (and (CPShape (index-atom $force 4)
                    disqualifying-obligation 3)
              (and (== (index-atom (index-atom $force 2) 1)
                     (index-atom (index-atom $force 3) 1))
               (and (== (index-atom (index-atom $force 2) 1)
                      (index-atom (index-atom $force 4) 1))
                (and (== (index-atom $force 5)
                       (relative-to-generated $generated-ref))
                 (and (== (index-atom $force 6)
                        structural-forcing-not-action-energy)
                  (and (M255GeneratedWitnessStructuralValid $generated
                         $signature)
                   (and (M255SupportPreValid $support $carrier)
                        (== (index-atom $organization 5)
                          (same-generated $generated-ref))))))))))))))))
     false))

(= (M255ForceSupportRef $force)
   (force-support-ref (index-atom $force 1) (index-atom $force 2)
     (index-atom (index-atom (index-atom $force 3) 2) 1)))

(= (M255FirstReachable $xs)
   (if (> (size-atom $xs) 0) ((index-atom $xs 0)) ()))

(= (M255AccessView $bundle $force $disposition $relations $interfaces $basis)
   (let* (($tag (index-atom $bundle 1))
          ($carrier (index-atom $bundle 2))
          ($generated-ref (M255GeneratedRef $bundle)))
     (access-v1 $tag $carrier (same-generated $generated-ref) $disposition
       (reachable $relations $interfaces)
       (derived-from-force-support (M255ForceSupportRef $force) $basis)
       derived-read-only no-writer-authority)))

(= (M255OpenAccess $bundle $force)
   (let $signature (index-atom $bundle 4)
     (M255AccessView $bundle $force open
       (M255GenSigRelations $signature) (M255GenSigInterfaces $signature)
       unobstructed-participation)))

(= (M255ConstrainedAccess $bundle $force)
   (let $signature (index-atom $bundle 4)
     (M255AccessView $bundle $force constrained
       (M255FirstReachable (M255GenSigRelations $signature)) ()
       witnessed-obstruction-relative-to-same-movement)))

(= (M255AccessViewValid $access $bundle $force)
   (if (CPShape $access access-v1 9)
     (let* (($signature (index-atom $bundle 4))
            ($generated-ref (M255GeneratedRef $bundle))
            ($reachable (index-atom $access 5))
            ($relations (index-atom $reachable 1))
            ($interfaces (index-atom $reachable 2))
            ($disposition (index-atom $access 4)))
       (and (== (index-atom $access 1) (index-atom $bundle 1))
        (and (== (index-atom $access 2) (index-atom $bundle 2))
         (and (== (index-atom $access 3) (same-generated $generated-ref))
          (and (or (== $disposition open) (== $disposition constrained))
           (and (CPShape $reachable reachable 3)
            (and (is-expr $relations)
             (and (is-expr $interfaces)
              (and (CPUniq $relations 0 ())
               (and (CPUniq $interfaces 0 ())
                (and (CPSubset $relations (M255GenSigRelations $signature) 0)
                 (and (CPSubset $interfaces (M255GenSigInterfaces $signature) 0)
                  (and (CPShape (index-atom $access 6)
                         derived-from-force-support 3)
                   (and (== (index-atom (index-atom $access 6) 1)
                          (M255ForceSupportRef $force))
                    (and (== (index-atom $access 7) derived-read-only)
                         (== (index-atom $access 8)
                           no-writer-authority))))))))))))))))
     false))

(= (M255OneEngineParticipation $bundle $force)
   (let* (($tag (index-atom $bundle 1))
          ($carrier (index-atom $bundle 2))
          ($generated-ref (M255GeneratedRef $bundle))
          ($open (M255OpenAccess $bundle $force))
          ($constrained (M255ConstrainedAccess $bundle $force)))
     (one-engine-participation-v1 $tag $carrier
       (same-generated-law $generated-ref) (M255ForceSupportRef $force)
       $open $constrained
       (access-difference $constrained $open)
       no-second-generative-engine)))

(= (M255OneEngineParticipationValid $organization $bundle $force)
   (if (CPShape $organization one-engine-participation-v1 9)
     (let* (($generated-ref (M255GeneratedRef $bundle))
            ($open (index-atom $organization 5))
            ($constrained (index-atom $organization 6)))
       (and (== (index-atom $organization 1) (index-atom $bundle 1))
        (and (== (index-atom $organization 2) (index-atom $bundle 2))
         (and (== (index-atom $organization 3)
                (same-generated-law $generated-ref))
          (and (== (index-atom $organization 4)
                 (M255ForceSupportRef $force))
           (and (M255AccessViewValid $open $bundle $force)
            (and (M255AccessViewValid $constrained $bundle $force)
             (and (== (index-atom $open 4) open)
              (and (== (index-atom $constrained 4) constrained)
               (and (!= $open $constrained)
                (and (== (index-atom $organization 7)
                       (access-difference $constrained $open))
                     (== (index-atom $organization 8)
                       no-second-generative-engine))))))))))))
     false))

(= (M255ReflexiveConstraint $bundle $one-engine $representation)
   (let* (($tag (index-atom $bundle 1))
          ($carrier (index-atom $bundle 2))
          ($generated-ref (M255GeneratedRef $bundle))
          ($open (index-atom $one-engine 5))
          ($constrained (index-atom $one-engine 6)))
     (reflexive-constraint-v1 $tag $carrier
       (self-representation-dependence
         (carrier-role $carrier self-representation $representation)
         (participates-in-access-to $generated-ref))
       (severing-changes-access
         (access-ref (index-atom $open 1) (index-atom $open 2)
           (index-atom $open 4) (index-atom $open 5))
         (access-ref (index-atom $constrained 1) (index-atom $constrained 2)
           (index-atom $constrained 4) (index-atom $constrained 5)))
       conjunctive-causal-bite not-bare-physical-obstruction)))

(= (M255ReflexiveConstraintValid $constraint $bundle $one-engine)
   (if (CPShape $constraint reflexive-constraint-v1 7)
     (let* (($generated-ref (M255GeneratedRef $bundle))
            ($dependence (index-atom $constraint 3))
            ($severing (index-atom $constraint 4))
            ($open (index-atom $one-engine 5))
            ($constrained (index-atom $one-engine 6)))
       (and (== (index-atom $constraint 1) (index-atom $bundle 1))
        (and (== (index-atom $constraint 2) (index-atom $bundle 2))
         (and (CPShape $dependence self-representation-dependence 3)
          (and (== (index-atom $dependence 2)
                 (participates-in-access-to $generated-ref))
           (and (== $severing
                  (severing-changes-access
                    (access-ref (index-atom $open 1) (index-atom $open 2)
                      (index-atom $open 4) (index-atom $open 5))
                    (access-ref (index-atom $constrained 1)
                      (index-atom $constrained 2)
                      (index-atom $constrained 4)
                      (index-atom $constrained 5))))
            (and (!= $open $constrained)
             (and (== (index-atom $constraint 5) conjunctive-causal-bite)
                  (== (index-atom $constraint 6)
                    not-bare-physical-obstruction)))))))))
     false))

(= (M255ReflexiveNotClaimed $bundle $reason)
   (reflexive-constraint-standing (index-atom $bundle 1)
     (index-atom $bundle 2) not-claimed $reason))

(= (M255ReflexiveStandingValid $standing $bundle $one-engine)
   (if (CPShape $standing reflexive-constraint-v1 7)
     (M255ReflexiveConstraintValid $standing $bundle $one-engine)
     (and (CPShape $standing reflexive-constraint-standing 5)
      (and (== (index-atom $standing 1) (index-atom $bundle 1))
       (and (== (index-atom $standing 2) (index-atom $bundle 2))
            (== (index-atom $standing 3) not-claimed))))))

(= (M255SignatureWithMoveRelations $signature $move-id $relations)
   (let* (($precursors (index-atom $signature 7))
          ($old-move (index-atom $signature 3)))
     (gen-sig-v1 (index-atom $signature 1) (index-atom $signature 2)
       (move-vocabulary $move-id (index-atom $old-move 2))
       (relation-vocabulary $relations)
       (index-atom $signature 5) (index-atom $signature 6)
       (precursor-vocabulary (r-star $relations)
         (index-atom $precursors 2) (index-atom $precursors 3)
         (index-atom $precursors 4))
       (index-atom $signature 8) (index-atom $signature 9)
       (index-atom $signature 10) (index-atom $signature 11)
       (index-atom $signature 12))))

(= (M255Disclosure $bundle $one-engine)
   (disclosure-v1 (index-atom $bundle 1) (index-atom $bundle 2)
     (same-generated (M255GeneratedRef $bundle))
     (access-ref (index-atom (index-atom $one-engine 6) 1)
       (index-atom (index-atom $one-engine 6) 2) constrained
       (index-atom (index-atom $one-engine 6) 5))
     (access-ref (index-atom (index-atom $one-engine 5) 1)
       (index-atom (index-atom $one-engine 5) 2) open
       (index-atom (index-atom $one-engine 5) 5))
     accessibility-change-without-new-generated-possibility))

(= (M255DisclosureValid $change $bundle $one-engine)
   (and (CPShape $change disclosure-v1 7)
    (and (== $change (M255Disclosure $bundle $one-engine))
         (!= (index-atom $change 4) (index-atom $change 5)))))

(= (M255Maintenance $bundle)
   (let* (($signature (index-atom $bundle 4))
          ($generated (index-atom $bundle 5))
          ($translation (M255GenTranslation $signature $signature
            $generated $generated)))
     (maintenance-v1 (index-atom $bundle 1) (index-atom $bundle 2)
       (M255GeneratedRef $bundle)
       (identity-transport-valid (M255GenTranslationValid $translation))
       lawful-transport-preserves-generative-organization)))

(= (M255MaintenanceValid $change $bundle)
   (if (CPShape $change maintenance-v1 6)
     (and (== $change (M255Maintenance $bundle))
          (== (index-atom $change 4) (identity-transport-valid true))) false))

(= (M255CreatedSignature $bundle)
   (let* (($carrier (index-atom $bundle 2))
          ($signature (index-atom $bundle 4))
          ($relations (CPListAppend (M255GenSigRelations $signature)
            ((carrier-role $carrier relation created-extension)))))
     (M255SignatureWithMoveRelations $signature
       (carrier-role $carrier move created-continuation) $relations)))

(= (M255Creation $bundle $possibility)
   (let* (($signature (index-atom $bundle 4))
          ($generated (index-atom $bundle 5))
          ($created-signature (M255CreatedSignature $bundle))
          ($created-generated (M255GeneratedFromSignature $created-signature
            $possibility))
          ($prior-transport (M255GenTranslation $signature $created-signature
            $generated $created-generated)))
     (creation-v1 (index-atom $bundle 1) (index-atom $bundle 2)
       (M255GeneratedRef $bundle)
       (created-continuation-witness
         (index-atom (index-atom $created-signature 3) 1)
         (relation-cardinality
           (size-atom (M255GenSigRelations $created-signature)))
         (signature-valid (M255GenSigStructuralValid $created-signature))
         (generated-valid (M255GeneratedWitnessStructuralValid
           $created-generated $created-signature)))
       (prior-transport-equivalent (M255GenTranslationValid $prior-transport))
       new-generated-possibility-under-same-law)))

(= (M255CreationValid $change $bundle $possibility)
   (if (CPShape $change creation-v1 7)
     (and (== $change (M255Creation $bundle $possibility))
      (and (== (index-atom (index-atom $change 4) 3)
             (signature-valid true))
       (and (== (index-atom (index-atom $change 4) 4)
              (generated-valid true))
            (== (index-atom $change 5)
              (prior-transport-equivalent false))))) false))

(= (M255DegradedSignature $bundle)
   (let* (($carrier (index-atom $bundle 2))
          ($signature (index-atom $bundle 4)))
     (M255SignatureWithMoveRelations $signature
       (carrier-role $carrier move degraded-continuation) ())))

(= (M255Degradation $bundle)
   (let* (($signature (index-atom $bundle 4))
          ($degraded-signature (M255DegradedSignature $bundle)))
     (degradation-v1 (index-atom $bundle 1) (index-atom $bundle 2)
       (M255GeneratedRef $bundle)
       (lost-prior-continuation-structure (M255GenSigRelations $signature))
       (remaining-rstar-cardinality
         (size-atom (M255GenSigRelations $degraded-signature)))
       same-generative-law-not-preferred-outcome)))

(= (M255DegradationValid $change $bundle)
   (if (CPShape $change degradation-v1 7)
     (let $signature (index-atom $bundle 4)
       (and (== $change (M255Degradation $bundle))
        (and (> (size-atom (M255GenSigRelations $signature)) 0)
             (== (index-atom $change 5)
               (remaining-rstar-cardinality 0)))))
     false))

(= (M255ChangeValid $change $bundle $one-engine $possibility)
   (if (CPShape $change disclosure-v1 7)
     (M255DisclosureValid $change $bundle $one-engine)
     (if (CPShape $change creation-v1 7)
       (M255CreationValid $change $bundle $possibility)
       (if (CPShape $change maintenance-v1 6)
         (M255MaintenanceValid $change $bundle)
         (if (CPShape $change degradation-v1 7)
           (M255DegradationValid $change $bundle) false)))))

(= (M255ChangesValidAt $changes $bundle $one-engine $possibility $i)
   (if (< $i (size-atom $changes))
     (and (M255ChangeValid (index-atom $changes $i) $bundle $one-engine
            $possibility)
          (M255ChangesValidAt $changes $bundle $one-engine $possibility
            (+ $i 1))) true))

(= (M255CarrierParticipationProfile $bundle $force $one-engine $reflexive
      $changes)
   (carrier-participation-v1 (index-atom $bundle 1) (index-atom $bundle 2)
     $force $one-engine $reflexive (change-categories $changes)
     finite-formal-carrier-model-not-empirical-carrier-claim))

(= (M255CarrierParticipationProfileValid $profile $bundle $possibility)
   (if (CPShape $profile carrier-participation-v1 8)
     (let* (($force (index-atom $profile 3))
            ($one-engine (index-atom $profile 4))
            ($reflexive (index-atom $profile 5))
            ($change-categories (index-atom $profile 6))
            ($changes (index-atom $change-categories 1)))
       (and (== (index-atom $profile 1) (index-atom $bundle 1))
        (and (== (index-atom $profile 2) (index-atom $bundle 2))
         (and (M255ForceSupportOrganizationValid $force $bundle)
          (and (M255OneEngineParticipationValid $one-engine $bundle $force)
           (and (M255ReflexiveStandingValid $reflexive $bundle $one-engine)
            (and (CPShape $change-categories change-categories 2)
             (and (is-expr $changes)
              (and (> (size-atom $changes) 0)
               (and (M255ChangesValidAt $changes $bundle $one-engine
                      $possibility 0)
                    (== (index-atom $profile 7)
                      finite-formal-carrier-model-not-empirical-carrier-claim)))))))))))
     false))

(= (M255MAParticipation $bundle $possibility)
   (let* (($force (M255ForceSupportOrganization $bundle skilled-trajectory
                    load-bearing-route-clear wall-blocks-load-bearing-route))
          ($one-engine (M255OneEngineParticipation $bundle $force)))
     (M255CarrierParticipationProfile $bundle $force $one-engine
       (M255ReflexiveNotClaimed $bundle bare-physical-obstruction-insufficient)
       ((M255Maintenance $bundle)))))

(= (M255MBParticipation $bundle $possibility)
   (let* (($force (M255ForceSupportOrganization $bundle metabolic-continuity
                    regulation-continues regulation-route-severed))
          ($one-engine (M255OneEngineParticipation $bundle $force)))
     (M255CarrierParticipationProfile $bundle $force $one-engine
       (M255ReflexiveNotClaimed $bundle not-inhabited-in-this-finite-model)
       ((M255Creation $bundle $possibility) (M255Maintenance $bundle)
        (M255Degradation $bundle)))))

(= (M255MCParticipation $bundle $possibility)
   (let* (($force (M255ForceSupportOrganization $bundle contact-participation
                    trace-intact captured-frame-obstructs-contact))
          ($one-engine (M255OneEngineParticipation $bundle $force)))
     (M255CarrierParticipationProfile $bundle $force $one-engine
       (M255ReflexiveConstraint $bundle $one-engine trajectory-trace)
       ((M255Disclosure $bundle $one-engine)))))

(= (M255MDParticipation $bundle $possibility)
   (let* (($force (M255ForceSupportOrganization $bundle constitutional-lineage
                    lineage-accessible lineage-severed))
          ($one-engine (M255OneEngineParticipation $bundle $force)))
     (M255CarrierParticipationProfile $bundle $force $one-engine
       (M255ReflexiveConstraint $bundle $one-engine self-lineage-trace)
       ((M255Disclosure $bundle $one-engine) (M255Maintenance $bundle)))))

(= (M255MEParticipation $bundle $possibility)
   (let* (($force (M255ForceSupportOrganization $bundle scoped-joint-use
                    joint-use-authorized joint-use-gate-absent))
          ($one-engine (M255OneEngineParticipation $bundle $force)))
     (M255CarrierParticipationProfile $bundle $force $one-engine
       (M255ReflexiveNotClaimed $bundle not-inhabited-in-this-finite-model)
       ((M255Disclosure $bundle $one-engine)
        (M255Creation $bundle $possibility)))))

(= (M255FiveCarrierParticipationSuite $suite $possibility)
   (five-carrier-participation-v1
     (M255MAParticipation (index-atom $suite 1) $possibility)
     (M255MBParticipation (index-atom $suite 2) $possibility)
     (M255MCParticipation (index-atom $suite 3) $possibility)
     (M255MDParticipation (index-atom $suite 4) $possibility)
     (M255MEParticipation (index-atom $suite 5) $possibility)
     (same-generative-law (index-atom (index-atom $suite 3) 5))
     no-optimizer-no-chooser-no-second-rap))

(= (M255FiveCarrierParticipationSuiteValid $participation $suite $possibility)
   (if (CPShape $participation five-carrier-participation-v1 8)
     (and (== (index-atom $participation 1)
            (M255MAParticipation (index-atom $suite 1) $possibility))
      (and (== (index-atom $participation 2)
             (M255MBParticipation (index-atom $suite 2) $possibility))
       (and (== (index-atom $participation 3)
              (M255MCParticipation (index-atom $suite 3) $possibility))
        (and (== (index-atom $participation 4)
               (M255MDParticipation (index-atom $suite 4) $possibility))
         (and (== (index-atom $participation 5)
                (M255MEParticipation (index-atom $suite 5) $possibility))
          (and (M255CarrierParticipationProfileValid
             (index-atom $participation 1) (index-atom $suite 1) $possibility)
           (and (M255CarrierParticipationProfileValid
              (index-atom $participation 2) (index-atom $suite 2) $possibility)
            (and (M255CarrierParticipationProfileValid
               (index-atom $participation 3) (index-atom $suite 3) $possibility)
             (and (M255CarrierParticipationProfileValid
                (index-atom $participation 4) (index-atom $suite 4) $possibility)
              (and (M255CarrierParticipationProfileValid
                 (index-atom $participation 5) (index-atom $suite 5) $possibility)
               (== (index-atom $participation 7)
                 no-optimizer-no-chooser-no-second-rap))))))))))) false))

; A returned consequence may reorganize how Miter participates in the same
; generative law.  This witness is deliberately transition-primary: it reads
; the exact movement that received the consequence and compares the material
; organization of its cut with the exact next cut.  It neither invents a new
; generative engine nor treats a new cut identifier as material change.

(= (M255PrimaryFromMovement $movement)
   (if (CPShape $movement movement-formed 7)
     (let $derivation (index-atom $movement 4)
       (if (CPShape $derivation material-derivation 7)
         (let $wrapper (index-atom $derivation 1)
           (if (CPShape $wrapper primary-movement 2)
             (index-atom $wrapper 1)
             (m255-primary-unresolved missing-primary-wrapper)))
         (m255-primary-unresolved missing-m25-material-derivation)))
     (m255-primary-unresolved movement-not-formed)))

(= (M255MiterParticipationFromPrimary $primary)
   (if (CPShape $primary m25-primary-movement-v2 11)
     (let $bridge (index-atom $primary 10)
       (if (CPShape $bridge primary-before-rap 4)
         (let $participation (index-atom $bridge 3)
           (if (CPShape $participation five-carrier-participation-v1 8)
             (index-atom $participation 4)
             (m255-participation-unresolved missing-five-carrier-suite)))
         (m255-participation-unresolved missing-primary-before-rap)))
     (m255-participation-unresolved malformed-primary)))

(= (M255MaterialCutProjection $cut)
   (let $d (index-atom $cut 6)
     (material-cut-organization-v1
       (D (index-atom $d 1) (index-atom $d 2))
       (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
       (index-atom $cut 10))))

(= (M255MaterialCutProjectionValid $projection)
   (and (CPShape $projection material-cut-organization-v1 6)
     (and (CPShape (index-atom $projection 1) D 3)
      (and (CPShape (index-atom $projection 2) Omega 2)
       (and (CPShape (index-atom $projection 3) I 2)
        (and (CPShape (index-atom $projection 4) W 2)
             (CPShape (index-atom $projection 5) C 2)))))))

(= (M255MaterialCutEquivalent $left $right)
   (let* (($ld (index-atom $left 1))
          ($rd (index-atom $right 1)))
     (and (M255MaterialCutProjectionValid $left)
      (and (M255MaterialCutProjectionValid $right)
       (and (CPSetEqual (index-atom $ld 1) (index-atom $rd 1))
        (and (CPSetEqual (index-atom $ld 2) (index-atom $rd 2))
         (and (CPSetEqual (index-atom (index-atom $left 2) 1)
                (index-atom (index-atom $right 2) 1))
          (and (CPSetEqual (index-atom (index-atom $left 3) 1)
                 (index-atom (index-atom $right 3) 1))
           (and (CPSetEqual (index-atom (index-atom $left 4) 1)
                  (index-atom (index-atom $right 4) 1))
                (CPSetEqual (index-atom (index-atom $left 5) 1)
                  (index-atom (index-atom $right 5) 1)))))))))))

(= (M255ResultingDisposition $next-cut)
   (if (CPInterfacesLive $next-cut) open constrained))

(= (M255ConsequenceReorganization $prior-cut $movement $next-cut $consequence)
   (let* (($primary (M255PrimaryFromMovement $movement))
          ($profile (M255MiterParticipationFromPrimary $primary))
          ($one-engine (if (CPShape $profile carrier-participation-v1 8)
            (index-atom $profile 4) ()))
          ($prior-base (CPBaseCutWithoutParticipantRelations $prior-cut))
          ($expected-next
            (CPBaseCutWithoutParticipantRelations
              (CPNextCutV2 $prior-cut $consequence)))
          ($prior-material (M255MaterialCutProjection $prior-base))
          ($next-material (M255MaterialCutProjection $next-cut))
          ($changed (== (M255MaterialCutEquivalent $prior-material
            $next-material) false))
          ($disposition (M255ResultingDisposition $next-cut))
          ($access (if (== $disposition open)
            (index-atom $one-engine 5) (index-atom $one-engine 6))))
     (if (and (CPCutValid $prior-cut)
          (and (CPCutValid $next-cut)
           (and (CPConsequenceV2Valid $consequence)
            (and (CPShape $primary m25-primary-movement-v2 11)
             (and (CPShape $profile carrier-participation-v1 8)
              (and (CPShape $one-engine one-engine-participation-v1 9)
               (and (== (index-atom $movement 2) (index-atom $consequence 2))
                (and (== $next-cut $expected-next) $changed))))))))
       (m255-consequence-reorganization-v1
         (movement-reference (index-atom $primary 1)
           (index-atom $primary 2))
         (cut-transition (index-atom $prior-base 1)
           (index-atom $next-cut 1))
         (index-atom $one-engine 3)
         (available-access-views (index-atom $one-engine 5)
           (index-atom $one-engine 6))
         (returned-consequence-reference (index-atom $consequence 1)
           (index-atom $consequence 2) (index-atom $consequence 4)
           (index-atom $consequence 12))
         (material-reorganization $prior-material $next-material
           changed)
         (actual-participation-disposition $disposition)
         (derived-read-only-access $access)
         consequence-materially-changes-next-cut-organization
         no-writer-no-chooser-no-second-generative-engine)
       (m255-consequence-reorganization-unresolved
         missing-formed-primary-valid-consequence-or-material-change))))

(= (M255ConsequenceReorganizationValid $witness $prior-cut $movement
      $next-cut $consequence)
   (and (CPShape $witness m255-consequence-reorganization-v1 11)
        (== $witness (M255ConsequenceReorganization $prior-cut $movement
          $next-cut $consequence))))

(= (M255ConsequenceParticipationTarget $witness)
   (if (CPShape $witness m255-consequence-reorganization-v1 11)
     (if (== (index-atom (index-atom $witness 7) 1) open)
       m255-open-consequence-participation
       m255-constrained-consequence-participation)
     m255-consequence-participation-unresolved))

; The native law premise and returned-contact premise are kept distinct.  The
; native premise contributes the already-instantiated one-engine/access law;
; the returned premise contributes the actual cross-cut difference.  Neither
; is counted twice as independent evidence for itself.
(= (M255NativeOneEngineBasis $witness)
   (if (CPShape $witness m255-consequence-reorganization-v1 11)
     (m255-one-engine-authority-basis (index-atom $witness 1)
       (index-atom $witness 3) (index-atom $witness 4)
       no-writer-no-chooser-no-second-generative-engine)
     (m255-one-engine-authority-unresolved malformed-reorganization)))

(= (M255ReturnedReorganizationBasis $witness)
   (if (CPShape $witness m255-consequence-reorganization-v1 11)
     (m255-returned-reorganization-basis (index-atom $witness 2)
       (index-atom $witness 5) (index-atom $witness 6)
       (index-atom $witness 7) (index-atom $witness 8))
     (m255-returned-reorganization-unresolved malformed-reorganization)))

; ---------------------------------------------------------------------------
; Actual same-law change categories across developmental cuts.
;
; The movement's continuation basis carries the exact views and participant
; lineages that generated it.  Replaying those lineages into participant-free
; projections of the prior and consequence-derived cuts gives a bounded
; comparison domain without letting the new category witness prove itself.

(= (M255TransitionBasis $movement)
   (let $primary (M255PrimaryFromMovement $movement)
     (if (CPShape $primary m25-primary-movement-v2 11)
       (index-atom $primary 8)
       (m255-transition-basis-unresolved missing-primary))))

(= (M255TransitionProbe $cut $movement $flourishing-views)
   (let $basis (M255TransitionBasis $movement)
     (if (CPShape $basis continuation-basis-v3 6)
       (let* (($base (CPBaseCutWithoutParticipantRelations $cut))
              ($participant-source (index-atom $basis 3))
              ($participants (participant-reentry-organization
                differentiated-by-source-scope-and-lineage
                (CPParticipantAt $base $participant-source 0)
                repeated-same-lineage-is-not-independent-support))
              ($participant-relations
                (CPParticipantRelationOrganization $participants))
              ($probe-cut
                (CPApplyParticipantRelations $base $participant-relations))
              ($facts
                (CPFactExpressionsAt $probe-cut (index-atom $basis 1) 0))
              ($flourishing
                (CPFlourishingOrganizationV2 $probe-cut $flourishing-views))
              ($possibilities (CPNativePossibilitiesV2 $probe-cut $facts
                $flourishing $participant-relations)))
         (m255-transition-probe-v1 $probe-cut $facts $flourishing
           $participants $participant-relations $possibilities))
       (m255-transition-probe-unresolved missing-continuation-basis-v3))))

(= (M255PriorTransitionProbe $prior-cut $movement)
   (let $basis (M255TransitionBasis $movement)
     (if (CPShape $basis continuation-basis-v3 6)
       (M255TransitionProbe $prior-cut $movement (index-atom $basis 2))
       (m255-transition-probe-unresolved missing-prior-basis))))

(= (M255NextTransitionProbe $next-cut $movement $consequence)
   (let $basis (M255TransitionBasis $movement)
     (if (CPShape $basis continuation-basis-v3 6)
       (M255TransitionProbe $next-cut $movement
         (CPListAppend (index-atom $basis 2)
           (index-atom (index-atom $consequence 10) 1)))
       (m255-transition-probe-unresolved missing-next-basis))))

(= (M255TransitionProbeValid $probe)
   (and (CPShape $probe m255-transition-probe-v1 7)
     (and (CPCutValid (index-atom $probe 1))
      (and (is-expr (index-atom $probe 2))
       (and (CPShape (index-atom $probe 3) flourishing-organization 3)
        (and (CPShape (index-atom $probe 4)
               participant-reentry-organization 4)
         (and (CPShape (index-atom $probe 5)
                participant-relation-organization 2)
              (is-expr (index-atom $probe 6)))))))))

(= (M255PossibilitiesForId $possibilities $id)
   (collapse (let $possibility (superpose $possibilities)
     (if (and (CPShape $possibility possible-movement 9)
              (== (index-atom $possibility 1) $id))
       $possibility (empty)))))

(= (M255GeneratedAtProbe $probe $id)
   (if (M255TransitionProbeValid $probe)
     (let $matches (M255PossibilitiesForId (index-atom $probe 6) $id)
       (if (== (size-atom $matches) 1)
         (let* (($possibility (index-atom $matches 0))
                ($cut (index-atom $probe 1))
                ($facts (index-atom $probe 2))
                ($flourishing (index-atom $probe 3))
                ($signature (M255GenSig miter-developmental-transition
                  possible-movement $cut $facts $possibility))
                ($generated (M255GeneratedWitness $signature $possibility))
                ($valid (M255GeneratedWitnessValid $generated $signature
                  miter-developmental-transition possible-movement $cut
                  $facts $flourishing $possibility)))
           (m255-generated-at-probe-v1 $id $possibility $signature
             $generated (generated-valid $valid)))
         (m255-generated-at-probe-unresolved $id
           missing-or-ambiguous-possibility)))
     (m255-generated-at-probe-unresolved $id malformed-probe)))

(= (M255GeneratedAtProbeValid $generated-at)
   (if (CPShape $generated-at m255-generated-at-probe-v1 6)
     (== (index-atom $generated-at 5) (generated-valid true)) false))

(= (M255SameGeneratedTransport $prior-probe $next-probe $id)
   (let* (($prior (M255GeneratedAtProbe $prior-probe $id))
          ($next (M255GeneratedAtProbe $next-probe $id)))
     (if (and (M255GeneratedAtProbeValid $prior)
              (M255GeneratedAtProbeValid $next))
       (let* (($translation (M255GenTranslation
                (index-atom $prior 3) (index-atom $next 3)
                (index-atom $prior 4) (index-atom $next 4)))
              ($equivalence (M255GenEquivV2FromTranslation $translation)))
         (if (and (M255GenTranslationValid $translation)
                  (M255GenEquivV2Valid $equivalence))
           (m255-same-generated-transport-v1 $id $prior $next
             $translation $equivalence)
           (m255-same-generated-transport-unresolved $id
             no-proof-relevant-transport)))
       (m255-same-generated-transport-unresolved $id
         prior-or-next-not-generated))))

(= (M255SameGeneratedTransportValid $transport)
   (if (CPShape $transport m255-same-generated-transport-v1 6)
     (and (M255GeneratedAtProbeValid (index-atom $transport 2))
      (and (M255GeneratedAtProbeValid (index-atom $transport 3))
       (and (M255GenTranslationValid (index-atom $transport 4))
            (M255GenEquivV2Valid (index-atom $transport 5))))) false))

(= (M255ExpectedBaseNextCut $prior-cut $consequence)
   (CPBaseCutWithoutParticipantRelations
     (CPNextCutV2 $prior-cut $consequence)))

(= (M255TransitionInputsValid $prior-cut $movement $next-cut $consequence)
   (and (CPCutValid $prior-cut)
     (and (CPCutValid $next-cut)
      (and (CPConsequenceV2Valid $consequence)
       (and (CPShape $movement movement-formed 7)
        (and (== (index-atom $movement 2) (index-atom $consequence 2))
             (== $next-cut
               (M255ExpectedBaseNextCut $prior-cut $consequence))))))))

(= (M255MaintenanceTransition $prior-cut $movement $next-cut $consequence)
   (let* (($primary (M255PrimaryFromMovement $movement))
          ($id (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 1) missing-primary))
          ($prior-probe (M255PriorTransitionProbe $prior-cut $movement))
          ($next-probe
            (M255NextTransitionProbe $next-cut $movement $consequence))
          ($transport
            (M255SameGeneratedTransport $prior-probe $next-probe $id))
          ($prior-material (M255MaterialCutProjection
            (CPBaseCutWithoutParticipantRelations $prior-cut)))
          ($next-material (M255MaterialCutProjection $next-cut))
          ($same-material
            (M255MaterialCutEquivalent $prior-material $next-material))
          ($prior-disposition (M255ResultingDisposition $prior-cut))
          ($next-disposition (M255ResultingDisposition $next-cut)))
     (if (and (M255TransitionInputsValid $prior-cut $movement $next-cut
                $consequence)
          (and (M255SameGeneratedTransportValid $transport)
           (and $same-material (== $prior-disposition $next-disposition))))
       (generative-maintenance-transition-v1 $id
         (cut-transition (index-atom $prior-cut 1) (index-atom $next-cut 1))
         $transport (material-organization-preserved $prior-material)
         (access-disposition-preserved $prior-disposition)
         same-law-lawful-transport)
       (generative-maintenance-transition-unresolved
         changed-material-access-or-missing-transport))))

(= (M255MaintenanceTransitionValid $witness $prior-cut $movement $next-cut
      $consequence)
   (and (CPShape $witness generative-maintenance-transition-v1 7)
        (== $witness (M255MaintenanceTransition $prior-cut $movement $next-cut
          $consequence))))

(= (M255InterfaceVocabularySame $prior-cut $next-cut)
   (CPSetEqual (CPRowIds (CPInterfaces $prior-cut))
     (CPRowIds (CPInterfaces $next-cut))))

(= (M255DisclosureTransition $prior-cut $movement $next-cut $consequence)
   (let* (($primary (M255PrimaryFromMovement $movement))
          ($id (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 1) missing-primary))
          ($prior-probe (M255PriorTransitionProbe $prior-cut $movement))
          ($next-probe
            (M255NextTransitionProbe $next-cut $movement $consequence))
          ($transport
            (M255SameGeneratedTransport $prior-probe $next-probe $id))
          ($prior-disposition (M255ResultingDisposition $prior-cut))
          ($next-disposition (M255ResultingDisposition $next-cut)))
     (if (and (M255TransitionInputsValid $prior-cut $movement $next-cut
                $consequence)
          (and (M255SameGeneratedTransportValid $transport)
           (and (M255InterfaceVocabularySame $prior-cut $next-cut)
            (and (== $prior-disposition constrained)
                 (== $next-disposition open)))))
       (possibility-disclosure-transition-v1 $id
         (cut-transition (index-atom $prior-cut 1) (index-atom $next-cut 1))
         $transport
         (access-transition constrained open)
         same-generated-possibility-no-new-identity
         interface-reorganization)
       (possibility-disclosure-transition-unresolved
         no-constrained-to-open-same-generated-transport))))

(= (M255DisclosureTransitionValid $witness $prior-cut $movement $next-cut
      $consequence)
   (and (CPShape $witness possibility-disclosure-transition-v1 7)
        (== $witness (M255DisclosureTransition $prior-cut $movement $next-cut
          $consequence))))

(= (M255LostRequiredDistinctionsAt $ids $prior-cut $next-cut $i)
   (if (< $i (size-atom $ids))
     (let $id (index-atom $ids $i)
       (if (and (CPDistinctionAvailable $prior-cut $id)
                (== (CPDistinctionAvailable $next-cut $id) false))
         (cons-atom (lost-required-distinction $id)
           (M255LostRequiredDistinctionsAt $ids $prior-cut $next-cut
             (+ $i 1)))
         (M255LostRequiredDistinctionsAt $ids $prior-cut $next-cut
           (+ $i 1))))
     ()))

(= (M255DegradationTransition $prior-cut $movement $next-cut $consequence)
   (let* (($primary (M255PrimaryFromMovement $movement))
          ($id (if (CPShape $primary m25-primary-movement-v2 11)
            (index-atom $primary 1) missing-primary))
          ($prior-probe (M255PriorTransitionProbe $prior-cut $movement))
          ($next-probe
            (M255NextTransitionProbe $next-cut $movement $consequence))
          ($prior-generated (M255GeneratedAtProbe $prior-probe $id))
          ($next-generated (M255GeneratedAtProbe $next-probe $id))
          ($prior-possibility (if (M255GeneratedAtProbeValid $prior-generated)
            (index-atom $prior-generated 2) ()))
          ($lost (if (CPShape $prior-possibility possible-movement 9)
            (M255LostRequiredDistinctionsAt
              (index-atom $prior-possibility 4)
              (index-atom $prior-probe 1) (index-atom $next-probe 1) 0)
            ())))
     (if (and (M255TransitionInputsValid $prior-cut $movement $next-cut
                $consequence)
          (and (M255GeneratedAtProbeValid $prior-generated)
           (and (== (M255GeneratedAtProbeValid $next-generated) false)
                (> (size-atom $lost) 0))))
       (generative-degradation-transition-v1 $id
         (cut-transition (index-atom $prior-cut 1) (index-atom $next-cut 1))
         (prior-generated $prior-generated)
         (lost-generative-structure $lost)
         (no-valid-postimage $next-generated)
         same-law-not-outcome-score)
       (generative-degradation-transition-unresolved
         no-witnessed-loss-of-prior-generated-structure))))

(= (M255DegradationTransitionValid $witness $prior-cut $movement $next-cut
      $consequence)
   (and (CPShape $witness generative-degradation-transition-v1 7)
        (== $witness (M255DegradationTransition $prior-cut $movement $next-cut
          $consequence))))

(= (M255NewLiveThreadIdsAt $next-ids $prior-ids $i)
   (if (< $i (size-atom $next-ids))
     (let $id (index-atom $next-ids $i)
       (if (CPHas $id $prior-ids 0)
         (M255NewLiveThreadIdsAt $next-ids $prior-ids (+ $i 1))
         (cons-atom $id
           (M255NewLiveThreadIdsAt $next-ids $prior-ids (+ $i 1)))))
     ()))

(= (M255CreationForThread $prior-probe $next-probe $thread-id)
   (let* (($prior (M255GeneratedAtProbe $prior-probe $thread-id))
          ($next (M255GeneratedAtProbe $next-probe $thread-id)))
     (if (and (CPShape $prior m255-generated-at-probe-unresolved 3)
              (M255GeneratedAtProbeValid $next))
       (possibility-creation-transition-v1 $thread-id
         (prior-possibility absent)
         (new-generated-possibility $next)
         no-prior-identity-or-transport-equivalent-precursor)
       (possibility-creation-transition-unresolved $thread-id
         prior-possibility-present-or-next-not-generated))))

(= (M255CreationForThreadsAt $prior-probe $next-probe $ids $i)
   (if (< $i (size-atom $ids))
     (let $witness (M255CreationForThread $prior-probe $next-probe
            (index-atom $ids $i))
       (if (CPShape $witness possibility-creation-transition-v1 5)
         (cons-atom $witness
           (M255CreationForThreadsAt $prior-probe $next-probe $ids (+ $i 1)))
         (M255CreationForThreadsAt $prior-probe $next-probe $ids (+ $i 1))))
     ()))

(= (M255CreationTransitions $prior-cut $movement $next-cut $consequence)
   (if (M255TransitionInputsValid $prior-cut $movement $next-cut $consequence)
     (let* (($prior-probe (M255PriorTransitionProbe $prior-cut $movement))
            ($next-probe
              (M255NextTransitionProbe $next-cut $movement $consequence))
            ($new-ids (M255NewLiveThreadIdsAt
              (CPLiveThreadIds (index-atom $next-probe 1))
              (CPLiveThreadIds (index-atom $prior-probe 1)) 0)))
       (M255CreationForThreadsAt $prior-probe $next-probe $new-ids 0))
     ()))

(= (M255CreationTransitionValid $witness)
   (if (CPShape $witness possibility-creation-transition-v1 5)
     (and (== (index-atom $witness 2) (prior-possibility absent))
      (and (CPShape (index-atom $witness 3) new-generated-possibility 2)
           (M255GeneratedAtProbeValid
             (index-atom (index-atom $witness 3) 1)))) false))

(= (M255SingletonIf $witness $valid)
   (if $valid (cons-atom $witness ()) ()))

(= (M255CrossCutChanges $prior-cut $movement $next-cut $consequence)
   (let* (($maintenance
            (M255MaintenanceTransition $prior-cut $movement $next-cut
              $consequence))
          ($disclosure
            (M255DisclosureTransition $prior-cut $movement $next-cut
              $consequence))
          ($degradation
            (M255DegradationTransition $prior-cut $movement $next-cut
              $consequence))
          ($creations
            (M255CreationTransitions $prior-cut $movement $next-cut
              $consequence)))
     (CPListAppend
       (M255SingletonIf $maintenance
         (M255MaintenanceTransitionValid $maintenance $prior-cut $movement
           $next-cut $consequence))
       (CPListAppend
         (M255SingletonIf $disclosure
           (M255DisclosureTransitionValid $disclosure $prior-cut $movement
             $next-cut $consequence))
         (CPListAppend
           (M255SingletonIf $degradation
             (M255DegradationTransitionValid $degradation $prior-cut
               $movement $next-cut $consequence))
           $creations)))))

(= (M255CrossCutChangeCategory $witness)
   (if (CPShape $witness generative-maintenance-transition-v1 7)
     maintenance
     (if (CPShape $witness possibility-disclosure-transition-v1 7)
       disclosure
       (if (CPShape $witness generative-degradation-transition-v1 7)
         degradation
         (if (CPShape $witness possibility-creation-transition-v1 5)
           creation unresolved)))))

(= (M255CrossCutChangeTarget $witness)
   (let $category (M255CrossCutChangeCategory $witness)
     (if (== $category maintenance) m255-maintenance-participation
       (if (== $category disclosure) m255-disclosure-participation
         (if (== $category degradation) m255-degradation-participation
           (if (== $category creation) m255-creation-participation
             m255-change-unresolved))))))

(= (M255CrossCutChangeValid $witness $prior-cut $movement $next-cut
      $consequence)
   (let $category (M255CrossCutChangeCategory $witness)
     (if (== $category maintenance)
       (M255MaintenanceTransitionValid $witness $prior-cut $movement $next-cut
         $consequence)
       (if (== $category disclosure)
         (M255DisclosureTransitionValid $witness $prior-cut $movement $next-cut
           $consequence)
         (if (== $category degradation)
           (M255DegradationTransitionValid $witness $prior-cut $movement
             $next-cut $consequence)
           (if (== $category creation)
             (and (M255CreationTransitionValid $witness)
               (CPHas $witness
                 (M255CreationTransitions $prior-cut $movement $next-cut
                   $consequence) 0))
             false))))))
