; Inquiry-25.5 generative signatures and proof-relevant carrier translation.
; Pure MeTTa. These finite witnesses neither select a movement nor claim
; actuality, carrier identity, SameBecoming, or total carrier isomorphism.

(= (M255AllIn $xs $ys $i)
   (if (< $i (size-atom $xs))
     (and (CPHas (index-atom $xs $i) $ys 0)
          (M255AllIn $xs $ys (+ $i 1))) true))

(= (M255RecognitionIdsAt $facts $i)
   (if (< $i (size-atom $facts))
     (let $fact (index-atom $facts $i)
       (cons-atom (if (CPShape $fact fact9-expression 10)
                    (index-atom $fact 1) unrecognized-fact-expression)
         (M255RecognitionIdsAt $facts (+ $i 1)))) ()))

(= (M255GenSig $carrier $move-type $cut $facts $possibility)
   (gen-sig-v1
     (carrier-signature $carrier constitutive-cut $move-type)
     (cut-vocabulary (index-atom $cut 1) (index-atom $cut 2)
       (proto-time inherited-strict-partial-order))
     (move-vocabulary (index-atom $possibility 1)
       (index-atom $possibility 2))
     (relation-vocabulary (index-atom $possibility 3))
     (distinction-vocabulary (index-atom $possibility 4))
     (interface-vocabulary (index-atom $possibility 5))
     (precursor-vocabulary
       (r-star (index-atom $possibility 3))
       (a-star (index-atom $possibility 5))
       (p-star (index-atom $possibility 4))
       (o-star (index-atom $possibility 7)))
     (inherited-legality (index-atom $possibility 8))
     (force-obligation-vocabulary
       (obligation-domain holding-apart imposed-velocity compensatory bypass)
       (holds-obligation-relation witness-required)
       (disqualifying-obligation-relation witness-required)
       witness-bearing-non-optimizing)
     (disposition-reachability-vocabulary
       (disposition-domain open constrained unresolved)
       (reachable-relation derived-read-only))
     (reflexive-constraint-vocabulary
       (self-representation-dependence witness-required)
       (severing-changes-access witness-required)
       conjunctive-causal-bite)
     (recognition-vocabulary (M255RecognitionIdsAt $facts 0)
       partial-non-reconstructive)))

(= (M255GenSigVocabularyValid $signature)
   (let* (($relations (index-atom $signature 4))
          ($distinctions (index-atom $signature 5))
          ($interfaces (index-atom $signature 6)))
     (and (CPShape $relations relation-vocabulary 2)
      (and (CPShape $distinctions distinction-vocabulary 2)
       (and (CPShape $interfaces interface-vocabulary 2)
        (and (is-expr (index-atom $relations 1))
         (and (is-expr (index-atom $distinctions 1))
          (and (is-expr (index-atom $interfaces 1))
           (and (CPUniq (index-atom $relations 1) 0 ())
            (and (CPUniq (index-atom $distinctions 1) 0 ())
                 (CPUniq (index-atom $interfaces 1) 0 ())))))))))))

(= (M255GenSigPrecursorsValid $signature)
   (let* (($precursors (index-atom $signature 7))
          ($relations (index-atom (index-atom $signature 4) 1))
          ($distinctions (index-atom (index-atom $signature 5) 1))
          ($interfaces (index-atom (index-atom $signature 6) 1)))
     (and (CPShape $precursors precursor-vocabulary 5)
      (and (== (index-atom $precursors 1) (r-star $relations))
       (and (== (index-atom $precursors 2) (a-star $interfaces))
        (and (== (index-atom $precursors 3) (p-star $distinctions))
             (CPShape (index-atom $precursors 4) o-star 2)))))))

(= (M255GenSigContractsValid $signature)
   (let* (($obligations (index-atom $signature 9))
          ($recognition (index-atom $signature 12)))
     (and (== (index-atom $signature 8)
            (inherited-legality l2425-supported))
      (and (== $obligations
             (force-obligation-vocabulary
               (obligation-domain holding-apart imposed-velocity
                 compensatory bypass)
               (holds-obligation-relation witness-required)
               (disqualifying-obligation-relation witness-required)
               witness-bearing-non-optimizing))
       (and (== (index-atom $signature 10)
              (disposition-reachability-vocabulary
                (disposition-domain open constrained unresolved)
                (reachable-relation derived-read-only)))
        (and (== (index-atom $signature 11)
               (reflexive-constraint-vocabulary
                 (self-representation-dependence witness-required)
                 (severing-changes-access witness-required)
                 conjunctive-causal-bite))
         (and (CPShape $recognition recognition-vocabulary 3)
          (and (is-expr (index-atom $recognition 1))
               (== (index-atom $recognition 2)
                 partial-non-reconstructive)))))))))

