#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#include "../include/function.h"
#include "../include/square.h"

#define EPS 0.001

// extern double f_subs(Function *func, double val);

int main(void) {
    clock_t begin = clock();

    Function *func = init_Function("3 7 /", "f1");
    Function *func_2 = init_Function("3 7 /", "f2");
    del_Function(func);
    del_Function(func_2);

    clock_t end = clock();
    double time_spent = (double) (end - begin) / CLOCKS_PER_SEC;

    printf("\nExecution time: %lf sec\n", time_spent);

    return 0;
}
