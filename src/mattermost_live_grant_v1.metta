; G31 corrected first-live authority representation. Grant completeness is an
; authority boundary, not a behavioral policy or permission to contact live.

(= (G31Present $value) (!= $value unresolved))

(= (G31SourceUsersValid $sourceUsers $botUser)
 (if (PShape $sourceUsers source-users 2)
  (let $users (index-atom $sourceUsers 1)
   (and (is-expr $users)
    (and (> (size-atom $users) 0)
         (not (PHas $botUser $users 0))))) false))

(= (G31CredentialValid $reference $botUser)
 (if (PShape $reference credential-ref 5)
  (and (== (index-atom $reference 1) macos-keychain)
   (and (G31Present (index-atom $reference 2))
    (and (G31Present (index-atom $reference 3))
         (== (index-atom $reference 4) $botUser)))) false))

(= (G31VoiceRouteValid $route)
 (== $route (voice-route certified-movement VoiceRNA required)))

(= (G31TransportValid $transport)
 (if (PShape $transport transport-qualified 4)
  (and (G31Present (index-atom $transport 1))
   (and (G31Present (index-atom $transport 2))
        (== (index-atom $transport 3) non-cognitive-prolog))) false))

(= (G31ReconciliationValid $reconciliation)
 (== $reconciliation
  (effect-reconciliation destination-specific
   same-key-result-lookup-or-dedup required)))

; live-grant-v2 fields: candidate, purpose, server URL/ID, team, channel,
; inbound source users, outbound bot, credential ref, event classes, canary,
; memory scope, voice, transport, reconciliation, journals, access, expiry,
; panic, rollback, revocation, and explicit human approval.
(= (G31GrantChecks $grant $expectedHash)
 (if (PShape $grant live-grant-v2 25)
  ((grant-obligation candidate-hash
     (if (== (index-atom $grant 1) $expectedHash) satisfied unresolved))
   (grant-obligation purpose
     (if (G31Present (index-atom $grant 2)) satisfied unresolved))
   (grant-obligation server-url
     (if (G31Present (index-atom $grant 3)) satisfied unresolved))
   (grant-obligation server-id
     (if (G31Present (index-atom $grant 4)) satisfied unresolved))
   (grant-obligation team-id
     (if (G31Present (index-atom $grant 5)) satisfied unresolved))
   (grant-obligation channel-id
     (if (G31Present (index-atom $grant 6)) satisfied unresolved))
   (grant-obligation authorized-source-users
     (if (G31SourceUsersValid (index-atom $grant 7)
                              (index-atom $grant 8)) satisfied unresolved))
   (grant-obligation outbound-bot-user-id
     (if (G31Present (index-atom $grant 8)) satisfied unresolved))
   (grant-obligation credential-reference
     (if (G31CredentialValid (index-atom $grant 9)
                             (index-atom $grant 8)) satisfied unresolved))
   (grant-obligation inbound-classes
     (if (G31Present (index-atom $grant 10)) satisfied unresolved))
   (grant-obligation outbound-classes
     (if (G31Present (index-atom $grant 11)) satisfied unresolved))
   (grant-obligation canary-payload
     (if (G31Present (index-atom $grant 12)) satisfied unresolved))
   (grant-obligation memory-scope
     (if (G31Present (index-atom $grant 13)) satisfied unresolved))
   (grant-obligation voice-certificate-route
     (if (G31VoiceRouteValid (index-atom $grant 14)) satisfied unresolved))
   (grant-obligation qualified-transport
     (if (G31TransportValid (index-atom $grant 15)) satisfied unresolved))
   (grant-obligation effect-reconciliation
     (if (G31ReconciliationValid (index-atom $grant 16)) satisfied unresolved))
   (grant-obligation cursor-journal
     (if (G31Present (index-atom $grant 17)) satisfied unresolved))
   (grant-obligation effect-journal
     (if (G31Present (index-atom $grant 18)) satisfied unresolved))
   (grant-obligation ongoing-access
     (if (G31Present (index-atom $grant 19)) satisfied unresolved))
   (grant-obligation expiry
     (if (G31Present (index-atom $grant 20)) satisfied unresolved))
   (grant-obligation panic
     (if (G31Present (index-atom $grant 21)) satisfied unresolved))
   (grant-obligation rollback
     (if (G31Present (index-atom $grant 22)) satisfied unresolved))
   (grant-obligation revocation
     (if (G31Present (index-atom $grant 23)) satisfied unresolved))
   (grant-obligation human-approval
     (if (== (index-atom $grant 24) berton-explicit) satisfied unresolved)))
  ((grant-obligation grant-shape unresolved))))

(= (G31GrantReady $checks)
 (not (PHas unresolved
  (collapse (let $check (superpose $checks) (index-atom $check 2))) 0)))

(= (G31Missing $checks)
 (collapse (let $check (superpose $checks)
  (if (== (index-atom $check 2) unresolved)
   (index-atom $check 1) (empty)))))

(= (G31AssessGrant $grant $expectedHash $inventory)
 (let $checks (G31GrantChecks $grant $expectedHash)
  (if (G31GrantReady $checks)
   (g31-live-preflight-ready $grant $checks $inventory)
   (g31-live-preflight-held (G31Missing $checks) $checks $inventory))))

(= (G31DiscoveryStanding $candidateHash $expectedHash $g30Standing)
 (if (and (== $candidateHash $expectedHash)
          (== $g30Standing G30-PASS-BOUNDED))
  (g31-read-only-discovery-ready $candidateHash)
  (g31-read-only-discovery-held $candidateHash $expectedHash $g30Standing)))

(= (G31Run $output $grant $candidateHash $expectedHash $g30Standing)
 (let $standing (G31DiscoveryStanding $candidateHash $expectedHash $g30Standing)
  (if (PShape $standing g31-read-only-discovery-ready 2)
   (let $inventory (g31_docker_inventory $output)
    (g31-preflight-result $standing
     (G31AssessGrant $grant $expectedHash $inventory)))
   (g31-preflight-result $standing not-executed))))
