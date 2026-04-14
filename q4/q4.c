#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

/**
 * To compile: gcc q4.c -o q4 -ldl
 * The -ldl flag is required to link the dynamic linking library.
 */

int main() {
    char op[10]; 
    int num1, num2;

    // 3 inputs: the string <op> and two integers
    while (scanf("%s %d %d", op, &num1, &num2) == 3) {
        
        // Construct the library name: lib<op>.so
        char filename[32];
        sprintf(filename, "./lib%s.so", op);

        // Load the library into memory 
        void *handle = dlopen(filename, RTLD_NOW);
        if (!handle) {
            // If library isn't found or can't be loaded, print error and skip
            fprintf(stderr, "Error: %s\n", dlerror());
            continue;
        }

        // Find the function within the library. 
        // The problem says the function name is exactly <op>.
        int (*math_func)(int, int);
        math_func = (int (*)(int, int)) dlsym(handle, op);

        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Error finding function: %s\n", error);
            dlclose(handle);
            continue;
        }

        // Perform the calculation and print the result
        int result = math_func(num1, num2);
        printf("%d\n", result);

        // Close the library.
        // This frees the 1.5GB of memory so we can load the next one.
        dlclose(handle);
    }

    return 0;
}
