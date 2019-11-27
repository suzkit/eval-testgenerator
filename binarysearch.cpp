#ifdef KLEE
#include <klee/klee.h>
#endif

#include <stdlib.h>
#include <assert.h>

#define SIZE 3

int binary_search(int a[], int key){
    int low = 0;
    int high = SIZE;
    int i;
    int j = 0;
    int tmp;
    int *tmp2 = (int *)malloc(sizeof(int)*SIZE);

    while (low < high){
        int mid = low + (high - low) / 2;
        int midVal = a[mid];

        if (key < midVal) {
            high = mid;
            free(tmp2);
            for(i=high; i<SIZE; i++){
                assert(a[i] != key); // upper filtering is correct
                tmp2[j] = j;         // maybe write after free (it depends...)
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

#ifdef KLEE
    //klee_make_symbolic(&_a0, sizeof(int), "a0");
    _a0 = klee_range(0, 5, "a0");
    //klee_make_symbolic(&_a1, sizeof(int), "a1");
    _a1 = klee_range(5, 10, "a1");
    //klee_make_symbolic(&_a2, sizeof(int), "a2");
    _a2 = klee_range(10, 15, "a2");
    //klee_make_symbolic(&key, sizeof(key), "key");
    key = klee_range(-1, 16, "key");
    klee_assume(_a0 <= _a1);
    klee_assume(_a1 <= _a2);
    a[0] = _a0;
    a[1] = _a1;
    a[2] = _a2;
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

