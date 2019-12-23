#!/bin/bash

#------------------------#
# consts for config
#------------------------#
LOG_FILE_HEADER=klee_test_log

TEST_FILES=(
# memory or pointer bug
    overrun_st.c \
    underrun_st.c \
    st_cross_thread_access.c \
    st_overflow.c \
    st_underrun.c \
    invalid_memory_access.c \
    memory_allocation_failure.c \
    memory_leak.c \
    return_local.c \
    uninit_memory_access.c \
    double_free.c \
    free_nondynamic_allocated_memory.c \
    free_null_pointer.c \
    func_pointer.c \
    null_pointer.c \
    ptr_subtraction.c \
    uninit_pointer.c \
    wrong_arguments_func_pointer.c \
    cmp_funcadr.c \
    littlemem_st.c \
    ow_memcpy.c \
    buffer_overrun_dynamic.c \
    buffer_underrun_dynamic.c \
    deletion_of_data_structure_sentinel.c \
# numerical calc bug
    pow_related_errors.c \
    sign_conv.c \
    zero_division.c \
    bit_shift.c \
    data_lost.c \
    data_overflow.c \
    data_underflow.c \
)




#------------------------#
# main
#------------------------#

LOG_FILE_DIR=${LOG_FILE_HEADER}"_"`date +%F%H%M%S`
LOG_FILE=${LOG_FILE_HEADER}"_"`date +%F%H%M%S`.txt

for i in ${TEST_FILES[@]}; do
    echo -n "###### ${i} -> " | tee -a ${LOG_FILE}
    if [ -e $i ]; then
        echo "exists ######" | tee -a ${LOG_FILE}
        ./do_klee_test.sh ${i} 2>&1 | tee -a ${LOG_FILE}
    else
        echo "not exists ######" | tee -a ${LOG_FILE}
    fi
done

./do_klee_test.sh summary
mkdir ${LOG_FILE_DIR}
mv klee_test_* ${LOG_FILE_DIR}