(= (M255GenSigStructuralValid $signature)
   (if (CPShape $signature gen-sig-v1 13)
     (and (CPShape (index-atom $signature 1) carrier-signature 4)
      (and (CPShape (index-atom $signature 2) cut-vocabulary 4)
       (and (== (index-atom (index-atom $signature 2) 3)
              (proto-time inherited-strict-partial-order))
        (and (CPShape (index-atom $signature 3) move-vocabulary 3)
         (and (M255GenSigVocabularyValid $signature)
          (and (M255GenSigPrecursorsValid $signature)
               (M255GenSigContractsValid $signature))))))) false))

(= (M255GenSigRelations $signature)
   (index-atom (index-atom $signature 4) 1))
(= (M255GenSigDistinctions $signature)
   (index-atom (index-atom $signature 5) 1))
(= (M255GenSigInterfaces $signature)
   (index-atom (index-atom $signature 6) 1))
(= (M255GenSigCarrier $signature)
   (index-atom (index-atom $signature 1) 1))

(= (M255CarrierRoleIdsAt $carrier $kind $ids $i)
   (if (< $i (size-atom $ids))
     (cons-atom (carrier-role $carrier $kind (index-atom $ids $i))
       (M255CarrierRoleIdsAt $carrier $kind $ids (+ $i 1))) ()))

(= (M255CarrierGenSig $carrier $move-type $cut $facts $possibility)
   (let* (($relations (M255CarrierRoleIdsAt $carrier relation
                       (index-atom $possibility 3) 0))
          ($distinctions (M255CarrierRoleIdsAt $carrier distinction
                          (index-atom $possibility 4) 0))
          ($interfaces (M255CarrierRoleIdsAt $carrier interface
                        (index-atom $possibility 5) 0))
          ($recognitions (M255CarrierRoleIdsAt $carrier recognition
                          (M255RecognitionIdsAt $facts 0) 0)))
     (gen-sig-v1
       (carrier-signature $carrier constitutive-cut $move-type)
       (cut-vocabulary (index-atom $cut 1) (index-atom $cut 2)
         (proto-time inherited-strict-partial-order))
       (move-vocabulary (index-atom $possibility 1)
         (index-atom $possibility 2))
       (relation-vocabulary $relations)
       (distinction-vocabulary $distinctions)
       (interface-vocabulary $interfaces)
       (precursor-vocabulary (r-star $relations) (a-star $interfaces)
         (p-star $distinctions) (o-star (index-atom $possibility 7)))
       (inherited-legality (index-atom $possibility 8))
       (force-obligation-vocabulary
         (obligation-domain holding-apart imposed-velocity compensatory bypass)
         (holds-obligation-relation witness-required)
         (disqualifying-obligation-relation witness-required)
         witness-bearing-non-optimizing)
       (disposition-reachability-vocabulary
         (disposition-domain open constrained unresolved)
         (reachable-relation derived-read-only))
       (reflexive-constraint-vocabulary
         (self-representation-dependence witness-required)
         (severing-changes-access witness-required)
         conjunctive-causal-bite)
       (recognition-vocabulary $recognitions partial-non-reconstructive))))

(= (M255GenSigValid $signature $carrier $move-type $cut $facts $possibility)
   (and (CPCutValid $cut)
     (and (CPShape $possibility possible-movement 9)
      (and (M255GenSigStructuralValid $signature)
           (== $signature
             (M255GenSig $carrier $move-type $cut $facts $possibility))))))

