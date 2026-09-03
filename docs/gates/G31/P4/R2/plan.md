# G31 P4 R2 — preserve native state losslessly in the durable journal

Attempt 101 established that the candidate's native state is richer than JSON's value grammar. R2 changes only the carrier: the complete ground state is serialized with SWI-Prolog's quoted canonical term representation, while cursor, candidate hash, and schema remain separate typed JSON fields.

The restart worker must read the journal, parse the term under safe syntax options, reproduce the original ground term exactly, and verify the independent cursor/hash fields. Only then may the unchanged loopback, panic, rollback, and native causal trials proceed.
