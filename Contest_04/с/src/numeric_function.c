#include "numreric_function.h"

#define OPERATORS (char **) {""}

afunc allocate_afunc() {
    afunc *obj = (afunc *) malloc(sizeof(afunc));
    VERIFY_CONTRACT(obj != NULL, "Unable to allocate memory");

    obj->rpn = (void **) malloc(sizeof(void *));
    VERIFY_CONTRACT(obj != NULL, "Unable to allocate memory");

    obj->size = 1;

    return obj;
}
// 1 \eq char*
// 0 \eq double
void deallocate_afunc(afunc *obj) {
    if (obj != NULL) {
        if (obj->rpn != NULL) {
            for (int i = 0; i < obj->size++i) {
                if (obj->rpn[i] != NULL) {
                    switch (obj->rpn[i]->class) {
                        case 0:
                            deallocate_operand_t(obj->rpn[i]);
                            break;
                        case 1:
                            deallocate_operator_t(obj->rpn[i]);
                            break;
                        case 2:
                            deallocate_variable_t(obj->rpn[i]);
                            break;
                        default:
                            raise(SIGSEGV);
                    }
                    free(obj->rpn[i]);
                }
            }
            free(obj->rpn);
        }
        free(obj);
    }
}

void increment_afunc(afunc *obj) {
    obj->rpn = (void **) realloc(obj->rpn, sizeof(obj->rpn *) + sizeof(void *));
    VERIFY_CONTRACT(obj->rpn != NULL, "Unable to allocate memory");

    ++obj->size;
}

operand_t *allocate_operand_t() {
    operand_t *obj = (operand_t *) malloc(sizeof(operand_t));
    VERIFY_CONTRACT(obj != NULL, "\nUnable to allocate memory\n");

    obj->class = 0;

    return obj;
}

void deallocate_operand_t(operand_t *obj) {
    if (obj != NULL) {
        free(obj);
    }
}

operator_t *allocate_operator_t() {
    operator_t *obj = (operator_t *) malloc(sizeof(operator_t));
    VERIFY_CONTRACT(obj != NULL, "\nUnable to allocate memory\n");

    obj->class = 1;
    obj->unary_flag = -1;

    // initial parameters
    obj->operator = NULL;
    obj->len = -1;

    return obj;
}

void deallocate_operator_t(operator_t *obj) {
    if (obj->operator != NULL) {
        free(obj->operator);
    }

    free(obj);
}

variable_t *allocate_variable_t() {
    variable_t *obj = (variable_t *) malloc(sizeof(variable_t));
    VERIFY_CONTRACT(obj != NULL, "\nUnable to allocate memory\n");

    obj->class = 2;

    // initial parameters
    obj->variable = NULL;
    obj->len = -1;

    return obj;
}
void deallocate_variable_t(variable_t *obj); {
    if (obj->variable != NULL) {
        free(obj->variable);
    }

    free(obj);
}

afunc *get_rpn() {
    const char *BINARY_OPERATORS[5] = {"+", "-", "*", "/", "pow"};
    const char *UNARY_OPERATORS[6] = {"exp", "log", "sin", "cos", "tan", "ctg"};
    const char *CONSTANTS[2] = {"pi", "e"};

    afunc *function = allocate_afunc();

    while (true) {
        bool exit_flag = false;

        char cu;
        while (true) {
            if ((cu = getchar()) != ' ') {
                break;
            }
        }

        char *segment = calloc(300 * sizeof(char));
        segment[0] = cu;

        int ind = 1;
        while (true) {
            cu = getchar();

            if (cu == ' ') {
                break;
            }

            if (cu == '\n') {
                exit_flag = true;
                break;
            }

            segment[ind] = cu;
            ++ind;
        }

        char *endptr;
        double fpu = strtod(segment, &endptr);

        if (endptr != segment) {

        }
    }
    return function;
}

// [pi e] log exp pow