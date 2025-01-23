load(
    "@aspect_rules_py//py:defs.bzl",
    aspect_py_library = "py_library",
    aspect_py_test = "py_test",
)
load(
    "@rules_python//python:defs.bzl",
    _py_library = "py_library",
    _py_test = "py_test",
)

bazel_py_library = _py_library

use_aspect_libs = False

def py_test(*args, **kw):
    aspect_py_test(*args, **kw) if use_aspect_libs else _py_test(*args, **kw)

def py_library(*args, **kw):
    aspect_py_library(*args, **kw) if use_aspect_libs else _py_library(*args, **kw)
