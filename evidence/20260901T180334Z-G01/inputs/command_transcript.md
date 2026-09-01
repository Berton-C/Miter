# G01 command transcript

All source and runtime paths were explicit; no branch name was used as the execution identity.

1. Verified a clean Miter `main` at `a9d36e09049c43ae7774df2fea066edf9f25f257` before the opening declaration.
2. Read the official PeTTa README at commit `ae66fa8e41dcd5539d614706bd4e5cfb34f9608d`; it requires SWI-Prolog 9.3 or newer and runs through `sh run.sh <file>`.
3. Inspected the Homebrew formula metadata: SWI-Prolog 10.0.2, native arm64 Tahoe bottle SHA-256 `658967ea1fc58394cd4efeb57b8fa0a2ec5d9a359822655a8657211369d47a87`.
4. Executed `HOMEBREW_NO_AUTO_UPDATE=1 brew install swi-prolog`; exit 0. The installed receipt and complete runtime dependency versions are retained under `raw/`.
5. Created `/private/tmp/miter-g01-petta-ae66fa8`, initialized Git, added `https://github.com/trueagi-io/PeTTa.git`, fetched only the selected full commit, and checked it out detached; exit 0.
6. Recorded the exact Git commit, tree ID, remote, clean status, and SHA-256 manifest for all 230 tracked source files.
7. Inspected `run.sh`. It directly invokes `swipl`; the optional `build.sh` performs unrelated MORK/FAISS network builds and was not executed.
8. Executed `sh -x /private/tmp/miter-g01-petta-ae66fa8/run.sh /Users/claritymiter/miter/tests/fixtures/minimal.metta`; exit 0, final scalar `5`.
9. Executed the same fixture again in a separate process; exit 0 and byte-identical stdout.
10. Ran `scripts/g01/verify_g01.sh` with expected `5`; the first attempt exposed an ANSI-normalization defect and failed. That result is retained under `raw/verifier_attempt1_*`.
11. Corrected ANSI normalization without changing runtime output. The canonical verifier then passed expected `5`; the otherwise-identical severed arm rejected expected `6` with exit 1.
12. Rechecked the PeTTa checkout: detached and clean after both executions.
