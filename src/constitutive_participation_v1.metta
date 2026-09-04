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

(= (CPFindAt $rows $id $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (is-expr $row) (> (size-atom $row) 1))
         (if (== (index-atom $row 1) $id) ($row)
           (CPFindAt $rows $id (+ $i 1)))
         (CPFindAt $rows $id (+ $i 1)))) ()))

; Lookup is total. Material absence remains an explicit empty result so that
; unresolved standing survives instead of making the whole reduction vanish.
(= (CPFind $rows $id) (CPFindAt $rows $id 0))

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

; V1 contact: id source principal audience project occurrence proto configuration parents
; V2 contact: id source principal audience project occurrence proto payload-ref configuration parents
(= (CPContactValid $contact)
   (if (CPShape $contact contact 10)
     (and (CPSourceKind (index-atom $contact 2))
       (and (is-expr (index-atom $contact 9))
         (CPEncounterConfigurationValid (index-atom $contact 8))))
     (if (CPShape $contact contact-v2 11)
       (and (CPSourceKind (index-atom $contact 2))
         (and (is-expr (index-atom $contact 10))
          (and (CPEncounterConfigurationValid (index-atom $contact 9))
               (== (size-atom (index-atom (index-atom $contact 9) 9)) 0)))) false)))

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

(= (CPContactConfiguration $contact)
   (if (CPShape $contact contact-v2 11)
     (index-atom $contact 9) (index-atom $contact 8)))

(= (CPContactParents $contact)
   (if (CPShape $contact contact-v2 11)
     (index-atom $contact 10) (index-atom $contact 9)))

(= (CPContactFrame $contact)
   (if (CPShape $contact contact-v2 11)
     (contact-frame (index-atom $contact 7)
       (payload-reference (index-atom $contact 8)))
     (index-atom $contact 7)))

(= (CPContactProvenance $contact)
   (if (CPShape $contact contact-v2 11)
     (contact-provenance-v2 (index-atom $contact 2) (index-atom $contact 1)
       (payload-reference (index-atom $contact 8)) (CPContactParents $contact))
     (contact-provenance (index-atom $contact 2) (index-atom $contact 1)
       (CPContactParents $contact))))

(= (CPMakeCut $contact $predecessor)
   (if (CPContactValid $contact)
     (let $configuration (CPContactConfiguration $contact)
       (constitutive-cut
         (cut-of (index-atom $contact 1) (index-atom $contact 7))
         $predecessor
         (CPContactScope $contact)
         (CPContactFrame $contact)
         (index-atom $contact 6)
         (index-atom $configuration 1)
         (index-atom $configuration 2)
         (index-atom $configuration 3)
         (index-atom $configuration 4)
         (index-atom $configuration 5)
         (index-atom $configuration 6)
         (CPContactProvenance $contact)
         partial-relational-configuration))
     (cut-unresolved malformed-or-unauthorized-contact $contact)))

(= (CPDevelopmentalProvenanceValid $provenance)
   (or (CPShape $provenance contact-provenance 4)
     (or (CPShape $provenance contact-provenance-v2 5)
         (CPShape $provenance consequence-provenance 5))))

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
       (if (CPShape $relation material-relation 5)
         (if (CPHas $role (index-atom $relation 2) 0)
           true (CPRoleAppears $role $relations (+ $i 1)))
         (CPRoleAppears $role $relations (+ $i 1)))) false))

(= (CPAllSupportCovered $support $relations $i)
   (if (< $i (size-atom $support))
     (and (CPRoleAppears (index-atom $support $i) $relations 0)
          (CPAllSupportCovered $support $relations (+ $i 1))) true))

(= (CPWholeRelationPresent $relations $support $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (CPShape $relation material-relation 5)
         (if (CPSetEqual (index-atom $relation 2) $support)
           true (CPWholeRelationPresent $relations $support (+ $i 1)))
         (CPWholeRelationPresent $relations $support (+ $i 1)))) false))

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
            ($relations (index-atom $fourthness 2))
            ($composition (index-atom $fact 6)))
       (and (CPShape $fourthness support-specific-fourthness 3)
         (and (CPShape $composition composition 3)
          (and (== (index-atom $composition 2) recognized-compose)
               (CPRelationIdPresent $relations $id 0))))) false))

(= (CPFactUnrecognized $fact)
   (if (CPShape $fact fact9-expression 10)
     (let $composition (index-atom $fact 6)
       (and (CPShape $composition composition 3)
            (== (index-atom $composition 2) unrecognized-compose))) false))

(= (CPFactsContainUnrecognized $facts)
   (CPHas true (collapse (let $fact (superpose $facts)
     (CPFactUnrecognized $fact))) 0))

(= (CPFactRelationSupported $facts $id)
   (CPHas true (collapse (let $fact (superpose $facts)
     (CPFactCoversRelation $fact $id))) 0))

(= (CPFactExpressionsLive $facts)
   (CPHas true (collapse (let $fact (superpose $facts)
     (if (CPShape $fact fact9-expression 10)
       (let $composition (index-atom $fact 6)
         (and (CPShape $composition composition 3)
              (== (index-atom $composition 2) recognized-compose))) false))) 0))

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