; A GenSig names the carrier vocabulary. Generated/𝒢 remains a separate,
; witness-bearing relation. In particular, the mere presence of the force,
; disposition, reflexive, and recognition fields above does not claim that
; any such witness is inhabited for this movement.
(= (M255GeneratedFromSignature $signature $possibility)
   (generated-v1 $signature
     (r-star-witness (M255GenSigRelations $signature)
       used-and-counterfactually-discriminating)
     (a-star-witness (M255GenSigInterfaces $signature)
       fits-interface no-unwitnessed-constraint)
     (p-star-witness (M255GenSigDistinctions $signature)
       used-and-counterfactually-discriminating)
     (o-star-witness (index-atom $possibility 7) consequence-open)
     (l2425-witness (index-atom $possibility 8))))

(= (M255GeneratedWitness $signature $possibility)
   (M255GeneratedFromSignature $signature $possibility))

(= (M255GeneratedWitnessStructuralValid $witness $signature)
   (if (CPShape $witness generated-v1 7)
     (and (== (index-atom $witness 1) $signature)
      (and (== (index-atom $witness 2)
             (r-star-witness (M255GenSigRelations $signature)
               used-and-counterfactually-discriminating))
       (and (== (index-atom $witness 3)
              (a-star-witness (M255GenSigInterfaces $signature)
                fits-interface no-unwitnessed-constraint))
        (and (== (index-atom $witness 4)
               (p-star-witness (M255GenSigDistinctions $signature)
                 used-and-counterfactually-discriminating))
         (and (CPShape (index-atom $witness 5) o-star-witness 3)
              (CPShape (index-atom $witness 6) l2425-witness 2)))))) false))

(= (M255GeneratedWitnessValid $witness $signature $carrier $move-type
      $cut $facts $flourishing $possibility)
   (and (M255GenSigValid $signature $carrier $move-type $cut $facts
          $possibility)
    (and (== $witness (M255GeneratedWitness $signature $possibility))
     (and (M255GeneratedWitnessStructuralValid $witness $signature)
      (and (CPRelationsReady $cut $facts (index-atom $possibility 3))
       (and (CPDistinctionsReady $cut (index-atom $possibility 4))
        (and (CPInterfacesReady $cut (index-atom $possibility 5))
         (and (CPConsequenceReady (index-atom $possibility 7))
          (and (== (index-atom $possibility 8) l2425-supported)
           (and (CPShape $flourishing flourishing-organization 3)
                (== (size-atom (index-atom $flourishing 2)) 9)))))))))))

(= (M255IdentityMapAt $kind $ids $i)
   (if (< $i (size-atom $ids))
     (let $id (index-atom $ids $i)
       (cons-atom (gen-map $kind $id $id
          (load-bearing-correspondence preserved))
         (M255IdentityMapAt $kind $ids (+ $i 1)))) ()))

(= (M255MapIdsAt $maps $field $i)
   (if (< $i (size-atom $maps))
     (cons-atom (index-atom (index-atom $maps $i) $field)
       (M255MapIdsAt $maps $field (+ $i 1))) ()))

(= (M255MapRowsValidAt $maps $kind $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (and (CPShape $row gen-map 5)
        (and (== (index-atom $row 1) $kind)
         (and (== (index-atom $row 4)
                (load-bearing-correspondence preserved))
              (M255MapRowsValidAt $maps $kind (+ $i 1)))))) true))

(= (M255MapCoverageValid $map-set $kind $source-ids $target-ids)
   (if (CPShape $map-set gen-map-set 3)
     (let* (($maps (index-atom $map-set 2))
            ($sources (M255MapIdsAt $maps 2 0))
            ($targets (M255MapIdsAt $maps 3 0)))
       (and (== (index-atom $map-set 1) $kind)
        (and (is-expr $maps)
         (and (M255MapRowsValidAt $maps $kind 0)
          (and (CPUniq $sources 0 ())
           (and (CPUniq $targets 0 ())
            (and (M255AllIn $source-ids $sources 0)
             (and (M255AllIn $sources $source-ids 0)
              (and (M255AllIn $target-ids $targets 0)
                   (M255AllIn $targets $target-ids 0)))))))))) false))

(= (M255GenTranslation $source $target $source-generated $target-generated)
   (gen-translation-v2 $source $target $source-generated $target-generated
     (gen-map-set relation
       (M255IdentityMapAt relation (M255GenSigRelations $source) 0))
     (gen-map-set distinction
       (M255IdentityMapAt distinction (M255GenSigDistinctions $source) 0))
     (gen-map-set interface
       (M255IdentityMapAt interface (M255GenSigInterfaces $source) 0))
     (coverage bidirectional load-bearing no-unwitnessed-mapping)
     (constraint-transport bidirectional no-unwitnessed-constraint)
     (o-star-transport bidirectional (index-atom $source-generated 5)
       (index-atom $target-generated 5))
     (proto-time-compatible (index-atom $source 2) (index-atom $target 2))
     structural-equivalence-does-not-imply-same-becoming))

