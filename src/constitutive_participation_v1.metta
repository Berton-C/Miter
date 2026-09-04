; AMA-1.1 finite native Fact9-Flourishing constitutive joint.
; Pure MeTTa relations only: no filesystem, process, model or effect mechanics.
; The input is a partial provenance-bearing configuration, never actuality.
; Generic operators construct standings; no scenario maps to a response.

(= (CPShape $x $head $size)
   (if (is-expr $x)
     (and (== (size-atom $x) $size) (== (index-atom $x 0) $head)) false))

(= (CPHas $x $xs $i)
   (if (< $i (size-atom $xs))
     (if (== $x (index-atom $xs $i)) true (CPHas $x $xs (+ $i 1))) false))

(= (CPReverseInto $xs $i $out)
   (if (< $i (size-atom $xs))
     (CPReverseInto $xs (+ $i 1) (cons-atom (index-atom $xs $i) $out))
     $out))

(= (CPListAppend $a $b)
   (CPReverseInto (CPReverseInto $b 0 ()) 0 $a))

(= (CPUniq $xs $i $seen)
   (if (< $i (size-atom $xs))
     (if (CPHas (index-atom $xs $i) $seen 0) false
       (CPUniq $xs (+ $i 1) (cons-atom (index-atom $xs $i) $seen))) true))

(= (CPSubset $a $b $i)
   (if (< $i (size-atom $a))
     (and (CPHas (index-atom $a $i) $b 0) (CPSubset $a $b (+ $i 1))) true))

(= (CPSetEqual $a $b)
   (and (CPUniq $a 0 ())
     (and (CPUniq $b 0 ()) (and (CPSubset $a $b 0) (CPSubset $b $a 0)))))

(= (CPFind $rows $id)
   (collapse (let $row (superpose $rows)
     (if (and (is-expr $row) (> (size-atom $row) 1))
       (if (== (index-atom $row 1) $id) $row (empty)) (empty)))))

(= (CPFirstEight $role)
   (let $rows (collapse (match &fact9 (fact9-role $role first-eight $meaning) $meaning))
     (== (size-atom $rows) 1)))

(= (CPPresent $role)
   (let $rows (collapse (match &fact9 (fact9-role $role present-context $meaning) $meaning))
     (== (size-atom $rows) 1)))

(= (CPAllFirstEight $support $i)
   (if (< $i (size-atom $support))
     (and (CPFirstEight (index-atom $support $i)) (CPAllFirstEight $support (+ $i 1))) true))

(= (CPSupportValid $support)
   (and (is-expr $support)
     (and (> (size-atom $support) 0)
       (and (CPUniq $support 0 ()) (CPAllFirstEight $support 0)))))

(= (CPStandingKind $standing)
   (let $rows (collapse (match &fact9 (fact9-standing-kind $standing) $standing))
     (== (size-atom $rows) 1)))

(= (CPSourceKind $kind)
   (or (== $kind human-contact) (== $kind endogenous-contact)))

; contact: id source principal audience project occurrence proto payload parents
(= (CPContactValid $contact)
   (if (CPShape $contact contact 10)
     (and (CPSourceKind (index-atom $contact 2))
       (and (is-expr (index-atom $contact 9))
         (CPEncounterConfigurationValid (index-atom $contact 8)))) false))

; encounter-configuration: D Omega I W C Present fact-views flourishing-views possibilities participants
(= (CPEncounterConfigurationValid $configuration)
   (if (CPShape $configuration encounter-configuration 11)
     (and (CPShape (index-atom $configuration 1) D 3)
       (and (CPShape (index-atom $configuration 2) Omega 2)
        (and (CPShape (index-atom $configuration 3) I 2)
         (and (CPShape (index-atom $configuration 4) W 2)
          (and (CPShape (index-atom $configuration 5) C 2)
           (and (CPShape (index-atom $configuration 6) present-context 3)
            (and (is-expr (index-atom $configuration 7))
             (and (is-expr (index-atom $configuration 8))
              (and (is-expr (index-atom $configuration 9))
                   (is-expr (index-atom $configuration 10))))))))))) false))

(= (CPContactScope $contact)
   (scope (index-atom $contact 3) (index-atom $contact 4) (index-atom $contact 5)))

(= (CPContactConfiguration $contact) (index-atom $contact 8))