(= (CPFlourishingStandingsContain $standings $kinds $i)
   (if (< $i (size-atom $standings))
     (let $standing (index-atom $standings $i)
       (if (and (CPShape $standing flourishing-standing 4)
                (CPHas (index-atom $standing 2) $kinds 0))
         true (CPFlourishingStandingsContain $standings $kinds (+ $i 1)))) false))

; A possible movement's flourishing requirement means beneficial expression is
; materially supported. Capture or obstruction remains visible and may support
; a separately formed inquiry, but it cannot certify the beneficial requirement
; it contradicts and cannot be compensated by another favorable row.
(= (CPFlourishingEngaged $organization $value)
   (let $rows (CPFlourishingExpressionFor $organization $value)
     (if (== (size-atom $rows) 1)
       (let $standings (index-atom (index-atom $rows 0) 3)
         (and (CPFlourishingStandingsContain $standings
                (flourishing beneficial-direction) 0)
              (== (CPFlourishingStandingsContain $standings
                (capture obstruction disguise contradiction unresolved
                  counterevidence positive-pole-distortion) 0) false))) false)))

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
         (if (CPFactsContainUnrecognized $facts)
           (generated-standing $id unrecognized
             (required-relations $relations) (required-distinctions $distinctions)
             (required-interfaces $interfaces) (required-flourishings $flourishings)
             (required-consequence $consequence) (required-legality $legality))
           (generated-standing $id unavailable-or-unresolved
             (required-relations $relations) (required-distinctions $distinctions)
             (required-interfaces $interfaces) (required-flourishings $flourishings)
             (required-consequence $consequence) (required-legality $legality)))))
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
     (if (CPShape $participant participant-unresolved 3)
       $participant
       (participant-unresolved unknown malformed-participant))))

(= (CPParticipantAt $cut $participants $i)
   (if (< $i (size-atom $participants))
     (cons-atom (CPParticipantReading $cut (index-atom $participants $i))
       (CPParticipantAt $cut $participants (+ $i 1))) ()))

(= (CPParticipantReadings $cut $contact)
   (participant-reentry-organization differentiated-by-source-scope-and-lineage
     (CPParticipantAt $cut (CPParticipants $contact) 0)
     repeated-same-lineage-is-not-independent-support))

; ---------------------------------------------------------------------------
; RR-002 constitutive formation path.
;
; This path starts with no carrier-supplied possible movement. It composes
; relation-sensitive cognitive affordances from the live cut. The affordances
; are enumerated independently; their order never selects a result.

(= (CPRowsNonempty $rows)
   (and (is-expr $rows) (> (size-atom $rows) 0)))

(= (CPWRows $cut) (index-atom (index-atom $cut 9) 1))
(= (CPCSoulRows $cut) (index-atom (index-atom $cut 10) 1))

