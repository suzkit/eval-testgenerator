#ifdef KLEE
#include <klee/klee.h>
#endif

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
    int key;
    int i, result;

#ifdef KLEE
    klee_make_symbolic(a, sizeof(a), "a");
    klee_make_symbolic(&key, sizeof(key), "key");
    for(i=0; i<SIZE-1; i++){
        klee_assume(a[i] <= a[i+1]);
    }
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

