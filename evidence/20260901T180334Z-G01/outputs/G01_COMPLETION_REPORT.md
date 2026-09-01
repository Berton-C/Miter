# G01 completion report

## Verdict

**PASS.** Canonical PeTTa commit `ae66fa8e41dcd5539d614706bd4e5cfb34f9608d` executes reproducibly under native arm64 SWI-Prolog on this Mac.

## Proven baseline

- Host runtime: SWI-Prolog 10.0.2 for `arm64-darwin`, installed from the Homebrew arm64 bottle.
- PeTTa source: `https://github.com/trueagi-io/PeTTa.git`, detached at the selected full commit.
- Source integrity: clean Git tree and a SHA-256 manifest covering all 230 tracked files.
- Fixture: `tests/fixtures/minimal.metta`, containing `!(+ 2 3)`.
- Canonical observation: final scalar `5`, runtime exit 0.
- Repeat observation: byte-identical stdout and exit 0 in a second process.
- Positive verifier: expected `5`, observed `5`, PASS.
- Severed verifier: expected `6`, observed `5`, FAIL with nonzero exit as required.
- Launcher trace: native `swipl` only; no `python`, `python3`, Janus call, or `py-call` appeared in the fixture or execution trace.

PeTTa is source-executed rather than compiled for this minimal baseline. Its optional `build.sh` adds MORK/FAISS integrations through unpinned external clones and is not required by the standard launcher, so it was not run.

## Scope and next gate

D-O01 is resolved to the canonical commit above. No Miter cognition, effect membrane, runtime root, or service client was implemented. G02 was not begun.