(= (CPIdsAt $rows $i $out)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (is-expr $row) (> (size-atom $row) 1))
         (CPIdsAt $rows (+ $i 1) (cons-atom (index-atom $row 1) $out))
         (CPIdsAt $rows (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (CPRowIds $rows) (CPIdsAt $rows 0 ()))

(= (CPCompassSemanticNames)
   (generative-capacity flourishing-pole capture-pole activation-signals
     felt-relational-expression disguise-mechanisms failure-modes gap-signature
     counterevidence positive-pole-distortion self-other-technical-expression
     time-and-consequences relations sources))

(= (CPCompassSemanticRows $value)
   (collapse (match &compass
     (compass-field $value $field $meaning $source)
     (compass-semantic-field $field $meaning $source))))

(= (CPAllCompassSemanticsPresent $rows $names $i)
   (if (< $i (size-atom $names))
     (and (== (size-atom (CPFind $rows (index-atom $names $i))) 1)
          (CPAllCompassSemanticsPresent $rows $names (+ $i 1))) true))

(= (CPCompassSemantics $value)
   (let* (($rows (CPCompassSemanticRows $value))
          ($names (CPCompassSemanticNames)))
     (if (and (== (size-atom $rows) 14)
              (CPAllCompassSemanticsPresent $rows $names 0))
       (compass-semantics $value complete-fourteen-fields $rows)
       (compass-semantics-unresolved $value expected-complete-fourteen-fields $rows))))

(= (CPFlourishingOneV2 $cut $views $value)
   (let* (($semantics (CPCompassSemantics $value))
          ($rows (CPFlourishingRowsFor $cut $views $value)))
     (if (> (size-atom $rows) 0)
       (flourishing-expression $value $semantics $rows)
       (flourishing-expression $value $semantics
         ((flourishing-standing no-material-relation unknown no-current-evidence))))))

(= (CPFlourishingAtV2 $cut $views $values $i)
   (if (< $i (size-atom $values))
     (cons-atom (CPFlourishingOneV2 $cut $views (index-atom $values $i))
       (CPFlourishingAtV2 $cut $views $values (+ $i 1))) ()))

(= (CPFlourishingOrganizationV2 $cut $views)
   (let $values (CPFlourishingValues)
     (if (== (size-atom $values) 9)
       (flourishing-organization non-scalar-interconnected-complete-semantics
         (CPFlourishingAtV2 $cut $views $values 0))
       (flourishing-organization-unresolved expected-nine-compass-identities $values))))

(= (CPFlourishingExpressionHas $expression $kinds)
   (if (CPShape $expression flourishing-expression 4)
     (CPFlourishingStandingsContain (index-atom $expression 3) $kinds 0) false))

(= (CPFlourishingOrganizationHasAt $organization $kinds $i)
   (let $expressions (index-atom $organization 2)
     (if (< $i (size-atom $expressions))
       (if (CPFlourishingExpressionHas (index-atom $expressions $i) $kinds)
         true (CPFlourishingOrganizationHasAt $organization $kinds (+ $i 1))) false)))

(= (CPFlourishingOrganizationHas $organization $kinds)
   (if (CPShape $organization flourishing-organization 3)
     (CPFlourishingOrganizationHasAt $organization $kinds 0) false))

(= (CPBeneficialFlourishingValuesAt $expressions $i $out)
   (if (< $i (size-atom $expressions))
     (let $expression (index-atom $expressions $i)
       (if (and (CPFlourishingExpressionHas $expression (flourishing beneficial-direction))
                (== (CPFlourishingExpressionHas $expression
                  (capture obstruction disguise contradiction unresolved
                    counterevidence positive-pole-distortion)) false))
         (CPBeneficialFlourishingValuesAt $expressions (+ $i 1)
           (cons-atom (index-atom $expression 1) $out))
         (CPBeneficialFlourishingValuesAt $expressions (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (CPBeneficialFlourishingValues $organization)
   (if (CPShape $organization flourishing-organization 3)
     (CPBeneficialFlourishingValuesAt (index-atom $organization 2) 0 ()) ()))

; Participant products remain readings. This section derives a bounded relation
; organization while preserving source, scope, lineage and conflict.
(= (CPParticipantRelationReading $reading)
   (if (CPShape $reading derived-participant-reading 9)
     (CPShape (index-atom $reading 5) participant-relation-claim 4) false))

(= (CPParticipantTargetsAt $readings $i $seen)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPParticipantRelationReading $reading)
         (let $target (index-atom (index-atom $reading 5) 1)
           (if (CPHas $target $seen 0)
             (CPParticipantTargetsAt $readings (+ $i 1) $seen)
             (CPParticipantTargetsAt $readings (+ $i 1) (cons-atom $target $seen))))
         (CPParticipantTargetsAt $readings (+ $i 1) $seen)))
     (CPReverseInto $seen 0 ())))

(= (CPParticipantClaimsForAt $readings $target $i $out)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPParticipantRelationReading $reading)
         (let $claim (index-atom $reading 5)
           (if (== (index-atom $claim 1) $target)
             (CPParticipantClaimsForAt $readings $target (+ $i 1)
               (cons-atom (participant-relation-evidence
                 (index-atom $reading 1) (index-atom $reading 2)
                 (index-atom $reading 4) (index-atom $claim 2)
                 (index-atom $reading 6) (index-atom $claim 3)) $out))
             (CPParticipantClaimsForAt $readings $target (+ $i 1) $out)))
         (CPParticipantClaimsForAt $readings $target (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (CPParticipantClaimsFor $readings $target)
   (CPParticipantClaimsForAt $readings $target 0 ()))

(= (CPParticipantClaimSupports $claim)
   (and (CPShape $claim participant-relation-evidence 7)
     (and (== (index-atom $claim 4) support)
          (== (index-atom $claim 5) supported))))

(= (CPParticipantClaimContradicts $claim)
   (and (CPShape $claim participant-relation-evidence 7)
     (or (== (index-atom $claim 4) contradiction)
         (== (index-atom $claim 5) contradicted))))

(= (CPParticipantClaimsHaveAt $claims $predicate $i)
   (if (< $i (size-atom $claims))
     (if ($predicate (index-atom $claims $i)) true
       (CPParticipantClaimsHaveAt $claims $predicate (+ $i 1))) false))

(= (CPParticipantSupportKeysAt $claims $i $out)
   (if (< $i (size-atom $claims))
     (let $claim (index-atom $claims $i)
       (if (CPParticipantClaimSupports $claim)
         (let $key (participant-lineage (index-atom $claim 2) (index-atom $claim 3))
           (if (CPHas $key $out 0)
             (CPParticipantSupportKeysAt $claims (+ $i 1) $out)
             (CPParticipantSupportKeysAt $claims (+ $i 1) (cons-atom $key $out))))
         (CPParticipantSupportKeysAt $claims (+ $i 1) $out)))
     $out))

(= (CPParticipantRelationOne $readings $target)
   (let* (($claims (CPParticipantClaimsFor $readings $target))
          ($supports (CPParticipantClaimsHaveAt $claims CPParticipantClaimSupports 0))
          ($contradicts (CPParticipantClaimsHaveAt $claims CPParticipantClaimContradicts 0))
          ($keys (CPParticipantSupportKeysAt $claims 0 ())))
     (if (and $supports $contradicts)
       (participant-relation-conflict $target support-and-contradiction-retained $claims)
       (if $supports
         (if (> (size-atom $keys) 1)
           (participant-supported-relation $target independent-lineages $claims)
           (participant-proposed-relation $target support
             same-lineage-not-independent $claims))
         (participant-proposed-relation $target unresolved $claims)))))

(= (CPParticipantRelationsAt $readings $targets $i)
   (if (< $i (size-atom $targets))
     (cons-atom (CPParticipantRelationOne $readings (index-atom $targets $i))
       (CPParticipantRelationsAt $readings $targets (+ $i 1))) ()))

(= (CPParticipantUnresolvedAt $readings $i)
   (if (< $i (size-atom $readings))
     (let $reading (index-atom $readings $i)
       (if (CPShape $reading participant-unresolved 3)
         (cons-atom (participant-reentry-unresolved
           (index-atom $reading 1) (index-atom $reading 2))
           (CPParticipantUnresolvedAt $readings (+ $i 1)))
         (CPParticipantUnresolvedAt $readings (+ $i 1)))) ()))

(= (CPParticipantRelationOrganization $participants)
   (let* (($readings (index-atom $participants 2))
          ($targets (CPParticipantTargetsAt $readings 0 ())))
     (participant-relation-organization
       (CPListAppend
         (CPParticipantRelationsAt $readings $targets 0)
         (CPParticipantUnresolvedAt $readings 0)))))

(= (CPParticipantRelationsHaveAt $organization $head $i)
   (let $relations (index-atom $organization 1)
     (if (< $i (size-atom $relations))
       (let $relation (index-atom $relations $i)
         (if (and (is-expr $relation) (== (index-atom $relation 0) $head))
           true (CPParticipantRelationsHaveAt $organization $head (+ $i 1)))) false)))

(= (CPParticipantRelationsHave $organization $head)
   (CPParticipantRelationsHaveAt $organization $head 0))

(= (CPParticipantDRelationsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (CPShape $relation participant-supported-relation 4)
         (cons-atom (relation (index-atom $relation 1) participant-derived support
           (participant-evidence $relation))
           (CPParticipantDRelationsAt $relations (+ $i 1)))
         (if (CPShape $relation participant-relation-conflict 4)
           (cons-atom (relation (index-atom $relation 1) participant-derived contradiction
             (participant-evidence $relation))
             (CPParticipantDRelationsAt $relations (+ $i 1)))
           (CPParticipantDRelationsAt $relations (+ $i 1))))) ()))

(= (CPParticipantDRelations $organization)
   (CPParticipantDRelationsAt (index-atom $organization 1) 0))

(= (CPMergeNewRelationsAt $rows $derived $i)
   (if (< $i (size-atom $derived))
     (let $relation (index-atom $derived $i)
       (if (and (CPShape $relation relation 5)
                (== (size-atom (CPFind $rows (index-atom $relation 1))) 0))
         (CPMergeNewRelationsAt (CPListAppend $rows ($relation)) $derived (+ $i 1))
         (CPMergeNewRelationsAt $rows $derived (+ $i 1))))
     $rows))

(= (CPApplyParticipantRelations $cut $organization)
   (let* (($old-d (index-atom $cut 6))
          ($derived (CPParticipantDRelations $organization)))
     (constitutive-cut
       (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
       (index-atom $cut 4) (index-atom $cut 5)
       (D (CPMergeNewRelationsAt (index-atom $old-d 1) $derived 0)
          (index-atom $old-d 2))
       (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
       (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
       (index-atom $cut 13))))

(= (CPNonParticipantDRelationsAt $rows $i)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (and (CPShape $row relation 5)
                (== (index-atom $row 2) participant-derived))
         (CPNonParticipantDRelationsAt $rows (+ $i 1))
         (cons-atom $row (CPNonParticipantDRelationsAt $rows (+ $i 1))))) ()))

; Restoration reconstructs from the pre-participant material cut and lets the
; retained participant basis re-form its bounded relations. This prevents both
; duplication and mechanically rehashed, semantically stale movements.
(= (CPBaseCutWithoutParticipantRelations $cut)
   (let $old-d (index-atom $cut 6)
     (constitutive-cut
       (index-atom $cut 1) (index-atom $cut 2) (index-atom $cut 3)
       (index-atom $cut 4) (index-atom $cut 5)
       (D (CPNonParticipantDRelationsAt (index-atom $old-d 1) 0)
          (index-atom $old-d 2))
       (index-atom $cut 7) (index-atom $cut 8) (index-atom $cut 9)
       (index-atom $cut 10) (index-atom $cut 11) (index-atom $cut 12)
       (index-atom $cut 13))))

(= (CPConstitutiveStandingV2 $cut $facts)
   (constitutive-standing
     (if (CPDLive $cut) D-live D-unresolved)
     (if (CPFactExpressionsUnresolved $facts) fact9-unresolved fact9-recognized)
     (if (CPInterfacesLive $cut) interface-available interface-unavailable)
     (if (> (size-atom (CPLiveThreadIds $cut)) 0) weave-available weave-unresolved)
     (if (CPSoulLive $cut) soul-relation-available soul-relation-unavailable)))

(= (CPBridgeOrganizationV2 $cut $facts $flourishing $participants $participant-relations)
   (bridge-organization many-way-situated-proof-relevant
     (source-cut (index-atom $cut 1))
     (contacted-organization (index-atom $cut 6) (index-atom $cut 7)
       (index-atom $cut 8) (index-atom $cut 9) (index-atom $cut 10))
     (fact9-expressions $facts)
     (flourishing-expressions $flourishing)
     (bounded-participant-relations $participants $participant-relations)
     (scope-and-present (index-atom $cut 3) (index-atom $cut 11))
     (CPConstitutiveStandingV2 $cut $facts)
     (bridge-uncertainty
       (facts-live (CPFactExpressionsLive $facts))
       (flourishing-tension (CPFlourishingOrganizationHas $flourishing
         (capture obstruction disguise contradiction unresolved counterevidence
           positive-pole-distortion)))
       (participant-tension
         (or (CPParticipantRelationsHave $participant-relations participant-proposed-relation)
             (CPParticipantRelationsHave $participant-relations participant-relation-conflict))))
     (alternatives plural-lawful-continuations-remain-possible)
     (defeaters relation-severance distinction-loss interface-loss
       capture disguise contradiction unresolved-standing)
     (predicted-difference continuation-accessibility-and-next-cut)))

(= (CPFactExpressionsUnresolvedAt $facts $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (CPShape $fact fact9-unresolved 4) true
         (CPFactExpressionsUnresolvedAt $facts (+ $i 1)))) false))

