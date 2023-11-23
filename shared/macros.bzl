def assert_linking_test(name, lib_root_name, require = None, disallow = None):
    args = ["--sut", "lib" + lib_root_name + ".so"]
    lib_label = ":{}_so".format(lib_root_name)
    for i in require or []:
        args += ["--require", i]
    for i in disallow or []:
        args += ["--disallow", i]
    args += ["--", "$(locations {})".format(lib_label)]

    script = Label("assert_linking.py")
    native.py_test(
        name = name,
        srcs = [script],
        data = [native.package_relative_label(lib_label)],
        args = args,
        main = script,
    )
