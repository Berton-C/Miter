# G31 P3 R4 — register the qualified membrane through PeTTa's explicit import library

Attempt 331 proved that the P3 bootstrap never loaded the PeTTa definition of `import_prolog_functions_from_file`. R4 adds the same explicit `(library lib_import)` bootstrap dependency already used by the passing G30 boundary.

The correction grants no new capability. It only registers the R3-qualified wrapper and effect-free readiness predicate through PeTTa's documented import path. A fresh preflight must reduce the readiness call to literal `true` while leaving the one-call claim absent; only then may the unchanged source-grounded request proceed.
