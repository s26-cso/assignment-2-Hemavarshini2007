#include <stdio.h>

// 🔹 Declare your assembly function(s)
int func(int a, int b);   // change name/signature as per q2

int main() {
    int a = 10;
    int b = 5;

    int result = func(a, b);

    printf("Result = %d\n", result);

    return 0;
}