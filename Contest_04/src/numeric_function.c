#include "../include/numeric_function.h"
#include "../include/utils.h"

#define VERIFY_CONTRACT(contract, format, ...) \
    do { \
        if (!(contract)) { \
            printf( \
                "\n[%s:%d:%s] " format "\n", \
                __FILE__, __LINE__, __func__, \
                ##__VA_ARGS__); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)

#define REGEX_Q 15
#define UNARY_Q 7

static const char *global_regex[REGEX_Q] =
        {"^exp$", "^log$", "^sin$", "^cos$", "^tan$", "^cot$", "^sqrt$", "^\\+$", "^\\-$", "^\\*$", "^\\/+$",
         "^[-+]?([0-9]*[.])?[0-9]+([eE][-+]?\\d+)?$", "^pi$", "^e$",
         "^[a-zA-Z]+[0-9_]*$"};
static const void *global_unary_operators_ptrs[UNARY_Q] = {exp, log, sin, cos, tan, cot, sqrt};

static OperatorLabel global_operator_name;
static double global_val;
static char *global_str;

static void change_global_operator_name(OperatorLabel new_operator);
static void change_global_val(double new_val);
static void change_global_str(const char *new_str);

static RPN *init_RPN(const char *raw_rpn);
static void del_RPN(RPN *rpn);

static int32_t sign(double val);
 
static char **split(const char *str, uint32_t *num_tokens);
static int matchesRegex(const char *string, const char *pattern);
static bool isRPN(RPN *obj_rpn);
 
static RPNelement *init_RPNelement(RPNelTypeLabel rpn_el_type);
static void del_RPNelement(RPNelement *rpn_el);
 
static Operator *init_Operator(OperatorLabel operation_name);
static void del_Operator(Operator *operator);
 
static Operand *init_Operand(double val);
static void del_Operand(Operand *operand);
 
static Variable *init_Variable(const char *str);
static void del_Variable(Variable *variable);

// double root(Function *f, Function *g, double a, double b, double eps1) {
//     VERIFY_CONTRACT(a <= b, "Invalid range");
//     if (f == NULL || g == NULL) {
//         raise(SIGSEGV);
//     }

//     double  a_i = a, 
//             b_i = b, 
//             c_i = (b_i - a_i) / 2;

//     while (true) {
//         if (fabs(a_i - b_i) < eps1) {
//             break;
//         }

//         double F_abc[3] = {func_subs(f, a_i) - func_subs(g, a_i),
//                             func_subs(f, c_i) - func_subs(g, c_i), 
//                             func_subs(f, b_i) - func_subs(g, b_i)};

//         if (sign(F_abc[0]) != sign(F_abc[1])) {
//             b_i = c_i;
//         } 
//         else if (sign(F_abc[1]) != sign(F_abc[0])) {
//             a_i = c_i; 
//         }
//         else {
//             VERIFY_CONTRACT(0, "Invalid arguments were passed")ж
//         }

//         c_i = (b_i - a_i) / 2;
//     }

//     double root = a_i + DBL_MIN;

//     return root;
// }
double integral(Function *f, double a, double b, double eps2);

static int32_t sign(double val) {
    if (val > 0) {
        return 1;
    }
    else if (val < 0) {
        return -1;
    }
    else {
        return 0;
    }
}

double cot(double x) {
    return 1 / tan(x);
}

Function *init_Function(const char *raw_rpn) {
    Function *function = (Function *) malloc(sizeof(Function));
    VERIFY_CONTRACT(function != NULL, "Unable to allocate memory");

    function->obj_rpn = init_RPN(raw_rpn);
    function->obj_var = NULL;

    bool isvarset = false;
    for (uint32_t i = 0; i < function->obj_rpn->size; ++i) {
        if (function->obj_rpn->rpn[i]->type == VARIABLE) {
            if (!isvarset) {
                function->obj_var = init_Variable(function->obj_rpn->rpn[i]->obj->variable->obj);
                isvarset = true;
            }
            else {
                VERIFY_CONTRACT(0, "Only R^2 dimension");
            }
        }
    }

    return function;
}
void del_Function(Function *function) {
    if (function != NULL) {
        if (function->obj_rpn != NULL) {
            del_RPN(function->obj_rpn);
        }
        if (function->obj_var != NULL) {
            del_Variable(function->obj_var);
        }
        free(function);
    }
}

void set_variable(Function *func, const char *var) {
    if (func == NULL) {
        raise(SIGSEGV);
    }
     
    for (uint32_t i = 0; i < func->obj_rpn->size; ++i) {
        if (func->obj_rpn->rpn[i]->type == VARIABLE) {
            del_RPNelement(func->obj_rpn->rpn[i]);

            change_global_str(var);
            func->obj_rpn->rpn[i] = init_RPNelement(VARIABLE);
        }
    }
}

static void change_global_operator_name(OperatorLabel new_operator) {
    VERIFY_CONTRACT(EXP <= new_operator && new_operator <= POW, "Invalid operation");
    global_operator_name = new_operator;
}
static void change_global_val(double new_val) {
    global_val = new_val;
}
static void change_global_str(const char *new_str) {
    if (new_str == NULL) {
        raise(SIGSEGV);
    }

    if (global_str != NULL) {
        free(global_str);
    }

    global_str = strdup(new_str);
    VERIFY_CONTRACT(global_str != NULL, "Unable to allocate memory");
}

static RPN *init_RPN(const char *raw_rpn) {
    if (raw_rpn == NULL) {
        raise(SIGSEGV);
    }

    RPN *obj_rpn = (RPN *) malloc(sizeof(RPN));
    VERIFY_CONTRACT(obj_rpn != NULL, "Unable to allocate memory");

    obj_rpn->rpn = (RPNelement **) malloc(sizeof(RPNelement));
    VERIFY_CONTRACT(obj_rpn->rpn != NULL, "Unable to allocate memory");
    uint32_t ind_rpn = 0;

    uint32_t num_tokens = 0;
    char **tokens = split(raw_rpn, &num_tokens);

    for (uint32_t i = 0; i < num_tokens; ++i) {
        bool match = false;
        for (uint32_t j = 0; j < REGEX_Q; ++j) {
            if (matchesRegex(tokens[i], global_regex[j])) {
                match = true;
                if (j <= 10) {
                    change_global_operator_name(j);
                    obj_rpn->rpn[ind_rpn] = init_RPNelement(OPERATOR);
                }
                else if (j <= 13) {
                    if (j == 11) {
                        char *endptr;
                        double fpu = strtod(tokens[i], &endptr);
                        VERIFY_CONTRACT(endptr != tokens[i], "Unable convert str to double");

                        change_global_val(fpu);
                    }
                    else if (j == 12) {
                        change_global_val(M_PI);
                    }
                    else {
                        change_global_val(M_E);
                    }
                    obj_rpn->rpn[ind_rpn] = init_RPNelement(OPERAND);
                }
                else {
                    change_global_str(tokens[i]);
                    obj_rpn->rpn[ind_rpn] = init_RPNelement(VARIABLE);
                }
                break;
            }
        }
        VERIFY_CONTRACT(match, "Incorrect symbols for the RPN");

        if (i < num_tokens) {
            ++ind_rpn;

            obj_rpn->rpn = (RPNelement **) realloc(obj_rpn->rpn, (ind_rpn + 1) * sizeof(RPNelement *));
            VERIFY_CONTRACT(obj_rpn->rpn != NULL, "Unable to allocate memory");
        }
    }
    obj_rpn->size = ind_rpn;

    VERIFY_CONTRACT(isRPN(obj_rpn), "Incorrect order of the RPN elements");

    for (uint32_t i = 0; i < num_tokens; ++i) {
        free(tokens[i]);
    }
    free(tokens);

    return obj_rpn;
}
static void del_RPN(RPN *obj_rpn) {
    if (obj_rpn != NULL) {
        if (obj_rpn->rpn != NULL) {
            for (uint32_t i = 0; i < obj_rpn->size; ++i) {
                if (obj_rpn->rpn[i] != NULL) {
                    del_RPNelement(obj_rpn->rpn[i]);
                }
            }
            free(obj_rpn->rpn);
        }
        free(obj_rpn);
    }
}

static char **split(const char *str, uint32_t *num_tokens) {
    if (str == NULL || num_tokens == NULL) {
        raise(SIGSEGV);
    }

    uint32_t ind_tokens_seq = 0;
    char **tokens_seq = (char **) malloc(sizeof(char *));
    VERIFY_CONTRACT(tokens_seq != NULL, "Unable to allocate memory");

    tokens_seq[ind_tokens_seq] = (char *) calloc(1, sizeof(char));
    VERIFY_CONTRACT(tokens_seq[ind_tokens_seq] != NULL, "Unable to allocate memory");

    uint32_t start_index = 0;
    uint32_t len = strlen(str);

    for (uint32_t i = 0; i < len; ++i) {
        if (str[i] != ' ') {
            start_index = i;
            break;
        }
    }

    uint32_t ind_token = 0;
    bool isintoken = false;

    for (uint32_t i = start_index; i < len; ++i) {
        if (str[i] != ' ') {
            tokens_seq[ind_tokens_seq][ind_token++] = str[i];

            tokens_seq[ind_tokens_seq] = realloc(tokens_seq[ind_tokens_seq], (ind_token + 1) * sizeof(char));
            VERIFY_CONTRACT(tokens_seq[ind_tokens_seq] != NULL, "Unable to allocate memory");

            isintoken = true;
        }
        if (str[i] == ' ' || i == len - 1) {
            if (isintoken) {
                tokens_seq[ind_tokens_seq][ind_token] = '\0';

                ++ind_tokens_seq;
                ind_token = 0;

                tokens_seq = (char **) realloc(tokens_seq, (ind_tokens_seq + 1) * sizeof(char *));
                VERIFY_CONTRACT(tokens_seq != NULL, "Unable to allocate memory");

                tokens_seq[ind_tokens_seq] = (char *) calloc(1, sizeof(char));
                VERIFY_CONTRACT(tokens_seq[ind_tokens_seq] != NULL, "Unable to allocate memory");

                isintoken = false;
            }
        }
    }

    free(tokens_seq[ind_tokens_seq]);

    *num_tokens = ind_tokens_seq;
    return tokens_seq;
}

static int matchesRegex(const char *string, const char *pattern) {
    if (string == NULL || pattern == NULL) {
        raise(SIGSEGV);
    }

    regex_t regex;
    int result;

    result = regcomp(&regex, pattern, REG_EXTENDED);
    VERIFY_CONTRACT(result != 1, "Could not compile regex");

    result = regexec(&regex, string, 0, NULL, 0);
    regfree(&regex);

    if (!result) {
        return 1;
    }
    else if (result == REG_NOMATCH) {
        return 0;
    }
    else {
        char error_msg[100];
        regerror(result, &regex, error_msg, sizeof(error_msg));
        fprintf(stderr, "Regex match failed: %s\n", error_msg);

        return 0;
    }
}
static bool isRPN(RPN *obj_rpn) {
    if (obj_rpn == NULL) {
        raise(SIGSEGV);
    }

    bool res = true;
    int32_t stack_size = 0;

    for (uint32_t i = 0; i < obj_rpn->size; ++i) {
        stack_size += 1;
        if (obj_rpn->rpn[i]->type == OPERATOR) {
            if (obj_rpn->rpn[i]->obj->operator->type == BINARY) {
                stack_size -= 2;
            }
            else if (obj_rpn->rpn[i]->obj->operator->type == UNARY) {
                stack_size -= 1;
            }
            else {
                VERIFY_CONTRACT(0, "Invalid operator type");
            }
        }

        if (stack_size <= 0) {
            res = false;
            break;
        }
    }

    if (stack_size != 1) {
        res = false;
    }

    return res;
}

static RPNelement *init_RPNelement(RPNelTypeLabel rpn_el_type) {
    RPNelement *rpn_el = (RPNelement *) malloc(sizeof(RPNelement));
    VERIFY_CONTRACT(rpn_el != NULL, "Unable to allocate memory");

    rpn_el->obj = (AnyRpnElType *) malloc(sizeof(AnyRpnElType));
    VERIFY_CONTRACT(rpn_el->obj != NULL, "Unable to allocate memory");

    if (rpn_el_type == OPERATOR) {
        rpn_el->type = OPERATOR;
        rpn_el->obj->operator = init_Operator(global_operator_name);
    }
    else if (rpn_el_type == OPERAND) {
        rpn_el->type = OPERAND;
        rpn_el->obj->operand = init_Operand(global_val);
    }
    else if (rpn_el_type == VARIABLE) {
        rpn_el->type = VARIABLE;
        rpn_el->obj->variable = init_Variable(global_str);
    }
    else {
        VERIFY_CONTRACT(0, "Invalid the RPN element type");
    }

    return rpn_el;
}
static void del_RPNelement(RPNelement *rpn_el) {
    if (rpn_el != NULL) {
        if (rpn_el->obj != NULL) {
            if (rpn_el->type == OPERATOR) {
                if (rpn_el->obj->operator != NULL) {
                    del_Operator(rpn_el->obj->operator);
                }
            }
            else if (rpn_el->type == OPERAND) {
                if (rpn_el->obj->operand != NULL) {
                    del_Operand(rpn_el->obj->operand);
                }
            }
            else if (rpn_el->type == VARIABLE) {
                if (rpn_el->obj->variable != NULL) {
                    del_Variable(rpn_el->obj->variable);
                }
            }
            free(rpn_el->obj);
        }
        free(rpn_el);
    }
}

static Operator *init_Operator(OperatorLabel operation_name) {
    Operator *operator = (Operator *) malloc(sizeof(Operator));
    VERIFY_CONTRACT(operator != NULL, "Unable to allocate memory");

    operator->obj = (AnyOperator *) malloc(sizeof(AnyOperator));
    VERIFY_CONTRACT(operator->obj != NULL, "Unable to allocate memory");

    if (EXP <= operation_name && operation_name <= SQRT) {
        operator->obj->unary = (Unary *) malloc(sizeof(Unary));
        VERIFY_CONTRACT(operator->obj->unary != NULL, "Unable to allocate memory");
        operator->obj->unary->type = operation_name;

        operator->type = UNARY;
        operator->obj->unary->func_ptr = (void *) global_unary_operators_ptrs[operation_name];
    }
    else if (ADD <= operation_name && operation_name <= POW) {
        operator->obj->binary = (Binary *) malloc(sizeof(Binary));
        VERIFY_CONTRACT(operator->obj->binary != NULL, "Unable to allocate memory");
        operator->obj->binary->type = operation_name;

        operator->type = BINARY;
    }
    else {
        VERIFY_CONTRACT(0, "Invalid operation");
    }

    return operator;
}
static void del_Operator(Operator *operator) {
    if (operator != NULL) {
        if (operator->obj != NULL) {
            if (operator->type == UNARY) {
                free(operator->obj->unary);
            } else {
                free(operator->obj->binary);
            }
            free(operator->obj);
        }
        free(operator);
    }
}

static Operand *init_Operand(double val) {
    Operand *operand = (Operand *) malloc(sizeof(Operand));
    VERIFY_CONTRACT(operand != NULL, "Unable to allocate memory");

    operand->obj = val;

    return operand;
}
static void del_Operand(Operand *operand) {
    if (operand != NULL) {
        free(operand);
    }
}

static Variable *init_Variable(const char *str) {
    if (str == NULL) {
        raise(SIGSEGV);
    }

    Variable *variable = (Variable *) malloc(sizeof(Variable));
    VERIFY_CONTRACT(variable != NULL, "Unable to allocate memory");

    variable->obj = (char *) calloc(strlen(str) + 1, sizeof(char));
    VERIFY_CONTRACT(variable->obj != NULL, "Unable to allocate memory");

    strcpy(variable->obj, str);

    return variable;
}
static void del_Variable(Variable *variable) {
    if (variable != NULL) {
        if (variable->obj != NULL) {
            free(variable->obj);
        }
        free(variable);
    }
}
