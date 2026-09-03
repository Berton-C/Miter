# G30 R2 outcome — independent mock round trip passed

G30 passed against the exact unchanged `mattermost-r9` candidate authored in G29. The only R2 implementation change normalized stored JSON identity strings back into the atom-valued surface contract at the builder mock's durable-state read boundary. It did not change candidate bytes, scenarios, obligations, severed transforms, or expected behavior.

The canonical run produced exactly one initial authorized `SurfaceEvent`, suppressed the duplicate, admitted one distinct edit, and rejected an unauthorized source before attempting its deliberately absent payload. Stable server, team, channel, user, post, root, timestamp, cursor, and authorization identities survived mapping. A fresh SWI-Prolog child process reloaded cursor `200` and both seen versions from durable state.

Two outbound effects exercised four request attempts. A confirmed `503` failure was witnessed and retried with the same `k1`; an accepted-but-response-lost outcome was witnessed and reconciled with the same `k2`. The mock created exactly one server post per effect, and the second `k2` attempt returned the existing receipt rather than creating another post. A repeated effect after confirmation was suppressed.

Native PeTTa/MeTTa assessment qualified only the complete relation set. Changing authorization standing, server creation count, restart cursor, or effect-deduplication consequence made the assessment unqualified. Independently severing the identity allowlist changed the authorization-before-payload result; severing candidate effect deduplication admitted the repeated effect. Candidate-authored tests also passed in a separately launched process but were not used as acceptance authority.

No credential, model call, network call, live service, activation, or promotion participated. G30 establishes deterministic mock behavior only. G31 still requires Berton's exact first-live grant for a dedicated server/account/channel, credential reference, bounded payload, persistence, rollback, and panic scope.
