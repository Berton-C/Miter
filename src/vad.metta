; Bounded VAD participation for the one C4 encounter.
;
; Prolog verifies the private licensed asset and performs exact lexical lookup.
; Native MeTTa owns coverage, clause profiles, within-contact trajectory and the
; attributable participant relation.  The cue is about language use only: it
; cannot diagnose a person, classify SNS/PNS, authorize action, select a
; movement, or substitute for the nine flourishings and one R/A/P read.

(= (C4VADTextParticipantsAt $participants $i)
   (if (< $i (size-atom $participants))
     (let $participant (index-atom $participants $i)
       (if (and (CPShape $participant participant-contribution 8)
             (and (== (index-atom $participant 2) human)
                  (CPShape (index-atom $participant 5)
                    participant-text-claim 5)))
         (cons-atom $participant
           (C4VADTextParticipantsAt $participants (+ $i 1)))
         (C4VADTextParticipantsAt $participants (+ $i 1))))
     ()))

(= (C4VADExactTextParticipant $contact)
   (let $rows (C4VADTextParticipantsAt (CPParticipants $contact) 0)
     (if (== (size-atom $rows) 1)
       (index-atom $rows 0)
       (c4-vad-text-participant-unavailable expected-exactly-one))))

(= (C4VADIdentityBasis $contact-id $text-sha256 $asset-sha256)
   (vad-language-cue-v1 $contact-id $text-sha256 $asset-sha256))

(= (C4VADRequestDescriptor $contact)
   (if (CPContactValid $contact)
     (let* (($participant (C4VADExactTextParticipant $contact))
            ($claim (if (CPShape $participant participant-contribution 8)
              (index-atom $participant 5) ()))
            ($text-sha256 (if (CPShape $claim participant-text-claim 5)
              (index-atom $claim 1) unknown-text-sha256))
            ($cue-id (as_native_id c4-vad-cue
              (C4VADIdentityBasis (index-atom $contact 1) $text-sha256
                42c718817fc91d5c133581b24b0bb31d2b14a0b16edb19bc6ce6ab70343e5a45))))
       (if (CPShape $claim participant-text-claim 5)
         (vad-language-request-v1 $cue-id (CPContactScope $contact)
           (source-contact (index-atom $contact 1))
           (exact-contact-text $text-sha256 (index-atom $claim 2))
           (asset NRC-VAD-2.1
             42c718817fc91d5c133581b24b0bb31d2b14a0b16edb19bc6ce6ab70343e5a45)
           (limits (maximum-text-characters 32768)
             (maximum-clauses 32) (maximum-tokens 4096)
             (maximum-ngram-tokens 3))
           lexical-cue-request-no-person-state-or-movement-authority)
         (vad-language-request-unavailable missing-exact-contact-text)))
     (vad-language-request-unavailable malformed-contact)))

(= (C4VADRequestDescriptorValid $descriptor $contact)
   (and (CPShape $descriptor vad-language-request-v1 8)
        (== $descriptor (C4VADRequestDescriptor $contact))))

(= (C4VADClauseMeasureValid $row)
   (if (CPShape $row vad-clause-measure-v1 6)
     ; Repeat these four bounded projections: the pinned PeTTa compiler does
     ; not reliably lower a first local numeric binding in this validator.
     ; This is validation only; no value is inferred or reconstructed.
     (and (>= (index-atom $row 1) 0)
      (and (CPShape (index-atom $row 2) token-count 2)
       (and (CPShape (index-atom $row 3) covered-token-count 2)
        (and (CPShape (index-atom $row 4) matched-expression-count 2)
         (and (CPShape (index-atom $row 5) axis-sums 4)
          (and (> (index-atom (index-atom $row 2) 1) 0)
           (and (>= (index-atom (index-atom $row 3) 1) 0)
            (and (<= (index-atom (index-atom $row 3) 1)
                     (index-atom (index-atom $row 2) 1))
                 (>= (index-atom (index-atom $row 4) 1) 0)))))))))
     false))

