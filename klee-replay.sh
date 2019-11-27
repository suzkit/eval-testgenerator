#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 /path/to/binary"
    exit 1
fi

LD_LIBRARY_PATH=/home/klee/klee_build/lib/
for i in `ls klee-last/*ktest`; do
    KTEST_FILE=${i} ./${1}
done
