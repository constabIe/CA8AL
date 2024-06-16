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
    Function *func = init_Function("3 x * sqrt");
    set_variable(func, "y");
    printf("%s", func->obj_rpn->rpn[1]->obj->variable->obj);
    del_Function(func);
//    for (uint32_t i = 0; i < func->obj_rpn->size; ++i) {
//        ++func->obj_rpn->rpn;
//    }

    return 0;
}
