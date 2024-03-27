def _import_impl(rctx):
    p = rctx.workspace_root.get_child("deps")
    rctx.watch_tree(p)
    for fn in ["BUILD.bazel", "splitfiles.bzl", "python.tar.gz"]:
        target = p.get_child(fn)
        rctx.symlink(target, fn)

python_import = repository_rule(
    implementation = _import_impl,
    local = True,
)

def _importer_impl(mctx):
    python_import(name = "py")

importer = module_extension(
    implementation = _importer_impl,
    tag_classes = {"python": tag_class()},
)
