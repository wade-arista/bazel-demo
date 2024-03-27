# Demonstration for `py_lib` in `py_runtime`

To the end of creating a python toolchain by extracting a tarball, I was using a `py_lib` as part of the
`files` for a `py_runtime`.

```starlark
py_library(
    name = "py_lib_with_data",
    data = ["python_package_py"],
)

py_runtime(
    name = "py_runtime_py_lib_with_data",
    files = [
        "py_lib_with_data",
        "python_package_misc_files",
        "python_package_sharedlibs",
    ],
)

...

genrule(
    name = "extract_python_archive",
    srcs = ["python.tar.gz"],
    outs = all_filenames,
    cmd = "tar -C $(RULEDIR) -x -f $<",
)
```

When I use `py_library.data` specifically, if I change the `python.tar.gz` with different `.py` files, I still
see cache hits for tests.

For my test, I was using `unittest.TestCase`, and in `bad.tar.gz`, I have a failing assertion in `case.py`.

```sh
# first, warm up the cache with a passing test run
ln -svf good.tar.gz deps/python.tar.gz
bazel test test

# now use python with broken `case.py`, and expect a test failure
ln -svf bad.tar.gz deps/python.tar.gz
bazel test test
```

The second run, however hits the cache:


```sh
//:test   (cached) PASSED in 0.1s
```

If, instead, I use `py_library.srcs` above, the second test run doesn't hit the cache and fails as expected.

# Running the Test Case

Failing case (using `data`) (unexpected cache hit):
```sh
./testcase.py "@py//:toolchain_py_lib_with_data"
```

Passing case (using `srcs`):
```sh
./testcase.py "@py//:toolchain_py_lib_with_srcs"
```
