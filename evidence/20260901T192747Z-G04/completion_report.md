# G04 completion report

## Verdict

**PASS.** Miter obtained and admitted one bounded typed semantic product from
each configured local chat model. The same semantic request, strict schema,
seed, sampling bounds, and request ID were used for both models. The malformed
control was rejected deterministically and created no typed file or semantic
atom.

## Observed positive results

| Alias | Exact model ID | HTTP | Duration | Typed answer | Semantic atom |
| --- | --- | ---: | ---: | --- | --- |
| `qwen-local` | `qwen/qwen3.8-27b` | 200 | 71,262 ms | `inside the blue box` | admitted |
| `nemotron-local` | `nemotron-3.5-30b-a3b-antislop-ftpo-i1` | 200 | 171,730 ms | `inside the blue box` | admitted |

Both products round-tripped `g04-fixed-request-001`, cited the exact evidence
span `The copper key is inside the blue box.`, reported `uncertainty` as a
number in range, and reported `completion_status` as `complete`.

## Enforced boundary

`effect_membranes/miter_llm.pl` now provides deterministic scalar-result
operations to:

1. resolve a local model alias and prepare a bounded provider request;
2. execute the HTTP request while retaining the provider envelope verbatim;
3. parse provider JSON strictly as inert data and write a separate typed
product only after complete validation.

The transport accepts only an exact HTTP loopback authority with an explicit
port and the `/v1/chat/completions` path; userinfo, remote hosts, query strings,
fragments, and HTTPS substitutions are rejected before transport.

The parser requires exactly the five G04 fields, the exact request ID, bounded
strings and evidence arrays, a numeric uncertainty in `[0,1]`, an allowed
completion status, and provider `finish_reason = stop`. It exposes no term or
MeTTa evaluation surface.

The process sample contains native `swipl` and the local `llama-server`
provider, with no Python, Janus, or `py-call` on Miter's request path.

## Nemotron provider correction

The exact Nemotron GGUF exposed two provider-runtime defects during the gate:

- LM Studio runtime 2.28.2 rejected its tensor count (`expected 417, got 408`).
- LM Studio runtimes 2.29.0, 2.31.2, and 2.32.0 loaded it but terminated prompt
  evaluation on a missing Apple Metal expert-matrix kernel.

The same LM Studio-supplied 2.32.0 runtime and unchanged GGUF completed when
started on loopback with GPU layers, operation offload, and KV offload
disabled. The final gate used LM Studio normally for Qwen on port 1234 and the
bounded CPU-safe runtime service for Nemotron on port 1235. That service had no
web UI or tool execution, was stopped after the fixture, and is reproducible
through `scripts/g04/run_nemotron_cpu_service.sh`.

No model weights were downloaded, replaced, modified, or added to Git. LM
Studio's original 2.28.2 selection and the original Qwen 8,192-context,
four-parallel load were restored after the gate. The added runtime versions
remain installed side-by-side and are removable.

## Integrity and scope

- G03 remained satisfied and the exact local profile config was unchanged.
- Constitution, acceptance, authority, specification, decision, and work
  protocol hashes were unchanged.
- Raw envelopes, typed products, timing, requests, process samples, negative
  proof, failed probes, and runtime transitions are preserved in this run.
- `runtime/g04/` remains ignored local state.
- No `~/.miter` path was created or changed.
- G05 was not started.

G02 through G04 have now supplied the runtime evidence requested by D-009.
Updating that normative decision status is deliberately outside this bounded
gate.
