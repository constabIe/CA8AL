#ifndef FUNCTION_H
#define FUNCTION_H

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
} RawFunction;

typedef double (*generated_func_t) (double);

typedef struct {
    RawFunction *raw_func;
    generated_func_t subs_val;
} Function;

double cot(double x);

Function *init_Function(const char *raw_rpn, const char *func_name);
void del_Function(Function *function);

void intel_asm_cdecl_function_start_template(FILE *output, const char *func_name);
void intel_asm_cdecl_function_end_template(FILE *output);

void intel_asm_load_binary_operator_template(FILE *output);
void intel_asm_load_unary_operator_template(FILE *output);

void intel_asm_fpu_add_operator_template(FILE *output);
void intel_asm_fpu_sub_operator_template(FILE *output);
void intel_asm_fpu_mul_operator_template(FILE *output);
void intel_asm_fpu_div_operator_template(FILE *output);
void intel_asm_fpu_pow_operator_template(FILE *output);
void intel_asm_fpu_unary_operator_template(FILE *output);

void intel_asm_fpu_UPload_template(FILE *output);

void intel_asm_fpu_load_operand_template(FILE *output);
void intel_asm_fpu_load_variable_template(FILE *output);

RawFunction *init_RawFunction(const char *raw_rpn);
void del_RawFunction(RawFunction *function);

RPN *init_RPN(const char *raw_rpn);
void del_RPN(RPN *rpn);

char **split(const char *str, uint32_t *num_tokens);
bool matchesRegex(const char *string, const char *pattern);
bool isRPN(RPN *obj_rpn);

RPNelement *init_RPNelement(RPNelTypeLabel rpn_el_type);
void del_RPNelement(RPNelement *rpn_el);

Operator *init_Operator(OperatorLabel operation_name);
void del_Operator(Operator *operator);

Operand *init_Operand(double val);
void del_Operand(Operand *operand);

Variable *init_Variable(const char *str);
void del_Variable(Variable *variable);

#endif // FUNCTION_H