(= (C4VADClauseMeasuresValidAt $rows $i)
   (if (< $i (size-atom $rows))
     (and (C4VADClauseMeasureValid (index-atom $rows $i))
      (and (== (index-atom (index-atom $rows $i) 1) $i)
           (C4VADClauseMeasuresValidAt $rows (+ $i 1))))
     true))

(= (C4VADSumClauseMetricAt $rows $row-index $metric-index $acc)
   (if (< $row-index (size-atom $rows))
     (C4VADSumClauseMetricAt $rows (+ $row-index 1) $metric-index
       (+ $acc (index-atom
         (index-atom (index-atom $rows $row-index) $metric-index) 1)))
     $acc))

(= (C4VADObservationValid $observation $descriptor)
   (if (and (CPShape $observation vad-mechanical-observation-v1 9)
            (CPShape $descriptor vad-language-request-v1 8))
     (let* (($rows-wrapper (index-atom $observation 5))
            ($rows (if (CPShape $rows-wrapper clauses 2)
              (index-atom $rows-wrapper 1) ()))
            ($coverage (index-atom $observation 6))
            ($tokens (if (CPShape $coverage coverage 4)
              (index-atom (index-atom $coverage 1) 1) -1))
            ($covered (if (CPShape $coverage coverage 4)
              (index-atom (index-atom $coverage 2) 1) -1))
            ($matches (if (CPShape $coverage coverage 4)
              (index-atom (index-atom $coverage 3) 1) -1)))
       (==
         ((== (index-atom $observation 1) (index-atom $descriptor 1))
          (== (index-atom $observation 2) (index-atom $descriptor 2))
          (== (index-atom $observation 3)
            (source-contact (index-atom (index-atom $descriptor 3) 1)
              (text-sha256
                (index-atom (index-atom $descriptor 4) 1))))
          (== (index-atom $observation 4)
            (asset (index-atom (index-atom $descriptor 5) 1)
              (index-atom (index-atom $descriptor 5) 2)
              private-read-only-checksum-verified))
          (> (size-atom $rows) 0)
          (<= (size-atom $rows) 32)
          (C4VADClauseMeasuresValidAt $rows 0)
          (CPShape $coverage coverage 4)
          (== $tokens (C4VADSumClauseMetricAt $rows 0 2 0))
          (== $covered (C4VADSumClauseMetricAt $rows 0 3 0))
          (== $matches (C4VADSumClauseMetricAt $rows 0 4 0))
          (CPShape (index-atom $observation 7) limitations 7)
          (== (index-atom $observation 8)
            mechanical-cue-no-meaning-movement-or-effect-authority))
         (true true true true true true true true true true true true true)))
     false))

(= (C4VADClauseAxisMean $row $axis-index)
   (let $matches (index-atom (index-atom $row 4) 1)
     (if (> $matches 0)
       (/ (index-atom (index-atom $row 5) $axis-index) $matches)
       unresolved)))

(= (C4VADClauseReading $row)
   (vad-clause-reading-v1 (index-atom $row 1)
     (index-atom $row 2) (index-atom $row 3) (index-atom $row 4)
     (axis-means
       (valence (C4VADClauseAxisMean $row 1))
       (arousal (C4VADClauseAxisMean $row 2))
       (dominance (C4VADClauseAxisMean $row 3)))))

(= (C4VADClauseReadingsAt $rows $i)
   (if (< $i (size-atom $rows))
     (cons-atom (C4VADClauseReading (index-atom $rows $i))
       (C4VADClauseReadingsAt $rows (+ $i 1)))
     ()))

(= (C4VADFirstCoveredAt $rows $i)
   (if (< $i (size-atom $rows))
     (if (> (index-atom (index-atom (index-atom $rows $i) 4) 1) 0)
       (index-atom $rows $i) (C4VADFirstCoveredAt $rows (+ $i 1)))
     ()))

