;; VAD Routing Substrate - MeTTa is the workspace
;; Python harness discretizes text to VAD atoms, feeds here
;; MeTTa deduces strategy via NAL inheritance chains

;; Strategy profiles: VAD -> strategy-name
(= (vad-route negative-valence high-arousal low-dominance) (empathic-attunement (stv 0.9 0.9)))
(= (vad-route negative-valence high-arousal mid-dominance) (empathic-attunement (stv 0.85 0.88)))
(= (vad-route mid-valence low-arousal mid-dominance) (gentle-activation (stv 0.88 0.9)))
(= (vad-route positive-valence mid-arousal high-dominance) (collaborative-exploration (stv 0.9 0.9)))
(= (vad-route positive-valence high-arousal high-dominance) (witnessing-celebration (stv 0.92 0.9)))
(= (vad-route mid-valence mid-arousal mid-dominance) (grounding-presence (stv 0.85 0.88)))

;; Strategy actions
(= (strategy-action empathic-attunement) prioritize-validation-lower-thresholds)
(= (strategy-action grounding-presence) steady-pacing-concrete-examples)
(= (strategy-action collaborative-exploration) open-ended-reasoning-co-build)
(= (strategy-action witnessing-celebration) amplify-momentum-raise-challenge)
(= (strategy-action gentle-activation) small-prompts-increase-warmth)
