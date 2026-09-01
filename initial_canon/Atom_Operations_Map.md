# Atom Operations Map (PeTTa/MeTTa substrate)

**Purpose:** The complete, status-marked map of how atom operations actually behave
in this substrate -- so substrate work (NACE writer, soul writers, any future
primitive) rests on a fully-mapped foundation, not a partly-mapped one. Every cell
is marked PROVEN / ASSUMED / UNKNOWN with its evidence. The UNKNOWN and ASSUMED cells
are the test queue, ordered by danger.
**Status:** LIVING DOCUMENT. Built 2026-06-13 from the N0/N0.5 nugget ladder; ALL
TIER-1 cells PROVEN as of 2026-06-13. Axis 6 (type declarations and reduction
guards) and superpose/partial-table composition cells added 2026-07-30 from the
corner-gate v3 investigation (the full atom-operation ladder ran clean). The
N1 writer pattern is now fully grounded on proven cells (see Section 5). Remaining
open cells are Tier 2-4, lower danger. Fill one cell per clean nugget.
**Method:** each cell is filled by one clean live-loop test against a known-clean
state, both-polarity where applicable, read via a PROVEN read instrument (never an
unverified one), result match-verified in a separate command (never trust a return
value). A cell moves to PROVEN only with an exact recorded result.
**Companion:** `NAL_and_the_Marshal_Boundary_Reference.md` (the |- / marshalling /
persistence findings this map extends); `nace_implementation_plan.md` (the consumer
whose N1 writer this map de-risks).

---

## 0. Evidence legend

- **PROVEN** -- tested live, exact result recorded, reproducible. Safe to build on.
- **ASSUMED** -- believed true from indirect evidence or documentation, NOT cleanly
  tested in isolation. Treat as a hypothesis. Do not build load-bearing logic on it
  until promoted to PROVEN.
- **UNKNOWN** -- not tested, no reliable evidence. A test-queue item.
- **CONTRA** -- two sources disagree (e.g. a documented rule vs an observation);
  needs a disambiguating test to resolve.

Every PROVEN cell cites its evidence inline. Every ASSUMED cell names why it is not
yet PROVEN. The danger ranking (Section 6) is built from the UNKNOWN/ASSUMED/CONTRA
cells.

---

## 1. The read instrument (Axis 5) -- must be solid FIRST

You cannot trust any operation test if you cannot trust the read that verifies it.
This axis is mostly PROVEN, which is why the rest of the map is testable.

| Read need | Pattern | Status | Evidence |
|---|---|---|---|
| Presence check (does an atom exist) | `(match &self (head ...) found)` -> `found` / `[]` | PROVEN | before-import `[]` vs after-import 3x `found`; clean both-polarity |
| Read one scalar from an stv | `(match &self (cap-efficacy NAME (stv $s $c)) $s)` -> `['0.5']` | PROVEN | returned `['0.5']` / `['0.0']` clean, no throw |
| Read the whole stv tuple | `(match &self (cap-efficacy NAME $tv) $tv)` | PROVEN (fails) | throws `type_error string` with value leaked inside; tuple render chokes |
| Read tuple via destructure-in-pattern | `(match &self (cap-efficacy NAME (stv $s $c)) ($s $c))` | PROVEN (fails) | also throws-with-leak; destructuring in return position does not help |
| Clean count of atoms under a head | scalar/symbol read, count the list length | PROVEN | match-count = atom-count confirmed: `(cap-efficacy $name ...)` returned web-search 3x while file-write/metta-query 1x each (the untouched controls) -- list length IS atom count for scalar/symbol returns |
| Read a COMPLETE atom (all fields) cleanly | ??? | UNKNOWN | scalar reads work field-by-field; no proven single-read whole-atom (tuple return throws). Read fields individually instead |
| Read all atoms of a head, one field each | `(match &self (cap-efficacy $x (stv $s $c)) $x)` -> list of names | PROVEN | returned `['web-search','web-search','file-write','metta-query']` clean (names are bare symbols, not tuples) |

**Read-instrument rule (PROVEN):** bare scalars and bare symbols render clean; any
return that carries an `(stv ...)` tuple (or any nested compound) throws-with-leak.
So: read fields individually as scalars/symbols, never return a nested compound.
COUNT by list length of a scalar/symbol read (match-count = atom-count, proven via
the untouched-control method). Whole-atom-single-read is still UNKNOWN (D2) but
unnecessary -- read fields individually.

---

## 2. Operation x cardinality (Axis 1 x Axis 2) -- where the danger lives

For each operation, behavior when the pattern matches ZERO / ONE / MANY atoms. This
is the core of the map and the most under-filled.

### match (read/query)

| Cardinality | Behavior | Status | Evidence |
|---|---|---|---|
| 0 match | returns clean `[]` | PROVEN | repeated clean empties throughout N0 ladder |
| 1 match | returns single clean result (if scalar/symbol return) | PROVEN | `['0.5']` |
| many match | returns all bindings as a list | PROVEN | `['0.5','0.3']` and `['web-search','web-search',...]` -- returns ALL, one per matching atom |

match is the best-mapped operation. Note: "many" returns every binding, so a
duplicate atom is VISIBLE as a repeated value -- this is how duplicates get detected.

### add-atom (create)

| Cardinality / case | Behavior | Status | Evidence |
|---|---|---|---|
| add a NEW atom (no identical exists) | creates, persists in-process | PROVEN | the cap-efficacy seeds; verified by later match |
| add when an IDENTICAL atom already exists | creates a TRUE DUPLICATE -- NOT idempotent | PROVEN (B1) | clean state one web-search at 0.5, add identical, match -> `['0.5','0.5']` (two). add-atom does not dedupe |
| add persists across rebuild | NO -- runtime only; file is source of truth | PROVEN | restart reloads from file, wiping runtime adds |

**B1 RESOLVED: add-atom is NOT idempotent -- it creates true duplicates.** Adding an
atom identical to one already present yields two copies. So add-atom is itself a
duplicate source; any writer that adds without first clearing the old can accumulate
duplicates. This is why the writer pattern is remove-then-add, never add-alone.

### remove-atom (delete)  <-- HIGHEST DANGER, we rely on this for the writer

