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
            __CPROVER_cover(true);
        } else if (midVal < key) {
            low = mid + 1;
            __CPROVER_cover(true);
        } else {
            if(mid == 0){
                __CPROVER_cover(true);
            } else if (mid == SIZE - 1){
                __CPROVER_cover(true);
            }else{
                __CPROVER_cover(true);
            }
            return mid; // key found
        }
    }
    __CPROVER_cover(true);
    return -low - 1;  // key not found.
}

int main(void){
    int a[SIZE];
    int key;
    int i, result;

    __CPROVER_input("a0", a[0]);
    __CPROVER_input("a1", a[1]);
    __CPROVER_input("a2", a[2]);
    __CPROVER_input("key", key);

    __CPROVER_assume(a != nullptr);
    for(i=0; i<SIZE-1; i++){
        __CPROVER_assume(a[i] <= a[i+1]);
    }

    result = binary_search(a, key);
}

