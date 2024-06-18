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
    Function *func = init_Function("7 3 /");

    Function_data *func_data = init_Function_data("7 3 /");
    set_first_derivative(func_data, "7 3 /");
    set_second_derivative(func_data, "7 3 /");


    printf("%d\n" , 444);

// //    set_variable(func, "y");
   // printf("%lf\n\n", func->obj_rpn->rpn[0]->obj->operand->obj);
//    printf("%u\n", func->obj_rpn->rpn[1]->type);
//    printf("%u\n", func->obj_rpn->rpn[2]->type);

    double val = func_subs(func, 5.0);

    printf("rddes: %lf", val); 

    del_Function(func);

    return 0;
}