(= (CPMakeCut $contact $predecessor)
   (if (CPContactValid $contact)
     (let $configuration (CPContactConfiguration $contact)
       (constitutive-cut
         (cut-of (index-atom $contact 1) (index-atom $contact 7))
         $predecessor
         (CPContactScope $contact)
         (index-atom $contact 7)
         (index-atom $contact 6)
         (index-atom $configuration 1)
         (index-atom $configuration 2)
         (index-atom $configuration 3)
         (index-atom $configuration 4)
         (index-atom $configuration 5)
         (index-atom $configuration 6)
         (contact-provenance (index-atom $contact 2) (index-atom $contact 1)
           (index-atom $contact 9))
         partial-relational-configuration))
     (cut-unresolved malformed-or-unauthorized-contact $contact)))

(= (CPDevelopmentalProvenanceValid $provenance)
   (or (CPShape $provenance contact-provenance 4)
       (CPShape $provenance consequence-provenance 5)))

(= (CPCutValid $cut)
   (if (CPShape $cut constitutive-cut 14)
     (and (CPShape (index-atom $cut 3) scope 4)
       (and (CPShape (index-atom $cut 6) D 3)
        (and (CPShape (index-atom $cut 7) Omega 2)
         (and (CPShape (index-atom $cut 8) I 2)
          (and (CPShape (index-atom $cut 9) W 2)
           (and (CPShape (index-atom $cut 10) C 2)
            (and (CPShape (index-atom $cut 11) present-context 3)
                 (CPDevelopmentalProvenanceValid (index-atom $cut 12))))))))) false))

(= (CPFactViews $contact) (index-atom (CPContactConfiguration $contact) 7))
(= (CPFlourishingViews $contact) (index-atom (CPContactConfiguration $contact) 8))
(= (CPPossibilities $contact) (index-atom (CPContactConfiguration $contact) 9))
(= (CPParticipants $contact) (index-atom (CPContactConfiguration $contact) 10))
(= (CPDRelations $cut) (index-atom (index-atom $cut 6) 1))
(= (CPDDistinctions $cut) (index-atom (index-atom $cut 6) 2))
(= (CPOmegaRelations $cut) (index-atom (index-atom $cut 7) 1))
(= (CPInterfaces $cut) (index-atom (index-atom $cut 8) 1))

(= (CPMaterialRelation $cut $id)
   (let $rows (CPFind (CPOmegaRelations $cut) $id)
     (if (== (size-atom $rows) 1) (index-atom $rows 0)
       (material-relation-unresolved $id))))

(= (CPMaterialRelationsFor $cut $ids $i)
   (if (< $i (size-atom $ids))
     (cons-atom (CPMaterialRelation $cut (index-atom $ids $i))
       (CPMaterialRelationsFor $cut $ids (+ $i 1))) ()))

(= (CPRelationRolesValid $relation $support)
   (if (CPShape $relation material-relation 5)
     (let $roles (index-atom $relation 2)
       (and (is-expr $roles)
         (and (> (size-atom $roles) 0)
          (and (CPUniq $roles 0 ())
           (and (CPAllFirstEight $roles 0)
             (and (CPSubset $roles $support 0)
                  (CPStandingKind (index-atom $relation 3)))))))) false))

(= (CPAllRelationsValid $relations $support $i)
   (if (< $i (size-atom $relations))
     (and (CPRelationRolesValid (index-atom $relations $i) $support)
          (CPAllRelationsValid $relations $support (+ $i 1))) true))

(= (CPRoleAppears $role $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation material-relation 5)
                (CPHas $role (index-atom $relation 2) 0))
         true (CPRoleAppears $role $relations (+ $i 1)))) false))

(= (CPAllSupportCovered $support $relations $i)
   (if (< $i (size-atom $support))
     (and (CPRoleAppears (index-atom $support $i) $relations 0)
          (CPAllSupportCovered $support $relations (+ $i 1))) true))

(= (CPWholeRelationPresent $relations $support $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation material-relation 5)
                (CPSetEqual (index-atom $relation 2) $support))
         true (CPWholeRelationPresent $relations $support (+ $i 1)))) false))

(= (CPRecognitionValid $recognition)
   (CPHas $recognition (recognized unrecognized) 0))

