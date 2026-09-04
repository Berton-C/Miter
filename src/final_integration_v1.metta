; G33 R14 compact evidence projection. These relations do not schedule work or
; decide behavior. They expose whether products already returned by the actual
; current consumers form the phase and causal structure frozen for acceptance.

(= (G33R14VoiceProof $result)
 (if (PShape $result voice-result 3)
  (let $certificate (index-atom $result 2)
   (if (and (PShape $certificate expression-certificate-v1 7)
            (== (index-atom $certificate 6) no-emission-authority))
    (voice-proof expression-certificate-v1 no-emission-authority
     (dh2_hash_native $certificate))
    (voice-proof-held (dh2_hash_native $certificate))))
  (voice-proof-held (dh2_hash_native $result))))

(= (G33R14ReadinessProof $product)
 (if (and (PShape $product readiness-observation 6)
          (and (== (index-atom $product 1) quiescent-ready)
               (and (== (index-atom $product 2) wake)
                    (== (index-atom $product 3) reactor-stopped))))
  (readiness-proof quiescent-ready wake reactor-stopped
   (index-atom $product 4) (index-atom $product 5) (dh2_hash_native $product))
  (readiness-proof-held (dh2_hash_native $product))))

(= (G33R14MattermostProof $trial $identity $panic $live)
 (if (and (PShape $trial g31-p3-candidate-qualified 7)
      (and (PShape $identity mattermost-identity-observation 6)
       (and (== (index-atom $identity 3) accepted)
        (and (PShape $panic mattermost-panic-observation 6)
         (and (PShape $live prior-live-witness 10)
              (== (index-atom $live 6) terminal-panic))))))
  (mattermost-proof (index-atom (index-atom $trial 1) 1)
   current-offline-trial current-stable-identity current-panic-containment
   prior-live-witness-only (dh2_hash_native $trial) (dh2_hash_native $live))
  (mattermost-proof-held (dh2_hash_native ($trial $identity $panic $live)))))

(= (G33R14FinalTrace $soul $continuity $voice $readiness $development $restart $mattermost)
 (if (and (== $soul true)
      (and (PShape $continuity continuity-proof 5)
       (and (== (index-atom $continuity 1) exact-continuity)
        (and (PShape $voice voice-proof 4)
         (and (PShape $readiness readiness-proof 7)
          (and (PShape $development development-helix-proof 5)
           (and (PShape $restart development-helix-v2-rehydrated 4)
                (PShape $mattermost mattermost-proof 8))))))))
  (g33-final-trace
   (phase soul (dh2_hash_native $soul))
   (phase continuity (dh2_hash_native $continuity))
   (phase voice (dh2_hash_native $voice))
   (phase readiness (dh2_hash_native $readiness))
   (phase development (dh2_hash_native $development))
   (phase restart (dh2_hash_native $restart))
   (phase mattermost (dh2_hash_native $mattermost))
   current-consumer-products prior-effects-not-replayed)
  (g33-final-trace-held (dh2_hash_native
   ($soul $continuity $voice $readiness $development $restart $mattermost)))))
