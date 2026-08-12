# Copyright (c) 2026 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.

"""Minimal reproduction for aspects on mixed-compatibility test suites."""

def _demo_test_impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        executable,
        "#!/bin/sh\nexit 0\n",
        is_executable = True,
    )
    return [DefaultInfo(executable = executable)]

demo_test = rule(
    implementation = _demo_test_impl,
    test = True,
)

def _manifest_aspect_impl(target, ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".aspect.txt")
    ctx.actions.write(output, str(target.label) + "\n")
    return [OutputGroupInfo(repro = depset([output]))]

manifest_aspect = aspect(
    implementation = _manifest_aspect_impl,
    attr_aspects = ["tests"],
)
