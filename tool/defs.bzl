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

    plugin_files = []
    for ci in info.plugins:
        if CcSharedLibraryInfo not in ci:
            continue
        for ll in ci[CcSharedLibraryInfo].linker_input.libraries:
            plugin_files.append(ll.resolved_symlink_dynamic_library)

    ctx.actions.run(
        outputs = [out_file],
        inputs = ctx.files.srcs,
        tools = plugin_files,
        executable = info.compiler.files_to_run,
        arguments = [args],
        env = {
            "LD_LIBRARY_PATH": ":".join([i.dirname for i in plugin_files]),
        },
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
            plugins = ctx.attr.plugins,
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
