#!/bin/sh
out=$(printf 'héllo\nworld' | /bin/sh /workspace/extension/adapter.sh)
exp=$(printf 'héllo\nworld\n')
[ "$out" = "$exp" ] || exit 1