(= (M255GenTranslationMapsValid $translation $source $target)
   (and (M255MapCoverageValid (index-atom $translation 5) relation
          (M255GenSigRelations $source) (M255GenSigRelations $target))
    (and (M255MapCoverageValid (index-atom $translation 6) distinction
           (M255GenSigDistinctions $source) (M255GenSigDistinctions $target))
         (M255MapCoverageValid (index-atom $translation 7) interface
           (M255GenSigInterfaces $source) (M255GenSigInterfaces $target)))))

(= (M255GenTranslationContractsValid $translation $source $target
      $source-generated $target-generated)
   (and (== (index-atom $translation 8)
          (coverage bidirectional load-bearing no-unwitnessed-mapping))
    (and (== (index-atom $translation 9)
           (constraint-transport bidirectional no-unwitnessed-constraint))
     (and (== (index-atom $translation 10)
            (o-star-transport bidirectional
              (index-atom $source-generated 5)
              (index-atom $target-generated 5)))
      (and (== (index-atom $translation 11)
             (proto-time-compatible (index-atom $source 2)
               (index-atom $target 2)))
           (== (index-atom $translation 12)
             structural-equivalence-does-not-imply-same-becoming))))))

(= (M255GenTranslationValid $translation)
   (if (CPShape $translation gen-translation-v2 13)
     (let* (($source (index-atom $translation 1))
            ($target (index-atom $translation 2))
            ($source-generated (index-atom $translation 3))
            ($target-generated (index-atom $translation 4)))
       (and (M255GenSigStructuralValid $source)
       (and (M255GenSigStructuralValid $target)
         (and (M255GeneratedWitnessStructuralValid $source-generated $source)
          (and (M255GeneratedWitnessStructuralValid $target-generated $target)
           (and (M255GenTranslationMapsValid $translation $source $target)
                (M255GenTranslationContractsValid $translation $source $target
                  $source-generated $target-generated)))))))
     false))

(= (M255CrossCarrierTranslationValid $translation)
   (and (M255GenTranslationValid $translation)
        (!= (M255GenSigCarrier (index-atom $translation 1))
            (M255GenSigCarrier (index-atom $translation 2)))))

(= (M255GenEquivV2 $source $target $source-generated $target-generated)
   (let $translation (M255GenTranslation $source $target
                        $source-generated $target-generated)
     (if (M255GenTranslationValid $translation)
       (gen-equiv-v2 $source $target $translation
         structural-equivalence-not-carrier-identity)
       (gen-equiv-v2-unresolved missing-proof-relevant-translation))))

(= (M255GenEquivV2Valid $equivalence)
   (if (CPShape $equivalence gen-equiv-v2 5)
     (and (M255GenTranslationValid (index-atom $equivalence 3))
      (and (== (index-atom $equivalence 1)
             (index-atom (index-atom $equivalence 3) 1))
       (and (== (index-atom $equivalence 2)
              (index-atom (index-atom $equivalence 3) 2))
            (== (index-atom $equivalence 4)
              structural-equivalence-not-carrier-identity)))) false))

(= (M255CrossCarrierEquivV2Valid $equivalence)
   (and (M255GenEquivV2Valid $equivalence)
        (M255CrossCarrierTranslationValid (index-atom $equivalence 3))))

(= (M255ReverseMapRowsAt $maps $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (cons-atom (gen-map (index-atom $row 1) (index-atom $row 3)
          (index-atom $row 2) (index-atom $row 4))
         (M255ReverseMapRowsAt $maps (+ $i 1)))) ()))

(= (M255ReverseMapSet $map-set)
   (gen-map-set (index-atom $map-set 1)
     (M255ReverseMapRowsAt (index-atom $map-set 2) 0)))

