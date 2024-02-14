import sys

import pytest
from pkg1.stuff import foo


def testme():
    assert foo() == "foo"

if __name__ == "__main__":
    sys.exit(pytest.main(sys.argv))
