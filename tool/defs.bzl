MyToolInfo = provider(
    "Toolchain info",
    fields = {
        "compiler": "compiler target",
        "plugins": "compiler plugins",
    },
)

def _my_tool_impl(ctx):
    info = ctx.toolchains["//tool:toolchain_type"].tool_info
    out_file = ctx.actions.declare_file(ctx.attr.name + ".txt")

    args = ctx.actions.args()
    args.add(out_file)
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        outputs = [out_file],
        inputs = ctx.files.srcs,
        executable = info.compiler.files_to_run,
        arguments = [args],
    )

    return [
        DefaultInfo(files = depset([out_file])),
    ]

my_tool = rule(
    implementation = _my_tool_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
    toolchains = ["//tool:toolchain_type"],
)

def _my_tool_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        tool_info = MyToolInfo(
            compiler = ctx.attr.compiler,
        ),
    )
    return [toolchain_info]

my_tool_toolchain = rule(
    implementation = _my_tool_toolchain_impl,
    attrs = {
        "compiler": attr.label(
            allow_single_file = True,
            mandatory = True,
            executable = True,
            cfg = "exec",
        ),
        "plugins": attr.label_list(),
    },
)