(= (M255GenTranslationSymm $translation)
   (if (M255GenTranslationValid $translation)
     (let* (($source (index-atom $translation 1))
            ($target (index-atom $translation 2))
            ($source-generated (index-atom $translation 3))
            ($target-generated (index-atom $translation 4)))
       (gen-translation-v2 $target $source $target-generated $source-generated
         (M255ReverseMapSet (index-atom $translation 5))
         (M255ReverseMapSet (index-atom $translation 6))
         (M255ReverseMapSet (index-atom $translation 7))
         (coverage bidirectional load-bearing no-unwitnessed-mapping)
         (constraint-transport bidirectional no-unwitnessed-constraint)
         (o-star-transport bidirectional (index-atom $target-generated 5)
           (index-atom $source-generated 5))
         (proto-time-compatible (index-atom $target 2)
           (index-atom $source 2))
         structural-equivalence-does-not-imply-same-becoming))
     (gen-translation-v2-unresolved invalid-source-translation)))

(= (M255MapTargetAt $maps $kind $source-id $i)
   (if (< $i (size-atom $maps))
     (let $row (index-atom $maps $i)
       (if (and (== (index-atom $row 1) $kind)
                (== (index-atom $row 2) $source-id))
         (index-atom $row 3)
         (M255MapTargetAt $maps $kind $source-id (+ $i 1))))
     missing-load-bearing-map))

(= (M255ComposeMapRowsAt $left $right $kind $i)
   (if (< $i (size-atom $left))
     (let* (($row (index-atom $left $i))
            ($source-id (index-atom $row 2))
            ($middle-id (index-atom $row 3))
            ($target-id (M255MapTargetAt $right $kind $middle-id 0)))
       (cons-atom (gen-map $kind $source-id $target-id
          (load-bearing-correspondence preserved))
         (M255ComposeMapRowsAt $left $right $kind (+ $i 1)))) ()))

(= (M255ComposeMapSet $left $right $kind)
   (gen-map-set $kind
     (M255ComposeMapRowsAt (index-atom $left 2)
       (index-atom $right 2) $kind 0)))

(= (M255GenTranslationsComposable $left $right)
   (and (M255GenTranslationValid $left)
    (and (M255GenTranslationValid $right)
     (and (== (index-atom $left 2) (index-atom $right 1))
          (== (index-atom $left 4) (index-atom $right 3))))))

(= (M255GenTranslationTrans $left $right)
   (if (M255GenTranslationsComposable $left $right)
     (let* (($source (index-atom $left 1))
            ($target (index-atom $right 2))
            ($source-generated (index-atom $left 3))
            ($target-generated (index-atom $right 4)))
       (gen-translation-v2 $source $target $source-generated $target-generated
         (M255ComposeMapSet (index-atom $left 5)
           (index-atom $right 5) relation)
         (M255ComposeMapSet (index-atom $left 6)
           (index-atom $right 6) distinction)
         (M255ComposeMapSet (index-atom $left 7)
           (index-atom $right 7) interface)
         (coverage bidirectional load-bearing no-unwitnessed-mapping)
         (constraint-transport bidirectional no-unwitnessed-constraint)
         (o-star-transport bidirectional (index-atom $source-generated 5)
           (index-atom $target-generated 5))
         (proto-time-compatible (index-atom $source 2)
           (index-atom $target 2))
         structural-equivalence-does-not-imply-same-becoming))
     (gen-translation-v2-unresolved non-composable-domain)))

(= (M255GenEquivV2FromTranslation $translation)
   (if (M255GenTranslationValid $translation)
     (gen-equiv-v2 (index-atom $translation 1) (index-atom $translation 2)
       $translation structural-equivalence-not-carrier-identity)
     (gen-equiv-v2-unresolved missing-proof-relevant-translation)))

(= (M255TranslationLawWitness $translation)
   (let* (($symmetric (M255GenTranslationSymm $translation))
          ($source-refl (M255GenTranslation (index-atom $translation 1)
            (index-atom $translation 1) (index-atom $translation 3)
            (index-atom $translation 3)))
          ($target-refl (M255GenTranslation (index-atom $translation 2)
            (index-atom $translation 2) (index-atom $translation 4)
            (index-atom $translation 4)))
          ($source-roundtrip (M255GenTranslationTrans $translation $symmetric))
          ($target-roundtrip (M255GenTranslationTrans $symmetric $translation)))
     (gen-equiv-v2-laws-v1
       (bounded-domain (M255GenSigCarrier (index-atom $translation 1))
         (M255GenSigCarrier (index-atom $translation 2)))
       (reflexive-source (M255GenTranslationValid $source-refl))
       (reflexive-target (M255GenTranslationValid $target-refl))
       (symmetric (M255GenTranslationValid $symmetric))
       (transitive-source-roundtrip
         (M255GenTranslationValid $source-roundtrip))
       (transitive-target-roundtrip
         (M255GenTranslationValid $target-roundtrip))
       finite-domain-law-witness-not-universal-proof)))

