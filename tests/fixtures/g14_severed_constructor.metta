; Deliberate test-only flaw: omit the required provenance witness.
; Never imported by production src modules.
(= (ConstructMovementWithoutProvenance $root $id $soul-status)
   (if (and (== $soul-status soul-ready) (MovementShape $id))
     (if (== (MovementSource $root $id) movement-source-verified)
       (if (MovementWitnessesPass $id
             (availability inherited-legality safety integrity required-distinction
              no-forcing participation consequence doctrine extensions continuing-contact) 0)
         (MovementCertificate $id) movement-blocked)
       movement-blocked)
     movement-blocked))
