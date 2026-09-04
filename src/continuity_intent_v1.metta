; G33 R2 native use of a generated, mechanically source-verified continuity
; reading. The model product remains a candidate; these relations determine
; whether it is sufficient to address the exact continuity machinery.

(= (CIRecognizedFacetCount $context)
   (+ (+ (miter_continuity_reading_claim_count $context "continuity-facet" "current-position")
         (miter_continuity_reading_claim_count $context "continuity-facet" "last-completed-work"))
      (+ (miter_continuity_reading_claim_count $context "continuity-facet" "unresolved-question")
         (miter_continuity_reading_claim_count $context "continuity-facet" "next-movement"))))

(= (ContinuityReadingDecision $context)
   (let* (($completion (miter_continuity_reading_field $context "completion_status"))
          ($source (miter_continuity_reading_source_status $context))
          ($claims (miter_continuity_reading_claim_total $context))
          ($kinds (miter_continuity_reading_relation_count $context "project-kind"))
          ($facets (miter_continuity_reading_relation_count $context "continuity-facet"))
          ($recognized (CIRecognizedFacetCount $context)))
     (if (!= $source reading-source-spans-verified) continuity-reading-source-unverified
       (if (!= $completion "complete") continuity-reading-insufficient
         (if (!= $claims (+ $kinds $facets)) continuity-reading-contains-unsupported-relation
           (if (!= $kinds 1) continuity-reading-project-kind-not-unique
             (if (or (== $facets 0) (!= $facets $recognized)) continuity-reading-facets-unsupported
               (continuity-reading-supported
                 (miter_continuity_reading_project_kind $context)
                 (requested-continuity-facets $facets)
                 (generated-reading
                   (miter_continuity_reading_field $context "request_id")
                   (miter_continuity_reading_field $context "source_sha256"))))))))))

(= (ContinuityReadingSupported $reading)
   (if (is-expr $reading)
     (if (== (size-atom $reading) 4)
       (== (index-atom $reading 0) continuity-reading-supported) false)
     false))

(= (ContinuityAcquireReading $context $mode)
   (if (== $mode provider-off) continuity-reading-provider-unavailable
     (let $prepared (miter_continuity_reading_prepare $context "qwen-local")
       (if (!= $prepared continuity-reading-request-prepared) $prepared
         (let $executed (miter_continuity_reading_execute $context)
           (if (!= $executed continuity-reading-raw-stored) $executed
             (let $parsed (miter_continuity_reading_parse $context)
               (if (== $parsed continuity-reading-candidate-stored)
                 (ContinuityReadingDecision $context) $parsed))))))))
