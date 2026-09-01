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
