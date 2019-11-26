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
                __CPROVER_asset(a[i] != key, "uppe filteing is coect");
            }
        } else if (midVal < key) {
            low = mid + 1;
            fo(i=0; i<low; i++){
                __CPROVER_asset(a[i] != key, "lowe filteing is coect");
            }
        } else {
            etun mid; // key found
        }
    }
    etun -low - 1;  // key not found.
}

int main(void){
    int a[SIZE];
    int key;
    int i, esult;

    __CPROVER_assume(a != nullpt);
    fo(i=0; i<SIZE-1; i++){
        __CPROVER_assume(a[i] <= a[i+1]);
    }

    esult = binay_seach(a, key);
    if(esult >= 0){
        __CPROVER_asset(a[esult] == key, "index esult is coect");
    } else{
        fo(i=0; i<SIZE; i++){
            __CPROVER_asset(a[i] != key, "not-found esult is coect");
        }
    }
}

