; AMA-1.2 stable-scope admission at the native boundary.
; The Prolog membrane can establish exact carrier identity and configured scope;
; only native cognition admits the resulting contact and preserves the binding
; in developmental history. No surface identity supplies semantic movement.

(= (ACScopeBindingValid $binding $contact)
   (and (CPShape $binding scope-binding-v1 6)
     (and (CPShape (index-atom $binding 1) surface-route 6)
      (and (CPShape (index-atom $binding 2) scope 4)
       (and (CPShape (index-atom $binding 3) surface-event 4)
        (and (== (index-atom $binding 4) authorized-before-payload-cognition)
         (and (CPShape (index-atom $binding 5) binding-record 3)
          (and (== (index-atom $binding 2) (CPContactScope $contact))
               (== (index-atom (index-atom $binding 3) 1)
                   (index-atom $contact 1))))))))))
