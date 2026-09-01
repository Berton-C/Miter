; ============================================================
; nace_substrate.metta -- NACE in the AtomSpace
; ============================================================
; NACE = capability efficacy learning. When Clarity uses a skill, the outcome
; (worked / failed) revises her belief about that skill's efficacy. The belief
; is an stv truth value. Revision is NAL. This file does ALL of it in MeTTa.
;
; Python's only job: read this file in cycle N, write it back in cycle N+1.
; That is the store carried across iterations. No JSON. No Python arithmetic.
;
; Requires lib_nal (|-nal, Truth_Revision, Truth_Expectation), loaded via
; lib_omegaclaw's chain. Confirmed working in the live container.
; ============================================================


; ------------------------------------------------------------
; BELIEF STORE  (lives in nace_beliefs.metta, NOT here)
; ------------------------------------------------------------
; The (cap-efficacy <name> (stv f c)) atoms are in nace_beliefs.metta, the
; dynamic file the courier writes each cycle. This file holds DEFINITIONS ONLY
; and is never written by the courier. The courier loads BOTH files per call.


; ------------------------------------------------------------
; EVIDENCE  (what an outcome means, as a truth value)
; ------------------------------------------------------------
; A skill outcome becomes one evidence stv to revise the belief with.
; confirmed   -> (stv 1.0 0.1)  one positive observation, low confidence
; disconfirmed-> (stv 0.0 0.1)  one negative observation, low confidence
; The 0.1 confidence is "one data point"; revision accumulates it over cycles.

(= (evidence-stv confirmed)    (stv 1.0 0.1))
(= (evidence-stv disconfirmed) (stv 0.0 0.1))


; ------------------------------------------------------------
; READ  (current belief for a capability)
; ------------------------------------------------------------
; collapse-then-branch per C12 (no match inside if). Returns the stv, or the
; agnostic default if the capability has no atom yet.

(= (current-efficacy $cap)
   (let $result (collapse (match &self (cap-efficacy $cap $stv) $stv))
        (if (== $result ())
            (stv 0.5 0.0)
            (car-atom $result))))


; ------------------------------------------------------------
; REVISE  (the learning step -- this is the NACE computation)
; ------------------------------------------------------------
; Take a capability's current belief, revise it with an outcome's evidence.
; |-nal's revision rule (lib_nal.metta:108) is (|-nal ($T $T1) ($T $T2)) ->
; ($T (Truth_Revision $T1 $T2)). The revision math IS Truth_Revision. Calling
; Truth_Revision directly on the two stv values returns (stv f c) with no term
; wrapper to strip. This matches the generated revision-delta prior art, which
; binds (Truth_Revision ...) directly. Cognition still in the substrate.

(= (revise-efficacy $cap $outcome)
   (Truth_Revision (current-efficacy $cap) (evidence-stv $outcome)))


; ------------------------------------------------------------
; DECISION  (should this capability be dispatched?)
; ------------------------------------------------------------
; Truth_Expectation turns (f,c) into a single number for thresholding.
; Gate: dispatch only if expectation >= 0.3. Also via the substrate, not Python.

(= (efficacy-expectation $cap)
   (Truth_Expectation (current-efficacy $cap)))

(= (should-dispatch $cap)
   (if (>= (efficacy-expectation $cap) 0.3) True False))


; ------------------------------------------------------------
; WRITE-BACK HELPER  (produces the new belief atom to persist)
; ------------------------------------------------------------
; Python reads the result of this, replaces the old (cap-efficacy $cap ...) line
; in the file with the new one, writes the file. That file becomes cycle N+1's
; store. This is the only place Python touches: moving the atom text to disk.

(= (updated-belief-atom $cap $outcome)
   (let $revised (eval (revise-efficacy $cap $outcome))
        (cap-efficacy $cap $revised)))


; ============================================================
; THE CYCLE  (N -> N+1)
; ============================================================
; 1. Python reads this file (loads the cap-efficacy atoms into AtomSpace).
; 2. A skill runs; outcome is confirmed or disconfirmed.
; 3. Substrate computes: !(updated-belief-atom web-search confirmed)
;    -> (cap-efficacy web-search (stv <revised-f> <revised-c>))
; 4. Python replaces the matching line in this file with that atom. Writes file.
; 5. Next cycle reads the file: the revised belief is now the current belief.
;    The twist: this cycle's revised belief is next cycle's prior. Mobius.
;
; All arithmetic (revision, expectation) is |-nal / Truth_Revision /
; Truth_Expectation, in the substrate. Python reads and writes the file. Hands.
; ============================================================
