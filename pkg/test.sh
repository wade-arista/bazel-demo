#!/bin/bash
# Reproduction case for rlocation directory symlink bug
set -euo pipefail

# Enable debug output to see what rlocation is doing
export RUNFILES_LIB_DEBUG=1

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

echo "=== Environment ==="
echo "RUNFILES_DIR=${RUNFILES_DIR:-<not set>}"
echo "RUNFILES_MANIFEST_FILE=${RUNFILES_MANIFEST_FILE:-<not set>}"
echo "PWD=$(pwd)"
echo ""

# $1 = path to a file inside subdir (works - used to derive directory path)
# $2 = path to the symlink (FAILS - this is the bug)

echo "=== Test 1: rlocation for file inside directory (works) ==="
SUBDIR=$(dirname "$(rlocation "$1")")
echo "SUBDIR=$SUBDIR"
echo "Contents:"
cat "$SUBDIR/testfile"
echo ""

echo "=== Test 2: rlocation for directory symlink (BUG - returns empty) ==="
SUBDIR_LINK=$(rlocation "$2")
echo "SUBDIR_LINK=$SUBDIR_LINK"

if [[ -z "$SUBDIR_LINK" ]]; then
    echo "FAIL: rlocation returned empty string for symlink"
    exit 1
fi

echo "Traversing symlink:"
cat "$SUBDIR_LINK/testfile"
echo "SUCCESS: rlocation resolved the symlink correctly"
