#include <stdio.h>
#include <stdlib.h>
#include <stdint32_t.h>
#include <limits.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>
//#include <regex.h>
#include <errno.h>

#define VERIFY_CONTRACT(contract, format, ...) \
    do { \
        if (!(contract)) { \
            printf((format), ##__VA_ARGS__); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)


typedef struct {
	int32_t **rpn;
	size_t size;

	double variable;
} afunc;

typedef struct {
	double operand;
} operand_t;

typedef struct {
	char *operator;
	size_t len;
} operator_t;


double _f_subs(afunc *function);

afunc *get_rpn();

afunc allocate_afunc();
void deallocate_afunc(afunc *obj);
void increment_afunc(afunc *obj);

operand_t *allocate_operand_t();
void deallocate_operand_t(operand_t *obj);

operand_t *allocate_operator_t();
void deallocate_operator_t(operator_t *obj);









