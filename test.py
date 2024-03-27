#!?usr/bin/env python3

from posixpath import realpath
import sys
print("executable:", sys.executable)
import unittest


class Test(unittest.TestCase):
    def test(self):
        print(sys.version)
        print("executable:", realpath(sys.executable))
        print("path:")
        for p in sys.path:
            print(" ", realpath(p))

unittest.main()
