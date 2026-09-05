!(import! &self "/Users/claritymiter/miter/src/bootstrap_assistant_v1.metta")
!(import! &self "/Users/claritymiter/miter/src/authority_inheritance_v1.metta")
!(import! &self "/Users/claritymiter/miter/tests/fixtures/ama1_2/r3/authority-cluster-data.metta")

!(bind! &r3_cluster (new-space))

!(let $contact (R3M24Canonical) (add-atom &r3_cluster $contact))
!(let $organization (R3M260Canonical) (add-atom &r3_cluster $organization))

!(match &r3_cluster $contact
  (if (CPShape $contact m24-contact 9)
    (let $value (M24ContactValid $contact)
      (cluster-result contact-valid $value))
    (empty)))
!(match &r3_cluster $contact
  (if (CPShape $contact m24-contact 9)
    (let $value (M24ContactOrganization $contact)
      (cluster-result contact-organization $value))
    (empty)))

!(let $value (M24DirectContact (prov-infer event-infer
    ((prov-contact (contact-seal contact-alpha event-alpha route-alpha payload-alpha)))))
  (cluster-result infer-is-not-contact $value))

!(let $value (M24StandingWarrant
    (standing (prov-testimony person-alpha event-alpha) provisional
      (event-alpha) (urgent repeated) fresh-for-contact))
  (cluster-result pressure-does-not-change-warrant-a $value))
!(let $value (M24StandingWarrant
    (standing (prov-testimony person-alpha event-alpha) provisional
      (event-alpha) () fresh-for-contact))
  (cluster-result pressure-does-not-change-warrant-b $value))

!(let $value (M24InterpretationUseValid
    (interpretation interpretation-alpha frame-alpha history-alpha meaning-alpha
      event-interpretation (prov-infer event-interpretation
        ((prov-contact (contact-seal contact-alpha event-alpha route-alpha payload-alpha)))))
    (interpretation-use event-use frame-alpha history-alpha interpretation-alpha
      (scope principal-alpha audience-alpha project-alpha) action-alpha
      soul-judgment-alpha interpretation-use-writer))
  (cluster-result interpretation-use-valid $value))

!(let $value (M24InterpretationUseValid
    (interpretation interpretation-alpha frame-alpha history-alpha meaning-alpha
      event-interpretation (prov-infer event-interpretation
        ((prov-contact (contact-seal contact-alpha event-alpha route-alpha payload-alpha)))))
    (interpretation-use event-use frame-alpha history-alpha interpretation-alpha
      (scope principal-alpha audience-alpha project-alpha) action-alpha
      soul-judgment-alpha renderer))
  (cluster-result interpretation-renderer-cannot-write $value))

!(let $value (M24ScopedJointUseValid
    (scoped-joint-use (frame-alpha frame-beta)
      (scope principal-alpha audience-alpha project-alpha)
      no-local-compatibility
      (retained-tension-witness frame-alpha frame-beta)))
  (cluster-result scoped-joint-retained-tension $value))

!(let $value (M24ScopedJointUseValid
    (scoped-joint-use (frame-alpha frame-beta)
      (scope principal-alpha audience-alpha project-alpha)
      no-local-compatibility no-retained-tension))
  (cluster-result scoped-joint-no-witness $value))

!(let $value (M24BranchTransactionValid
    (branch-transaction event-new (event-old) (patch relation-new)
      (event-new event-old) contact-recorder))
  (cluster-result branch-commit-valid $value))
!(let $value (M24BranchTransactionValid
    (branch-transaction event-old (event-old) (patch relation-new)
      (event-old) contact-recorder))
  (cluster-result branch-recommit-rejected $value))

!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260OrganizationValid $organization)
      (cluster-result occurrence-valid $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260SameOcc $organization part-before part-after)
      (cluster-result same-occurrence $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260SameBecoming $organization movement-alpha
        (l2425 movement-alpha evidence-l2425)
        (same-becoming-witness movement-alpha occurrence-alpha
          (l2425 movement-alpha evidence-l2425) evidence-same-becoming))
      (cluster-result same-becoming $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260GReadingOf $organization
        (generated movement-alpha precursor-organization source-alpha)
        (l2425 movement-other evidence-l2425)
        (same-becoming-witness movement-alpha occurrence-alpha
          (l2425 movement-alpha evidence-l2425) evidence-same-becoming))
      (cluster-result orphan-generated $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260GReadingOf $organization
        (generated movement-alpha precursor-organization source-alpha)
        (l2425 movement-alpha evidence-l2425)
        (same-becoming-witness movement-alpha occurrence-alpha
          (l2425 movement-alpha evidence-l2425) evidence-same-becoming))
      (cluster-result generated-reading $value))
    (empty)))

!(let $value (M260StructuralFidelity (relation-contact) (relation-contact relation-consequence))
  (cluster-result structural-fidelity-forward $value))
!(let $value (M260StructuralFidelity (relation-contact relation-consequence) (relation-contact))
  (cluster-result structural-fidelity-reverse $value))

!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260PersistentForm $organization part-before part-after)
      (cluster-result persistent-form $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260DWS $organization
        (aspect-ontology aspect-phenomenology aspect-consciousness))
      (cluster-result dws $value))
    (empty)))
!(match &r3_cluster $organization
  (if (CPShape $organization m260-occurrence-organization 13)
    (let $value (M260OPCAt $organization)
      (cluster-result opc $value))
    (empty)))
