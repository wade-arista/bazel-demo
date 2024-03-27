#!/usr/bin/env python3
from os import symlink, unlink
from subprocess import PIPE, STDOUT, run
from shlex import join
import sys


def runme(argv: list[str], expect_rc: int) -> str:
    print("+", join(argv))
    p = run(argv, stdout=PIPE, stderr=STDOUT, text=True)
    if p.returncode != expect_rc:
        print(p.stdout)
        print(f"ERROR: expected rc={expect_rc}, actual={p.returncode}")
        print("")
        sys.exit(1)
    return p.stdout


def bazel_test(expect_rc: int) -> None:
    tc = sys.argv[1]
    cmd = ["bazel", "test", f"--extra_toolchains={tc}", "--test_output=all", "test"]
    runme(cmd, expect_rc)


def setup_python_package(source: str) -> None:
    target = "deps/python.tar.gz"
    try:
        unlink(target)
    except FileNotFoundError:
        pass
    print("symlink", source, "->", target)
    symlink(source, target)


def main():
    setup_python_package("good.tar.gz")
    bazel_test(0)

    setup_python_package("bad.tar.gz")
    bazel_test(3)

    print("test passed (hit expected failure)")


main()
