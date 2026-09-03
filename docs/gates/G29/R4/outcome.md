# G29 R4 outcome — explicit preload succeeded; constrained inference still crashed

Native MeTTa uniquely selected the bounded `nemotron-explicit-load` recovery from the retained R3 evidence. Reordering was neutral, removing the supported recovery held the undertaking, and adding an equally supported recovery produced unresolved standing.

The exact transient load succeeded at full GPU, 8,192-token context, speculative MTP disabled, and a fifteen-minute TTL. The CLI also reported that its attempt to write a local preference file was denied; no persistent setting was changed. Both subsequent schema-constrained requests returned HTTP 200 streams containing only `event: error` and `terminated`, and two corresponding LM Studio crash dumps appeared. No source artifact or candidate was produced.

The model had already disappeared by the exact unload step, so the CLI reported `Model Not Found`; the observed post-state nevertheless matched the empty pre-state. Docker services were unchanged, no credentials or Mattermost network access were used, and both R4 claims are spent.

R4 rules out on-demand loading as the sole cause. It does not yet distinguish ordinary Nemotron inference failure from a crash induced by the strict JSON response schema/grammar. R5 may therefore make one tiny unconstrained diagnostic request after the same reversible preload. Only a successful exact sentinel response may admit the two bounded plain-text artifact requests. Failure of the diagnostic must stop the slice without artifact calls.
