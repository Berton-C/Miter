(= (R3RuntimeContact)
   (contact-v2 contact-scope-alpha human-contact principal-alpha audience-alpha
    project-alpha occurrence-scope-alpha proto-scope-alpha payload-scope-alpha
    (encounter-configuration
      (D ((relation relation-request contact support controlled-contact))
         ((distinction distinction-authorship available controlled-contact)))
      (Omega ((material-relation relation-whole
        (Gravity Balance Connection Love) support nary-contact-witness)))
      (I ((interface interface-conversation open authorized-local-contact)))
      (W ((thread thread-undertaking-alpha open contact-lineage)))
      (C ((soul-relation relation-soul-participation material constitutional-weave)))
      (present-context present-scope-alpha occurrence-bound)
      ((fact-view fact-view-scope-alpha (Gravity Balance Connection Love)
        (relation-whole) recognized finite-contact-reading))
      ((flourishing-view AgencyBalance relation-request flourishing choice-remains-open)
       (flourishing-view SharedUnderstanding relation-request beneficial-direction
         request-distinction-live)
       (flourishing-view ConnectionDepth relation-whole flourishing
         contact-remains-relational))
      () ())
    ()))

(= (R3NeutralRuntimeContact)
   (contact-v2 contact-scope-alpha human-contact principal-alpha audience-alpha
    project-alpha occurrence-scope-alpha proto-scope-alpha payload-scope-alpha
    (encounter-configuration
      (D ((distinction distinction-authorship available controlled-contact))
         ((relation relation-request contact support controlled-contact)))
      (Omega ((material-relation relation-whole
        (Gravity Balance Connection Love) support nary-contact-witness)))
      (I ((interface interface-conversation open authorized-local-contact)))
      (W ((thread thread-undertaking-alpha open contact-lineage)))
      (C ((soul-relation relation-soul-participation material constitutional-weave)))
      (present-context present-scope-alpha occurrence-bound)
      ((fact-view fact-view-scope-alpha (Gravity Balance Connection Love)
        (relation-whole) recognized finite-contact-reading))
      ((flourishing-view ConnectionDepth relation-whole flourishing
         contact-remains-relational)
       (flourishing-view SharedUnderstanding relation-request beneficial-direction
         request-distinction-live)
       (flourishing-view AgencyBalance relation-request flourishing choice-remains-open))
      () ())
    ()))

(= (R3M24WithoutSeal $m24)
   (m24-contact
     (index-atom $m24 1) (index-atom $m24 2) (index-atom $m24 3)
     (contact-seal-severed (index-atom $m24 1))
     (index-atom $m24 5) (index-atom $m24 6) (index-atom $m24 7)
     (index-atom $m24 8)))

(= (R3M260WithoutManifestation $m260)
   (m260-occurrence-organization
     (index-atom $m260 1) (index-atom $m260 2) (index-atom $m260 3)
     (index-atom $m260 4) () (index-atom $m260 6) (index-atom $m260 7)
     (index-atom $m260 8) (index-atom $m260 9) (index-atom $m260 10)
     (index-atom $m260 11) (index-atom $m260 12)))

(= (R3M260WithoutPreservedStructure $m260)
   (m260-occurrence-organization
     (index-atom $m260 1) (index-atom $m260 2) (index-atom $m260 3)
     (index-atom $m260 4) (index-atom $m260 5) (index-atom $m260 6)
     (index-atom $m260 7) (index-atom $m260 8) (index-atom $m260 9)
     ((preserves (contact-view contact-scope-alpha) sealed-contact)
      (preserves (frame-view contact-scope-alpha) partial-frame))
     (index-atom $m260 11) (index-atom $m260 12)))

