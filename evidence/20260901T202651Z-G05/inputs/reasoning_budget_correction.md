# Explicit bounded-reasoning correction

The first fixed-parameter bakeoff used the providers' implicit `auto` reasoning
mode. This allowed both models to consume the complete 1,024-token attempt
budget before closing—or, for Nemotron, before beginning—the required JSON
product. The auto-reasoning arms are preserved under `raw/probes/`.

The final corpus declares `reasoning_effort: none` in every request for both
profiles. Current `llama.cpp` maps this OpenAI-compatible request field to
disabled template thinking. This makes the attempt budget govern the requested
bounded artifact rather than an unbounded private trace.

The prompt corpus, response schema, content requirements, expected completion
status, uncertainty bounds, temperature, top-p, seed, repetitions, and scoring
rules are unchanged. Provider products remain inert and must still pass the
same strict parser.
