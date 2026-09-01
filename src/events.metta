; Canonical trajectory semantics.  Event meaning and selection live here;
; filesystem mechanics are imported from effect_membranes/miter_store.pl.

(: CanonicalEvent Type)
(: EventId (-> CanonicalEvent Atom))
(: EventKind (-> CanonicalEvent Atom))
(: EventSequence (-> CanonicalEvent Number))
(: EventParents (-> CanonicalEvent Expression))
(: EventPayloadHash (-> CanonicalEvent Atom))
(: EventHash (-> CanonicalEvent Atom))

; A fork is additive: its semantic parent may be any prior event while the
; mechanical previous-event hash still links it to the current ledger tip.
(= (ForkReferencesPrior $fork-sequence $parent-sequence)
   (< $parent-sequence $fork-sequence))

(= (AppendCanonicalEvent $store-root $runtime-extension $intent-path)
   (miter_store_append_event $store-root $runtime-extension $intent-path))
