import unittest

from pkg1.stuff import foo


class Test(unittest.TestCase):
    def test(self):
        self.assertEqual(foo(), "foo")


if __name__ == "__main__":
    unittest.main()