(= (C4VADLastCoveredAt $rows $i $last)
   (if (< $i (size-atom $rows))
     (C4VADLastCoveredAt $rows (+ $i 1)
       (if (> (index-atom (index-atom (index-atom $rows $i) 4) 1) 0)
         (index-atom $rows $i) $last))
     $last))

(= (C4VADAxisDelta $first $last $axis-index)
   (- (C4VADClauseAxisMean $last $axis-index)
      (C4VADClauseAxisMean $first $axis-index)))

(= (C4VADTrajectory $rows)
   (let* (($first (C4VADFirstCoveredAt $rows 0))
          ($last (C4VADLastCoveredAt $rows 0 ())))
     (if (and (C4VADClauseMeasureValid $first)
              (C4VADClauseMeasureValid $last))
       (if (!= (index-atom $first 1) (index-atom $last 1))
         (within-contact-trajectory-v1
           (from-clause (index-atom $first 1))
           (to-clause (index-atom $last 1))
           (axis-delta
             (valence (C4VADAxisDelta $first $last 1))
             (arousal (C4VADAxisDelta $first $last 2))
             (dominance (C4VADAxisDelta $first $last 3)))
           numeric-language-cue-no-direction-or-person-state-verdict)
         (within-contact-trajectory-unresolved single-covered-clause))
       (within-contact-trajectory-unresolved no-covered-clause))))

(= (C4VADCue $observation $descriptor)
   (if (C4VADObservationValid $observation $descriptor)
     (let* (($rows (index-atom (index-atom $observation 5) 1))
            ($coverage (index-atom $observation 6))
            ($tokens (index-atom (index-atom $coverage 1) 1))
            ($covered (index-atom (index-atom $coverage 2) 1)))
       (vad-language-cue-v1 (index-atom $observation 1)
         (index-atom $observation 2) (index-atom $observation 3)
         (index-atom $observation 4)
         (coverage-ratio (if (> $tokens 0) (/ $covered $tokens) 0))
         (clause-readings (C4VADClauseReadingsAt $rows 0))
         (C4VADTrajectory $rows)
         (index-atom $observation 7)
         cue-not-person-state-not-permission-not-movement-authority))
     (vad-language-cue-unavailable invalid-mechanical-observation)))

(= (C4VADClauseReadingValid $row)
   (if (CPShape $row vad-clause-reading-v1 6)
     (let $axes (index-atom $row 5)
       (==
         ((CPShape (index-atom $row 2) token-count 2)
          (CPShape (index-atom $row 3) covered-token-count 2)
          (CPShape (index-atom $row 4) matched-expression-count 2)
          (CPShape $axes axis-means 4)
          (CPShape (index-atom $axes 1) valence 2)
          (CPShape (index-atom $axes 2) arousal 2)
          (CPShape (index-atom $axes 3) dominance 2))
         (true true true true true true true)))
     false))

(= (C4VADClauseReadingsValidAt $rows $i)
   (if (< $i (size-atom $rows))
     (if (C4VADClauseReadingValid (index-atom $rows $i))
       (if (== (index-atom (index-atom $rows $i) 1) $i)
         (C4VADClauseReadingsValidAt $rows (+ $i 1)) false)
       false)
     true))

(= (C4VADTrajectoryValid $trajectory)
   (if (CPShape $trajectory within-contact-trajectory-unresolved 2)
     (CPHas (index-atom $trajectory 1)
       (single-covered-clause no-covered-clause) 0)
     (if (CPShape $trajectory within-contact-trajectory-v1 5)
       (==
         ((CPShape (index-atom $trajectory 1) from-clause 2)
          (CPShape (index-atom $trajectory 2) to-clause 2)
          (CPShape (index-atom $trajectory 3) axis-delta 4)
          (CPShape (index-atom (index-atom $trajectory 3) 1) valence 2)
          (CPShape (index-atom (index-atom $trajectory 3) 2) arousal 2)
          (CPShape (index-atom (index-atom $trajectory 3) 3) dominance 2)
          (== (index-atom $trajectory 4)
            numeric-language-cue-no-direction-or-person-state-verdict))
         (true true true true true true true))
       false)))