(= (CPFactExpressionsUnresolved $facts)
   (CPFactExpressionsUnresolvedAt $facts 0))

(= (CPDLive $cut) (CPRowsNonempty (CPDRelations $cut)))
(= (CPSoulLive $cut) (CPRowsNonempty (CPCSoulRows $cut)))

(= (CPInterfacesLive $cut)
   (let $interfaces (CPInterfaces $cut)
     (CPHas true (collapse (let $row (superpose $interfaces)
       (if (and (CPShape $row interface 4)
                (CPHas (index-atom $row 2) (available open revisable) 0)) true false))) 0)))

(= (CPThreadLive $row)
   (and (CPShape $row thread 4)
        (CPHas (index-atom $row 2) (open continued) 0)))

(= (CPLiveThreadIdsAt $rows $i $seen)
   (if (< $i (size-atom $rows))
     (let $row (index-atom $rows $i)
       (if (CPThreadLive $row)
         (let $id (index-atom $row 1)
           (if (CPHas $id $seen 0)
             (CPLiveThreadIdsAt $rows (+ $i 1) $seen)
             (CPLiveThreadIdsAt $rows (+ $i 1) (cons-atom $id $seen))))
         (CPLiveThreadIdsAt $rows (+ $i 1) $seen)))
     (CPReverseInto $seen 0 ())))

