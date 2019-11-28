#ifdef KLEE
#include <klee/klee.h>
#endif

#include <stdio.h>
#include <assert.h>

#define SIZE 3

int binary_search(int a[], int key){
    int low = 0;
    int high = SIZE;
    int i;

    while (low < high){
        int mid = low + (high - low) / 2;
        int midVal = a[mid];

        if (key < midVal) {
            high = mid;
            for(i=high; i<SIZE; i++){
                assert(a[i] != key); // upper filtering is correct
            }
        } else if (midVal < key) {
            low = mid + 1;
            for(i=0; i<low; i++){
                assert(a[i] != key); // lower filtering is correct
            }
        } else {
            return mid; // key found
        }
    }
    return -low - 1;  // key not found.
}

int main(void){
    int a[SIZE];
    int _a0, _a1, _a2;
    int key;
    int i, result;
    char tmp[5] = {0};

#ifdef KLEE
    for(i = 0; i < SIZE; i++) {
        sprintf(tmp, "a%d", i);
        a[i] = klee_range(5*i, 5*(i+1), tmp);
        if(i != 0) {
            klee_assume(a[i-1] <= a[i]);
        }
    }
    key = klee_range(-1, 16, "key");
#endif
    result = binary_search(a, key);
    if(result >= 0){
        assert(a[result] == key);
    } else{
        for(i=0; i<SIZE; i++){
            assert(a[i] != key);
        }
    }
}

