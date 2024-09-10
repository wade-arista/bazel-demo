#!/bin/bash
set -ue

actual=$(cat "$1")

set -x

if [ "$EXPECTED" != "$actual" ]
then
   echo "Expected: --[$EXPECTED]--"
   echo "Actual: --[$actual]--"
   exit 1
fi
