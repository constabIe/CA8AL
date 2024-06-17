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

// extern double f_subs(Function *func, double val);

int main(void) {
    Function *func = init_Function("3");
    // printf("%lu\n" , sizeof(func->obj_rpn->rpn));

//    set_variable(func, "y");
   printf("%u\n", func->obj_rpn->rpn[0]->type);
   printf("%u\n", func->obj_rpn->rpn[1]->type);
   printf("%u\n", func->obj_rpn->rpn[2]->type);

    double val = func_subs(func, 4);

    printf("res: %lf", val);

    del_Function(func);

    return 0;
}
