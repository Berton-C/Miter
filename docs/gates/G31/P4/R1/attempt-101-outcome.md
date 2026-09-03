# G31 P4 R1 attempt 101 — native state did not fit the JSON journal carrier

The P4 authorship audit passed: the exact P3 candidate was copied without modification, and the generic transport source contains none of the fixed fixture's destination-specific endpoint, event, or identity-field literals.

The canonical trial admitted the authorized frame, rejected an unauthorized payload-free frame before parsing, constructed the candidate effect descriptor, and durably wrote the pending-effect journal. It then stopped before starting the loopback server. The cursor journal tried to place the complete native candidate state directly into JSON; the state's valid Prolog pair term (`effect-1-stable-key-1`) is not a JSON term, so the writer raised a typed encoding error.

No loopback request, model call, credential lookup, Mattermost request, message effect, activation, or promotion occurred.

P4 R2 will preserve the complete state as an opaque quoted native term string and retain the cursor/hash as separately typed fields. The fresh child process must read that representation back exactly; no semantic interpretation moves into Prolog or JavaScript.
