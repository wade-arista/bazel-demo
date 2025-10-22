def _my_action_impl(ctx):
    out = ctx.actions.declare_file(ctx.attr.name + ".txt")
    args = ctx.actions.args()
    args.add(out)
    args.add_all(ctx.attr.envs)
    ctx.actions.run(
        outputs = [out],
        executable = ctx.executable._worker,
        arguments = [args],
        env = {"OTHER_ENV": "3"},
        use_default_shell_env = ctx.attr.use_default_shell_env,
    )

    return DefaultInfo(files = depset([out]))

my_action = rule(
    implementation = _my_action_impl,
    attrs = {
        "envs": attr.string_list(),
        "use_default_shell_env": attr.bool(),
        "_worker": attr.label(default = "worker_script.sh", allow_files = True, executable = True, cfg = "exec"),
    },
)
