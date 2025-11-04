#!/bin/bash
(
   set -x
   env -u MY_ENV bazelisk aquery test_vars > /tmp/no_env
   env MY_ENV=1 bazelisk aquery test_vars > /tmp/env1
   env MY_ENV=2 bazelisk aquery test_vars > /tmp/env2
)

echo
echo "-- Checking aquery output for expected MY_ENV differences"
rc=0
if diff -s /tmp/no_env /tmp/env1; then
   echo "ERROR: expected no_env and env1 to differ, but they did not."
   rc=1
fi
if diff -s /tmp/env2 /tmp/env1; then
   echo "ERROR: expected env2 and env1 to differ, but they did not."
   rc=1
fi

( set -x; cat /tmp/env1; )
exit $rc
