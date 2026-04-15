#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#define MAX_OP 6   // max 5 chars + null

int main() {
    char op[MAX_OP];
    int num1, num2;

    while (1) {
        // Read input
        if (scanf("%5s %d %d", op, &num1, &num2) != 3) {
            break;  // stop on EOF / invalid input
        }

        // Build library name: lib<op>.so
        char libname[20];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // Load shared library
        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading %s\n", libname);
            continue;
        }

        // Get function symbol
        int (*func)(int, int);
        *(void **)(&func) = dlsym(handle, op);

        if (!func) {
            fprintf(stderr, "Error finding function %s\n", op);
            dlclose(handle);
            continue;
        }

        // Call function
        int result = func(num1, num2);

        // Print result
        printf("%d\n", result);

        // IMPORTANT: free memory
        dlclose(handle);
    }

    return 0;
}