def _symlink_dir_impl(ctx):
    link_name = "_%s" % ctx.attr.name
    link_dir = "_%s_dir" % ctx.attr.name
    seen = set([])
    dir_ends = []
    for f in ctx.files.target:
        if f.basename in seen:
            continue
        out = ctx.actions.declare_file("%s/%s" % (link_dir, f.basename))
        ctx.actions.symlink(output = out, target_file = f)
        dir_ends.append(out)
        seen.add(f.basename)

    link = ctx.actions.declare_symlink(link_name)
    ctx.actions.symlink(output = link, target_path = link_dir)

    return [DefaultInfo(files = depset([link]),
            runfiles = ctx.runfiles([link] + dir_ends))]

symlink_dir = rule(
    implementation = _symlink_dir_impl,
    attrs = {
        "target": attr.label(allow_files=True),
    }
)
