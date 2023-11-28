load("@bazel_skylib//lib:paths.bzl", "paths")

fmt = """
const char * greeting = "{}";
"""

def _codegen_impl(ctx):
    outs = []
    for cc in ctx.files.cc:
        out = ctx.actions.declare_file(cc.basename + ".cc")
        outs.append(out)
        ctx.actions.run(
            outputs = [out],
            inputs = [cc],
            executable = "cp",
            arguments = ["-v", cc.path, out.path],
        )

        inc_out = ctx.actions.declare_file(paths.split_extension(cc.basename)[0] + ".inc")
        outs.append(inc_out)
        ctx.actions.symlink(output = inc_out, target_file = ctx.files.src[0])

    return [
        DefaultInfo(files = depset(outs)),
    ]

codegen = rule(
    implementation = _codegen_impl,
    attrs = {
        "cc": attr.label_list(allow_files = True),
        "out": attr.output_list(),
        "src": attr.label(allow_files = True, mandatory = True),
    },
)
