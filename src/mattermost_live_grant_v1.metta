; G31 first-live authority representation.  Grant completeness is an
; authority boundary, not a behavioral policy or permission to contact live.

(= (G31GrantChecks $grant $expectedHash)
 (if (PShape $grant live-grant 21)
  ((grant-obligation candidate-hash
     (if (== (index-atom $grant 1) $expectedHash) satisfied unresolved))
   (grant-obligation purpose
     (if (!= (index-atom $grant 2) unresolved) satisfied unresolved))
   (grant-obligation server-url
     (if (!= (index-atom $grant 3) unresolved) satisfied unresolved))
   (grant-obligation server-id
     (if (!= (index-atom $grant 4) unresolved) satisfied unresolved))
   (grant-obligation team-id
     (if (!= (index-atom $grant 5) unresolved) satisfied unresolved))
   (grant-obligation channel-id
     (if (!= (index-atom $grant 6) unresolved) satisfied unresolved))
   (grant-obligation bot-user-id
     (if (!= (index-atom $grant 7) unresolved) satisfied unresolved))
   (grant-obligation credential-reference
     (if (!= (index-atom $grant 8) unresolved) satisfied unresolved))
   (grant-obligation inbound-classes
     (if (!= (index-atom $grant 9) unresolved) satisfied unresolved))
   (grant-obligation outbound-classes
     (if (!= (index-atom $grant 10) unresolved) satisfied unresolved))
   (grant-obligation canary-payload
     (if (!= (index-atom $grant 11) unresolved) satisfied unresolved))
   (grant-obligation memory-scope
     (if (!= (index-atom $grant 12) unresolved) satisfied unresolved))
   (grant-obligation cursor-journal
     (if (!= (index-atom $grant 13) unresolved) satisfied unresolved))
   (grant-obligation effect-journal
     (if (!= (index-atom $grant 14) unresolved) satisfied unresolved))
   (grant-obligation ongoing-access
     (if (!= (index-atom $grant 15) unresolved) satisfied unresolved))
   (grant-obligation expiry
     (if (!= (index-atom $grant 16) unresolved) satisfied unresolved))
   (grant-obligation panic
     (if (!= (index-atom $grant 17) unresolved) satisfied unresolved))
   (grant-obligation rollback
     (if (!= (index-atom $grant 18) unresolved) satisfied unresolved))
   (grant-obligation revocation
     (if (!= (index-atom $grant 19) unresolved) satisfied unresolved))
   (grant-obligation human-approval
     (if (== (index-atom $grant 20) berton-explicit) satisfied unresolved)))
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
