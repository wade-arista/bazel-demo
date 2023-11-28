#!/bin/bash
set -exuo pipefail
executable="$1"
expected="$2"

[[ "$("$executable")" == "$expected" ]]
