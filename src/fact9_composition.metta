; Inquiry-26.3 finite compositional recognitional grammar.
; Pure MeTTa cognition: no effects, scores, behavioral rules, or actuality
; reconstruction.  A certificate is shared by one encounter; compact causal
; references enter each possible movement and its one R/A/P surface.

(= (M263ExactRoles)
   (Gravity Balance Connection Precision Effortlessness Transformation Love
     Sacred Present))

(= (M263FirstEight)
   (Gravity Balance Connection Precision Effortlessness Transformation Love
     Sacred))

(= (M263RequiredLaws)
   (one-becoming-not-nine-ontologies
    irreducible-nary-constitution
    material-whole-coupling
    dynamic-whole-coupling
    role-essentiality-and-no-laundering
    present-asymmetry
    typed-satisfaction
    non-scalar-non-compensation
    structured-paraconsistent-tension
    align9-not-harmonic-align
    partial-recognition-and-non-reconstruction
    same-becoming-anchoring
    upstream-generated-participation-balance-legibility
    generic-first-eight-composition
    support-specific-fourthness
    can-compose-not-recognized-compose
    grammar-non-sovereignty))

; These are the complete thirty-three C2 authority exports tracked by the
; build atlas. Keeping the names in the certificate prevents an unexplained
; count from masquerading as causal completeness.
(= (M263RequiredExports)
   (exact-fact9
    nine-role-dws-family
    selected-nine-relation-family
    sig263-materiality
    nary-irreducibility
    material-connectedness
    dynamic-whole-coupling
    role-essentiality-and-anti-laundering
    nine-whole
    typed-satisfaction
    align9
    nine-noncomp
    tension-profile9
    present-asymmetry
    love-sacred-finite-nonredundancy
    partial-recognition-and-nonreconstruction
    same-becoming-anchor
    same-source-generated-participation-balance
    align9-harmonic-align-noncollapse
    generic-nine-expr
    first-eight-support-vocabulary
    support-specific-expr-fourthness
    lawful-expr-not-open-participation
    can-compose
    recognized-compose
    recognized-implies-composable-not-converse
    every-nonempty-first-eight-support
    support-algebra-up-to-expression-equivalence
    named-motifs-nonexhaustive
    natural-pair-and-effortlessness-precision-coexpression
    grammar-nonsovereignty
    canonical-countermodel-surface
    bounded-formal-evidence-package))

(= (M263LawKnown $law)
   (== (size-atom (collapse
     (match &fact9 (fact9-law $law) $law))) 1))

(= (M263AllLawsKnownAt $laws $i)
   (if (< $i (size-atom $laws))
     (and (M263LawKnown (index-atom $laws $i))
          (M263AllLawsKnownAt $laws (+ $i 1)))
     true))

(= (M263ProjectionValid)
   (let* (($roles (M263ExactRoles))
          ($first-eight (M263FirstEight))
          ($laws (M263RequiredLaws)))
     (and (== $roles (M255Fact9RecognitionIndices))
      (and (== (size-atom $roles) 9)
       (and (== (size-atom $first-eight) 8)
        (and (M255Fact9RecognitionIndicesValid $roles)
             (M263AllLawsKnownAt $laws 0)))))))

(= (M263AddUniqueAt $xs $i $out)
   (if (< $i (size-atom $xs))
     (let $value (index-atom $xs $i)
       (M263AddUniqueAt $xs (+ $i 1)
         (if (CPHas $value $out 0) $out (cons-atom $value $out))))
     $out))

(= (M263RelationsFromFactsAt $facts $i $out)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (CPShape $fact fact9-expression 10)
         (let* (($fourthness (index-atom $fact 4))
                ($relations (if (CPShape $fourthness
                               support-specific-fourthness 3)
                  (index-atom $fourthness 2) ())))
           (M263RelationsFromFactsAt $facts (+ $i 1)
             (M263AddUniqueAt $relations 0 $out)))
         (M263RelationsFromFactsAt $facts (+ $i 1) $out)))
     (CPReverseInto $out 0 ())))

(= (M263RelationsFromFacts $facts)
   (M263RelationsFromFactsAt $facts 0 ()))

