#!/bin/sh
set -eu
run=$1
fail() { printf 'G17 FAIL: %s\n' "$1" >&2; exit 1; }
jq -e '.status=="withheld" and .reason=="attempt-budget-exhausted" and .attempts==2 and .attempt_budget==2 and .emission==false and .fallback_text==null' "$run/bounded/exhaustion/outcome.json" >/dev/null || fail exhaustion
jq -e '.reason=="invalid-budget" and .attempts==0 and .emission==false' "$run/bounded/bad-budget/outcome.json" >/dev/null || fail budget
for n in 0 1; do
 jq -e '.status=="audit-repair-required" and (.defects|length)>0' "$run/bounded/exhaustion/attempt-$n.audit.json" >/dev/null || fail audit
done
[ ! -f "$run/bounded/exhaustion/attempt-2.candidate.json" ] || fail excess
[ ! -f "$run/bounded/exhaustion/attempt-0.certificate.json" ] || fail certificate
[ ! -f "$run/bounded/bad-budget/attempt-0.candidate.json" ] || fail 'bad budget called renderer'
jq -e '.standing=="certified-utterance"' "$run/bounded/first-valid/attempt-0.certificate.json" >/dev/null || fail positive
[ ! -f "$run/bounded/first-valid/attempt-1.candidate.json" ] || fail 'valid retried'
[ "$(find "$run/bounded/surface" -type f | wc -l | tr -d ' ')" -eq 1 ] || fail surface
jq -e '.status=="deadline_exceeded" and .elapsed_seconds>=8 and .elapsed_seconds<12 and .reaped==true' "$run/raw/watchdog.json" >/dev/null || fail watchdog
[ -f "$run/runaway/runaway/attempt-3.audit.json" ] || fail 'severed did not continue'
[ ! -d "$run/runaway/surface" ] || fail 'severed emitted'
[ "$(rg -c '^voice-withheld[[:blank:]]*$' "$run/raw/bounded.stdout")" -eq 2 ] || fail withholding
rg -q '^voice-emitted[[:blank:]]*$' "$run/raw/bounded.stdout" || fail emission
[ "$(rg -c '^\(\)[[:blank:]]*$' "$run/raw/g16-reaudit.stdout")" -eq 5 ] || fail regression
jq -e '.status=="valid" and .event_count==63' "$run/outputs/ledger.json" >/dev/null || fail ledger
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail protected
printf '%s\n' '{"gate_id":"G17","status":"PASS","negative_control_difference":true,"attempt_budget":2,"withholding_explicit":true,"valid_first_attempt":true,"invalid_budget_no_renderer":true,"runaway_terminated_and_reaped":true,"g16_native_reaudit_pass":true}'