(= (R3M260WithUnchangedBoundary $m260)
   (m260-occurrence-organization
     (index-atom $m260 1) (index-atom $m260 2) (index-atom $m260 3)
     (index-atom $m260 4) (index-atom $m260 5) (index-atom $m260 6)
     (index-atom $m260 7) (index-atom $m260 8)
     ((local-boundary (contact-part contact-scope-alpha) shared-boundary)
      (local-boundary (frame-part contact-scope-alpha) shared-boundary)
      (local-boundary (soul-part contact-scope-alpha)
        (soul-boundary (scope principal-alpha audience-alpha project-alpha))))
     (index-atom $m260 10) (index-atom $m260 11) (index-atom $m260 12)))

(= (R3M260WithCollapsedOPC $m260)
   (m260-occurrence-organization
     (index-atom $m260 1) (index-atom $m260 2) (index-atom $m260 3)
     (index-atom $m260 4) (index-atom $m260 5) (index-atom $m260 6)
     (index-atom $m260 7) (index-atom $m260 8) (index-atom $m260 9)
     (index-atom $m260 10) (index-atom $m260 11)
     ((mode-reading (relational-organization contact-scope-alpha) ontology)
      (mode-reading (relational-organization contact-scope-alpha) phenomenology)
      (mode-reading (self-relating-organization contact-scope-alpha) consciousness))))

(= (R3M260WithCollapsedAmbiguity $m260)
   (m260-occurrence-organization
     (index-atom $m260 1) (index-atom $m260 2) (index-atom $m260 3)
     (index-atom $m260 4) (index-atom $m260 5) (index-atom $m260 6)
     (index-atom $m260 7)
     (finite-ambiguity
       ((contact-view contact-scope-alpha) (frame-view contact-scope-alpha)
        (soul-view contact-scope-alpha))
       occurrence-scope-alpha occurrence-scope-alpha equal-observations)
     (index-atom $m260 9) (index-atom $m260 10)
     (index-atom $m260 11) (index-atom $m260 12)))

(= (R3JointWithoutSameBecoming $joint)
   (if (CPShape $joint authority-participation-joint-v2 11)
     (let* (($same (index-atom $joint 8))
            ($severed-same (same-becoming-certified
              (index-atom $same 1) (index-atom $same 2)
              (index-atom $same 3) false)))
       (authority-participation-joint-v2
         (index-atom $joint 1) (index-atom $joint 2) (index-atom $joint 3)
         (index-atom $joint 4) (index-atom $joint 5) (index-atom $joint 6)
         (index-atom $joint 7) $severed-same (index-atom $joint 9)
         (index-atom $joint 10)))
     (authority-participation-joint-v1
       (index-atom $joint 1) (index-atom $joint 2) (index-atom $joint 3)
       (index-atom $joint 4) (index-atom $joint 5) (index-atom $joint 6)
       (index-atom $joint 7) false (index-atom $joint 9))))

(= (R3JointWithoutQualifiedGenerated $joint)
   (authority-participation-joint-v2
     (index-atom $joint 1) (index-atom $joint 2) (index-atom $joint 3)
     (index-atom $joint 4) (index-atom $joint 5) (index-atom $joint 6)
     (g-reading-unresolved severed-generated-reading)
     (index-atom $joint 8) (index-atom $joint 9) (index-atom $joint 10)))

(= (R3JointWithoutContactAnswerability $joint)
   (authority-participation-joint-v2
     (index-atom $joint 1) (index-atom $joint 2) (index-atom $joint 3)
     (index-atom $joint 4) (index-atom $joint 5) (index-atom $joint 6)
     (index-atom $joint 7) (index-atom $joint 8)
     (contact-answerability-anchor severed-frame severed-contact severed-domain)
     (index-atom $joint 10)))

(= (R3SnapshotFromGrounded $contact $grounded $joint)
   (let* (($scope (CPContactScope $contact))
          ($encounter (index-atom $grounded 2))
          ($cut (index-atom $encounter 1))
          ($movement (AREncounterMovement $encounter))
          ($summary (AR2EncounterSummary $encounter $joint)))
     (assistant-snapshot
       (state ((active-organization $scope $cut $movement)))
       (history ((assistant-history encounter (index-atom $contact 1)
         $scope $summary))))))
