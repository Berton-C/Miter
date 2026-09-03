# G29 R3 outcome — on-demand Nemotron startup failure

Native MeTTa selected `nemotron-local` uniquely from the frozen resource relations before inference. Reordering was neutral, removing Nemotron held the undertaking, and making qwen equally supported produced an unresolved comparison rather than first-match selection.

Both bounded Nemotron requests then ended after about ten seconds with HTTP 200 streams containing only `event: error` and `terminated`. Neither produced content or a candidate artifact. LM Studio wrote crash dumps at the corresponding request times; only their paths, sizes, timestamps, and hashes are recorded, and dump contents are not copied into the public repository. No model remained loaded afterward.

A read-only load estimate for 16,384 context and full GPU reports approximately 25.18 GiB against this Mac's 48 GiB unified memory, so raw capacity is plausible. The changed evidence points to the on-demand loading path rather than token latency or candidate quality. R4 may therefore test one reversible runtime condition: explicitly preload the same already-authorized model at full GPU with an 8,192-token context, speculative MTP disabled, and a finite TTL; use it for the unchanged two repair requests; then unload exactly that model. This does not alter persistent model settings.

Both R3 call claims are spent. This is not G29 closure, and no candidate was created or promoted.
