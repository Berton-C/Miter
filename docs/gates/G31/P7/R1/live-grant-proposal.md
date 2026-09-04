# G31 proposed live Mattermost canary grant — inactive

Status: **not approved and not active**
Live-effect approval: **unresolved**
Principal selection: **explicitly confirmed; private stable identity bound**

## Purpose

Run the smallest live experiment that can establish the G31 claims: exact ingress authorization, Soul/VoiceRNA participation before an external utterance, durable cursor/effect state across restart, denied-channel rejection before cognition, and immediate panic containment.

## Exact proposed reach

- Server: the single previously resolved, hash-bound loopback Mattermost instance; its exact URL and stable ID remain in private local state.
- Team: the single previously resolved, hash-bound team; its exact name and stable ID remain in private local state.
- Cognition-eligible ingress and sole egress: the single hash-bound private allowlisted channel.
- Negative-control ingress: the single hash-bound private denied-control channel; never an egress target.
- Human source: the single explicitly selected and privately bound principal.
- Writer: the single hash-bound dedicated bot only; its exact account identity remains in private local state.
- Credential: macOS Keychain service `ai.bgi.miter.mattermost`, account `bcb`; the value may be resolved only inside the mechanical membrane and may never be returned.

No other server, team, channel, user, bot, credential, destination, or network host is included.

## Information exposure

For a newly received event in the allowlisted channel, the adapter may expose to Miter only the authenticated event identity, exact new message text, and thread/root context required for that contact. Existing channel history is outside scope.

Mattermost transport may deliver a denied-channel event frame to the adapter. The adapter must check server, team, channel, and principal identity first and must not admit its content to cognition, memory, an LLM, or an outbound effect.

For this canary, retrieval from ChromaDB or prior private memory is prohibited. The memory scope is the current canary contact only; cross-principal access is prohibited.

## Proposed live sequence

1. Start the bridge under this exact grant.
2. The authorized human creates one new allowlisted post containing `Miter G31 bounded live canary`.
3. Miter forms its response through cognition and VoiceRNA. Only a `CertifiedUtterance` may become a prepared effect, and exactly one response may be committed for that post.
4. Stop and restart the bridge and native state from durable cursor/effect journals.
5. The authorized human creates a second new allowlisted post with the same text but a different Mattermost post ID.
6. Miter may commit exactly one newly certified response to the second post. The first response must not replay.
7. The authorized human creates one new post in the exact privately bound denied-control channel containing `Miter G31 denied control`. The event must be rejected before cognition and produce no response.
8. Invoke the fixed local panic control. No new effects may begin; state and evidence must remain readable.
9. Stop automatically when the sequence completes, any bound is reached, panic is invoked, approval is revoked, or 30 minutes have elapsed since activation.

Maximum live allowance: two allowlisted input posts, one denied-control input post, and two outbound response effects.

## Effect and persistence requirements

- Outbound effect class: Mattermost `create-post`, targeting only the exact allowlisted channel.
- Raw model output is never an effect; VoiceRNA certification is mandatory.
- Every effect has a stable effect ID and idempotency key.
- Pending intent is durably journaled before send; the receipt or explicit unknown outcome is recorded afterward.
- Cursor and effect journals require fresh-process readback.
- Destination-specific reconciliation is required. Universal exactly-once behavior remains unproven and is not claimed.

## Ongoing access, expiry, panic, rollback, and revocation

- Ongoing access: none beyond this bounded experiment.
- Expiry: 30 minutes after explicit activation, or earlier on completion or revocation.
- Panic: fixed local control immediately prohibits new effects without deleting state.
- Rollback: stop the adapter and restore the prior active registry while preserving all candidate, grant, trial, failure, and effect history. External effects are not represented as undone.
- Revocation: the authorized human principal may revoke locally at any time; all future effects are prohibited immediately.

## Evidence required before G31 can pass

Redacted event/effect identities, exact source/version hashes, VoiceRNA certificate evidence, prepare/commit/witness records, cursor and effect journal readback after restart, no-replay result, denied-channel pre-cognition rejection, panic result, process state, and a credential/private-identity scan.

## What approval would mean

Approval would authorize only the sequence, identities, information exposure, duration, and effects written above. It would not authorize ordinary ongoing Mattermost operation, other conversations, historical-message retrieval, prior-memory retrieval, broader network access, additional messages, deployment for other users, or any future UI/workbench capability.
