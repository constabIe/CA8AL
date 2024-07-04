#include "function.h"
#include "utils.h"

#define REGEX_Q             15
#define UNARY_Q             7
#define CMD_SIZE            500
#define FUNC_NAME_SIZE      256
#define PATH_SIZE           256
#define FPUS_Q              256


static const char *global_regex[REGEX_Q] =
        {"^exp$", "^log$", "^sin$", "^cos$", "^tan$", "^cot$", "^sqrt$", "^\\+$", "^\\-$", "^\\*$", "^\\/+$",
         "^[-+]?([0-9]*[.])?[0-9]+([eE][-+]?\\d+)?$", "^pi$", "^e$",
         "^[a-zA-Z]+[0-9_]*$"};
static const void *global_unary_operators_ptrs[UNARY_Q] = {exp, log, sin, cos, tan, cot, sqrt};

static OperatorLabel global_operator_name;
static double global_val;
static char *global_str;

static char *global_functions_names[FUNC_NAME_SIZE];
static uint32_t global_func_names_quantity = 0;

static double global_fpus[FPUS_Q];
static uint32_t global_fpus_q = 0;

static uint32_t global_label_cntr = 0;
static void set_default_global_label_cntr() {
    global_label_cntr = 0;
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

static void add_func_name(const char *func_name) {
    if (func_name == NULL) { raise(SIGSEGV); }

    for (uint32_t i = 0; i < global_func_names_quantity; ++i) {
        VERIFY_CONTRACT(strcmp(global_functions_names[i], func_name) != 0, "The function name already used");
    }

    global_functions_names[global_func_names_quantity] = strdup(func_name);
    ++global_func_names_quantity;
}
static void add_fpu(double unit) {
    if (global_fpus_q <= FPUS_Q) {
        global_fpus[global_fpus_q++] = unit;
    }
}

// =====================================================================================================================

double cot(double x) {
    return 1 / tan(x);
}

void init_Function(const char *raw_rpn, const char *func_name) {
    add_func_name(func_name);

    RPN *func_rpn = init_RPN(raw_rpn);
    VERIFY_CONTRACT(func_rpn != NULL, "Unable to allocate memory");

    char command[CMD_SIZE];
    memset(command, 0, sizeof(command));
    const char *prefix_command = "make touch_function FUNCNAME=";
    snprintf(command, sizeof(command), "%s%s", prefix_command, func_name);

    VERIFY_CONTRACT(system(command) != -1, "The error was raised after an attempt to initialize the shell command");

    const char *prefix_path = "functions_implementation/";
    char path[PATH_SIZE];
    const char *suffix_path = ".asm";

    snprintf(path, sizeof(path), "%s%s%s", prefix_path, func_name, suffix_path);

    FILE *output = fopen(path, "w");

    intel_asm_cdecl_function_definition_start_template(output, func_name);
    set_default_global_label_cntr();

    for (uint32_t i = 0; i < func_rpn->size; ++i) {
        if (func_rpn->rpn[i]->type == OPERATOR) {
            if (func_rpn->rpn[i]->obj->operator->type == BINARY) {
                intel_asm_load_fpu_template(output);
                intel_asm_load_fpu_template(output);
                intel_asm_call_binary_operator(output, func_rpn->rpn[i]->obj->operator->obj->binary->type);
                intel_asm_UPload_fpu_template(output);
            }
            else {
                intel_asm_load_fpu_template(output);
                intel_asm_call_unary_operator(output, func_rpn->rpn[i]->obj->operator->obj->unary->type);
                intel_asm_UPload_fpu_template(output);
            }
        }
        else if (func_rpn->rpn[i]->type == OPERAND) {
            add_fpu(1);
            add_fpu(func_rpn->rpn[i]->obj->operand->obj);
        }
        else {
            add_fpu(0);
            add_fpu(0);
        }
    }

    intel_asm_cdecl_function_definition_end_template(output);
    fclose(output);

    del_RPN(func_rpn);
}
//void del_Function(Function *function) {
//    if (function != NULL) {
//        if (function->raw_func != NULL) {
//            del_RawFunction(function->raw_func);
//        }
//        free(function);
//    }
//}

void intel_asm_cdecl_function_definition_start_template(FILE *output, const char *func_name) {
    if (output == NULL) { raise(SIGSEGV); }

    fprintf(output, "%s", "bits 32\n");

    fprintf(output, "%s", "extern exp, log, sin, cos, tan, cot, sqrt, pow\n");

    fprintf(output, "%s", "%macro ALIGN_STACK 1.nolist\n");
    fprintf(output, "%s", "\tsub \tesp, %1\n");
    fprintf(output, "%s", "\tand \tesp, 0xfffffff0\n");
    fprintf(output, "%s", "\tadd \tesp, %1\n");
    fprintf(output, "%s", "%endmacro\n");

    fprintf(output, "%s", "%macro UNALIGN_STACK 1.nolist\n");
    fprintf(output, "%s", "\tadd \tesp, %1\n");
    fprintf(output, "%s", "%endmacro\n");

    fprintf(output, "%s", "%macro FUNCTION_PROLOGUE 1.nolist\n");
    fprintf(output, "%s", "\tenter   %1, 0\n");
    fprintf(output, "%s", "\tand \tesp, 0xfffffff0\n");
    fprintf(output, "%s", "%endmacro\n");

    fprintf(output, "%s", "%macro FUNCTION_EPILOGUE 0.nolist\n");
    fprintf(output, "%s", "\tleave\n");
    fprintf(output, "%s", "%endmacro\n");

    fprintf(output, "%s", "%define val\t\t\tebp + 8\n");
    fprintf(output, "%s", "%define tmp_ebx\t\tebp - 4\n");
    fprintf(output, "%s", "%define tmp_edi\t\tebp - 12\n");
    fprintf(output, "%s", "%define tmp_esi\t\tebp - 16\n");
    fprintf(output, "%s", "%define fpu_ctrl\tebp - 20\n");

    fprintf(output, "global %s\n", func_name);
    fprintf(output, "%s:\n", func_name);
    fprintf(output, "%s", "\tFUNCTION_PROLOGUE 20\n");
    fprintf(output, "%s", "\tmov \t[tmp_ebx], ebx\n");
    fprintf(output, "%s", "\tmov \t[tmp_edi], edi\n");
    fprintf(output, "%s", "\tmov \t[tmp_esi], esi\n");

    fprintf(output, "%s", "\tmov \tebx, fpus\n");

    fprintf(output, "%s", "\tfinit\n");
    fprintf(output, "%s", "\tfstcw\tword [fpu_ctrl]\n");
}
void intel_asm_cdecl_function_definition_end_template(FILE *output) {
    if (output == NULL) { raise(SIGSEGV); }

    intel_asm_load_fpu_template(output);

    fprintf(output, "%s", "\tfldcw   word [fpu_ctrl]\n");
    fprintf(output, "%s", "\tFUNCTION_EPILOGUE\n");
    fprintf(output, "%s", "\tret\n");

    fprintf(output, "%s", "section .data\n");
    fprintf(output, "%s", "\tQWORD_SIZE  \tequ     8\n");

    fprintf(output, "%s", "section .data\n");
    fprintf(output, "%s", "\tfpus\t\tdq      ");

    for (uint32_t i = 0; i < global_fpus_q - 1; ++i) {
        fprintf(output, "%lf, ", global_fpus[i]);
    }
    fprintf(output, "%lf", global_fpus[global_fpus_q - 1]);
}

void intel_asm_load_fpu_template(FILE *output) {
    if (output == NULL) { raise(SIGSEGV); }

    const char *label_1 = "cont_";
    char token_1[7];
    snprintf(token_1, sizeof(token_1), "%s", label_1);
    token_1[5] = (char) (global_label_cntr + 49);
    token_1[6] = '\0';

    const char *label_2 = "operand_";
    char token_2[10];
    snprintf(token_2, sizeof(token_2), "%s", label_2);
    token_2[8] = (char) (global_label_cntr + 49);
    token_2[9] = '\0';

    const char *label_3 = "val_";
    char token_3[6];
    snprintf(token_3, sizeof(token_3), "%s", label_3);
    token_3[4] = (char) (global_label_cntr + 49);
    token_3[5] = '\0';

    fprintf(output, "%s", "\tlea \tedi, [ebx]\n");
    fprintf(output, "%s", "\tfld \tqword [edi]\n");
    fprintf(output, "%s", "\tadd \tebx, QWORD_SIZE\n");
    fprintf(output, "%s", "\tfld1\n");
    fprintf(output, "%s", "\tfcompp\n");
    fprintf(output, "%s", "\tfstsw\tax\n");
    fprintf(output, "%s", "\tsahf\n");
    fprintf(output, "\tje  \t.%s\n", token_2);
    fprintf(output, "\tjne \t.%s\n", token_3);
    fprintf(output, "\t.%s:\n", token_2);
    fprintf(output, "%s", "\t\tlea \tedi, [ebx]\n");
    fprintf(output, "%s", "\t\tfld \tqword [edi]\n");
    fprintf(output, "%s", "\t\tadd \tebx, QWORD_SIZE\n");
    fprintf(output,       "\t\tjmp \t.%s\n", token_1);

    fprintf(output, "\t.%s:\n", token_3);
    fprintf(output, "%s", "\t\tfld \tqword [val]\n");
    fprintf(output, "\t\tjmp \t.%s\n", token_1);
    fprintf(output, ".%s:\n", token_1);

    ++global_label_cntr;
}
void intel_asm_UPload_fpu_template(FILE *output) {
    if (output == NULL) { raise(SIGSEGV); }

    fprintf(output, "%s", "\tsub \tebx, QWORD_SIZE\n");
    fprintf(output, "%s", "\tfstp\tqword [ebx]\n");
    fprintf(output, "%s", "\tsub \tebx, QWORD_SIZE\n");
    fprintf(output, "%s", "\tfld1\n");
    fprintf(output, "%s", "\tfstp\tqword [ebx]\n");
}

void intel_asm_call_binary_operator(FILE *output, OperatorLabel label) {
    if (output == NULL) { raise(SIGSEGV); }

    switch (label) {
        case (ADD):
            fprintf(output, "%s", "\tfaddp\n");
            break;
        case (SUB):
            fprintf(output, "%s", "\tfsubrp\n");
            break;
        case (MUL):
            fprintf(output, "%s", "\tfmulp\n");
            break;
        case (DIV):
            fprintf(output, "%s", "\tfdivrp\n");
            break;
        default:
            fprintf(output, "%s", "\tALIGN_STACK 16\n");
            fprintf(output, "%s", "\tsub \tesp, 8\n");
            fprintf(output, "%s", "\tfstp\tqword [esp]\n");
            fprintf(output, "%s", "\tsub \tesp, 8\n");
            fprintf(output, "%s", "\tfstp\tqword [esp]\n");
            fprintf(output, "%s", "\tcall \tpow\n");
            fprintf(output, "%s", "\tUNALIGN_STACK 16\n");
            break;
    }
//    if (label == ADD) {
//        fprintf(output, "%s", "\tfaddp\n");
//    }
//    else if (label == SUB) {
//        fprintf(output, "%s", "\tfsubrp\n");
//    }
//    else if (label == MUL) {
//        fprintf(output, "%s", "\tfmulp\n");
//    }
//    else if (label == DIV) {
//        fprintf(output, "%s", "\tfdivrp\n");
//    }
//    else {
//        fprintf(output, "%s", "\tALIGN_STACK 16\n");
//        fprintf(output, "%s", "\tsub		esp, 8\n");
//        fprintf(output, "%s", "\tfstp	qword [esp]\n");
//        fprintf(output, "%s", "\tsub		esp, 8\n");
//        fprintf(output, "%s", "\tfstp	qword [esp]\n");
//        fprintf(output, "%s", "\tcall	pow\n");
//        fprintf(output, "%s", "\tUNALIGN_STACK 16\n");
//    }
}
void intel_asm_call_unary_operator(FILE *output, OperatorLabel label) {
    fprintf(output, "%s", "\tALIGN_STACK 16");
    fprintf(output, "%s", "\tsub \tesp, 8");
    fprintf(output, "%s", "\tfstp\tqword [esp]");
    fprintf(output, "%s", "\tsub \tesp, 8");
    fprintf(output, "%s", "\tfstp\tqword [esp]");
    switch (label) {
        case EXP:
            fprintf(output, "%s", "\tcall \texp");
            break;
        case LOG:
            fprintf(output, "%s", "\tcall \tlog");
            break;
        case SIN:
            fprintf(output, "%s", "\tcall \tsin");
            break;
        case COS:
            fprintf(output, "%s", "\tcall \tcos");
            break;
        case TAN:
            fprintf(output, "%s", "\tcall \ttan");
            break;
        case COT:
            fprintf(output, "%s", "\tcall \tcot");
            break;
        case SQRT:
            fprintf(output, "%s", "\tcall \tsqrt");
            break;
        default:
            VERIFY_CONTRACT(0, "Invalid operator label");
    }
    fprintf(output, "%s", "\tUNALIGN_STACK 16");
}

//RawFunction *init_RawFunction(const char *raw_rpn) {
//    RawFunction *function = (RawFunction *) malloc(sizeof(RawFunction));
//    VERIFY_CONTRACT(function != NULL, "Unable to allocate memory");
//
//    function->obj_rpn = init_RPN(raw_rpn);
//    function->obj_var = NULL;
//
//    bool isvarset = false;
//    for (uint32_t i = 0; i < function->obj_rpn->size; ++i) {
//        if (function->obj_rpn->rpn[i]->type == VARIABLE) {
//            if (!isvarset) {
//                function->obj_var = init_Variable(function->obj_rpn->rpn[i]->obj->variable->obj);
//                isvarset = true;
//            }
//            else {
//                VERIFY_CONTRACT(0, "Only R^2 dimension");
//            }
//        }
//    }
//
//    return function;
//}
//void del_RawFunction(RawFunction *function) {
//    if (function != NULL) {
//        if (function->obj_rpn != NULL) {
//            del_RPN(function->obj_rpn);
//        }
//        if (function->obj_var != NULL) {
//            del_Variable(function->obj_var);
//        }
//        free(function);
//    }
//}

RPN *init_RPN(const char *raw_rpn) {
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
        VERIFY_CONTRACT(match, "Incorrect symbolss for the RPN");

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
void del_RPN(RPN *obj_rpn) {
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

char **split(const char *str, uint32_t *num_tokens) {
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
bool matchesRegex(const char *string, const char *pattern) {
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
        return true;
    }
    else if (result == REG_NOMATCH) {
        return false;
    }
    else {
        char error_msg[100];
        regerror(result, &regex, error_msg, sizeof(error_msg));
        fprintf(stderr, "Regex match failed: %s\n", error_msg);

        return false;
    }
}
bool isRPN(RPN *obj_rpn) {
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

RPNelement *init_RPNelement(RPNelTypeLabel rpn_el_type) {
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
void del_RPNelement(RPNelement *rpn_el) {
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

Operator *init_Operator(OperatorLabel operation_name) {
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
void del_Operator(Operator *operator) {
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

Operand *init_Operand(double val) {
    Operand *operand = (Operand *) malloc(sizeof(Operand));
    VERIFY_CONTRACT(operand != NULL, "Unable to allocate memory");

    operand->obj = val;

    return operand;
}
void del_Operand(Operand *operand) {
    if (operand != NULL) {
        free(operand);
    }
}

Variable *init_Variable(const char *str) {
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
void del_Variable(Variable *variable) {
    if (variable != NULL) {
        if (variable->obj != NULL) {
            free(variable->obj);
        }
        free(variable);
    }
}
