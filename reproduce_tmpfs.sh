#!/bin/bash
set -euo pipefail

bazel=bazelisk
v9=9.3.2
v10=10.0.0rc3

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Keep the output base outside /tmp to avoid the separate sandbox-base bug.
workDir=$(mktemp -d /var/tmp/bazel-hermetic-tmpfs.XXXXXX)
trap "rm -fr $workDir" EXIT

startup=(
   --batch
   --nohome_rc
   --nosystem_rc
   "--output_user_root=${workDir}/output"
)

mkdir -p /var/tmp/{inner,outer}
OUTER=/var/tmp/outer/subdir
INNER=/var/tmp/inner/subdir
mkdir -p $OUTER
rm -fr $INNER

args=(
   "--action_env=NOW=$(date +%s)" # invalidate cache entries
   --sandbox_add_mount_pair=/var/tmp/outer:/var/tmp/inner
   # NOTE that the tmpfs is created at the "outer" path, and then is seen in the sandbox
   # at the "inner" path.
   --sandbox_tmpfs_path=$OUTER
)

runCase() {
   export USE_BAZEL_VERSION=$1
   local name=$2
   shift 2
   echo ================================================================================
   echo "test case: $name $*"
   "$bazel" --version
   echo ================================================================================
   echo "+ $bazel" build "${args[@]}" "$@" //:tmpfs_probe
   lastlog=$workDir/$name-${USE_BAZEL_VERSION}.log
   "$bazel" "${startup[@]}" build "${args[@]}" "$@" //:tmpfs_probe > "$lastlog" 2>&1
}

expectFail() {
   cat $lastlog
   echo "REPRO FAILURE: Unexpected success"
   (
      set -x
      cat bazel-bin/tmpfs_probe.txt
   )
   exit 1
}

####################################################################################################
# In bazel 9, we don't need to use --sandbox_writable_path
####################################################################################################
if ! runCase $v9 baseline; then
   echo "Unexpected failure in bazel $v9"
   cat "$lastlog"
   exit 1
fi
cat bazel-bin/tmpfs_probe.txt

####################################################################################################
# In bazel 10, the specified --sandbox_tmpfs_path is now readonly due to 3a1589cf434521fa4a319db58e19ae5f4412ac34
####################################################################################################
if runCase $v10 baseline; then
   echo "Unexpected success"
   cat "$lastlog"
   cat bazel-bin/tmpfs_probe.txt
   exit 1
fi
if ! grep "$INNER/probe: Read-only" "$lastlog"; then
   echo "Expected failure due to Read-only subdir, but it didn't match"
   cat $lastlog
   exit 1
fi
echo "==> matched expected failure"

####################################################################################################
# The bug: if we use --sandbox_writable_path=INNER, then INNER must exist *outside the sandbox*
####################################################################################################
if runCase $v10 writable-dir --sandbox_writable_path=$INNER; then
   expectFail
fi
if ! grep "exception during sandboxed execution.*$INNER" $lastlog; then
   echo "Expected failure due to missing $INNER"
   cat $lastlog
   exit 1
fi
echo "==> matched expected failure"

####################################################################################################
# The workaround: create INNER on the host first (outside the sandbox)
####################################################################################################
mkdir -p $INNER
if ! runCase $v10 workaround --sandbox_writable_path=$INNER; then
   echo "Unexpected failure in bazel $v10 with workaround"
   cat "$lastlog"
fi
echo "==> workaround succeeded for $v10"
cat bazel-bin/tmpfs_probe.txt
