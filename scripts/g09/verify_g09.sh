#!/bin/sh
set -eu
run=$1
fail() { printf 'G09 FAIL: %s\n' "$1" >&2; exit 1; }
for pair in 'legacy_before.sha256 legacy_after.sha256' 'backup_source.sha256 backup.sha256' 'protected_before.sha256 protected_after.sha256'; do
  set -- $pair
  cmp -s "$run/hashes/$1" "$run/hashes/$2" || fail "$pair differ"
done
cmp -s "$run/raw/legacy_before.tsv" "$run/raw/legacy_after.tsv" || fail 'legacy counts changed'
cmp -s "$run/raw/legacy_identity_before.json" "$run/raw/legacy_identity_after.json" || fail 'legacy identity changed'
jq -e '.result=="chroma-collection-created" and .details.name=="miter-ltm-v1"' "$run/outputs/create.json" >/dev/null || fail 'creation'
for phase in before after; do
  jq -e '.result=="chroma-snapshot-stored" and .details.count==0 and (.details.collections|length)==1 and .details.collection.metadata.embedding_dimension==768 and .details.collection.metadata.embedding_model_id=="text-embedding-nomic-embed-text-v1.5" and .details.collection.metadata.normalization=="provider-l2-unit" and .details.collection.metadata.chunking_version=="miter-chunk-v1" and .details.collection.configuration_json.hnsw.space=="cosine" and .details.collection.metadata.embedding_profile_sha256=="0bd1ec2ff3f91f5ee51bc8ee665761ccf24bab434518565eff0f8aea3a41dfc0"' "$run/outputs/$phase.json" >/dev/null || fail "$phase snapshot"
done
jq -S '.details' "$run/outputs/before.json" > "$run/outputs/before.canonical.json"
jq -S '.details' "$run/outputs/after.json" > "$run/outputs/after.canonical.json"
cmp -s "$run/outputs/before.canonical.json" "$run/outputs/after.canonical.json" || fail 'Miter changed during negatives'
jq -e '.result=="chroma-profile-mismatch" and .http_requests==0' "$run/outputs/wrong-profile-result.json" >/dev/null || fail 'profile negative'
for target in legacy-target legacy-http; do
  jq -e '.result=="chroma-target-blocked" and .http_requests==0' "$run/outputs/$target-result.json" >/dev/null || fail "$target negative"
done
jq -e '.mounts|length==1 and .[0].Type=="volume" and .[0].Name=="miter-chroma-v1" and .[0].Destination=="/data"' "$run/raw/miter_identity.json" >/dev/null || fail 'separate volume'
jq -e '.ports["8000/tcp"]==[{"HostIp":"127.0.0.1","HostPort":"8001"}]' "$run/raw/miter_identity.json" >/dev/null || fail 'loopback port'
jq -e '.architecture=="arm64" and (.digests|index("chromadb/chroma@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6"))' "$run/raw/image_identity.json" >/dev/null || fail 'image digest/architecture'
rg -q '^chroma-collection-created[[:blank:]]*$' "$run/raw/create.stdout" || fail 'PeTTa create result'
rg -q '^chroma-profile-mismatch[[:blank:]]*$' "$run/raw/verify.stdout" || fail 'PeTTa negative result'
if rg -n 'py-call|janus|process_create|shell\(' effect_membranes/miter_chroma_service.pl; then fail 'forbidden transport'; fi
printf '%s\n' '{"gate_id":"G09","status":"PASS","negative_control_difference":true,"backup_verified":true,"legacy_identity_counts_bytes_unchanged":true,"isolated_volume":"miter-chroma-v1","collection":"miter-ltm-v1","count":0,"profile_rejection_pre_dispatch":true,"legacy_rejection_pre_dispatch":true}'
