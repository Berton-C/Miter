#!/bin/sh
set -eu
run=$1
fail() { printf 'G13 FAIL: %s\n' "$1" >&2; exit 1; }
pin=constitution/authority-manifest.json
jq -e '.schema=="miter-soul-integrity-v1" and .atom_count==78 and (.atom_manifest|length)==78' "$pin" >/dev/null || fail 'pin shape/count'
jq -r '.files[] | "\(.sha256)  \(.path)"' "$pin" | shasum -a 256 -c - > "$run/outputs/source-verification.txt" || fail 'source hash'
atom_hash=$(jq -jr '.atom_manifest|join("\n")' "$pin" | shasum -a 256 | cut -d ' ' -f 1)
[ "$atom_hash" = "$(jq -r .atom_manifest_sha256 "$pin")" ] || fail 'independent atom manifest hash'
jq -e --slurpfile pin "$pin" '.result=="soul-integrity-verified" and .measured==$pin[0] and .pin==$pin[0]' "$run/outputs/canonical-integrity.json" >/dev/null || fail 'loaded atom/source equality'
rg -q '^soul-ready[[:blank:]]*$' "$run/raw/canonical.stdout" || fail startup
rg -q '^Miter[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'symbol read'
for n in 78 9 17 6; do rg -q "^$n[[:blank:]]*$" "$run/raw/canonical.stdout" || fail "count $n"; done
[ "$(rg -c '^witnessed[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 23 ] || fail 'positive causal procedures'
[ "$(rg -c '^blocked[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 31 ] || fail 'negative/partner/unknown controls'
for arm in orphan dead; do
  rg -q '^false[[:blank:]]*$' "$run/raw/$arm.stdout" || fail "$arm audit"
  [ "$(rg -c '^soul-startup-blocked[[:blank:]]*$' "$run/raw/$arm.stdout")" -eq 2 ] || fail "$arm audit/combined startup"
done
for arm in orphan dead atom-tamper source-tamper; do
  jq -e '.result=="soul-integrity-mismatch"' "$run/outputs/$arm-integrity.json" >/dev/null || fail "$arm integrity"
done
rg -q '^soul-startup-blocked[[:blank:]]*$' "$run/raw/atom_tamper.stdout" || fail 'loaded atom tamper'
rg -q '^soul-startup-blocked[[:blank:]]*$' "$run/raw/source-tamper.stdout" || fail 'source tamper'
jq -e '.measured.atom_manifest==.pin.atom_manifest and .measured.files!=.pin.files' "$run/outputs/source-tamper-integrity.json" >/dev/null || fail 'source-only control isolation'
jq -e '.measured.files==.pin.files and .measured.atom_manifest!=.pin.atom_manifest' "$run/outputs/atom-tamper-integrity.json" >/dev/null || fail 'atom-only control isolation'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
[ "$(rg -c '^soul-integrity-error[[:blank:]]*$' "$run/raw/totality.stdout")" -eq 2 ] || fail 'malformed and missing input totality'
printf '%s\n' '{"gate_id":"G13","status":"PASS","negative_control_difference":true,"loaded_atoms":78,"patterns":9,"values":17,"degradation_relations":6,"positive_causal_executions":23,"contrary_or_unknown_blocks":31,"orphan_and_dead_procedure_blocked":true,"source_and_atom_integrity_verified":true,"candidate_sandbox_claimed":false}'