| Cardinality | Behavior | Status | Evidence |
|---|---|---|---|
| 0 match | error? no-op? returns false? | **UNKNOWN** | never isolated removing a non-existent atom (low priority now -- the writer's variable pattern always matches if any atom exists) |
| 1 match | removes it cleanly | PROVEN | implied + confirmed by the many-match and variable tests; remove returns `'true'`, atom gone |
| **many identical match (literal pattern)** | removes ALL in one call | PROVEN (A1) | two identical web-search at 0.5, single `remove-atom` literal -> match `[]` (zero). Removes ALL matching, not one |
| **many at DISTINCT values (variable pattern `$v`)** | removes ALL regardless of value or count | PROVEN | three web-search (one 0.5, two 0.8), single `(remove-atom &self (cap-efficacy web-search $v))` -> match `[]`. Cleared all three across two values |

**A1 RESOLVED, and the variable pattern too -- this is the writer's safe pattern,
fully proven.** `remove-atom` removes ALL matching atoms in one call. With a LITERAL
pattern it clears all exact matches; with a VARIABLE in the value position
`(cap-efficacy NAME $v)` it clears ALL atoms for that capability regardless of value
or count. So "remove-then-add" is a SELF-HEALING clean-swap: `remove (cap-efficacy X
$v)` clears whatever exists (one, many, stale-valued), then `add (cap-efficacy X new)`
places exactly one. From ANY prior state the writer lands at exactly one correct
belief. The duplicate-corruption risk is structurally eliminated by remove-all
semantics. THE WRITER REMOVES BY VARIABLE VALUE, never by the literal old value
(a literal that does not match current state would remove nothing).

### set-atom! (replace / upsert)

| Cardinality (source pattern) | Behavior | Status | Evidence |
|---|---|---|---|
| source matches 0 | does NOT replace, does NOT fail -- CREATES a new atom | PROVEN | controlled test: source `(stv 0.7 0.7)` absent, returned `'true'`, post-match `['0.5','0.3']` -- new atom created |
| source matches 1 | replaces it in place | PROVEN | the N0.5 gate test: 0.5 0.0 -> 0.9 0.2, read-back showed new value |
| source matches many | replaces which? one? all? errors? | **UNKNOWN** | never tested set-atom! with a source matching 2+ atoms |

**set-atom! is upsert-toward-create on non-match (PROVEN, contradicts the older
"requires exact match" rule).** This is why set-atom!-with-source-pattern is unsafe
for the writer: in a revision loop the source (old value) may not exactly match, and
a non-match silently CREATES rather than no-ops. **Queue item C1 (set-atom! on many):**
unknown and reachable -- if a duplicate exists and the writer set-atom!s, what happens?

### |- and |-nal (compute / derive)

| Case | Behavior | Status | Evidence |
|---|---|---|---|
| `|-` compute a derivation | computes correct NAL truth values | PROVEN | three exact multiplicative-confidence deductions |
| `|-` persist the derivation | does NOT persist; computes only | PROVEN | premises committed, A->C computed 0.81, match empty |
| `|-` vs `|-nal` | `|-` is the calculator; `|-nal` calls Truth_Revision (lib_nal) | ASSUMED/PROVEN-split | `|-nal`-not-`|-` documented + |- non-persist proven; `|-nal` live-reduction proven per NACE plan, but the |- vs |-nal relationship not re-tested this session |
| `|-nal` reduces outside live loop | NO -- live loop only (lib_nal load) | PROVEN | per NACE plan, run.sh echoes unreduced |

---

## 3. Composition (Axis 3) -- behavior inside let / collapse, same vs across cycle

| Composition case | Behavior | Status | Evidence |
|---|---|---|---|
| read -> modify -> read, SAME cycle (RMW) | composes; same-cycle read sees the write | PROVEN | N0.5 gate: set-atom! then same-command scalar read returned `['0.9']` |
| write commits across cycle boundary | YES (in-process persistence) | PROVEN | persist-check next-command showed revised value |
| a throwing read inside a `let` chain | leaks value in error; chain behavior otherwise | ASSUMED | the stale Nugget 7 leaked `$before -> $after` inside a type_error; not cleanly characterized whether the chain completed or partial-failed |
| `collapse (eval ...)` over a command | materializes nondet stream; raw commands inside clause bodies EXECUTE | PROVEN | Repair-1 physics (collapse in clause body invokes reduce) |
| `set-atom!` return value | returns `'true'` on success | PROVEN | controlled test returned `['true']` |
| trust the return value of a write | NO -- return can differ from stored state | PROVEN | the discipline that caught multiple errors; match-verify separately always |

**Queue item E-comp (throwing-read-in-chain):** characterize what a `let` chain does
when a binding step throws -- does the chain abort, bind the error term, or continue?
Matters because the writer composes reads and writes in chains.


++++++++++++++(Berton_C --> THIS SECTION NEEDS REVIEW)++++++++++++++++
### Composition (Axis 3) -- nested application reduction in a let BIND

| Case | Behavior | Status | Evidence |
|---|---|---|---|
| core form nested in a bind: (collapse (match ...)) | REDUCES (findall) | PROVEN | getContext $results bind compiled to findall(E, match(...), D) |
| ordinary fn, arg is a VALUE: (size-atom $v), (string_length $v) | REDUCES (real call) | PROVEN | p-dsize size-atom($s,D); loop marker string_length(F,I) |
| ordinary fn, arg is a CALL: (string_length (py-str (getSkills))) | DOES NOT REDUCE -- compiled to inert DATA, only innermost runs | PROVEN | p-flat: A=[string_length,[py-str,B]], getSkills(B). string_length/py-str never called |
| nested application in TAIL/body: (string-safe (py-str (...))) | REDUCES + sequences | PROVEN | getContext body: py-str([...],U), string-safe(U,B) |

RULE: in a let BIND, an ordinary function whose argument is itself a function
call is NOT reduced -- it becomes a silent data term (no error), only the
innermost reducible piece runs. Core forms (collapse/match/let/if) compose
nested fine. To compute (f (g x)) with ordinary f,g in a bind, sequence:
(let $gx (g x) (let $r (f $gx) ...)). Silent: produces wrong data, not an error.
++++++++++++++(END)++++++++++++++++


### Composition additions -- superpose choice points, partial tables, failing bindings (added 2026-07-30, corner-gate v3 arc)

| Composition case | Behavior | Status | Evidence |
|---|---|---|---|
| bare `(let $x (superpose $list) ...)` in a let* bind | N members = N Prolog solutions; choice points stay OPEN and escape to the CALLER's let* | PROVEN | T58 cardinality probe; production log: replay count tracked to-remove member count exactly (1, 2, 3; later samples grew as consecutive-pair sums 3+4, 5+6, 7+8) |
| downstream failure with open choice points upstream | failure-driven backtracking REPLAYS the segment between the superpose bind and the failure point, once per remaining solution; presents as balanced repeating trace segments with the iteration counter frozen (body never completes) | PROVEN | production: TRACE 172/175/176 triplets repeating, 178 never reached, body re-entering at iteration 1 |
| collapse-wrapped superpose-remove (guard-empty first) | exactly one solution; containment total | PROVEN | Phase A / A.1 v2 probes all-pass; live steady state one triplet per cycle at 9-member snapshots |
| `(superpose ())` in a let bind | ZERO solutions; halts the let* before anything downstream | PROVEN | 2026-06-04 fix-era comment block plus this arc's re-derivation; the guard-empty-first shape exists for this reason |
| bare call to a PARTIAL clause table (no matching clause for the input) | silent Prolog failure; kills the enclosing let* with no error text | PROVEN | guard probe T2: line absent for the clause-less input while T1 matching-input control reduced |
| `collapse` over a defined-but-unmatched call | returns clean `()`, not an error; the safe guard shape for partial tables | PROVEN | guard probe T3 printed the collapse-guarded default |
| a FAILING (non-throwing) binding inside a let* chain | aborts the whole chain silently; later bindings never run; no partial results | PROVEN | the corner-gate death corridor; sentinel bisection showed a clean stop at the failing binding, nothing after |

**Superpose containment rule (PROVEN):** any superpose iteration inside a let* must
be collapse-wrapped unless downstream multiplication is intended; the certified shape
is guard-empty-first then collapse-wrap (per do-clear-state-delta! 2026-06-04, applied
repo-wide by the 2026-07-29 audit). Note the throwing case is DIFFERENT from the
failing case (see E-comp in the queue): failure is now PROVEN to abort silently and
completely; the throw-with-leak case remains its own open cell.

---

## 4. Persistence (Axis 4) -- runtime atomspace vs file

| Persistence question | Behavior | Status | Evidence |
|---|---|---|---|
| runtime mutation touches the seed file | NO | PROVEN | file unchanged through atomspace tests; restart reloaded clean seeds |
| restart reloads from file, wipes runtime | YES | PROVEN | crash-restart wiped the duplicate, reloaded 3 clean seeds; deliberate restart confirmed clean |
| add/set/remove persist within process life | YES | PROVEN | add+set+remove all verified by later match within a process life |
| `|-` derivations persist | NO | PROVEN | computes, does not store |
| **file path resolution** | CWD is `/PeTTa`; relative paths resolve to `/PeTTa/soul/` (wrong); MUST use absolute paths | PROVEN | `shell pwd` -> `/PeTTa`; relative `read-file soul/...` -> `[]` (not-found); absolute `/PeTTa/repos/omegaclaw/soul/nace_beliefs.metta` -> content |
| **write -> restart -> load round-trip (E-dual core)** | write-file to the absolute path lands in the file the boot import loads | PROVEN | appended `(cap-efficacy persist-marker-test (stv 0.42 0.42))` to the file, restart, atomspace match -> `['0.42']`. The writer-rewrites-the-file persistence model WORKS |
| file restore via overwrite | write-file overwrite-whole + read-back verify | PROVEN | restored 3 clean seeds via write-file, read-back confirmed exactly 3 lines, marker gone |
| dual-write mid-crash atomicity | file + atomspace can diverge on mid-write crash | UNKNOWN | not tested; v1-acceptable boundary per NACE plan (restart reverts to last-good file) |
| file is the source of truth, runtime is disposable | YES | PROVEN | restart-reset behavior; round-trip confirms file drives the load |

**E-dual core RESOLVED:** the writer persists a revision by rewriting
`nace_beliefs.metta` at the ABSOLUTE path `/PeTTa/repos/omegaclaw/soul/nace_beliefs.metta`;
the boot import loads it on restart. Proven by the marker round-trip. Mid-write-crash
atomicity remains UNKNOWN but is a v1-acceptable boundary (restart reverts to
last-good file). The writer MUST use absolute paths -- a relative path writes to a
nonexistent `/PeTTa/soul/` and the revision silently vanishes.

---

## 4.5. Type declarations and reduction guards (Axis 6) -- added 2026-07-30

Filled from the corner-gate v3 investigation (probes N0-N5, guard-isolation probe
P1-P4, declared-symbol probe D1-D3, A.1 v2 bisect; raw compile traces retained).
Environment: PeTTa on SWI-Prolog 9.2.4 x86_64-linux. Numbered 4.5 to avoid
renumbering the sections below.

| Case | Behavior | Status | Evidence |
|---|---|---|---|
| get-type on an UNDECLARED bare symbol | `%Undefined%`, never Atom | PROVEN | N4: `(get-type intention)` -> `%Undefined%` |
| get-type on a DECLARED symbol | the declared type | PROVEN | D1: with `(: alpha Atom)`, `(get-type alpha)` -> `Atom` |
| get-type on constructor term, Number args | reduces to declared return type | PROVEN | N1: `(get-type (mk-pbit 0.9 0.7))` -> `pbit` |
| get-type on constructor term, UNDECLARED-symbol args | does NOT reduce; returns unreduced arrow form with `%Undefined%` in the symbol slots | PROVEN | N2: `((-> Atom Atom pbit qalignment) %Undefined% %Undefined% pbit)` |
| get-type on constructor term, DECLARED-symbol args | reduces to declared return type | PROVEN | D2: `(get-type (mk-t alpha alpha))` -> `tsym` with `(: alpha Atom)` present |
| get-metatype on a compound / a symbol | `Expression` / `Symbol` (never a user type) | PROVEN | P3 -> `Expression`, P4 -> `Symbol` |
| call-site compilation of a TYPE-DECLARED function | transpiler wraps EVERY call site: per-argument guards AND a return-value guard, shape `('get-type'(X, T) *-> true ; 'get-metatype'(X, T))` | PROVEN | compile trace: p1 clause carries pre-call and post-call guards; production derive-support carried eleven |
| call-site compilation of an UNTYPED function | bare call, no guards | PROVEN | p2 clause: `'u-pass'([...], A).` only |
| function BODY compilation, typed vs untyped | identical (guards are call-site only) | PROVEN | `'t-pass'(A, A).` and `'u-pass'(A, A).` byte-identical in the trace |
| typed call, argument contains an UNDECLARED symbol | SILENT clause failure: no output, no error, no warning; enclosing let* dies | PROVEN | P1 absent while byte-identical untyped control P2 printed; error/warn grep over the full raw trace: zero matches |
| typed call, argument symbols DECLARED | passes end to end | PROVEN | D3 printed `(mk-t alpha alpha)` |
| failing goal is the GUARD (not head, not body, not argument evaluation) | yes, by exhaustive elimination | PROVEN | single-variable differential (declaration only), identical compiled bodies, inert data argument in both clauses, zero errors; the only differing goals are the guards |
| collapse-wrapping a typed call rescues it | NO -- it only converts the death into a clean empty collapse (a usable guard, not a fix) | PROVEN | S7/S12 collapse-guarded typed calls yielded not-computed every cycle in A.1 while the arithmetic bypass restored real values |
| return guard alone kills on an untypable return value | plausible second kill surface | ASSUMED | the return guard EXISTS in the trace (proven); a case where argument guards pass and the return guard alone fails has never been isolated |
| typed function receiving an unbound VARIABLE argument | ??? | UNKNOWN | all probes passed ground terms |
| nested declared constructors (a declared type in an INNER argument position failing) | ??? | UNKNOWN | only one nesting level tested; the tested inner position (pbit inside qalignment) was the passing kind |
| runtime-generated symbols (cannot be pre-declared) in typed positions | presumed to hit the undeclared-symbol failure | ASSUMED | follows from the undeclared-symbol cell; never tested with genuinely runtime-minted symbols |

**Axis-6 rule (PROVEN):** a type declaration on a function converts every call site
into guarded compilation; any argument (or return) that get-type cannot reduce to the
declared type AND whose metatype is not that type fails BOTH guard disjuncts, and the
`*->` soft-cut makes that failure SILENT clause death, indistinguishable from a
declined polymorphic branch (Clarity's framing: type resolution compiled as control
flow, so invalid-program collapses into wrong-branch-tried). Practical consequences:
(1) never route adapter logic through type-declared functions whose signatures carry
Atom positions unless every symbol fed in carries its own type declaration;
(2) two valid repairs exist -- declare the symbols' types, or bypass the typed path
with an equivalent untyped computation (the corner-gate fix used the arithmetic
bypass; the declaration route was viable and was not taken);
(3) a typed corridor dying silently is localized by sentinel bisection, not by
reading. Upstream report drafted 2026-07-30 (silent-failure-instead-of-type-error
framing, non-fatal-warning suggestion).

---

## 5. What is PROVEN, consolidated (safe to build on today)

- Read instrument: scalar/symbol reads clean; tuple reads throw-with-leak; `found`
  presence check clean; `match` returns all bindings; match-count = atom-count
  (count by list length of a scalar/symbol read).
- `match`: 0 -> `[]`, 1 -> clean, many -> all bindings. Fully mapped.
- `add-atom`: creates a new atom; NOT idempotent -- adding an identical atom makes a
  true duplicate (B1 proven). Persists in-process, not across rebuild.
- `remove-atom`: removes ALL matching in one call -- literal pattern clears all exact
  matches; VARIABLE-value pattern `(cap-efficacy NAME $v)` clears ALL for the
  capability regardless of value or count (A1 + variable proven).
- `set-atom!`: source-matches-1 replaces; source-matches-0 CREATES (upsert). Source-
  matches-many UNKNOWN (C1). Use remove-then-add, not set-atom!, for the writer.
- `|-`: computes correct NAL, does NOT persist; `add-atom` is the only commit.
  `|-nal` reduces live-loop only.
- RMW composes same-cycle; writes commit across the boundary; return values are NOT
  trustworthy (match-verify separately).
- Persistence: runtime disposable, file is source of truth, restart reloads clean.
  CWD is `/PeTTa` -> file ops MUST use absolute paths. Write -> restart -> load
  round-trip PROVEN (write-file to the absolute path lands in what the boot import
  loads). File restore = write-file overwrite + read-back verify.

- Superpose in a let* bind: N solutions, open choice points escape to the caller;
  downstream failure replays the intervening segment per solution. Containment =
  guard-empty then collapse-wrap (certified shape, repo-wide as of 2026-07-29).
- Partial clause tables: a bare unmatched call is a silent let*-killer; collapse
  over the call returns clean `()` (the guard shape). A failing binding aborts a
  let* chain silently and completely (distinct from the still-open throwing case).
- Type declarations (Axis 6, Section 4.5): typed call sites are guard-wrapped;
  undeclared-symbol arguments fail both guard disjuncts silently; declared-symbol
  arguments pass; collapse does not rescue a typed call, it only absorbs the death.

### The N1 writer, fully grounded on the proven cells above

Every step rests on a PROVEN cell, not an assumption:

```
do-process-pending-revisions! (per capability X with outcome):
  1. read current belief        -> scalar reads (clean): current freq/conf of X
  2. compute revised stv        -> |-nal / Truth_Revision (live-loop only)
  3. remove-atom (cap-efficacy X $v)   <- VARIABLE value: clears ALL copies of X,
                                           any value, any count (self-healing)
  4. add-atom (cap-efficacy X revised-stv)   <- places exactly ONE
  5. write-file the absolute path /PeTTa/repos/omegaclaw/soul/nace_beliefs.metta
                                 <- persists across restart (round-trip proven)
```

Why each choice: remove-then-add (not set-atom!) because set-atom! upserts-on-non-
match and a revision loop's source value drifts. Variable-value remove (not literal)
because the writer does not know the exact current stv. Remove-ALL semantics make the
swap self-healing against any pre-existing duplicates. Absolute path because CWD is
`/PeTTa`. Step 1 reads scalars individually because tuple reads throw. The duplicate-
corruption risk is structurally eliminated. The only remaining writer-design caution
is mid-write-crash atomicity (file+atomspace divergence), a v1-acceptable boundary.

## 6. The test queue -- remaining UNKNOWN cells (Tier 1 fully cleared)

All TIER 1 cells are now PROVEN. Remaining items are lower-danger:

**TIER 2 (minor, do during N1 build if relevant):**

- **A0 -- remove-atom on ZERO match: no-op, error, or false?** Low priority now: the
  writer's variable pattern matches if any atom exists, and remove-all means it never
  leaves a partial state. Worth a one-line confirm that removing a non-existent atom
  does not error.
- **C1 -- set-atom! when source matches MANY.** Moot for the writer (it uses remove-
  then-add, not set-atom!), but a real cell for completeness.
- **E-comp -- throwing-read inside a `let` chain**: does the chain abort/continue/
  bind-error? Matters if the writer composes reads and writes in one chain; safer to
  keep them as separate commands (which we proved works). PARTIAL RESOLUTION
  2026-07-30: the FAILING (non-throwing) case is now PROVEN -- a failing binding
  aborts the chain silently and completely (Section 3 additions). The THROWING
  case remains open; the two cases need separate cells.
- **F-ret (Axis 6) -- isolate the return guard**: construct a case where argument
  guards pass and the return-value guard alone fails; confirms the second kill
  surface currently ASSUMED.
- **F-var (Axis 6) -- typed call with an unbound variable argument**: behavior
  UNKNOWN; all probes passed ground terms.
- **F-nest (Axis 6) -- nested declared constructor failing in an INNER position**:
  only one nesting level tested, and the tested inner position was the passing kind.
- **F-mint (Axis 6) -- runtime-minted symbols in typed positions**: presumed to hit
  the undeclared-symbol failure; never tested with genuinely runtime-generated
  symbols.
- **E-dual-atomicity -- mid-write-crash** file+atomspace divergence. v1-acceptable
  boundary; revisit for durability.

**TIER 3 (instrument completeness, optional):**

- **D2 -- clean whole-atom single-read** (all fields at once). Unnecessary -- read
  fields individually as scalars. (D1 count idiom is now PROVEN: list length of a
  scalar read.)

**TIER 4 (no live test needed -- but the CONTRA is a SAFETY correction, do it promptly):**

- **CONTRA-setatom -- the existing documented rule is WRONG in a dangerous direction;
  correct it promptly.** The task-state constraint catalog says (C-Set-Atom-Match)
  that `set-atom!` "requires exact match." The PROVEN behavior is: set-atom! requires
  a match TO REPLACE, but on a NON-match it CREATES a new atom rather than no-oping.
  This is not housekeeping -- it is a latent landmine. Anyone who reads the old rule
  and writes `set-atom!` expecting a no-op when the source does not match will instead
  get SILENT ATOM CREATION (a duplicate where they expected nothing). That is exactly
  the failure that produced duplicate beliefs in this investigation. No live test is
  needed (the behavior is already PROVEN), which makes the fix cheap -- so there is no
  reason to defer it. Correct the C-Set-Atom-Match entry in the task-state constraint
  catalog to: "set-atom! requires a matching source TO REPLACE; on a non-matching
  source it CREATES a new atom (upsert), it does NOT no-op. Do not use set-atom! with
  a possibly-stale source pattern -- use remove-by-variable then add." (Credit: Clarity
  flagged that this is a safety correction, not a doc-fix.)

