import os
import glob

print("getcwd:", os.getcwd())
print("LD_LIBRARY_PATH:", os.getenv("LD_LIBRARY_PATH"))
if p := os.getenv("LD_LIBRARY_PATH"):
   for path in p.split(":"):
      print(f"{path}: {' '.join(sorted(glob.glob(path+'/*.so')))}")

import sys

print("sys.path:")
for p in sorted(sys.path):
    print(f"  {p}")

import foo

assert 135 == foo.echo(135)
