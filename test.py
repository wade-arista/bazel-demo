import os
import glob
import unittest

print("getcwd:", os.getcwd())
print("LD_LIBRARY_PATH:", os.getenv("LD_LIBRARY_PATH"))
if p := os.getenv("LD_LIBRARY_PATH"):
    for path in p.split(":"):
        for fn in sorted(glob.glob(path + "/*.so")):
            print(f"  {fn}")

import sys

print("PYTHONPATH:", os.getenv("PYTHONPATH"))
print("sys.path:")
for p in sorted(sys.path):
    print(f"  {p}")

import foo


class Test(unittest.TestCase):
    def test(self):
        self.assertEqual(135, foo.echo(135))


unittest.main()
