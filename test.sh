#!/bin/bash
set -uxeo pipefail
trap 'readelf -d bazel-bin/cc_runfiles; find bazel-bin/cc_runfiles.runfiles -name "*librunfiles*" -print0 | xargs -0 readelf -d' EXIT
bazelisk test "$@" --test_output=all ...
