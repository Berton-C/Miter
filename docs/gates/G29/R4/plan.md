# G29 R4 — transient explicit-load recovery experiment

## Bounded claim

G29 R4 tests whether the exact Nemotron renderer that failed during on-demand startup can participate when the runtime condition is changed to an explicit, reversible preload. Native MeTTa compares the retained failure with available recovery operations and may select only a transient full-GPU load with fixed context, disabled speculative MTP, finite TTL, and exact post-trial unload. The two source requests and all candidate qualifications remain unchanged.

This is a transport/runtime recovery experiment plus, if loading succeeds, a candidate rendering trial. It does not weaken syntax or behavioral requirements, change persistent LM Studio settings, contact Mattermost, use credentials, promote an adapter, or establish G30 behavior.

## Frozen experiment

1. Reopen from committed R3 stream errors, crash metadata, model-state observation, resource estimate, and exact R2 candidate.
2. Represent recovery operations by resource, mechanism, reversibility, scope, changed consequence, and grant. Native comparison must select the uniquely supported transient preload. Reordering is neutral; removing it holds; adding an equally supported operation creates unresolved standing.
3. Through the Prolog process membrane, verify no model is loaded, then invoke only `/Users/bcb/.lmstudio/bin/lms load nemotron-3.5-30b-a3b-antislop-ftpo-i1 --gpu max --context-length 8192 --ttl 900 --no-speculative-draft-mtp --yes`. Capture status/stdout/stderr and verify the expected model is loaded before inference.
4. Spend at most two new Nemotron calls, one bridge and one tests, under the same 2,048-output-token, 300-second, 2-MiB limits. The test call receives the exact new bridge product. No qwen, remote model, credential, live Mattermost request, or hand-authored candidate code is allowed.
5. If both products complete, assemble `mattermost-r4` in quarantine and apply the unchanged corrected syntax, PLUnit, boundary, lineage, identity, idempotency, cursor, panic, and causal checks.
6. Unload exactly the explicitly loaded Nemotron model whether generation passes or fails. Verify the post-trial model state equals the pre-trial state and Docker services remain unchanged.
7. Produce G29 closure and freeze G30 only after all G29 evidence agrees. Otherwise preserve failure and stop the slice.

An explicit load failure consumes no generation call. A completed error stream consumes its call. No request or claim is replayed under another identity.
