load("@bazel_skylib//lib:paths.bzl", "paths")

fmt = """
const char * greeting = "{}";
"""

def _codegen_impl(ctx):
    cc_map = {
        paths.split_extension(f.basename)[0]: f
        for f in ctx.outputs.out
        if paths.split_extension(f.basename)[1] == ".cc"
    }
    inc_list = [
        f
        for f in ctx.outputs.out
        if paths.split_extension(f.basename)[1] in [".inc", ".h"]
    ]
    for cc in ctx.files.cc:
        out = cc_map[paths.split_extension(cc.basename)[0]]
        ctx.actions.run(
            outputs = [out],
            inputs = [cc],
            executable = "cp",
            arguments = ["-v", cc.path, out.path],
        )

    for out in inc_list:
        ctx.actions.write(out, fmt.format(ctx.attr.txt))

codegen = rule(
    implementation = _codegen_impl,
    attrs = {
        "cc": attr.label_list(allow_files = True),
        "txt": attr.string(mandatory = True),
        "out": attr.output_list(),
    },
)
