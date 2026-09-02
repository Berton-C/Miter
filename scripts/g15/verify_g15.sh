#!/bin/sh
set -eu
run=$1
fail() { printf 'G15 FAIL: %s\n' "$1" >&2; exit 1; }
for p in "$run"/cues/*.json; do
  jq -e '.label=="affective-language-cue" and .permission_effect=="none" and .confidence_basis=="uncalibrated-priors" and (.limitations|index("no-inner-state-claim"))!=null and (.limitations|index("no-diagnosis"))!=null and (.coverage>=0 and .coverage<=1) and (.valence_profile|length)==.clause_count and (.arousal_profile|length)==.clause_count and (.dominance_profile|length)==.clause_count and ([.valence_profile[],.arousal_profile[],.dominance_profile[]]|all(.=="low" or .=="mid" or .=="high" or .=="unknown"))' "$p" >/dev/null || fail "cue shape $p"
done
jq -e '.trajectory_class=="improving-pivot" and .presence_requirement=="preserve-emerging-insight" and .morphology_matches>0' "$run/cues/pivot.json" >/dev/null || fail pivot
jq -e '.trajectory_class=="minimization-pressure-cue" and .presence_requirement=="acknowledge-tension-gently" and .clause_trajectory==[["lexical","stable-or-ambiguous"],["minimization-marker",true]]' "$run/cues/minimized.json" >/dev/null || fail minimization
jq -e '.trajectory_class=="minimization-pressure-cue"' "$run/cues/min-alternative.json" >/dev/null || fail 'generalized minimization'
for arm in min-positive unease-no-min min-first-only; do
  jq -e '.trajectory_class!="minimization-pressure-cue" and .clause_trajectory[1][1]==false' "$run/cues/$arm.json" >/dev/null || fail "$arm false positive"
done
for arm in sparse unknown-coverage pivot-lexicon-off; do
  jq -e '.trajectory_class=="insufficient-coverage" and .coverage<0.25 and .presence_requirement=="withhold-affective-inference"' "$run/cues/$arm.json" >/dev/null || fail "$arm sparse"
done
jq -e '.asset_access=="disabled" and .matched_term_ids==[] and .valence_profile==["unknown","unknown"]' "$run/cues/pivot-lexicon-off.json" >/dev/null || fail 'severed invented measurement'
jq -e '(.unknown_terms|index("muslim"))!=null' "$run/cues/identity.json" >/dev/null || fail 'identity exclusion'
jq -e '.multiword_matches>0' "$run/cues/mwe.json" >/dev/null || fail 'real MWE lookup'
rg -q '^synthetic-mwe-longest-pass$' "$run/raw/mwe.stdout" || fail 'MWE overlap control'
[ "$(rg -c '^affect-cue-stored[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 15 ] || fail 'native results'
rg -q '^vad-unavailable[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'missing input'
rg -q '^policy-admitted[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'normal permission dependencies'
rg -q '^rejected-affect-authority-dependency[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'affect dependency permitted'
[ "$(rg -c '^permitted[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 2 ] || fail 'permission positives/mock'
[ "$(rg -c '^blocked[[:blank:]]*$' "$run/raw/canonical.stdout")" -eq 3 ] || fail 'permission negatives/mock'
rg -q '^preserve-emerging-insight[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'presence consumer'
rg -q '^attentive-non-diagnostic[[:blank:]]*$' "$run/raw/canonical.stdout" || fail 'presence severed'
shasum -a 256 -c "$run/hashes/private_asset.sha256" > "$run/outputs/asset-check.txt" || fail 'asset changed'
cmp "$run/hashes/protected_before.sha256" "$run/hashes/protected_after.sha256" || fail 'protected drift'
jq -e '.status=="valid" and .event_count==26' "$run/outputs/ledger.json" >/dev/null || fail 'source ledger'
if rg -l '^[^[:space:]]+\t-?[0-9]+\.[0-9]+\t-?[0-9]+\.[0-9]+\t-?[0-9]+\.[0-9]+$' "$run"; then fail 'possible redistributed row'; fi
git check-ignore -q config/local/vad-asset.json || fail 'local config not ignored'
printf '%s\n' '{"gate_id":"G15","status":"PASS","negative_control_difference":true,"synthetic_phrases":14,"derived_cues":15,"lexicon_redistributed":false,"native_aggregation_and_trajectory":true,"minimization_distinguished_from_lexical_delta":true,"affect_permission_dependency_rejected":true}'