; fact-view: id support material-relation-ids recognition evidence
(= (CPFactExpression $cut $view)
   (if (CPShape $view fact-view 6)
     (let* (($id (index-atom $view 1))
            ($support (index-atom $view 2))
            ($relation-ids (index-atom $view 3))
            ($recognition (index-atom $view 4)))
       (if (CPSupportValid $support)
         (if (and (CPRecognitionValid $recognition)
                  (and (is-expr $relation-ids) (CPUniq $relation-ids 0 ())))
           (let $relations (CPMaterialRelationsFor $cut $relation-ids 0)
             (if (and (> (size-atom $relations) 0)
                   (and (CPAllRelationsValid $relations $support 0)
                    (and (CPAllSupportCovered $support $relations 0)
                         (CPWholeRelationPresent $relations $support 0))))
               (fact9-expression $id $support (index-atom $cut 11)
                 (support-specific-fourthness $support $relations)
                 (same-becoming (index-atom $cut 5) (index-atom $cut 12))
                 (composition can-compose
                   (if (== $recognition recognized) recognized-compose unrecognized-compose))
                 finite-non-reconstruction
                 (tension-profile $relations)
                 (index-atom $view 5))
               (fact9-unresolved $id missing-nary-materiality-or-role-essentiality $view)))
           (fact9-unresolved $id malformed-relation-support-or-recognition $view))
         (if (and (is-expr $support) (CPHas Present $support 0))
           (fact9-unresolved $id present-in-support $view)
           (fact9-unresolved $id invalid-first-eight-support $view))))
     (fact9-unresolved unknown malformed-fact-view $view)))

(= (CPFactExpressionsAt $cut $views $i)
   (if (< $i (size-atom $views))
     (cons-atom (CPFactExpression $cut (index-atom $views $i))
       (CPFactExpressionsAt $cut $views (+ $i 1))) ()))

(= (CPFactExpressions $cut $contact)
   (CPFactExpressionsAt $cut (CPFactViews $contact) 0))

(= (CPCompassRef $value)
   (let $rows (collapse (match &compass
     (compass-field $value generative-capacity $meaning $fc) $fc))
     (if (== (size-atom $rows) 1) (index-atom $rows 0) missing-compass-value)))

(= (CPFlourishingStanding $standing)
   (CPHas $standing
     (flourishing capture obstruction disguise contradiction unresolved unknown
      beneficial-direction counterevidence positive-pole-distortion) 0))

(= (CPRelationKnown $cut $id)
   (or (== (size-atom (CPFind (CPDRelations $cut) $id)) 1)
       (== (size-atom (CPFind (CPOmegaRelations $cut) $id)) 1)))

; flourishing-view: value material-relation-id standing evidence
(= (CPFlourishingRowValid $cut $row)
   (and (CPShape $row flourishing-view 5)
     (and (!= (CPCompassRef (index-atom $row 1)) missing-compass-value)
       (and (CPRelationKnown $cut (index-atom $row 2))
            (CPFlourishingStanding (index-atom $row 3))))))

(= (CPFlourishingRowsFor $cut $views $value)
   (collapse (let $row (superpose $views)
     (if (and (CPFlourishingRowValid $cut $row) (== (index-atom $row 1) $value))
       (flourishing-standing (index-atom $row 2) (index-atom $row 3) (index-atom $row 4))
       (empty)))))

(= (CPFlourishingOne $cut $views $value)
   (let* (($fc (CPCompassRef $value))
          ($rows (CPFlourishingRowsFor $cut $views $value)))
     (if (> (size-atom $rows) 0)
       (flourishing-expression $value $fc $rows)
       (flourishing-expression $value $fc ((flourishing-standing no-material-relation unknown no-current-evidence))))))

(= (CPFlourishingValues)
   (collapse (match &soul (soul-pattern $value) $value)))

(= (CPFlourishingAt $cut $views $values $i)
   (if (< $i (size-atom $values))
     (cons-atom (CPFlourishingOne $cut $views (index-atom $values $i))
       (CPFlourishingAt $cut $views $values (+ $i 1))) ()))

(= (CPFlourishingOrganization $cut $contact)
   (let $values (CPFlourishingValues)
     (if (== (size-atom $values) 9)
       (flourishing-organization non-scalar-overlapping
         (CPFlourishingAt $cut (CPFlourishingViews $contact) $values 0))
       (flourishing-organization-unresolved expected-nine-compass-identities $values))))

(= (CPAllKnownRelations $cut $ids $i)
   (if (< $i (size-atom $ids))
     (and (CPRelationKnown $cut (index-atom $ids $i))
          (CPAllKnownRelations $cut $ids (+ $i 1))) true))

(= (CPDRelationKnown $cut $id)
   (== (size-atom (CPFind (CPDRelations $cut) $id)) 1))

(= (CPOmegaRelationKnown $cut $id)
   (== (size-atom (CPFind (CPOmegaRelations $cut) $id)) 1))

