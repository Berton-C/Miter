# G31 P5 R1 outcome — live identities resolved read-only; effects remain held

The fixed Prolog acceptance probe authenticated the dedicated `miter` bot through the macOS Keychain and resolved the exact loopback Mattermost server, `clarityclaw` team, `miter-g31-canary` allowlisted channel, `miter-g31-denied` control channel, and both bot-channel membership relations. All eight HTTP responses were `200`. Exactly one non-bot member was observed in the allowlisted channel; P5 deliberately retained that human principal as unresolved.

Actual stable IDs and the sole human candidate remain only in ignored `config/local/` state with mode `0600`. Public evidence contains hashes, counts, slugs, response status, and membership relations; it contains neither the credential value nor actual IDs. The run made no post-content read, message read or write, API mutation, model call, promotion, or activation.

Attempt 501 preserved the bot-visible `404` before channel membership was corrected. Attempt 502 then resolved every identity, but its first native check returned an unexecuted expression because the newly added MeTTa definition contained one extra closing parenthesis. The harness rejected that result. Removing that single syntax error without changing the frozen expectation allowed the resumed native check to produce `g31-identity-resolution-complete-awaiting-human`. The failed evidence remains present.

After this bounded evidence was captured, Berton explicitly confirmed the sole observed human account as the authorized G31 principal. That later authority does not retroactively change P5 evidence and does not authorize a live message. It is an input to the separately frozen grant-construction phase; the account name and stable ID remain private.
