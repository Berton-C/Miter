# Nemotron runtime compatibility correction

The first full G04 fixture reached LM Studio but could not load the pinned
Nemotron GGUF under the selected `llama.cpp` runtime 2.28.2. LM Studio's server
log reported `wrong number of tensors; expected 417, got 408`. The failed
request, response, timing, process sample, and fixture output are preserved
under `raw/probes/pre_runtime_upgrade/`.

This is a documented runtime/model compatibility failure rather than a Miter
schema-boundary failure:

- https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/2283
- https://huggingface.co/mradermacher/Nemotron-3.5-30B-A3B-Antislop-FTPO-i1-GGUF
- https://huggingface.co/bartowski/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF/discussions/3

LM Studio's 2.29.0 beta, 2.31.2 stable, and 2.32.0 beta runtimes were installed
side-by-side for bounded compatibility probes. Versions 2.29.0 and later load
the GGUF, resolving the original tensor-count failure. The LM Studio-managed
load path then terminated this model at prompt evaluation on Apple Metal with
`kernel_mul_mm_id_map0_ne20_18_ne02=128`; 2.29.0, 2.31.2, and 2.32.0 all
reproduced that provider-side failure. The failed requests, timings, and
relevant service excerpts are retained under `raw/probes/`.

The same LM Studio-supplied 2.32.0 `llama-server` runtime and exact GGUF
completed successfully when started on loopback with GPU layers, operation
offload, and KV offload disabled. The G04 final fixture therefore used:

- the normal LM Studio API at `127.0.0.1:1234` for Qwen; and
- the LM Studio 2.32.0 runtime at `127.0.0.1:1235` for Nemotron, launched by
  `scripts/g04/run_nemotron_cpu_service.sh` with its tools and web UI disabled.

The prompts, response schema, bounds, seed, and Miter PeTTa/Prolog request path
were identical; only the localhost provider endpoint and model ID differed.
The direct service was stopped after the gate. LM Studio's original 2.28.2
selection and Qwen load configuration were restored. All additional runtimes
remain installed side-by-side for reproducibility and rollback. No model file
was downloaded, replaced, copied into the repository, or modified. The exact
runtime transitions are retained under `environment/`.

Miter's core request path remains PeTTa/MeTTa plus the SWI-Prolog effect
membrane. Provider lifecycle and engine flags stay outside the cognitive core,
and no Python was introduced into the request path.
