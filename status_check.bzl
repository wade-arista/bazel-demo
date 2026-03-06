def _status_check_impl(ctx):
    out = ctx.actions.declare_file("status_check.txt")
    ctx.actions.run_shell(
        inputs = [ctx.info_file],
        outputs = [out],
        command = """
function fail {{
  (
    echo "------------------------------"
    echo "content of {status}:"
    echo "------------------------------"
    cat {status}
    echo "------------------------------"
    echo "ERROR: missing entry for: $1"
    echo "------------------------------"
  )>&2
  exit 1
}}
grep -q '^STABLE_WITH_VALUE ' "{status}" || {{ fail STABLE_WITH_VALUE; }}
grep -q '^STABLE_FIRST_NO_VALUE' "{status}" || {{ fail STABLE_FIRST_NO_VALUE; }}
grep -q '^STABLE_SECOND_NO_VALUE' "{status}" || {{ fail STABLE_SECOND_NO_VALUE; }}
grep -q '^STABLE_THIRD_NO_VALUE' "{status}" || {{ fail STABLE_THIRD_NO_VALUE; }}
cp "{status}" "{out}"
""".format(status = ctx.info_file.path, out = out.path),
    )
    return [DefaultInfo(files = depset([out]))]

status_check = rule(
    implementation = _status_check_impl,
)
