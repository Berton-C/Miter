#!/bin/sh
set -eu
run=$1
fail() { printf 'G14 FAIL: %s\n' "$1" >&2; exit 1; }
for arm in complete complete-high-score; do
  jq -e '.status=="certified" and .certificate.movement_id=="'"$arm"'" and .certificate.source_cut=="source-g10-pref-new" and .certificate.certificate_version=="miter-movement-v1" and (.certificate|keys|length)==13 and .certificate.relation_floor_witnesses==["w-safety","w-integrity"] and .certificate.precision_floor_witnesses==["w-provenance","w-required-distinction"] and .certificate.availability_witness=="w-availability" and .certificate.inherited_legality_witness=="w-inherited-legality" and .certificate.no_disqualifying_forcing_witness=="w-no-forcing" and .certificate.participation_open_witness=="w-participation" and .certificate.consequence_answerability_witness=="w-consequence" and .certificate.doctrine_bound_reading_witness=="w-doctrine" and .certificate.material_extension_alignment_witnesses=="w-extensions" and .certificate.continuing_contact_witness=="w-continuing-contact"' "$run/outputs/$arm.json" >/dev/null || fail "$arm fields"
done
for arm in missing-provenance missing-distinction high-score-unsafe missing-availability missing-inherited-legality missing-safety missing-integrity missing-no-forcing missing-participation missing-consequence missing-doctrine missing-extensions missing-continuing-contact scope-forgery unknown-source soul-severed undeclared-extension; do
  jq -e '.status=="blocked" and .certificate==null' "$run/outputs/$arm.json" >/dev/null || fail "$arm admitted"
done
jq -e '.status=="certified" and .certificate.precision_floor_witnesses[0]=="missing-witness"' "$run/outputs/severed-missing-provenance.json" >/dev/null || fail 'severed constructor did not differ'
[ "$(rg -c '^movement-result-stored[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 19 ] || fail 'native outputs'
[ "$(rg -c '^movement-result-error[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 1 ] || fail 'malformed product'
[ ! -f "$run/outputs/malformed.json" ] || fail 'malformed product persisted'
for arm in complete missing-provenance missing-distinction high-score-unsafe missing-availability missing-inherited-legality missing-safety missing-integrity missing-no-forcing missing-participation missing-consequence missing-doctrine missing-extensions missing-continuing-contact scope-forgery unknown-source undeclared-extension complete-high-score severed; do
  p="$run/outputs/$arm-integrity.json"
  jq -e '.result=="soul-integrity-verified"' "$p" >/dev/null || fail 'Soul integrity'
done
jq -s -e '(.[0].certificate|del(.movement_id))==(.[1].certificate|del(.movement_id))' "$run/outputs/complete.json" "$run/outputs/complete-high-score.json" >/dev/null || fail 'utility changed certificate'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
printf '%s\n' '{"gate_id":"G14","status":"PASS","negative_control_difference":true,"complete_certificates":2,"blocked_controls":17,"all_twelve_obligations_severed_individually":true,"high_score_cannot_override_floor":true,"provenance_severed_admits":true,"fixture_witnesses_not_general_truth":true}'
