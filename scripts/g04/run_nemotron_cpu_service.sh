#!/bin/sh
set -eu

if [ "$#" -ne 4 ]; then
  printf '%s\n' 'usage: run_nemotron_cpu_service.sh RUNTIME_BIN MODEL_FILE PORT MODEL_ID' >&2
  exit 64
fi

RUNTIME_BIN=$1
MODEL_FILE=$2
PORT=$3
MODEL_ID=$4

if [ ! -x "$RUNTIME_BIN" ]; then
  printf '%s\n' 'runtime executable is unavailable' >&2
  exit 66
fi

if [ ! -f "$MODEL_FILE" ]; then
  printf '%s\n' 'model file is unavailable' >&2
  exit 66
fi

case "$PORT" in
  ''|*[!0-9]*)
    printf '%s\n' 'port must be numeric' >&2
    exit 64
    ;;
esac

exec "$RUNTIME_BIN" \
  --model "$MODEL_FILE" \
  --host 127.0.0.1 \
  --port "$PORT" \
  --alias "$MODEL_ID" \
  --ctx-size 8192 \
  --parallel 1 \
  --device none \
  --n-gpu-layers 0 \
  --no-op-offload \
  --no-kv-offload \
  --no-ui \
  --jinja \
  --no-reasoning-preserve \
  --log-colors off