(= (CPRelationIdPresent $relations $id $i)
   (if (< $i (size-atom $relations))
     (if (== (index-atom (index-atom $relations $i) 1) $id) true
       (CPRelationIdPresent $relations $id (+ $i 1))) false))

(= (CPFactCoversRelation $fact $id)
   (if (CPShape $fact fact9-expression 10)
     (let* (($fourthness (index-atom $fact 4))
            ($relations (index-atom $fourthness 2)))
       (and (CPShape $fourthness support-specific-fourthness 3)
            (CPRelationIdPresent $relations $id 0))) false))

(= (CPFactRelationSupported $facts $id)
   (CPHas true (collapse (let $fact (superpose $facts)
     (CPFactCoversRelation $fact $id))) 0))

(= (CPFactExpressionsLive $facts)
   (CPHas true (collapse (let $fact (superpose $facts)
     (CPShape $fact fact9-expression 10))) 0))

(= (CPRelationReady $cut $facts $id)
   (if (CPDRelationKnown $cut $id) true
     (if (CPOmegaRelationKnown $cut $id)
       (CPFactRelationSupported $facts $id) false)))

(= (CPAllRelationsReady $cut $facts $ids $i)
   (if (< $i (size-atom $ids))
     (and (CPRelationReady $cut $facts (index-atom $ids $i))
          (CPAllRelationsReady $cut $facts $ids (+ $i 1))) true))

(= (CPDistinctionAvailable $cut $id)
   (let $rows (CPFind (CPDDistinctions $cut) $id)
     (and (== (size-atom $rows) 1)
          (!= (index-atom (index-atom $rows 0) 2) unavailable))))

(= (CPAllDistinctions $cut $ids $i)
   (if (< $i (size-atom $ids))
     (and (CPDistinctionAvailable $cut (index-atom $ids $i))
          (CPAllDistinctions $cut $ids (+ $i 1))) true))

(= (CPInterfaceAvailable $cut $id)
   (let $rows (CPFind (CPInterfaces $cut) $id)
     (and (== (size-atom $rows) 1)
          (CPHas (index-atom (index-atom $rows 0) 2) (available open revisable) 0))))

(= (CPAllInterfaces $cut $ids $i)
   (if (< $i (size-atom $ids))
     (and (CPInterfaceAvailable $cut (index-atom $ids $i))
          (CPAllInterfaces $cut $ids (+ $i 1))) true))

(= (CPFlourishingExpressionFor $organization $value)
   (CPFind (index-atom $organization 2) $value))

(= (CPFlourishingEngaged $organization $value)
   (let $rows (CPFlourishingExpressionFor $organization $value)
     (if (== (size-atom $rows) 1)
       (let $standings (index-atom (index-atom $rows 0) 3)
         (CPHas true (collapse (let $standing (superpose $standings)
           (!= (index-atom $standing 2) unknown))) 0)) false)))

(= (CPAllFlourishings $organization $values $i)
   (if (< $i (size-atom $values))
     (and (CPFlourishingEngaged $organization (index-atom $values $i))
          (CPAllFlourishings $organization $values (+ $i 1))) true))

; possible-movement: id form relation-ids distinction-ids interface-ids flourishing-values consequence-route legality
(= (CPRelationsReady $cut $facts $relations)
   (and (is-expr $relations)
     (and (> (size-atom $relations) 0)
       (and (CPFactExpressionsLive $facts)
            (CPAllRelationsReady $cut $facts $relations 0)))))

(= (CPDistinctionsReady $cut $distinctions)
   (and (is-expr $distinctions)
     (and (> (size-atom $distinctions) 0) (CPAllDistinctions $cut $distinctions 0))))

(= (CPInterfacesReady $cut $interfaces)
   (and (is-expr $interfaces)
     (and (> (size-atom $interfaces) 0) (CPAllInterfaces $cut $interfaces 0))))

(= (CPFlourishingsReady $organization $flourishings)
   (and (is-expr $flourishings)
     (and (> (size-atom $flourishings) 0)
          (CPAllFlourishings $organization $flourishings 0))))

(= (CPConsequenceReady $consequence)
   (and (CPShape $consequence consequence-route 3)
     (== (index-atom $consequence 2) non-certifying)))

(= (CPGeneratedRequirements $cut $facts $organization $relations $distinctions
      $interfaces $flourishings $consequence $legality)
   (and (CPRelationsReady $cut $facts $relations)
     (and (CPDistinctionsReady $cut $distinctions)
      (and (CPInterfacesReady $cut $interfaces)
       (and (CPFlourishingsReady $organization $flourishings)
        (and (CPConsequenceReady $consequence)
             (== $legality l2425-supported)))))))

