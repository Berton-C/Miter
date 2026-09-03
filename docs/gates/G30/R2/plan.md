# G30 R2 — normalize durable identity types at the membrane

R1 proved the complete inbound phase, durable state write, and invocation of a fresh restart process. The worker failed before candidate re-entry because JSON string identities were not translated back into the atom-valued surface contract.

R2 permits only explicit normalization of the stored schema, event IDs, effect IDs, and idempotency keys during readback, plus selection of this frozen plan for a fresh attempt. It changes no raw evidence, candidate, fixture, native obligation, severed transform, or expected behavior.
