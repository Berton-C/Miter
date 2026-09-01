#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' 'usage: build_store_extension.sh OUTPUT_SHARED_LIBRARY' >&2
  exit 64
fi

output=$1
mkdir -p "$(dirname "$output")"
swipl-ld -shared -O2 -o "$output" effect_membranes/runtime_extensions/miter_store_posix.c
