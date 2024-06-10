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
    const char *BINARY_OPERATORS[5] = {"pow", "+", "-", "*", "/"};
    const char *UNARY_OPERATORS[6] = {"exp", "log", "sin", "cos", "tan", "ctg"};
    const char *CONSTANTS[2] = {"pi", "e"};

    afunc *function = allocate_afunc();

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

        if (cu == '+' || cu == '-') {
            cu = getchar();

            if (cu == ' ') {
                operator_t *cell = allocate_operator_t();

                cell->unary_flag = 0;

                cell->operator = (char *) malloc(2 * sizeof(char));
                cell->operator[0] = cu;
                cell->operator[1] = '\0';

                cell->len = 1;
            }
            else if (cu >= '0' && cu <= '9' ) {

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
                double fpu = strtod(str_double, &endptr);

                VERIFY_CONTRACT(endptr == str_double, "\nUnable to convert the string to the number\n");
                VERIFY_CONTRACT(errno == ERANGE, "\nOverflow or unacceptably small value\n");

                operand_t *cell = allocate_operand_t();

                cell->operand = fpu;

                increment_afunc(function);

                function->rpn[size - 1][0] = 0;
                function->rpn[size - 1][1] = cell;

                free(str_double);
            }
        }

         else if (cu == '+' || cu == '-' || cu == '*' || cu == '/') {
            operator_t *cell = allocate_operator_t();

            cell->unary_flag = 0;

            cell->operator = (char *) malloc(2 * sizeof(char));
            cell->operator[0] = cu;
            cell->operator[1] = '\0';

            cell->len = 1;
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



            if (str)
//
//            for (int i = 0; i < size; ++i) {
//                operator[i] = tolower(operator[i]);
//            }
//
//            operator_t *cell = (operator_t *) malloc(sizeof(operator_t));
//            VERIFY_CONTRACT(cell != NULL, "Unable to allocate memory");
//
//            cell->operator = operator;
//            cell->len = size;
//
//            increment_afunc(function);
//
//            function->rpn[size - 1][0] = 1;
//            function->rpn[size - 1][1] = cell;
//
//            free(operator);
        }
    }
    return function;
}

// [pi e] log exp pow