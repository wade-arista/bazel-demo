#!/bin/bash
data=$(<$1)
set -ex
[ "$data" == "version1" ]