(= (M255TranslationLawWitnessValid $translation $witness)
   (and (M255GenTranslationValid $translation)
    (and (== $witness (M255TranslationLawWitness $translation))
     (and (CPShape $witness gen-equiv-v2-laws-v1 8)
      (and (== (index-atom (index-atom $witness 2) 1) true)
       (and (== (index-atom (index-atom $witness 3) 1) true)
        (and (== (index-atom (index-atom $witness 4) 1) true)
         (and (== (index-atom (index-atom $witness 5) 1) true)
              (== (index-atom (index-atom $witness 6) 1) true)))))))))

(= (M255CarrierBundle $tag $carrier $move-type $cut $facts $possibility)
   (let* (($signature (M255CarrierGenSig $carrier $move-type $cut $facts
                        $possibility))
          ($generated (M255GeneratedFromSignature $signature $possibility)))
     (manifestation-carrier-v1 $tag $carrier $move-type $signature $generated)))

(= (M255CarrierBundleStructuralValid $bundle $tag $carrier $move-type
      $possibility)
   (if (CPShape $bundle manifestation-carrier-v1 6)
     (let* (($signature (index-atom $bundle 4))
            ($generated (index-atom $bundle 5)))
       (and (== (index-atom $bundle 1) $tag)
        (and (== (index-atom $bundle 2) $carrier)
         (and (== (index-atom $bundle 3) $move-type)
          (and (M255GenSigStructuralValid $signature)
           (and (== (M255GenSigCarrier $signature) $carrier)
            (and (== (index-atom (index-atom $signature 1) 3) $move-type)
             (and (== (index-atom $signature 3)
                    (move-vocabulary (index-atom $possibility 1)
                      (index-atom $possibility 2)))
                  (M255GeneratedWitnessStructuralValid $generated
                    $signature))))))))) false))

(= (M255CarrierMapRowsAt $kind $source-carrier $target-carrier $ids $i)
   (if (< $i (size-atom $ids))
     (let $id (index-atom $ids $i)
       (cons-atom
         (gen-map $kind (carrier-role $source-carrier $kind $id)
           (carrier-role $target-carrier $kind $id)
           (load-bearing-correspondence preserved))
         (M255CarrierMapRowsAt $kind $source-carrier $target-carrier
           $ids (+ $i 1)))) ()))

(= (M255CarrierMapSet $kind $source-carrier $target-carrier $ids)
   (gen-map-set $kind
     (M255CarrierMapRowsAt $kind $source-carrier $target-carrier $ids 0)))

(= (M255CarrierTranslation $source-bundle $target-bundle $possibility)
   (let* (($source-carrier (index-atom $source-bundle 2))
          ($target-carrier (index-atom $target-bundle 2))
          ($source (index-atom $source-bundle 4))
          ($target (index-atom $target-bundle 4))
          ($source-generated (index-atom $source-bundle 5))
          ($target-generated (index-atom $target-bundle 5)))
     (gen-translation-v2 $source $target $source-generated $target-generated
       (M255CarrierMapSet relation $source-carrier $target-carrier
         (index-atom $possibility 3))
       (M255CarrierMapSet distinction $source-carrier $target-carrier
         (index-atom $possibility 4))
       (M255CarrierMapSet interface $source-carrier $target-carrier
         (index-atom $possibility 5))
       (coverage bidirectional load-bearing no-unwitnessed-mapping)
       (constraint-transport bidirectional no-unwitnessed-constraint)
       (o-star-transport bidirectional (index-atom $source-generated 5)
         (index-atom $target-generated 5))
       (proto-time-compatible (index-atom $source 2) (index-atom $target 2))
       structural-equivalence-does-not-imply-same-becoming)))

