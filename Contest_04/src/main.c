#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>
//#include <regex.h>
#include <errno.h>

#include "../include/numeric_function.h"
#define EPS 0.001

// extern double f_subs(Function *func, double val);

int main(void) {
    Function *func = init_Function("x 3 /");

    Function_data *func_data = init_Function_data("32 43 * x exp + 65 2 pow /");
    set_first_derivative(func_data, "7 3 /");
    set_second_derivative(func_data, "7 3 /");

    double val = func_subs(func, 5.0);

    printf("res: %lf\n", val); 

    del_Function_data(func_data);
    del_Function(func);

    return 0;
}
