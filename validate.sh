#!/bin/bash
set -ueo pipefail
mapfile -t data <"$INPUT_FILE"
mapfile -t expect <"$EXPECT_FILE"

rc=0
if [[ "${#data[@]}" != "${#expect[@]}" ]]; then
   echo "length mismatch"
   rc=1
fi
for ((i=0; i < ${#data[@]}; i++)); do
   if [[ "${data[i]:-EOF}" != "${expect[i]:-EOF}" ]]; then
      echo -e "ERROR: mismatch at idx=$i:\n ${data[i]}\n ${expect[i]}"
      rc=2
   else
      echo -e "idx=$i:\n ${data[i]}\n ${expect[i]}"
   fi
done
exit $rc