(= (M255GenEquivV2Compact $translation)
   (gen-equiv-v2-compact-v1
     (source-carrier (M255GenSigCarrier (index-atom $translation 1)))
     (target-carrier (M255GenSigCarrier (index-atom $translation 2)))
     (index-atom $translation 5) (index-atom $translation 6)
     (index-atom $translation 7) (index-atom $translation 8)
     (index-atom $translation 9) (index-atom $translation 10)
     (index-atom $translation 11)
     structural-equivalence-not-carrier-identity-or-same-becoming))

(= (M255GenEquivV2CompactValid $certificate $translation)
   (and (M255CrossCarrierTranslationValid $translation)
        (== $certificate (M255GenEquivV2Compact $translation))))

(= (M255HubEquivalenceEvidence $source-bundle $hub-bundle $possibility)
   (let* (($translation (M255CarrierTranslation $source-bundle $hub-bundle
                          $possibility))
          ($equivalence (M255GenEquivV2Compact $translation))
          ($laws (M255TranslationLawWitness $translation)))
     (hub-equivalence-v1 (index-atom $source-bundle 1)
       (index-atom $hub-bundle 1) $equivalence $laws)))

(= (M255HubEquivalenceEvidenceValid $evidence $source-bundle $hub-bundle
      $possibility)
   (if (CPShape $evidence hub-equivalence-v1 5)
     (let* (($translation (M255CarrierTranslation $source-bundle $hub-bundle
                            $possibility))
            ($equivalence (index-atom $evidence 3))
            ($laws (index-atom $evidence 4)))
       (and (== (index-atom $evidence 1) (index-atom $source-bundle 1))
        (and (== (index-atom $evidence 2) (index-atom $hub-bundle 1))
         (and (== $equivalence (M255GenEquivV2Compact $translation))
          (and (M255GenEquivV2CompactValid $equivalence $translation)
               (M255TranslationLawWitnessValid $translation $laws)))))) false))

(= (M255FiveCarrierSuite $cut $facts $possibility)
   (let* (($ma (M255CarrierBundle MA m255-physical physical-movement
                 $cut $facts $possibility))
          ($mb (M255CarrierBundle MB m255-autopoietic autopoietic-movement
                 $cut $facts $possibility))
          ($mc (M255CarrierBundle MC m255-human-cognitive
                 human-cognitive-movement $cut $facts $possibility))
          ($md (M255CarrierBundle MD m255-miter-synthetic
                 synthetic-movement $cut $facts $possibility))
          ($me (M255CarrierBundle ME m255-multi-agent-inquiry
                 multi-agent-inquiry-movement $cut $facts $possibility)))
     (five-carrier-connected-suite-v1 $ma $mb $mc $md $me
       (human-cognitive-hub MC)
       (hub-equivalences
         (M255HubEquivalenceEvidence $ma $mc $possibility)
         (M255HubEquivalenceEvidence $mb $mc $possibility)
         (M255HubEquivalenceEvidence $md $mc $possibility)
         (M255HubEquivalenceEvidence $me $mc $possibility))
       one-generated-law-across-five-carriers
       finite-formal-projection-not-empirical-carrier-or-actuality-claim)))

(= (M255FiveCarrierSuiteStructuralValid $suite $possibility)
   (if (CPShape $suite five-carrier-connected-suite-v1 10)
     (let* (($ma (index-atom $suite 1))
            ($mb (index-atom $suite 2))
            ($mc (index-atom $suite 3))
            ($md (index-atom $suite 4))
            ($me (index-atom $suite 5))
            ($equivalences (index-atom $suite 7)))
       (and (M255CarrierBundleStructuralValid $ma MA m255-physical
              physical-movement $possibility)
        (and (M255CarrierBundleStructuralValid $mb MB m255-autopoietic
               autopoietic-movement $possibility)
         (and (M255CarrierBundleStructuralValid $mc MC m255-human-cognitive
                human-cognitive-movement $possibility)
          (and (M255CarrierBundleStructuralValid $md MD m255-miter-synthetic
                 synthetic-movement $possibility)
           (and (M255CarrierBundleStructuralValid $me ME
                  m255-multi-agent-inquiry multi-agent-inquiry-movement
                  $possibility)
            (and (== (index-atom $suite 6) (human-cognitive-hub MC))
             (and (CPShape $equivalences hub-equivalences 5)
              (and (M255HubEquivalenceEvidenceValid
                     (index-atom $equivalences 1) $ma $mc $possibility)
               (and (M255HubEquivalenceEvidenceValid
                      (index-atom $equivalences 2) $mb $mc $possibility)
                (and (M255HubEquivalenceEvidenceValid
                       (index-atom $equivalences 3) $md $mc $possibility)
                 (and (M255HubEquivalenceEvidenceValid
                        (index-atom $equivalences 4) $me $mc $possibility)
                  (and (== (index-atom $suite 8)
                         one-generated-law-across-five-carriers)
                       (== (index-atom $suite 9)
                         finite-formal-projection-not-empirical-carrier-or-actuality-claim))))))))))))))
     false))