(= (CPLiveThreadIds $cut) (CPLiveThreadIdsAt (CPWRows $cut) 0 ()))

(= (CPAdverseFlourishing $flourishing)
   (CPFlourishingOrganizationHas $flourishing
     (capture obstruction disguise contradiction unresolved counterevidence
       positive-pole-distortion)))

(= (CPParticipantNeedsInquiry $participant-relations)
   (or (CPParticipantRelationsHave $participant-relations participant-proposed-relation)
     (or (CPParticipantRelationsHave $participant-relations participant-relation-conflict)
         (CPParticipantRelationsHave $participant-relations participant-reentry-unresolved))))

(= (CPInquiryNeededV2 $cut $facts $flourishing $participant-relations)
   (or (CPFactExpressionsUnresolved $facts)
     (or (== (size-atom (CPLiveThreadIds $cut)) 0)
      (or (CPAdverseFlourishing $flourishing)
          (CPParticipantNeedsInquiry $participant-relations)))))

(= (CPNativeRequirementRelations $cut)
   (CPListAppend (CPRowIds (CPDRelations $cut)) (CPRowIds (CPOmegaRelations $cut))))

(= (CPNativeRequirementDistinctions $cut) (CPRowIds (CPDDistinctions $cut)))
(= (CPNativeRequirementInterfaces $cut) (CPRowIds (CPInterfaces $cut)))

(= (CPNativeUndertakingsAt $cut $flourishing $threads $i)
   (if (< $i (size-atom $threads))
     (cons-atom (possible-movement (index-atom $threads $i) undertaking
       (CPNativeRequirementRelations $cut)
       (CPNativeRequirementDistinctions $cut)
       (CPNativeRequirementInterfaces $cut)
       (CPBeneficialFlourishingValues $flourishing)
       (consequence-route returned-contact non-certifying) l2425-supported)
       (CPNativeUndertakingsAt $cut $flourishing $threads (+ $i 1))) ()))

