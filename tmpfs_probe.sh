#!/bin/bash
set -u

directory=/var/tmp/inner/subdir
out=$directory/probe

check()
(
   set -x
   find /var/tmp/inner
   grep -F "/var/tmp/inner" /proc/mounts
)

check >&2
check >$out 2>&1

# The mount must both be tmpfs and allow writes.
cat $out || exit 1
