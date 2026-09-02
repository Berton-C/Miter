!(import! &self "/Users/claritymiter/miter/src/bootstrap_interests.metta")
!(SoulBoot "runtime/g20/soul-severed/integrity-before-severing.json")
; Test-only loaded-atom severing after independently verified startup.
; Source files and the pinned Soul are never modified.
!(match &soul (soul-value CreativeTranscendence $description)
   (remove-atom &soul (soul-value CreativeTranscendence $description)))
!(ReactorCycle "runtime/g20/soul-severed" false)
