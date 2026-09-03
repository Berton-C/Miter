# G31 P4 R2 — Attempt 102 outcome

`FAIL-PRESERVED`. The candidate remained byte-identical and the repaired transport stopped before writing `cursor.json`, opening a loopback socket, or making any request. The R2 requirement that candidate state satisfy Prolog `ground/1` was incompatible with SWI-Prolog's normal anonymous-dictionary representation: even closed dictionaries carry a variable as their anonymous tag.

The failure does not justify flattening state into JSON or accepting arbitrary open terms. R3 must distinguish anonymous dictionary tags from variables in actual state values, encode a numbered copy canonically, reconstruct the same term variant in the child, and fail closed if any variable occurs outside a dictionary tag.
