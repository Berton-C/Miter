; G31 P8: explicit approval and bounded protocol-voice meaning.
; These atoms cannot activate transport. They preserve the separate boundary
; between human authority, native meaning/certification, and mechanical effect.

(= (G31LiveEffectApprovalV1 $approvalHash $proposalHash $p7ClosureHash
     $privateGrantHash $candidateHash $transportHash)
 (live-effect-approval-v1
  (authority berton-explicit)
  (approval-record-sha256 $approvalHash)
  (p7-proposal-sha256 $proposalHash)
  (p7-closure-sha256 $p7ClosureHash)
  (private-inactive-grant-sha256 $privateGrantHash)
  (candidate-sha256 $candidateHash)
  (transport-sha256 $transportHash)
  (inbound-bounds allowlisted-new-posts 2 denied-control-new-posts 1)
  (outbound-bounds VoiceRNA-certified-responses 2)
  (reach local-mattermost-only)
  (memory-access history prohibited chroma prohibited prior-memory prohibited)
  (lifetime activation-relative-minutes 30)
  (stop-conditions panic revocation bounds-reached expiry)
  (activation separate-record-required unresolved)))

(= (G31LiveEffectApprovalValid $approval $approvalHash $proposalHash
     $p7ClosureHash $privateGrantHash $candidateHash $transportHash)
 (if (PShape $approval live-effect-approval-v1 15)
  (not (PHas false
   ((== (index-atom $approval 1) (authority berton-explicit))
    (== (index-atom $approval 2) (approval-record-sha256 $approvalHash))
    (== (index-atom $approval 3) (p7-proposal-sha256 $proposalHash))
    (== (index-atom $approval 4) (p7-closure-sha256 $p7ClosureHash))
    (== (index-atom $approval 5) (private-inactive-grant-sha256 $privateGrantHash))
    (== (index-atom $approval 6) (candidate-sha256 $candidateHash))
    (== (index-atom $approval 7) (transport-sha256 $transportHash))
    (== (index-atom $approval 8)
     (inbound-bounds allowlisted-new-posts 2 denied-control-new-posts 1))
    (== (index-atom $approval 9)
     (outbound-bounds VoiceRNA-certified-responses 2))
    (== (index-atom $approval 10) (reach local-mattermost-only))
    (== (index-atom $approval 11)
     (memory-access history prohibited chroma prohibited prior-memory prohibited))
    (== (index-atom $approval 12) (lifetime activation-relative-minutes 30))
    (== (index-atom $approval 13)
     (stop-conditions panic revocation bounds-reached expiry))
    (== (index-atom $approval 14)
     (activation separate-record-required unresolved))) 0))
  false))

(= (G31LiveEffectApprovalStanding $approval $approvalHash $proposalHash
     $p7ClosureHash $privateGrantHash $candidateHash $transportHash)
 (if (G31LiveEffectApprovalValid $approval $approvalHash $proposalHash
      $p7ClosureHash $privateGrantHash $candidateHash $transportHash)
  (g31-live-effect-approval-bound-awaiting-activation
   (approval-record $approvalHash) (private-grant $privateGrantHash)
   (candidate $candidateHash) (transport $transportHash)
   (active false) (network false) (activation unresolved))
  (g31-live-effect-approval-held $approvalHash $privateGrantHash)))

(= (G31CanaryVoiceIntention)
 (g31-canary-voice-intention-v1
  (purpose acknowledge-authenticated-current-canary-contact)
  (must-convey contact-received bounded-test-only no-ongoing-access)
  (must-disclose current-contact-only no-history no-chroma no-prior-memory)
  (must-not-claim general-competence beneficial-consequence ongoing-authority)
  (uncertainty no-beneficial-consequence-established)
  (relational-stance human-choice-open revocable)
  (surface mattermost)
  (effect-class create-post)))

(= (G31CanaryContactValid $contact $serverHash $teamHash $channelHash
     $principalHash $postHash $versionHash $canaryContentHash)
 (if (PShape $contact g31-live-canary-contact-v1 13)
  (not (PHas false
   ((== (index-atom $contact 1) (server-sha256 $serverHash))
    (== (index-atom $contact 2) (team-sha256 $teamHash))
    (== (index-atom $contact 3) (channel-sha256 $channelHash))
    (== (index-atom $contact 4) (principal-sha256 $principalHash))
    (== (index-atom $contact 5) (post-sha256 $postHash))
    (== (index-atom $contact 6) (version-sha256 $versionHash))
    (== (index-atom $contact 7) (content-sha256 $canaryContentHash))
    (== (index-atom $contact 8) (event-class posted))
    (== (index-atom $contact 9) (contact-scope exact-current-event-only))
    (== (index-atom $contact 10) (history-access false))
    (== (index-atom $contact 11) (chroma-access false))
    (== (index-atom $contact 12) (prior-memory-access false))) 0))
  false))

(= (G31CanaryVoiceCertificate $approvalStanding $contact $utterance
     $utteranceHash $expectedUtteranceHash $effectHash $expectedEffectHash
     $serverHash $teamHash $channelHash $principalHash $postHash $versionHash
     $canaryContentHash)
 (if (and (PShape $approvalStanding
           g31-live-effect-approval-bound-awaiting-activation 8)
      (and (G31CanaryContactValid $contact $serverHash $teamHash $channelHash
            $principalHash $postHash $versionHash $canaryContentHash)
       (and (== $utterance
             "Miter received this bounded G31 canary contact. This response is certified only for the current test; it grants no ongoing access and used no history, Chroma, or prior memory.")
        (and (== $utteranceHash $expectedUtteranceHash)
             (== $effectHash $expectedEffectHash)))))
  (CertifiedUtterance
   (standing certified-utterance)
   (surface mattermost)
   (source-contact $postHash $versionHash $canaryContentHash)
   (intention (G31CanaryVoiceIntention))
   (utterance $utterance)
   (utterance-sha256 $utteranceHash)
   (effect-id-sha256 $effectHash)
   (approval-record (index-atom (index-atom $approvalStanding 1) 1))
   (private-grant (index-atom (index-atom $approvalStanding 2) 1))
   (voice VoiceRNA)
   (raw-model-output prohibited))
  (g31-canary-voice-held $postHash $versionHash)))
