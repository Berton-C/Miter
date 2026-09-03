; Exact continuity semantics.  A capsule is an operational checkpoint, not a
; prose summary and not a vector-search result.

(: ProjectContinuity Type)
(: CapsuleId (-> ProjectContinuity Atom))
(: ProjectId (-> ProjectContinuity Atom))
(: CurrentArtifact (-> ProjectContinuity Atom))
(: ExactLocation (-> ProjectContinuity Atom))
(: UnresolvedQuestions (-> ProjectContinuity Expression))
(: NextIntendedMovement (-> ProjectContinuity Atom))

(= (AppendContinuityCapsule $store-root $runtime-extension $fixture-path)
   (miter_continuity_write_capsule $store-root $runtime-extension $fixture-path))

(= (SelectCurrentCapsule $store-root $runtime-extension $project-id $capsule-id)
   (miter_continuity_set_current $store-root $runtime-extension $project-id $capsule-id))

(= (RecoverContinuity $store-root $project-id $output-path)
   (miter_continuity_reconstruct $store-root $project-id $output-path))

; G11 bounded book-continuity intent. No fuzzy vector result grants exactness.
(= (ContinuityRNA $context $mode)
   (let* (($text (miter_resume_field $context "text"))
          ($begin (miter_resume_begin $context)))
     (if (== $begin restart-contact-recorded)
       (if (== $text "Where was I with the book?")
         (if (== (miter_resume_registry_count $context "book") 1)
           (BookContinuityRNA $context $mode)
           continuity-project-ambiguous)
         continuity-intent-unsupported)
       $begin)))

(= (BookContinuityRNA $context $mode)
   (let* (($project (miter_resume_registry_project $context "book"))
          ($store (miter_resume_field $context "memory_store"))
          ($principal (miter_resume_field $context "principal_scope"))
          ($audience (miter_resume_field $context "audience_scope"))
          ($text (miter_resume_field $context "text"))
          ($tag (miter_resume_field $context "query_tag"))
          ($capsules (miter_resume_field $context "capsule_store"))
          ($output (miter_resume_field $context "capsule_output"))
          ($semantic (if (== $mode chroma-off) semantic-unavailable
                       (RecallRNA $store $principal $audience $project active $text $tag)))
          ($resolved (if (== $mode capsule-off) capsule-resolver-disabled
                       (RecoverContinuity $capsules $project $output)))
          ($witness (if (== $resolved continuity-reconstructed)
                      (miter_resume_witness $context) source-unverified))
          ($certificate (if (and (== $resolved continuity-reconstructed)
                                (== $witness capsule-event-verified))
                          exact-continuity non-authoritative-recall)))
     (miter_resume_answer $context $certificate $semantic)))