## 7. How filling a cell works (the per-nugget protocol)

For each queue item:
1. Establish KNOWN-CLEAN state (restart reloads clean from file is the cheapest reset).
2. State the expected result for BOTH polarities before running.
3. Run ONE properly-parenthesized command (mutations never batched -- a malformed
   batch crashed the container once; single fully-wrapped `(metta "(cmd ...)")` only).
4. Verify the result with a PROVEN read instrument in a SEPARATE command (never trust
   the mutation's return value).
5. Record the exact result in the cell; mark PROVEN with evidence, or record the
   surprise as its own nugget.
6. Re-establish clean state (restart) before the next cell if the test mutated state.

The map is complete when every TIER 1 and TIER 2 cell is PROVEN. At that point the
NACE writer (and any future atom-manipulating primitive) rests on a fully-mapped
foundation: every operation's behavior on every cardinality is known, not assumed.



Apendix A:

### June 25 2026 Artifact #1:
(bcb) clarityclaw-omega% docker exec clarity_omega sh -c 'f=$(find /PeTTa/repos/omegaclaw -name "lib_nal*" -not -path "*/staging/*" -not -path "*/shared_files/*" 2>/dev/null | head -1); echo "FILE: $f"; echo "=== operator definition lines containing |- ==="; grep -n "(= (|-" "$f"; echo "=== all |-nal references ==="; grep -n "|-nal" "$f" | head -20; echo "=== bare |- references (excluding |-nal) ==="; grep -n "|-" "$f" | grep -v "|-nal" | head -20'
FILE: /PeTTa/repos/omegaclaw/lib_nal.metta
=== operator definition lines containing |- ===
108:(= (|-nal ($T $T1) ($T $T2)) ($T (Truth_Revision $T1 $T2)))
110:(= (|-nal ((--> $a $b) $T1) ((--> $b $c) $T2)) ((--> $a $c) (Truth_Deduction $T1 $T2)))
111:(= (|-nal ((--> $a $b) $T1) ((--> $a $c) $T2)) ((--> $c $b) (Truth_Induction $T1 $T2)))
112:(= (|-nal ((--> $a $c) $T1) ((--> $b $c) $T2)) ((--> $b $a) (Truth_Abduction $T1 $T2)))
113:(= (|-nal ((--> $a $b) $T1) ((--> $b $c) $T2)) ((--> $c $a) (Truth_Exemplification $T1 $T2)))
117:(= (|-nal ((<-> $S $P) $T)) ((<-> $P $S) (Truth_StructuralIntersection $T)))
118:(= (|-nal ((<-> $M $P) $T1) ((<-> $S $M) $T2)) ((<-> $S $P) (Truth_Resemblance $T1 $T2)))
119:(= (|-nal ((--> $P $M) $T1) ((--> $S $M) $T2)) ((<-> $S $P) (Truth_Comparison $T1 $T2)))
120:(= (|-nal ((--> $M $P) $T1) ((--> $M $S) $T2)) ((<-> $S $P) (Truth_Comparison $T1 $T2)))
121:(= (|-nal ((--> $M $P) $T1) ((<-> $S $M) $T2)) ((--> $S $P) (Truth_Analogy $T1 $T2)))
122:(= (|-nal ((--> $P $M) $T1) ((<-> $S $M) $T2)) ((--> $P $S) (Truth_Analogy $T1 $T2)))
123:(= (|-nal ((--> $M $P) $T1) ((<-> $M $S) $T2)) ((--> $S $P) (Truth_Analogy $T1 $T2)))
124:(= (|-nal ((--> $P $M) $T1) ((<-> $M $S) $T2)) ((--> $P $S) (Truth_Analogy $T1 $T2)))
126:(= (|-nal ((--> $S (ExtSet $P)) $T)) ((<-> $S (ExtSet $P)) (Truth_StructuralIntersection $T)))
127:(= (|-nal ((--> (IntSet $S) $P) $T)) ((<-> (IntSet $S) $P) (Truth_StructuralIntersection $T)))
128:(= (|-nal ((--> (ExtSet $M) $P) $T1) ((<-> $S $M) $T2)) ((--> (ExtSet $S) $P) (Truth_Analogy $T1 $T2)))
129:(= (|-nal ((--> $P (IntSet $M)) $T1) ((<-> $S $M) $T2)) ((--> $P (IntSet $S)) (Truth_Analogy $T1 $T2)))
130:(= (|-nal ((<-> (ExtSet $A) (ExtSet $B)) $T)) ((<-> $A $B) (Truth_StructuralIntersection $T)))
131:(= (|-nal ((<-> (IntSet $A) (IntSet $B)) $T)) ((<-> $A $B) (Truth_StructuralIntersection $T)))
135:(= (|-nal ((--> ({} $A $B) $M) $T)) ((--> ({} $A) $M) (Truth_StructuralDeduction $T)))
136:(= (|-nal ((--> ({} $A $B) $M) $T)) ((--> ({} $B) $M) (Truth_StructuralDeduction $T)))
137:(= (|-nal ((--> $M ([] $A $B)) $T)) ((--> $M ([] $A)) (Truth_StructuralDeduction $T)))
138:(= (|-nal ((--> $M ([] $A $B)) $T)) ((--> $M ([] $B)) (Truth_StructuralDeduction $T)))
140:(= (|-nal ((--> (∪ $S $P) $M) $T)) ((--> $S $M) (Truth_StructuralDeduction $T)))
141:(= (|-nal ((--> $M (∩ $S $P)) $T)) ((--> $M $S) (Truth_StructuralDeduction $T)))
142:(= (|-nal ((--> (∪ $S $P) $M) $T)) ((--> $P $M) (Truth_StructuralDeduction $T)))
143:(= (|-nal ((--> $M (∩ $S $P)) $T)) ((--> $M $P) (Truth_StructuralDeduction $T)))
144:(= (|-nal ((--> (~ $A $S) $M) $T)) ((--> $A $M) (Truth_StructuralDeduction $T)))
145:(= (|-nal ((--> $M (− $B $S)) $T)) ((--> $M $B) (Truth_StructuralDeduction $T)))
146:(= (|-nal ((--> (~ $A $S) $M) $T)) ((--> $S $M) (Truth_StructuralDeductionNegated $T)))
147:(= (|-nal ((--> $M (− $B $S)) $T)) ((--> $M $S) (Truth_StructuralDeductionNegated $T)))
149:(= (|-nal ((--> $S $M) $T1) ((--> (∪ $S $P) $M) $T2)) ((--> $P $M) (Truth_DecomposePNN $T1 $T2)))
150:(= (|-nal ((--> $P $M) $T1) ((--> (∪ $S $P) $M) $T2)) ((--> $S $M) (Truth_DecomposePNN $T1 $T2)))
151:(= (|-nal ((--> $S $M) $T1) ((--> (∩ $S $P) $M) $T2)) ((--> $P $M) (Truth_DecomposeNPP $T1 $T2)))
152:(= (|-nal ((--> $P $M) $T1) ((--> (∩ $S $P) $M) $T2)) ((--> $S $M) (Truth_DecomposeNPP $T1 $T2)))
153:(= (|-nal ((--> $S $M) $T1) ((--> (~ $S $P) $M) $T2)) ((--> $P $M) (Truth_DecomposePNP $T1 $T2)))
154:(= (|-nal ((--> $S $M) $T1) ((--> (~ $P $S) $M) $T2)) ((--> $P $M) (Truth_DecomposeNNN $T1 $T2)))
155:(= (|-nal ((--> $M $S) $T1) ((--> $M (∩ $S $P)) $T2)) ((--> $M $P) (Truth_DecomposePNN $T1 $T2)))
156:(= (|-nal ((--> $M $P) $T1) ((--> $M (∩ $S $P)) $T2)) ((--> $M $S) (Truth_DecomposePNN $T1 $T2)))
157:(= (|-nal ((--> $M $S) $T1) ((--> $M (∪ $S $P)) $T2)) ((--> $M $P) (Truth_DecomposeNPP $T1 $T2)))
158:(= (|-nal ((--> $M $P) $T1) ((--> $M (∪ $S $P)) $T2)) ((--> $M $S) (Truth_DecomposeNPP $T1 $T2)))
159:(= (|-nal ((--> $M $S) $T1) ((--> $M (− $S $P)) $T2)) ((--> $M $P) (Truth_DecomposePNP $T1 $T2)))
160:(= (|-nal ((--> $M $S) $T1) ((--> $M (− $P $S)) $T2)) ((--> $M $P) (Truth_DecomposeNNN $T1 $T2)))
164:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> (× $C $B) $R) $T2)) ((--> $C $A) (Truth_Abduction $T1 $T2)))
165:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> (× $A $C) $R) $T2)) ((--> $C $B) (Truth_Abduction $T1 $T2)))
166:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $R (× $C $B)) $T2)) ((--> $C $A) (Truth_Induction $T1 $T2)))
167:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $R (× $A $C)) $T2)) ((--> $C $B) (Truth_Induction $T1 $T2)))
168:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> $C $A) $T2)) ((--> (× $C $B) $R) (Truth_Deduction $T1 $T2)))
169:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> $A $C) $T2)) ((--> (× $C $B) $R) (Truth_Induction $T1 $T2)))
170:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> $C $B) $T2)) ((--> (× $A $C) $R) (Truth_Deduction $T1 $T2)))
171:(= (|-nal ((--> (× $A $B) $R) $T1) ((--> $B $C) $T2)) ((--> (× $A $C) $R) (Truth_Induction $T1 $T2)))
172:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $A $C) $T2)) ((--> $R (× $C $B)) (Truth_Deduction $T1 $T2)))
173:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $C $A) $T2)) ((--> $R (× $C $B)) (Truth_Abduction $T1 $T2)))
174:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $B $C) $T2)) ((--> $R (× $A $C)) (Truth_Deduction $T1 $T2)))
175:(= (|-nal ((--> $R (× $A $B)) $T1) ((--> $C $B) $T2)) ((--> $R (× $A $C)) (Truth_Abduction $T1 $T2)))
179:(= (|-nal ((==> $a $b) $T1) ((==> $b $c) $T2)) ((==> $a $c) (Truth_Deduction $T1 $T2)))
180:(= (|-nal ((==> $a $b) $T1) ((==> $a $c) $T2)) ((==> $c $b) (Truth_Induction $T1 $T2)))
181:(= (|-nal ((==> $a $c) $T1) ((==> $b $c) $T2)) ((==> $b $a) (Truth_Abduction $T1 $T2)))
183:(= (|-nal ((¬ $A) $T)) ($A (Truth_Negation $T)))
184:(= (|-nal ((∧ $A $B) $T)) ($A (Truth_StructuralDeduction $T)))
185:(= (|-nal ((∧ $A $B) $T)) ($B (Truth_StructuralDeduction $T)))
186:(= (|-nal ($S $T1) ((∧ $S $A) $T2)) ($A (Truth_DecomposePNN $T1 $T2)))
187:(= (|-nal ($S $T1) ((∨ $S $A) $T2)) ($A (Truth_DecomposeNPP $T1 $T2)))
188:(= (|-nal ($S $T1) ((∧ (¬ $S) $A) $T2)) ($A (Truth_DecomposeNNN $T1 $T2)))
189:(= (|-nal ($S $T1) ((∨ (¬ $S) $A) $T2)) ($A (Truth_DecomposePPP $T1 $T2)))
191:(= (|-nal ($A $T1) ((==> $A $B) $T2)) ($B (Truth_Deduction $T1 $T2)))
192:(= (|-nal ($A $T1) ((==> (¬ $A) $B) $T2)) ($B (Truth_Deduction (Truth_Negation $T1) $T2)))
193:(= (|-nal ((¬ $A) $T1) ((==> $A $B) $T2)) ($B (Truth_Deduction (Truth_Negation $T1) $T2)))
194:(= (|-nal ($A $T1) ((==> (∧ $A $B) $C) $T2)) ((==> $B $C) (Truth_Deduction $T1 $T2)))
195:(= (|-nal ((¬ $A) $T1) ((==> (∧ $A $B) $C) $T2)) ((==> $B $C) (Truth_Deduction (Truth_Negation $T1) $T2)))
196:(= (|-nal ($A $T1) ((==> (∧ (¬ $A) $B) $C) $T2)) ((==> $B $C) (Truth_Deduction (Truth_Negation $T1) $T2)))
197:(= (|-nal ($B $T1) ((==> $A $B) $T2)) ($A (Truth_Abduction $T1 $T2)))
198:(= (|-nal ((¬ $B) $T1) ((==> $A $B) $T2)) ($A (Truth_Abduction (Truth_Negation $T1) $T2)))
199:(= (|-nal ($B $T1) ((==> $A (¬ $B)) $T2)) ($A (Truth_Abduction (Truth_Negation $T1) $T2)))
201:(= (|- $a $b)
=== all |-nal references ===
108:(= (|-nal ($T $T1) ($T $T2)) ($T (Truth_Revision $T1 $T2)))
110:(= (|-nal ((--> $a $b) $T1) ((--> $b $c) $T2)) ((--> $a $c) (Truth_Deduction $T1 $T2)))
111:(= (|-nal ((--> $a $b) $T1) ((--> $a $c) $T2)) ((--> $c $b) (Truth_Induction $T1 $T2)))
112:(= (|-nal ((--> $a $c) $T1) ((--> $b $c) $T2)) ((--> $b $a) (Truth_Abduction $T1 $T2)))
113:(= (|-nal ((--> $a $b) $T1) ((--> $b $c) $T2)) ((--> $c $a) (Truth_Exemplification $T1 $T2)))
117:(= (|-nal ((<-> $S $P) $T)) ((<-> $P $S) (Truth_StructuralIntersection $T)))
118:(= (|-nal ((<-> $M $P) $T1) ((<-> $S $M) $T2)) ((<-> $S $P) (Truth_Resemblance $T1 $T2)))
119:(= (|-nal ((--> $P $M) $T1) ((--> $S $M) $T2)) ((<-> $S $P) (Truth_Comparison $T1 $T2)))
120:(= (|-nal ((--> $M $P) $T1) ((--> $M $S) $T2)) ((<-> $S $P) (Truth_Comparison $T1 $T2)))
121:(= (|-nal ((--> $M $P) $T1) ((<-> $S $M) $T2)) ((--> $S $P) (Truth_Analogy $T1 $T2)))
122:(= (|-nal ((--> $P $M) $T1) ((<-> $S $M) $T2)) ((--> $P $S) (Truth_Analogy $T1 $T2)))
123:(= (|-nal ((--> $M $P) $T1) ((<-> $M $S) $T2)) ((--> $S $P) (Truth_Analogy $T1 $T2)))
124:(= (|-nal ((--> $P $M) $T1) ((<-> $M $S) $T2)) ((--> $P $S) (Truth_Analogy $T1 $T2)))
126:(= (|-nal ((--> $S (ExtSet $P)) $T)) ((<-> $S (ExtSet $P)) (Truth_StructuralIntersection $T)))
127:(= (|-nal ((--> (IntSet $S) $P) $T)) ((<-> (IntSet $S) $P) (Truth_StructuralIntersection $T)))
128:(= (|-nal ((--> (ExtSet $M) $P) $T1) ((<-> $S $M) $T2)) ((--> (ExtSet $S) $P) (Truth_Analogy $T1 $T2)))
129:(= (|-nal ((--> $P (IntSet $M)) $T1) ((<-> $S $M) $T2)) ((--> $P (IntSet $S)) (Truth_Analogy $T1 $T2)))
130:(= (|-nal ((<-> (ExtSet $A) (ExtSet $B)) $T)) ((<-> $A $B) (Truth_StructuralIntersection $T)))
131:(= (|-nal ((<-> (IntSet $A) (IntSet $B)) $T)) ((<-> $A $B) (Truth_StructuralIntersection $T)))
135:(= (|-nal ((--> ({} $A $B) $M) $T)) ((--> ({} $A) $M) (Truth_StructuralDeduction $T)))
=== bare |- references (excluding |-nal) ===
201:(= (|- $a $b)
(bcb) clarityclaw-omega% 


### June 25 2026 Artifact #2:
(bcb) clarityclaw-omega% docker exec clarity_omega sh -c 'echo "=== bare |- definition body, lines 201-225 ==="; sed -n "201,225p" /PeTTa/repos/omegaclaw/lib_nal.metta'
=== bare |- definition body, lines 201-225 ===
(= (|- $a $b)
   (unique-atom (collapse (superpose ((|-nal $a $b) (|-nal $b $a))))))
(bcb) clarityclaw-omega% 


### June 25 2026 Artifact #3:
(bcb) clarityclaw-omega% docker run --rm --entrypoint python3 clarityclaw-omega-clarityclaw -c '
import subprocess, os
Q=chr(34); NL=chr(10)
P=[
"!(import! &self (library lib_import))",
"!(git-import! "+Q+"https://github.com/asi-alliance/omegaClaw-Core.git"+Q+")",
"!(import! &self (library omegaclaw lib_omegaclaw))",
"!(println! (PROBE_1_libnal_reduces_GATE))",
"!(metta "+Q+"(|-nal ((--> a b) (stv 1.0 0.9)) ((--> b c) (stv 1.0 0.9)))"+Q+")",
"!(println! (PROBE_2_quoted_bar_nal_THE_FIX))",
"!(metta "+Q+"(|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9)))"+Q+")",
"!(println! (PROBE_3_bare_bar_nal_HER_OLD_FORM))",
"!(metta (|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9))))",
"!(println! (PROBE_4_bare_match_HER_CURRENT_FORM))",
"!(metta (match &self (--> $x foo) $x))",
"!(println! (PROBE_5_quoted_match))",
"!(metta "+Q+"(match &self (--> $x foo) $x)"+Q+")",
"!(println! (PROBE_END))",
]
open("/tmp/probe.metta","w").write(NL.join(P)+NL)
env=dict(os.environ); pl="/PeTTa/mork_ffi/target/release/libmork_ffi.so"
a=["swipl","--stack_limit=8g","-q","-s","/PeTTa/src/main.pl","--","/tmp/probe.metta","default"]
if os.path.exists(pl):
    env["LD_PRELOAD"]=pl; a=a+["mork"]
try:
    r=subprocess.run(a,cwd="/PeTTa",env=env,capture_output=True,timeout=120)
    o=(r.stdout+r.stderr).decode("utf-8","replace")
except subprocess.TimeoutExpired as e:
    o="TIMEOUT_120s"+NL+(e.stdout or b"").decode("utf-8","replace")+(e.stderr or b"").decode("utf-8","replace")
i=o.find("PROBE_1")
print(o if i<0 else o[i:])
'
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
PROBE_1_libnal_reduces_GATE))
-->  prolog goal  --> 
:- findall(A, 'println!'(['PROBE_1_libnal_reduces_GATE'], A), _).
^^^^^^^^^^^^^^^^^^^^^^^
(PROBE_1_libnal_reduces_GATE)
--> metta runnable  -->
!(metta "(|-nal ((--> a b) (stv 1.0 0.9)) ((--> b c) (stv 1.0 0.9)))")
-->  prolog goal  --> 
:- findall(A,
           metta("(|-nal ((--> a b) (stv 1.0 0.9)) ((--> b c) (stv 1.0 0.9)))",
                 A),
           _).