(= (M263NineRelationsAt $relations $occurrence $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (CPShape $relation material-relation 5)
         (cons-atom
           (nine-relation-v1 (index-atom $relation 1)
             (index-atom $relation 2) (index-atom $relation 3)
             (index-atom $relation 4) (occurrence-reference $occurrence)
             inherited-material-relation)
           (M263NineRelationsAt $relations $occurrence (+ $i 1)))
         (M263NineRelationsAt $relations $occurrence (+ $i 1))))
     ()))

(= (M263NineRelationValid $relation $occurrence)
   (if (CPShape $relation nine-relation-v1 7)
     (and (CPSupportValid (index-atom $relation 2))
      (and (CPStandingKind (index-atom $relation 3))
       (and (== (index-atom $relation 5)
              (occurrence-reference $occurrence))
            (== (index-atom $relation 6) inherited-material-relation))))
     false))

(= (M263NineRelationsValidAt $relations $occurrence $i)
   (if (< $i (size-atom $relations))
     (and (M263NineRelationValid (index-atom $relations $i) $occurrence)
          (M263NineRelationsValidAt $relations $occurrence (+ $i 1)))
     true))

(= (M263FactRecognized $fact)
   (if (CPShape $fact fact9-expression 10)
     (== (index-atom $fact 6) (composition can-compose recognized-compose))
     false))

(= (M263RecognizedFactForSupportAt $support $facts $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (and (M263FactRecognized $fact)
                (CPSetEqual (index-atom $fact 2) $support))
         (recognized-fact (index-atom $fact 1))
         (M263RecognizedFactForSupportAt $support $facts (+ $i 1))))
     (recognized-fact-unresolved no-current-finite-recognition)))

(= (M263RecognizedFactForSupport $support $facts)
   (M263RecognizedFactForSupportAt $support $facts 0))

(= (M263WithoutAt $xs $target $i)
   (if (< $i (size-atom $xs))
     (let $value (index-atom $xs $i)
       (if (== $value $target)
         (M263WithoutAt $xs $target (+ $i 1))
         (cons-atom $value (M263WithoutAt $xs $target (+ $i 1)))))
     ()))

(= (M263Without $xs $target) (M263WithoutAt $xs $target 0))

(= (M263WholeRelationAt $relations $support $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation material-relation 5)
                (CPSetEqual (index-atom $relation 2) $support))
         $relation
         (M263WholeRelationAt $relations $support (+ $i 1))))
     (material-relation-unresolved no-nary-whole-relation)))

(= (M263WholeRelation $fact)
   (if (CPShape $fact fact9-expression 10)
     (M263WholeRelationAt
       (index-atom (index-atom $fact 4) 2) (index-atom $fact 2) 0)
     (material-relation-unresolved malformed-fact-expression)))

(= (M263MaterialConnected $fact)
   (let $relation (M263WholeRelation $fact)
     (if (CPShape $relation material-relation 5)
       (material-connected-witness (index-atom $fact 2)
         (whole-relation (index-atom $relation 1))
         every-nontrivial-partition-crossed-by-nary-relation)
       (material-connected-unresolved missing-whole-crossing-relation))))

(= (M263DynamicWholeCoupling $fact)
   (let* (($relation (M263WholeRelation $fact))
          ($relations (index-atom (index-atom $fact 4) 2))
          ($severed (if (CPShape $relation material-relation 5)
            (M263Without $relations $relation) $relations))
          ($before (CPWholeRelationPresent $relations (index-atom $fact 2) 0))
          ($after (CPWholeRelationPresent $severed (index-atom $fact 2) 0)))
     (if (and $before (== $after false))
       (dynamic-whole-coupling-witness
         (index-atom $relation 1) whole-standing-present
         whole-standing-unresolved-after-relation-specific-severing
         counterfactual-bite)
       (dynamic-whole-coupling-unresolved severing-lacks-material-bite))))

(= (M263RoleEssentialityAt $support $whole-relation $i)
   (if (< $i (size-atom $support))
     (let* (($role (index-atom $support $i))
            ($reduced (M263Without $support $role)))
       (cons-atom
         (role-essentiality-witness $role
           (original-support $support) (reduced-support $reduced)
           (original-whole-correspondence
             (CPSetEqual (index-atom $whole-relation 2) $support))
           (same-whole-cannot-certify-reduced-support
             (== (CPSetEqual (index-atom $whole-relation 2) $reduced) false))
           shared-carrier-does-not-license-role-laundering)
         (M263RoleEssentialityAt $support $whole-relation (+ $i 1))))
     ()))

