; AMA-1.2 R3 native finite inheritance substrate.
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
       (index-atom $contact 8))
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
