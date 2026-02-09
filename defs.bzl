load("@bazel_skylib//lib:paths.bzl", "paths")

def _symlink_dir_impl(ctx):
    link_name = ctx.attr.name
    dir_ends = []
    target_dir = None
    for f in ctx.files.target:
        out = ctx.actions.declare_file("subdir/%s" % f.basename)
        ctx.actions.symlink(output = out, target_file = f)
        dir_ends.append(out)
        target_dir = paths.dirname(out.short_path)

    link = ctx.actions.declare_symlink(link_name)
    ctx.actions.symlink(output = link, target_path = target_dir)

    return [DefaultInfo(files = depset([link]),
            runfiles = ctx.runfiles([link] + dir_ends))]

symlink_dir = rule(
    implementation = _symlink_dir_impl,
    attrs = {
        "target": attr.label(allow_files=True),
    }
)
