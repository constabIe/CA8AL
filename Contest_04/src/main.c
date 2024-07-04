//#ifndef __i386__
//#error Wrong architecture!
//#endif

#include <stdio.h>

extern double f1(double val);
extern double f2(double val);

int main(void) {
    printf("f1(3) = %lf", f1(3));
    printf("f2(3) = %lf", f2(3));

    return 0;
}
