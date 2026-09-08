; Native participation of the dedicated-user open growth environment.
; Availability is contact, not authority and not a selected tool action.

(= (C4CapabilityEnvironmentObservationValid $observation)
   (if (CPShape $observation capability-environment-observation-v1 10)
     (and (== (index-atom $observation 1)
            miter-open-growth-environment-v1)
      (and (CPShape (index-atom $observation 2) runtime-identity 4)
       (and (CPShape (index-atom $observation 3) workspace 3)
        (and (CPShape (index-atom $observation 4) informational-network 3)
         (and (CPShape (index-atom $observation 5) terminal 3)
          (and (CPShape (index-atom $observation 6) reversible-writes 3)
           (and (CPShape (index-atom $observation 7) credential-access 3)
            (and (CPShape (index-atom $observation 8)
                   human-authority-boundaries 7)
             (CPHas (index-atom $observation 9)
               (held-environment-disabled held-runtime-identity-mismatch
                 held-workspace-unavailable held-request-broker-unimplemented
                 available-open-growth-environment) 0)))))))))
     false))

(= (C4CapabilityEnvironmentStanding $observation)
   (if (C4CapabilityEnvironmentObservationValid $observation)
     (index-atom $observation 9)
     capability-environment-observation-invalid))

(= (C4CapabilityEnvironmentParticipants $contact $observation)
   (if (and (CPContactValid $contact)
            (C4CapabilityEnvironmentObservationValid $observation))
     (let* (($standing (C4CapabilityEnvironmentStanding $observation))
            ($available (== $standing available-open-growth-environment)))
       ((participant-contribution
          (c4-capability-environment-participation (index-atom $contact 1))
          tool (CPContactScope $contact)
          (lineage miter-open-growth-environment-v1
            mechanical-runtime-observation)
          (participant-relation-claim open-growth-environment-standing
            (if $available support unresolved)
            (capability-environment-evidence $observation))
          (if $available supported unresolved)
          no-contact-no-movement-authority)))
     ()))

(= (C4ContactWithCapabilityEnvironment $contact $participants)
   (if (> (size-atom $participants) 0)
     (CP2ContactWithAuthorityParticipants $contact $participants)
     $contact))
