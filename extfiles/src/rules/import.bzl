"""
bring in files from outside of bazel
"""

def _input_importer_impl(repository_ctx):
    dirname = repository_ctx.os.environ.get("EXT_ROOT", "/run/user/1000/ext/")
    print("importing from", dirname)
    repository_ctx.symlink(dirname + "input.txt", "input.txt")
    repository_ctx.symlink(dirname + "BUILD.bazel", "BUILD.bazel")
    content = repository_ctx.read("BUILD.bazel")
    repository_ctx.file("BUILD", content = content)

input_importer = repository_rule(
    implementation = _input_importer_impl,
    attrs = {},
    environ = ["EXT_ROOT"],
    local = True,
)

def _binder_impl(module_ctx):
    input_importer(name = "externals")

binder = module_extension(
    implementation = _binder_impl,
)
