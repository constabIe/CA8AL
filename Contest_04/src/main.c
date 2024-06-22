#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "../include/numeric_function.h"

#define EPS 0.001

// extern double f_subs(Function *func, double val);

int main(void) {
    Function *func = init_Function("3 7 /", "f1");
    del_Function(func);

    return 0;
}
