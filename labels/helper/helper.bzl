load("@rules_python//python:defs.bzl", "py_test")

def mytest(name, srcs, deps = None):
    new_deps = []
    for d in deps:
        new_deps.append(d)
        prl = native.package_relative_label(d)

        new_deps.append(prl.same_package_label(prl.name + "_extra"))
        # new_deps.append(str(prl) + "_extra")

    py_test(
        name = name,
        srcs = srcs,
        deps = new_deps,
    )
