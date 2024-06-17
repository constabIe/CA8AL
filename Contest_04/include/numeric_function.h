#ifndef NUMERIC_FUNCTION_H
#define NUMERIC_FUNCTION_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <stdbool.h>
#include <regex.h>
#include <errno.h>
#include <signal.h>
#include <string.h>

typedef enum {
    EXP,
    LOG,
    SIN,
    COS,
    TAN,
    COT,
    SQRT,
    ADD,
    SUB,
    MUL,
    DIV,
    POW
} OperatorLabel;

typedef struct {
    void *func_ptr;
    OperatorLabel type;
} Unary;

typedef struct {
    OperatorLabel type;
} Binary;

typedef union {
    Unary *unary;
    Binary *binary;
} AnyOperator;

typedef enum {
    BINARY,
    UNARY
} OperatorTypeLabel;

typedef struct {
    AnyOperator *obj;
    OperatorTypeLabel type;
} Operator;

typedef struct {
    double obj;
} Operand;

typedef struct {
    char *obj;
} Variable;

typedef union {
    Operator *operator;
    Operand *operand;
    Variable *variable;
} AnyRpnElType;

typedef enum {
    OPERATOR,
    OPERAND,
    VARIABLE
} RPNelTypeLabel;

typedef struct {
    AnyRpnElType *obj;
    RPNelTypeLabel type;
} RPNelement;

typedef struct {
    RPNelement **rpn;
    uint32_t size;
} RPN;

typedef struct {
    RPN *obj_rpn;
    Variable *obj_var;
} Function;

double root(Function *f, Function *g, double a, double b, double eps1);
double integral(Function *f, double a, double b, double eps2);

double cot(double x);

double func_subs(Function *func, double val);

Function *init_Function(const char *raw_rpn);
void del_Function(Function *function);

void set_variable(Function *func, const char *var);

#endif // NUMERIC_FUNCTION_H