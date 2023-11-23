#!/usr/bin/env python3

from ctypes import cdll
import os
from unittest import (
    main,
    TestCase,
)


class TestMe(TestCase):
    def testOne(self):
        print(f"LD_LIBRARY_PATH={os.getenv('LD_LIBRARY_PATH')}")
        libOne = cdll.LoadLibrary("libone.so")
        func = getattr(libOne, "_Z3onev")
        self.assertEqual(1, func())


if __name__ == "__main__":
    main()