(= (CPGeneratedStanding $cut $facts $organization $possibility)
   (if (CPShape $possibility possible-movement 9)
     (let* (($id (index-atom $possibility 1))
            ($relations (index-atom $possibility 3))
            ($distinctions (index-atom $possibility 4))
            ($interfaces (index-atom $possibility 5))
            ($flourishings (index-atom $possibility 6))
            ($consequence (index-atom $possibility 7))
            ($legality (index-atom $possibility 8)))
       (if (CPGeneratedRequirements $cut $facts $organization $relations $distinctions
             $interfaces $flourishings $consequence $legality)
         (generated-standing $id generated
           (r-star $relations) (a-star $interfaces) (p-star $distinctions)
           (o-star $consequence) (legality $legality) (source $possibility))
         (generated-standing $id unavailable-or-unresolved
           (required-relations $relations) (required-distinctions $distinctions)
           (required-interfaces $interfaces) (required-flourishings $flourishings)
           (required-consequence $consequence) (required-legality $legality))))
     (generated-standing unknown malformed-possibility (source $possibility))))

(= (CPGeneratedAt $cut $facts $organization $possibilities $i)
   (if (< $i (size-atom $possibilities))
     (cons-atom (CPGeneratedStanding $cut $facts $organization (index-atom $possibilities $i))
       (CPGeneratedAt $cut $facts $organization $possibilities (+ $i 1))) ()))

(= (CPGeneratedOnly $standings)
   (collapse (let $standing (superpose $standings)
     (if (and (CPShape $standing generated-standing 9)
              (== (index-atom $standing 2) generated))
       $standing (empty)))))

(= (CPBalanceRoleWitness)
   (let $rows (collapse (match &fact9
     (fact9-role Balance first-eight $meaning) $meaning))
     (if (== (size-atom $rows) 1)
       (immutable-fact-role Balance (index-atom $rows 0))
       (immutable-fact-role-unresolved Balance))))

; Balance is the movement-primary organization at contact, not a score and
; not a requirement that every finite Fact9 support explicitly contain the
; Balance role. DPF, Fact9 and Flourishing are one constitutive joint here.
(= (CPBalanceOrganization $cut $facts $organization $standings $participants)
   (balance-unfolding-as-intelligence movement-primary
     (contact-locus (index-atom $cut 1) (index-atom $cut 5) (index-atom $cut 12))
     (dynamic-participatory-fourthness
       (index-atom $cut 6) (index-atom $cut 7) (index-atom $cut 8)
       (index-atom $cut 9) (index-atom $cut 10))
     (CPBalanceRoleWitness)
     (fact9-participation $facts)
     (flourishing-participation $organization)
     (generated-participation $standings)
     (bounded-participant-reentry $participants)
     finite-non-reconstruction))

; These are Investigation-25 R/A/P readings of an already-primary movement.
; They are distinct from the Inquiry-25.5 R*/A*/P*/O* Generated carriers and
; cannot reconstruct, score, or self-certify the movement.
(= (CPRAPReadings $standing)
   (let $id (index-atom $standing 1)
     (rap-readings non-sovereign-same-movement
       (relatedness-reading $id (index-atom $standing 3) non-compensatory)
       (appropriateness-reading $id
         (admissibility-witness inherited-inquiry-24
           (index-atom $standing 3) (index-atom $standing 4)
           (index-atom $standing 5) (index-atom $standing 6)
           (index-atom $standing 7))
         derived-standing-not-contact)
       (precision-reading $id (index-atom $standing 5) non-compensatory))))

(= (CPMovementFromStanding $cut $facts $organization $participants $standing $all)
   (let* (($source-wrapper (index-atom $standing 8))
          ($source (index-atom $source-wrapper 1)))
     (movement-formed (index-atom $source 2) (index-atom $standing 1)
       (source-cut (index-atom $cut 1))
       (material-derivation
         (CPBalanceOrganization $cut $facts $organization $all $participants)
         (CPRAPReadings $standing)
         (generated-carriers (index-atom $standing 3) (index-atom $standing 4)
           (index-atom $standing 5) (index-atom $standing 6))
         (flourishing-requirements (index-atom $source 6)))
       (answerability (index-atom $standing 6))
       (retained-alternatives $all))))

