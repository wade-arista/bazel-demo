#!/bin/bash
set -uxeo pipefail
bin=$1
readelf -d "$bin" > /tmp/readelf
grep -E "\(NEEDED\)\s+Shared library: \[libliblib1\.so\]" /tmp/readelf
grep -E "\(NEEDED\)\s+Shared library: \[libliblib2\.so\]" /tmp/readelf

objdump -C -t "$bin" > /tmp/objdump
grep -E -q "F\s+\*UND\*\s+.*value2\(\)$" /tmp/objdump
