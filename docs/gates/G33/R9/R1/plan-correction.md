# G33 R9 R1 plan-package correction

The original R9 plan put the three explicitly mutable repair targets in both
`allowed_paths` and `preserved`. The fidelity checker therefore—and
correctly—refused to open the package as soon as an unexecuted source draft
changed one of those files.

No native test was run and no source draft was retained. The three files were
restored byte-for-byte to their R8 state. R1 preserves the original bounded
claim and scope, records those bytes under `mutable_baseline`, and removes only
those intended targets from the immutable `preserved` set. All semantic source,
controls, prior evidence, and unrelated work remain protected.
