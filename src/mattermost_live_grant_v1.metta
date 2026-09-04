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

; P5 consumes a redacted observation only. Actual live identities remain in
; private local configuration until Berton selects and confirms the grant.
(= (G31IdentityResolutionValid $observation $candidateHash $transportHash)
 (if (PShape $observation g31-identity-resolution-observation 20)
  (and (== (index-atom $observation 1) $candidateHash)
   (and (== (index-atom $observation 2) $transportHash)
    (and (== (index-atom $observation 3) true)
     (and (== (index-atom $observation 4) true)
      (and (== (index-atom $observation 5) false)
       (and (== (index-atom $observation 6) false)
        (and (== (index-atom $observation 7) true)
         (and (== (index-atom $observation 8) true)
          (and (== (index-atom $observation 9) true)
           (and (== (index-atom $observation 10) true)
            (and (== (index-atom $observation 11) true)
             (and (== (index-atom $observation 12) true)
              (and (> (index-atom $observation 13) 0)
               (and (== (index-atom $observation 14) 0)
                (and (== (index-atom $observation 15) 0)
                 (and (== (index-atom $observation 16) 0)
                  (and (== (index-atom $observation 17) true)
                   (and (== (index-atom $observation 18) true)
                        (== (index-atom $observation 19) unresolved)))))))))))))))))))
  false))

(= (G31IdentityResolutionStanding $observation $candidateHash $transportHash)
 (if (G31IdentityResolutionValid $observation $candidateHash $transportHash)
  (g31-identity-resolution-complete-awaiting-human
   (candidate $candidateHash) (transport $transportHash)
   (human-candidate-count (index-atom $observation 13))
   (human-principal unresolved) (live-effects held))
  (g31-identity-resolution-held $candidateHash $transportHash $observation)))

; Principal identity selection is not live communication authority.
(= (G31PrincipalBindingValid $observation $candidateHash $transportHash $sourceHash)
 (if (PShape $observation g31-principal-binding-observation 15)
  (not (PHas false
   ((== (index-atom $observation 1) $candidateHash)
    (== (index-atom $observation 2) $transportHash)
    (== (index-atom $observation 3) $sourceHash)
    (== (index-atom $observation 4) true)
    (== (index-atom $observation 5) 1)
    (G31Present (index-atom $observation 6))
    (G31Present (index-atom $observation 7))
    (== (index-atom $observation 8) berton-explicit)
    (== (index-atom $observation 9) unresolved)
    (== (index-atom $observation 10) false)
    (== (index-atom $observation 11) 0)
    (== (index-atom $observation 12) 0)
    (== (index-atom $observation 13) 0)
    (== (index-atom $observation 14) true)) 0))
  false))

(= (G31PrincipalBindingStanding $observation $candidateHash $transportHash $sourceHash)
 (if (G31PrincipalBindingValid $observation $candidateHash $transportHash $sourceHash)
  (g31-human-principal-bound-awaiting-live-grant
   (candidate $candidateHash) (transport $transportHash)
   (source-identity $sourceHash)
   (human-principal-sha256 (index-atom $observation 7))
   (authority berton-explicit) (live-effect-approval unresolved)
   (live-effects held))
  (g31-human-principal-binding-held $candidateHash $transportHash $sourceHash)))

