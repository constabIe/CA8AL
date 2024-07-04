#ifndef __i386__
#error Wrong architecture!
#endif

#include "function.h"

int main(void) {
    printf("dddd");
    init_Function("3 2 /", "f1");
    init_Function("3 x + 4 *", "f2");

    return 0;
}
