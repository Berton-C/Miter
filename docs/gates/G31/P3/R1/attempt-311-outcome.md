# G31 P3 R1 attempt 311 — compact handoff works; scalar types differ

R1 removed the multiline parser failure. Native stdout now contains one compact, parse-safe standing with the correct request ID, candidate hash, source version/commit, discrepancies, and envelope values. The builder then rejected the envelope because PeTTa's printed nested scalars decoded as the atoms `"8192"` and `"300"`, while its assertion expected JSON numbers.

No source meaning or value changed. This is an explicit native/builder type-boundary mismatch. No call claim, model request, candidate, credential lookup, Mattermost contact, message effect, activation, or promotion occurred; the original call remains unspent.

R2 will normalize only those two compact diagnostic scalars with exact numeric validation. The full native question, durable source bytes, model grant, and all candidate acceptance conditions remain unchanged.
