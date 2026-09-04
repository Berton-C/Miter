# G31 P8 R1 — explicit live-canary approval record

## Authority event

On 2026-09-04, Berton explicitly approved the exact G31 live-canary grant surfaced in `docs/gates/G31/P7/R1/live-grant-proposal.md`:

> I approve --> Do you approve this exact G31 live canary grant: two new allowlisted posts, at most two VoiceRNA-certified responses, one denied-control post rejected before cognition with no response, one restart/no-replay test, local Mattermost only, no history/Chroma/prior-memory access, and a 30-minute maximum with panic, revocation, and automatic stop?

The approval authority is `berton-explicit`. It is bound to the P7 proposal, P7 closure, private inactive-grant hash, exact candidate hash, and exact qualified-transport hash recorded by the P8 frozen plan.

## Meaning and limits

This approval authorizes only the exact bounded experiment described above and in the P7 proposal. It does not authorize historical-message retrieval, Chroma or prior-memory access, other principals, other teams or channels, other network hosts, more than two outbound responses, ordinary ongoing Mattermost operation, or any post-PoC workbench capability.

Approval does not itself activate the adapter or start the 30-minute interval. A separately frozen and preflighted live-experiment package must bind this authority record to the private grant, implement the native VoiceRNA and effect lifecycle, and create an activation record. The 30-minute interval begins only at that later mechanical activation. Panic, revocation, any count bound, or expiry prohibits every subsequent effect while preserving evidence.

The authorized human remains represented publicly only by authority class and hashes. Exact usernames, stable IDs, the local server URL, and the Keychain credential remain outside Git.
