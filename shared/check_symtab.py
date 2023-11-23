#!/usr/bin/env python3
from argparse import ArgumentParser
from collections.abc import Iterable
from os.path import basename
from re import split
from shlex import quote
from subprocess import check_output
from typing import Optional


def _fmt(v: Optional[Iterable[str]]) -> Optional[str]:
    return ("\n  " + "\n  ".join(sorted(v))) if v else None


def assert_empty(entries: set[str], tag: str) -> None:
    assert not entries, f"{tag} entries ({len(entries)}): {_fmt(entries)}"


def main():
    ap = ArgumentParser()
    ap.add_argument("--sut")
    ap.add_argument("--undefined", action="append")
    ap.add_argument("--defined", action="append")
    ap.add_argument("files", metavar="FILE", nargs="+")
    args = ap.parse_args()

    sut = None
    for fn in args.files:
        if basename(fn) == args.sut:
            sut = fn
            break

    assert sut, f"SUT {args.sut} not found in files args {args.files}"
    print("sut:", sut)

    cmd = ["readelf", "--dyn-syms", sut]
    print("+", " ".join(map(quote, cmd)))
    out = check_output(cmd, text=True)
    defined = set()
    undefined = set()
    for line in out.splitlines():
        parts = split(r"\s+", line)
        try:
            defState = parts[7]
            name = " ".join(parts[8:])
        except IndexError:
            continue
        if not name.strip():
            continue
        if defState == "Ndx":
            continue
        (undefined if defState == "UND" else defined).add(name)

    print("undefined:", _fmt(undefined))
    print("defined:", _fmt(defined))

    assert_empty(set(args.undefined) - undefined, "missing undefined")
    assert_empty(set(args.defined) - defined, "missing defined")


main()
