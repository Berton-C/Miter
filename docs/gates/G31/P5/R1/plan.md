# G31 P5 R1 — authorized read-only live identity resolution

Resolve only the local Mattermost identities needed to construct the exact first-live grant: server, team, allowlisted channel, expected denied-control channel, and credentialed bot. Use the user-authorized Keychain reference without returning its value. Read channel membership only to report possible human principals; do not select one for Berton.

Actual IDs remain in ignored `config/local/` state with restrictive permissions. Public evidence records hashes, presence, membership relations, response status, and explicit unresolved fields. No post content, message creation, WebSocket, activation, promotion, or canary effect is permitted.
