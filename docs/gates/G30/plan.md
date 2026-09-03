# G30 — independent Mattermost mock round trip

## Bounded claim

G30 tests the exact quarantined `mattermost-r9` candidate against an independently constructed, non-networked mock service. It asks whether authorization, stable event identity, duplicate/edit handling, send-failure witnessing, same-key recovery, and restart cursor state actually preserve the generic surface contract.

## Execution boundary

1. Copy the exact G29 candidate into disposable G30 runtime/evidence and prove its source hash.
2. Construct a deterministic Prolog mock service whose request log and returned outcomes are independent of the candidate.
3. Freeze authorized, duplicate, edited, unauthorized-user/channel, failed-send, retry, restart, panic, and malformed cases.
4. Let native PeTTa/MeTTa admit the trial relations before the Prolog process is launched.
5. Record canonical events, effects, request attempts, receipts/failures, witnesses, cursor/dedupe state, and post-restart readback.
6. Run severed variants that remove identity allowlisting and idempotency participation. The corresponding forbidden behavior must become observable.
7. Independently hash and compare every log and state transition. Candidate-owned unit tests cannot certify the result.
8. If the exact candidate fails a required result, preserve the typed consequence and stop. Any revision requires a separate frozen plan grounded in that returned evidence.

No Mattermost or other network is contacted, no credential or model is used, and no candidate is activated or promoted in G30.