^^^^^^^^^^^^^^^^^^^^^^^
--> metta runnable  -->
!(println! (PROBE_2_quoted_bar_nal_THE_FIX))
-->  prolog goal  --> 
:- findall(A, 'println!'(['PROBE_2_quoted_bar_nal_THE_FIX'], A), _).
^^^^^^^^^^^^^^^^^^^^^^^
(PROBE_2_quoted_bar_nal_THE_FIX)
--> metta runnable  -->
!(metta "(|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9)))")
-->  prolog goal  --> 
:- findall(A,
           metta("(|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9)))",
                 A),
           _).
^^^^^^^^^^^^^^^^^^^^^^^
--> metta runnable  -->
!(println! (PROBE_3_bare_bar_nal_HER_OLD_FORM))
-->  prolog goal  --> 
:- findall(A,
           'println!'(['PROBE_3_bare_bar_nal_HER_OLD_FORM'], A),
           _).
^^^^^^^^^^^^^^^^^^^^^^^
(PROBE_3_bare_bar_nal_HER_OLD_FORM)
--> metta runnable  -->
!(metta (|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9))))
-->  prolog goal  --> 
:- findall(A,
           ( '|-'([[-->, sam, friend], [stv, 1.0, 0.9]],
                  [[-->, friend, animal], [stv, 1.0, 0.9]],
                  B),
             metta(B, A)
           ),
           _).