(= (CPNativeUndertakingsV2 $cut $facts $flourishing $participant-relations)
   (CPNativeUndertakingsAt $cut $flourishing (CPLiveThreadIds $cut) 0))

(= (CPNativeInquiriesV2 $cut $facts $flourishing $participant-relations)
   (cons-atom (possible-movement constitutive-inquiry inquiry
       (CPNativeRequirementRelations $cut)
       (CPNativeRequirementDistinctions $cut)
       (CPNativeRequirementInterfaces $cut)
       (CPBeneficialFlourishingValues $flourishing)
       (consequence-route discriminating-contact non-certifying) l2425-supported)
     ()))

(= (CPNativeDeferralsV2 $cut $flourishing)
   (cons-atom (possible-movement constitutive-defer defer
       (CPNativeRequirementRelations $cut)
       (CPNativeRequirementDistinctions $cut) ()
       (CPBeneficialFlourishingValues $flourishing)
       (consequence-route interface-contact non-certifying) l2425-supported)
     ()))

(= (CPNativePossibilitiesV2 $cut $facts $flourishing $participant-relations)
   (CPListAppend
     (CPNativeUndertakingsV2 $cut $facts $flourishing $participant-relations)
     (CPListAppend
       (CPNativeInquiriesV2 $cut $facts $flourishing $participant-relations)
       (CPNativeDeferralsV2 $cut $flourishing))))

; R/A/P read the same forming movement and are consumed by Generated standing.
; They expose per-relation and per-distinction witnesses rather than a scalar.
(= (CPRAPStandingV2 $cut $facts $flourishing $participant-relations $possibility)
   (let $form (index-atom $possibility 2)
     (if (== $form undertaking)
       (if (and (CPDLive $cut)
         (and (CPSoulLive $cut)
          (and (CPInterfacesLive $cut)
           (and (CPFactExpressionsLive $facts)
            (and (== (CPFactExpressionsUnresolved $facts) false)
             (and (== (CPAdverseFlourishing $flourishing) false)
                  (== (CPParticipantNeedsInquiry $participant-relations) false)))))))
         admissible unresolved)
       (if (== $form inquiry)
         (if (and (CPDLive $cut)
           (and (CPSoulLive $cut)
            (and (CPInterfacesLive $cut)
              (CPInquiryNeededV2 $cut $facts $flourishing $participant-relations))))
           admissible unresolved)
         (if (== $form defer)
           (if (and (CPDLive $cut)
             (and (CPSoulLive $cut) (== (CPInterfacesLive $cut) false)))
             admissible unresolved)
           unresolved)))))

(= (CPRAPReadingsV2 $cut $facts $flourishing $participant-relations $possibility)
   (let $id (index-atom $possibility 1)
     (rap-readings non-sovereign-same-forming-movement
       (relatedness-reading $id
         (relatedness-witness
           (required-relations (index-atom $possibility 3))
           (live-D (index-atom $cut 6)) (live-Omega (index-atom $cut 7)))
         non-compensatory)
       (appropriateness-reading $id
         (admissibility-witness (index-atom $cut 3) (index-atom $cut 8)
           (index-atom $cut 10) (CPInquiryNeededV2 $cut $facts $flourishing $participant-relations))
         derived-standing-not-contact)
       (precision-reading $id
         (precision-witness (required-distinctions (index-atom $possibility 4))
           (live-distinctions (index-atom (index-atom $cut 6) 2)))
         non-compensatory)
       (rap-standing (CPRAPStandingV2 $cut $facts $flourishing
         $participant-relations $possibility)))))

(= (CPRAPAdmissibleV2 $rap)
   (and (CPShape $rap rap-readings 6)
     (and (CPShape (index-atom $rap 5) rap-standing 2)
          (== (index-atom (index-atom $rap 5) 1) admissible))))

(= (CPGeneratedNonliveStandingV2 $cut $facts $flourishing $participant-relations $possibility)
   (let $form (index-atom $possibility 2)
     (if (== (CPSoulLive $cut) false) unresolved
       (if (== (CPDLive $cut) false) unresolved
         (if (and (== $form undertaking)
                  (or (CPAdverseFlourishing $flourishing)
                      (CPParticipantNeedsInquiry $participant-relations)))
           contradicted
           (if (and (!= $form defer) (== (CPInterfacesLive $cut) false))
             deferred
             (if (and (== $form inquiry)
                      (== (CPInquiryNeededV2 $cut $facts $flourishing
                        $participant-relations) false))
               unrecognized
               (if (and (== $form defer) (CPInterfacesLive $cut))
                 unavailable unavailable-or-unresolved))))))))

