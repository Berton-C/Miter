# G31 P0 — exact first-live authority preflight

G30 qualifies the Miter-authored bridge for a live canary; it does not authorize one. P0 creates the native representation that refuses network and credential effects until a complete, exact first-live grant exists.

The grant must bind the exact candidate hash to the local server and stable server/team/channel/bot IDs; credential lookup reference; exact inbound/outbound classes and canary payload; memory-scope derivation; cursor/effect persistence; duration and ongoing access; panic; rollback; expiry and revocation. Read-only local discovery may enumerate possible targets, but it cannot choose them for Berton or reuse the separate OpenRouter authorization.

P0 makes no live request, reads no message or secret, mutates no service, and promotes nothing. Its result is either an exact list of unresolved authority fields or `live-preflight-ready` after those fields are explicitly granted in a later frozen plan.
