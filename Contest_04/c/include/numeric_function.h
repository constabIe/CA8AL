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
    const Operator *operator;
    const Operand *operand;
    const Variable *variable;
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


// void change_global_operator_name(OperatorLabel new_operator);
// void change_global_val(double new_val);
// void change_global_str(const char *new_str);

double cot(double x);

double _f_subs(Function *func, double val);

Function *init_Function(const char *raw_rpn);
void del_Function(Function *function);

void set_variable(Function *func, const char *var);

// RPN *init_RPN(const char *raw_rpn);
// void del_RPN(RPN *rpn);

// char **split(const char *str, uint32_t *num_tokens);
// int matchesRegex(const char *string, const char *pattern);
// bool isRPN(RPN *obj_rpn);

// RPNelement *init_RPNelement(RPNelTypeLabel rpn_el_type);
// void del_RPNelement(RPNelement *rpn_el);

// Operator *init_Operator(OperatorLabel operation_name);
// void del_Operator(Operator *operator);

// Operand *init_Operand(double val);
// void del_Operand(Operand *operand);

// Variable *init_Variable(const char *str);
// void del_Variable(Variable *variable);

#endif // NUMERIC_FUNCTION_H