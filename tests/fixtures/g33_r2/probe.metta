!(import! &self "/Users/claritymiter/miter/src/bootstrap_continuity_intent_v1.metta")
!(result acquire (ContinuityAcquireReading "unused" provider-off))
!(result supported (ContinuityReadingSupported (continuity-reading-supported "book" (requested-continuity-facets 1) (generated-reading "id" "hash"))))
!(result atomic (ContinuityReadingSupported continuity-reading-provider-unavailable))