(= (CPGeneratedCandidateV2 $cut $facts $flourishing $participant-relations $possibility)
   (let* (($rap (CPRAPReadingsV2 $cut $facts $flourishing $participant-relations $possibility))
          ($id (index-atom $possibility 1)))
     (if (and (CPRAPAdmissibleV2 $rap)
              (== (index-atom $possibility 8) l2425-supported))
       (generated-candidate
         (generated-standing $id generated
           (r-star (index-atom $possibility 3))
           (a-star (index-atom $possibility 5))
           (p-star (index-atom $possibility 4))
           (o-star (index-atom $possibility 7))
           (legality (index-atom $possibility 8)) (source $possibility))
         $rap)
       (generated-candidate
         (generated-standing $id
           (CPGeneratedNonliveStandingV2 $cut $facts $flourishing
             $participant-relations $possibility)
           (required-relations (index-atom $possibility 3))
           (required-interfaces (index-atom $possibility 5))
           (required-distinctions (index-atom $possibility 4))
           (required-flourishings (index-atom $possibility 6))
           (required-consequence (index-atom $possibility 7))
           (required-legality (index-atom $possibility 8)))
         $rap))))

(= (CPGeneratedCandidatesAtV2 $cut $facts $flourishing $participant-relations $possibilities $i)
   (if (< $i (size-atom $possibilities))
     (cons-atom (CPGeneratedCandidateV2 $cut $facts $flourishing $participant-relations
       (index-atom $possibilities $i))
       (CPGeneratedCandidatesAtV2 $cut $facts $flourishing $participant-relations
         $possibilities (+ $i 1))) ()))

(= (CPGeneratedCandidateIsLive $candidate)
   (if (CPShape $candidate generated-candidate 3)
     (let $standing (index-atom $candidate 1)
       (and (CPShape $standing generated-standing 9)
            (== (index-atom $standing 2) generated))) false))

