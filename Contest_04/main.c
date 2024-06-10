#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>
//#include <regex.h>
#include <errno.h>

#include "/Users/almiravhadiev/Downloads/HSE/Computer_Architecture_and_Assembly_Language/Assembly_Practice/Contest_04/с/src/numreric_function.h"

int main(void) {
    afunc *function = get_rpn();

    printf("{");
    for (int i = 0; i < function->size ; ++i) {
        if (!function->rpn[i][0]) {
            printf("{%d, %lf}", function->rpn[i][0], function->rpn[i][1]->operand);
        } else {
            printf("{%d, %s}", function->rpn[i][0], function->rpn[i][1]->operator);
        }

    }
}
