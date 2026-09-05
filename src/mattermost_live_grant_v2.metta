; AMA-1.2 R2 ratified multi-principal evaluation grant.
;
; This atom is authority and scope, not cognition.  It makes mechanical reach
; legible to the Soul while leaving encounter meaning, undertaking formation,
; movement, memory admission, expression, and consequence interpretation to
; native constitutive cognition.

(= (AMA12RatifiedGrantV2 $planHash $grantHash $configHash $modelHash
     $g31ClosureHash $candidateHash $transportHash)
 (ama12-live-grant-v2
  (authority-lineage
   (campaign-plan $planHash)
   (ratified-grant $grantHash)
   (public-config $configHash)
   (model-registry $modelHash)
   (g31-closure $g31ClosureHash)
   (candidate $candidateHash)
   (transport $transportHash))
  (standing ratified-by-berton activation-authorized-after-complete-preflight
   activation-inactive-until-durable-witness)
  (surface
   (mattermost "http://127.0.0.1:8065" loopback-only)
   (team clarityclaw exact-private-identity)
   (carrier exact-private-group-conversation
    exact-members berton_c haley miter)
   (denied-control miter-g31-denied reject-before-payload-cognition))
  (principals
   (authorized-humans berton_c haley)
   (outbound-bot miter)
   (stable-identities private-mode-0600-binding-only)
   (credential-ref macos-keychain bcb "ai.bgi.miter.mattermost"
    value-never-returned))
  (consent
   (berton affirmed-by-ratification)
   (haley affirmation-required-before-payload-cognition-memory-model-or-egress)
   (disclosure alpha durable-shared-memory local-model bounded-openrouter
    prohibited-private-data panic-revocation-correction-incomplete-erasure))
  (project-scope miter-evaluation-v1 berton-haley-shared-local
   principal-private-and-unrelated-isolated)
  (inbound posted post-edited new-events-only no-history-backfill
   bot-posts-not-contact denied-before-payload-cognition
   event-max-bytes 32768 root-max-bytes 65536)
  (continuity
   (canonical-planes append-only-trajectory exact-capsules raw-artifacts
    admitted-relational-and-semantic-memory)
   (retention durable-no-age-expiry
    explicit-authorized-erasure-repair-or-migration-only)
   (correction additive-supersession-with-lineage)
   (projections rebuildable-chroma temporary-model-context tiered-summary)
   (thirty-day-event continuity-and-privacy-audit-no-implied-deletion))
  (semantic-memory miter-ltm-v1 exact-scope-filtered
   native-admission-required vector-rank-no-authority
   other-collections-prohibited canonical-source-rebuildable)
  (model-participation
   (authorized openrouter-glm53 qwen-local nemotron-local soul-choice)
   (initial-human-preference openrouter-glm53)
   (human-directions one-call conversation undertaking until-time clearable)
   (most-specific-current-authenticated-direction-controls-participant)
   (conflicting-direction explicit-authority-contact-tension)
   (returned-standing candidate-participant no-contact-authority
    no-soul-authority no-movement-authority no-memory-admission-authority
    no-effect-authority))
  (remote-disclosure
   both-participants-affirmed minimum-source-bound-shared-subset-only
   credentials-prohibited private-stable-ids-prohibited
   principal-private-memory-prohibited unrelated-projects-prohibited
   other-channel-content-prohibited secret-bearing-content-prohibited)
  (voice-effect mattermost-create-post exact-shared-carrier-only
   current-native-movement-required VoiceRNA-certified-utterance-required
   raw-model-output-prohibited)
  (effect-reconciliation stable-effect-id pending-post-id
   durable-pending-before-send confirmed-or-unknown-after-observation
   unknown-hold-and-reconcile never-blind-resend)
  (resource-window first-segment-hours 72 maximum-hours 168
   continuation-requires-joint-berton-haley-checkpoint
   admitted-events 1000 outbound-posts 500 outbound-per-hour 60
   remote-calls 50)
  (forensic-lifecycle automatic-pause-at-72-hours checkpoint-before-continuation
   mandatory-final-closure no-self-renewal-or-self-certification)
  (persistence explicit-absolute-runtime-root private-directory-mode 0700
   private-file-mode 0600 repository-write-prohibited
   arbitrary-home-write-prohibited no-dot-miter)
  (containment fixed-local-panic either-human-revocation
   crash-loop-three-in-sixty last-known-good-rollback history-preserved
   pending-effect-reconcile-before-future-send)
  (authority-separation
   grant-bounds-reach-not-meaning
   human-model-direction-selects-participant-not-cognition
   transport-model-vector-rank-consent-counter-host-branch-no-cognitive-authority)
  (activation-preconditions exact-private-binding haley-disclosure-affirmed
   implementation-integrity private-file-modes service-health panic-health
   no-unresolved-prior-effect restart-no-replay supported-constitutive-route)
  (activation held-until-durable-witness)))

(= (AMA12RatifiedGrantValid $grant $planHash $grantHash $configHash $modelHash
     $g31ClosureHash $candidateHash $transportHash)
 (== $grant
  (AMA12RatifiedGrantV2 $planHash $grantHash $configHash $modelHash
   $g31ClosureHash $candidateHash $transportHash)))

(= (AMA12RatifiedGrantStanding $grant $planHash $grantHash $configHash
     $modelHash $g31ClosureHash $candidateHash $transportHash)
 (if (AMA12RatifiedGrantValid $grant $planHash $grantHash $configHash
      $modelHash $g31ClosureHash $candidateHash $transportHash)
  (ama12-ratified-grant-ready-for-private-binding-and-preflight
   (grant $grantHash) (berton-consent affirmed)
   (haley-consent unresolved) (activation held))
  (ama12-ratified-grant-held source-scope-or-authority-mismatch)))

; Stable identity resolution is mechanical evidence only.  Payload cognition,
; memory, model use, and egress remain held until the second human's disclosure
; affirmation is separately witnessed.
(= (AMA12IdentityStanding $observation $candidateHash $transportHash)
 (if (== $observation
      (ama12-identity-observation $candidateHash $transportHash
       server-resolved team-resolved group-resolved exact-three-members
       bot-resolved berton-resolved haley-resolved denied-control-resolved
       unique-group-count 1 post-content-reads 0 message-writes 0 api-mutations 0))
  (ama12-private-identity-bound
   (candidate $candidateHash) (transport $transportHash)
   (haley-disclosure unresolved) (ordinary-cognition held)
   (memory-admission held) (model-use held) (egress held))
  (ama12-private-identity-held identity-or-scope-mismatch)))