; P7 constructs a complete reviewable grant, but cannot approve or activate it.
(= (G31InactiveGrantV3 $candidateHash $transportHash $identityHash $bindingHash
     $serverHash $teamHash $allowHash $deniedHash $principalHash $botHash
     $p3Hash $p4Hash $p5Hash $p6Hash)
 (live-grant-v3
  $candidateHash
  (purpose bounded-local-mattermost-canary validate-ingress-voice-effect-restart-panic)
  (server-scope (private-identity-ref g31-server $serverHash) loopback-only)
  (team-scope (private-identity-ref g31-team $teamHash) exact)
  (allowlisted-channel (private-identity-ref g31-allow-channel $allowHash)
   cognition-eligible)
  (denied-control-channel (private-identity-ref g31-denied-channel $deniedHash)
   reject-before-cognition)
  (source-principal (private-identity-ref g31-human-principal $principalHash)
   sole-authorized-human)
  (outbound-bot (private-identity-ref g31-bot $botHash) sole-writer)
  (credential-capability macos-keychain bcb ai.bgi.miter.mattermost
   value-never-returned)
  (inbound-event-classes posted post-edited new-events-only)
  (inbound-content-exposure
   (allowlisted message-text thread-context exact-event-only)
   (denied-control transport-may-receive-frame identity-checked-first
    content-not-admitted-to-cognition))
  (outbound-effect-class create-post allowlisted-channel-only
   CertifiedUtterance-required idempotency-required)
  (canary-sequence
   (allowlisted-input "Miter G31 bounded live canary" first-new-post)
   (certified-response exactly-one)
   (restart bridge-and-native-state)
   (allowlisted-input "Miter G31 bounded live canary" second-new-post)
   (certified-response exactly-one old-effect-replay-zero)
   (denied-input "Miter G31 denied control" one-new-post)
   (denied-cognition zero denied-response zero)
   (panic local-fixed new-effects-zero))
  (memory-scope current-canary-contact-only prior-private-memory prohibited
   chroma-retrieval prohibited cross-principal prohibited)
  (voice-route certified-movement VoiceRNA required raw-model-output prohibited)
  (transport-qualified surface-transport-v1 $transportHash non-cognitive-prolog)
  (effect-reconciliation destination-specific
   same-key-result-lookup-or-dedup required universal-exactly-once unproven)
  (cursor-journal private-durable required fresh-process-readback required)
  (effect-journal private-durable pending-before-send confirmed-after-receipt
   unknown-outcome explicit)
  (lifecycle activation-after-separate-human-approval max-duration-minutes 30
   max-allowlisted-inputs 2 max-denied-inputs 1 max-outbound-effects 2)
  (ongoing-access none auto-stop-on-bounds-or-expiry)
  (panic local-fixed immediate-stop-new-effects state-preserved)
  (rollback stop-adapter restore-prior-registry history-preserved
   external-effects-not-undone)
  (revocation human-local immediate future-effects-prohibited)
  (source-evidence
   (identity-record $identityHash) (principal-binding $bindingHash)
   (p3-closure $p3Hash) (p4-closure $p4Hash)
   (p5-closure $p5Hash) (p6-closure $p6Hash))
  (principal-selection-authority berton-explicit $bindingHash)
  (live-effect-approval unresolved)))

