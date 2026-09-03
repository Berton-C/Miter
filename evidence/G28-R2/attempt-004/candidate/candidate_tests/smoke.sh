#!/bin/sh
set -eu

ARG='hello'
OUT=/tmp/smoke_out.$$ 
EXP=/tmp/smoke_exp.$$ 
trap 'rm -f "$OUT" "$EXP"' EXIT INT TERM

/bin/sh /workspace/extension/adapter.sh "$ARG" > "$OUT"

printf '%s\n' "$ARG" > "$EXP"

cmp -s "$OUT" "$EXP"
