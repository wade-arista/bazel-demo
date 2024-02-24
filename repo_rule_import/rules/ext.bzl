def run(repository_ctx, cmd, working_directory = None):
    out = repository_ctx.execute(cmd, working_directory = working_directory)
    if out.return_code != 0:
        fail("failed to execute", cmd, "rc", out.return_code, "\n" + out.stdout, "\n" + out.stderr)
    return out

def _create_ext_repo_impl(repository_ctx):
    root = repository_ctx.attr.root
    user_build = repository_ctx.read(repository_ctx.attr.build_file)
    repository_ctx.file("archive.tar")
    tar_path = repository_ctx.path("archive.tar")
    run(
        repository_ctx,
        ["tar", "-c", "-f", tar_path, root],
        working_directory = str(repository_ctx.workspace_root),
    )
    repository_ctx.symlink(root, "repo_root")
    files = run(
        repository_ctx,
        ["find", root, "-type", "f"],
        working_directory = str(repository_ctx.workspace_root),
    ).stdout.splitlines()
    content = user_build + """
genrule(
    name = "{name}_extract",
    srcs = ["archive.tar"],
    outs = {files_repr},
    visibility = ["//visibility:public"],
    cmd = "tar -x -C $(RULEDIR) -f $< ",
)
""".format(
        name = root.strip("/"),
        files_repr = repr(files),
    )
    repository_ctx.file("BUILD", content = content)

create_ext_repo = repository_rule(
    implementation = _create_ext_repo_impl,
    attrs = {
        "root": attr.string(mandatory = True),
        "build_file": attr.label(mandatory = True, allow_single_file = True),
    },
)

def _importer_impl(module_ctx):
    for mod in module_ctx.modules:
        for tag in mod.tags.ext:
            create_ext_repo(
                name = tag.name,
                root = tag.root,
                build_file = tag.build_file,
            )

importer_ext = tag_class(attrs = {
    "name": attr.string(mandatory = True),
    "root": attr.string(mandatory = True),
    "build_file": attr.label(mandatory = True, allow_single_file = True),
})

importer = module_extension(
    implementation = _importer_impl,
    tag_classes = {"ext": importer_ext},
)
