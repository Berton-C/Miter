;; lib_quantale.metta -- ClarityClaw Reasoning Extensions
;; Quantale composition (p-bit algebra) for paraconsistent truth values
;; Pattern: pure (= ...) definitions, no imports, no side effects
;; Agent invokes via: (metta "(q-mul (mk-pbit 0.8 0.9) (mk-pbit 0.7 0.85))")

;; === Core Type ===
(: pbit Type)
(: mk-pbit (-> Number Number pbit))

;; === Quantale Multiplication (sequential composition) ===
(: q-mul (-> pbit pbit pbit))
(= (q-mul (mk-pbit $s1 $c1) (mk-pbit $s2 $c2))
   (mk-pbit (* $s1 $s2) (min $c1 $c2)))

;; === Quantale Join (parallel composition) ===
(: q-join (-> pbit pbit pbit))
(= (q-join (mk-pbit $s1 $c1) (mk-pbit $s2 $c2))
   (mk-pbit (max $s1 $s2) (min $c1 $c2)))

;; === Quantale Meet (conjunction) ===
(: q-meet (-> pbit pbit pbit))
(= (q-meet (mk-pbit $s1 $c1) (mk-pbit $s2 $c2))
   (mk-pbit (min $s1 $s2) (min $c1 $c2)))

;; === Negation (paraconsistent) ===
(: q-neg (-> pbit pbit))
(= (q-neg (mk-pbit $s $c))
   (mk-pbit (- 1.0 $s) $c))

;; === Bridge: stv to pbit ===
(: stv-to-pbit (-> Atom pbit))
(= (stv-to-pbit (stv $s $c)) (mk-pbit $s $c))

;; === Bridge: pbit to stv ===
(: pbit-to-stv (-> pbit Atom))
(= (pbit-to-stv (mk-pbit $s $c)) (stv $s $c))

;; === Governance bridge: two stv inputs, q-meet as pbit ===
(: governance-pbit (-> Atom Atom pbit))
(= (governance-pbit (stv $s1 $c1) (stv $s2 $c2))
   (q-meet (mk-pbit $s1 $c1) (mk-pbit $s2 $c2)))

;; === Unit elements ===
(: q-top pbit)
(= q-top (mk-pbit 1.0 1.0))
(: q-bot pbit)
(= q-bot (mk-pbit 0.0 1.0))
(: q-unknown pbit)
(= q-unknown (mk-pbit 0.5 0.0))
