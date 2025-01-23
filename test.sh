#!/bin/bash
set -uxe

cd "$(git rev-parse --show-toplevel)"

# these should pass:
bazelisk test ...

# expected failures (tagged as "manual")
bazelisk query 'attr("tags", "manual", tests(...))'  | xargs bazelisk test
