#!/bin/bash


#--------------------------------#
# consts
#--------------------------------#

declare -A FILE_IDS
FILE_IDS["overrun_st.c"]=32
FILE_IDS["underrun_st.c"]=44
FILE_IDS["st_cross_thread_access.c"]=41
FILE_IDS["st_overflow.c"]=42
FILE_IDS["st_underrun.c"]=43
FILE_IDS["invalid_memory_access.c"]=24
FILE_IDS["memory_allocation_failure.c"]=28
FILE_IDS["memory_leak.c"]=29
FILE_IDS["return_local.c"]=38
FILE_IDS["uninit_memory_access.c"]=45
FILE_IDS["double_free.c"]=12
FILE_IDS["free_nondynamic_allocated_memory.c"]=16
FILE_IDS["free_nondynamically_allocated_memory.c"]=16
FILE_IDS["free_null_pointer.c"]=17
FILE_IDS["func_pointer.c"]=18
FILE_IDS["null_pointer.c"]=31
FILE_IDS["ptr_subtraction.c"]=35
FILE_IDS["uninit_pointer.c"]=46
FILE_IDS["wrong_arguments_func_pointer.c"]=50
FILE_IDS["cmp_funcadr.c"]=4
FILE_IDS["littlemem_st.c"]=25
FILE_IDS["ow_memcpy.c"]=33
FILE_IDS["buffer_overrun_dynamic.c"]=2
FILE_IDS["buffer_underrun_dynamic.c"]=3
FILE_IDS["deletion_of_data_structure_sentinel.c"]=11
FILE_IDS["pow_related_errors.c"]=34
FILE_IDS["sign_conv.c"]=39
FILE_IDS["zero_division.c"]=51
FILE_IDS["bit_shift.c"]=1
FILE_IDS["data_lost.c"]=6
FILE_IDS["data_overflow.c"]=7
FILE_IDS["data_underflow.c"]=8

ERROR_MESSAGE="Tool should detect this line as error"

#--------------------------------#
# config
#--------------------------------#

MAINFUNC_FILENAME=main.c
TESTCODE_FILENAME=klee_test_
RESULT_FILENAME=klee_test_result.txt
KLEE=klee

#--------------------------------#
# sub
#--------------------------------#

function clean {
    rm -rf *.bc klee-out* klee-last klee_test_*
}

function summary {
    for i in `ls -lhsrt --color=none | grep drwx | perl -lane 'print $F[-1]' `; do
        cat ${i}/klee_test_result.txt >> all_result.txt
    done
}

function gen_testharness {
    local target_source_file=$1
    local output_filename=$2
    local tempfile=$(mktemp)

    #if [ ${target_source_file} = "sign_conv.c" ]; then
    #    cp ${target_source_file} ${output_filename}
    #    return
    #fi

    cat ${target_source_file} | perl -lane 's/(^extern .* vflag;$)/\/\/$1/g; print' > ${tempfile}

    if [ `get_fileid ${target_source_file}` = "31" -o `get_fileid ${target_source_file}` = "7" ]; then
        local tempfile2=$(mktemp)
        cat ${tempfile} | perl -lane 's/^(static int sink;)/\/\/$1/g; print' > ${tempfile2}
        mv ${tempfile2} ${tempfile}
    fi

    cat ${MAINFUNC_FILENAME} ${tempfile} > ${output_filename}
}

function compile_testcode {
    if [ $1 = "st_underrun.c" ]; then
        clang -I ../../../include -I ../include -emit-llvm -DKLEE -DNDEBUG -c -O0 -Xclang -disable-O0-optnone $1
    else
        clang -I ../../../include -I ../include -emit-llvm -DKLEE -DNDEBUG -g -c -O0 -Xclang -disable-O0-optnone $1
    fi
}

function get_fileid {
    local base_filename=$1
    echo ${FILE_IDS[$base_filename]}
}

function result_log {
    echo "$@" >> ${RESULT_FILENAME}
}

function do_klee_test {
    local base_filename=$1
    local testcode_filename=$2
    local bitcode_filename=$3
    local test_ids=`cat ${base_filename} | \
                        grep vflag | \
                        perl -lane "s/^\t//g; s/==/ /g; s/ +/ /g; print" | \
                        perl -lane 'print $F[2] if !/vflag;/' | \
                        sort -n`
    local max_id=`echo ${test_ids} | perl -lane 'print $F[-1]'`
    local file_id=`get_fileid ${base_filename}`
    local error_line=""
    local count_exact=0
    local count_detect=0
    local count_not_detect=0

    result_log "#---------------------------------------#"
    result_log "# ${base_filename} test results"
    result_log "# source code under the test: ${testcode_filename}"
    result_log "#---------------------------------------#"

    for i in ${test_ids}; do
        ${KLEE} ${bitcode_filename} ${file_id}`printf %03d ${i}`
        if [ -e klee-last/*.err ]; then
            count_detect=$((count_detect+1))
            error_line_no=$(cat klee-last/*.err \
                            | grep -A1 Stack \
                            | tail -n 1 \
                            | perl -lane 's/:/ /g; print' \
                            | perl -lane 'print $F[-1]')
            error_line=$(cat ${testcode_filename} \
                            | head -n ${error_line_no} \
                            | tail -n 1 \
                            | grep "Tool should detect this line as error")
            if [ -n "$error_line" ]; then
                set -f
                result_log `printf "%d%03d defect detected -> %s" ${file_id} ${i} "${error_line}"`
                set +f
                count_exact=$((count_exact+1))
            else
               result_log `printf "%d%03d defect detected but not expected line (%d @ %s)" ${file_id} ${i} ${error_line_no} ${testcode_filename}`
            fi
        else
           result_log `printf "%d%03d defect NOT detected" ${file_id} ${i}`
            count_not_detect=$((count_not_detect+1))
        fi
        error_line=""
    done
    result_log "score(exact match): ${count_exact} / ${max_id}"
    result_log "score(detected): ${count_detect} / ${max_id}"
    result_log "score(not detected): ${count_not_detect} / ${max_id}"
    result_log ""
}

function result_save {
    local base_filename=$1
    local testcode_filename=$2
    local bitcode_filename=$3
    local dirname=klee_test_${base_filename/.c/}

    mkdir ${dirname}
    cp ${base_filename} ${testcode_filename} ${bitcode_filename} ${dirname}
    mv klee-out* ${RESULT_FILENAME} ${dirname}
}

#--------------------------------#
# main
#--------------------------------#

if [ $# -ne 1 ]; then
    echo "usage: $0 (target_source_file|clean|summary)"
    exit 1
fi

if [ $1 = "clean" ]; then
    clean
    exit 0
fi

if [ $1 = "summary" ]; then
    summary
    exit 0
fi

BASE_FILENAME=${1}
TESTCODE_FILENAME=${TESTCODE_FILENAME}${1}
BITCODE_FILENAME=${TESTCODE_FILENAME/.c/.bc}

gen_testharness $1 ${TESTCODE_FILENAME}
compile_testcode ${TESTCODE_FILENAME}
do_klee_test ${BASE_FILENAME} ${TESTCODE_FILENAME} ${BITCODE_FILENAME}
result_save ${BASE_FILENAME} ${TESTCODE_FILENAME} ${BITCODE_FILENAME}
