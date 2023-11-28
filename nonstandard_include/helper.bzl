scr = """
"{file}" "{sut}" "{msg}"
"""

def _assert_hello_test_impl(ctx):
    ctx.actions.write(
        ctx.outputs.executable,
        scr.format(
            file = ctx.attr._exec.files_to_run.executable.path,
            sut = ctx.attr.sut.files_to_run.executable.short_path,
            msg = ctx.attr.msg,
        ),
        is_executable = True,
    )
    runfiles = ctx.runfiles([ctx.attr._exec.files_to_run.executable])
    runfiles = runfiles.merge(ctx.attr.sut[DefaultInfo].default_runfiles)
    return [DefaultInfo(runfiles = runfiles)]

assert_hello_test = rule(
    implementation = _assert_hello_test_impl,
    attrs = {
        "sut": attr.label(mandatory = True),
        "msg": attr.string(default = "hello, world!"),
        "_exec": attr.label(allow_files = True, default = "assert_hello.sh"),
    },
    test = True,
)