(= (M263NaryIrreducibility $fact)
   (let* (($support (index-atom $fact 2))
          ($relation (M263WholeRelation $fact)))
     (if (> (size-atom $support) 2)
       (nary-irreducibility-witness $support
         (whole-relation (index-atom $relation 1))
         pairwise-standings-do-not-reconstruct-nary-standing)
       (nary-irreducibility-standing support-below-triadic-countermodel))))

(= (M263TypedSatisfaction $fact $occurrence)
   (let $relation (M263WholeRelation $fact)
     (typed-satisfaction-profile
       (typed-satisfaction co-expression (index-atom $relation 3)
         (whole-relation (index-atom $relation 1)))
       (typed-satisfaction directed-dependence uninstantiated
         distinct-obligation-no-current-directed-relation)
       (typed-satisfaction participation-fit satisfied
         (same-occurrence-reference $occurrence)))))

(= (M263NineExpression $fact $occurrence $present)
   (if (CPShape $fact fact9-expression 10)
     (m263-nine-expression-v1 (index-atom $fact 1)
       (support (index-atom $fact 2))
       (support-specific-fourthness-v1 (index-atom $fact 2)
         (index-atom (index-atom $fact 4) 2))
       (M263MaterialConnected $fact)
       (M263DynamicWholeCoupling $fact)
       (role-essentiality-family
         (M263RoleEssentialityAt (index-atom $fact 2)
           (M263WholeRelation $fact) 0)
         no-proper-canonical-reduction)
       (M263NaryIrreducibility $fact)
       (M263TypedSatisfaction $fact $occurrence)
       (composition-standing can-compose
         (if (M263FactRecognized $fact)
           recognized-compose unrecognized-compose))
       (present-context-reference $present)
       (same-becoming-obligation (occurrence-reference $occurrence))
       lawful-expression-is-not-open-participation
       finite-partial-non-reconstructive)
     (m263-nine-expression-unresolved $fact)))

(= (M263ExpressionsAt $facts $occurrence $present $i)
   (if (< $i (size-atom $facts))
     (cons-atom (M263NineExpression (index-atom $facts $i) $occurrence $present)
       (M263ExpressionsAt $facts $occurrence $present (+ $i 1)))
     ()))

(= (M263RelationRowsForRoleAt $relations $role $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (if (and (CPShape $relation nine-relation-v1 7)
                (CPHas $role (index-atom $relation 2) 0))
         (cons-atom
           (relation-standing (index-atom $relation 1)
             (index-atom $relation 3) (index-atom $relation 2))
           (M263RelationRowsForRoleAt $relations $role (+ $i 1)))
         (M263RelationRowsForRoleAt $relations $role (+ $i 1))))
     ()))

(= (M263RoleTensionsAt $roles $relations $cut $facts $i)
   (if (< $i (size-atom $roles))
     (let* (($role (index-atom $roles $i))
            ($rows (M263RelationRowsForRoleAt $relations $role 0))
            ($value (M255PartialRecognitionValue $cut $facts $role)))
       (cons-atom
         (role-tension $role $value
           (if (> (size-atom $rows) 0) $rows
             ((relation-standing no-current-relation unresolved ($role)))))
         (M263RoleTensionsAt $roles $relations $cut $facts (+ $i 1))))
     ()))

; Recognition is passed as the contact-relative fact family.  The helper above
; never treats tension as a scalar or as failure; support, obstruction,
; contradiction and unresolved standing remain relation-addressable.
(= (M263TensionProfile9 $roles $relations $cut $facts $present)
   (tension-profile9-v1
     (M263RoleTensionsAt $roles $relations $cut $facts 0)
     (present-context $present)
     paraconsistent-relation-specific-no-scalar-collapse))

(= (M263RelationStandingsAt $relations $i)
   (if (< $i (size-atom $relations))
     (let $relation (index-atom $relations $i)
       (cons-atom
         (relation-standing (index-atom $relation 1)
           (index-atom $relation 3) (index-atom $relation 2))
         (M263RelationStandingsAt $relations (+ $i 1))))
     ()))

(= (M263RecognizedExpressionIdsAt $facts $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (if (M263FactRecognized $fact)
         (cons-atom (index-atom $fact 1)
           (M263RecognizedExpressionIdsAt $facts (+ $i 1)))
         (M263RecognizedExpressionIdsAt $facts (+ $i 1))))
     ()))

