# GitHub Issue: rlocation fails for relative directory symlinks

## Title

`rlocation` fails for directory symlinks when runfiles.bash initialization prefers manifest mode over RUNFILES_DIR

## Category

- [x] Local Execution

## Description of the bug

When a Starlark rule creates a directory symlink using `ctx.actions.symlink(output, target_path=relative_dir)`, the `rlocation` function in `runfiles.bash` fails to resolve the symlink path, returning an empty string.

The symlink **exists and works correctly** in the runfiles directory. The issue is that `runfiles.bash` initialization prefers the manifest, and the manifest cannot properly represent symlinks with relative targets.

### How the bug manifests:

1. Rule creates symlink: `ctx.actions.symlink(output=link, target_path="target_dir")`
2. Manifest stores: `path/to/link target_dir` (relative path)
3. `rlocation("path/to/link")` looks up manifest, gets `target_dir`
4. Checks if `target_dir` exists as file - it doesn't (relative path)
5. Returns empty string

### Why RUNFILES_DIR would work:

1. `rlocation("path/to/link")` checks `$RUNFILES_DIR/path/to/link`
2. File exists (it's the actual symlink)
3. Returns `$RUNFILES_DIR/path/to/link`
4. Shell can traverse: `cat "$RESULT/file_inside"` works

## Root Cause

In `runfiles.bash` lines 88-96, initialization only sets ONE of `RUNFILES_DIR` or `RUNFILES_MANIFEST_FILE`:

```bash
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  if [[ -f "$0.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"  # Wins, RUNFILES_DIR never set
  elif [[ -f "$0.runfiles/MANIFEST" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
  elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    export RUNFILES_DIR="$0.runfiles"
  fi
fi
```

Since `$0.runfiles_manifest` typically exists, the manifest is used and `RUNFILES_DIR` is never set.

Then in `runfiles_rlocation_checked` (line 351):

```bash
if [[ -e "${RUNFILES_DIR:-/dev/null}/$1" ]]; then  # Always false: RUNFILES_DIR not set
```

## Reproduction Steps

1. Extract the attached tarball
2. Run: `bazel run //pkg:test`
3. Observe the error output showing `rlocation` returns empty for the symlink

**Important**: The test must be in a non-root package (`pkg/`) to reproduce. In the root package, the bug is masked because the relative path `_subdir_link_dir` happens to exist from `$RUNFILES/_main/`. In nested packages, it's at `$RUNFILES/_main/pkg/_subdir_link_dir` but rlocation still returns just `_subdir_link_dir`.

Minimal reproduction files:
- `pkg/defs.bzl`: Rule that creates directory symlink with `target_path`
- `pkg/BUILD.bazel`: sh_binary using the rule
- `pkg/test.sh`: Script calling `rlocation` on the symlink

## Proposed Fix

Set BOTH variables when both the runfiles directory and manifest exist:

```bash
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  if [[ -d "$0.runfiles" ]]; then
    export RUNFILES_DIR="$0.runfiles"
  fi
  if [[ -f "$0.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
  elif [[ -f "$0.runfiles/MANIFEST" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
  fi
fi
```

This ensures `rlocation` can check the directory first (where symlinks work) before falling back to manifest.

## Workaround

Add this after the runfiles.bash initialization block

```bash
runfiles_export_envvars
```

## Operating System

```bash
$ cat /etc/os-release
NAME="AlmaLinux"
VERSION="9.7 (Moss Jungle Cat)"
ID="almalinux"
VERSION_ID="9.7"
PLATFORM_ID="platform:el9"
```

## Bazel Version

```bash
$ bazel info release
release 8.5.1
```

This also happens in Bazel 9.0

## Additional Context

Debug output from `RUNFILES_LIB_DEBUG=1`:

```
INFO[runfiles.bash]: rlocation(_main/path/_subdir_link): looking in RUNFILES_MANIFEST_FILE
INFO[runfiles.bash]: rlocation(_main/path/_subdir_link): found in manifest as (_subdir_link_dir), but file does not exist
```

The manifest correctly maps the symlink, but the relative target path `_subdir_link_dir` cannot be resolved as a standalone path.
