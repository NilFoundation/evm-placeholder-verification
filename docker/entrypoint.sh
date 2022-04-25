#!/bin/bash
cat "${1:-/dev/stdin}" > /.secret
export LD_LIBRARY_PATH=/usr/local/lib/
# shellcheck disable=SC2164
cd /home/app/build/benchmark/
./run.sh /.secret