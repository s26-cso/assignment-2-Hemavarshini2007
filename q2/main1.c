#include <stdio.h>
#include <stdlib.h>

// Assembly function
// arr = input array
// n = size
// result = output array
void next_greater(int *arr, int n, int *result);

int main(int argc, char *argv[]) {
    // number of elements
    int n = argc - 1;

    if (n <= 0) {
        return 0;
    }

    int arr[n];
    int result[n];

    // convert input strings to integers
    for (int i = 0; i < n; i++) {
        arr[i] = atoi(argv[i + 1]);
    }

    // call assembly function
    next_greater(arr, n, result);

    // print result
    for (int i = 0; i < n; i++) {
        printf("%d ", result[i]);
    }
    printf("\n");

    return 0;
}