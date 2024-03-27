from posixpath import splitext
from getfiles import filenames

classifiers = {
    ".py": "python_package_py",
    ".pyc": "python_package_pyc",
    ".h": "python_package_headers",
    ".so": "python_package_sharedlibs",
}

splits = {}

MISC = "python_package_misc_files"

for fn in filenames:
    _, ext = splitext(fn)
    splits.setdefault(classifiers.get(ext, MISC), set()).add(fn)

template = """native.filegroup(
   name="{name}",
   srcs={name}_filenames,
)
"""

with open("splitfiles.bzl", "w") as fp:
    keys = list(classifiers.values()) + [MISC]

    for k in keys:
        v = splits.get(k, [])
        print(f"{k}_filenames = {sorted(v)!r}", file=fp)
    print("", file=fp)

    print("all_filenames = " + " + ".join( f"{k}_filenames" for k in keys), file=fp)
    print("", file=fp)

    print("def create_python_package_filegroups():", file=fp)
    for k in keys:
        print("   " + template.format(name=k), file=fp)

print("done")
