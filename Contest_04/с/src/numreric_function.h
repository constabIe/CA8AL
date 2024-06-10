#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>
#include <errno.h>
#include <signal.h>
#include <string.h>

#define VERIFY_CONTRACT(contract, format, ...) \
    do { \
        if (!(contract)) { \
            printf((format), ##__VA_ARGS__); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)


typedef struct {
	void **rpn;
	size_t size;
} afunc;

typedef struct {
    int32_t class; // 0

	double operand;
} operand_t;

typedef struct {
    int32_t class; // 1
    int32_t unary_flag;

	char *operator;
	size_t len;
} operator_t;

typedef struct {
    int32_t class; // 2

    char *variable;
    size_t len;
} variable_t;


double _f_subs(afunc *function, variable_t var);

afunc *get_rpn();

afunc allocate_afunc();
void deallocate_afunc(afunc *obj);
void increment_afunc(afunc *obj);

operand_t *allocate_operand_t();
void deallocate_operand_t(operand_t *obj);

operator_t *allocate_operator_t();
void deallocate_operator_t(operator_t *obj);

variable_t *allocate_variable_t();
void deallocate_variable_t(variable_t *obj);