!(import! &self "./src/generative_participation.metta")

(= (M255FiveCarrierSuiteReady $suite $cut $facts $flourishing $possibility)
   (and (== $suite (M255FiveCarrierSuite $cut $facts $possibility))
    (and (M255FiveCarrierSuiteStructuralValid $suite $possibility)
     (and (CPRelationsReady $cut $facts (index-atom $possibility 3))
      (and (CPDistinctionsReady $cut (index-atom $possibility 4))
       (and (CPInterfacesReady $cut (index-atom $possibility 5))
        (and (CPConsequenceReady (index-atom $possibility 7))
         (and (== (index-atom $possibility 8) l2425-supported)
          (and (CPShape $flourishing flourishing-organization 3)
               (== (size-atom (index-atom $flourishing 2)) 9))))))))))

(= (M255PrimaryCarrierBridge $cut $facts $flourishing $possibility)
   (let* (($source (M255GenSig miter-native-possibility possible-movement
                    $cut $facts $possibility))
          ($target (M255GenSig miter-primary-movement
                    m25-primary-movement-v2 $cut $facts $possibility))
          ($source-generated (M255GeneratedWitness $source $possibility))
          ($target-generated (M255GeneratedWitness $target $possibility))
          ($equivalence (M255GenEquivV2 $source $target
            $source-generated $target-generated))
          ($suite (M255FiveCarrierSuite $cut $facts $possibility))
          ($participation (M255FiveCarrierParticipationSuite $suite
            $possibility)))
     (if (and (M255GeneratedWitnessValid $source-generated $source
                miter-native-possibility possible-movement $cut $facts
                $flourishing $possibility)
          (and (M255GeneratedWitnessValid $target-generated $target
                 miter-primary-movement m25-primary-movement-v2 $cut $facts
                 $flourishing $possibility)
           (and (M255FiveCarrierSuiteReady $suite $cut $facts $flourishing
                  $possibility)
                (M255FiveCarrierParticipationSuiteValid $participation $suite
                  $possibility))))
       (primary-before-rap $equivalence $suite $participation)
       (primary-before-rap-unresolved missing-generated-signature))))

(= (M255PrimaryCarrierBridgeValid $bridge $possibility)
   (if (CPShape $bridge primary-before-rap 4)
     (let* (($equivalence (index-atom $bridge 1))
            ($suite (index-atom $bridge 2))
            ($participation (index-atom $bridge 3))
            ($source (if (CPShape $equivalence gen-equiv-v2 5)
              (index-atom $equivalence 1) ()))
            ($target (if (CPShape $equivalence gen-equiv-v2 5)
              (index-atom $equivalence 2) ())))
       (and (M255CrossCarrierEquivV2Valid $equivalence)
        (and (== (M255GenSigCarrier $source) miter-native-possibility)
         (and (== (M255GenSigCarrier $target) miter-primary-movement)
          (and (== (index-atom (index-atom $source 1) 3)
                 possible-movement)
           (and (== (index-atom (index-atom $target 1) 3)
                  m25-primary-movement-v2)
            (and (== (index-atom $source 3)
                   (move-vocabulary (index-atom $possibility 1)
                     (index-atom $possibility 2)))
             (and (== (index-atom $target 3)
                    (move-vocabulary (index-atom $possibility 1)
                      (index-atom $possibility 2)))
              (and (M255FiveCarrierSuiteStructuralValid $suite $possibility)
                   (M255FiveCarrierParticipationSuiteValid $participation
                     $suite $possibility)))))))))) false))
