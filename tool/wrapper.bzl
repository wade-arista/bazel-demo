load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")
load("helper.bzl", "get_depset")

def _resolve_dep_paths(ctx, dep):
    dep_files = get_depset(dep[DefaultInfo])
    if not dep_files:
        return (None, None)

    wksp = (dep.label.workspace_name or ctx.workspace_name)
    external_prefix = "external/" + wksp + "/"

    file_paths = []
    for file in dep_files.to_list():
        file_path = file.path
        root_path = file.root.path + "/"

        if file_path.startswith(root_path):
            file_path = file_path[len(root_path):]

        if file_path.startswith(external_prefix):
            file_path = file_path[len(external_prefix):]

        file_paths.append(wksp + "/" + file_path)

    return (dep_files, file_paths)

def _tool_wrapper_impl(ctx):
    transitive_runfiles = []
    dirs = {}
    run = None
    for dep in ctx.attr.plugins + ctx.attr._deps:
        dep_files, file_paths = _resolve_dep_paths(ctx, dep)
        if not dep_files:
            continue
        transitive_runfiles.append(dep_files)

        for path in file_paths:
            if path.endswith(".so") or ".so." in path:
                dirs.setdefault(paths.dirname(path), []).append(path)

    exec_dep_files, exec_path = _resolve_dep_paths(ctx, ctx.attr.executable)
    transitive_runfiles.append(exec_dep_files)

    ctx.actions.expand_template(
        template = ctx.files._template[0],
        output = ctx.outputs.out,
        substitutions = {
            "@@run@@": exec_path[0],
            "@@ldpaths@@": shell.array_literal([k[0] for k in dirs.values()]),
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = ctx.outputs.out,
            runfiles = ctx.runfiles(
                files = [ctx.outputs.out],
                transitive_files = depset(transitive = transitive_runfiles),
            ),
        ),
    ]

tool_wrapper = rule(
    implementation = _tool_wrapper_impl,
    executable = True,
    outputs = {
        "out": "%{name}.sh",
    },
    attrs = {
        "executable": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "plugins": attr.label_list(),
        "_deps": attr.label_list(default = ["@bazel_tools//tools/bash/runfiles"]),
        "_template": attr.label(default = "wrapper.sh.tmpl", allow_single_file = True),
    },
)
