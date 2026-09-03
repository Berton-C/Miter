# G29 R1 outcome — retained failure, no promotion

R1 successfully decomposed the local-model rendering into design, bridge, and test products. Native MeTTa assembled the exact products, and independent byte checks confirmed their lineage, quarantine, lack of credentials, and lack of direct Soul or Chroma access.

The first behavioral execution defeated qualification. SWI-Prolog reported a syntax error and missing exported predicate in the bridge, while the test file used invalid PLUnit directive forms. It also exposed a mechanical verifier defect: SWI-Prolog can report load errors on stderr while returning exit status zero. The verifier now treats any `ERROR:` diagnostic as failure, and a native replay returns `(surface-candidate-syntax 1 1 false)` for the retained R1 candidate.

The exact failed candidate remains under `evidence/G29/attempt-107/` and is not promoted. The unused fourth R1 model-call claim remains unspent. Because both separately generated artifacts require repair, one single-part repair cannot complete the candidate. R2 therefore preserves all useful R1 products and requests only the two evidence-selected replacement artifacts.

This is not a G29 closure. G29 remains open until the revised candidate passes syntax, its model-authored tests, independent causal controls, and the G29 contract verifier. G30 remains a separate mock-service trial.
