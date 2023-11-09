def py_test_so_env_wrapper(name, data, env = None, **kwargs):
    env = env or {}
    base = env.get("LD_LIBRARY_PATH", "")
    libPath = base.split(":") if base else []
    pkgPaths = [native.package_relative_label(d).package for d in data]
    libPath += sorted({p: True for p in pkgPaths if p}.keys())
    env["LD_LIBRARY_PATH"] = ":".join(libPath)
    native.py_test(
        name = name,
        data = data,
        env = env,
        **kwargs
    )
