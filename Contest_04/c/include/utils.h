#ifndef UTILS_H
#define UTILS_H

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

#endif // UTILS_H   