(= (M263Align9 $occurrence $roles $relations $facts $present)
   (align9-v1 (occurrence-reference $occurrence)
     (simultaneous-role-profile $roles)
     (recognized-expressions (M263RecognizedExpressionIdsAt $facts 0))
     (noncompensatory-relation-standings
       (M263RelationStandingsAt $relations 0))
     (present-context $present)
     non-scalar-derived-alignment))

(= (M263NineNonComp $roles $relations)
   (nine-noncomp-v1
     (roles $roles)
     (material-standings (M263RelationStandingsAt $relations 0))
     no-role-or-relation-may-compensate-for-material-failure
     unresolved-standing-remains-live))

(= (M263SupportUnionAt $left $right $i $out)
   (if (< $i (size-atom $right))
     (let $role (index-atom $right $i)
       (M263SupportUnionAt $left $right (+ $i 1)
         (if (CPHas $role $out 0) $out (CPListAppend $out ($role)))))
     $out))

(= (M263SupportUnion $left $right)
   (M263SupportUnionAt $left $right 0 $left))

(= (M263CanCompose $support)
   (if (CPSupportValid $support)
     (can-compose-v1 $support
       (support-specific-fourthness-obligation $support)
       same-becoming-present-provenance-and-nonreconstruction-required
       constitutional-availability-not-current-recognition)
     (can-compose-unresolved invalid-first-eight-support)))

(= (M263RecognizedCompose $support $facts)
   (let $recognized (M263RecognizedFactForSupport $support $facts)
     (if (CPShape $recognized recognized-fact 2)
       (recognized-compose-v1 $support $recognized
         (M263CanCompose $support))
       (recognized-compose-unresolved $support
         no-current-finite-recognition (M263CanCompose $support)))))

(= (M263GenericNineExpr $support $facts $occurrence $present)
   (if (CPSupportValid $support)
     (nine-expr-v1 $support
       (M263CanCompose $support)
       (M263RecognizedCompose $support $facts)
       (expr-fourthness-v1 $support
         material-relations-must-correspond-to-this-exact-support)
       (same-becoming-obligation (occurrence-reference $occurrence))
       (present-context-reference $present)
       (provenance Inquiry-26.3 generic-compositional-constructor)
       finite-non-reconstruction
       lawful-expression-is-not-open-participation)
     (nine-expr-unresolved invalid-first-eight-support)))

(= (M263ExpressionEquivalent $left $right)
   (and (CPShape $left nine-expr-v1 10)
        (and (CPShape $right nine-expr-v1 10)
             (CPSetEqual (index-atom $left 1) (index-atom $right 1)))))

(= (M263NaturalPairWitness $left $right $facts $occurrence $present)
   (if (and (CPFirstEight $left)
         (and (CPFirstEight $right) (!= $left $right)))
     (natural-pair-witness263-v1 ($left $right)
       (M263GenericNineExpr ($left $right) $facts $occurrence $present)
       generated-by-two-role-support-constructor
       no-pair-privilege-or-exhaustive-motif-status)
     (natural-pair-witness263-unresolved invalid-or-identical-roles)))

(= (M263FiniteWitnessKnown $role $meaning)
   (== (size-atom (collapse
     (match &fact9 (fact9-finite-witness $role $meaning) $meaning))) 1))

