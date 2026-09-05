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

(= (R3JointWithoutSameBecoming $joint)
   (authority-participation-joint-v1
     (index-atom $joint 1) (index-atom $joint 2) (index-atom $joint 3)
     (index-atom $joint 4) (index-atom $joint 5) (index-atom $joint 6)
     (index-atom $joint 7) false (index-atom $joint 9)))

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
