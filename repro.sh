#!/bin/bash

set -ueo pipefail

rc=0
runbazel() {
   local -a statuses
   rc=0
   cmd=(
      bazelisk
      --nosystem_rc
      --nohome_rc
      "$@"
   )
   echo >&2 "+ ${cmd[*]}"
   if "${cmd[@]}" |& grep -e ':timeout_test.* in ' -e '^release'; then
      statuses=( "${PIPESTATUS[@]}" )
   else
      statuses=( "${PIPESTATUS[@]}" )
   fi
   return "${statuses[0]}"
}

fail() {
   msg=$1
   echo >&2 "FAILURE: $msg"
   exit 99
}

test_should_pass() {
   runbazel test --test_timeout=10 :all
}

test_should_timeout() {
   runbazel test --test_timeout=1 :all || rc=$?
   [[ $rc -eq 3 ]] || fail "expected TIMEOUT, got rc=$rc"
}

runbazel info release
runbazel clean
test_should_pass
runbazel clean
test_should_timeout

runbazel clean
test_should_pass
echo "skipping bazel clean to hit local cache"
test_should_timeout
