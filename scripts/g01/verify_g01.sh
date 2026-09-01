#!/bin/sh
set -u

if [ "$#" -ne 3 ]; then
  printf '%s\n' 'usage: verify_g01.sh EXPECTED_FILE STDOUT_FILE STATUS_FILE' >&2
  exit 64
fi

EXPECTED_FILE=$1
STDOUT_FILE=$2
STATUS_FILE=$3

for required_file in "$EXPECTED_FILE" "$STDOUT_FILE" "$STATUS_FILE"
do
  if [ ! -f "$required_file" ]; then
    printf '{"verifier":"g01-verifier-v1","status":"FAIL","reason":"missing input"}\n'
    exit 1
  fi
done

expected=$(tr -d '\r\n ' < "$EXPECTED_FILE")
runtime_status=$(tr -d '\r\n ' < "$STATUS_FILE")
escape_character=$(printf '\033')
actual=$(awk 'NF { value=$0 } END { print value }' "$STDOUT_FILE" | sed "s/${escape_character}\\[[0-9;]*m//g" | tr -d '\r')

if [ "$runtime_status" = "0" ] && [ "$actual" = "$expected" ]; then
  printf '{"verifier":"g01-verifier-v1","status":"PASS","expected":"%s","actual":"%s","runtime_exit":0}\n' "$expected" "$actual"
  exit 0
fi

printf '{"verifier":"g01-verifier-v1","status":"FAIL","expected":"%s","actual":"%s","runtime_exit":"%s"}\n' "$expected" "$actual" "$runtime_status"
exit 1
