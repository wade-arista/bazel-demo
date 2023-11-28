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
        ctx.actions.write(inc_out, fmt.format(ctx.attr.txt))

    return [
        DefaultInfo(files = depset(outs)),
    ]

codegen = rule(
    implementation = _codegen_impl,
    attrs = {
        "cc": attr.label_list(allow_files = True),
        "txt": attr.string(mandatory = True),
        "out": attr.output_list(),
    },
)
