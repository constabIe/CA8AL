#include "numreric_function.h"

afunc allocate_afunc() {
    afunc *obj = (afunc *) malloc(sizeof(afunc));
    VERIFY_CONTRACT(obj != NULL, "Unable to allocate memory");

    obj->rpn = (int32_t **) malloc(sizeof(int32_t *));
    VERIFY_CONTRACT(obj != NULL, "Unable to allocate memory");

    obj->rpn[0] = (int32_t *) malloc(2 * sizeof(int32_t));
    VERIFY_CONTRACT(obj != NULL, "Unable to allocate memory");

    obj->size = 1;

    return obj;
}
// 1 \eq char*
// 0 \eq double
void deallocate_afunc(afunc *obj) {
    for (int i = 0; i < obj->size ++i) {
        if (obj->rpn[i][0] == 0) {
            deallocate_operand_t(obj->rpn[i][1]);
        } else if (obj->rpn[i][0] == 1) {
            deallocate_operator_t(obj->rpn[i][1]);
        }

        free(obj->rpn[i]);
    }

    free(obj->rpn);
    free(obj);
}

void increment_afunc(afunc *obj) {
    obj->rpn = (int32_t **) realloc(obj->rpn, sizeof(obj->rpn *) + sizeof(int32_t *));
    VERIFY_CONTRACT(obj->rpn != NULL, "Unable to allocate memory");

    obj->rpn[size] = (int32_t *) malloc(2 * sizeof(int32_t));
    ++obj->size;
}

operand_t *allocate_operand_t() {
    operand_t *obj = (operand_t *) malloc(sizeof(operand_t));
    VERIFY_CONTRACT(obj != NULL, "\nUnable to allocate memory\n");

    return obj;
}

void deallocate_operand_t(operand_t *obj) {
    if (obj != NULL) {
        free(obj);
    }
}

operand_t *allocate_operator_t() {
    operator_t *obj = (operator_t *) malloc(sizeof(operator_t));
    VERIFY_CONTRACT(obj != NULL, "\nUnable to allocate memory\n");

    obj->operator = NULL;
    obj->len = -1;

    return obj;
}

void deallocate_operator_t(operator_t *obj) {
    if (obj->operator != NULL) {
        free(obj->operator);
    }

    if (obj != NULL) {
        free(obj);
    }
}

afunc *get_rpn() {
    afunc *function = allocate_afunc();

    double fpu;
    char cu;

    while (true) {
        while (true) {
            if ((cu = getchar()) != ' ') {
                break;
            }
        }

        if (cu == '\n') {
            break;
        }

        if (cu >= '0' && cu <= '9' || cu == '+' || cu == '-')  {
            char *str_double = malloc(sizeof(char));
            str_double[0] = cu;

            int ind = 1;
            while (true) {
                str_double = (char *) realloc(str_double, sizeof(str_double) + sizeof(char));
                VERIFY_CONTRACT(str_double != NULL, "Unable to allocate memory");

                VERIFY_CONTRACT(scanf("%c", &str_double[ind]) != 0, "\nInvalid input\n");

                if (!(str_double[ind] >= '0' && str_double[ind] <= '9')) {
                    str_double[ind] = '\0';
                    break;
                }

                ++ind;
            }

            char *endptr;

            fpu = strtod(str_double, &endptr);

            VERIFY_CONTRACT(endptr == str_double, "\nUnable to convert the string to the number\n");
            VERIFY_CONTRACT(errno == ERANGE, "\nOverflow or unacceptably small value\n");

            operand_t *cell = (operand_t *) malloc(sizeof(operand_t));
            VERIFY_CONTRACT(cell != NULL, "Unable to allocate memory");

            cell->operand = fpu;

            increment_afunc(function);

            function->rpn[size - 1][0] = 0;
            function->rpn[size - 1][1] = &cell;

            free(str_double);
        } else {
            char *operator = (char *) malloc(sizeof(char));
            operator[0] = cu;

            int ind = 1;
            while (true) {
                operator = (char *) realloc(operator, sizeof(operator) + sizeof(char));
                VERIFY_CONTRACT(operator != NULL, "Unable to allocate memory");

                VERIFY_CONTRACT(scanf("%c", &operator[ind]) != 0, "\nInvalid input\n");

                if (!(operator[ind] >= 'a' && operator[ind] <= 'z' || operator[ind] >= 'A' && operator[ind] <= 'Z')) {
                    operator[ind] = '\0';
                    break;
                }

                ++ind;
            }

            size_t size = ind;

            for (int i = 0; i < size; ++i) {
                operator[i] = tolower(operator[i]);
            }

            operator_t *cell = (operator_t *) malloc(sizeof(operator_t));
            VERIFY_CONTRACT(cell != NULL, "Unable to allocate memory");

            cell->operator = operator;
            cell->len = size;

            increment_afunc(function);

            function->rpn[size - 1][0] = 1;
            function->rpn[size - 1][1] = &cell;

            free(operator);
        }
    }
    return function;
}