(= (CPLiveGeneratedCandidatesAt $candidates $i $out)
   (if (< $i (size-atom $candidates))
     (let $candidate (index-atom $candidates $i)
       (if (CPGeneratedCandidateIsLive $candidate)
         (CPLiveGeneratedCandidatesAt $candidates (+ $i 1) (cons-atom $candidate $out))
         (CPLiveGeneratedCandidatesAt $candidates (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (CPLiveGeneratedCandidates $candidates)
   (CPLiveGeneratedCandidatesAt $candidates 0 ()))

(= (CPMovementFromCandidateV2 $cut $facts $flourishing $participants
      $participant-relations $bridge $candidate $all $basis)
   (let* (($standing (index-atom $candidate 1))
          ($rap (index-atom $candidate 2))
          ($source (index-atom (index-atom $standing 8) 1)))
     (movement-formed (index-atom $source 2) (index-atom $standing 1)
       (source-cut (index-atom $cut 1))
       (material-derivation-v2
         (CPBalanceOrganization $cut $facts $flourishing $all $participants)
         $bridge $rap
         (generated-carriers (index-atom $standing 3) (index-atom $standing 4)
           (index-atom $standing 5) (index-atom $standing 6))
         (flourishing-requirements (index-atom $source 6))
         $participant-relations)
       (answerability (index-atom $standing 6))
       (retained-alternatives-v2 $all $basis))))

(= (CPConstructMovementV2 $cut $facts $flourishing $participants
      $participant-relations $bridge $candidates $basis)
   (let $generated (CPLiveGeneratedCandidates $candidates)
     (if (== (size-atom $generated) 0)
       (movement-unresolved (source-cut (index-atom $cut 1))
         (retained-alternatives-v2 $candidates $basis
           (CPBalanceOrganization $cut $facts $flourishing $candidates $participants)
           $bridge $participant-relations
           (unresolved-organization
             (D-live (CPDLive $cut))
             (soul-relation-available (CPSoulLive $cut))
             (interface-available (CPInterfacesLive $cut)))))
       (if (== (size-atom $generated) 1)
         (CPMovementFromCandidateV2 $cut $facts $flourishing $participants
           $participant-relations $bridge (index-atom $generated 0) $candidates $basis)
         (movement-plural-live (source-cut (index-atom $cut 1))
           (generated-alternatives $generated)
           (retained-alternatives-v2 $candidates $basis
             (CPBalanceOrganization $cut $facts $flourishing $candidates $participants)
             $bridge $participant-relations))))))

(= (CPConstitutiveEncounterV2 $cut $fact-views $flourishing-views
      $participant-source $payload-ref)
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
          ($possibilities (CPNativePossibilitiesV2 $revised-cut $facts $flourishing
            $participant-relations))
          ($generated (CPGeneratedCandidatesAtV2 $revised-cut $facts $flourishing
            $participant-relations $possibilities 0))
          ($basis (continuation-basis-v2 $fact-views $flourishing-views
            $participant-source (payload-reference $payload-ref)))
          ($movement (CPConstructMovementV2 $revised-cut $facts $flourishing
            $participants $participant-relations $bridge $generated $basis)))
     (constitutive-encounter $revised-cut $facts $flourishing $generated $movement $participants)))

(= (CPEncounterV2 $contact $predecessor)
   (let $cut (CPMakeCut $contact $predecessor)
     (if (CPCutValid $cut)
       (let $configuration (CPContactConfiguration $contact)
         (CPConstitutiveEncounterV2 $cut
           (index-atom $configuration 7) (index-atom $configuration 8)
           (index-atom $configuration 10) (index-atom $contact 8)))
       $cut)))

(= (CPEncounter $contact $predecessor)
   (if (CPShape $contact contact-v2 11)
     (CPEncounterV2 $contact $predecessor)
     (let $cut (CPMakeCut $contact $predecessor)
       (if (CPCutValid $cut)
         (let* (($facts (CPFactExpressions $cut $contact))
                ($flourishing (CPFlourishingOrganization $cut $contact))
                ($participants (CPParticipantReadings $cut $contact))
                ($generated (CPGeneratedAt $cut $facts $flourishing (CPPossibilities $contact) 0))
                ($movement (CPConstructMovement $cut $facts $flourishing $participants $generated)))
           (constitutive-encounter $cut $facts $flourishing $generated $movement $participants))
         $cut))))

; consequence: id movement-id effect-key result D-delta I-delta W-delta Present provenance
(= (CPConsequenceV1Valid $consequence)
   (if (CPShape $consequence consequence 10)
     (and (CPShape (index-atom $consequence 5) D-delta 3)
       (and (CPShape (index-atom $consequence 6) I-delta 2)
         (and (CPShape (index-atom $consequence 7) W-delta 2)
              (CPShape (index-atom $consequence 8) present-context 3)))) false))

(= (CPConsequenceV2Valid $consequence)
   (if (CPShape $consequence consequence-v2 13)
     (and (CPShape (index-atom $consequence 5) D-delta 3)
      (and (CPShape (index-atom $consequence 6) Omega-delta 2)
       (and (CPShape (index-atom $consequence 7) I-delta 2)
        (and (CPShape (index-atom $consequence 8) W-delta 2)
         (and (CPShape (index-atom $consequence 9) C-delta 2)
          (and (CPShape (index-atom $consequence 10) flourishing-delta 2)
               (CPShape (index-atom $consequence 11) present-context 3))))))) false))

(= (CPConsequenceValid $consequence)
   (or (CPConsequenceV1Valid $consequence) (CPConsequenceV2Valid $consequence)))

(= (CPNextCut $cut $consequence)
   (if (and (CPCutValid $cut) (CPConsequenceV1Valid $consequence))
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

(= (CPNextCutV2 $cut $consequence)
   (if (and (CPCutValid $cut) (CPConsequenceV2Valid $consequence))
     (let* (($old-d (index-atom $cut 6))
            ($delta-d (index-atom $consequence 5))
            ($old-omega (index-atom $cut 7))
            ($delta-omega (index-atom $consequence 6))
            ($old-i (index-atom $cut 8))
            ($delta-i (index-atom $consequence 7))
            ($old-w (index-atom $cut 9))
            ($delta-w (index-atom $consequence 8))
            ($old-c (index-atom $cut 10))
            ($delta-c (index-atom $consequence 9)))
       (constitutive-cut
         (next-cut (index-atom $cut 1) (index-atom $consequence 1))
         (index-atom $cut 1)
         (index-atom $cut 3)
         (after (index-atom $cut 4) (index-atom $consequence 1))
         (same-becoming (index-atom $cut 5) (index-atom $consequence 1))
         (D (CPListAppend (index-atom $old-d 1) (index-atom $delta-d 1))
            (CPListAppend (index-atom $old-d 2) (index-atom $delta-d 2)))
         (Omega (CPListAppend (index-atom $old-omega 1) (index-atom $delta-omega 1)))
         (I (CPListAppend (index-atom $old-i 1) (index-atom $delta-i 1)))
         (W (CPListAppend (index-atom $old-w 1) (index-atom $delta-w 1)))
         (C (CPListAppend (index-atom $old-c 1) (index-atom $delta-c 1)))
         (index-atom $consequence 11)
         (consequence-provenance (index-atom $consequence 1)
           (index-atom $consequence 2) (index-atom $consequence 3)
           (index-atom $consequence 12))
         consequence-incorporated))
     (cut-unresolved malformed-consequence-v2 $consequence)))

(= (CPMovementBasisV2 $movement)
   (if (CPShape $movement movement-formed 7)
     (let $retained (index-atom $movement 6)
       (if (CPShape $retained retained-alternatives-v2 3)
         (index-atom $retained 2) no-continuation-basis))
     no-continuation-basis))

(= (CPReconstituteAfterConsequenceV2 $cut $movement $consequence)
   (let $basis (CPMovementBasisV2 $movement)
     (if (CPShape $basis continuation-basis-v2 5)
       (let* (($next-cut (CPNextCutV2 $cut $consequence))
              ($flourishing-views (CPListAppend (index-atom $basis 2)
                (index-atom (index-atom $consequence 10) 1)))
              ($next (CPConstitutiveEncounterV2 $next-cut
                (index-atom $basis 1) $flourishing-views
                (index-atom $basis 3) (index-atom (index-atom $basis 4) 1))))
         (next-constitutive-organization $next))
       (next-constitutive-organization-unresolved missing-continuation-basis))))