(= (G31InactiveGrantValid $grant $candidateHash $transportHash $identityHash
     $bindingHash $serverHash $teamHash $allowHash $deniedHash $principalHash
     $botHash $p3Hash $p4Hash $p5Hash $p6Hash)
 (if (PShape $grant live-grant-v3 28)
  (not (PHas false
   ((== (index-atom $grant 1) $candidateHash)
    (== (index-atom $grant 2)
     (purpose bounded-local-mattermost-canary validate-ingress-voice-effect-restart-panic))
    (== (index-atom $grant 3)
     (server-scope (private-identity-ref g31-server $serverHash) loopback-only))
    (== (index-atom $grant 4)
     (team-scope (private-identity-ref g31-team $teamHash) exact))
    (== (index-atom $grant 5)
     (allowlisted-channel (private-identity-ref g31-allow-channel $allowHash)
      cognition-eligible))
    (== (index-atom $grant 6)
     (denied-control-channel (private-identity-ref g31-denied-channel $deniedHash)
      reject-before-cognition))
    (== (index-atom $grant 7)
     (source-principal (private-identity-ref g31-human-principal $principalHash)
      sole-authorized-human))
    (== (index-atom $grant 8)
     (outbound-bot (private-identity-ref g31-bot $botHash) sole-writer))
    (== (index-atom $grant 9)
     (credential-capability macos-keychain bcb ai.bgi.miter.mattermost
      value-never-returned))
    (== (index-atom $grant 10) (inbound-event-classes posted post-edited new-events-only))
    (== (index-atom $grant 11)
     (inbound-content-exposure
      (allowlisted message-text thread-context exact-event-only)
      (denied-control transport-may-receive-frame identity-checked-first
       content-not-admitted-to-cognition)))
    (== (index-atom $grant 12)
     (outbound-effect-class create-post allowlisted-channel-only
      CertifiedUtterance-required idempotency-required))
    (== (index-atom $grant 13)
     (canary-sequence
      (allowlisted-input "Miter G31 bounded live canary" first-new-post)
      (certified-response exactly-one)
      (restart bridge-and-native-state)
      (allowlisted-input "Miter G31 bounded live canary" second-new-post)
      (certified-response exactly-one old-effect-replay-zero)
      (denied-input "Miter G31 denied control" one-new-post)
      (denied-cognition zero denied-response zero)
      (panic local-fixed new-effects-zero)))
    (== (index-atom $grant 14)
     (memory-scope current-canary-contact-only prior-private-memory prohibited
      chroma-retrieval prohibited cross-principal prohibited))
    (== (index-atom $grant 15)
     (voice-route certified-movement VoiceRNA required raw-model-output prohibited))
    (== (index-atom $grant 16)
     (transport-qualified surface-transport-v1 $transportHash non-cognitive-prolog))
    (== (index-atom $grant 17)
     (effect-reconciliation destination-specific
      same-key-result-lookup-or-dedup required universal-exactly-once unproven))
    (== (index-atom $grant 18)
     (cursor-journal private-durable required fresh-process-readback required))
    (== (index-atom $grant 19)
     (effect-journal private-durable pending-before-send confirmed-after-receipt
      unknown-outcome explicit))
    (== (index-atom $grant 20)
     (lifecycle activation-after-separate-human-approval max-duration-minutes 30
      max-allowlisted-inputs 2 max-denied-inputs 1 max-outbound-effects 2))
    (== (index-atom $grant 21) (ongoing-access none auto-stop-on-bounds-or-expiry))
    (== (index-atom $grant 22)
     (panic local-fixed immediate-stop-new-effects state-preserved))
    (== (index-atom $grant 23)
     (rollback stop-adapter restore-prior-registry history-preserved
      external-effects-not-undone))
    (== (index-atom $grant 24)
     (revocation human-local immediate future-effects-prohibited))
    (== (index-atom $grant 25)
     (source-evidence
      (identity-record $identityHash) (principal-binding $bindingHash)
      (p3-closure $p3Hash) (p4-closure $p4Hash)
      (p5-closure $p5Hash) (p6-closure $p6Hash)))
    (== (index-atom $grant 26)
     (principal-selection-authority berton-explicit $bindingHash))
    (== (index-atom $grant 27) (live-effect-approval unresolved))) 0))
  false))

(= (G31InactiveGrantStanding $grant $candidateHash $transportHash $identityHash
     $bindingHash $serverHash $teamHash $allowHash $deniedHash $principalHash
     $botHash $p3Hash $p4Hash $p5Hash $p6Hash)
 (if (G31InactiveGrantValid $grant $candidateHash $transportHash $identityHash
      $bindingHash $serverHash $teamHash $allowHash $deniedHash $principalHash
      $botHash $p3Hash $p4Hash $p5Hash $p6Hash)
  (g31-inactive-live-grant-ready-for-human-review
   (candidate $candidateHash) (transport $transportHash)
   (identity-source $identityHash) (principal-binding $bindingHash)
   (live-effect-approval unresolved) (network-effects held))
  (g31-inactive-live-grant-held $candidateHash $transportHash)))

(= (G31Run $output $grant $candidateHash $expectedHash $g30Standing)
 (let $standing (G31DiscoveryStanding $candidateHash $expectedHash $g30Standing)
  (if (PShape $standing g31-read-only-discovery-ready 2)
   (let $inventory (g31_docker_inventory $output)
    (g31-preflight-result $standing
     (G31AssessGrant $grant $expectedHash $inventory)))
   (g31-preflight-result $standing not-executed))))