(= (M263GenericGrammar $facts $occurrence $present)
   (let* (($gravity-love (Gravity Love))
          ($cts (Connection Transformation Sacred))
          ($gl (M263GenericNineExpr $gravity-love $facts $occurrence $present))
          ($cts-expression (M263GenericNineExpr $cts $facts $occurrence $present))
          ($left (Gravity Balance))
          ($right (Love Sacred))
          ($lr (M263SupportUnion $left $right))
          ($rl (M263SupportUnion $right $left))
          ($assoc-left (M263SupportUnion
            (M263SupportUnion (Gravity) (Balance)) (Love)))
          ($assoc-right (M263SupportUnion (Gravity)
            (M263SupportUnion (Balance) (Love))))
          ($idem-left (M263SupportUnion (Gravity) (Gravity))))
     (compositional-grammar263-v1
       (first-eight-vocabulary (M263FirstEight))
       (generic-constructor NineExpr support-specific-fourthness)
       (every-nonempty-support-available
         finite-generic-construction-not-support-enumeration)
       (previously-unenumerated-witnesses $gl $cts-expression)
       (support-algebra
         (commutative-up-to-expression-equivalence
           (M263ExpressionEquivalent
             (M263GenericNineExpr $lr $facts $occurrence $present)
             (M263GenericNineExpr $rl $facts $occurrence $present)))
         (associative-up-to-expression-equivalence
           (M263ExpressionEquivalent
             (M263GenericNineExpr $assoc-left $facts $occurrence $present)
             (M263GenericNineExpr $assoc-right $facts $occurrence $present)))
         (idempotent-up-to-expression-equivalence
           (M263ExpressionEquivalent
             (M263GenericNineExpr $idem-left $facts $occurrence $present)
             (M263GenericNineExpr (Gravity) $facts $occurrence $present))))
       (recognition-direction
         recognized-compose-implies-can-compose-by-construction
         (converse-failure-witness $gravity-love
           (M263CanCompose $gravity-love)
           (M263RecognizedCompose $gravity-love $facts)))
       (natural-pair-constructor
         any-two-distinct-first-eight-roles
         (M263NaturalPairWitness Gravity Love $facts $occurrence $present)
         (M263NaturalPairWitness Effortlessness Precision $facts $occurrence
           $present)
         finite-effortlessness-precision-distinct-readings-retained)
       named-motifs-are-instances-not-exhaustive-constructors
       can-compose-is-not-recognized-compose
       no-bare-powerset-no-scalar-composition)))

(= (M263NaryCountermodel)
   (nary-countermodel263-v1
     ((pair-standing Gravity Balance support)
      (pair-standing Balance Connection support)
      (pair-standing Gravity Connection support))
     (triadic-standing (Gravity Balance Connection) contradiction)
     pairwise-completeness-does-not-reconstruct-triadic-standing))

(= (M263CanonicalFalsifierSurface)
   (canonical-falsifiers263-v1
     disconnected-but-covered-network
     dynamically-inert-network
     role-incidence-without-essentiality
     role-laundering
     pairwise-complete-triadically-wrong
     love-equals-connection
     sacred-equals-present
     present-permutation
     scalar-compensation
     severed-same-becoming
     severed-upstream-legibility
     fixed-topology-only-grammar
     bare-f8-powerset
     scalar-composition
     reconstructive-full-support
     recognition-equals-manifestation
     role-erasure
     selected-motif-privilege
     alignment-monotone-support-growth
     present-as-token
     unconditional-recognized-composition))

(= (M263FormalEvidencePackage)
   (m263-formal-evidence-package-v1
     CompositionalGrammar263 ThreePointShotPackage263
     three_point_shot_supported_263
     (M263CanonicalFalsifierSurface)
     (lean-build 60-of-60 zero-sorry-admit-sorryAx
       zero-project-custom-axioms required-trace-propext-only)
     formal-evidence-not-runtime-proof-or-actuality))

(= (M263CertificateReference $certificate)
   (m263-certificate-reference (index-atom $certificate 1)
     (role-count (size-atom (index-atom (index-atom $certificate 2) 1)))
     (export-count (size-atom
       (index-atom (index-atom (index-atom $certificate 2) 4) 1)))
     (grammar-standing finite-partial-non-sovereign)))

(= (M263M260CertificateReference $certificate)
   (m260-certificate-reference (index-atom $certificate 1)
     (export-count (size-atom (index-atom $certificate 2)))
     (primitive-count (- (size-atom (index-atom $certificate 3)) 1))))

