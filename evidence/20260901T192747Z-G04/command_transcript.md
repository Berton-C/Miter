# G04 command transcript

This is a concise, non-secret operational transcript. Complete provider and
PeTTa outputs are retained in the adjacent evidence directories.

1. Verified the clean G03 baseline, protected-document hashes, ignored local
   model configuration, native SWI-Prolog, and the pinned PeTTa commit.
2. Compiled `effect_membranes/miter_llm.pl`, syntax-checked the G04 scripts,
   parsed all JSON fixtures, and compared both semantic request bodies.
3. Probed SWI-Prolog HTTP transport and corrected the missing HTTP JSON module
   import and atomic raw-body writer before the final fixture.
4. Proved the Qwen response required a 1,024-token completion bound for this
   reasoning model; preserved the earlier bounded rejection.
5. Ran the combined PeTTa fixture against LM Studio runtime 2.28.2 and retained
   Nemotron's tensor-count failure.
6. Installed LM Studio llama.cpp runtimes 2.29.0, 2.31.2, and 2.32.0
   side-by-side; retained each relevant Apple Metal failure probe.
7. Proved the exact Nemotron GGUF under LM Studio's 2.32.0 runtime with GPU
   layers, operation offload, and KV offload disabled.
8. Loaded Qwen in LM Studio with an 8,192-token context and started the bounded
   Nemotron runtime service on `127.0.0.1:1235`.
9. Ran the final pinned PeTTa fixture and sampled its native process path.
10. Ran `scripts/g04/verify_g04.sh` and the holistic evidence verifier; both
    returned PASS.
11. Copied requests, raw provider envelopes, typed results, and timings into
    evidence and verified their hashes against ignored runtime products.
12. Stopped the bounded Nemotron service and restored LM Studio runtime 2.28.2
    with Qwen loaded at the original context and parallel settings.
13. Hardened and directly tested the localhost URI parser against userinfo-host,
    query-string, and scheme-confusion inputs, then reran both G04 verifiers.
