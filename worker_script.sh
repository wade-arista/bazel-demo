#!/bin/bash
env
out_file=$1
shift
echo "vars: $*" > "$out_file"
set -x
for a in "$@"; do
   echo "$a=${!a:-<UNSET>}" >> "$out_file"
done

cat "$out_file"
