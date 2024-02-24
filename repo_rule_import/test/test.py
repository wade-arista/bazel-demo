#!/usr/bin/env python3

import bar
import foo

def main():
    assert bar.name == "bar"
    assert foo.name == "foo"
    print( "passed" )

assert __name__ == "__main__"
main()
