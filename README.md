# Bazel rlocation Directory Symlink Bug

This is a minimal reproduction case for a bug in Bazel's `runfiles.bash` library where `rlocation` fails to resolve directory symlinks created with `ctx.actions.symlink(target_path=...)`.

## Prerequisites

- Bazel 8.x or later

## Reproducing the Bug

```bash
bazel run //pkg:test
```

**Note**: The test is in a nested package (`pkg/`) because the bug is masked in root packages due to lucky path resolution. See "Why Nested Package" below.

### Expected Behavior

`rlocation` should return the path to the symlink, allowing the script to traverse it:
```
SUBDIR_LINK=/path/to/runfiles/_main/experiment/_subdir_link
Traversing symlink:
PASS
```

### Actual Behavior

`rlocation` returns an empty string:
```
SUBDIR_LINK=
FAIL: rlocation returned empty string for symlink
```

## Root Cause

The bug is in `runfiles.bash` initialization (lines 88-96). When both `$0.runfiles` directory and `$0.runfiles_manifest` file exist, the initialization only sets `RUNFILES_MANIFEST_FILE`, not `RUNFILES_DIR`:

```bash
if [[ -f "$0.runfiles_manifest" ]]; then
  export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"  # Set, but RUNFILES_DIR is not!
elif ...
```

Later, `rlocation` checks `RUNFILES_DIR` first (line 351), but since it's not set, it falls back to manifest mode. In manifest mode, symlinks with relative `target_path` are stored as relative paths that cannot be resolved.

## Workaround

Add this after the runfiles.bash initialization block to force both variables to exist.

```bash
runfiles_export_envvars
```

## Why Nested Package

The bug only manifests in non-root packages. In the root package, `rlocation` returns the relative path `_subdir_link_dir` and it happens to exist from the working directory (`$RUNFILES/_main/`). In nested packages, the symlink is at `$RUNFILES/_main/pkg/_subdir_link_dir` but rlocation still returns `_subdir_link_dir`, which doesn't exist from PWD.

## Files

- `pkg/BUILD.bazel` - Defines the test target and `symlink_dir` rule usage
- `pkg/defs.bzl` - The `symlink_dir` rule that creates directory symlinks
- `pkg/test.sh` - Shell script that demonstrates the bug
- `pkg/subdir/testfile` - Test file to read through the symlink
- `MODULE.bazel` - Bazel module definition for standalone build
