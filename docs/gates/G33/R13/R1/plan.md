# G33 R13 R1 — version-aware closure correction

R13 runtime passed after promoting the compact v2 development path. The old
R12 verifier then rejected the changed current default-bootstrap hash. That is
correct historical provenance behavior, but it cannot also be a current-version
regression test.

R1 changes no runtime or evidence. It binds R12 to the exact Git bytes at its
evidence commit and binds v2 to the current R13 freeze and independent verifier.
The captured old-verifier mismatch remains evidence of the version boundary.
Neither version is rewritten, and no semantic test is weakened.
