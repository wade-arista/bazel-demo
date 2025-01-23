# Demonstration of ld issues with imported shared-lib as python module

## Overview

This uses a shared lib `foo.so` with a dep `libecho.so`:

    (NEEDED)    Shared library: [libecho.so]

And demonstrates the issues with doing so.

```mermaid
graph TD
  //:foo_py_library_dep_test --> //foo:foo_py_library_using_py_library_dep
  //foo:foo_py_library_using_py_library_dep --> //echo:libecho_py_library_imported
  //foo:foo_py_library_using_py_library_dep --> //foo:foo_imported_so_file
  //echo:libecho_py_library_imported --> //echo:libecho_imported_so_file
```

## Symptoms

### Missing Dependent Shared Library

Looking at the runfiles tree:

    foo_cc_library_dep_test.runfiles/_main/foo_cc_library_dep_test
    foo_cc_library_dep_test.runfiles/_main/foo/foo.so
    foo_cc_library_dep_test.runfiles/_main/foo/__init__.py
    foo_cc_library_dep_test.runfiles/_main/_solib_k8/__init__.py
    foo_cc_library_dep_test.runfiles/_main/_solib_k8/_U_S_Secho_Clibecho_Ucc_Ulibrary_Uimported___Uecho/__init__.py
    foo_cc_library_dep_test.runfiles/_main/_solib_k8/_U_S_Secho_Clibecho_Ucc_Ulibrary_Uimported___Uecho/libecho.so
    foo_cc_library_dep_test.runfiles/_main/test.py

We can see that `foo.so` shows up, (and gets loaded), but it fails to load `libecho.so`. Adding
`_solib_k8/_U_S_Secho_Clibecho_Ucc_Ulibrary_Uimported___Uecho` to the `LD_LIBRARY_PATH` does solve 
the problem. The issue with that approach is that it's needed by the `foo` library user, but requires
that user to know about the transient deps (`[libecho.so]`) to form the `LD_LIBRARY_PATH`.