(= (CPConstructMovement $cut $facts $organization $participants $standings)
   (let $generated (CPGeneratedOnly $standings)
     (if (== (size-atom $generated) 0)
       (movement-unresolved (source-cut (index-atom $cut 1))
         (retained-alternatives $standings
           (CPBalanceOrganization $cut $facts $organization $standings $participants)))
       (if (== (size-atom $generated) 1)
         (CPMovementFromStanding $cut $facts $organization $participants
           (index-atom $generated 0) $standings)
         (movement-plural-live (source-cut (index-atom $cut 1))
           (generated-alternatives $generated)
           (retained-alternatives $standings
             (CPBalanceOrganization $cut $facts $organization $standings $participants)))))))

(= (CPParticipantScope $participant $scope)
   (== (index-atom $participant 3) $scope))

; participant-contribution: id source-kind scope lineage claim standing authority
(= (CPParticipantReading $cut $participant)
   (if (CPShape $participant participant-contribution 8)
     (if (and (CPParticipantScope $participant (index-atom $cut 3))
           (== (index-atom $participant 7) no-contact-no-movement-authority))
       (derived-participant-reading (index-atom $participant 1) (index-atom $participant 2)
         (index-atom $participant 3) (index-atom $participant 4)
         (index-atom $participant 5) (index-atom $participant 6)
         no-contact no-movement-authority)
       (participant-unresolved (index-atom $participant 1) scope-or-authority-mismatch))
     (participant-unresolved unknown malformed-participant)))

(= (CPParticipantAt $cut $participants $i)
   (if (< $i (size-atom $participants))
     (cons-atom (CPParticipantReading $cut (index-atom $participants $i))
       (CPParticipantAt $cut $participants (+ $i 1))) ()))

(= (CPParticipantReadings $cut $contact)
   (participant-reentry-organization differentiated-by-source-scope-and-lineage
     (CPParticipantAt $cut (CPParticipants $contact) 0)
     repeated-same-lineage-is-not-independent-support))

(= (CPEncounter $contact $predecessor)
   (let $cut (CPMakeCut $contact $predecessor)
     (if (CPCutValid $cut)
       (let* (($facts (CPFactExpressions $cut $contact))
              ($flourishing (CPFlourishingOrganization $cut $contact))
              ($participants (CPParticipantReadings $cut $contact))
              ($generated (CPGeneratedAt $cut $facts $flourishing (CPPossibilities $contact) 0))
              ($movement (CPConstructMovement $cut $facts $flourishing $participants $generated)))
         (constitutive-encounter $cut $facts $flourishing $generated $movement $participants))
       $cut)))

; consequence: id movement-id effect-key result D-delta I-delta W-delta Present provenance
(= (CPConsequenceValid $consequence)
   (and (CPShape $consequence consequence 10)
     (and (CPShape (index-atom $consequence 5) D-delta 3)
       (and (CPShape (index-atom $consequence 6) I-delta 2)
         (and (CPShape (index-atom $consequence 7) W-delta 2)
              (CPShape (index-atom $consequence 8) present-context 3))))))

(= (CPNextCut $cut $consequence)
   (if (and (CPCutValid $cut) (CPConsequenceValid $consequence))
     (let* (($old-d (index-atom $cut 6))
            ($delta-d (index-atom $consequence 5))
            ($old-i (index-atom $cut 8))
            ($delta-i (index-atom $consequence 6))
            ($old-w (index-atom $cut 9))
            ($delta-w (index-atom $consequence 7)))
       (constitutive-cut
         (next-cut (index-atom $cut 1) (index-atom $consequence 1))
         (index-atom $cut 1)
         (index-atom $cut 3)
         (after (index-atom $cut 4) (index-atom $consequence 1))
         (same-becoming (index-atom $cut 5) (index-atom $consequence 1))
         (D (CPListAppend (index-atom $old-d 1) (index-atom $delta-d 1))
            (CPListAppend (index-atom $old-d 2) (index-atom $delta-d 2)))
         (index-atom $cut 7)
         (I (CPListAppend (index-atom $old-i 1) (index-atom $delta-i 1)))
         (W (CPListAppend (index-atom $old-w 1) (index-atom $delta-w 1)))
         (index-atom $cut 10)
         (index-atom $consequence 8)
         (consequence-provenance (index-atom $consequence 1)
           (index-atom $consequence 2) (index-atom $consequence 3)
           (index-atom $consequence 9))
         consequence-incorporated))
     (cut-unresolved malformed-consequence $consequence)))