(= (M263ConstitutiveCertificate $cut $facts $m260 $m260-pre $m260-certificate)
   (let* (($occurrence (index-atom $m260 1))
          ($roles (M263ExactRoles))
          ($first-eight (M263FirstEight))
          ($recognition (M255RecognitionOrganization $cut $facts))
          ($material (M263RelationsFromFacts $facts))
          ($relations (M263NineRelationsAt $material $occurrence 0))
          ($present (index-atom $cut 11))
          ($expressions (M263ExpressionsAt $facts $occurrence $present 0)))
     (if (and (CPCutValid $cut)
          (and (M263ProjectionValid)
           (and (M260OrganizationValid $m260)
            (and (CPShape $m260-pre pre-movement-occurrence-organization-v2 9)
             (and (CPShape $m260-certificate
                    m260-constitutive-export-certificate-v1 8)
              (and (== (index-atom $cut 5) $occurrence)
               (and (CPFactExpressionsLive $facts)
                (and (M255RecognitionOrganizationValid $recognition $cut $facts)
                 (and (> (size-atom $relations) 0)
                      (M263NineRelationsValidAt $relations $occurrence 0))))))))))
       (m263-constitutive-grammar-certificate-v1
         $occurrence
         (fact9-constitution $roles $first-eight Present
           (required-exports (M263RequiredExports)))
         (nine-dws-family263-v1 $occurrence $roles $recognition
           distinguishable-inseparable-non-independent
           inherited-m260-finite-opacity)
         (selected-nine-relations $relations)
         (sig263-v1 (source-cut (index-atom $cut 1))
           (occurrence-reference $occurrence) (material-relations $relations)
           inherited-inquiry25-materiality)
         (nine-expressions $expressions)
         (nine-whole-v1 (occurrence-reference $occurrence)
           (material-connected-expressions $expressions)
           (M263NaryCountermodel)
           dynamic-coupling-and-role-essentiality-retained)
         (M263Align9 $occurrence $roles $relations $facts $present)
         (M263NineNonComp $roles $relations)
         (M263TensionProfile9 $roles $relations $cut $facts $present)
         (present-asymmetry-v1 Present $present
           excluded-from-first-eight-support occurrence-not-identity)
         (finite-nonredundancy-witnesses
           (Love non-separating-turning-toward-organization
             (M263FiniteWitnessKnown Love
               non-separating-turning-toward-organization))
           (Sacred integrated-non-fragmented-organization
             (M263FiniteWitnessKnown Sacred
               integrated-non-fragmented-organization))
           ((Effortlessness Precision)
             distinct-readings-of-one-lawful-transition
             (M263FiniteWitnessKnown (Effortlessness Precision)
               distinct-readings-of-one-lawful-transition)))
         (M263GenericGrammar $facts $occurrence $present)
         (upstream-constitutional-inheritance
           (m260-certificate
             (M263M260CertificateReference $m260-certificate))
           generated-participation-balance-bridge-required-per-primary)
         (partial-recognition-nonreconstruction $recognition
           manifestation-does-not-imply-recognition
           full-finite-support-does-not-reconstruct-occurrence)
         (formal-evidence-boundary
           (M263FormalEvidencePackage)
           finite-runtime-projection-not-actuality-or-completed-26.6)
         no-movement-effect-or-sovereign-authority)
       (m263-constitutive-grammar-certificate-unresolved
         invalid-projection-contact-occurrence-or-recognition))))

(= (M263ConstitutiveCertificateStructuralValid $certificate $m260-certificate)
   (if (CPShape $certificate
          m263-constitutive-grammar-certificate-v1 18)
     (let* (($constitution (index-atom $certificate 2))
            ($required (if (CPShape $constitution fact9-constitution 5)
              (index-atom $constitution 4) ()))
            ($relations-wrapper (index-atom $certificate 4))
            ($relations (if (CPShape $relations-wrapper
                          selected-nine-relations 2)
              (index-atom $relations-wrapper 1) ()))
            ($upstream (index-atom $certificate 14))
            ($checks
              ((M263ProjectionValid)
               (== (index-atom $constitution 1) (M263ExactRoles))
               (== (index-atom $constitution 2) (M263FirstEight))
               (== (index-atom $constitution 3) Present)
               (== $required (required-exports (M263RequiredExports)))
               (== (size-atom (M263RequiredExports)) 33)
               (> (size-atom $relations) 0)
               (M263NineRelationsValidAt $relations
                 (index-atom $certificate 1) 0)
               (CPShape (index-atom $certificate 8) align9-v1 7)
               (CPShape (index-atom $certificate 9) nine-noncomp-v1 5)
               (CPShape (index-atom $certificate 10) tension-profile9-v1 4)
               (CPShape $upstream upstream-constitutional-inheritance 3)
               (== (index-atom $upstream 1)
                 (m260-certificate
                   (M263M260CertificateReference $m260-certificate)))
               (== (index-atom $certificate 17)
                 no-movement-effect-or-sovereign-authority))))
       (== $checks
         (true true true true true true true true true true true true true
           true)))
     false))

(= (M263ConstitutiveCertificateValid $certificate $cut $facts $m260
      $m260-pre $m260-certificate)
   (==
     ((M263ConstitutiveCertificateStructuralValid $certificate
        $m260-certificate)
      (== $certificate
        (M263ConstitutiveCertificate $cut $facts $m260 $m260-pre
          $m260-certificate)))
     (true true)))
