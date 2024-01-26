"""
bring in files from outside of bazel
"""

def _input_importer_impl(repository_ctx):
    dirname = repository_ctx.os.environ["EXT_ROOT"]
    print("importing from", dirname)
    repository_ctx.symlink(dirname, "root")
    srcRoot = repository_ctx.os.environ["SRC_ROOT"]
    repository_ctx.file("BUILD", content = repository_ctx.read(srcRoot + "/BUILD.bazel"))

input_importer = repository_rule(
    implementation = _input_importer_impl,
    attrs = {},
    environ = ["EXT_ROOT", "SRC_ROOT"],
    local = True,
)

def _binder_impl(module_ctx):
    input_importer(name = "externals")

binder = module_extension(
    implementation = _binder_impl,
)
