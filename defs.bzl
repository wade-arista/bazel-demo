def _symlink_directory_impl(ctx):
    links_dir = "_{}_links".format(ctx.attr.name)
    out = ctx.actions.declare_directory(links_dir)
    path = out.path
    cmd = [
        "set -xe",
        "mkdir -p {}".format(path),
        "cd {}".format(path),
    ]

    n_dirs = path.count("/") + 1
    prefix = "/".join([".."] * n_dirs)

    for s in ctx.files.srcs:
        cmd += ["ln -svf {}/{} {}".format(prefix, s.path, s.basename)]

    ctx.actions.run_shell(
        outputs = [out],
        inputs = ctx.files.srcs,
        command = "\n".join(cmd),
        mnemonic = "CreateLinksDir",
    )
    return [
        DefaultInfo(files = depset([out])),
    ]

symlink_directory = rule(
    implementation = _symlink_directory_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)
