#!/usr/bin/env python3
from argparse import ArgumentParser
from collections.abc import Iterable
from os.path import basename
import re
from shlex import quote
from subprocess import check_output
from typing import Optional


def _fmt(v: Optional[Iterable[str]]) -> Optional[str]:
    return ("\n  " + "\n  ".join(sorted(v))) if v else None


def assert_empty(entries: set[str], tag: str) -> None:
    assert not entries, f"{tag} entries ({len(entries)}): {_fmt(entries)}"


def main() -> None:
    ap = ArgumentParser()
    ap.add_argument("--require", action="append")
    ap.add_argument("--disallow", action="append")
    ap.add_argument("--sut")
    ap.add_argument("files", metavar="FILE", nargs="+")
    args = ap.parse_args()

    sut = None
    for fn in args.files:
        if basename(fn) == args.sut:
            sut = fn
            break

    assert sut, f"SUT {args.sut} not found in files args {args.files}"

    cmd = ["readelf", "-d", sut]
    print("+", " ".join(map(quote, cmd)))
    out = check_output(cmd, text=True)
    needs = set()
    reg = re.compile(r"\(NEEDED\)\s+Shared library: \[([^]]+)\]\s*$", re.I)
    for line in out.splitlines():
        if not (m := reg.search(line)):
            continue
        print(line)
        needs.add(m.group(1))

    print("sut:", args.sut)
    print("needs:", _fmt(needs))
    print("required:", _fmt(args.require))
    print("disallowed:", _fmt(args.disallow))
    assert_empty(set(args.require or []).difference(needs), "missing required")
    assert_empty(needs.intersection(set(args.disallow or [])), "unexpected disallowed")


main()