^^^^^^^^^^^^^^^^^^^^^^^

ERROR: /PeTTa/src/main.pl:23: user:main atom_string/2: Type error: `string' expected, found `[[[-->,sam,animal],[stv,1.0,0.81]],[[-->,animal,sam],[stv,1.0,0.44751381215469616]]]' (a list)

(bcb) clarityclaw-omega% 

|||||||||||||||||||||||||||||
++++ Docker log of "docker run --rm --entrypoint python3 clarityclaw-omega-clarityclaw" Commmand:
|||||||||||||||||||||||||||||
priceless_carver  | PROBE_1_libnal_reduces_GATE))
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A, 'println!'(['PROBE_1_libnal_reduces_GATE'], A), _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | (PROBE_1_libnal_reduces_GATE)
priceless_carver  | --> metta runnable  -->
priceless_carver  | !(metta "(|-nal ((--> a b) (stv 1.0 0.9)) ((--> b c) (stv 1.0 0.9)))")
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A,
priceless_carver  |            metta("(|-nal ((--> a b) (stv 1.0 0.9)) ((--> b c) (stv 1.0 0.9)))",
priceless_carver  |                  A),
priceless_carver  |            _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | --> metta runnable  -->
priceless_carver  | !(println! (PROBE_2_quoted_bar_nal_THE_FIX))
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A, 'println!'(['PROBE_2_quoted_bar_nal_THE_FIX'], A), _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | (PROBE_2_quoted_bar_nal_THE_FIX)
priceless_carver  | --> metta runnable  -->
priceless_carver  | !(metta "(|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9)))")
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A,
priceless_carver  |            metta("(|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9)))",
priceless_carver  |                  A),
priceless_carver  |            _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | --> metta runnable  -->
priceless_carver  | !(println! (PROBE_3_bare_bar_nal_HER_OLD_FORM))
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A,
priceless_carver  |            'println!'(['PROBE_3_bare_bar_nal_HER_OLD_FORM'], A),
priceless_carver  |            _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | (PROBE_3_bare_bar_nal_HER_OLD_FORM)
priceless_carver  | --> metta runnable  -->
priceless_carver  | !(metta (|- ((--> sam friend) (stv 1.0 0.9)) ((--> friend animal) (stv 1.0 0.9))))
priceless_carver  | -->  prolog goal  --> 
priceless_carver  | :- findall(A,
priceless_carver  |            ( '|-'([[-->, sam, friend], [stv, 1.0, 0.9]],
priceless_carver  |                   [[-->, friend, animal], [stv, 1.0, 0.9]],
priceless_carver  |                   B),
priceless_carver  |              metta(B, A)
priceless_carver  |            ),
priceless_carver  |            _).
priceless_carver  | ^^^^^^^^^^^^^^^^^^^^^^^
priceless_carver  | 
priceless_carver  | ERROR: /PeTTa/src/main.pl:23: user:main atom_string/2: Type error: `string' expected, found `[[[-->,sam,animal],[stv,1.0,0.81]],[[-->,animal,sam],[stv,1.0,0.44751381215469616]]]' (a list)
priceless_carver  | 
priceless_carver exited with code 0


