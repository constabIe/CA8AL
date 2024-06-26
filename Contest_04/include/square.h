#ifndef SQUARE_H
#define SQUARE_H

#include <stdint.h>

#include "function.h"

typedef struct {
    Function *func;
    Function *func_prime;
    Function *func_prime_prime;
} Function_data;

double func_subs(Function *func, double val);
double root(Function_data *f, Function_data *g, double a, double b, double eps);
double integral(Function *f, double a, double b, double eps );

int32_t sign(double val);

#endif // SQUARE_H