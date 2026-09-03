# G30 R1 outcome — phase one passed; restart rehydration type mismatch

R1 corrected only the mock's unsupported null sentinel. The unchanged candidate then completed phase one: one authorized canonical event, no duplicate event, one edited event, no unauthorized event, authorization before payload access, stable identities, and durable cursor `200` with both event versions recorded.

The required fresh SWI-Prolog child process started and read the durable JSON file, but its state rehydration compared JSON string identities directly with atom-valued candidate identities. The worker therefore exited `1` before reconnect/effect behavior and emitted no native result. This is a mechanical representation mismatch in the builder mock, not evidence for or against the candidate's post-restart behavior. No model, credential, network, activation, promotion, or candidate change occurred.

R2 may normalize only the schema, seen-event identities, and effect identities/idempotency keys from JSON strings into the atom-valued surface contract. All scenarios, candidate bytes, native obligations, severed transforms, and expected behavior remain frozen.
