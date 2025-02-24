LibsInfo = provider(fields = {"files": ""})

def _lib_path_aspect_impl(target, ctx):
    direct = []
    transitive = []
    if CcInfo in target:
        direct.append(target[CcInfo].linking_context.linker_inputs)

    deps = getattr(ctx.rule.attr, "deps", [])
    for dep in deps:
        if not CcInfo in dep:
            continue
        transitive.append(dep[CcInfo].linking_context.linker_inputs)

    return [LibsInfo(files = depset(direct, transitive = transitive))]

lib_path_aspect = aspect(
    implementation = _lib_path_aspect_impl,
    attr_aspects = ["deps"],
)

def _lib_path_impl(ctx):
    libs_dir = "_{}_libs".format(ctx.attr.name)
    links_dir = "_{}_links".format(ctx.attr.name)

    out = ctx.actions.declare_symlink(libs_dir)
    links = []
    for d in ctx.attr.deps:
        for li in d[LibsInfo].files.to_list():
            for lib in li.libraries:
                dl = lib.dynamic_library
                if not dl:
                    fail("missing dynamic_library in", lib)

                link_target = "{}/{}".format(links_dir, dl.basename)
                link = ctx.actions.declare_file(link_target)

                links.append(link)
                ctx.actions.symlink(output = link, target_file = dl)

    ctx.actions.symlink(output = out, target_path = links_dir)

    return DefaultInfo(
        files = depset([out]),
        runfiles = ctx.runfiles(files = links),
    )

lib_path = rule(
    implementation = _lib_path_impl,
    attrs = {
        "deps": attr.label_list(
            allow_files = True,
            aspects = [lib_path_aspect],
        ),
    },
)
