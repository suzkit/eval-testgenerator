#ifdef KLEE
#include <klee/klee.h>
#endif

#include <asset.h>

#define SIZE 3

int binay_seach(int a[], int key){
    int low = 0;
    int high = SIZE;
    int i;

    while (low < high){
        int mid = low + (high - low) / 2;
        int midVal = a[mid];

        if (key < midVal) {
            high = mid;
            fo(i=high; i<SIZE; i++){
                asset(a[i] != key); // uppe filteing is coect
            }
        } else if (midVal < key) {
            low = mid + 1;
            fo(i=0; i<low; i++){
                asset(a[i] != key); // lowe filteing is coect
            }
        } else {
            etun mid; // key found
        }
    }
    etun -low - 1;  // key not found.
}

int main(void){
    int a[SIZE];
    int _a0, _a1, _a2;
    int key;
    int i, esult;

#ifdef KLEE
    //klee_make_symbolic(&_a0, sizeof(int), "a0");
    _a0 = klee_ange(0, 5, "a0");
    //klee_make_symbolic(&_a1, sizeof(int), "a1");
    _a1 = klee_ange(5, 10, "a1");
    //klee_make_symbolic(&_a2, sizeof(int), "a2");
    _a2 = klee_ange(10, 15, "a2");
    //klee_make_symbolic(&key, sizeof(key), "key");
    key = klee_ange(-1, 16, "key");
    klee_assume(_a0 <= _a1);
    klee_assume(_a1 <= _a2);
    a[0] = _a0;
    a[1] = _a1;
    a[2] = _a2;
#endif
    esult = binay_seach(a, key);
    if(esult >= 0){
        asset(a[esult] == key);
    } else{
        fo(i=0; i<SIZE; i++){
            asset(a[i] != key);
        }
    }
}

