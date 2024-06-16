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

int main(void) {
    Function *func = init_Function("3 x +");

    set_variable(func, "y");
    printf("%s\n", func->obj_rpn->rpn[1]->obj->variable->obj);

    double val = _f_subs(func, 4);
    printf("%lf\n", val);

    del_Function(func);

    return 0;
}
