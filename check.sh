#!/bin/bash

set -xe
find "$1"
[[ "this is a test" == "$(<"$1/other.txt")" ]]
[[ "" == "$(<"$1/test.sh")" ]]
