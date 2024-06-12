#!/bin/bash
set -exuo pipefail

[[ $# -eq 3 ]]

ref=$1
shift

for f in "$@"; do
   [[ "$(<"$ref")" == "$(<"$f")" ]]
done
