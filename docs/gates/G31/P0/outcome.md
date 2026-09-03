# G31 P0 outcome — service found; live-grant identity model incomplete

P0 bound the exact G30-qualified candidate and performed only read-only Docker metadata discovery. It found one possible local target, `clarityclaw_mattermost`, image `mattermost/mattermost-team-edition:11.7.7`, published at local port `8065`. Container state was unchanged; no credential, HTTP/WebSocket, message, model, activation, or promotion participated.

The incomplete real grant was correctly held. However, the synthetic “complete” control exposed a material schema omission: it represented the credentialed outbound bot user but not a separate allowlist of inbound source users. The candidate checks `Frame.user_id` before emitting contact, while the bot credential authorizes response effects. Treating those as one identity would blur two distinct authority roles and could admit the wrong live surface.

The grant also needs explicit standing for the VoiceRNA/certified-movement route, the exact qualified live transport version, and destination-specific uncertain-outcome reconciliation. P0 therefore does **not** pass and cannot authorize live reach. Its inventory remains useful evidence. P1 must correct the native grant ontology and causal controls without repeating discovery or contacting Mattermost.
