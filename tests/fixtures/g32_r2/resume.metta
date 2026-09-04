; Current DRResume consumer driven by fixture-owned mechanical readbacks.
!(import! &self (library lib_import))
!(import! &self "/Users/claritymiter/miter/src/participation.metta")
!(import! &self "/Users/claritymiter/miter/src/participation_support.metta")
!(bind! &derived (new-space))
!(import! &self "/Users/claritymiter/miter/src/development_resume_v1.metta")

(= (tv_restore accepted-root) fixture-active-projection)
(= (TVHydrate accepted-root fixture-active-projection) active-projection-restored)
(= (NLoad efficacy-root $inv) efficacy-projected)
(= (EComparable $invs) true)
(= (dr_record $root $event) restart-recorded)
(= (ERank $invs)
 (supported-expression-alternatives
  ((efficacy-option parent-module (stv 0.5 0.5))
   (efficacy-option candidate-module (stv 0.75 0.66)))
  consequence-earned-ranking))

!(add-atom &derived
 (active-voice-v2 accepted-root parent-module candidate-module
  (pins active-parent-pin active-candidate-pin)))

(= (G32R2ResumeInput $bindings)
 (resume-input accepted-root efficacy-root
  ((efficacy-invocation invocation-parent
    (scope cut-g32r2 principal-g32r2 project-g32r2 private-g32r2)
    (evidence-root-parent) frame-g32r2 criterion context-g32r2
    parent-efficacy-pin parent-module budget)
   (efficacy-invocation invocation-candidate
    (scope cut-g32r2 principal-g32r2 project-g32r2 private-g32r2)
    (evidence-root-candidate) frame-g32r2 criterion context-g32r2
    candidate-efficacy-pin candidate-module budget))
  (resume-capsule project-g32r2 principal-g32r2 private-g32r2 capsule-g32r2
   frame-g32r2 exact-location current-goal last-work (open-question)
   next-movement prior-capsule (event-a event-b) artifact-hash)
  () (history-a history-b) resume-hash $bindings))
(= (dr_input resume-canonical)
 (G32R2ResumeInput
  ((module-byte-binding active-parent-pin parent-efficacy-pin)
   (module-byte-binding active-candidate-pin candidate-efficacy-pin))))
(= (dr_input resume-lineage-severed)
 (G32R2ResumeInput
  ((module-byte-binding active-parent-pin wrong-parent-pin)
   (module-byte-binding active-candidate-pin wrong-candidate-pin))))