(= (C4VADLanguageCueValid $cue)
   (if (CPShape $cue vad-language-cue-v1 10)
     (let $readings-wrapper (index-atom $cue 6)
       (==
         ((CPShape (index-atom $cue 2) scope 4)
          (CPShape (index-atom $cue 3) source-contact 3)
          (CPShape (index-atom (index-atom $cue 3) 2) text-sha256 2)
          (== (index-atom $cue 4)
            (asset NRC-VAD-2.1
              42c718817fc91d5c133581b24b0bb31d2b14a0b16edb19bc6ce6ab70343e5a45
              private-read-only-checksum-verified))
          (CPShape (index-atom $cue 5) coverage-ratio 2)
          (CPShape $readings-wrapper clause-readings 2)
          (> (size-atom (index-atom $readings-wrapper 1)) 0)
          (C4VADClauseReadingsValidAt
            (index-atom $readings-wrapper 1) 0)
          (C4VADTrajectoryValid (index-atom $cue 7))
          (== (index-atom $cue 8)
            (limitations lexical-association-only no-person-state-claim
              no-sns-pns-classification no-permission-effect
              exact-matching-only negation-irony-and-context-unresolved))
          (== (index-atom $cue 9)
            cue-not-person-state-not-permission-not-movement-authority))
         (true true true true true true true true true true true)))
     false))

(= (C4VADObservationParticipant $descriptor $observation)
   (let $cue (C4VADCue $observation $descriptor)
     (if (C4VADLanguageCueValid $cue)
       (participant-contribution
         (c4-vad-language-cue-participation (index-atom $cue 1))
         tool (index-atom $cue 2)
         (lineage NRC-VAD-2.1 (index-atom $cue 3) (index-atom $cue 4))
         (participant-relation-claim language-affect-cue unresolved
           (c4-vad-language-cue-evidence-v1
             (index-atom $cue 1) (index-atom $cue 3) $cue))
         unresolved no-contact-no-movement-authority)
       (participant-unresolved vad-language-cue
         unavailable-or-invalid-mechanical-observation))))

(= (C4VADCueSurfacesAt $participants $i)
   (if (< $i (size-atom $participants))
     (let* (($participant (index-atom $participants $i))
            ($claim (if (CPShape $participant participant-contribution 8)
              (index-atom $participant 5) ())))
       (if (and (CPShape $claim participant-relation-claim 4)
                (== (index-atom $claim 1) language-affect-cue))
         (cons-atom (index-atom (index-atom $claim 3) 3)
           (C4VADCueSurfacesAt $participants (+ $i 1)))
         (C4VADCueSurfacesAt $participants (+ $i 1))))
     ()))

(= (C4VADCueSurface $contact)
   (let $cues (C4VADCueSurfacesAt (CPParticipants $contact) 0)
     (if (== (size-atom $cues) 1)
       (if (C4VADLanguageCueValid (index-atom $cues 0))
         (language-cue-participation (index-atom $cues 0)
           lexical-association-not-person-state-or-authority)
         (language-cue-participation cue-unavailable
           no-affective-inference))
       (language-cue-participation cue-unavailable
         no-affective-inference))))

(= (C4VADCueSurfaceValid $surface)
   (if (CPShape $surface language-cue-participation 3)
     (if (== (index-atom $surface 1) cue-unavailable)
       (== (index-atom $surface 2) no-affective-inference)
       (and (C4VADLanguageCueValid (index-atom $surface 1))
            (== (index-atom $surface 2)
              lexical-association-not-person-state-or-authority)))
     false))
