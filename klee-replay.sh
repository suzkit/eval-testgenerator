#!/bin/bash

LD_LIBRARY_PATH=/home/klee/klee_build/lib/
for i in `ls klee-last/*ktest`; do
    KTEST_FILE=${i} ./binarysearch
done
