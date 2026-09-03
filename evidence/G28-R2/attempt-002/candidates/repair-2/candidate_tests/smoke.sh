#!/bin/sh
set -eu

# Correct adapter: argument + LF, exact bytes
out=$(printf 'héllo\nworld' | /bin/sh /workspace/extension/adapter.sh)
exp=$(printf 'héllo\nworld\n')
[ "$out" = "$exp" ] || exit 1

# No-output adapter: must fail
printf '' > /tmp/noout.sh
chmod +x /tmp/noout.sh
if /bin/sh /tmp/noout.sh 'héllo\nworld' > /dev/null 2>&1; then
  exit 1
fi

# Missing final LF adapter: must fail
printf '%s' 'héllo\nworld' > /tmp/nolf.sh
chmod +x /tmp/nolf.sh
if /bin/sh /tmp/nolf.sh 'héllo\nworld' > /dev/null 2>&1; then
  exit 1
fi

exit 0